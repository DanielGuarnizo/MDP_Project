# Eyeriss HLS Kernel Generator

Generates HLS-ready C kernels for the **Eyeriss** spatial architecture (2D convolution and GEMM),
driven by a **FactorFlow** mapping. Given a workload size, the pipeline:

1. Runs **FactorFlow** → produces a tiling/spatial mapping across the memory hierarchy
2. Parses the mapping → `MappingInfo`
3. Generates C kernels + Bambu scripts → compiles and co-simulates via **Bambu HLS**

The goal: show that SA-shaped code (loop structure mirrors the FF spatial hierarchy) achieves
fewer Bambu clock cycles than a sequential baseline.

---

## Quick-start

```bash
# 1. Generate all files for an experiment (runs FF if needed, then code generation)
python src/main.py --config experiments/eyeriss/conv/ex1/config.json

# 2. CPU correctness check (fast, no Bambu)
cd experiments/eyeriss/conv/ex1
gcc -O2 -o cpu_sa  top_level_sa.c  testbench_common.c -lm && ./cpu_sa
gcc -O2 -o cpu_seq top_level_seq.c testbench_common.c -lm && ./cpu_seq

# 3. Bambu co-simulation + cycle count (slow)
./run_compare.sh          # default N_mul
./run_compare.sh 4        # override N_mul=4 (-C=__float_mul=4)

# 4. Analytical cycle model (no Bambu needed)
python src/model.py --ff experiments/eyeriss/conv/ex1/FF_output/FF_output.txt --n-mul 1 2 4 8 16

# 5. Run FactorFlow directly
python FactorFlow/main_cli.py eyeriss-conv 4 4 4 4 3 3   # M P Q C R S
python FactorFlow/main_cli.py eyeriss 8 8 8               # M K N (GEMM)
```

---

## 1. Pipeline Overview

```
config.json
  │
  ├─ factorflow.args + factorflow.architecture
  │      │
  │      ▼
  │  FactorFlow/main_cli.py          (FactorFlow optimizer)
  │      │
  │      ▼  stdout → FF_output/FF_output.txt
  │
  ├─ ff_parser.parse_ff_output()     (src/ff_parser.py)
  │      │
  │      ▼  MappingInfo
  │
  └─ _dispatch_and_generate()        (src/main.py)
         │
         ├─ CONV: codegen/conv/eyeriss_generator.generate_experiment()
         │          ├─ _emit_top_level_seq()    sequential baseline
         │          ├─ _emit_top_level_sa()     SA-shaped kernel
         │          ├─ harness/conv_harness.make_conv_testbench()
         │          └─ compile_bambu.sh + run_compare.sh
         │
         └─ GEMM: codegen/gemm/eyeriss_generator.generate_experiment()
                    ├─ _emit_top_level_seq()    sequential baseline
                    ├─ _emit_top_level_sa()     SA-shaped kernel
                    ├─ harness/gemm_harness.make_gemm_testbench()
                    └─ compile_bambu.sh + run_compare.sh
```

Experiments are organized by architecture and workload:

```
experiments/
  eyeriss/
    conv/ex1/        # eyeriss-conv reference
    gemm/ex1/        # eyeriss-gemm reference
```

Each experiment folder is self-contained:

```
config.json              # factorflow args + bambu settings
FF_output/FF_output.txt  # FactorFlow output (reused if force: false)
top_level_seq.c          # generated sequential kernel
top_level_sa.c           # generated SA-shaped kernel
testbench_common.c       # correctness + Bambu co-sim harness
compile_bambu.sh         # single-kernel Bambu invocation
run_compare.sh           # runs both kernels, prints cycle summary
Bambu_outputs/seq/       # Bambu artifacts + log for seq
Bambu_outputs/sa/        # Bambu artifacts + log for sa
```

---

## 2. Parsing `FF_output.txt` → `MappingInfo`

### What FactorFlow outputs

FactorFlow prints a header block followed by a mapping. Only the **last** occurrence of
`Final condition:` or `Mapping:` is used — earlier occurrences are intermediate candidates
printed during the search, not the final result.

A representative output looks like:

```
Architecture: eyeriss-conv
Computation: {M: 4, P: 4, Q: 4, C: 4, R: 3, S: 3}

Final condition:
DRAM ----------> Q: 2
GlobalBuffer --> P: 4
SACols --------> Q: 2, M: 4
SARows --------> S: 3, C: 4
WRegister -----> R: 3
```

Each level line `LevelName ----> dim: factor, dim: factor` assigns loop factors to that level.
Levels with no factors assigned are omitted or left blank.

### `parse_ff_output()` → `MappingInfo`

`src/ff_parser.py` reads the file and populates a `MappingInfo` dataclass
(`src/mapping_types.py`):

| Field | Type | Content |
|---|---|---|
| `arch_workload` | `str` | Raw string from `Architecture:` line, e.g. `"eyeriss-conv"` |
| `arch` | `str` | Architecture name, e.g. `"eyeriss"` |
| `workload` | `str` | `"CONV"` or `"GEMM"` |
| `dims` | `Dict[str, int]` | Full problem dimensions, e.g. `{"M":4,"P":4,"Q":4,"C":4,"R":3,"S":3}` |
| `spatial_levels` | `List[str]` | Ordered level names as FF reports them, e.g. `["DRAM","GlobalBuffer","SACols","SARows","WRegister"]` |
| `tiling` | `Dict[str, Dict[str, int]]` | `tiling[level][dim] = factor`, e.g. `tiling["SACols"]["M"] = 4` |

### Workload inference

The `Architecture:` string encodes both arch and workload when present (e.g. `"eyeriss-conv"`).
When only the arch is given (plain `"eyeriss"`), the workload is inferred from which dims appear
in `Computation`:

- `K` and `N` present, `R` absent → **GEMM**
- Otherwise → error (cannot infer)

This allows FactorFlow to be called as `python FactorFlow/main_cli.py eyeriss M K N` without a
workload suffix, while the pipeline still routes correctly to the GEMM generator.

### Why parse the LAST section marker

FactorFlow prints the initial condition (all dims at DRAM) before starting optimisation, using
the same `Level ---->` format. Picking the first occurrence would give the trivially bad initial
assignment. The parser scans for the last `Final condition:` or `Mapping:` header and only parses
level lines below it, ensuring only the optimised result is used.

---

## 3. CONV Kernel Generation

The CONV generator lives in `src/codegen/conv/eyeriss_generator.py`. Given a `MappingInfo` it
produces `top_level_seq.c`, `top_level_sa.c`, `testbench_common.c`, and two shell scripts.

### Level classification: `_classify_levels()`

The first thing the generator does is partition the FF hierarchy into three groups:

```
outer_mem  — MemLevels BEFORE the first SA level  (e.g. DRAM, GlobalBuffer)
fanout     — FanoutLevels (all levels whose name contains "SA")  (e.g. SACols, SARows)
inner_mem  — MemLevels AFTER the last SA level, excluding OutRegister  (e.g. WRegister)
```

**Why three tiers?** Each tier plays a distinct role in the generated C:

- `outer_mem` factors → ordinary `for` loops that tile the full computation into blocks. These
  are NOT unrolled because they iterate over potentially large tile counts; unrolling would
  produce exponentially more code with no HLS benefit.
- `fanout` factors → the parallel SA lanes. These become the accumulator dimensions and are
  unrolled with `#pragma GCC unroll` so Bambu sees them as independent, schedulable operations.
- `inner_mem` factors → sequential reduction loops inside each tile (e.g. filter height R via
  `WRegister`). They contribute to the accumulator but cannot be parallelised by adding
  multipliers; they are plain `for` loops.

**Why "SA" substring matching?** FactorFlow consistently names spatial array levels with the
prefix `SA` (SACols, SARows). A substring check is simple, robust, and requires no configuration
when new SA sub-levels are added.

### Memory banking

**Input and weight banks (split by `c%2`):**
Channels are split across two AXI ports: even channels (`c%2 == 0`) go to bank 0, odd channels
(`c%2 == 1`) go to bank 1. Each inner iteration over `C_sa` channels reads from both banks
simultaneously. Without this split, both banks would map to the same address space and Bambu
could not schedule parallel AXI reads — the dual-port advantage would be lost entirely.

The index into each bank is `c_blk = c >> 1` (i.e. `c // 2`), so bank 0 holds channels
`[0, 2, 4, ...]` and bank 1 holds `[1, 3, 5, ...]`. The same `c%2` split applies to weights
because each weight element at `(m, c, r, s)` is consumed alongside its corresponding input.

**Output banks (`m_sf × p_sf × q_sf` banks):**
Each combination of spatial output lane `(lane_m, lane_p, lane_q)` writes to its own AXI port
(`dram_out_b{i}` where `i = lane_m * p_sf * q_sf + lane_p * q_sf + lane_q`). This is what makes
the parallel accumulator write feasible: all `m_sf × p_sf × q_sf` lanes write in the same clock
cycle without any port conflict. If all lanes wrote to the same port the write step would
serialize and destroy the parallelism of the SA.

### Bank spec inference: `_out_bank_factors_eyeriss()`

The output bank factors `(m_sf, p_sf, q_sf)` are inferred from the mapping with a tiered policy:

1. **SACols directly**: if SACols has M/P/Q factors, use them. This is the common case because
   SACols maps the output spatial dimensions in Eyeriss.
2. **All SA levels aggregated**: if SACols alone gives factor 1 for everything, multiply the
   M/P/Q factors from any level whose name contains "SA". This handles unusual mappings where
   output parallelism is spread across multiple SA sub-levels.
3. **Fallback**: `(1, 1, 1)` — a single output bank, effectively serialised writes.

### `_emit_top_level_sa()` structure

The SA kernel loop nest mirrors the FF hierarchy exactly:

```c
// --- outer_mem loops (DRAM → GlobalBuffer) ---
for (int q_dram = 0; q_dram < 2; ++q_dram) {     // DRAM → Q:2
  for (int p_gb = 0; p_gb < 4; ++p_gb) {          // GlobalBuffer → P:4

    // Accumulator: one element per SA output lane
    DTYPE acc[m_sf][q_sf];   // or acc[m_sf][p_sf][q_sf] when p_sf > 1
    // ... initialised to 0.0f ...

    // --- inner_mem loop (WRegister) ---
    for (int r = 0; r < 3; ++r) {                  // WRegister → R:3

      // --- SARows unrolled (C:4, S:3) ---
      #pragma GCC unroll 4
      for (int c_sa = 0; c_sa < 4; ++c_sa) {
        #pragma GCC unroll 3
        for (int s_sa = 0; s_sa < 3; ++s_sa) {

          // --- SACols unrolled (M:4, Q:2) ---
          #pragma GCC unroll 4
          for (int lane_m = 0; lane_m < 4; ++lane_m) {
            #pragma GCC unroll 2
            for (int lane_q = 0; lane_q < 2; ++lane_q) {
              // compute index, read from banked ports, accumulate
              acc[lane_m][lane_q] += w * in;
            }
          }
        }
      }
    } // r

    // Write accumulator to banked output ports (one port per lane)
    #pragma GCC unroll m_sf*q_sf
    for (int lane = ...) {
      switch(out_bank) { case i: dram_out_bi[idx] = acc[...]; break; }
    }
  }
}
```

**`p_sf == 1` optimisation:** when the SACols P factor is 1, the accumulator collapses from 3D
`acc[m_sf][p_sf][q_sf]` to 2D `acc[m_sf][q_sf]`. Bambu incurs per-dimension overhead for
multidimensional arrays even when one dimension is 1; the 2D form avoids this and produces
cleaner RTL.

**`#pragma GCC unroll N` vs `#pragma HLS unroll`:** Bambu ignores `#pragma HLS unroll` directives
entirely — it processes the C source before the HLS pragma is meaningful. `#pragma GCC unroll N`
is applied by GCC at C compilation time, so Bambu receives already-unrolled code and can schedule
the independent operations across its functional units. This is a critical detail: without the
GCC pragma, the SA loops would synthesize as sequential loops and the performance advantage of the
spatial mapping would be completely lost.

### `_emit_top_level_seq()`: the sequential baseline

The sequential kernel implements textbook 2D convolution with 6 nested loops `(M, P, Q, C, R, S)`.
It reads from the same banked AXI ports as the SA kernel (required for the testbench to work
correctly with both), but accumulates without any unrolling. Its purpose is to provide a
cycle-count reference: if the SA kernel doesn't outperform it at some N_mul, something is wrong.

### Testbench (`conv_harness.make_conv_testbench()`)

The testbench scatters flat `float` arrays into banked layout before calling `top_level()`, then
gathers results back and compares against a golden C reference:

- **Scatter input** `[C × H × W]` → `dram_in_b{c%2}` indexed by `[c//2][h][w]`
- **Scatter weights** `[M × C × R × S]` → `dram_w_b{c%2}` indexed by `[m][c//2][r][s]`
- **Golden reference**: plain 6-loop convolution on the flat arrays
- **Gather output**: for each `(m, p, q)`, compute `lane = (m%m_sf, p%p_sf, q%q_sf)` →
  `out_bank = lane_m*p_sf*q_sf + lane_p*q_sf + lane_q`; read from `dram_out_b{out_bank}` at
  index `[(m//m_sf)*Ptiles + (p//p_sf)]*Qtiles + (q//q_sf)`
- **Comparison**: element-wise absolute difference with `eps = 1e-3f`

Under `#ifdef __BAMBU_SIM__` the testbench also calls `m_param_alloc()` for each AXI port so
Bambu knows the memory size for co-simulation.

---

## 4. GEMM Kernel Generation

The GEMM generator lives in `src/codegen/gemm/eyeriss_generator.py`. It reuses
`_classify_levels()` from the CONV generator — the level classification logic is
workload-agnostic. The key structural differences from CONV are:

### How GEMM maps onto the Eyeriss SA

For GEMM `C[M×N] = A[M×K] × B[K×N]`, the spatial mapping assigns:

- **SACols**: M and K dimensions — M lanes produce independent partial sums; K is the unrolled
  reduction within each lane.
- **SARows**: M dimension (additional M parallelism) — total `m_sf = m_sacols × m_sarows`.
- **N is never in SA**: N is handled entirely by outer temporal loops (GlobalBuffer → N). This is
  a fundamental FactorFlow constraint for the Eyeriss GEMM mapping: the SA grid processes one N
  output column at a time, iterating over all N columns in the outer loop.

**Why N stays in the outer loop:** The Eyeriss SA is designed for reduction along one axis at a
time. Placing N in the SA would require independent accumulators for each N value AND each M
value simultaneously, which doubles the accumulator area. Keeping N outer lets the same M
accumulators be reused across all N columns, matching the physical register file structure.

### `GemmBankSpec` fields

| Field | Value / formula | Meaning |
|---|---|---|
| `m_sf` | `m_sacols × m_sarows` | Total M spatial parallelism |
| `k_sa` | `SACols["K"]` | K reduction unrolled per inner iteration |
| `k_blks` | `(K + 1) // 2` | Per-bank K elements (ceiling for odd K) |
| `in_bank_elems` | `k_blks × N` | B-matrix elements per bank |
| `w_bank_elems` | `M × k_blks` | A-matrix elements per bank |
| `out_banks` | `m_sf` | One output port per M lane |
| `out_bank_elems` | `M_tiles × N` | Output elements per bank |

### Banking (split by `k%2`)

The reduction dimension K plays the same role as C in CONV: each K step reads a weight element
and an input element. Splitting by `k%2` puts even K-steps in bank 0 and odd K-steps in bank 1,
enabling dual-port AXI reads. The index into each bank is `k_blk = k >> 1`.

- `dram_w_b{k%2}[m * k_blks + k//2]` = A[m, k]
- `dram_in_b{k%2}[k//2 * N + n]` = B[k, n]

Output banking uses `m % m_sf` (lane index) with one AXI port per M lane, same as CONV.

### `_emit_top_level_sa()` for GEMM

The key structural difference is the accumulator: because N is always in an outer loop and never
replicated in the SA, the accumulator is **1D** `acc[m_sf]` — one scalar per M lane, shared
across the N iteration. The N value enters as an outer loop variable (`n_global_expr`):

```c
// outer temporal loops (includes GlobalBuffer → N)
for (int n_gb = 0; n_gb < N_fac; ++n_gb) {
  for (int m_outer = ...) {

    DTYPE acc[m_sf];
    #pragma GCC unroll m_sf
    for (int mi = 0; mi < m_sf; ++mi) acc[mi] = 0.0f;

    // SARows M:m_sarows × SACols M:m_sacols × SACols K:k_sa  — all unrolled
    #pragma GCC unroll m_sarows
    for (int mri = 0; mri < m_sarows; ++mri) {
      #pragma GCC unroll m_sacols
      for (int mci = 0; mci < m_sacols; ++mci) {
        int acc_m = mri * m_sacols + mci;
        #pragma GCC unroll k_sa
        for (int kci = 0; kci < k_sa; ++kci) {
          // k%2 bank select, read w and in, accumulate into acc[acc_m]
        }
      }
    }

    // write acc[m_sf] to m_sf output ports
  }
}
```

### Testbench (`gemm_harness.make_gemm_testbench()`)

- **Scatter A[M×K]** → `dram_w_b{k%2}[m * k_blks + k//2]`
- **Scatter B[K×N]** → `dram_in_b{k%2}[k//2 * N + n]`
- **Golden reference**: 3-loop `C[m][n] += A[m][k] * B[k][n]`
- **Gather C**: `bank = m % m_sf`, `idx = (m / m_sf) * N + n`; read from `dram_out_b{bank}[idx]`

---

## 5. Analytical Cycle Model

`src/model.py` predicts Bambu cycle counts without running Bambu. It is workload-agnostic:
the same formulas apply to CONV and GEMM; only the AXI port-read counts differ (handled by
`ArchProfile` subclasses in `src/model_profiles.py`).

### Key quantities derived from the FF mapping

**`U` — unroll depth (parallel MACs per inner-loop body)**

```
U = product of ALL FanoutLevel (SA) factors
```

For the ex2 CONV mapping `SACols={Q:2, M:4}`, `SARows={S:3, C:4}`:
`U = 2 × 4 × 3 × 4 = 96`

U is the number of independent multiply-accumulate operations that Bambu can schedule
concurrently if given enough functional units. It is the product, not the sum, because each SA
level adds an independent parallelism dimension — a `m_sf × q_sf` grid of M×Q lanes each running
the full `C_sa × S_sa` reduction, so the total parallel multiplications per inner body is their
product.

**`T_seq` — inner sequential loop count**

```
T_seq = product of inner MemLevel (WRegister, InRegister) factors
```

For ex2: `WRegister={R:3}` → `T_seq = 3`

These iterations are irreducibly sequential: each R step accumulates into the same accumulator
that the previous step wrote. Adding more multipliers does not help here.

**`T_outer` — outer tile iteration count**

```
T_outer = product of outer MemLevel (DRAM, GlobalBuffer) factors
```

For ex2: `DRAM={Q:2}`, `GlobalBuffer={P:4}` → `T_outer = 2 × 4 = 8`

The model is linear in `T_outer` — the same computation repeats for each tile combination.

**Sanity check:** `U × T_seq × T_outer = total_MACs`. For ex2:
`96 × 3 × 8 = 2304 = 4 × 4 × 4 × 4 × 3 × 3` ✓

### Two-regime model

The model divides the N_mul space into two regimes based on whether compute or memory is the
bottleneck:

**Serial regime (N_mul < n_threshold):**

```
predicted_cycles = alpha_s × total_reads_all_ports
```

When N_mul is small, the multipliers are the bottleneck — they cannot keep up with the amount of
work. Adding one more multiplier reduces the time proportionally. The baseline (`alpha=1`) is the
sum of reads across ALL ports because in the compute-bound case, ALL ports must supply data to
keep the multipliers busy; the critical path involves every port.

**Parallel regime (N_mul ≥ n_threshold):**

```
predicted_cycles = alpha_p × heaviest_port_reads
```

When N_mul is large enough, the multipliers are no longer the bottleneck — the AXI bus for the
most heavily loaded port is. Adding more multipliers does not help because the data cannot arrive
faster. The baseline is the read count of the **single heaviest port**: the overall throughput is
gated by whichever AXI channel has the most traffic. Once that channel saturates, cycle count
becomes independent of N_mul.

**Why `n_threshold = 2`?** In Bambu's scheduler, parallel regime behaviour begins as soon as there
is more than one multiplier available (N_mul ≥ 2). With N_mul=1, every multiplication is strictly
sequential regardless of the mapping; with N_mul≥2, the pipelining kicks in and the memory bus
becomes the bottleneck for well-designed SA kernels.

### Crossover N_mul\*

```
N_mul* = U / max_reads_per_port
```

where `max_reads_per_port` is the reads-per-inner-iteration of the heaviest port (not total, per
iteration). Below N_mul\*, adding multipliers reduces cycles. Above N_mul\*, adding multipliers
has no effect. This crossover is derived by setting the compute-bound II equal to the
memory-bound II:

```
compute-bound II = ceil(U / N_mul)   (U operations, N_mul units, per iteration)
memory-bound  II = max_reads_per_port  (one word per cycle per port, BW=1)
crossover: U / N_mul* = max_reads_per_port  →  N_mul* = U / max_reads_per_port
```

### AXI read formulas (`src/model_profiles.py`)

The read counts depend on the specific loop-banking scheme, which differs between CONV and GEMM.
An `ArchProfile` ABC (`port_reads()` + `n_chains()`) isolates this arch-specific logic from the
generic model. Adding a new architecture only requires a new profile subclass.

**`EyerissCONVProfile`:**

```
rw = (C_sa // 2) × S_sa × m_sf × n      # per weight bank (dram_w_b0 or dram_w_b1)
ri = (C_sa // 2) × S_sa × q_sf × n      # per input bank  (dram_in_b0 or dram_in_b1)
```

where `n = T_seq × T_outer`.

- `C_sa // 2`: c%2 banking splits C_sa evenly — each bank sees half the channel iterations.
- `S_sa`: filter width steps within SARows; each step is a separate read.
- `m_sf` (for weights): every M lane reads its own weight element → m_sf independent reads.
- `q_sf` (for inputs): input reuse is across output Q positions (same input pixel, different
  output columns) → q_sf reads per input bank, not m_sf (input does not depend on M).
- `n`: the full outer × inner tile count scales everything linearly.

**`EyerissGEMMProfile`:**

```
rw = (k_sa // 2) × m_sf × n      # per weight bank (A-matrix rows)
ri = (k_sa // 2) × 1     × n     # per input bank  (B-matrix column)
```

- `k_sa // 2`: k%2 banking splits K reduction; each bank sees half the K steps.
- `m_sf` (for weights): each M lane reads its own A row element independently.
- `1` (for inputs): input reuse is across ALL M lanes — every M lane in the SA uses the same
  B[k, n] element. So only ONE read per bank per k-step, regardless of m_sf. This is a key
  difference from CONV: in GEMM the input is shared across the M dimension, whereas in CONV
  each output position reads a spatially shifted input patch.

### `alpha_s` and `alpha_p` — why two calibrated constants

The model uses two separate overhead factors:

- **`alpha_s`** scales the serial-regime baseline. It is large (typically 8–15×) because in
  the compute-bound case each AXI read is individually scheduled, incurs full AXI initiation
  overhead, and the Bambu scheduler cannot pipeline reads that target different ports across
  independent multiplications.

- **`alpha_p`** scales the parallel-regime baseline. It is smaller than `alpha_s` (typically
  2–5×) because in the memory-bound case, Bambu pipelines many in-flight AXI read requests
  across the unrolled loop body. The fixed AXI latency is amortized over many parallel
  transactions, so the effective overhead per read is significantly lower.

Both constants are calibrated empirically rather than derived analytically because Bambu's
internal AXI scheduler and the pipeline depth of the synthesized RTL are opaque to the model.
The exact values depend on the compiler target (e.g. `I386_GCC8`) and the clock period.

---

## 6. Alpha Calibration

The model resolves `alpha_s` and `alpha_p` through a four-tier priority system, checked in order:

### Tier 1 — `--measured` (highest priority)

```bash
python src/model.py --ff ... --measured 1:23660 2:4148
```

User-supplied exact Bambu cycle counts. Each `N_mul:cycles` pair is used directly:
- Any N_mul below `n_threshold` (= 2) calibrates `alpha_s` via `calibrate_alpha_s(cycles)`
- Any N_mul ≥ `n_threshold` calibrates `alpha_p` via `calibrate_alpha_p(N_mul, cycles)`

Use this tier when you have run Bambu yourself and want exact calibration for this specific
mapping.

### Tier 2 — calibration store

```
src/bambu_calibration.json
```

A JSON file keyed by `{arch_workload}__{compiler}__{clock_period}` (e.g.
`"eyeriss-conv__I386_GCC8__5"`). Each entry stores `alpha_s`, `alpha_p`, `source`, and
optionally `measured_cycles` from the auto-calibration sweep. On subsequent model runs, both
alphas are loaded from here with no Bambu invocation required.

Why JSON: human-readable, easily inspectable with any text editor, portable across machines, no
database dependency. The key encodes all three degrees of freedom that affect alpha (target
architecture, compiler, clock period).

### Tier 3 — auto-calibration (Bambu sweep)

When neither `--measured` nor a store entry exists for the current
`(arch_workload, compiler, clock_period)` triple, the model automatically runs Bambu for a
canonical reference workload (defined in `_PROFILE_REGISTRY`) and sweeps N_mul values:

```python
_N_MUL_SWEEP = [1, 2, 4, 8, 16]
```

Each value is attempted in order; the sweep stops on the first failure (Bambu resource or
licensing limit). The results are used to:

1. Fit `alpha_s` from the N_mul=1 measurement (always in the serial regime).
2. Fit `alpha_p` from the lowest N_mul ≥ `n_threshold` measurement (first parallel-regime point).
3. Persist the full sweep + both alphas to the calibration store.

**Why sweep [1, 2, 4, 8, 16] and not just [1, 2]?** A two-point calibration can produce a
misleading `alpha_p` if N_mul=2 happens to land in an intermediate region between regimes.
Sweeping to N_mul=16 confirms the flat plateau of the parallel regime (where cycles stop
decreasing with N_mul), validates the crossover prediction, and gives a more accurate `alpha_p`
fit. Powers of 2 are required because Bambu's `-C=__float_mul=N` flag only accepts powers of 2.

**Canonical reference workload:** to make the calibration transferable across different problem
sizes, the sweep uses a fixed small workload (e.g. M=K=N=4 for GEMM) that runs quickly in Bambu
while still producing a meaningful serial/parallel split. The resulting alphas are then applied to
any problem size for the same `(arch, compiler, clock)` triple, relying on the assumption that
the AXI overhead factors are geometry-independent.

### Tier 4 — heuristic (lowest priority)

If calibration fails entirely (no `--measured`, no store entry, auto-calibration not possible),
the model falls back to a geometric heuristic derived from the ratio of port reads:

```python
# if only alpha_p is known (from --measured in parallel regime):
alpha_s = alpha_p * (total_reads_all_ports / heaviest_port_reads)

# if only alpha_s is known (from --measured in serial regime):
alpha_p = alpha_s * (heaviest_port_reads / total_reads_all_ports)
```

This assumes the overhead ratio between regimes is proportional to the ratio of work done.
It is explicitly marked as a rough estimate in the model output (`"heuristic estimate"`).
If neither alpha is known, both default to 1.0, giving the theoretical lower bound.
