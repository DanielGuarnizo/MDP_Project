#define DTYPE float

/* AXI pragmas: inputs and outputs share bundles (time-multiplexed) */
#pragma HLS interface port = dram_input_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_input_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_weight_p0 mode = m_axi offset = direct bundle = gmem_2
#pragma HLS interface port = dram_weight_p1 mode = m_axi offset = direct bundle = gmem_3
#pragma HLS interface port = dram_output_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_output_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_output_p2 mode = m_axi offset = direct bundle = gmem_2
#pragma HLS interface port = dram_output_p3 mode = m_axi offset = direct bundle = gmem_3
#pragma HLS interface port = dram_output_p4 mode = m_axi offset = direct bundle = gmem_4
#pragma HLS interface port = dram_output_p5 mode = m_axi offset = direct bundle = gmem_5
#pragma HLS interface port = dram_output_p6 mode = m_axi offset = direct bundle = gmem_6
#pragma HLS interface port = dram_output_p7 mode = m_axi offset = direct bundle = gmem_7

void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7)
{
    // SA (weight-preload) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=8, P=8, Q=8, C=8, R=5, S=5;
    const int H=12, W=12;
    const int Ptiles=8, Qtiles=4;
    const int input_ports=2;

    // sarows_0 → SARows_0 = S:5
    // sarows_1 → SARows_1 = C:2
    // sacols_0 → SACols_0 = Q:2
    // sacols_1 → SACols_1 = M:4
    // 80 PE accumulators: accumulator[5][2][2][4]
    DTYPE accumulator[5][2][2][4];

    // DRAM_0 = Q:4
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 4; ++dram_0) {
      // GlobalBuffer_0 = P:8
      #pragma GCC nounroll
      for (int globalbuffer_0 = 0; globalbuffer_0 < 8; ++globalbuffer_0) {
        // OutRegister_0 = M:2
        #pragma GCC nounroll
        for (int outregister_0 = 0; outregister_0 < 2; ++outregister_0) {
          // Zero 80 PE accumulators (nounroll — non-spatial init)
          #pragma GCC nounroll
          for (int sarows_0 = 0; sarows_0 < 5; ++sarows_0) {
            #pragma GCC nounroll
            for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
              #pragma GCC nounroll
              for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
                #pragma GCC nounroll
                for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
                  accumulator[sarows_0][sarows_1][sacols_0][sacols_1] = 0.0f;
                }
              }
            }
          }

          // WRegister → C:4 (sequential)
          #pragma GCC nounroll
          for (int wregister_0 = 0; wregister_0 < 4; ++wregister_0) {
            // WRegister → R:5 (sequential)
            #pragma GCC nounroll
            for (int wregister_1 = 0; wregister_1 < 5; ++wregister_1) {
              // ---- Phase 1: preload weights — 40 elems, no Q loop ----
              // weight_tile[5][2][4]: level-indexed, Q absent (weight is Q-independent)
              DTYPE weight_tile[5][2][4];
              #pragma GCC unroll 5
              for (int sarows_0 = 0; sarows_0 < 5; ++sarows_0) {
                #pragma GCC unroll 2
                for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
                  #pragma GCC unroll 4
                  for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
                    int global_channel_index = (wregister_0 * 2 + (sarows_1));
                    int weight_port_index = global_channel_index % input_ports;
                    int channel_block_index = global_channel_index / input_ports;
                    int weight_dram_index = ((outregister_0 * 4 + (sacols_1)) * ((C + input_ports - 1) / input_ports) + channel_block_index) * (R * S) + wregister_1 * S + sarows_0;
                    switch(weight_port_index) {
                      case 0: weight_tile[sarows_0][sarows_1][sacols_1] = dram_weight_p0[weight_dram_index]; break;
                      case 1: weight_tile[sarows_0][sarows_1][sacols_1] = dram_weight_p1[weight_dram_index]; break;
                      default: weight_tile[sarows_0][sarows_1][sacols_1] = 0.0f; break;
                    }
                  }  // sacols_1 (preload)
                }  // sarows_1 (preload)
              }  // sarows_0 (preload)

              // ---- Phase 2a: multiply — 80 independent products ----
              // product[5][2][2][4]: GCC SROA → 80 scalar float regs
              DTYPE product[5][2][2][4];
              int output_col_base = dram_0 * 2;
              #pragma GCC unroll 5
              for (int sarows_0 = 0; sarows_0 < 5; ++sarows_0) {  // S:5
                #pragma GCC unroll 2
                for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {  // C:2
                  #pragma GCC unroll 2
                  for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {  // Q:2
                    #pragma GCC unroll 4
                    for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {  // M:4
                      int global_channel_index = (wregister_0 * 2 + (sarows_1));
                      int input_port_index = global_channel_index % input_ports;
                      int channel_block_index = global_channel_index / input_ports;
                      int input_channel_base_address = channel_block_index * (H * W);
                      int input_row_base_address = input_channel_base_address + (globalbuffer_0 + wregister_1) * W;
                      int input_column_offset = output_col_base + sacols_0 + sarows_0;
                      DTYPE weight_value = weight_tile[sarows_0][sarows_1][sacols_1];
                      DTYPE input_value;
                      switch(input_port_index) {
                        case 0: input_value = dram_input_p0[input_row_base_address + input_column_offset]; break;
                        case 1: input_value = dram_input_p1[input_row_base_address + input_column_offset]; break;
                        default: input_value = 0.0f; break;
                      }
                      product[sarows_0][sarows_1][sacols_0][sacols_1] = weight_value * input_value;
                    }  // sacols_1 (M:4)
                  }  // sacols_0 (Q:2)
                }  // sarows_1 (C:2)
              }  // sarows_0 (S:5)

              // ---- Phase 2b: accumulate — 80 independent, no RAW chain ----
              #pragma GCC unroll 5
              for (int sarows_0 = 0; sarows_0 < 5; ++sarows_0) {
                #pragma GCC unroll 2
                for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
                  #pragma GCC unroll 2
                  for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
                    #pragma GCC unroll 4
                    for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
                      accumulator[sarows_0][sarows_1][sacols_0][sacols_1] += product[sarows_0][sarows_1][sacols_0][sacols_1];
                    }  // sacols_1
                  }  // sacols_0
                }  // sarows_1
              }  // sarows_0

            }  // wregister_1
          }  // wregister_0

          // ---- reduction: 80 acc → 8 outputs (10 inputs each) ----
          DTYPE reduced_output[2][4];
          #pragma GCC unroll 2
          for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
            #pragma GCC unroll 4
            for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
              DTYPE partial_sum_0_0 = accumulator[0][0][sacols_0][sacols_1] + accumulator[0][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_1 = accumulator[1][0][sacols_0][sacols_1] + accumulator[1][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_2 = accumulator[2][0][sacols_0][sacols_1] + accumulator[2][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_3 = accumulator[3][0][sacols_0][sacols_1] + accumulator[3][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_4 = accumulator[4][0][sacols_0][sacols_1] + accumulator[4][1][sacols_0][sacols_1];
              DTYPE partial_sum_1_0 = partial_sum_0_0 + partial_sum_0_1;
              DTYPE partial_sum_1_1 = partial_sum_0_2 + partial_sum_0_3;
              DTYPE partial_sum_2_0 = partial_sum_1_0 + partial_sum_1_1;
              DTYPE partial_sum_3_0 = partial_sum_2_0 + partial_sum_0_4;
              reduced_output[sacols_0][sacols_1] = partial_sum_3_0;
            }  // sacols_1 (reduction)
          }  // sacols_0 (reduction)

          // OutRegister: write accumulator to output DRAM ports
          #pragma GCC unroll 2
          for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
            #pragma GCC unroll 4
            for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
              int output_bank = sacols_0*4 + sacols_1;
              int output_filter_tile = outregister_0;
              int output_row_tile = globalbuffer_0;
              int output_col_tile = dram_0;
              int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
              DTYPE output_value = reduced_output[sacols_0][sacols_1];
              switch(output_bank) {
                case 0: dram_output_p0[output_dram_offset] = output_value; break;
                case 1: dram_output_p1[output_dram_offset] = output_value; break;
                case 2: dram_output_p2[output_dram_offset] = output_value; break;
                case 3: dram_output_p3[output_dram_offset] = output_value; break;
                case 4: dram_output_p4[output_dram_offset] = output_value; break;
                case 5: dram_output_p5[output_dram_offset] = output_value; break;
                case 6: dram_output_p6[output_dram_offset] = output_value; break;
                case 7: dram_output_p7[output_dram_offset] = output_value; break;
                default: break;
              }
            }
          }
        }  // outregister_0
      }  // globalbuffer_0
    }  // dram_0
}
