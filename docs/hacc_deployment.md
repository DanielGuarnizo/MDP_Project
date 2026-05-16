# HACC Deployment: CONV Accelerator on Xilinx U55C

Reference folder: `/Users/danielguarnizo/workspace/Master/MDP/HACC/MDP-main`

---

## Concepts

### HACC (Heterogeneous Accelerated Compute Cluster)
A compute cluster at ETH Zurich / AMD-Xilinx with **Alveo U55C FPGA boards** (`xcu55c-fsvh2892-2L-e`). The board has HBM (High-Bandwidth Memory) directly attached to the FPGA fabric.

---

## The Deployment Pipeline

```
your_top_level.v (Bambu output)
       │
       │  [PROBLEM: Bambu control interface ≠ Vitis required interface]
       │
       ▼
Modified .v (+ translator wrapper)
       │
       │  vivado -mode batch -source script_to_xo.tcl
       ▼
  panda.xo       ← Xilinx Object: packaged RTL kernel IP
       │
       │  v++ --link  (xo_to_xclbin.tcl)
       ▼
  panda.xclbin   ← FPGA binary: placed & routed bitstream for U55C
       │
       │  loaded by XRT at runtime
       ▼
  Host Application (C++ + XRT API)
       │
       │  allocates HBM buffers, writes data, triggers kernel, reads results
       ▼
  Execution on FPGA
```

---

## The Core Problem: Bambu ≠ Vitis Interface

**Bambu generates** RTL with this control interface:

```verilog
module top_level(
  clock, reset, start_port,        // Bambu control
  dram_in_b0, dram_in_b1,         // scalar args (memory pointers, passed directly as ports)
  dram_w_b0,  dram_w_b1,
  dram_out_b0 ... dram_out_b7,
  done_port,                       // Bambu done signal
  m_axi_gmem_in0_*, ...            // AXI4 Master ports for memory
);
```

**Vitis requires** every kernel to expose:
- `ap_clk`, `ap_rst_n` (renamed clock/reset)
- An **AXI-Lite Slave** bus called `s_axi_control` — the host passes scalar arguments and triggers execution through this bus
- `ap_done`, `ap_ready` signals (part of `ap_ctrl_hs` handshake)
- **No direct scalar ports** — all scalars live in AXI-Lite registers inside the kernel

---

## The Translator Module (`bfs_translator.v` / `conv_translator.v`)

The "small component" that bridges Bambu's interface to Vitis's interface. It is a hand-written AXI-Lite slave that:

1. **Implements the `s_axi_control` bus** so the host can write to memory-mapped registers
2. **Holds registers** for each scalar argument with fixed addresses (e.g., `ADDR_NODES = 0x10`, `ADDR_EDGES = 0x18`, ...)
3. **Implements `AP_CTRL` register at address 0x00** — host writes bit-0=1 to start, reads bit-1 to check done
4. **Converts** the level-high `ap_start` from AXI-Lite into a **1-cycle pulse** `start_port` (rising-edge detect) that Bambu needs
5. **Routes** `done_port` from Bambu back as `ap_done` visible to the host

```
Host CPU
   │
   │  PCIe → XRT → s_axi_control bus
   ▼
conv_translator.v
   ├── s_axi_control writes → stored in reg_dram_in_b0, reg_dram_w_b0, ...
   ├── ADDR_AP_CTRL write(bit0=1) → fires 1-cycle start_port pulse to Bambu
   ├── Bambu done_port → ap_done → visible on ADDR_AP_CTRL bit1
   └── outputs: dram_in_b0, dram_w_b0, ... as wires into Bambu submodule
```

---

## What the Diff Does to `top_level.v`

Three types of changes (see `version_2/diff/bfs.diff` as reference):

**a) Module signature changes:**
- `clock` → `ap_clk`, `reset` → `ap_rst_n`, `done_port` → `ap_done`
- Remove scalar ports from port list (`dram_in_b0` etc. become internal `wire`)
- Add all `s_axi_control_*` ports and `ap_ready`
- Add AXI-Lite parameters (`C_S_AXI_CONTROL_DATA_WIDTH`, `C_S_AXI_CONTROL_ADDR_WIDTH`)

**b) Internal wiring:**
- Declare removed scalar ports as internal `wire` (driven by the translator)
- Instantiate `conv_translator` inside the top module
- Edge-detect `ap_start` → `start_port_pulse` (1-cycle) → Bambu's `start_port`

**c) Internal submodule connections:**
- `.clock(clock)` → `.clock(ap_clk)`, `.reset(reset)` → `.reset(ap_rst_n)`
- `.p_dram_in_b0(32'b0)` (was hardwired to zero!) → `.p_dram_in_b0(dram_in_b0)` (now driven by translator registers)

---

## The `.xo` File — Vitis Kernel Package

`script_to_xo.tcl` does:
1. Creates a Vivado project with the 3 source files (`top_level.v`, `conv_translator.v`, `panda_libtech.v`)
2. `ipx::package_project` — wraps design as an IP core
3. Declares `sdx_kernel=true`, `ctrl_protocol=ap_ctrl_hs` (tells Vitis this kernel uses AXI-Lite control)
4. Associates each `m_axi_gmem_*` interface to `ap_clk`
5. Adds registers to the `s_axi_control` memory map with their offsets
6. Associates each register to its `m_axi_*` bundle (linker uses this to assign HBM ports)
7. `package_xo` → outputs `panda.xo`

---

## The `.xclbin` File — Final FPGA Binary

`xo_to_xclbin.tcl` runs `v++`:

```bash
v++ -t hw_emu \
    --platform xilinx_u55c_gen3x16_xdma_3_202210_1 \
    --link panda.xo \
    --connectivity.sp panda_1.m_axi_gmem_in0:HBM[0] \
    --connectivity.sp panda_1.m_axi_gmem_w0:HBM[0]  \
    ... (all AXI masters mapped to HBM banks) \
    -o panda.xclbin
```

- `-t hw_emu` = hardware emulation (simulation), `-t hw` = real board deployment
- This **places and routes** the design for the U55C, producing the actual bitstream

---

## The Host Application (C++ / XRT)

```cpp
auto device = xrt::device(0);                      // open FPGA
auto uuid   = device.load_xclbin("panda.xclbin");  // load bitstream
auto krnl   = xrt::kernel(device, uuid, "panda");  // get kernel handle

// Allocate HBM-mapped buffers
auto bo_in0 = xrt::bo(device, size_in_b0, krnl.group_id(0));
// group_id(N) maps to N-th m_axi bundle in s_axi_control memory map

// Write data CPU → FPGA HBM
bo_in0.write(input_data_b0);
bo_in0.sync(XCL_BO_SYNC_BO_TO_DEVICE);

// Launch kernel:
//   XRT writes each bo physical address to its s_axi_control register,
//   then writes 1 to AP_CTRL bit0 → triggers start_port pulse in translator
auto run = krnl(bo_in0, bo_in1, bo_w0, bo_w1, bo_out0, ...);
run.wait();  // polls AP_CTRL bit1 (ap_done) via s_axi_control reads

// Read results FPGA HBM → CPU
bo_out0.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
bo_out0.read(output_buffer);
```

---

## CONV Accelerator Interface (ex1, n1)

Your `top_level.v` has:

| Scalar arg (pointer) | AXI Master | Suggested s_axi_control offset |
|---|---|---|
| `dram_in_b0` | `m_axi_gmem_in0` | `0x10` |
| `dram_in_b1` | `m_axi_gmem_in1` | `0x18` |
| `dram_w_b0`  | `m_axi_gmem_w0`  | `0x20` |
| `dram_w_b1`  | `m_axi_gmem_w1`  | `0x28` |
| `dram_out_b0`| `m_axi_gmem_out0`| `0x30` |
| `dram_out_b1`| `m_axi_gmem_out1`| `0x38` |
| `dram_out_b2`| `m_axi_gmem_out2`| `0x40` |
| `dram_out_b3`| `m_axi_gmem_out3`| `0x48` |
| `dram_out_b4`| `m_axi_gmem_out4`| `0x50` |
| `dram_out_b5`| `m_axi_gmem_out5`| `0x58` |
| `dram_out_b6`| `m_axi_gmem_out6`| `0x60` |
| `dram_out_b7`| `m_axi_gmem_out7`| `0x68` |

12 scalar args → 12 AXI Masters → 12 HBM bank mappings.

---

## Files to Create for CONV Deployment

| File | Action |
|---|---|
| `conv/src/top_level.v` | Apply diff: rename ports, add s_axi_control ports, remove scalar inputs, instantiate translator |
| `conv/src/conv_translator.v` | New AXI-Lite translator with 12 registers (addresses 0x10–0x68) |
| `conv/src/panda_libtech.v` | Copy from `version_2/src/panda_libtech.v` |
| `conv/script_to_xo.tcl` | Register 12 m_axi interfaces; 12 registers in s_axi_control memory map |
| `conv/xo_to_xclbin.tcl` | Map all 12 AXI masters to HBM banks |
| `host_application_conv/src/harness.cpp` | Allocate 12 buffers; call `krnl(bo_in_b0, bo_in_b1, bo_w_b0, bo_w_b1, bo_out_b0..bo_out_b7)` |

---

## Build & Run Commands

```bash
# Set environment
export XILINX_VITIS=/home/DIRECTORY/2025.1/Vitis
export XILINX_XRT=/opt/xilinx/xrt

# Create .xo (package RTL as Vitis kernel)
vivado -mode batch -source conv/script_to_xo.tcl

# Create .xclbin (hw emulation)
# (run xo_to_xclbin.tcl content as a shell script or via v++ directly)

# Build host
cmake -S host_application_conv -B build/host_application_conv
cmake --build build/host_application_conv -j

# Run (hw emulation)
export XCL_EMULATION_MODE=hw_emu
export XRT_VERBOSE=3
export LD_LIBRARY_PATH=/opt/xilinx/xrt/lib:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

./build/host_application_conv/bambu_application \
    ./conv/xo/panda.xclbin \
    ./data/input.data \
    ./data/check.data
```
