#define DTYPE float
#define M_TOTAL 4
#define K_TOTAL 4
#define N_TOTAL 4

/* AXI pragmas for parallel memory buses */
#pragma HLS interface port = dram_w_b0  mode = m_axi offset = direct bundle = gmem_w0
#pragma HLS interface port = dram_w_b1  mode = m_axi offset = direct bundle = gmem_w1
#pragma HLS interface port = dram_in_b0 mode = m_axi offset = direct bundle = gmem_in0
#pragma HLS interface port = dram_in_b1 mode = m_axi offset = direct bundle = gmem_in1
#pragma HLS interface port = dram_out_b0 mode = m_axi offset = direct bundle = gmem_out0
#pragma HLS interface port = dram_out_b1 mode = m_axi offset = direct bundle = gmem_out1
#pragma HLS interface port = dram_out_b2 mode = m_axi offset = direct bundle = gmem_out2
#pragma HLS interface port = dram_out_b3 mode = m_axi offset = direct bundle = gmem_out3

void top_level(DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3)
{
    // SA (weight-preload) Eyeriss GEMM -- loop structure mirrors FF mapping hierarchy
    const int M=4, K=4, N=4;
    const int m_sf=4, m_sacols=2, m_sarows=2;
    const int k_sa=4, k_blks=2, M_tiles=1;

    // Accumulator: flat 1D at function scope → GCC SROA → 4 scalar regs
    DTYPE accumulator[4];

    // GlobalBuffer_0 = N:4
    #pragma GCC nounroll
    for (int globalbuffer_0 = 0; globalbuffer_0 < 4; ++globalbuffer_0) {
      // Zero accumulator (nounroll — non-spatial init)
      #pragma GCC nounroll
      for (int accumulator_reset_index = 0; accumulator_reset_index < 4; ++accumulator_reset_index) accumulator[accumulator_reset_index] = 0.0f;

      // ---- Phase 1: preload A weights for this k-tile ----
      // weight_tile[2][2][4] → GCC SROA → 16 scalar regs
      DTYPE weight_tile[2][2][4];
      #pragma GCC unroll 2
      for (int sarows_0 = 0; sarows_0 < 2; ++sarows_0) {
        #pragma GCC unroll 2
        for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
          int global_m_index = 0 * 4 + sarows_0 * 2 + sacols_0;
          #pragma GCC unroll 4
          for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
            int global_k_index = sacols_1;
            int k_bank_selector = global_k_index & 1;
            int k_block_index  = global_k_index >> 1;
            weight_tile[sarows_0][sacols_0][sacols_1] = (k_bank_selector==0) ? dram_w_b0[global_m_index * k_blks + k_block_index]
                                                        : dram_w_b1[global_m_index * k_blks + k_block_index];
          }  // sacols_1
        }  // sacols_0
      }  // sarows_0

      // ---- Phase 2: compute using local w_tile + AXI B reads only ----
      // SARows M:2 × SACols M:2 × SACols K:4
      #pragma GCC unroll 2
      for (int sarows_0 = 0; sarows_0 < 2; ++sarows_0) {
        #pragma GCC unroll 2
        for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
          int output_row_lane_index = sarows_0 * 2 + sacols_0;
          #pragma GCC unroll 4
          for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
            int global_k_index = sacols_1;
            int k_bank_selector = global_k_index & 1;
            int k_block_index  = global_k_index >> 1;
            DTYPE weight_value = weight_tile[sarows_0][sacols_0][sacols_1];  // local reg — off AXI path
            DTYPE input_value = (k_bank_selector==0) ? dram_in_b0[k_block_index * N + globalbuffer_0]
                                                      : dram_in_b1[k_block_index * N + globalbuffer_0];
            accumulator[output_row_lane_index] += weight_value * input_value;
          }  // sacols_1
        }  // sacols_0
      }  // sarows_0


      // Write accumulator to banked output ports
      #pragma GCC unroll 4
      for (int output_row_lane_index = 0; output_row_lane_index < 4; ++output_row_lane_index) {
        int output_dram_offset = 0 * N + globalbuffer_0;
        switch(output_row_lane_index) {
          case 0: dram_out_b0[output_dram_offset] = accumulator[output_row_lane_index]; break;
          case 1: dram_out_b1[output_dram_offset] = accumulator[output_row_lane_index]; break;
          case 2: dram_out_b2[output_dram_offset] = accumulator[output_row_lane_index]; break;
          case 3: dram_out_b3[output_dram_offset] = accumulator[output_row_lane_index]; break;
          default: break;
        }
      }  // output_row_lane_index
    }  // globalbuffer_0
}
