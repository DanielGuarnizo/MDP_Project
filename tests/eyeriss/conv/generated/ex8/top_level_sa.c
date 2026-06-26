#define DTYPE float

/* AXI pragmas: inputs and outputs share bundles (time-multiplexed) */
#pragma HLS interface port = dram_input_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_input_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_input_p2 mode = m_axi offset = direct bundle = gmem_2
#pragma HLS interface port = dram_input_p3 mode = m_axi offset = direct bundle = gmem_3
#pragma HLS interface port = dram_weight_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_weight_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_weight_p2 mode = m_axi offset = direct bundle = gmem_2
#pragma HLS interface port = dram_weight_p3 mode = m_axi offset = direct bundle = gmem_3
#pragma HLS interface port = dram_output_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_output_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_output_p2 mode = m_axi offset = direct bundle = gmem_2
#pragma HLS interface port = dram_output_p3 mode = m_axi offset = direct bundle = gmem_3
#pragma HLS interface port = dram_output_p4 mode = m_axi offset = direct bundle = gmem_4
#pragma HLS interface port = dram_output_p5 mode = m_axi offset = direct bundle = gmem_5
#pragma HLS interface port = dram_output_p6 mode = m_axi offset = direct bundle = gmem_6
#pragma HLS interface port = dram_output_p7 mode = m_axi offset = direct bundle = gmem_7

// GlobalBuffer scratchpads — filled once per top_level call from AXI ports
static DTYPE gb_weight[4][8][3][3];
static DTYPE gb_input[8][6][6];
void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_input_p2, DTYPE *dram_input_p3, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_weight_p2, DTYPE *dram_weight_p3, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7)
{
    // SA (weight-preload) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=4, P=4, Q=4, C=8, R=3, S=3;
    const int H=6, W=6;
    const int Ptiles=4, Qtiles=2;
    const int input_ports=4;

    // sarows_0 → SARows_0 = S:3
    // sarows_1 → SARows_1 = C:4
    // sacols_0 → SACols_0 = Q:2
    // sacols_1 → SACols_1 = M:4
    // 96 PE accumulators: accumulator[3][4][2][4]
    DTYPE accumulator[3][4][2][4];

    // ---- GlobalBuffer weight preload: wt_ideal = 4*8*3*3 AXI reads ----
    for (int _gm = 0; _gm < 4; ++_gm) {
      for (int _gc = 0; _gc < 8; ++_gc) {
        for (int _gr = 0; _gr < 3; ++_gr) {
          for (int _gs = 0; _gs < 3; ++_gs) {
            int weight_port_index = _gc % 4;
            int _cb = _gc / 4;
            int _wa = (_gm * ((8 + 4 - 1) / 4) + _cb) * (3 * 3) + _gr * 3 + _gs;
            switch(weight_port_index) {
              case 0: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p0[_wa]; break;
              case 1: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p1[_wa]; break;
              case 2: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p2[_wa]; break;
              case 3: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p3[_wa]; break;
              default: gb_weight[_gm][_gc][_gr][_gs] = 0.0f; break;
            }
          }
        }
      }
    }

    // ---- GlobalBuffer input preload: in_ideal = 8*6*6 AXI reads ----
    for (int _gc = 0; _gc < 8; ++_gc) {
      for (int _gr = 0; _gr < 6; ++_gr) {
        for (int _gw = 0; _gw < 6; ++_gw) {
          int input_port_index = _gc % 4;
          int _cb = _gc / 4;
          int _ia = _cb * (6 * 6) + _gr * 6 + _gw;
          switch(input_port_index) {
            case 0: gb_input[_gc][_gr][_gw] = dram_input_p0[_ia]; break;
            case 1: gb_input[_gc][_gr][_gw] = dram_input_p1[_ia]; break;
            case 2: gb_input[_gc][_gr][_gw] = dram_input_p2[_ia]; break;
            case 3: gb_input[_gc][_gr][_gw] = dram_input_p3[_ia]; break;
            default: gb_input[_gc][_gr][_gw] = 0.0f; break;
          }
        }
      }
    }

    // GlobalBuffer_0 = Q:2
    #pragma GCC nounroll
    for (int globalbuffer_0 = 0; globalbuffer_0 < 2; ++globalbuffer_0) {
      // GlobalBuffer_1 = P:4
      #pragma GCC nounroll
      for (int globalbuffer_1 = 0; globalbuffer_1 < 4; ++globalbuffer_1) {
        // Zero 96 PE accumulators (nounroll — non-spatial init)
        #pragma GCC nounroll
        for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
          #pragma GCC nounroll
          for (int sarows_1 = 0; sarows_1 < 4; ++sarows_1) {
            #pragma GCC nounroll
            for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
              #pragma GCC nounroll
              for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
                accumulator[sarows_0][sarows_1][sacols_0][sacols_1] = 0.0f;
              }
            }
          }
        }

        // WRegister → C:2 (sequential)
        #pragma GCC nounroll
        for (int wregister_0 = 0; wregister_0 < 2; ++wregister_0) {
          // WRegister → R:3 (sequential)
          #pragma GCC nounroll
          for (int wregister_1 = 0; wregister_1 < 3; ++wregister_1) {
            // ---- Phase 1: preload weights — 48 elems, no Q loop ----
            // weight_tile[3][4][4]: level-indexed, Q absent (weight is Q-independent)
            DTYPE weight_tile[3][4][4];
            #pragma GCC unroll 3
            for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
              #pragma GCC unroll 4
              for (int sarows_1 = 0; sarows_1 < 4; ++sarows_1) {
                #pragma GCC unroll 4
                for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
                  int global_channel_index = (wregister_0 * 4 + (sarows_1));
                  weight_tile[sarows_0][sarows_1][sacols_1] = gb_weight[(sacols_1)][global_channel_index][wregister_1][sarows_0];
                }  // sacols_1 (preload)
              }  // sarows_1 (preload)
            }  // sarows_0 (preload)

            // ---- Phase 2a: multiply — 96 independent products ----
            // product[3][4][2][4]: GCC SROA → 96 scalar float regs
            DTYPE product[3][4][2][4];
            int output_col_base = globalbuffer_0 * 2;
            #pragma GCC unroll 3
            for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {  // S:3
              #pragma GCC unroll 4
              for (int sarows_1 = 0; sarows_1 < 4; ++sarows_1) {  // C:4
                #pragma GCC unroll 2
                for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {  // Q:2
                  #pragma GCC unroll 4
                  for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {  // M:4
                    int global_channel_index = (wregister_0 * 4 + (sarows_1));
                    int input_col = output_col_base + sacols_0 + sarows_0;
                    DTYPE weight_value = weight_tile[sarows_0][sarows_1][sacols_1];
                    DTYPE input_value = gb_input[global_channel_index][(globalbuffer_1 + wregister_1)][input_col];
                    product[sarows_0][sarows_1][sacols_0][sacols_1] = weight_value * input_value;
                  }  // sacols_1 (M:4)
                }  // sacols_0 (Q:2)
              }  // sarows_1 (C:4)
            }  // sarows_0 (S:3)

            // ---- Phase 2b: accumulate — 96 independent, no RAW chain ----
            #pragma GCC unroll 3
            for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
              #pragma GCC unroll 4
              for (int sarows_1 = 0; sarows_1 < 4; ++sarows_1) {
                #pragma GCC unroll 2
                for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
                  #pragma GCC unroll 4
                  for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
                    accumulator[sarows_0][sarows_1][sacols_0][sacols_1] += product[sarows_0][sarows_1][sacols_0][sacols_1];
                  }  // sacols_1
                }  // sacols_0
              }  // sarows_1
            }  // sarows_0

          }  // wregister_1
        }  // wregister_0

        // ---- reduction: 96 acc → 8 outputs (12 inputs each) ----
        DTYPE reduced_output[2][4];
        #pragma GCC unroll 2
        for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
          #pragma GCC unroll 4
          for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
            DTYPE partial_sum_0_0 = accumulator[0][0][sacols_0][sacols_1] + accumulator[0][1][sacols_0][sacols_1];
            DTYPE partial_sum_0_1 = accumulator[0][2][sacols_0][sacols_1] + accumulator[0][3][sacols_0][sacols_1];
            DTYPE partial_sum_0_2 = accumulator[1][0][sacols_0][sacols_1] + accumulator[1][1][sacols_0][sacols_1];
            DTYPE partial_sum_0_3 = accumulator[1][2][sacols_0][sacols_1] + accumulator[1][3][sacols_0][sacols_1];
            DTYPE partial_sum_0_4 = accumulator[2][0][sacols_0][sacols_1] + accumulator[2][1][sacols_0][sacols_1];
            DTYPE partial_sum_0_5 = accumulator[2][2][sacols_0][sacols_1] + accumulator[2][3][sacols_0][sacols_1];
            DTYPE partial_sum_1_0 = partial_sum_0_0 + partial_sum_0_1;
            DTYPE partial_sum_1_1 = partial_sum_0_2 + partial_sum_0_3;
            DTYPE partial_sum_1_2 = partial_sum_0_4 + partial_sum_0_5;
            DTYPE partial_sum_2_0 = partial_sum_1_0 + partial_sum_1_1;
            DTYPE partial_sum_3_0 = partial_sum_2_0 + partial_sum_1_2;
            reduced_output[sacols_0][sacols_1] = partial_sum_3_0;
          }  // sacols_1 (reduction)
        }  // sacols_0 (reduction)

        // OutRegister: write 8 outputs to 8 port(s), folding=1
        int output_filter_tile = 0;
        int output_row_tile = globalbuffer_1;
        int output_col_tile = globalbuffer_0;
        int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
        dram_output_p0[output_dram_offset] = reduced_output[0][0];
        dram_output_p1[output_dram_offset] = reduced_output[0][1];
        dram_output_p2[output_dram_offset] = reduced_output[0][2];
        dram_output_p3[output_dram_offset] = reduced_output[0][3];
        dram_output_p4[output_dram_offset] = reduced_output[1][0];
        dram_output_p5[output_dram_offset] = reduced_output[1][1];
        dram_output_p6[output_dram_offset] = reduced_output[1][2];
        dram_output_p7[output_dram_offset] = reduced_output[1][3];
      }  // globalbuffer_1
    }  // globalbuffer_0
}
