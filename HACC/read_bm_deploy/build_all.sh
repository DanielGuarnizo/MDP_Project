#!/usr/bin/env bash
# build_all.sh — full build: XO → xclbin + host binary
# Run on hacc-build-01 from the deploy folder.
set -eo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="$SCRIPT_DIR/build_all.log"
exec > >(tee -a "$LOG") 2>&1

echo "=== BUILD START $(date) ==="

# 1. Package Verilog → XO using Vivado
source /tools/Xilinx/Vivado/2024.2/settings64.sh
echo "[1/3] Packaging XO with Vivado..."
vivado -mode batch -source "$SCRIPT_DIR/script_to_xo.tcl" 2>&1
[ -f "$SCRIPT_DIR/xo/read_bm_krnl.xo" ] || { echo "ERROR: XO not created"; exit 1; }

# 2. Link XO → xclbin using v++
echo "[2/3] Linking xclbin with v++..."
bash "$SCRIPT_DIR/xo_to_xclbin.sh" 2>&1

# 3. Build host binary
source /tools/Xilinx/Vitis/2024.2/settings64.sh
echo "[3/3] Building host binary..."
cmake -S "$SCRIPT_DIR/host" -B "$SCRIPT_DIR/build/host" -DCMAKE_INSTALL_PREFIX="$SCRIPT_DIR" -DCMAKE_BUILD_TYPE=Release
cmake --build "$SCRIPT_DIR/build/host" --parallel 4
cmake --install "$SCRIPT_DIR/build/host"

echo "=== BUILD DONE $(date) ==="
