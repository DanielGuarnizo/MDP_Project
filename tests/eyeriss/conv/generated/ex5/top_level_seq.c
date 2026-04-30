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
    // seq (all-nounroll) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=8, P=8, Q=8, C=8, R=5, S=5;
    const int H=12, W=12;
    const int Ptiles=8, Qtiles=4;
    const int input_ports=2;

    // Accumulator: flat 1D at function scope → GCC SROA → 8 scalar regs
    DTYPE accumulator[8];

    // DRAM_0 = Q:4
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 4; ++dram_0) {
      // GlobalBuffer_0 = P:8
      #pragma GCC nounroll
      for (int globalbuffer_0 = 0; globalbuffer_0 < 8; ++globalbuffer_0) {
        // OutRegister_0 = M:2
        #pragma GCC nounroll
        for (int outregister_0 = 0; outregister_0 < 2; ++outregister_0) {
          // Zero accumulator (nounroll — non-spatial init)
          #pragma GCC nounroll
          for (int accumulator_dim_index = 0; accumulator_dim_index < 8; ++accumulator_dim_index) accumulator[accumulator_dim_index] = 0.0f;

          // WRegister → C:4 (sequential)
          #pragma GCC nounroll
          for (int wregister_0 = 0; wregister_0 < 4; ++wregister_0) {
            // WRegister → R:5 (sequential)
            #pragma GCC nounroll
            for (int wregister_1 = 0; wregister_1 < 5; ++wregister_1) {
              // SARows C:2 -- sequential (reduction)
              #pragma GCC nounroll
              for (int c = 0; c < 2; ++c) {
                int global_channel_index = wregister_0 * 2 + c;
                int channel_port_index = global_channel_index % input_ports;
                int channel_block_index = global_channel_index / input_ports;
                int input_channel_base_address = channel_block_index * (H * W);
                int output_col_base = dram_0 * 2;

                // SARows S:5
                #pragma GCC nounroll
                for (int s = 0; s < 5; ++s) {
                  #pragma GCC nounroll
                  for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {  // Q:2
                    #pragma GCC nounroll
                    for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {  // M:4
                      int weight_dram_index = (((outregister_0 * 4 + (sacols_1))) * ((C + input_ports - 1) / input_ports) + channel_block_index) * (R * S) + wregister_1 * S + s;
                      DTYPE weight_value;
                      switch(channel_port_index) {
                        case 0: weight_value = dram_weight_p0[weight_dram_index]; break;
                        case 1: weight_value = dram_weight_p1[weight_dram_index]; break;
                        default: weight_value = 0.0f; break;
                      }
                      int input_row_base_address = input_channel_base_address + (globalbuffer_0 + wregister_1) * W;
                      int input_column_offset = output_col_base + sacols_0 + s;
                      DTYPE input_value;
                      switch(channel_port_index) {
                        case 0: input_value = dram_input_p0[input_row_base_address + input_column_offset]; break;
                        case 1: input_value = dram_input_p1[input_row_base_address + input_column_offset]; break;
                        default: input_value = 0.0f; break;
                      }
                      accumulator[sacols_0*4 + sacols_1] += weight_value * input_value;
                    }  // sacols_1 (M:4)
                  }  // sacols_0 (Q:2)
                }  // s
              }  // c

            }  // wregister_1
          }  // wregister_0

          // OutRegister: write accumulator to output DRAM ports
          #pragma GCC nounroll 2
          for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
            #pragma GCC nounroll 4
            for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
              int output_bank = sacols_0*4 + sacols_1;
              int output_filter_tile = outregister_0;
              int output_row_tile = globalbuffer_0;
              int output_col_tile = dram_0;
              int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
              DTYPE output_value = accumulator[sacols_0*4 + sacols_1];
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
