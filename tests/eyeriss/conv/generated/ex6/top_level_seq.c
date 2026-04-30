#define DTYPE float

/* AXI pragmas: inputs and outputs share bundles (time-multiplexed) */
#pragma HLS interface port = dram_input_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_input_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_input_p2 mode = m_axi offset = direct bundle = gmem_2
#pragma HLS interface port = dram_input_p3 mode = m_axi offset = direct bundle = gmem_3
#pragma HLS interface port = dram_weight_p0 mode = m_axi offset = direct bundle = gmem_4
#pragma HLS interface port = dram_weight_p1 mode = m_axi offset = direct bundle = gmem_5
#pragma HLS interface port = dram_weight_p2 mode = m_axi offset = direct bundle = gmem_6
#pragma HLS interface port = dram_weight_p3 mode = m_axi offset = direct bundle = gmem_7
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

void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_input_p2, DTYPE *dram_input_p3, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_weight_p2, DTYPE *dram_weight_p3, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7, DTYPE *dram_output_p8, DTYPE *dram_output_p9, DTYPE *dram_output_p10, DTYPE *dram_output_p11, DTYPE *dram_output_p12, DTYPE *dram_output_p13, DTYPE *dram_output_p14, DTYPE *dram_output_p15, DTYPE *dram_output_p16, DTYPE *dram_output_p17, DTYPE *dram_output_p18, DTYPE *dram_output_p19, DTYPE *dram_output_p20, DTYPE *dram_output_p21, DTYPE *dram_output_p22, DTYPE *dram_output_p23)
{
    // seq (all-nounroll) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=4, P=6, Q=6, C=4, R=3, S=1;
    const int H=8, W=6;
    const int Ptiles=6, Qtiles=1;
    const int input_ports=4;

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
          int channel_port_index = c % input_ports;
          int channel_block_index = c / input_ports;
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
                  int weight_dram_index = ((sarows_1*2 + sacols_1) * ((C + input_ports - 1) / input_ports) + channel_block_index) * (R * S) + wregister_0 * S + s;
                  DTYPE weight_value;
                  switch(channel_port_index) {
                    case 0: weight_value = dram_weight_p0[weight_dram_index]; break;
                    case 1: weight_value = dram_weight_p1[weight_dram_index]; break;
                    case 2: weight_value = dram_weight_p2[weight_dram_index]; break;
                    case 3: weight_value = dram_weight_p3[weight_dram_index]; break;
                    default: weight_value = 0.0f; break;
                  }
                  int input_row_base_address = input_channel_base_address + (globalbuffer_0 + wregister_0) * W;
                  int input_column_offset = output_col_base + sacols_0 + s;
                  DTYPE input_value;
                  switch(channel_port_index) {
                    case 0: input_value = dram_input_p0[input_row_base_address + input_column_offset]; break;
                    case 1: input_value = dram_input_p1[input_row_base_address + input_column_offset]; break;
                    case 2: input_value = dram_input_p2[input_row_base_address + input_column_offset]; break;
                    case 3: input_value = dram_input_p3[input_row_base_address + input_column_offset]; break;
                    default: input_value = 0.0f; break;
                  }
                  accumulator[sarows_1*12 + sacols_0*2 + sacols_1] += weight_value * input_value;
                }  // sacols_1 (M:2)
              }  // sacols_0 (Q:6)
            }  // sarows_1 (M:2)
          }  // s
        }  // c

      }  // wregister_0

      // OutRegister: write accumulator to output DRAM ports
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
              default: break;
            }
          }
        }
      }
    }  // globalbuffer_0
}
