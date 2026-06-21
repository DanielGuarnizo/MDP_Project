#!/usr/bin/env bash
# build_all.sh — full build pipeline on hacc-build-01
# Run inside a tmux session: tmux new-session -d -s hacc_build 'bash build_all.sh; echo EXIT=$?; read'
set -eo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="$DEPLOY_DIR/build_all.log"
# Rotate previous log so each run starts clean
[ -f "$LOG" ] && mv "$LOG" "$LOG.prev"
exec &> >(tee "$LOG")
echo "=== BUILD START $(date) ==="

# Unset vars that Xilinx scripts expect to exist
export PYTHONPATH="${PYTHONPATH:-}"
export PYTHONHOME="${PYTHONHOME:-}"

# Vivado + Vitis environment
source /tools/Xilinx/Vivado/2024.2/settings64.sh
source /tools/Xilinx/Vitis/2024.2/settings64.sh

# XRT: setup.sh rejects paths not ending in /xrt, so set manually
export XILINX_XRT=/opt/xilinx/xrt_2024.2
export LD_LIBRARY_PATH=$XILINX_XRT/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export PATH=$XILINX_XRT/bin${PATH:+:$PATH}
export PYTHONPATH=$XILINX_XRT/python${PYTHONPATH:+:$PYTHONPATH}

echo "=== [1/3] Vivado: .v -> .xo (~10 min) ==="
cd "$DEPLOY_DIR"
vivado -mode batch -source script_to_xo.tcl
echo "=== .xo: $(ls -lh xo/panda.xo) ==="

echo "=== [2/3] v++: .xo -> .xclbin (edit -t flag for hw vs hw_emu, hw takes 4-8h) ==="
bash xo_to_xclbin.sh
echo "=== .xclbin: $(ls -lh xo/panda.xclbin) ==="

echo "=== [3/3] Host application ==="
cmake -S "$DEPLOY_DIR/host" -B "$DEPLOY_DIR/build/host"
cmake --build "$DEPLOY_DIR/build/host" -j$(nproc)
echo "=== Done: $(ls -lh $DEPLOY_DIR/build/host/bambu_application) ==="

touch "${DEPLOY_DIR}/.build_done"
echo "=== BUILD COMPLETE $(date) ==="
