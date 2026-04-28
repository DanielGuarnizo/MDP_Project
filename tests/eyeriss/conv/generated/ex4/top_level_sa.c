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
    // SA (weight-preload) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=4, P=4, Q=4, C=4, R=1, S=1;
    const int H=4, W=4;
    const int Ptiles=4, Qtiles=1;
    const int in_banks=2;

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
            int channel_bank = global_channel_index & 1;
            int channel_block_index = global_channel_index >> 1;
            int weight_dram_index = ((outregister_0 * 2 + (sarows_1)) * ((C + in_banks - 1) / in_banks) + channel_block_index) * (R * S) + filter_row_offset * S + 0;
            weight_tile[sarows_0][sarows_1] = (channel_bank==0) ? dram_w_b0[weight_dram_index] : dram_w_b1[weight_dram_index];
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
              int channel_bank = global_channel_index & 1;
              int channel_block_index = global_channel_index >> 1;
              int input_channel_base_address = channel_block_index * (H * W);
              int input_row_base_address = input_channel_base_address + (dram_0 + filter_row_offset) * W;
              int input_column_offset = output_col_base + sacols_0 + 0;
              DTYPE weight_value = weight_tile[sarows_0][sarows_1];
              DTYPE input_value = (channel_bank==0) ? dram_in_b0[input_row_base_address + input_column_offset]
                                                    : dram_in_b1[input_row_base_address + input_column_offset];
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

        // OutRegister: write accumulator to banked output ports
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
      }  // outregister_0
    }  // dram_0
}
