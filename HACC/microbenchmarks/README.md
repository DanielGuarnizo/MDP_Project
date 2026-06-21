# AXI latency microbenchmarks

Two minimal kernels for calibrating HBM read and write latency on Alveo U55C.
Results feed the FactorFlow analytical model (Plan B calibration).

---

## read_bm.c

**Purpose:** measure pure AXI read latency.

**What it does:** reads N floats sequentially from `dram_input_p0`, accumulates
them into a local `sum`, writes `sum` to `dram_output_p0[0]`.

- One AXI read transaction per loop iteration (sequential, not burst-unrolled).
- The write of `sum` is required to prevent the compiler/synthesizer from
  eliminating the read loop as dead code.
- Use `--hw-profile` in the HACC harness to capture `rd_busy_cycles` and
  `rd_txn_count`; divide to get average read latency in cycles.

**Signature:**
```c
void read_bm(float* dram_input_p0, float* dram_output_p0, int n);
```

**Ports:**
| Arg | Direction | AXI bundle |
|-----|-----------|------------|
| `dram_input_p0`  | input  | `gmem_0` |
| `dram_output_p0` | output | `gmem_0` |
| `n`              | scalar | AXI-Lite  |

**Expected output:** `dram_output_p0[0]` = sum of all N input floats.

---

## write_bm.c

**Purpose:** measure pure AXI write latency.

**What it does:** writes the constant `1.0f` to N consecutive addresses on
`dram_output_p0`. No reads at all.

- One AXI write transaction per loop iteration (sequential).
- Use `--hw-profile` to capture `wr_busy_cycles` and `wr_txn_count`.

**Signature:**
```c
void write_bm(float* dram_output_p0, int n);
```

**Ports:**
| Arg | Direction | AXI bundle |
|-----|-----------|------------|
| `dram_output_p0` | output | `gmem_0` |
| `n`              | scalar | AXI-Lite  |

**Expected output:** `dram_output_p0[i] == 1.0f` for all `i < n`.

---

## Bambu synthesis

Both kernels use `--generate-interface=WB4` to match the existing project
convention. Replace `<vivado_backend.tcl>` with the project backend script.

```bash
# Read benchmark
bambu read_bm.c \
  --top-fname=read_bm \
  --device-name=xcu55c-fsvh2892-2L-e \
  --clock-period=3.333 \
  --generate-interface=WB4 \
  --experimental-set=BAMBU \
  --compiler=I386_GCC8 \
  -O3 \
  --backend-script-extensions=<vivado_backend.tcl>

# Write benchmark
bambu write_bm.c \
  --top-fname=write_bm \
  --device-name=xcu55c-fsvh2892-2L-e \
  --clock-period=3.333 \
  --generate-interface=WB4 \
  --experimental-set=BAMBU \
  --compiler=I386_GCC8 \
  -O3 \
  --backend-script-extensions=<vivado_backend.tcl>
```

After synthesis, feed each `top_level.v` through the HACC generator:

```bash
python HACC/hacc_gen/cli.py \
  --verilog <bambu_out>/top_level.v \
  --output  HACC/microbenchmarks/read_bm_deploy \
  --hw-profile
```

---

## Extracting latency numbers

The `--hw-profile` harness prints after kernel completion:

```
[hw-perf] rd_busy_cycles : <X>
[hw-perf] rd_txn_count   : <N>
[hw-perf] avg rd latency : <X/N> cycles/txn
```

At 300 MHz (3.333 ns clock), `cycles/txn * 3.333 ns` = latency in nanoseconds.

Use these two numbers (avg_rd_latency, avg_wr_latency) to update the
FactorFlow calibration constants in the analytical model.

---

## Notes / known concerns

1. **`#pragma GCC nounroll` vs Bambu**: Bambu parses GCC pragmas; `nounroll`
   prevents loop unrolling at IR level. The existing SA kernels use this
   pattern successfully, so it should work here too.

2. **`--generate-interface=WB4` vs `INFER`**: The existing `compile_bambu.sh`
   scripts use `INFER`. If Bambu fails to infer pointer types as AXI-master
   with WB4, switch to `INFER` — same functional result, slightly different
   AXI-Lite slave map. The HACC parser (`parser.py`) handles both.

3. **Dead-code elimination**: `write_bm` writes a compile-time constant
   (`1.0f`). Bambu may optimize this to a burst write or memset-style
   operation. That is fine for latency measurement — we still want sequential
   transactions. If Bambu emits a single burst, add a data dependency:
   `dram_output_p0[i] = (float)(i & 1) + 1.0f;`

4. **Bundle sharing (read_bm)**: input and output share `gmem_0`. This is the
   same pattern used in the SA kernels. Bambu time-multiplexes them. If you
   want fully independent ports, assign them different bundle names.

5. **n as a variable**: Bambu must be able to synthesize a loop with a
   variable upper bound. This is standard — the existing SA kernels use
   constant loops only because the mapping is fixed, but Bambu handles
   variable-bound loops fine.
