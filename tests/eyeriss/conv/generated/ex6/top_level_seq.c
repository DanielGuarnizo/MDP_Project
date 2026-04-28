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
    // seq (all-nounroll) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=4, P=6, Q=6, C=4, R=3, S=1;
    const int H=8, W=6;
    const int Ptiles=6, Qtiles=1;
    const int in_banks=2;

    // Accumulator: flat 1D at function scope → GCC SROA → 24 scalar regs
    DTYPE accumulator[24];

    // GlobalBuffer_0 = P:6
    #pragma GCC nounroll
    for (int globalbuffer_0 = 0; globalbuffer_0 < 6; ++globalbuffer_0) {
      // Zero accumulator (nounroll — non-spatial init)
      #pragma GCC nounroll
      for (int accumulator_dim_index = 0; accumulator_dim_index < 24; ++accumulator_dim_index) accumulator[accumulator_dim_index] = 0.0f;

      // WRegister → R:3 (sequential)
      #pragma GCC nounroll
      for (int wregister_0 = 0; wregister_0 < 3; ++wregister_0) {
        // SARows C:4 -- sequential (reduction)
        #pragma GCC nounroll
        for (int c = 0; c < 4; ++c) {
          int channel_bank = c & 1;
          int channel_block_index = c >> 1;
          int input_channel_base_address = channel_block_index * (H * W);
          int output_col_base = 0;

          // SARows S:1
          #pragma GCC nounroll
          for (int s = 0; s < 1; ++s) {
            #pragma GCC nounroll
            for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {  // M:2
              #pragma GCC nounroll
              for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {  // Q:6
                #pragma GCC nounroll
                for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {  // M:2
                  int weight_dram_index = ((sarows_1*2 + sacols_1) * ((C + in_banks - 1) / in_banks) + channel_block_index) * (R * S) + wregister_0 * S + s;
                  DTYPE weight_value = (channel_bank==0) ? dram_w_b0[weight_dram_index] : dram_w_b1[weight_dram_index];
                  int input_row_base_address = input_channel_base_address + (globalbuffer_0 + wregister_0) * W;
                  int input_column_offset = output_col_base + sacols_0 + s;
                  DTYPE input_value = (channel_bank==0) ? dram_in_b0[input_row_base_address + input_column_offset]
                                                        : dram_in_b1[input_row_base_address + input_column_offset];
                  accumulator[sarows_1*12 + sacols_0*2 + sacols_1] += weight_value * input_value;
                }  // sacols_1 (M:2)
              }  // sacols_0 (Q:6)
            }  // sarows_1 (M:2)
          }  // s
        }  // c

      }  // wregister_0

      // OutRegister: write accumulator to banked output ports
      #pragma GCC nounroll 2
      for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
        #pragma GCC nounroll 6
        for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {
          #pragma GCC nounroll 2
          for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
            int output_bank = sarows_1*12 + sacols_0*2 + sacols_1;
            int output_filter_tile = 0;
            int output_row_tile = globalbuffer_0;
            int output_col_tile = 0;
            int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
            DTYPE output_value = accumulator[sarows_1*12 + sacols_0*2 + sacols_1];
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
