#define DTYPE float
#define M_TOTAL 4
#define P_TOTAL 4
#define Q_TOTAL 4
#define C_TOTAL 4
#define R_TOTAL 3
#define S_TOTAL 3

/* AXI pragmas for parallel memory buses */
#pragma HLS interface port = dram_in_b0 mode = m_axi offset = direct bundle = gmem_in0
#pragma HLS interface port = dram_in_b1 mode = m_axi offset = direct bundle = gmem_in1
#pragma HLS interface port = dram_w_b0  mode = m_axi offset = direct bundle = gmem_w0
#pragma HLS interface port = dram_w_b1  mode = m_axi offset = direct bundle = gmem_w1
#pragma HLS interface port = dram_out_b0 mode = m_axi offset = direct bundle = gmem_out0
#pragma HLS interface port = dram_out_b1 mode = m_axi offset = direct bundle = gmem_out1
#pragma HLS interface port = dram_out_b2 mode = m_axi offset = direct bundle = gmem_out2
#pragma HLS interface port = dram_out_b3 mode = m_axi offset = direct bundle = gmem_out3
#pragma HLS interface port = dram_out_b4 mode = m_axi offset = direct bundle = gmem_out4
#pragma HLS interface port = dram_out_b5 mode = m_axi offset = direct bundle = gmem_out5
#pragma HLS interface port = dram_out_b6 mode = m_axi offset = direct bundle = gmem_out6
#pragma HLS interface port = dram_out_b7 mode = m_axi offset = direct bundle = gmem_out7

void top_level(DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7)
{
    // SA (weight-preload) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=8, P=8, Q=8, C=4, R=3, S=3;
    const int H=10, W=10;
    const int Ptiles=8, Qtiles=2;
    const int in_banks=2;

    // sarows_0 → SARows_0 = S:3
    // sarows_1 → SARows_1 = C:4
    // sacols_0 → SACols_0 = Q:4
    // sacols_1 → SACols_1 = M:2
    // 96 PE accumulators: accumulator[3][4][4][2]
    DTYPE accumulator[3][4][4][2];

    // DRAM_0 = Q:2
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 2; ++dram_0) {
      // GlobalBuffer_0 = P:8
      #pragma GCC nounroll
      for (int globalbuffer_0 = 0; globalbuffer_0 < 8; ++globalbuffer_0) {
        // OutRegister_0 = M:4
        #pragma GCC nounroll
        for (int outregister_0 = 0; outregister_0 < 4; ++outregister_0) {
          // Zero 96 PE accumulators (nounroll — non-spatial init)
          #pragma GCC nounroll
          for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
            #pragma GCC nounroll
            for (int sarows_1 = 0; sarows_1 < 4; ++sarows_1) {
              #pragma GCC nounroll
              for (int sacols_0 = 0; sacols_0 < 4; ++sacols_0) {
                #pragma GCC nounroll
                for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
                  accumulator[sarows_0][sarows_1][sacols_0][sacols_1] = 0.0f;
                }
              }
            }
          }

          // WRegister → R:3 (sequential)
          #pragma GCC nounroll
          for (int wregister_0 = 0; wregister_0 < 3; ++wregister_0) {
            // ---- Phase 1: preload weights — 24 elems, no Q loop ----
            // weight_tile[3][4][2]: level-indexed, Q absent (weight is Q-independent)
            DTYPE weight_tile[3][4][2];
            #pragma GCC unroll 3
            for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
              #pragma GCC unroll 4
              for (int sarows_1 = 0; sarows_1 < 4; ++sarows_1) {
                #pragma GCC unroll 2
                for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
                  int global_channel_index = (sarows_1);
                  int channel_bank = global_channel_index & 1;
                  int channel_block_index = global_channel_index >> 1;
                  int weight_dram_index = ((outregister_0 * 2 + (sacols_1)) * ((C + in_banks - 1) / in_banks) + channel_block_index) * (R * S) + wregister_0 * S + sarows_0;
                  weight_tile[sarows_0][sarows_1][sacols_1] = (channel_bank==0) ? dram_w_b0[weight_dram_index] : dram_w_b1[weight_dram_index];
                }  // sacols_1 (preload)
              }  // sarows_1 (preload)
            }  // sarows_0 (preload)

            // ---- Phase 2a: multiply — 96 independent products ----
            // product[3][4][4][2]: GCC SROA → 96 scalar float regs
            DTYPE product[3][4][4][2];
            int output_col_base = dram_0 * 4;
            #pragma GCC unroll 3
            for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {  // S:3
              #pragma GCC unroll 4
              for (int sarows_1 = 0; sarows_1 < 4; ++sarows_1) {  // C:4
                #pragma GCC unroll 4
                for (int sacols_0 = 0; sacols_0 < 4; ++sacols_0) {  // Q:4
                  #pragma GCC unroll 2
                  for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {  // M:2
                    int global_channel_index = (sarows_1);
                    int channel_bank = global_channel_index & 1;
                    int channel_block_index = global_channel_index >> 1;
                    int input_channel_base_address = channel_block_index * (H * W);
                    int input_row_base_address = input_channel_base_address + (globalbuffer_0 + wregister_0) * W;
                    int input_column_offset = output_col_base + sacols_0 + sarows_0;
                    DTYPE weight_value = weight_tile[sarows_0][sarows_1][sacols_1];
                    DTYPE input_value = (channel_bank==0) ? dram_in_b0[input_row_base_address + input_column_offset]
                                                          : dram_in_b1[input_row_base_address + input_column_offset];
                    product[sarows_0][sarows_1][sacols_0][sacols_1] = weight_value * input_value;
                  }  // sacols_1 (M:2)
                }  // sacols_0 (Q:4)
              }  // sarows_1 (C:4)
            }  // sarows_0 (S:3)

            // ---- Phase 2b: accumulate — 96 independent, no RAW chain ----
            #pragma GCC unroll 3
            for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
              #pragma GCC unroll 4
              for (int sarows_1 = 0; sarows_1 < 4; ++sarows_1) {
                #pragma GCC unroll 4
                for (int sacols_0 = 0; sacols_0 < 4; ++sacols_0) {
                  #pragma GCC unroll 2
                  for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
                    accumulator[sarows_0][sarows_1][sacols_0][sacols_1] += product[sarows_0][sarows_1][sacols_0][sacols_1];
                  }  // sacols_1
                }  // sacols_0
              }  // sarows_1
            }  // sarows_0

          }  // wregister_0

          // ---- reduction: 96 acc → 8 outputs (12 inputs each) ----
          DTYPE reduced_output[4][2];
          #pragma GCC unroll 4
          for (int sacols_0 = 0; sacols_0 < 4; ++sacols_0) {
            #pragma GCC unroll 2
            for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
              DTYPE partial_sum_0_0 = accumulator[0][0][sacols_0][sacols_1] + accumulator[0][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_1 = accumulator[0][2][sacols_0][sacols_1] + accumulator[0][3][sacols_0][sacols_1];
              DTYPE partial_sum_0_2 = accumulator[1][0][sacols_0][sacols_1] + accumulator[1][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_3 = accumulator[1][2][sacols_0][sacols_1] + accumulator[1][3][sacols_0][sacols_1];
              DTYPE partial_sum_0_4 = accumulator[2][0][sacols_0][sacols_1] + accumulator[2][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_5 = accumulator[2][2][sacols_0][sacols_1] + accumulator[2][3][sacols_0][sacols_1];
              DTYPE partial_sum_1_0 = partial_sum_0_0 + partial_sum_0_1;
              DTYPE partial_sum_1_1 = partial_sum_0_2 + partial_sum_0_3;
              DTYPE partial_sum_1_2 = partial_sum_0_4 + partial_sum_0_5;
              DTYPE partial_sum_2_0 = partial_sum_1_0 + partial_sum_1_1;
              DTYPE partial_sum_3_0 = partial_sum_2_0 + partial_sum_1_2;
              reduced_output[sacols_0][sacols_1] = partial_sum_3_0;
            }  // sacols_1 (reduction)
          }  // sacols_0 (reduction)

          // OutRegister: write accumulator to banked output ports
          #pragma GCC unroll 4
          for (int sacols_0 = 0; sacols_0 < 4; ++sacols_0) {
            #pragma GCC unroll 2
            for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
              int output_bank = sacols_0*2 + sacols_1;
              int output_filter_tile = outregister_0;
              int output_row_tile = globalbuffer_0;
              int output_col_tile = dram_0;
              int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
              DTYPE output_value = reduced_output[sacols_0][sacols_1];
              switch(output_bank) {
                case 0: dram_out_b0[output_dram_offset] = output_value; break;
                case 1: dram_out_b1[output_dram_offset] = output_value; break;
                case 2: dram_out_b2[output_dram_offset] = output_value; break;
                case 3: dram_out_b3[output_dram_offset] = output_value; break;
                case 4: dram_out_b4[output_dram_offset] = output_value; break;
                case 5: dram_out_b5[output_dram_offset] = output_value; break;
                case 6: dram_out_b6[output_dram_offset] = output_value; break;
                case 7: dram_out_b7[output_dram_offset] = output_value; break;
                default: break;
              }
            }
          }
        }  // outregister_0
      }  // globalbuffer_0
    }  // dram_0
}
