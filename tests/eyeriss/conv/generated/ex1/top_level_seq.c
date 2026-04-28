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
    // seq (all-nounroll) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=4, P=4, Q=4, C=4, R=3, S=3;
    const int H=6, W=6;
    const int Ptiles=4, Qtiles=2;
    const int in_banks=2;

    // Accumulator: flat 1D at function scope → GCC SROA → 8 scalar regs
    DTYPE accumulator[8];

    // DRAM_0 = Q:2
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 2; ++dram_0) {
      // GlobalBuffer_0 = P:4
      #pragma GCC nounroll
      for (int globalbuffer_0 = 0; globalbuffer_0 < 4; ++globalbuffer_0) {
        // Zero accumulator (nounroll — non-spatial init)
        #pragma GCC nounroll
        for (int accumulator_dim_index = 0; accumulator_dim_index < 8; ++accumulator_dim_index) accumulator[accumulator_dim_index] = 0.0f;

        // WRegister → R:3 (sequential)
        #pragma GCC nounroll
        for (int wregister_0 = 0; wregister_0 < 3; ++wregister_0) {
          // SARows C:4 -- sequential (reduction)
          #pragma GCC nounroll
          for (int c = 0; c < 4; ++c) {
            int channel_bank = c & 1;
            int channel_block_index = c >> 1;
            int input_channel_base_address = channel_block_index * (H * W);
            int output_col_base = dram_0 * 2;

            // SARows S:3
            #pragma GCC nounroll
            for (int s = 0; s < 3; ++s) {
              #pragma GCC nounroll
              for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {  // Q:2
                #pragma GCC nounroll
                for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {  // M:4
                  int weight_dram_index = ((sacols_1) * ((C + in_banks - 1) / in_banks) + channel_block_index) * (R * S) + wregister_0 * S + s;
                  DTYPE weight_value = (channel_bank==0) ? dram_w_b0[weight_dram_index] : dram_w_b1[weight_dram_index];
                  int input_row_base_address = input_channel_base_address + (globalbuffer_0 + wregister_0) * W;
                  int input_column_offset = output_col_base + sacols_0 + s;
                  DTYPE input_value = (channel_bank==0) ? dram_in_b0[input_row_base_address + input_column_offset]
                                                        : dram_in_b1[input_row_base_address + input_column_offset];
                  accumulator[sacols_0*4 + sacols_1] += weight_value * input_value;
                }  // sacols_1 (M:4)
              }  // sacols_0 (Q:2)
            }  // s
          }  // c

        }  // wregister_0

        // OutRegister: write accumulator to banked output ports
        #pragma GCC nounroll 2
        for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
          #pragma GCC nounroll 4
          for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
            int output_bank = sacols_0*4 + sacols_1;
            int output_filter_tile = 0;
            int output_row_tile = globalbuffer_0;
            int output_col_tile = dram_0;
            int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
            DTYPE output_value = accumulator[sacols_0*4 + sacols_1];
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
      }  // globalbuffer_0
    }  // dram_0
}
