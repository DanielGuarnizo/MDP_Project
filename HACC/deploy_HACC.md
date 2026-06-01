# HACC Deployment Guide

End-to-end guide for deploying a Bambu-generated accelerator to the ETH HACC cluster (Alveo U55C).

---

## Architecture overview

```
Your Mac
  │
  │  (OpenConnect VPN: sslvpn.ethz.ch/inf-docking)
  │
  ├──► hacc-build-01   ← synthesis + host app build (no booking needed)
  │         Vivado 2024.2 / Vitis 2024.2 / XRT 2024.2
  │
  └──► hacc-alveo-u55c-01   ← FPGA execution (booking required)
            Xilinx U55C + HBM, XRT 2024.2
```

Build pipeline:

```
src/*.v  ──[Vivado TCL]──► panda.xo  ──[v++ -t hw]──► panda.xclbin
                                                              │
accel_config.json + input/*.bin ──[host app]──► output/*.bin ◄┘
```

---

## Step 1 — Prerequisites

- **NETHZ account** with HACC access granted
  (apply at `https://github.com/fpgasystems/hacc/tree/main/docs`)
- **MFA** registered at `https://password.ethz.ch/qrcode`
- **Alveo node booked** at `https://hacc-booking.ethz.ch` (requires VPN; build nodes do not need booking)
- Two passwords: **NETHZ** (SSH) and **RADIUS** (VPN only)

---

## Step 2 — Connect to VPN

```bash
brew install openconnect            # macOS, one-time
sudo openconnect --user=YOUR_USERNAME@inf-systems.ethz.ch sslvpn.ethz.ch/inf-docking
```

When prompted:
- **Password**: RADIUS password
- **Second password**: OTP from your MFA app

Keep the terminal open (VPN drops if you close it). To run in background:

```bash
sudo openconnect --user=YOUR_USERNAME@inf-systems.ethz.ch \
  sslvpn.ethz.ch/inf-docking \
  --background --pid-file=/tmp/vpn.pid

# To disconnect:
sudo kill $(cat /tmp/vpn.pid)
```

---

## Step 3 — SSH setup (one-time)

### 3a. Add host keys

```bash
ssh-keyscan -H hacc-build-01.inf.ethz.ch   >> ~/.ssh/known_hosts
ssh-keyscan -H alveo-u55c-01.inf.ethz.ch   >> ~/.ssh/known_hosts
```

### 3b. Generate SSH key and copy to build node

```bash
ssh-keygen -t ed25519

# Copy to build node (enter NETHZ password once)
ssh-copy-id YOUR_USERNAME@hacc-build-01.inf.ethz.ch
```

The alveo node requires a separate key install **per booking** — see Step 3c.

### 3c. Install key on alveo node (repeat after each new booking)

```bash
ssh-copy-id -o ProxyJump=hacc-build-01 YOUR_USERNAME@alveo-u55c-01
```

This jumps through build-01 (already has your key) to reach the alveo node and appends
your public key to its `~/.ssh/authorized_keys`. Run this once right after booking.

### 3d. Add to SSH config

Edit `~/.ssh/config`:

```
ServerAliveInterval 300
ServerAliveCountMax 12

Host hacc-build-01
  HostName hacc-build-01.inf.ethz.ch
  User YOUR_USERNAME
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes
  ForwardAgent yes

Host hacc-alveo-u55c-01
  HostName alveo-u55c-01.inf.ethz.ch
  User YOUR_USERNAME
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes
  ForwardAgent yes
```

`ForwardAgent yes` is required so that `hacc-build-01` can forward your local key when
it `scp`s artifacts directly to the alveo node during `deploy_and_run.sh run`.

### 3e. Load key into SSH agent (required each session)

```bash
ssh-add ~/.ssh/id_ed25519
```

---

## Step 4 — Connect to the build node

### Option A — VS Code Remote SSH (recommended)

1. Install the **Remote - SSH** extension (`ms-vscode-remote.remote-ssh`)
2. `Cmd+Shift+P` → **Remote-SSH: Connect to Host…**
3. Select `hacc-build-01` from the dropdown
4. VS Code opens a remote window; open a terminal with `` Ctrl+` ``

### Option B — Plain SSH terminal

```bash
ssh hacc-build-01
```

---

## Step 5 — Generate deploy folder (on local Mac)

```bash
# From HACC root
python3 generate_hacc_project.py \
    --verilog path/to/top_level.v \
    --workload conv --dims 4 4 4 4 3 3

DEPLOY=$(ls -td [0-9]*/ | head -1 | tr -d '/')
```

The deploy dir contains:

```
<deploy_dir>/
├── src/           ← Verilog sources
├── host/          ← CMakeLists.txt, harness.cpp
├── accel_config.json
├── script_to_xo.tcl
├── xo_to_xclbin.sh
├── build_all.sh
└── xrt.ini        ← copied from lib/xrt.ini
```

---

## Step 6 — Generate input data (on local Mac)

```bash
# From HACC root
python3 gen_inputs.py $DEPLOY/input_data
```

Writes one `.bin` per input/output buffer into `<deploy_dir>/input_data/`, plus a
`golden_out.bin` golden reference used by `verify.py`.

If you have input files from a Bambu simulation, copy them into `<deploy_dir>/input_data/` directly.

---

## Step 7 — What `build_all.sh` does

`build_all.sh` is auto-generated. It:

1. Sets up Vivado 2024.2 + Vitis 2024.2 + XRT environments manually
   (workaround: XRT's `setup.sh` rejects paths not ending in `/xrt`)
2. Runs `vivado -mode batch -source script_to_xo.tcl` → `xo/panda.xo` (~10 min)
3. Runs `xo_to_xclbin.sh` with `-t hw` → `xo/panda.xclbin` (4–8 hours)
4. Runs `cmake` + `cmake --build` → `build/host/bambu_application`

---

## Step 8 — Build on hacc-build-01

> **Automated**: `deploy_and_run.sh build <local_deploy_dir>` handles rsync + tmux launch.

```bash
# From HACC root on local Mac
bash deploy_and_run.sh build $DEPLOY
```

Monitor progress:
```bash
ssh hacc-build-01 'tail -f ~/workspace/deploy/<deploy_dir>/build_all.log'
ssh hacc-build-01 'tmux attach -t hacc_build'    # Ctrl-B D to detach

# Check completion sentinel
ssh hacc-build-01 'test -f ~/workspace/deploy/<deploy_dir>/.build_done && echo DONE || echo BUILDING'
```

Expected times:

| Step | Duration |
|------|----------|
| Vivado `.v` → `.xo` | ~10 min |
| v++ `.xo` → `.xclbin` | 4–8 hours |
| cmake host app | ~2 min |

To pull Vivado `.rpt` files locally before running on alveo (useful to check utilization
or diagnose a failed build):

```bash
bash deploy_and_run.sh fetch-reports $DEPLOY
```

---

## Step 9 — Run on alveo + collect results

> **Automated**: `deploy_and_run.sh run <local_deploy_dir> <alveo_host>` handles all steps below.

```bash
# From HACC root on local Mac (input_data auto-found at $DEPLOY/input_data)
bash deploy_and_run.sh run $DEPLOY hacc-alveo-u55c-01
```

What the script does:
1. Verifies `.build_done` sentinel on hacc-build-01
2. `build-01 → alveo`: copies `panda.xclbin`, `bambu_application`, `accel_config.json`
3. `local → alveo`: copies `input_data/` and `xrt.ini` directly (skips build-01)
4. Runs `./bambu_application panda.xclbin accel_config.json input_data/ output_data/` on alveo
5. `alveo → local`: copies `output_data/`, `run.log`, profiling CSVs
6. `build-01 → local`: rsyncs all `.rpt` files
7. Runs `performance_analysis.sh $DEPLOY/run.log` locally
8. Runs `verify.py $DEPLOY` locally

Expected accelerator output:
```
[1] Config: accel_config.json   kernel=panda  buffers=12
[2] Opening device 0
[3] Allocating 12 buffers
[4] CPU -> FPGA
[5] Running kernel 'panda'
[6] Kernel done
[7] FPGA -> CPU
[8] Done.
[perf] CPU->FPGA transfer :   19.923 ms
[perf] Kernel execution   :    0.364 ms
[perf] FPGA->CPU transfer :   27.438 ms
[perf] Est. kernel cycles : 109200  (@ 300 MHz)
```

Expected verify output:
```
SUCCESS: all outputs match the golden reference.
```

---

## Step 10 — Performance analysis (local, automatic after run)

`deploy_and_run.sh run` calls this automatically. To re-run manually:

```bash
bash HACC/performance_analysis.sh <local_deploy_dir>/run.log
```

**What it reads** (all under `<deploy_dir>/`):

| File | Used for |
|------|---------|
| `run.log` | Wall-clock times (CPU→FPGA, kernel, FPGA→CPU) |
| `build/vpp/reports/link/imp/impl_1_full_util_routed.rpt` | CLB LUTs, Registers, RAMB36, DSPs |
| `build/vpp/reports/link/imp/impl_1_hw_bb_locked_timing_summary_postroute_physopted.rpt` | Real kernel clock (WNS) |

**Output**: `<deploy_dir>/perf_<timestamp>.txt`

**Real clock vs 300 MHz estimate:**

The harness labels its cycle count `@ 300 MHz` — this is the target, not the achieved clock.
`performance_analysis.sh` reads the Vivado timing report and computes the actual frequency:

```
Actual freq  : 154.4 MHz   ← 1000 / (3.333 ns target − (−3.144 ns WNS))
Kernel cycles: ~56202       ← kernel_ms × 154.4 MHz × 1000
```

**Power:** The Vivado v++ flow does not write `impl_1_power_routed.rpt` by default;
power shows N/A in the perf report — this is expected, not an error.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Host key verification failed` | Host not in `known_hosts` | `ssh-keyscan -H <host> >> ~/.ssh/known_hosts` |
| `Permission denied (publickey,password)` on build node | Key not in agent | `ssh-add ~/.ssh/id_ed25519` |
| `Permission denied (publickey,password)` on alveo (after booking) | Key not installed on new node | `ssh-copy-id -o ProxyJump=hacc-build-01 YOUR_USERNAME@alveo-u55c-01` |
| `perf_*.txt` shows N/A for utilization/clock | `.rpt` files not present locally | `bash deploy_and_run.sh fetch-reports <deploy_dir>` then re-run perf script |
| Routing failure with `--profile_kernel` flags | APM monitors exhaust routing on large designs (n=96 PE) | Remove `--profile_kernel` from `xo_to_xclbin.sh`; real cycles come from Vivado timing report |
| Power shows N/A in perf report | v++ flow doesn't write power `.rpt` by default | Expected — no fix needed |
| `Invalid location: /opt/xilinx/xrt_2024.2` | XRT `setup.sh` requires path ending in `/xrt` | Set `XILINX_XRT` manually — `build_all.sh` already does this |
| `unbound variable` when sourcing Vitis | `set -u` + unset `PYTHONPATH` | `export PYTHONPATH="${PYTHONPATH:-}"` before sourcing |
| `v++` exits immediately | Wrong platform or missing `.xo` | Check `ls /opt/xilinx/platforms/` matches platform in `xo_to_xclbin.sh` |
| `Cannot open: input_data/xxx.bin` | Missing input file | Run `python3 gen_inputs.py <deploy_dir>/input_data` |
| tmux session disappeared | Build crashed or node rebooted | `cat build_all.log`; re-launch with same command |

---

## Quick reference

```bash
# Re-load SSH key after reboot/new session
ssh-add ~/.ssh/id_ed25519

# Install key on alveo after each new booking
ssh-copy-id -o ProxyJump=hacc-build-01 YOUR_USERNAME@alveo-u55c-01

# Build on hacc-build-01 (exits immediately, build runs in tmux)
bash deploy_and_run.sh build <deploy_dir>

# Monitor build
ssh hacc-build-01 'tail -20 ~/workspace/deploy/<deploy_dir>/build_all.log'
ssh hacc-build-01 'test -f ~/workspace/deploy/<deploy_dir>/.build_done && echo DONE || echo BUILDING'

# Fetch Vivado .rpt files without running on alveo (works on partial/failed builds too)
bash deploy_and_run.sh fetch-reports <deploy_dir>

# Run on alveo (after build done)
bash deploy_and_run.sh run <deploy_dir> hacc-alveo-u55c-01

# Performance analysis (re-run manually if needed)
bash performance_analysis.sh <deploy_dir>/run.log

# Verify FPGA device on alveo
ssh hacc-alveo-u55c-01 'xrt-smi examine'
```
