#!/usr/bin/env bash
# xo_to_xclbin.sh — links panda.xo into a .xclbin
# Run: bash xo_to_xclbin.sh
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${SCRIPT_DIR}/build/vpp/logs"          "${SCRIPT_DIR}/build/vpp/tmp"          "${SCRIPT_DIR}/build/vpp/reports"

v++ -t hw \
  --platform xilinx_u55c_gen3x16_xdma_3_202210_1 \
  --link "${SCRIPT_DIR}/xo/panda.xo" \
  --log_dir    "${SCRIPT_DIR}/build/vpp/logs" \
  --temp_dir   "${SCRIPT_DIR}/build/vpp/tmp" \
  --report_dir "${SCRIPT_DIR}/build/vpp/reports" \
  --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE=AggressiveExplore \
  --vivado.prop run.impl_1.STEPS.PHYS_OPT_DESIGN.IS_ENABLED=true \
  --vivado.prop run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED=true \
  --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.TCL.POST="${SCRIPT_DIR}/post_route.tcl" \
  --connectivity.sp panda_1.m_axi_gmem_0:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_1:HBM[1] \
  --connectivity.sp panda_1.m_axi_gmem_2:HBM[2] \
  --connectivity.sp panda_1.m_axi_gmem_3:HBM[3] \
  --connectivity.sp panda_1.m_axi_gmem_4:HBM[4] \
  --connectivity.sp panda_1.m_axi_gmem_5:HBM[5] \
  --connectivity.sp panda_1.m_axi_gmem_6:HBM[6] \
  --connectivity.sp panda_1.m_axi_gmem_7:HBM[7] \
  -o "${SCRIPT_DIR}/xo/panda.xclbin"

echo "Generated: ${SCRIPT_DIR}/xo/panda.xclbin"
