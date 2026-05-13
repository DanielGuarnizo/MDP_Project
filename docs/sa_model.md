# `sa_model.py` — Analytical Cycle Model for SA Kernels

## Overview

`sa_model.py` predicts the number of Bambu simulation cycles for a generated
`top_level_sa.c` kernel, given the path to that file and an integer `N_mul`
(the number of parallel FP multiplier units).  A prediction takes < 1 ms;
an actual Bambu compile + simulate run takes 30–300 s.

The model is a **platform-aware, 4-parameter linear formula**:

```
C = α_acc · X_acc  +  α_bf · X_bf  +  α_post · X_post  +  α_func
```

The four features (`X_acc`, `X_bf`, `X_post`, constant) are derived
**purely analytically** from the C source and from `N_mul`.  The α coefficients
are platform-specific, fitted with least-squares over measured Bambu cycle
counts, and stored per-platform in `src/bambu_calibration.json`.

> **Legacy note.** An optional additive term `α_outer_body · is_outer_body`
> survives for old platforms (e.g. `I386_GCC8|5|default`) where a single
> serialised output port inflates `X_bf` for n\_seq=0 kernels.  It reads as
> `0.0` from any platform entry that does not store the field, so it has no
> effect on newly calibrated platforms.

---

## Platform awareness

Every `top_level_sa.c` lives next to a `config.json` (in the same directory
or its parent) that records the Bambu invocation parameters:

```json
{
  "bambu": {
    "compiler":     "I386_GCC8",
    "clock_period": 5,
    "device":       { "name": "xc7z020-1clg484-VVD" }
  }
}
```

`_load_config(c_path)` finds that file, and `_platform_key(cfg)` converts it
to a lookup key:

```
"{compiler}|{clock_period}|{device.name}"
```

e.g. `"I386_GCC8|5|xc7z020-1clg484-VVD"`.  When the device field is absent
the key ends with `|default`.

`load_calib(calib_path, ex_key, platform_key)` looks up the matching entry in
`bambu_calibration.json`.  If no entry exists the model exits with a clear
message listing the available platforms.  When `platform_key` is omitted it is
inferred from the `experiments` dict in the JSON (keyed by ex_key); when
neither is supplied it falls back to the first platform in the file.

### `bambu_calibration.json` structure

```json
{
  "platforms": {
    "I386_GCC8|5|xc7z020-1clg484-VVD": {
      "note": "...",
      "alpha_acc":        6.98474554,
      "alpha_body_fixed": 2.03070650,
      "alpha_post":       1.01183835,
      "alpha_func":       209.5892,
      "P_write":          null,
      "r2":               0.9999885226
    },
    "I386_GCC8|5|default": {
      "note": "...",
      "alpha_acc":        7.00302868,
      "alpha_body_fixed": 2.17961750,
      "alpha_post":       1.00352452,
      "alpha_func":       361.0141,
      "alpha_outer_body": -302.304
    }
  },
  "experiments": {
    "ex1": {
      "platform": "I386_GCC8|5|default",
      "C_sat": 2548,
      "measured_cycles": { "1": 23196, "2": 12668, ... }
    },
    ...
  }
}
```

The `experiments` block stores the measured data used during fitting and looked
up by `--compare` when no local Bambu XML files are present.

### Currently calibrated platforms

| Platform key | Device | Fitted from | Points | R² |
|---|---|---|---|---|
| `I386_GCC8\|5\|default` | (none / soft) | ex1–ex6 (JSON) | 47 | — |
| `I386_GCC8\|5\|xc7z020-1clg484-VVD` | Zynq-7020 | ex1 + ex4 (XML) | 16 | 0.99999 |
| `I386_GCC8\|5\|xcu55c-2Lfsvh2892-VVD` | Ultrascale+ | ex11 (XML) | 7 | 0.99994 |

---

## Background: what Bambu produces

Bambu HLS compiles C to a Verilog finite-state machine (FSM).  Each FSM state
executes in exactly one clock cycle.  The total cycle count is the number of
FSM states visited during one call to `top_level`.

Two hardware resources are limited:

| Resource | Constraint |
|---|---|
| FP multiply/add units | at most `N_mul` parallel FP ops per FSM state |
| DRAM memory buses | `input_ports`-way banked: weight bus and input bus share the same banking width; output bus has `P_out` physical ports |

The generated C file always has the same anatomy:

```
outer loop(s)                 ← n_outer iterations total
  Zero init                   ← zero all N_PE accumulators (nounroll, excluded from n_seq)
  [inner sequential loop(s)]  ← n_seq_loops dims, n_inner iterations total
    Phase 1  : weight preload    (fully unrolled, reads from banked weight DRAM)
    Phase 2a : multiply          (N_PE independent FP muls, fully unrolled)
    Phase 2b : accumulate        (N_PE independent FP adds, fully unrolled)
  reduction tree               ← N_PE accumulators → N_out outputs (binary tree)
  write outputs                ← N_out stores to P_out banked output DRAM ports
```

### Two kernel types

The model distinguishes kernels by `n_seq_loops` (the count of sequential
inner loops between the Zero-init block and Phase 1):

| Type | `n_seq_loops` | Examples | Key difference |
|---|---|---|---|
| **Inner r-loop** | ≥ 1 | ex1–ex3, ex5–ex11 | Reduction + writes happen *after* all inner iterations in a separate post-loop section |
| **Outer-body** | 0 | ex4 | Everything (reads, muls, reduction, writes) happens once per outer iteration; no inner sequential loop |

---

## Step 1 — Parsing: `parse_sa_c()`

`parse_sa_c(text)` reads the raw C source and returns a parameter dict.

### Parameters extracted

| Parameter | Type | Meaning |
|---|---|---|
| `N_PE` | int | Total PE accumulators = product of all SARows × SACols loop bounds |
| `N_W` | int | Weight elements loaded in Phase 1 |
| `N_out` | int | Number of output values written per outer iteration |
| `N_red` | int | Reduction fan-in per output (= N\_PE / N\_out) |
| `n_outer` | int | Product of all outer loop bounds (before the Zero-init block) |
| `n_inner` | int | Product of sequential inner loop bounds (Zero → Phase 1, excluding sarows\_\*/sacols\_\* init loops) |
| `n_seq_loops` | int | Count of those sequential inner loops |
| `sa_dims` | dict | SA spatial dimension sizes: `{S, C, Q, M}` from Phase 2a loop comments |
| `c_global_var` | str | Which `sarows_X` variable carries the DRAM bank bit (`'sarows_0'` or `'sarows_1'`) |
| `sarows0_in_col` | bool | Whether `sarows_0` appears in the `in_col` index formula |
| `input_ports` | int | Number of physical AXI input/weight ports, parsed from `const int input_ports = N;` (defaults to 2) |
| `P_out` | int | Number of physical AXI output ports, counted from `#pragma HLS interface port = dram_output_pX` lines (defaults to 1) |

### Extraction logic

- **`N_PE`** — comment `"N PE accumulators"`.
- **`N_W`** — comment `"Phase 1 … N elems"`.
- **`N_out`, `N_red`** — comment `"reduction: N_PE acc → N_out outputs (N_red inputs each)"`.
- **`n_outer`** — `#pragma GCC nounroll` loops *before* the `// Zero` comment.
- **`n_inner`, `n_seq_loops`** — `#pragma GCC nounroll` loops from `// Zero` to `Phase 1`, excluding loops whose variable starts with `sarows_` or `sacols_`.
- **`sa_dims`** — comments `// S:N`, `// C:N`, `// Q:N`, `// M:N` inside Phase 2a.
- **`c_global_var`** — the `sarows_X` token in `int c_global = ...;` inside Phase 2a.
- **`sarows0_in_col`** — whether `sarows_0` appears in `in_col = ...`.
- **`input_ports`** — `const int input_ports = N;` declaration in the C file.
- **`P_out`** — count of `#pragma HLS interface port = dram_output_p` lines.

### Parsed values (experiments/ — input\_ports=2, P\_out=1)

| exp | N\_PE | N\_W | N\_out | N\_red | n\_outer | n\_inner | n\_seq | c\_global\_var |
|---|---|---|---|---|---|---|---|---|
| ex1 | 96 | 48 | 8 | 12 | 8 | 3 | 1 | sarows\_1 |
| ex2 | 96 | 24 | 8 | 12 | 64 | 3 | 1 | sarows\_1 |
| ex3 | 72 | 36 | 8 | 9 | 8 | 3 | 1 | sarows\_1 |
| ex4 | 64 | 16 | 16 | 4 | 4 | 1 | 0 | sarows\_0 |
| ex5 | 80 | 40 | 8 | 10 | 64 | 20 | 2 | sarows\_1 |
| ex6 | 96 | 16 | 24 | 4 | 6 | 3 | 1 | sarows\_0 |

---

## Step 2 — `body_const`: non-FP cycles per inner-body iteration

`compute_body_const(params, P_write=None)` derives analytically the constant
number of non-FP FSM states consumed per inner-loop body iteration.

### Physical motivation

In each Phase 1 + Phase 2a, the FSM serialises DRAM reads through a banked
bus with `input_ports` physical ports.  Bank-0 is the bottleneck bank;
`reads_bottleneck = max(weight_bank0, input_bank0)`.

### Counting weight reads on bank-0

`bank0_count = ceil(C_dim / input_ports)` — the number of C-channel values
that map to bank-0.

- **`c_global_var == 'sarows_1'`**: C is at sarows\_1; Phase 1 iterates over
  sarows\_0 (S) and sacols\_1 (M) for each bank-0 C value:
  `weight_bank0 = bank0_count × S × M`

- **`c_global_var == 'sarows_0'`**: C is at sarows\_0; remaining Phase 1
  dimensions combine to N\_W / C elements per C value:
  `weight_bank0 = bank0_count × (N_W // C)`

### Counting input reads on bank-0

- **`in_row_base`**:
  - `n_seq ≥ 2`: outer sequential variable fixes `c_blk` → **1** distinct row base.
  - `n_seq ≤ 1`: `c_blk` varies with the SA index → **`bank0_count`** rows.

- **`in_col_distinct`**:
  - `sarows_0` in `in_col` (filter height spans columns): `Q + S − 1`.
  - Otherwise: `Q`.

```
input_bank0 = in_row_base × in_col_distinct
```

### Overhead terms

| Situation | Fixed overhead |
|---|---|
| n\_seq ≥ 1 | `9 + 4·max(0, n_seq−1) + 2·tie` |
| n\_seq = 0 | `ceil(N_out/P_out) + ceil(N_PE/P_write) + 4 + 2·tie` |

For n\_seq ≥ 1: 9 = prologue + mul-chain entry + inner READ\_COND; 4 per extra
sequential dim; 2 when both banks are equally loaded (`tie = 1`).

For n\_seq = 0: output writes are serialised over `P_out` ports giving
`ceil(N_out/P_out)` write states; `ceil(N_PE/P_write)` is the zero-initialisation
overhead (fully exposed when there is no inner loop to overlap it).
`P_write=None` (the default) sets the zero-init contribution to 0.

### Full formulas

**Inner r-loop kernels (n\_seq ≥ 1):**
```
body_const = reads_bottleneck + 9 + 4·max(0, n_seq−1) + 2·tie
```

**Outer-body kernels (n\_seq = 0):**
```
body_const = reads_bottleneck + ceil(N_out/P_out) + ceil(N_PE/P_write) + 4 + 2·tie
```
where `ceil(N_PE/P_write) = 0` when `P_write` is `None`.

### Verified body\_const values (experiments/ — input\_ports=2, P\_out=1, P\_write=None)

| exp | n\_seq | weight\_b0 | input\_b0 | bottleneck | overhead | body\_const |
|---|---|---|---|---|---|---|
| ex1 | 1 | 24 | 8 | 24 | 9 | **33** |
| ex2 | 1 | 12 | 12 (tie) | 12 | 11 | **23** |
| ex3 | 1 | 24 | 8 | 24 | 9 | **33** |
| ex4 | 0 | 8 (tie) | 8 (tie) | 8 | 16+4+2=22 | **30** |
| ex5 | 2 | 20 | 6 | 20 | 13 | **33** |
| ex6 | 1 | 8 | 12 | 12 | 9 | **21** |
| ex7 | 3 | 30 | 2 | 30 | 17 | **47** |
| ex8 | 2 | 24 | 4 | 24 | 13 | **37** |
| ex9 | 2 | 24 | 7 | 24 | 13 | **37** |
| ex10 | 2 | 24 | 7 | 24 | 13 | **37** |

For ex4: `ceil(N_out/P_out) = ceil(16/1) = 16` write states; tie=1 because both banks
receive 8 reads each.

> When `input_ports` or `P_out` differ (e.g. tests/ex4 with `input_ports=4`,
> `P_out=8`), the same formula applies with the actual parsed values; body\_const
> will be different from the table above.

---

## Step 3 — Reduction tree helpers

### `compute_red_batches(N_out, N_red, N_mul)`

The binary reduction tree reduces `N_red` accumulators per output to 1.
At each tree level, `per_level = adds // 2` additions are performed across
`N_out` outputs and batched into groups of `N_mul`:

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
|---|---|---|---|
| 1 | 12 | 6 | 12 |
| 2 | 6 | 3 | 6 |
| 3 | 3 | 1 | 2 |
| 4 | 2 | 1 | 2 |
| **Total** | | | **22** |

### `compute_red_gaps(N_out, N_red, N_mul, N_PE)`

When `N_mul < N_PE`, some reduction tree levels have fewer additions than
`N_mul` fits.  Bambu inserts one empty FSM state (*gap*) per such boundary.
Returns 0 when `N_mul ≥ N_PE`.

---

## Step 4 — Post-reduction section: `compute_post_rloop()`

For inner r-loop kernels (n\_seq ≥ 1), after all inner iterations complete, the
FSM runs a post-rloop section executing the reduction tree and writing outputs:

```
post_rloop = 1 + 7·rb + gaps + extra_write0 + (ceil(N_out/P_out) − 1) + 1
```

| Term | Meaning |
|---|---|
| `1` | Entry state into post-reduction section |
| `7·rb` | 7 FSM states per FP-add batch (`rb` = `compute_red_batches(...)`) |
| `gaps` | Idle states between reduction levels (`compute_red_gaps(...)`) |
| `extra_write0` | 1 if `N_mul < N_PE` (write-0 cannot overlap last reduction state), else 0 |
| `ceil(N_out/P_out) − 1` | FSM states for output writes 1 … N\_out−1, batched over `P_out` ports |
| `1` | Outer-loop READ\_COND |

`P_out > 1` reduces the number of write states: with 8 output ports and 8
outputs, `ceil(8/8) − 1 = 0` extra write states instead of 7.

This function is **not called** for n\_seq = 0 kernels (`X_post = 0`).

---

## Step 5 — `predict()`: assembling features and applying the formula

### Feature computation — two branches

**Inner r-loop (n\_seq ≥ 1):**
```
B_acc  = ceil(N_PE / N_mul)
X_acc  = n_outer × n_inner × B_acc
X_bf   = n_outer × n_inner × body_const
X_post = n_outer × post_rloop(N_out, N_red, N_mul, N_PE, P_out)
```

`body_const` is computed with `compute_body_const(params, P_write)` where
`P_write` comes from the platform's calibration entry.

**Outer-body (n\_seq = 0):**
```
B_acc  = ceil(N_PE / N_mul)
rb     = compute_red_batches(N_out, N_red, N_mul)
X_acc  = n_outer × (B_acc + rb)
X_bf   = n_outer × body_const
X_post = 0
```

Reduction batches `rb` are folded into `X_acc` (they happen inline per outer
iteration rather than in a separate post-rloop section).

### The formula

```
C = α_acc · X_acc  +  α_bf · X_bf  +  α_post · X_post  +  α_func
    + α_outer_body · is_outer_body          ← 0 unless platform stores this field
```

`is_outer_body = 1` when `n_seq_loops == 0`, else 0.  `α_outer_body` defaults
to 0.0 for any platform that does not include it in the JSON, so the formula
reduces to the clean 4-parameter form for all newly calibrated platforms.

### Platform-specific fitted constants

**`I386_GCC8|5|xc7z020-1clg484-VVD`** (fitted from tests/ex1 + tests/ex4, 16 points):

| Constant | Value | Physical interpretation |
|---|---|---|
| α\_acc | 6.985 | Cycles per FP-op batch |
| α\_bf | 2.031 | Cycles per body\_const unit |
| α\_post | 1.012 | Cycles per post\_rloop state |
| α\_func | 209.6 | Fixed function-entry / prologue cost |
| P\_write | None | No zero-init correction fitted |

**`I386_GCC8|5|default`** (fitted from experiments/ex1–ex6, stored as 5-parameter legacy):

| Constant | Value |
|---|---|
| α\_acc | 7.003 |
| α\_bf | 2.180 |
| α\_post | 1.004 |
| α\_func | 361.0 |
| α\_outer\_body | −302.304 |

**`I386_GCC8|5|xcu55c-2Lfsvh2892-VVD`** (fitted from tests/ex11, 7 points):

| Constant | Value |
|---|---|
| α\_acc | 2.814 |
| α\_bf | 1.415 |
| α\_post | 3.477 |
| α\_func | 0.0 |

> α\_func = 0 here because ex11 was the only experiment used: X\_bf is
> constant across all N\_mul values, making α\_bf · X\_bf and α\_func degenerate
> (rank 3/4).  Predictions for ex11 itself are accurate; adding a second
> structurally different experiment would break the degeneracy.

---

## Step 6 — `fit_sa_platform.py`: fitting α coefficients

`fit_sa_platform.py` reads Bambu simulation results, computes feature vectors
using the same analytical formulas as `predict()`, and runs least-squares
regression to find platform-specific α coefficients.

### Input modes

**Mode 1 — from Bambu XML files (default)**

Each `nX/` subdirectory of a `Bambu_outputs/sa/` directory is expected to
contain a `bambu_results_0.xml` file with a `<CYCLES value="N"/>` element.

```bash
python src/fit_sa_platform.py \
  tests/eyeriss/conv/generated/ex1/Bambu_outputs/sa \
  tests/eyeriss/conv/generated/ex4/Bambu_outputs/sa \
  --update
```

**Mode 2 — from JSON stored `measured_cycles` (`--from-json`)**

When Bambu XML files are unavailable, measured cycles can be read directly from
the `experiments` section of `bambu_calibration.json`.  Pass experiment
directories (containing `top_level_sa.c`) instead of `Bambu_outputs/sa` dirs.

```bash
python src/fit_sa_platform.py --from-json \
  experiments/eyeriss/conv/ex{1,2,3,4,5,6} \
  --update
```

### Grid search for `P_write`

The fitter performs a grid search over `P_write ∈ {None, 1, 2, 4, 8, 16, 32}`.
For each candidate it recomputes `body_const` for n\_seq=0 rows, builds the
4-column feature matrix `[X_acc, X_bf, X_post, 1]`, runs lstsq, and records
R².  The candidate with the highest R² is chosen.

`P_write` is **only identifiable** when at least two experiments with different
N\_PE values are present in the n\_seq=0 rows (so that `ceil(N_PE/P_write)`
varies between experiments).  When only one n\_seq=0 experiment is available,
`P_write=None` is selected and a note is printed.

### Rank and identifiability

| Available data | Rank | What is identified |
|---|---|---|
| 1 experiment, varying N\_mul | 3/4 | α\_acc, α\_post, combined (α\_bf·X\_bf + α\_func) |
| ≥2 experiments with different body\_const | 4/4 | all four α independently |
| ≥2 n\_seq=0 experiments with different N\_PE | also identifies P\_write | — |

For full rank-4 calibration, use at least one n\_seq ≥ 1 experiment and one
n\_seq = 0 experiment (e.g. ex1 + ex4).

### `--update`

When `--update` is passed, the fitter writes the fitted platform entry into
`bambu_calibration.json`.  `P_write` is included only when it is not `None`.
`alpha_outer_body` is never written by the fitter (it is a legacy-only field).

---

## `--compare`: measured vs predicted

When `--compare` is passed to `sa_model.py`, measured cycles are resolved in
this order:

1. **Local Bambu XML files** — `<exp_dir>/Bambu_outputs/sa/nX/bambu_results_0.xml`,
   parsed by `_load_measured_from_bambu(c_path)`.
2. **JSON fallback** — `measured_cycles` from the matching `experiments` entry in
   `bambu_calibration.json`, loaded by `load_calib()`.

This means running `--compare` on a `tests/` experiment uses the actual Bambu
simulation results for that platform, while running it on an `experiments/`
path (which may not have local XMLs) falls back to the stored JSON values.

---

## CLI usage

```bash
# Single N_mul value
python src/sa_model.py tests/eyeriss/conv/generated/ex1/top_level_sa.c 4

# Sweep N_mul ∈ {1,2,4,8,16,32,64,N_PE}
python src/sa_model.py tests/eyeriss/conv/generated/ex1/top_level_sa.c --sweep

# Sweep with comparison against measured data
python src/sa_model.py tests/eyeriss/conv/generated/ex1/top_level_sa.c --sweep --compare

# Override calibration file location
python src/sa_model.py path/to/top_level_sa.c --sweep --calib path/to/bambu_calibration.json
```

Example output (`--sweep --compare` on tests/ex1, platform xc7z020):

```
File    : top_level_sa.c  [ex1]
Platform: I386_GCC8|5|xc7z020-1clg484-VVD
Params  : N_PE=96, N_W=48, N_out=8, N_red=12, n_outer=8, n_inner=3, n_seq=1, input_ports=4, P_out=8
Calib   : α_acc=6.9847, α_bf=2.0307, α_post=1.0118, α_func=209.6, P_write=None, body_const=21 [analytical]

 N_mul   Predicted    Measured    Error%  B_acc
  ----------------------------------------------------
  ✓    1       22,337      22,332     +0.0%  96
  ✓    2       11,797      11,804     -0.1%  48
  ✓    4        6,527       6,540     -0.2%  24
  ✓    8        3,908       3,916     -0.2%  12
  ✓   16        2,676       2,636     +1.5%   6
  ✓   32        2,068       2,028     +2.0%   3
  ✓   64        1,844       1,860     -0.9%   2
  ✓   96        1,644       1,684     -2.4%   1

Pass (<10% error): 8/8
```

---

## Accuracy results

### `I386_GCC8|5|xc7z020-1clg484-VVD` (fitted from tests/ex1 + tests/ex4)

| Experiment | n\_seq | Points | Max error |
|---|---|---|---|
| ex1 | 1 | 8 | 2.4% |
| ex4 | 0 | 8 | 2.1% |

### `I386_GCC8|5|default` (fitted from experiments/ex1–ex6)

| Experiment | n\_seq | Points | Max error |
|---|---|---|---|
| ex1 | 1 | 8 | 3.1% |
| ex2 | 1 | 8 | 4.1% |
| ex3 | 1 | 8 | 3.1% |
| ex4 | 0 | 7 | 2.3% |
| ex5 | 2 | 8 | 1.1% |
| ex6 | 1 | 8 | 1.4% |

Experiments ex7–ex10 are predicted from the same platform with zero additional
Bambu runs.  Their body\_const values are derived analytically from the C file.

### `I386_GCC8|5|xcu55c-2Lfsvh2892-VVD` (fitted from tests/ex11)

| Experiment | n\_seq | Points | Max error |
|---|---|---|---|
| ex11 | 3 | 7 | 1.5% |

---

## Tests

- **`tests/test_sa_model_accuracy.py`** — regression test using cycle counts
  from `Bambu_outputs_working` log files for experiments ex1–ex6.  All 97
  predictions are asserted within 5%.
- **`tests/test_sa_model_parse.py`** — parse correctness (`N_PE`, `n_seq_loops`,
  `c_global_var`) and `body_const` values for experiments ex1–ex10.  Also
  includes prediction smoke tests (non-negative, non-increasing with N\_mul)
  for ex7–ex10.

---

## Limitations

- **Platform-specific α constants.** Alphas must be re-fitted for each new
  compiler/clock/device combination.  Use `fit_sa_platform.py` with Bambu
  results from at least two structurally distinct experiments (one n\_seq ≥ 1,
  one n\_seq = 0) to achieve full rank-4 calibration.

- **Single-experiment fit gives rank 3/4.** When only one experiment is used,
  α\_bf and α\_func are degenerate: lstsq folds the constant into whichever
  parameter fits best (typically α\_bf, leaving α\_func ≈ 0).  Predictions for
  that same experiment remain accurate, but predictions for other experiments
  with a different body\_const may be off.

- **`P_write` requires two n\_seq=0 experiments with different N\_PE.**
  `ceil(N_PE/P_write)` is constant across all N\_mul values within a single
  experiment, so it is always absorbed by α\_func.  Two n\_seq=0 experiments
  with different N\_PE are required to make it observable.

- **Binary reduction tree assumed.** `compute_red_batches` and
  `compute_red_gaps` assume the generated code uses a binary halving structure.
  Non-binary reductions would need updated logic.

- **`alpha_outer_body` is a legacy field for single-port platforms.** When
  `P_out = 1` and `N_out` is large, the `ceil(N_out/P_out) = N_out` write
  states inflate `X_bf` disproportionately for n\_seq = 0 kernels.  The
  `I386_GCC8|5|default` platform stores `alpha_outer_body = −302.304` to
  correct this.  Platforms with multiple output ports (P\_out > 1) do not need
  this correction.

- **N\_mul is a manual input.** The model does not read `N_mul` from
  `compile_bambu.sh`; the caller must supply it.  Use `--sweep` to evaluate
  the full design space automatically.
