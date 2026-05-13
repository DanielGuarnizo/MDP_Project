# MDP — Mapping-Driven Pipeline

End-to-end HLS pipeline: FactorFlow produces dataflow mappings, the MDP
code-generator emits C kernels, Bambu compiles them to RTL for cycle-accurate
simulation, and the analytical SA model predicts cycle counts in < 1 ms without
running Bambu.

## Clone

```bash
git clone --recurse-submodules <repo-url>
```

`FactorFlow` and `PandA-bambu` are git submodules — without
`--recurse-submodules` those directories will be empty.

---

## Setup (two commands)

```bash
# 1. Build image — installs all deps + PandA-bambu from source (~30-60 min)
docker build --platform linux/amd64 --progress=plain -t dev_mdp_image -f Dockerfile.dev .

# 2. Create container — stays on Docker daemon, attach via VSCode or exec
docker run -d -t --platform linux/amd64 --name dev_mdp_container -v "$(pwd)":/workspace dev_mdp_image
```

Enter the container:

```bash
docker exec -it dev_mdp_container bash
```

Start/stop with Docker Desktop or `docker start / docker stop dev_mdp_container`.
Attach a VSCode window via **Remote Explorer → Attach to Running Container**.

---

## Repository layout

```
src/
  sa_model.py            # analytical cycle model — predict without Bambu
  fit_sa_platform.py     # fit alpha coefficients from Bambu results
  bambu_calibration.json # per-platform alpha coefficients + stored measurements
  main.py                # codegen pipeline (FactorFlow → C kernel)
tests/
  eyeriss/conv/generated/ex{1..12}/   # pre-generated kernels with Bambu results
  test_sa_model_accuracy.py           # accuracy regression tests
  test_sa_model_parse.py              # parse + body_const correctness tests
experiments/
  eyeriss/conv/ex{1..12}/             # full experiment outputs (Bambu logs, Verilog)
docs/
  sa_model.md            # detailed model documentation
```

Each experiment folder contains a `config.json` (specifying the Bambu platform)
and a `top_level_sa.c` (the generated SA kernel).

---

## Analytical SA model (`sa_model.py`)

The model predicts Bambu cycle counts from the C source alone — no Bambu run
needed. All commands below run from `/workspace`.

### Predict for specific N\_mul values

```bash
python src/sa_model.py tests/eyeriss/conv/generated/ex1/top_level_sa.c 4 16 64
```

### Sweep N\_mul automatically

Sweeps `{1, 2, 4, 8, 16, 32, 64, N_PE}`:

```bash
python src/sa_model.py tests/eyeriss/conv/generated/ex1/top_level_sa.c --sweep
```

### Compare predictions against measured Bambu results

```bash
# Uses local Bambu XML files (tests/) or JSON stored values (experiments/)
python src/sa_model.py tests/eyeriss/conv/generated/ex1/top_level_sa.c --sweep --compare
python src/sa_model.py tests/eyeriss/conv/generated/ex4/top_level_sa.c --sweep --compare
python src/sa_model.py experiments/eyeriss/conv/ex1/top_level_sa.c --sweep --compare
```

Example output:

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

The model reads the platform from `config.json` next to the C file, looks up
the matching alpha coefficients in `src/bambu_calibration.json`, and exits with
a clear error if no calibration exists for that platform yet.

---

## Fitting a new platform (`fit_sa_platform.py`)

When you run Bambu on a new device or clock period, the alpha coefficients must
be re-fitted from measured cycle counts.

### What you need

- At least **two structurally different experiments** on the new platform:
  one with inner sequential loops (`n_seq ≥ 1`, e.g. R=3) and one without
  (`n_seq = 0`, e.g. R=1).  A single experiment only identifies 3 of the 4
  alpha parameters (see `docs/sa_model.md` for the identifiability analysis).
- Each experiment run at **3 or more N\_mul values** via Bambu.

### Mode 1 — from Bambu XML files

After running Bambu, each `Bambu_outputs/sa/nX/` directory should contain a
`bambu_results_0.xml` file. Pass all relevant SA directories:

```bash
# Fit from two experiments, write result into bambu_calibration.json
python src/fit_sa_platform.py \
  tests/eyeriss/conv/generated/ex1/Bambu_outputs/sa \
  tests/eyeriss/conv/generated/ex4/Bambu_outputs/sa \
  --update
```

```bash
# Fit from a single experiment (rank 3/4 — alpha_func will be 0)
python src/fit_sa_platform.py \
  tests/eyeriss/conv/generated/ex11/Bambu_outputs/sa \
  --update
```

### Mode 2 — from stored JSON values (`--from-json`)

If Bambu XML files are not available but `measured_cycles` are already stored
in `bambu_calibration.json`, point to the experiment directories instead:

```bash
python src/fit_sa_platform.py --from-json \
  experiments/eyeriss/conv/ex1 \
  experiments/eyeriss/conv/ex2 \
  experiments/eyeriss/conv/ex3 \
  experiments/eyeriss/conv/ex4 \
  experiments/eyeriss/conv/ex5 \
  experiments/eyeriss/conv/ex6 \
  --update
```

### Dry run (preview without writing)

Omit `--update` to print the fitted parameters without modifying the JSON:

```bash
python src/fit_sa_platform.py \
  tests/eyeriss/conv/generated/ex1/Bambu_outputs/sa \
  tests/eyeriss/conv/generated/ex4/Bambu_outputs/sa
```

### After fitting

The new platform entry appears in `src/bambu_calibration.json` and
`sa_model.py` will use it automatically for any `config.json` that references
the same compiler / clock period / device combination.

---

## Currently calibrated platforms

| Platform key | Device | Fitted from | R² |
|---|---|---|---|
| `I386_GCC8\|5\|xc7z020-1clg484-VVD` | Zynq-7020 | tests/ex1 + tests/ex4 (16 pts) | 0.99999 |
| `I386_GCC8\|5\|xcu55c-2Lfsvh2892-VVD` | Ultrascale+ | tests/ex11 (7 pts) | 0.99994 |
| `I386_GCC8\|5\|default` | (no device) | experiments/ex1–ex6 (47 pts) | — |

---

## Tests

```bash
# All tests
python -m pytest tests/

# SA model accuracy and parse tests only (fast, no Bambu)
python -m pytest tests/test_sa_model_accuracy.py tests/test_sa_model_parse.py -v

# Codegen correctness (compiles and runs C golden reference)
python -m pytest tests/eyeriss/conv/test_eyeriss_conv.py -v
python -m pytest tests/eyeriss/gemm/test_eyeriss_gemm.py -v
```

---

## Full pipeline (codegen only, no Bambu)

```bash
# Generate C kernel for a single experiment
python src/main.py --config tests/eyeriss/conv/generated/ex1/config.json

# FactorFlow directly (args = M P Q C R S for CONV)
python FactorFlow/main_cli.py eyeriss-conv 4 4 4 4 3 3
```

`src/main.py` must be run from `/workspace`.
