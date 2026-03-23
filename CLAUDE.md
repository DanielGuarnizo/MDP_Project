# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo does

Generates HLS-ready C kernels for the **Eyeriss** spatial architecture running 2D convolution, driven by a **FactorFlow** mapping. For a given workload size (M,P,Q,C,R,S), the pipeline:

1. Runs **FactorFlow** → produces a tiling/spatial mapping across the memory hierarchy
2. Parses the mapping → `MappingInfo`
3. Generates C kernels + Bambu scripts → compiles and co-simulates via **Bambu HLS**

The goal is to show that SA-shaped code (loop structure mirrors the FF spatial hierarchy) achieves fewer Bambu clock cycles than a sequential baseline.

## Key commands

**Generate files for an experiment:**
```bash
python src/main.py --config experiments/ex2/config.json
```

**CPU correctness check (fast, no Bambu):**
```bash
cd experiments/ex2
gcc -O2 -o cpu_sa top_level_sa.c testbench_common.c -lm && ./cpu_sa
gcc -O2 -o cpu_seq top_level_seq.c testbench_common.c -lm && ./cpu_seq
```

**Bambu co-simulation + cycle count (slow):**
```bash
cd experiments/ex2
./run_compare.sh          # runs both seq and sa, prints cycle counts
./compile_bambu.sh        # runs only sa (default) or: ./compile_bambu.sh top_level_seq.c
```

**Analytical cycle model (no Bambu needed):**
```bash
python src/model.py --ff experiments/ex2/FF_output/FF_output.txt --n-mul 1 2 4 8 16
# With calibration from a known measurement:
python src/model.py --ff experiments/ex2/FF_output/FF_output.txt --measured 1:22895
```

**Run FactorFlow directly:**
```bash
python FactorFlow/main_cli.py eyeriss-conv 4 4 4 4 3 3   # M P Q C R S
```

## Architecture

### Pipeline (`src/`)

```
main.py
  ├─ _run_factorflow_if_needed()   runs FactorFlow/main_cli.py, writes FF_output.txt
  ├─ ff_parser.parse_ff_output()   parses FF_output.txt → MappingInfo
  └─ _dispatch_and_generate()      routes to the right generator
       └─ codegen/conv/eyeriss_generator.generate_experiment()
            ├─ _emit_top_level_seq()   sequential baseline
            ├─ _emit_top_level_sa()    SA-shaped kernel (FF-faithful)
            ├─ harness/conv_harness.make_conv_testbench()
            └─ emits compile_bambu.sh + run_compare.sh
```

### Key types

**`MappingInfo`** (`mapping_types.py`): holds `dims` (M,P,Q,C,R,S sizes), `tiling` (level → dim → factor), `spatial_levels` (ordered list from DRAM to Compute), `arch`, `workload`.

**`ConvBankSpec`** (`eyeriss_generator.py`): derived from mapping — `m_sf`, `p_sf`, `q_sf` (SACols output parallelism = number of output banks), `p_tiles`, `q_tiles`.

### FF mapping → generated C

The FF hierarchy maps to C loop structure as follows:

| FF level type | C code role |
|---|---|
| MemLevels above FanoutLevels (DRAM, GlobalBuffer) | Outer temporal `for` loops |
| FanoutLevels (SACols, SARows) | `acc[m_sf][p_sf][q_sf]` accumulator + `#pragma GCC unroll N` loops |
| MemLevels below FanoutLevels (WRegister) | Inner sequential `for` loop |

`_classify_levels()` identifies level types by checking if the name contains `"SA"`.

### Memory banking

Inputs/weights split into **2 banks** by `c % 2` (even/odd channels).
Outputs split into **`m_sf * p_sf * q_sf` banks**, each a separate AXI bundle (`gmem_out0..N`).
The testbench (`conv_harness.py`) scatters flat arrays → banked layout before calling `top_level()`, then gathers back and compares to a golden reference.

### Analytical model (`src/model.py`)

Key quantities:
- **U** = unroll depth = product of all FanoutLevel factors (SACols × SARows) = MACs exposed per inner-seq-loop body
- **T_seq** = inner sequential loop iterations (WRegister R)
- **T_outer** = outer tile iterations (DRAM × GlobalBuffer)
- **Crossover N_mul*** = U / max_reads_per_port — below this: compute-bound; above: memory-bound (adding multipliers stops helping)
- **alpha** ≈ 10 (AXI overhead factor; calibrated from measured cycles at N_mul=1)

### Bambu notes

- `#pragma HLS unroll` is **ignored** by Bambu. Use `#pragma GCC unroll N` for actual unrolling.
- `-C=__float_mul=N` (powers of 2 only) sets the number of float multiplier units.
- `--tb-param-size=port:bytes` tells Bambu the memory size of each AXI port.
- Cycle count extracted from `bambu_*.log` via `grep "Run 1 execution time"`.

## Experiment layout

Each `experiments/exN/` is self-contained:
```
config.json          # factorflow args + bambu settings
FF_output/FF_output.txt   # FactorFlow output (reused if force:false)
top_level_seq.c      # generated sequential kernel
top_level_sa.c       # generated SA-shaped kernel
testbench_common.c   # correctness + Bambu co-sim harness
compile_bambu.sh     # single-kernel Bambu invocation
run_compare.sh       # runs both kernels, prints cycle summary
Bambu_outputs/seq/   # Bambu artifacts + log for seq
Bambu_outputs/sa/    # Bambu artifacts + log for sa
```

`experiments/ex_nmul{2,4,8,16}/` are sweeps of `-C=__float_mul=N` for model validation.

## Currently supported

- **Eyeriss-CONV** only (end-to-end, correct, cycle-compared).
- GEMM and other architectures: dispatcher raises `NotImplementedError` — placeholders exist.
- FactorFlow expected at `FactorFlow/main_cli.py` (repo root). Configurable via `config.factorflow.main_cli`.
