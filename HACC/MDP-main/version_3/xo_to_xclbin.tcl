v++ -t hw_emu -g \
  --platform xilinx_u55c_gen3x16_xdma_3_202210_1 \
  --link ./version_3/xo/panda.xo \
  --connectivity.sp panda_1.m_axi_0:HBM[0] \
  --connectivity.sp panda_1.m_axi_1:HBM[1] \
  -o .version_3/xo/panda.xclbin


