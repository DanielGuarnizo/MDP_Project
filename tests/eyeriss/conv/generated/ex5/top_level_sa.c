#define DTYPE float

/* AXI pragmas: inputs and outputs share bundles (time-multiplexed) */
#pragma HLS interface port = dram_input_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_input_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_weight_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_weight_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_output_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_output_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_output_p2 mode = m_axi offset = direct bundle = gmem_2
#pragma HLS interface port = dram_output_p3 mode = m_axi offset = direct bundle = gmem_3
#pragma HLS interface port = dram_output_p4 mode = m_axi offset = direct bundle = gmem_4
#pragma HLS interface port = dram_output_p5 mode = m_axi offset = direct bundle = gmem_5
#pragma HLS interface port = dram_output_p6 mode = m_axi offset = direct bundle = gmem_6
#pragma HLS interface port = dram_output_p7 mode = m_axi offset = direct bundle = gmem_7

// GlobalBuffer scratchpads — filled once per top_level call from AXI ports
static DTYPE gb_weight[8][8][5][5];
static DTYPE gb_input[8][12][12];
void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7)
{
    // SA (weight-preload) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=8, P=8, Q=8, C=8, R=5, S=5;
    const int H=12, W=12;
    const int Ptiles=8, Qtiles=4;
    const int input_ports=2;

    // sarows_0 → SARows_0 = S:5
    // sarows_1 → SARows_1 = C:2
    // sacols_0 → SACols_0 = Q:2
    // sacols_1 → SACols_1 = M:4
    // 80 PE accumulators: accumulator[5][2][2][4]
    DTYPE accumulator[5][2][2][4];

    // ---- GlobalBuffer weight preload: wt_ideal = 8*8*5*5 AXI reads ----
    for (int _gm = 0; _gm < 8; ++_gm) {
      for (int _gc = 0; _gc < 8; ++_gc) {
        for (int _gr = 0; _gr < 5; ++_gr) {
          for (int _gs = 0; _gs < 5; ++_gs) {
            int weight_port_index = _gc % 2;
            int _cb = _gc / 2;
            int _wa = (_gm * ((8 + 2 - 1) / 2) + _cb) * (5 * 5) + _gr * 5 + _gs;
            switch(weight_port_index) {
              case 0: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p0[_wa]; break;
              case 1: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p1[_wa]; break;
              default: gb_weight[_gm][_gc][_gr][_gs] = 0.0f; break;
            }
          }
        }
      }
    }

    // ---- GlobalBuffer input preload: in_ideal = 8*12*12 AXI reads ----
    for (int _gc = 0; _gc < 8; ++_gc) {
      for (int _gr = 0; _gr < 12; ++_gr) {
        for (int _gw = 0; _gw < 12; ++_gw) {
          int input_port_index = _gc % 2;
          int _cb = _gc / 2;
          int _ia = _cb * (12 * 12) + _gr * 12 + _gw;
          switch(input_port_index) {
            case 0: gb_input[_gc][_gr][_gw] = dram_input_p0[_ia]; break;
            case 1: gb_input[_gc][_gr][_gw] = dram_input_p1[_ia]; break;
            default: gb_input[_gc][_gr][_gw] = 0.0f; break;
          }
        }
      }
    }

    // DRAM_0 = Q:4
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 4; ++dram_0) {
      // GlobalBuffer_0 = P:8
      #pragma GCC nounroll
      for (int globalbuffer_0 = 0; globalbuffer_0 < 8; ++globalbuffer_0) {
        // OutRegister_0 = M:2
        #pragma GCC nounroll
        for (int outregister_0 = 0; outregister_0 < 2; ++outregister_0) {
          // Zero 80 PE accumulators (nounroll — non-spatial init)
          #pragma GCC nounroll
          for (int sarows_0 = 0; sarows_0 < 5; ++sarows_0) {
            #pragma GCC nounroll
            for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
              #pragma GCC nounroll
              for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
                #pragma GCC nounroll
                for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
                  accumulator[sarows_0][sarows_1][sacols_0][sacols_1] = 0.0f;
                }
              }
            }
          }

          // WRegister → C:4 (sequential)
          #pragma GCC nounroll
          for (int wregister_0 = 0; wregister_0 < 4; ++wregister_0) {
            // WRegister → R:5 (sequential)
            #pragma GCC nounroll
            for (int wregister_1 = 0; wregister_1 < 5; ++wregister_1) {
              // ---- Phase 1: preload weights — 40 elems, no Q loop ----
              // weight_tile[5][2][4]: level-indexed, Q absent (weight is Q-independent)
              DTYPE weight_tile[5][2][4];
              #pragma GCC unroll 5
              for (int sarows_0 = 0; sarows_0 < 5; ++sarows_0) {
                #pragma GCC unroll 2
                for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
                  #pragma GCC unroll 4
                  for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
                    int global_channel_index = (wregister_0 * 2 + (sarows_1));
                    weight_tile[sarows_0][sarows_1][sacols_1] = gb_weight[(outregister_0 * 4 + (sacols_1))][global_channel_index][wregister_1][sarows_0];
                  }  // sacols_1 (preload)
                }  // sarows_1 (preload)
              }  // sarows_0 (preload)

              // ---- Phase 2a: multiply — 80 independent products ----
              // product[5][2][2][4]: GCC SROA → 80 scalar float regs
              DTYPE product[5][2][2][4];
              int output_col_base = dram_0 * 2;
              #pragma GCC unroll 5
              for (int sarows_0 = 0; sarows_0 < 5; ++sarows_0) {  // S:5
                #pragma GCC unroll 2
                for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {  // C:2
                  #pragma GCC unroll 2
                  for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {  // Q:2
                    #pragma GCC unroll 4
                    for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {  // M:4
                      int global_channel_index = (wregister_0 * 2 + (sarows_1));
                      int input_col = output_col_base + sacols_0 + sarows_0;
                      DTYPE weight_value = weight_tile[sarows_0][sarows_1][sacols_1];
                      DTYPE input_value = gb_input[global_channel_index][(globalbuffer_0 + wregister_1)][input_col];
                      product[sarows_0][sarows_1][sacols_0][sacols_1] = weight_value * input_value;
                    }  // sacols_1 (M:4)
                  }  // sacols_0 (Q:2)
                }  // sarows_1 (C:2)
              }  // sarows_0 (S:5)

              // ---- Phase 2b: accumulate — 80 independent, no RAW chain ----
              #pragma GCC unroll 5
              for (int sarows_0 = 0; sarows_0 < 5; ++sarows_0) {
                #pragma GCC unroll 2
                for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
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

          // ---- reduction: 80 acc → 8 outputs (10 inputs each) ----
          DTYPE reduced_output[2][4];
          #pragma GCC unroll 2
          for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
            #pragma GCC unroll 4
            for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
              DTYPE partial_sum_0_0 = accumulator[0][0][sacols_0][sacols_1] + accumulator[0][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_1 = accumulator[1][0][sacols_0][sacols_1] + accumulator[1][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_2 = accumulator[2][0][sacols_0][sacols_1] + accumulator[2][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_3 = accumulator[3][0][sacols_0][sacols_1] + accumulator[3][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_4 = accumulator[4][0][sacols_0][sacols_1] + accumulator[4][1][sacols_0][sacols_1];
              DTYPE partial_sum_1_0 = partial_sum_0_0 + partial_sum_0_1;
              DTYPE partial_sum_1_1 = partial_sum_0_2 + partial_sum_0_3;
              DTYPE partial_sum_2_0 = partial_sum_1_0 + partial_sum_1_1;
              DTYPE partial_sum_3_0 = partial_sum_2_0 + partial_sum_0_4;
              reduced_output[sacols_0][sacols_1] = partial_sum_3_0;
            }  // sacols_1 (reduction)
          }  // sacols_0 (reduction)

          // OutRegister: write 8 outputs to 8 port(s), folding=1
          int output_filter_tile = outregister_0;
          int output_row_tile = globalbuffer_0;
          int output_col_tile = dram_0;
          int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
          dram_output_p0[output_dram_offset] = reduced_output[0][0];
          dram_output_p1[output_dram_offset] = reduced_output[0][1];
          dram_output_p2[output_dram_offset] = reduced_output[0][2];
          dram_output_p3[output_dram_offset] = reduced_output[0][3];
          dram_output_p4[output_dram_offset] = reduced_output[1][0];
          dram_output_p5[output_dram_offset] = reduced_output[1][1];
          dram_output_p6[output_dram_offset] = reduced_output[1][2];
          dram_output_p7[output_dram_offset] = reduced_output[1][3];
        }  // outregister_0
      }  // globalbuffer_0
    }  // dram_0
}
