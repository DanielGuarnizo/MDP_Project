#!/usr/bin/env bash
# xo_to_xclbin.sh — links panda.xo into a .xclbin
# Run: bash xo_to_xclbin.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${SCRIPT_DIR}/build/vpp/logs"          "${SCRIPT_DIR}/build/vpp/tmp"          "${SCRIPT_DIR}/build/vpp/reports"

v++ -t hw \
  --platform xilinx_u55c_gen3x16_xdma_3_202210_1 \
  --link "${SCRIPT_DIR}/xo/panda.xo" \
  --log_dir    "${SCRIPT_DIR}/build/vpp/logs" \
  --temp_dir   "${SCRIPT_DIR}/build/vpp/tmp" \
  --report_dir "${SCRIPT_DIR}/build/vpp/reports" \
  --connectivity.sp panda_1.m_axi_gmem_0:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_1:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_2:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_3:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_4:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_5:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_6:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_7:HBM[0] \
  -o "${SCRIPT_DIR}/xo/panda.xclbin"

echo "Generated: ${SCRIPT_DIR}/xo/panda.xclbin"
