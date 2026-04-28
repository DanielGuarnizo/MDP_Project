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

void top_level(DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7, DTYPE *dram_out_b8, DTYPE *dram_out_b9, DTYPE *dram_out_b10, DTYPE *dram_out_b11, DTYPE *dram_out_b12, DTYPE *dram_out_b13, DTYPE *dram_out_b14, DTYPE *dram_out_b15, DTYPE *dram_out_b16, DTYPE *dram_out_b17, DTYPE *dram_out_b18, DTYPE *dram_out_b19, DTYPE *dram_out_b20, DTYPE *dram_out_b21, DTYPE *dram_out_b22, DTYPE *dram_out_b23)
{
    // SA (weight-preload) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=4, P=6, Q=6, C=4, R=3, S=1;
    const int H=8, W=6;
    const int Ptiles=6, Qtiles=1;
    const int in_banks=2;

    // sarows_0 → SARows_0 = C:4
    // sarows_1 → SARows_1 = M:2
    // sacols_0 → SACols_0 = Q:6
    // sacols_1 → SACols_1 = M:2
    // 96 PE accumulators: accumulator[4][2][6][2]
    DTYPE accumulator[4][2][6][2];

    // GlobalBuffer_0 = P:6
    #pragma GCC nounroll
    for (int globalbuffer_0 = 0; globalbuffer_0 < 6; ++globalbuffer_0) {
      // Zero 96 PE accumulators (nounroll — non-spatial init)
      #pragma GCC nounroll
      for (int sarows_0 = 0; sarows_0 < 4; ++sarows_0) {
        #pragma GCC nounroll
        for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
          #pragma GCC nounroll
          for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {
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
        // ---- Phase 1: preload weights — 16 elems, no Q loop ----
        // weight_tile[4][2][2]: level-indexed, Q absent (weight is Q-independent)
        DTYPE weight_tile[4][2][2];
        #pragma GCC unroll 4
        for (int sarows_0 = 0; sarows_0 < 4; ++sarows_0) {
          #pragma GCC unroll 2
          for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
            #pragma GCC unroll 2
            for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
              int global_channel_index = (sarows_0);
              int channel_bank = global_channel_index & 1;
              int channel_block_index = global_channel_index >> 1;
              int weight_dram_index = ((sarows_1*2 + sacols_1) * ((C + in_banks - 1) / in_banks) + channel_block_index) * (R * S) + wregister_0 * S + 0;
              weight_tile[sarows_0][sarows_1][sacols_1] = (channel_bank==0) ? dram_w_b0[weight_dram_index] : dram_w_b1[weight_dram_index];
            }  // sacols_1 (preload)
          }  // sarows_1 (preload)
        }  // sarows_0 (preload)

        // ---- Phase 2a: multiply — 96 independent products ----
        // product[4][2][6][2]: GCC SROA → 96 scalar float regs
        DTYPE product[4][2][6][2];
        int output_col_base = 0;
        #pragma GCC unroll 4
        for (int sarows_0 = 0; sarows_0 < 4; ++sarows_0) {  // C:4
          #pragma GCC unroll 2
          for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {  // M:2
            #pragma GCC unroll 6
            for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {  // Q:6
              #pragma GCC unroll 2
              for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {  // M:2
                int global_channel_index = (sarows_0);
                int channel_bank = global_channel_index & 1;
                int channel_block_index = global_channel_index >> 1;
                int input_channel_base_address = channel_block_index * (H * W);
                int input_row_base_address = input_channel_base_address + (globalbuffer_0 + wregister_0) * W;
                int input_column_offset = output_col_base + sacols_0 + 0;
                DTYPE weight_value = weight_tile[sarows_0][sarows_1][sacols_1];
                DTYPE input_value = (channel_bank==0) ? dram_in_b0[input_row_base_address + input_column_offset]
                                                      : dram_in_b1[input_row_base_address + input_column_offset];
                product[sarows_0][sarows_1][sacols_0][sacols_1] = weight_value * input_value;
              }  // sacols_1 (M:2)
            }  // sacols_0 (Q:6)
          }  // sarows_1 (M:2)
        }  // sarows_0 (C:4)

        // ---- Phase 2b: accumulate — 96 independent, no RAW chain ----
        #pragma GCC unroll 4
        for (int sarows_0 = 0; sarows_0 < 4; ++sarows_0) {
          #pragma GCC unroll 2
          for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
            #pragma GCC unroll 6
            for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {
              #pragma GCC unroll 2
              for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
                accumulator[sarows_0][sarows_1][sacols_0][sacols_1] += product[sarows_0][sarows_1][sacols_0][sacols_1];
              }  // sacols_1
            }  // sacols_0
          }  // sarows_1
        }  // sarows_0

      }  // wregister_0

      // ---- reduction: 96 acc → 24 outputs (4 inputs each) ----
      DTYPE reduced_output[2][6][2];
      #pragma GCC unroll 2
      for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
        #pragma GCC unroll 6
        for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {
          #pragma GCC unroll 2
          for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
            DTYPE partial_sum_0_0 = accumulator[0][sarows_1][sacols_0][sacols_1] + accumulator[1][sarows_1][sacols_0][sacols_1];
            DTYPE partial_sum_0_1 = accumulator[2][sarows_1][sacols_0][sacols_1] + accumulator[3][sarows_1][sacols_0][sacols_1];
            DTYPE partial_sum_1_0 = partial_sum_0_0 + partial_sum_0_1;
            reduced_output[sarows_1][sacols_0][sacols_1] = partial_sum_1_0;
          }  // sacols_1 (reduction)
        }  // sacols_0 (reduction)
      }  // sarows_1 (reduction)

      // OutRegister: write accumulator to banked output ports
      #pragma GCC unroll 2
      for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
        #pragma GCC unroll 6
        for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {
          #pragma GCC unroll 2
          for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
            int output_bank = sarows_1*12 + sacols_0*2 + sacols_1;
            int output_filter_tile = 0;
            int output_row_tile = globalbuffer_0;
            int output_col_tile = 0;
            int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
            DTYPE output_value = reduced_output[sarows_1][sacols_0][sacols_1];
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
              default: break;
            }
          }
        }
      }
    }  // globalbuffer_0
}
