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
#pragma HLS interface port = dram_out_b8 mode = m_axi offset = direct bundle = gmem_out8
#pragma HLS interface port = dram_out_b9 mode = m_axi offset = direct bundle = gmem_out9
#pragma HLS interface port = dram_out_b10 mode = m_axi offset = direct bundle = gmem_out10
#pragma HLS interface port = dram_out_b11 mode = m_axi offset = direct bundle = gmem_out11
#pragma HLS interface port = dram_out_b12 mode = m_axi offset = direct bundle = gmem_out12
#pragma HLS interface port = dram_out_b13 mode = m_axi offset = direct bundle = gmem_out13
#pragma HLS interface port = dram_out_b14 mode = m_axi offset = direct bundle = gmem_out14
#pragma HLS interface port = dram_out_b15 mode = m_axi offset = direct bundle = gmem_out15
#pragma HLS interface port = dram_out_b16 mode = m_axi offset = direct bundle = gmem_out16
#pragma HLS interface port = dram_out_b17 mode = m_axi offset = direct bundle = gmem_out17
#pragma HLS interface port = dram_out_b18 mode = m_axi offset = direct bundle = gmem_out18
#pragma HLS interface port = dram_out_b19 mode = m_axi offset = direct bundle = gmem_out19
#pragma HLS interface port = dram_out_b20 mode = m_axi offset = direct bundle = gmem_out20
#pragma HLS interface port = dram_out_b21 mode = m_axi offset = direct bundle = gmem_out21
#pragma HLS interface port = dram_out_b22 mode = m_axi offset = direct bundle = gmem_out22
#pragma HLS interface port = dram_out_b23 mode = m_axi offset = direct bundle = gmem_out23
#pragma HLS interface port = dram_out_b24 mode = m_axi offset = direct bundle = gmem_out24
#pragma HLS interface port = dram_out_b25 mode = m_axi offset = direct bundle = gmem_out25
#pragma HLS interface port = dram_out_b26 mode = m_axi offset = direct bundle = gmem_out26
#pragma HLS interface port = dram_out_b27 mode = m_axi offset = direct bundle = gmem_out27

void top_level(DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7, DTYPE *dram_out_b8, DTYPE *dram_out_b9, DTYPE *dram_out_b10, DTYPE *dram_out_b11, DTYPE *dram_out_b12, DTYPE *dram_out_b13, DTYPE *dram_out_b14, DTYPE *dram_out_b15, DTYPE *dram_out_b16, DTYPE *dram_out_b17, DTYPE *dram_out_b18, DTYPE *dram_out_b19, DTYPE *dram_out_b20, DTYPE *dram_out_b21, DTYPE *dram_out_b22, DTYPE *dram_out_b23, DTYPE *dram_out_b24, DTYPE *dram_out_b25, DTYPE *dram_out_b26, DTYPE *dram_out_b27)
{
    // SA (weight-preload) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=64, P=56, Q=56, C=64, R=3, S=3;
    const int H=58, W=58;
    const int Ptiles=56, Qtiles=8;
    const int in_banks=2;

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
                          int channel_bank = global_channel_index & 1;
                          int channel_block_index = global_channel_index >> 1;
                          int weight_dram_index = ((outregister_0 * 4 + (sarows_2*2 + sacols_1)) * ((C + in_banks - 1) / in_banks) + channel_block_index) * (R * S) + wregister_1 * S + sarows_0;
                          weight_tile[sarows_0][sarows_1][sarows_2][sacols_1] = (channel_bank==0) ? dram_w_b0[weight_dram_index] : dram_w_b1[weight_dram_index];
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
                            int channel_bank = global_channel_index & 1;
                            int channel_block_index = global_channel_index >> 1;
                            int input_channel_base_address = channel_block_index * (H * W);
                            int input_row_base_address = input_channel_base_address + (globalbuffer_1 + wregister_1) * W;
                            int input_column_offset = output_col_base + sacols_0 + sarows_0;
                            DTYPE weight_value = weight_tile[sarows_0][sarows_1][sarows_2][sacols_1];
                            DTYPE input_value = (channel_bank==0) ? dram_in_b0[input_row_base_address + input_column_offset]
                                                                  : dram_in_b1[input_row_base_address + input_column_offset];
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

            // OutRegister: write accumulator to banked output ports
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
                    case 0: dram_out_b0[output_dram_offset] = output_value; break;
                    case 1: dram_out_b1[output_dram_offset] = output_value; break;
                    case 2: dram_out_b2[output_dram_offset] = output_value; break;
                    case 3: dram_out_b3[output_dram_offset] = output_value; break;
                    case 4: dram_out_b4[output_dram_offset] = output_value; break;
                    case 5: dram_out_b5[output_dram_offset] = output_value; break;
                    case 6: dram_out_b6[output_dram_offset] = output_value; break;
                    case 7: dram_out_b7[output_dram_offset] = output_value; break;
                    case 8: dram_out_b8[output_dram_offset] = output_value; break;
                    case 9: dram_out_b9[output_dram_offset] = output_value; break;
                    case 10: dram_out_b10[output_dram_offset] = output_value; break;
                    case 11: dram_out_b11[output_dram_offset] = output_value; break;
                    case 12: dram_out_b12[output_dram_offset] = output_value; break;
                    case 13: dram_out_b13[output_dram_offset] = output_value; break;
                    case 14: dram_out_b14[output_dram_offset] = output_value; break;
                    case 15: dram_out_b15[output_dram_offset] = output_value; break;
                    case 16: dram_out_b16[output_dram_offset] = output_value; break;
                    case 17: dram_out_b17[output_dram_offset] = output_value; break;
                    case 18: dram_out_b18[output_dram_offset] = output_value; break;
                    case 19: dram_out_b19[output_dram_offset] = output_value; break;
                    case 20: dram_out_b20[output_dram_offset] = output_value; break;
                    case 21: dram_out_b21[output_dram_offset] = output_value; break;
                    case 22: dram_out_b22[output_dram_offset] = output_value; break;
                    case 23: dram_out_b23[output_dram_offset] = output_value; break;
                    case 24: dram_out_b24[output_dram_offset] = output_value; break;
                    case 25: dram_out_b25[output_dram_offset] = output_value; break;
                    case 26: dram_out_b26[output_dram_offset] = output_value; break;
                    case 27: dram_out_b27[output_dram_offset] = output_value; break;
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
