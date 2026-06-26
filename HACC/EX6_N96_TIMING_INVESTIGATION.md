# EX6 N=96 Timing Investigation
## Context

Workload: convolution, M=4 P=6 Q=6 C=4 R=3 S=1 (eyeriss-conv mapping via FactorFlow).  
Architecture: 96 PEs (n_mul=96), 4 input ports + 4 weight ports + 24 output ports.  
Target board: Alveo U55C on ETH HACC (`hacc-alveo-u55c-01`), built on `hacc-build-01`.  
Vitis/Vivado: 2024.2. Platform: `xilinx_u55c_gen3x16_xdma_3_202210_1`.

### Two C source files used (NOT the same workload)

| File | Role |
|---|---|
| `tests/eyeriss/conv/generated/ex6_1/top_level_sa.c` | **OLD** — performed extra reads of inputs/weights beyond the ideal FactorFlow number. Used in v8 (clock=5.0). |
| `tests/alveo_u55c/conv/ex6/top_level_sa.c` | **NEW** (correct) — matches FactorFlow memory access count exactly. Used in all 3.3 ns experiments. |

The new C file is the correct baseline. v8 is a functional reference only, NOT the correct mapping.

---

## Verilog specs

| Param | v8 (old C) | n96 3.3ns (new C) |
|---|---|---|
| Bambu `--clock-period` | 5.0 ns | 3.3 ns |
| Bambu `--device-name` | `xcu55c-2Lfsvh2892-VVD` | `xcu55c-2Lfsvh2892-VVD` |
| Verilog lines | 52,350 | 67,373 |
| Location | `tests/eyeriss/conv/generated/ex6_1/Bambu_outputs/sa/n96/top_level.v` | `tests/alveo_u55c/conv/ex6/Bambu_outputs/sa/n96/top_level.v` |

Tighter Bambu clock-period → deeper pipelining → more registers → larger netlist.

---

## Critical mechanism: Vitis AUTO-FREQ-SCALING

Vitis 2024.2 automatically scales the kernel clock at bitstream generation time when timing is not met:

```
WARNING: [AUTO-FREQ-SCALING-04] The kernel clock ulp_ucs/aclk_kernel_00 has been
automatically changed to X MHz to enable proper functionality.
```

This means **no design built here actually ran at 300 MHz**. The actual operating frequency is the auto-scaled value, which equals `1000 / (period + |WNS|)` computed from the post-route timing report.

---

## All build results

| Build name | Bambu clock | Verilog | Routing directive | Placement | v++ freq target | Overlaps | WNS at 300MHz | Auto-scaled freq | Failing endpoints | TNS | Functional |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `ex6_1_N_mul_96_v8` | 5.0 ns | OLD (52K) | AggressiveExplore | Default | 300 MHz | 0 | **-2.495 ns** | **176.4 MHz** | 11,005 | -8592 ns | ✅ PASS |
| `ex6_n_mul_96_updated` | 3.3 ns | NEW (67K) | AggressiveExplore | Default | 300 MHz | **10,972** | N/A | N/A | N/A | N/A | ❌ ROUTING FAIL |
| `ex6_n96_3p3ns` | 3.3 ns | NEW (67K) | Explore | AltSpreadLogic_high | 300 MHz | 0 | **-3.821 ns** | **139.7 MHz** | 38,388 | -50089 ns | ❌ FUNC FAIL |
| `ex6_n96_C_explore_nospread` | 3.3 ns | NEW (67K) | Explore | Default | 300 MHz | **149,035** | N/A | N/A | N/A | N/A | ❌ ROUTING FAIL |
| `ex6_n96_D_aggr_nospread` | 3.3 ns | NEW (67K) | AggressiveExplore | Default | 300 MHz | **102,897** | N/A | N/A | N/A | N/A | ❌ ROUTING FAIL |
| `ex6_n96_A_200mhz` | 3.3 ns | NEW (67K) | Explore | AltSpreadLogic_high | **200 MHz** | 0 | **-3.821 ns** | **139.7 MHz** | 38,388 | -50089 ns | ❌ FUNC FAIL (same as 3.3ns) |
| `ex6_n96_B_aggr_spread` | 3.3 ns | NEW (67K) | **AggressiveExplore** | AltSpreadLogic_high | 300 MHz | **2** | N/A | N/A | N/A | N/A | ❌ ROUTING FAIL |

---

## Key findings

### 1. AltSpreadLogic_high is mandatory for the 67K-line design

Without it, routing fails regardless of routing directive:
- Explore + no spread → 149,035 overlaps
- AggressiveExplore + no spread → 102,897 overlaps

AggressiveExplore reduces overlaps more than Explore (102K vs 149K) but neither routes cleanly. The generator auto-tune (`is_large AND is_tight_clock → Explore + AltSpreadLogic_high`) is correct in requiring spread placement for this design class.

### 2. The functional failure at 139.7 MHz is not a simple timing violation

`ex6_n96_3p3ns` ran at **139.7 MHz** (auto-scaled by Vitis) — this is theoretically the max timing-met frequency. Yet verification failed with outputs of `~−5×10¹⁹` vs gold `~5`. Analysis of the float32 bit patterns showed:

- All HW outputs have float32 exponent = 192 (unbiased 65) — uniformly wrong
- Correct exponent for values ~3–5 is 0–2 (biased 127–129)
- The accumulated value is ~2⁶³ × correct_value, suggesting the accumulator partial-sum (psum) register is NOT being reset to 0.0 before each output computation
- Mantissa bits loosely track the correct computation, which is why `|HW| / 10¹⁹ ≈ gold` numerically — a coincidence, not a small representational error

The root cause is that the auto-scaled frequency (139.7 MHz) still leaves the critical paths at exactly zero margin. Vivado's STA model has finite accuracy; at zero margin, real silicon paths that are slightly slower than the model predicts will cause setup violations. With 38,388 failing endpoints at 300 MHz (vs 11,005 for v8), the 3.3ns design is far more sensitive to STA model inaccuracies.

### 3. The functional threshold is between 139.7 MHz and 176.4 MHz

Both v8 and 3.3ns are timing-violated at 300 MHz — neither meets the 300 MHz constraint. What determines functional correctness is the auto-scaled frequency:
- 176.4 MHz (v8) → PASS
- 139.7 MHz (3.3ns) → FAIL

The threshold is somewhere between these two values. To guarantee functional correctness, the new C file design must achieve WNS at 300 MHz of approximately −2.3 ns or better, so the auto-scaled frequency reaches ~176 MHz.

### 4. WNS / TNS comparison reveals the scale of the problem

| Metric | v8 | 3.3ns |
|---|---|---|
| WNS at 300 MHz | −2.495 ns | −3.821 ns |
| TNS at 300 MHz | −8,592 ns | −50,089 ns |
| Failing endpoints | 11,005 | 38,388 |
| Auto-scaled freq | 176.4 MHz | 139.7 MHz |

The 3.3ns design has 3.5× more failing endpoints and 5.8× worse TNS. Even at the auto-scaled frequency, the design is operating at the absolute edge of what STA predicts is possible — which is insufficient for reliable functional operation.

---

## Generator changes made (already committed)

`HACC/hacc_gen/models.py`, `parser.py`, `gen_tcl.py`, `cli.py` — auto-tune logic:

```python
_LARGE_LINE_THRESH  = 55_000   # lines in top_level.v
_TIGHT_CLOCK_THRESH = 4.5      # ns; covers 3.0, 3.3; excludes 5.0

if is_large and is_tight_clock and routing_directive == "AggressiveExplore":
    routing_directive = "Explore"
    use_spread_placement = True   # → AltSpreadLogic_high placement
```

This prevents routing failure for 3.3 ns / 67K-line designs. Backward-compatible: v8-class designs (52K lines, 5.0 ns) keep AggressiveExplore + default placement.

**Open question**: the auto-tune correctly prevents routing failure but does NOT solve the timing/WNS problem. Builds A and B are testing whether better WNS is achievable while keeping AltSpreadLogic_high.

---

## Experiments completed — final results (2026-06-26)

All experiments are done. Summary of what was learned from each:

### A: `--clock.freqHz` v++ option does nothing to P&R timing

Build A (200 MHz v++ target) produced **identical** timing to `ex6_n96_3p3ns`:
- WNS = -3.821 ns, 38,388 failing endpoints, auto-scaled to 139.7 MHz
- The `--clock.freqHz` flag only configures the MMCM/PLL in the bitstream; Vivado's P&R always optimizes against the platform's 300 MHz constraint regardless. Auto-freq-scaling then overrides the requested frequency anyway.
- **Do not use `--clock.freqHz` as a WNS improvement strategy** — it has no effect on timing closure.

### B: AggressiveExplore + AltSpreadLogic_high leaves 2 overlaps

Only 2 node overlaps remained, down from 10,972 without spread placement. This confirms spread placement dramatically reduces congestion for this design. However, "almost routed" is still a hard failure in Vivado. The routing took 7.5 hours before failing.

**Implication**: AggressiveExplore is not viable for the 67K-line 3.3ns design even with AltSpreadLogic_high. Only Explore + AltSpreadLogic_high achieves 0 overlaps for this design class.

### Full routing decision matrix for the 67K-line 3.3ns design

| Routing directive | Placement | Overlaps | Can route? |
|---|---|---|---|
| AggressiveExplore | Default | 10,972 | ❌ |
| AggressiveExplore | AltSpreadLogic_high | **2** | ❌ |
| Explore | Default | 149,035 | ❌ |
| Explore | AltSpreadLogic_high | **0** | ✅ (but WNS=-3.821 ns) |

Only one combination routes cleanly. That combination produces WNS=-3.821 ns → auto-scale to 139.7 MHz → functional failure.

---

## Final conclusion

**The 67K-line 3.3ns design cannot be made functionally correct through Vivado P&R strategy changes alone.** Every routing combination that achieves 0 overlaps produces WNS=-3.821 ns. Every strategy that improves WNS causes routing failures. There is no setting in between.

The root cause: Bambu at `--clock-period=3.3` generates a 29% larger netlist than at 5.0 (67K vs 52K lines), which pushes the design into a congestion regime that forces Vivado to choose between routing closure and timing closure — it cannot achieve both simultaneously.

---

## Critical discovery: the `-C=` Bambu flag and FP unit count

The `-C=__float_mule8m23b_127nih=N` flag controls how many hardware FP multiplier instances
Bambu generates. The 3.3 ns Verilog had **`-C=1`** — a single shared FP multiplier for all 96 PEs.
This means the 3.3 ns design was NOT a true 96-PE parallel design; all PEs were time-multiplexed
through one FP unit (effectively sequential). The 8.0 ns Verilog (recompiled with Serena's guidance)
has **`-C=96`** — 96 independent FP multiplier instances, the correct parallel architecture.

This explains the unexpected netlist sizes:
- 3.3 ns, `-C=1`: 67,373 lines (large scheduling FSM, complex control, 1 FP unit)
- 8.0 ns, `-C=96`: 65,638 lines (96 simple parallel FP units, simpler FSM per unit)

All functional results from the 3.3 ns experiments are for a sequential architecture, not the
intended n=96 parallel design. The 8.0 ns design is the first correct implementation.

---

## Next step: Deploy 8.0 ns Verilog (already compiled)

This is the only remaining path to functional correctness with the new C source.

- Run Bambu Docker with `--clock-period=5.0` on `tests/alveo_u55c/conv/ex6/top_level_sa.c`
- Expected netlist: ~52K lines (same class as v8)
- Generator auto-tune: `is_tight_clock=False` → AggressiveExplore + default placement (no spread)
- Expected WNS: ~−2.3 to −2.5 ns at 300 MHz → auto-scale to ~176 MHz → likely PASS
- This is what v8 proved works, now with the correct C file (correct memory access count)

Bambu command (run inside the Docker container):
```bash
bambu \
  --top-fname=top_level \
  --generate-interface=INFER \
  --compiler=I386_GCC8 \
  --clock-period=5.0 \
  --device-name=xcu55c-2Lfsvh2892-VVD \
  -O3 -v4 \
  --generate-tb=/workspace/tests/alveo_u55c/conv/ex6/testbench_common.c \
  [--tb-param-size=... same as 3.3ns] \
  -C=__float_mule8m23b_127nih=1 \
  -C=__float_adde8m23b_127nih=1 \
  --simulate \
  /workspace/tests/alveo_u55c/conv/ex6/top_level_sa.c
```

Output Verilog goes to: `tests/alveo_u55c/conv/ex6/Bambu_outputs/sa/n96_5ns/top_level.v` (suggested new subfolder to keep separate from 3.3ns).

---

## Deploy folder locations on hacc-build-01

```
~/workspace/deploy/
  ex6_1_N_mul_96_v8/          ← reference (old C, clock=5.0, PASSES)
  ex6_n_mul_96_updated/       ← first 3.3ns attempt (routing fail)
  ex6_n96_3p3ns/              ← Explore+spread (routes, functional fail)
  ex6_n96_C_explore_nospread/ ← Explore+no spread (routing fail: 149K overlaps)
  ex6_n96_D_aggr_nospread/    ← AggressiveExplore+no spread (routing fail: 102K overlaps)
  ex6_n96_A_200mhz/           ← Explore+spread+200MHz target (🔄 building)
  ex6_n96_B_aggr_spread/      ← AggressiveExplore+spread (🔄 building)
```
