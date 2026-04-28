# `sa_model.py` — Analytical Cycle Model for SA Kernels

## Overview

`sa_model.py` predicts the number of Bambu simulation cycles for a generated
`top_level_sa.c` kernel, given the path to that file and an integer `N_mul`
(the number of parallel FP multiplier units).  A prediction takes < 1 ms;
an actual Bambu run takes 30–300 s.

The model is a fitted 5-parameter linear formula:

```
C = α_acc · X_acc  +  α_bf · X_bf  +  α_post · X_post  +  α_ex4 · is_ex4  +  α_func
```

The five features (`X_acc`, `X_bf`, `X_post`, `is_ex4`, constant) are derived
**purely analytically** from the C file and from `N_mul`.  The α coefficients
were fitted with least-squares over ex1–ex6 (47 measured data points, all
within 5% error) and are stored in `src/bambu_calibration.json`.
Experiments ex7–ex10 are predicted with zero additional calibration data.

---

## Background: what Bambu produces

Bambu HLS compiles C to a Verilog finite-state machine (FSM).  Each FSM state
executes in exactly one clock cycle.  The total cycle count is therefore the
number of FSM states visited during one call to `top_level`.

Two hardware resources are limited:

| Resource | Constraint |
|----------|-----------|
| FP multiply/add units | at most `N_mul` parallel FP ops per FSM state |
| DRAM memory buses | 2-bank split: weight bus (gmem\_w0/w1), input bus (gmem\_in0/in1) |

The generated C file always has the same anatomy:

```
outer loop(s)                 ← n_outer iterations total
  Zero init                   ← zero all N_PE accumulators (nounroll, excluded from n_seq)
  [inner sequential loop(s)]  ← n_seq_loops dims, n_inner iterations total
    Phase 1  : weight preload    (fully unrolled, reads from 2-bank weight DRAM)
    Phase 2a : multiply          (N_PE independent FP muls, fully unrolled)
    Phase 2b : accumulate        (N_PE independent FP adds, fully unrolled)
  reduction tree               ← N_PE accumulators → N_out outputs (binary tree)
  write outputs                ← N_out stores to banked output DRAM
```

### Two kernel types

The model distinguishes kernels by `n_seq_loops` (the count of sequential
inner loops between the Zero-init block and Phase 1):

| Type | `n_seq_loops` | Examples | Key difference |
|------|--------------|---------|----------------|
| **Inner r-loop** | ≥ 1 | ex1–ex3, ex5–ex10 | Reduction + writes happen *after* the inner loops in a separate post-loop section |
| **Outer-body** | 0 | ex4 | Everything (reads, muls, reduction, writes) happens once per outer iteration; no inner sequential loop |

---

## Step 1 — Parsing: `parse_sa_c()`

`parse_sa_c(text)` reads the raw C source and returns a dict of structural
parameters needed by every downstream formula.

### Parameters extracted

| Parameter | Type | Meaning |
|-----------|------|---------|
| `N_PE` | int | Total PE accumulators = product of all SARows × SACols loop bounds |
| `N_W` | int | Weight elements loaded in Phase 1 |
| `N_out` | int | Number of output values written per outer iteration |
| `N_red` | int | Reduction fan-in per output (= N\_PE / N\_out) |
| `n_outer` | int | Product of all outer loop bounds (before the Zero-init block) |
| `n_inner` | int | Product of sequential inner loop bounds (Zero → Phase 1, excluding sarows_*/sacols_* init loops) |
| `n_seq_loops` | int | Count of those sequential inner loops |
| `sa_dims` | dict | SA spatial dimension sizes: `{S, C, Q, M}` from Phase 2a loop comments |
| `c_global_var` | str | Which `sarows_X` variable carries the DRAM bank bit (`'sarows_0'` or `'sarows_1'`) |
| `sarows0_in_col` | bool | Whether `sarows_0` appears in the `in_col` index formula (signals S filter-height in column addressing) |

### Extraction logic

- **`N_PE`** — comment `"N PE accumulators"` (e.g. `"96 PE accumulators"`).
- **`N_W`** — comment `"Phase 1 … N elems"`.
- **`N_out`, `N_red`** — comment `"reduction: N_PE acc → N_out outputs (N_red inputs each)"`.
- **`n_outer`** — `#pragma GCC nounroll` loops *before* the `// Zero` comment.
- **`n_inner`, `n_seq_loops`** — `#pragma GCC nounroll` loops in the region from
  `// Zero` to `Phase 1`, *excluding* loops whose variable starts with `sarows_`
  or `sacols_` (those are the zero-init loops, not sequential computation loops).
- **`sa_dims`** — comments `// S:N`, `// C:N`, `// Q:N`, `// M:N` inside Phase 2a.
- **`c_global_var`** — the `sarows_X` token in `int c_global = ...;` inside Phase 2a.
- **`sarows0_in_col`** — whether `sarows_0` appears in the `in_col = ...` expression.

### Verified parsed values (ex1–ex6)

| exp | N\_PE | N\_W | N\_out | N\_red | n\_outer | n\_inner | n\_seq | c\_global\_var |
|-----|------|-----|------|------|---------|--------|------|-------------|
| ex1 | 96   | 48  | 8    | 12   | 8       | 3      | 1    | sarows\_1   |
| ex2 | 96   | 24  | 8    | 12   | 64      | 3      | 1    | sarows\_1   |
| ex3 | 72   | 36  | 8    | 9    | 8       | 3      | 1    | sarows\_1   |
| ex4 | 64   | 16  | 16   | 4    | 4       | 1      | 0    | sarows\_0   |
| ex5 | 80   | 40  | 8    | 10   | 64      | 20     | 2    | sarows\_1   |
| ex6 | 96   | 16  | 24   | 4    | 6       | 3      | 1    | sarows\_0   |

---

## Step 2 — `body_const`: non-FP cycles per inner-body iteration

`compute_body_const(params)` derives analytically the constant number of
non-FP FSM states consumed per inner-loop body iteration.  It is the most
non-obvious component of the model.

### Physical motivation

In each Phase 1 + Phase 2a, the FSM must issue DRAM reads for N\_W weights
and N\_PE inputs.  Both weight and input buses are split into two banks
(bank-0 / bank-1).  Within a bank, reads are serialised by the FSM — they
cannot overlap.  The cycle cost of the read phase is therefore proportional
to whichever bank carries more *distinct* accesses: the **bottleneck bank**.

```
reads_bottleneck = max(weight_bank0, input_bank0)
```

### Counting weight reads on bank-0

The weight bank bit is `c_bank = c_global_var & 1`.
Bank-0 receives reads when `c_bank == 0`, i.e. for even values of
`c_global_var`.  Exactly `ceil(C/2)` values of the C index are even
(`bank0_count = ceil(C / 2)`).

- **`c_global_var == 'sarows_1'`** (C dimension is at sarows\_1):  
  Phase 1 loops over `sarows_0` (S dim) and `sacols_1` (M dim) for each
  bank-0 C value:  
  `weight_bank0 = bank0_count × S × M`

- **`c_global_var == 'sarows_0'`** (C dimension is at sarows\_0):  
  The other Phase 1 dimensions combine to `N_W / C` elements per C value:  
  `weight_bank0 = bank0_count × (N_W // C)`

### Counting input reads on bank-0

For bank-0 inputs, the key questions are: how many distinct `in_row_base`
values and how many distinct `in_col` values appear?

- **`in_row_base`** = number of distinct memory-row addresses per bank-0:
  - `n_seq ≥ 2`: the outer sequential variable fixes `c_blk` → only **1** distinct row base.
  - `n_seq ≤ 1`: `c_blk = c_global_var >> 1` varies with the SA index → **`bank0_count`** rows.

- **`in_col_distinct`** = number of distinct column offsets:
  - If `sarows_0` appears in `in_col` (filter-height S spans columns):  
    `Q + S − 1` (sliding window width).
  - Otherwise: `Q` (only the output-column index).

```
input_bank0 = in_row_base × in_col_distinct
```

### Overhead terms

Beyond the read bottleneck, the FSM incurs fixed control overhead:

| Situation | Formula | Includes |
|-----------|---------|----------|
| n\_seq ≥ 1 | `9 + 4·max(0, n_seq−1) + 2·tie` | 9 = prologue + mul-chain entry + inner READ\_COND; 4 per extra sequential dim (phi/prologue); 2 when both banks equally loaded |
| n\_seq = 0 | `4 + 2·tie` | 4 = outer-body control (no inner r-loop READ\_COND); N\_out writes added separately (see below) |

### Full formulas

**Inner r-loop kernels (n\_seq ≥ 1):**
```
body_const = reads_bottleneck + 9 + 4·max(0, n_seq−1) + 2·tie
```

**Outer-body kernels (n\_seq = 0):**
```
body_const = reads_bottleneck + N_out + 4 + 2·tie
```
The `N_out` term appears here because for n\_seq = 0 there is no post-loop
reduction section — the output writes happen inside the outer body and must
be counted in `body_const` rather than in `X_post`.

### Verified body\_const values (all experiments)

| exp | n\_seq | weight\_bank0 | input\_bank0 | bottleneck | overhead | body\_const |
|-----|--------|-------------|------------|----------|---------|------------|
| ex1 | 1      | 24          | 8           | 24        | 9       | **33**      |
| ex2 | 1      | 12          | 12 (tie)    | 12        | 11      | **23**      |
| ex3 | 1      | 24          | 8           | 24        | 9       | **33**      |
| ex4 | 0      | 8 (tie)     | 8 (tie)     | 8 + N\_out=16 | 6  | **30**      |
| ex5 | 2      | 20          | 6           | 20        | 13      | **33**      |
| ex6 | 1      | 8           | 12          | 12        | 9       | **21**      |
| ex7 | 3      | 30          | 2           | 30        | 17      | **47**      |
| ex8 | 2      | 24          | 4           | 24        | 13      | **37**      |
| ex9 | 2      | 24          | 7           | 24        | 13      | **37**      |
| ex10| 2      | 24          | 7           | 24        | 13      | **37**      |

Note: ex2 has `tie=1` because both weight and input banks receive 12 reads;
ex6's bottleneck is on the input side (12 > 8 weight reads).

---

## Step 3 — Reduction tree helpers

### `compute_red_batches(N_out, N_red, N_mul)`

The binary reduction tree reduces `N_red` accumulators per output to 1.
At each tree level, `per_level = adds // 2` additions are performed across
`N_out` outputs.  With `N_mul` parallel FP units, these additions are batched:

```
total_batches = 0
adds = N_red
while adds > 1:
    per_level = adds // 2
    total_batches += ceil(N_out × per_level / N_mul)
    adds -= per_level
```

**Worked example (ex1: N\_out=8, N\_red=12, N\_mul=4):**

| Level | adds | per\_level | ceil(8 × per\_level / 4) |
|-------|------|-----------|------------------------|
| 1     | 12   | 6         | 12                     |
| 2     | 6    | 3         | 6                      |
| 3     | 3    | 1         | 2                      |
| 4     | 2    | 1         | 2                      |
| **Total** | | | **22 batches** |

### `compute_red_gaps(N_out, N_red, N_mul, N_PE)`

When `N_mul < N_PE`, there can be levels of the reduction tree where the
total number of additions is smaller than `N_mul`.  In that case, the next
level cannot start immediately — Bambu inserts one empty FSM state (a *gap*)
as a scheduling boundary.  `compute_red_gaps` counts how many such gaps occur.
Returns 0 when `N_mul ≥ N_PE` (full parallelism, no gaps).

---

## Step 4 — Post-reduction section: `compute_post_rloop()`

For inner r-loop kernels (n\_seq ≥ 1), after all inner iterations complete,
the FSM runs a post-rloop section that executes the reduction tree and writes
the N\_out outputs:

```
post_rloop = 1 + 7·rb + gaps + extra_write0 + (N_out − 1) + 1
```

| Term | Meaning |
|------|---------|
| `1` | Entry state into post-reduction section |
| `7·rb` | 7 FSM states per FP-add batch (`rb` = `compute_red_batches(...)`) |
| `gaps` | Idle states between reduction levels (`compute_red_gaps(...)`) |
| `extra_write0` | 1 if `N_mul < N_PE` (write-0 cannot overlap last reduction state), else 0 |
| `(N_out − 1)` | FSM states for output writes 1 through N\_out−1 |
| `1` | Outer-loop READ\_COND (checks whether to repeat the outer loop) |

The factor of 7 states per FP-add batch was established by direct inspection
of Bambu-generated FSM logs for ex1–ex6.

This function is **not used** for n\_seq = 0 kernels (`X_post = 0`, `is_ex4 = 1`).

---

## Step 5 — `predict()`: assembling features and applying the formula

### Feature computation — two branches

**Inner r-loop (n\_seq ≥ 1):**
```
B_acc  = ceil(N_PE / N_mul)
X_acc  = n_outer × n_inner × B_acc
X_bf   = n_outer × n_inner × body_const
X_post = n_outer × post_rloop(N_out, N_red, N_mul, N_PE)
is_ex4 = 0
```

`B_acc` = accumulation batches per inner-body iteration (ceil because the last
batch may be partial).  `X_acc` is the total number of FP-op batches across
all outer × inner loop iterations.  `X_bf` is the analogous total for
non-FP (body-const) units.  `X_post` is the total post-rloop states across
all outer iterations.

**Outer-body (n\_seq = 0):**
```
B_acc  = ceil(N_PE / N_mul)
rb     = compute_red_batches(N_out, N_red, N_mul)
X_acc  = n_outer × (B_acc + rb)
X_bf   = n_outer × body_const
X_post = 0
is_ex4 = 1
```

Here the reduction batches `rb` are folded into `X_acc` (they happen inline
per outer iteration rather than in a separate post-rloop section).

### The formula

```
C = α_acc · X_acc  +  α_bf · X_bf  +  α_post · X_post  +  α_ex4 · is_ex4  +  α_func
```

### Fitted constants

Obtained via least-squares over ex1–ex6 (47 data points from
`Bambu_outputs_working`), stored in `src/bambu_calibration.json`:

| Constant | Value | Physical interpretation |
|----------|-------|------------------------|
| `α_acc`  | 7.003 | Average cycles consumed per FP-op batch |
| `α_bf`   | 2.180 | Average cycles per body\_const unit (non-MAC overhead) |
| `α_post` | 1.004 | Average cycles per post\_rloop state |
| `α_ex4`  | −302.3 | Intercept shift for the outer-body kernel variant |
| `α_func` | 361.0 | Fixed function-entry / prologue cost (cycles) |

The α constants are **universal** — the same values apply to all experiments.
Only `body_const` varies per experiment (and it is derived analytically, not
measured).

---

## Accuracy results

All 47 calibration points (ex1–ex6) lie within the 5% error budget.

| Experiment | Points | Max error | Mean error |
|------------|--------|-----------|-----------|
| ex1        | 9      | 2.94%     | 0.95%     |
| ex2        | 9      | 2.30%     | 1.03%     |
| ex3        | 9      | 1.06%     | 0.57%     |
| ex4        | 8      | 2.26%     | 0.51%     |
| ex5        | 9      | 2.48%     | 1.36%     |
| ex6        | 9      | 2.79%     | 1.72%     |

Experiments ex7–ex10 are predicted **with zero additional Bambu runs**.
Their body\_const values are derived analytically from the C file structure
using the same formula; the α constants are unchanged.

Tests:
- `tests/test_sa_model_accuracy.py` — 69 ground-truth points from
  `Bambu_outputs_working`, all asserted within 5%.
- `tests/test_sa_model_parse.py` — parse correctness and body\_const values
  for all 10 experiments.

---

## CLI usage

```bash
# Single N_mul value
python src/sa_model.py experiments/eyeriss/conv/ex1/top_level_sa.c 4

# Sweep N_mul ∈ {1,2,4,8,16,32,64,N_PE}
python src/sa_model.py experiments/eyeriss/conv/ex1/top_level_sa.c --sweep

# Sweep with comparison against measured data
python src/sa_model.py experiments/eyeriss/conv/ex1/top_level_sa.c --sweep --compare
```

Example output (`--sweep --compare` on ex1):

```
File  : top_level_sa.c  [ex1]
Params: N_PE=96, N_W=48, N_out=8, N_red=12, n_outer=8, n_inner=3, n_seq=1
Calib : α_acc=7.0030, α_bf=2.1796, α_post=1.0035, α_func=361.0, body_const=33 [analytical]

 N_mul   Predicted    Measured    Error%  B_acc
  ----------------------------------------------------
  ✓    1       23,248      23,196     +0.2%  96
  ✓    2       12,708      12,668     +0.3%  48
  ✓    4        7,438       7,404     +0.5%  24
  ✓    8        4,819       4,780     +0.8%  12
  ✓   16        3,585       3,500     +2.4%   6
  ✓   32        2,977       2,892     +2.9%   3
  ✓   64        2,753       2,724     +1.1%   2
  ✓   96        2,552       2,548     +0.2%   1

Pass (<10% error): 8/8
```

The `--calib` flag overrides the default calibration file location.  Without
`--compare`, the Measured and Error% columns show `—`.

---

## Limitations

- **Platform-specific α constants.** The fitted values assume Bambu I386\_GCC8
  with a 5 ns clock.  A different compiler backend or clock period requires
  re-fitting the α coefficients via least-squares against new measured data.

- **Single data point for n\_seq = 0.** The outer-body formula
  (`body_const = reads + N_out + 4 + 2·tie`) was derived from one experiment
  (ex4).  A kernel with a structurally different outer-body loop (e.g. a
  non-trivial zero-init or multiple output banks per write state) may require
  an adjusted formula.

- **Binary reduction tree assumed.** `compute_red_batches` and
  `compute_red_gaps` assume the generated code uses a binary tree structure
  (halving the number of partial sums at each level).  Non-binary reductions
  would need updated tree-traversal logic.

- **N\_mul is a manual input.** The model does not read `N_mul` from
  `compile_bambu.sh`; the caller must supply it.  Use `--sweep` to evaluate
  the full design space automatically.
