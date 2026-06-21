#!/usr/bin/env bash
# xo_to_xclbin_profile.sh — relinks existing panda.xo with --profile_kernel APM monitors
# Uses the XO from ex6_1_N_mul_1_v7 (already fully implemented — no re-synthesis needed)
# Only the v++ link step runs (~30-60 min).
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XO_SRC=~/workspace/deploy/ex6_1_N_mul_96_v6/xo/panda.xo
XO_DST="${SCRIPT_DIR}/xo/panda.xo"

echo "=== PROFILE RELINK START $(date) ==="
echo "Source XO : $XO_SRC"

[ -f "$XO_SRC" ] || { echo "ERROR: XO not found at $XO_SRC"; exit 1; }
cp "$XO_SRC" "$XO_DST"

mkdir -p "${SCRIPT_DIR}/build/vpp/logs" "${SCRIPT_DIR}/build/vpp/tmp" "${SCRIPT_DIR}/build/vpp/reports"

source /tools/Xilinx/Vitis/2024.2/settings64.sh

# Check --profile_kernel syntax for this Vitis version
echo "v++ version: $(v++ --version 2>&1 | head -1)"

v++ -t hw \
  --platform xilinx_u55c_gen3x16_xdma_3_202210_1 \
  --link "${XO_DST}" \
  --profile_kernel data:panda:panda_1:all \
  --log_dir    "${SCRIPT_DIR}/build/vpp/logs" \
  --temp_dir   "${SCRIPT_DIR}/build/vpp/tmp" \
  --report_dir "${SCRIPT_DIR}/build/vpp/reports" \
  --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE=AggressiveExplore \
  --vivado.prop run.impl_1.STEPS.PHYS_OPT_DESIGN.IS_ENABLED=true \
  --vivado.prop run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED=true \
  --vivado.prop run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE=AggressiveExplore \
  "--vivado.prop=run.impl_1.STEPS.PLACE_DESIGN.TCL.PRE=${SCRIPT_DIR}/pre_place_pblock.tcl" \
  --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.TCL.POST="${SCRIPT_DIR}/post_route.tcl" \
  --connectivity.sp panda_1.m_axi_gmem_0:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_1:HBM[1] \
  --connectivity.sp panda_1.m_axi_gmem_2:HBM[2] \
  --connectivity.sp panda_1.m_axi_gmem_3:HBM[3] \
  --connectivity.sp panda_1.m_axi_gmem_4:HBM[4] \
  --connectivity.sp panda_1.m_axi_gmem_5:HBM[5] \
  --connectivity.sp panda_1.m_axi_gmem_6:HBM[6] \
  --connectivity.sp panda_1.m_axi_gmem_7:HBM[7] \
  -o "${SCRIPT_DIR}/xo/panda_profile.xclbin"

echo "=== PROFILE RELINK DONE $(date) ==="
echo "Output: ${SCRIPT_DIR}/xo/panda_profile.xclbin"
touch "${SCRIPT_DIR}/.profile_relink_done"
