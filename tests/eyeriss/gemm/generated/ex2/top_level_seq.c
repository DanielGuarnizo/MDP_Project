#define DTYPE float
#define M_TOTAL 32
#define K_TOTAL 32
#define N_TOTAL 32

/* AXI pragmas for parallel memory buses */
#pragma HLS interface port = dram_w_b0  mode = m_axi offset = direct bundle = gmem_w0
#pragma HLS interface port = dram_w_b1  mode = m_axi offset = direct bundle = gmem_w1
#pragma HLS interface port = dram_in_b0 mode = m_axi offset = direct bundle = gmem_in0
#pragma HLS interface port = dram_in_b1 mode = m_axi offset = direct bundle = gmem_in1
#pragma HLS interface port = dram_out_b0 mode = m_axi offset = direct bundle = gmem_out0
#pragma HLS interface port = dram_out_b1 mode = m_axi offset = direct bundle = gmem_out1
#pragma HLS interface port = dram_out_b2 mode = m_axi offset = direct bundle = gmem_out2
#pragma HLS interface port = dram_out_b3 mode = m_axi offset = direct bundle = gmem_out3
#pragma HLS interface port = dram_out_b4 mode = m_axi offset = direct bundle = gmem_out4
#pragma HLS interface port = dram_out_b5 mode = m_axi offset = direct bundle = gmem_out5
#pragma HLS interface port = dram_out_b6 mode = m_axi offset = direct bundle = gmem_out6
#pragma HLS interface port = dram_out_b7 mode = m_axi offset = direct bundle = gmem_out7

void top_level(DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7)
{
    // sequential baseline Eyeriss GEMM -- loop structure mirrors FF mapping hierarchy
    const int M=32, K=32, N=32;
    const int m_sf=8, m_sacols=1, m_sarows=8;
    const int k_sa=8, k_blks=16, M_tiles=4;

    // Accumulator: flat 1D at function scope → GCC SROA → 8 scalar regs
    DTYPE accumulator[8];

    // M tile (synthetic outer loop)
    #pragma GCC nounroll
    for (int m_tile = 0; m_tile < 4; ++m_tile) {
      // DRAM_0 = N:8
      #pragma GCC nounroll
      for (int dram_0 = 0; dram_0 < 8; ++dram_0) {
        // GlobalBuffer_0 = N:4
        #pragma GCC nounroll
        for (int globalbuffer_0 = 0; globalbuffer_0 < 4; ++globalbuffer_0) {
          // Zero accumulator (nounroll — non-spatial init)
          #pragma GCC nounroll
          for (int accumulator_reset_index = 0; accumulator_reset_index < 8; ++accumulator_reset_index) accumulator[accumulator_reset_index] = 0.0f;

          // WRegister → K:4 (sequential)
          #pragma GCC nounroll
          for (int wregister_0 = 0; wregister_0 < 4; ++wregister_0) {
            // SARows M:8 × SACols M:1 × SACols K:8
            #pragma GCC nounroll 8
            for (int sarows_0 = 0; sarows_0 < 8; ++sarows_0) {
              #pragma GCC nounroll 1
              for (int sacols_0 = 0; sacols_0 < 1; ++sacols_0) {
                int output_row_lane_index = sarows_0 * 1 + sacols_0;
                int global_m_index = m_tile * 8 + output_row_lane_index;
                #pragma GCC nounroll 8
                for (int sacols_1 = 0; sacols_1 < 8; ++sacols_1) {
                  int global_k_index = wregister_0 * 8 + sacols_1;
                  int k_bank_selector = global_k_index & 1;
                  int k_block_index  = global_k_index >> 1;
                  DTYPE weight_value = (k_bank_selector==0) ? dram_w_b0[global_m_index * k_blks + k_block_index]
                                                             : dram_w_b1[global_m_index * k_blks + k_block_index];
                  DTYPE input_value = (k_bank_selector==0) ? dram_in_b0[k_block_index * N + dram_0 * 4 + globalbuffer_0]
                                                            : dram_in_b1[k_block_index * N + dram_0 * 4 + globalbuffer_0];
                  accumulator[output_row_lane_index] += weight_value * input_value;
                }  // sacols_1
              }  // sacols_0
            }  // sarows_0

          }  // wregister_0

          // Write accumulator to banked output ports
          #pragma GCC nounroll 8
          for (int output_row_lane_index = 0; output_row_lane_index < 8; ++output_row_lane_index) {
            int output_dram_offset = m_tile * N + dram_0 * 4 + globalbuffer_0;
            switch(output_row_lane_index) {
              case 0: dram_out_b0[output_dram_offset] = accumulator[output_row_lane_index]; break;
              case 1: dram_out_b1[output_dram_offset] = accumulator[output_row_lane_index]; break;
              case 2: dram_out_b2[output_dram_offset] = accumulator[output_row_lane_index]; break;
              case 3: dram_out_b3[output_dram_offset] = accumulator[output_row_lane_index]; break;
              case 4: dram_out_b4[output_dram_offset] = accumulator[output_row_lane_index]; break;
              case 5: dram_out_b5[output_dram_offset] = accumulator[output_row_lane_index]; break;
              case 6: dram_out_b6[output_dram_offset] = accumulator[output_row_lane_index]; break;
              case 7: dram_out_b7[output_dram_offset] = accumulator[output_row_lane_index]; break;
              default: break;
            }
          }  // output_row_lane_index
        }  // globalbuffer_0
      }  // dram_0
    }  // m_tile
}
