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

void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_input_p2, DTYPE *dram_input_p3, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_weight_p2, DTYPE *dram_weight_p3, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7)
{
    // SA (weight-preload) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=4, P=4, Q=4, C=4, R=1, S=1;
    const int H=4, W=4;
    const int Ptiles=4, Qtiles=1;
    const int input_ports=4;

    // sarows_0 → SARows_0 = C:4
    // sarows_1 → SARows_1 = M:2
    // sacols_0 → SACols_0 = Q:4
    // 32 PE accumulators: accumulator[4][2][4]
    DTYPE accumulator[4][2][4];

    // DRAM_0 = P:4
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 4; ++dram_0) {
      // OutRegister_0 = M:2
      #pragma GCC nounroll
      for (int outregister_0 = 0; outregister_0 < 2; ++outregister_0) {
        // Zero 32 PE accumulators (nounroll — non-spatial init)
        #pragma GCC nounroll
        for (int sarows_0 = 0; sarows_0 < 4; ++sarows_0) {
          #pragma GCC nounroll
          for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
            #pragma GCC nounroll
            for (int sacols_0 = 0; sacols_0 < 4; ++sacols_0) {
              accumulator[sarows_0][sarows_1][sacols_0] = 0.0f;
            }
          }
        }

        int filter_row_offset = 0;  // R=1 or no inner sequential R loop
        // ---- Phase 1: preload weights — 8 elems, no Q loop ----
        // weight_tile[4][2]: level-indexed, Q absent (weight is Q-independent)
        DTYPE weight_tile[4][2];
        #pragma GCC unroll 4
        for (int sarows_0 = 0; sarows_0 < 4; ++sarows_0) {
          #pragma GCC unroll 2
          for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
            int global_channel_index = (sarows_0);
            int weight_port_index = global_channel_index % input_ports;
            int channel_block_index = global_channel_index / input_ports;
            int weight_dram_index = ((outregister_0 * 2 + (sarows_1)) * ((C + input_ports - 1) / input_ports) + channel_block_index) * (R * S) + filter_row_offset * S + 0;
            switch(weight_port_index) {
              case 0: weight_tile[sarows_0][sarows_1] = dram_weight_p0[weight_dram_index]; break;
              case 1: weight_tile[sarows_0][sarows_1] = dram_weight_p1[weight_dram_index]; break;
              case 2: weight_tile[sarows_0][sarows_1] = dram_weight_p2[weight_dram_index]; break;
              case 3: weight_tile[sarows_0][sarows_1] = dram_weight_p3[weight_dram_index]; break;
              default: weight_tile[sarows_0][sarows_1] = 0.0f; break;
            }
          }  // sarows_1 (preload)
        }  // sarows_0 (preload)

        // ---- Phase 2a: multiply — 32 independent products ----
        // product[4][2][4]: GCC SROA → 32 scalar float regs
        DTYPE product[4][2][4];
        int output_col_base = 0;
        #pragma GCC unroll 4
        for (int sarows_0 = 0; sarows_0 < 4; ++sarows_0) {  // C:4
          #pragma GCC unroll 2
          for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {  // M:2
            #pragma GCC unroll 4
            for (int sacols_0 = 0; sacols_0 < 4; ++sacols_0) {  // Q:4
              int global_channel_index = (sarows_0);
              int input_port_index = global_channel_index % input_ports;
              int channel_block_index = global_channel_index / input_ports;
              int input_channel_base_address = channel_block_index * (H * W);
              int input_row_base_address = input_channel_base_address + (dram_0 + filter_row_offset) * W;
              int input_column_offset = output_col_base + sacols_0 + 0;
              DTYPE weight_value = weight_tile[sarows_0][sarows_1];
              DTYPE input_value;
              switch(input_port_index) {
                case 0: input_value = dram_input_p0[input_row_base_address + input_column_offset]; break;
                case 1: input_value = dram_input_p1[input_row_base_address + input_column_offset]; break;
                case 2: input_value = dram_input_p2[input_row_base_address + input_column_offset]; break;
                case 3: input_value = dram_input_p3[input_row_base_address + input_column_offset]; break;
                default: input_value = 0.0f; break;
              }
              product[sarows_0][sarows_1][sacols_0] = weight_value * input_value;
            }  // sacols_0 (Q:4)
          }  // sarows_1 (M:2)
        }  // sarows_0 (C:4)

        // ---- Phase 2b: accumulate — 32 independent, no RAW chain ----
        #pragma GCC unroll 4
        for (int sarows_0 = 0; sarows_0 < 4; ++sarows_0) {
          #pragma GCC unroll 2
          for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
            #pragma GCC unroll 4
            for (int sacols_0 = 0; sacols_0 < 4; ++sacols_0) {
              accumulator[sarows_0][sarows_1][sacols_0] += product[sarows_0][sarows_1][sacols_0];
            }  // sacols_0
          }  // sarows_1
        }  // sarows_0


        // ---- reduction: 32 acc → 8 outputs (4 inputs each) ----
        DTYPE reduced_output[2][4];
        #pragma GCC unroll 2
        for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
          #pragma GCC unroll 4
          for (int sacols_0 = 0; sacols_0 < 4; ++sacols_0) {
            DTYPE partial_sum_0_0 = accumulator[0][sarows_1][sacols_0] + accumulator[1][sarows_1][sacols_0];
            DTYPE partial_sum_0_1 = accumulator[2][sarows_1][sacols_0] + accumulator[3][sarows_1][sacols_0];
            DTYPE partial_sum_1_0 = partial_sum_0_0 + partial_sum_0_1;
            reduced_output[sarows_1][sacols_0] = partial_sum_1_0;
          }  // sacols_0 (reduction)
        }  // sarows_1 (reduction)

        // OutRegister: write accumulator to output DRAM ports
        #pragma GCC unroll 2
        for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
          #pragma GCC unroll 4
          for (int sacols_0 = 0; sacols_0 < 4; ++sacols_0) {
            int output_bank = sarows_1*4 + sacols_0;
            int output_filter_tile = outregister_0;
            int output_row_tile = dram_0;
            int output_col_tile = 0;
            int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
            DTYPE output_value = reduced_output[sarows_1][sacols_0];
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
    }  // dram_0
}
