# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run all tests
python -m pytest tests/

# Run a single test suite
python -m pytest tests/eyeriss/conv/test_eyeriss_conv.py -v
python -m pytest tests/eyeriss/gemm/test_eyeriss_gemm.py -v

# Run one experiment (generates C files, runs CPU golden check)
python src/main.py --config tests/eyeriss/conv/generated/ex1/config.json

# FactorFlow directly (args = M P Q C R S for CONV, M K N for GEMM)
python FactorFlow/main_cli.py eyeriss-conv 4 4 4 4 3 3
python FactorFlow/main_cli.py eyeriss 8 8 8

# Analytical model (no Bambu needed)
python src/model.py --ff experiments/eyeriss/conv/ex1/FF_output/FF_output.txt --n-mul 1 2 4 8 16
```

`src/main.py` must be run from the repo root (imports resolve relative to `src/`).

## Architecture

### End-to-end pipeline

```
config.json → FactorFlow → FF_output.txt → ff_parser.py → MappingInfo → _dispatch_and_generate()
                                                                              ├─ CONV: codegen/conv/eyeriss_generator.py
                                                                              └─ GEMM: codegen/gemm/eyeriss_generator.py
```

Dispatch key: `(mapping.workload, mapping.arch)` — `"CONV"+"eyeriss"` or `"GEMM"+"eyeriss"`. Workload is inferred from dims when the FF Architecture string is plain `"eyeriss"` (K+N present, no R → GEMM).

### Test structure

Tests live in `tests/eyeriss/{conv,gemm}/generated/exN/`. Each folder needs:
- `config.json` with `"force": false` (reuse cached FF mapping)
- `FF_output/FF_output.txt` (committed; FactorFlow not re-run during tests)

Running a test calls `main.py`, which generates C files into the same folder, compiles with gcc, and runs a CPU golden reference check. A zero exit code = correctness pass.

### Level classification (`_classify_levels` in `codegen/conv/eyeriss_generator.py`, reused by GEMM)

Every generator starts by splitting the FF hierarchy into three tiers:

| Tier | Which levels | Role in generated C |
|---|---|---|
| `outer_mem` | MemLevels before first SA level (DRAM, GlobalBuffer) | Sequential `#pragma GCC nounroll` tile loops |
| `fanout` | Levels containing "SA" (SACols, SARows) | Unrolled `#pragma GCC unroll` spatial lanes → accumulator dimensions |
| `inner_mem` | MemLevels after last SA level, excl. OutRegister (WRegister, InRegister) | Sequential inner reduction loops |

### Variable naming convention (CONV generator)

All loop variables use the **full level name in lowercase**, no abbreviations:

- Outer mem loops: `{level_lowercase}_{k}` — e.g. `globalbuffer_0`, `dram_0`
- SA fanout loops: `{level_lowercase}_{k}` — e.g. `sarows_0`, `sacols_1`
- Inner sequential loops: `{level_lowercase}_{k}` — e.g. `wregister_0`, `inregister_0`
- Reduction tree temporaries: `psum_{level}_{idx}` (not `_t{level}_{idx}`)
- Writeback tile coords: `tile_m`, `tile_p`, `tile_q`, `out_offset`

The GEMM generator has not yet adopted this convention (uses abbreviations like `gb`, `wr`, and loop vars `mri`/`mci`/`kci`).

### SA kernel structure (CONV)

`seq` delegates entirely to `sa` with `unroll=False`. All index arithmetic, banking, and output write logic is shared. When `unroll=True`: Phase 1 preloads weights into `w_tile[...]` (local regs via GCC SROA), Phase 2 reads only inputs from AXI. When `unroll=False`: weights read inline, no preload.

`#pragma GCC unroll N` is critical — Bambu receives already-unrolled C; `#pragma HLS unroll` is ignored by Bambu.

### CONV vs GEMM structural differences

- **Output dims**: CONV `{M,P,Q}`; GEMM `{M,N}` (N always stays in outer temporal loops, never in SA)
- **Reduction dim**: CONV reduces over C,R,S; GEMM reduces over K
- **Banking split**: CONV by `c%2` (channel parity); GEMM by `k%2` (K parity)
- **Accumulator**: CONV is multidimensional `acc[sarows_dims][sacols_dims]`; GEMM is flat 1D `acc[m_sf]`
- **Address computation**: CONV uses 2D convolution geometry (H×W maps, strides); GEMM uses simple matrix row×col

These differences mean the two generators cannot share `_emit_sa_compute_body` — they are correctly kept separate.
