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
#pragma HLS interface port = dram_output_p8 mode = m_axi offset = direct bundle = gmem_8
#pragma HLS interface port = dram_output_p9 mode = m_axi offset = direct bundle = gmem_9
#pragma HLS interface port = dram_output_p10 mode = m_axi offset = direct bundle = gmem_10
#pragma HLS interface port = dram_output_p11 mode = m_axi offset = direct bundle = gmem_11
#pragma HLS interface port = dram_output_p12 mode = m_axi offset = direct bundle = gmem_12
#pragma HLS interface port = dram_output_p13 mode = m_axi offset = direct bundle = gmem_13
#pragma HLS interface port = dram_output_p14 mode = m_axi offset = direct bundle = gmem_14
#pragma HLS interface port = dram_output_p15 mode = m_axi offset = direct bundle = gmem_15
#pragma HLS interface port = dram_output_p16 mode = m_axi offset = direct bundle = gmem_16
#pragma HLS interface port = dram_output_p17 mode = m_axi offset = direct bundle = gmem_17
#pragma HLS interface port = dram_output_p18 mode = m_axi offset = direct bundle = gmem_18
#pragma HLS interface port = dram_output_p19 mode = m_axi offset = direct bundle = gmem_19
#pragma HLS interface port = dram_output_p20 mode = m_axi offset = direct bundle = gmem_20
#pragma HLS interface port = dram_output_p21 mode = m_axi offset = direct bundle = gmem_21
#pragma HLS interface port = dram_output_p22 mode = m_axi offset = direct bundle = gmem_22
#pragma HLS interface port = dram_output_p23 mode = m_axi offset = direct bundle = gmem_23
#pragma HLS interface port = dram_output_p24 mode = m_axi offset = direct bundle = gmem_24
#pragma HLS interface port = dram_output_p25 mode = m_axi offset = direct bundle = gmem_25
#pragma HLS interface port = dram_output_p26 mode = m_axi offset = direct bundle = gmem_26
#pragma HLS interface port = dram_output_p27 mode = m_axi offset = direct bundle = gmem_27

void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7, DTYPE *dram_output_p8, DTYPE *dram_output_p9, DTYPE *dram_output_p10, DTYPE *dram_output_p11, DTYPE *dram_output_p12, DTYPE *dram_output_p13, DTYPE *dram_output_p14, DTYPE *dram_output_p15, DTYPE *dram_output_p16, DTYPE *dram_output_p17, DTYPE *dram_output_p18, DTYPE *dram_output_p19, DTYPE *dram_output_p20, DTYPE *dram_output_p21, DTYPE *dram_output_p22, DTYPE *dram_output_p23, DTYPE *dram_output_p24, DTYPE *dram_output_p25, DTYPE *dram_output_p26, DTYPE *dram_output_p27)
{
    // SA (weight-preload) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=64, P=56, Q=56, C=64, R=3, S=3;
    const int H=58, W=58;
    const int Ptiles=56, Qtiles=8;
    const int input_ports=2;

    // sarows_0 → SARows_0 = S:3
    // sarows_1 → SARows_1 = C:2
    // sarows_2 → SARows_2 = M:2
    // sacols_0 → SACols_0 = Q:7
    // sacols_1 → SACols_1 = M:2
    // 168 PE accumulators: accumulator[3][2][2][7][2]
    DTYPE accumulator[3][2][2][7][2];

    // DRAM_0 = Q:2
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 2; ++dram_0) {
      // GlobalBuffer_0 = Q:4
      #pragma GCC nounroll
      for (int globalbuffer_0 = 0; globalbuffer_0 < 4; ++globalbuffer_0) {
        // GlobalBuffer_1 = P:56
        #pragma GCC nounroll
        for (int globalbuffer_1 = 0; globalbuffer_1 < 56; ++globalbuffer_1) {
          // OutRegister_0 = M:16
          #pragma GCC nounroll
          for (int outregister_0 = 0; outregister_0 < 16; ++outregister_0) {
            // Zero 168 PE accumulators (nounroll — non-spatial init)
            #pragma GCC nounroll
            for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
              #pragma GCC nounroll
              for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
                #pragma GCC nounroll
                for (int sarows_2 = 0; sarows_2 < 2; ++sarows_2) {
                  #pragma GCC nounroll
                  for (int sacols_0 = 0; sacols_0 < 7; ++sacols_0) {
                    #pragma GCC nounroll
                    for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
                      accumulator[sarows_0][sarows_1][sarows_2][sacols_0][sacols_1] = 0.0f;
                    }
                  }
                }
              }
            }

            // DRAM_1 = C:4
            #pragma GCC nounroll
            for (int dram_1 = 0; dram_1 < 4; ++dram_1) {
              // WRegister → C:8 (sequential)
              #pragma GCC nounroll
              for (int wregister_0 = 0; wregister_0 < 8; ++wregister_0) {
                // WRegister → R:3 (sequential)
                #pragma GCC nounroll
                for (int wregister_1 = 0; wregister_1 < 3; ++wregister_1) {
                  // ---- Phase 1: preload weights — 24 elems, no Q loop ----
                  // weight_tile[3][2][2][2]: level-indexed, Q absent (weight is Q-independent)
                  DTYPE weight_tile[3][2][2][2];
                  #pragma GCC unroll 3
                  for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
                    #pragma GCC unroll 2
                    for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
                      #pragma GCC unroll 2
                      for (int sarows_2 = 0; sarows_2 < 2; ++sarows_2) {
                        #pragma GCC unroll 2
                        for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
                          int global_channel_index = (dram_1 * 16 + wregister_0 * 2 + (sarows_1));
                          int weight_port_index = global_channel_index % input_ports;
                          int channel_block_index = global_channel_index / input_ports;
                          int weight_dram_index = ((outregister_0 * 4 + (sarows_2*2 + sacols_1)) * ((C + input_ports - 1) / input_ports) + channel_block_index) * (R * S) + wregister_1 * S + sarows_0;
                          switch(weight_port_index) {
                            case 0: weight_tile[sarows_0][sarows_1][sarows_2][sacols_1] = dram_weight_p0[weight_dram_index]; break;
                            case 1: weight_tile[sarows_0][sarows_1][sarows_2][sacols_1] = dram_weight_p1[weight_dram_index]; break;
                            default: weight_tile[sarows_0][sarows_1][sarows_2][sacols_1] = 0.0f; break;
                          }
                        }  // sacols_1 (preload)
                      }  // sarows_2 (preload)
                    }  // sarows_1 (preload)
                  }  // sarows_0 (preload)

                  // ---- Phase 2a: multiply — 168 independent products ----
                  // product[3][2][2][7][2]: GCC SROA → 168 scalar float regs
                  DTYPE product[3][2][2][7][2];
                  int output_col_base = (dram_0 * 4 + globalbuffer_0) * 7;
                  #pragma GCC unroll 3
                  for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {  // S:3
                    #pragma GCC unroll 2
                    for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {  // C:2
                      #pragma GCC unroll 2
                      for (int sarows_2 = 0; sarows_2 < 2; ++sarows_2) {  // M:2
                        #pragma GCC unroll 7
                        for (int sacols_0 = 0; sacols_0 < 7; ++sacols_0) {  // Q:7
                          #pragma GCC unroll 2
                          for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {  // M:2
                            int global_channel_index = (dram_1 * 16 + wregister_0 * 2 + (sarows_1));
                            int input_port_index = global_channel_index % input_ports;
                            int channel_block_index = global_channel_index / input_ports;
                            int input_channel_base_address = channel_block_index * (H * W);
                            int input_row_base_address = input_channel_base_address + (globalbuffer_1 + wregister_1) * W;
                            int input_column_offset = output_col_base + sacols_0 + sarows_0;
                            DTYPE weight_value = weight_tile[sarows_0][sarows_1][sarows_2][sacols_1];
                            DTYPE input_value;
                            switch(input_port_index) {
                              case 0: input_value = dram_input_p0[input_row_base_address + input_column_offset]; break;
                              case 1: input_value = dram_input_p1[input_row_base_address + input_column_offset]; break;
                              default: input_value = 0.0f; break;
                            }
                            product[sarows_0][sarows_1][sarows_2][sacols_0][sacols_1] = weight_value * input_value;
                          }  // sacols_1 (M:2)
                        }  // sacols_0 (Q:7)
                      }  // sarows_2 (M:2)
                    }  // sarows_1 (C:2)
                  }  // sarows_0 (S:3)

                  // ---- Phase 2b: accumulate — 168 independent, no RAW chain ----
                  #pragma GCC unroll 3
                  for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
                    #pragma GCC unroll 2
                    for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
                      #pragma GCC unroll 2
                      for (int sarows_2 = 0; sarows_2 < 2; ++sarows_2) {
                        #pragma GCC unroll 7
                        for (int sacols_0 = 0; sacols_0 < 7; ++sacols_0) {
                          #pragma GCC unroll 2
                          for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
                            accumulator[sarows_0][sarows_1][sarows_2][sacols_0][sacols_1] += product[sarows_0][sarows_1][sarows_2][sacols_0][sacols_1];
                          }  // sacols_1
                        }  // sacols_0
                      }  // sarows_2
                    }  // sarows_1
                  }  // sarows_0

                }  // wregister_1
              }  // wregister_0

            }  // dram_1

            // ---- reduction: 168 acc → 28 outputs (6 inputs each) ----
            DTYPE reduced_output[2][7][2];
            #pragma GCC unroll 2
            for (int sarows_2 = 0; sarows_2 < 2; ++sarows_2) {
              #pragma GCC unroll 7
              for (int sacols_0 = 0; sacols_0 < 7; ++sacols_0) {
                #pragma GCC unroll 2
                for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
                  DTYPE partial_sum_0_0 = accumulator[0][0][sarows_2][sacols_0][sacols_1] + accumulator[0][1][sarows_2][sacols_0][sacols_1];
                  DTYPE partial_sum_0_1 = accumulator[1][0][sarows_2][sacols_0][sacols_1] + accumulator[1][1][sarows_2][sacols_0][sacols_1];
                  DTYPE partial_sum_0_2 = accumulator[2][0][sarows_2][sacols_0][sacols_1] + accumulator[2][1][sarows_2][sacols_0][sacols_1];
                  DTYPE partial_sum_1_0 = partial_sum_0_0 + partial_sum_0_1;
                  DTYPE partial_sum_2_0 = partial_sum_1_0 + partial_sum_0_2;
                  reduced_output[sarows_2][sacols_0][sacols_1] = partial_sum_2_0;
                }  // sacols_1 (reduction)
              }  // sacols_0 (reduction)
            }  // sarows_2 (reduction)

            // OutRegister: write accumulator to output DRAM ports
            #pragma GCC unroll 2
            for (int sarows_2 = 0; sarows_2 < 2; ++sarows_2) {
              #pragma GCC unroll 7
              for (int sacols_0 = 0; sacols_0 < 7; ++sacols_0) {
                #pragma GCC unroll 2
                for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
                  int output_bank = sarows_2*14 + sacols_0*2 + sacols_1;
                  int output_filter_tile = outregister_0;
                  int output_row_tile = globalbuffer_1;
                  int output_col_tile = (dram_0 * 4 + globalbuffer_0);
                  int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
                  DTYPE output_value = reduced_output[sarows_2][sacols_0][sacols_1];
                  switch(output_bank) {
                    case 0: dram_output_p0[output_dram_offset] = output_value; break;
                    case 1: dram_output_p1[output_dram_offset] = output_value; break;
                    case 2: dram_output_p2[output_dram_offset] = output_value; break;
                    case 3: dram_output_p3[output_dram_offset] = output_value; break;
                    case 4: dram_output_p4[output_dram_offset] = output_value; break;
                    case 5: dram_output_p5[output_dram_offset] = output_value; break;
                    case 6: dram_output_p6[output_dram_offset] = output_value; break;
                    case 7: dram_output_p7[output_dram_offset] = output_value; break;
                    case 8: dram_output_p8[output_dram_offset] = output_value; break;
                    case 9: dram_output_p9[output_dram_offset] = output_value; break;
                    case 10: dram_output_p10[output_dram_offset] = output_value; break;
                    case 11: dram_output_p11[output_dram_offset] = output_value; break;
                    case 12: dram_output_p12[output_dram_offset] = output_value; break;
                    case 13: dram_output_p13[output_dram_offset] = output_value; break;
                    case 14: dram_output_p14[output_dram_offset] = output_value; break;
                    case 15: dram_output_p15[output_dram_offset] = output_value; break;
                    case 16: dram_output_p16[output_dram_offset] = output_value; break;
                    case 17: dram_output_p17[output_dram_offset] = output_value; break;
                    case 18: dram_output_p18[output_dram_offset] = output_value; break;
                    case 19: dram_output_p19[output_dram_offset] = output_value; break;
                    case 20: dram_output_p20[output_dram_offset] = output_value; break;
                    case 21: dram_output_p21[output_dram_offset] = output_value; break;
                    case 22: dram_output_p22[output_dram_offset] = output_value; break;
                    case 23: dram_output_p23[output_dram_offset] = output_value; break;
                    case 24: dram_output_p24[output_dram_offset] = output_value; break;
                    case 25: dram_output_p25[output_dram_offset] = output_value; break;
                    case 26: dram_output_p26[output_dram_offset] = output_value; break;
                    case 27: dram_output_p27[output_dram_offset] = output_value; break;
                    default: break;
                  }
                }
              }
            }
          }  // outregister_0
        }  // globalbuffer_1
      }  // globalbuffer_0
    }  // dram_0
}
