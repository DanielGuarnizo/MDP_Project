v++ -t hw_emu \
  --platform xilinx_u55c_gen3x16_xdma_3_202210_1 \
  --link ./version_2/xo/panda.xo \
  --connectivity.sp panda_1.m_axi_gmem0:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem1:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem2:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmem3:HBM[0] \
  --connectivity.sp panda_1.m_axi_gmemQ:HBM[0] \
  -o ./version_2/xo/panda.xclbin
