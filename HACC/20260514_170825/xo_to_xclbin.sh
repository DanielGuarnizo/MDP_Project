#!/usr/bin/env bash
# xo_to_xclbin.sh — links panda.xo into a .xclbin
# Run: bash xo_to_xclbin.sh
# Edit -t to switch between hw_emu and hw

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

v++ -t hw_emu \
  --platform xilinx_u55c_gen3x16_xdma_3_202210_1 \
  --link "${SCRIPT_DIR}/xo/panda.xo" \
  --connectivity.sp panda_1.m_axi_gmem_in0:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_in1:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_out0:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_out1:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_out2:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_out3:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_out4:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_out5:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_out6:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_out7:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_w0:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem_w1:HBM[0] \
  -o "${SCRIPT_DIR}/xo/panda.xclbin"

echo "Generated: ${SCRIPT_DIR}/xo/panda.xclbin"
