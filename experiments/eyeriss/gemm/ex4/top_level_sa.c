#define DTYPE float
#define M_TOTAL 3
#define K_TOTAL 5
#define N_TOTAL 7

/* AXI pragmas for parallel memory buses */
#pragma HLS interface port = dram_w_b0  mode = m_axi offset = direct bundle = gmem_w0
#pragma HLS interface port = dram_w_b1  mode = m_axi offset = direct bundle = gmem_w1
#pragma HLS interface port = dram_in_b0 mode = m_axi offset = direct bundle = gmem_in0
#pragma HLS interface port = dram_in_b1 mode = m_axi offset = direct bundle = gmem_in1
#pragma HLS interface port = dram_out_b0 mode = m_axi offset = direct bundle = gmem_out0

void top_level(DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_out_b0)
{
    // SA (weight-preload) Eyeriss GEMM -- loop structure mirrors FF mapping hierarchy
    const int M=3, K=5, N=7;
    const int m_sf=1, m_sacols=1, m_sarows=1;
    const int k_sa=5, k_blks=3, M_tiles=3;

    // Accumulator: flat 1D at function scope → GCC SROA → 1 scalar regs
    DTYPE acc[1];

    // M tile (synthetic outer loop)
    #pragma GCC nounroll
    for (int m_tile = 0; m_tile < 3; ++m_tile) {
      // DRAM_0 = N:7
      #pragma GCC nounroll
      for (int dram_0 = 0; dram_0 < 7; ++dram_0) {
        // Zero accumulator (nounroll — non-spatial init)
        #pragma GCC nounroll
        for (int mi = 0; mi < 1; ++mi) acc[mi] = 0.0f;

        // ---- Phase 1: preload A weights for this k-tile ----
        // w_tile[1][1][5] → GCC SROA → 5 scalar regs
        DTYPE w_tile[1][1][5];
        #pragma GCC unroll 1
        for (int sarows_0 = 0; sarows_0 < 1; ++sarows_0) {
          #pragma GCC unroll 1
          for (int sacols_0 = 0; sacols_0 < 1; ++sacols_0) {
            int m_global = m_tile * 1 + sarows_0 * 1 + sacols_0;
            #pragma GCC unroll 5
            for (int sacols_1 = 0; sacols_1 < 5; ++sacols_1) {
              int k_global = sacols_1;
              int k_bank = k_global & 1;
              int k_blk  = k_global >> 1;
              w_tile[sarows_0][sacols_0][sacols_1] = (k_bank==0) ? dram_w_b0[m_global * k_blks + k_blk]
                                                   : dram_w_b1[m_global * k_blks + k_blk];
            }  // sacols_1
          }  // sacols_0
        }  // sarows_0

        // ---- Phase 2: compute using local w_tile + AXI B reads only ----
        // SARows M:1 × SACols M:1 × SACols K:5
        #pragma GCC unroll 1
        for (int sarows_0 = 0; sarows_0 < 1; ++sarows_0) {
          #pragma GCC unroll 1
          for (int sacols_0 = 0; sacols_0 < 1; ++sacols_0) {
            int m_lane = sarows_0 * 1 + sacols_0;
            #pragma GCC unroll 5
            for (int sacols_1 = 0; sacols_1 < 5; ++sacols_1) {
              int k_global = sacols_1;
              int k_bank = k_global & 1;
              int k_blk  = k_global >> 1;
              DTYPE wv = w_tile[sarows_0][sacols_0][sacols_1];  // local reg — off AXI path
              DTYPE iv = (k_bank==0) ? dram_in_b0[k_blk * N + dram_0]
                                     : dram_in_b1[k_blk * N + dram_0];
              acc[m_lane] += wv * iv;
            }  // sacols_1
          }  // sacols_0
        }  // sarows_0


        // Write accumulator to banked output ports
        #pragma GCC unroll 1
        for (int m_lane = 0; m_lane < 1; ++m_lane) {
          int out_offset = m_tile * N + dram_0;
          switch(m_lane) {
            case 0: dram_out_b0[out_offset] = acc[m_lane]; break;
            default: break;
          }
        }  // m_lane
      }  // dram_0
    }  // m_tile
}
