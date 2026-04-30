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

void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7, DTYPE *dram_output_p8, DTYPE *dram_output_p9, DTYPE *dram_output_p10, DTYPE *dram_output_p11, DTYPE *dram_output_p12, DTYPE *dram_output_p13, DTYPE *dram_output_p14, DTYPE *dram_output_p15)
{
    // seq (all-nounroll) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=64, P=56, Q=56, C=64, R=3, S=3;
    const int H=58, W=58;
    const int Ptiles=56, Qtiles=8;
    const int input_ports=2;

    // Accumulator: flat 1D at function scope → GCC SROA → 28 scalar regs
    DTYPE accumulator[28];

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
            // Zero accumulator (nounroll — non-spatial init)
            #pragma GCC nounroll
            for (int accumulator_dim_index = 0; accumulator_dim_index < 28; ++accumulator_dim_index) accumulator[accumulator_dim_index] = 0.0f;

            // DRAM_1 = C:4
            #pragma GCC nounroll
            for (int dram_1 = 0; dram_1 < 4; ++dram_1) {
              // WRegister → C:8 (sequential)
              #pragma GCC nounroll
              for (int wregister_0 = 0; wregister_0 < 8; ++wregister_0) {
                // WRegister → R:3 (sequential)
                #pragma GCC nounroll
                for (int wregister_1 = 0; wregister_1 < 3; ++wregister_1) {
                  // SARows C:2 -- sequential (reduction)
                  #pragma GCC nounroll
                  for (int c = 0; c < 2; ++c) {
                    int global_channel_index = dram_1 * 16 + wregister_0 * 2 + c;
                    int channel_port_index = global_channel_index % input_ports;
                    int channel_block_index = global_channel_index / input_ports;
                    int input_channel_base_address = channel_block_index * (H * W);
                    int output_col_base = (dram_0 * 4 + globalbuffer_0) * 7;

                    // SARows S:3
                    #pragma GCC nounroll
                    for (int s = 0; s < 3; ++s) {
                      #pragma GCC nounroll
                      for (int sarows_2 = 0; sarows_2 < 2; ++sarows_2) {  // M:2
                        #pragma GCC nounroll
                        for (int sacols_0 = 0; sacols_0 < 7; ++sacols_0) {  // Q:7
                          #pragma GCC nounroll
                          for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {  // M:2
                            int weight_dram_index = (((outregister_0 * 4 + (sarows_2*2 + sacols_1))) * ((C + input_ports - 1) / input_ports) + channel_block_index) * (R * S) + wregister_1 * S + s;
                            DTYPE weight_value;
                            switch(channel_port_index) {
                              case 0: weight_value = dram_weight_p0[weight_dram_index]; break;
                              case 1: weight_value = dram_weight_p1[weight_dram_index]; break;
                              default: weight_value = 0.0f; break;
                            }
                            int input_row_base_address = input_channel_base_address + (globalbuffer_1 + wregister_1) * W;
                            int input_column_offset = output_col_base + sacols_0 + s;
                            DTYPE input_value;
                            switch(channel_port_index) {
                              case 0: input_value = dram_input_p0[input_row_base_address + input_column_offset]; break;
                              case 1: input_value = dram_input_p1[input_row_base_address + input_column_offset]; break;
                              default: input_value = 0.0f; break;
                            }
                            accumulator[sarows_2*14 + sacols_0*2 + sacols_1] += weight_value * input_value;
                          }  // sacols_1 (M:2)
                        }  // sacols_0 (Q:7)
                      }  // sarows_2 (M:2)
                    }  // s
                  }  // c

                }  // wregister_1
              }  // wregister_0

            }  // dram_1

            // OutRegister: write accumulator to output DRAM ports
            #pragma GCC nounroll 2
            for (int sarows_2 = 0; sarows_2 < 2; ++sarows_2) {
              #pragma GCC nounroll 7
              for (int sacols_0 = 0; sacols_0 < 7; ++sacols_0) {
                #pragma GCC nounroll 2
                for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
                  int output_bank = sarows_2*14 + sacols_0*2 + sacols_1;
                  int output_filter_tile = outregister_0;
                  int output_row_tile = globalbuffer_1;
                  int output_col_tile = (dram_0 * 4 + globalbuffer_0);
                  int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
                  DTYPE output_value = accumulator[sarows_2*14 + sacols_0*2 + sacols_1];
                  int output_port_index = output_bank % 16;
                  int safe_dram_offset = output_dram_offset * 2 + output_bank / 16;
                  switch(output_port_index) {
                    case 0: dram_output_p0[safe_dram_offset] = output_value; break;
                    case 1: dram_output_p1[safe_dram_offset] = output_value; break;
                    case 2: dram_output_p2[safe_dram_offset] = output_value; break;
                    case 3: dram_output_p3[safe_dram_offset] = output_value; break;
                    case 4: dram_output_p4[safe_dram_offset] = output_value; break;
                    case 5: dram_output_p5[safe_dram_offset] = output_value; break;
                    case 6: dram_output_p6[safe_dram_offset] = output_value; break;
                    case 7: dram_output_p7[safe_dram_offset] = output_value; break;
                    case 8: dram_output_p8[safe_dram_offset] = output_value; break;
                    case 9: dram_output_p9[safe_dram_offset] = output_value; break;
                    case 10: dram_output_p10[safe_dram_offset] = output_value; break;
                    case 11: dram_output_p11[safe_dram_offset] = output_value; break;
                    case 12: dram_output_p12[safe_dram_offset] = output_value; break;
                    case 13: dram_output_p13[safe_dram_offset] = output_value; break;
                    case 14: dram_output_p14[safe_dram_offset] = output_value; break;
                    case 15: dram_output_p15[safe_dram_offset] = output_value; break;
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
