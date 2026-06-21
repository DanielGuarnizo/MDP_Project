#!/usr/bin/env bash
# xo_to_xclbin.sh — link write_bm_krnl.xo into a hw xclbin for Alveo U55C
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XO="${SCRIPT_DIR}/xo/write_bm_krnl.xo"

[ -f "$XO" ] || { echo "ERROR: $XO not found — run script_to_xo.tcl first"; exit 1; }

mkdir -p "${SCRIPT_DIR}/build/vpp/logs" \
         "${SCRIPT_DIR}/build/vpp/tmp"  \
         "${SCRIPT_DIR}/build/vpp/reports"

source /tools/Xilinx/Vitis/2024.2/settings64.sh

echo "=== v++ link start $(date) ==="
v++ -t hw \
  --platform xilinx_u55c_gen3x16_xdma_3_202210_1 \
  --link "$XO" \
  --log_dir    "${SCRIPT_DIR}/build/vpp/logs"   \
  --temp_dir   "${SCRIPT_DIR}/build/vpp/tmp"    \
  --report_dir "${SCRIPT_DIR}/build/vpp/reports" \
  --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE=Explore \
  --vivado.prop run.impl_1.STEPS.PHYS_OPT_DESIGN.IS_ENABLED=true \
  --vivado.prop run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED=true \
  --vivado.prop run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE=Explore \
  "--vivado.prop=run.impl_1.STEPS.PLACE_DESIGN.TCL.PRE=${SCRIPT_DIR}/pre_place_pblock.tcl" \
  --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.TCL.POST="${SCRIPT_DIR}/post_route.tcl" \
  --connectivity.sp write_bm_krnl_1.m_axi_gmem_0:HBM[0] \
  -o "${SCRIPT_DIR}/xo/write_bm_krnl.xclbin"

echo "=== v++ link done $(date) ==="
touch "${SCRIPT_DIR}/.build_done"
