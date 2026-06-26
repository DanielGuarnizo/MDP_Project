#define DTYPE float

/* AXI pragmas: inputs and outputs share bundles (time-multiplexed) */
#pragma HLS interface port = dram_input_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_input_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_input_p2 mode = m_axi offset = direct bundle = gmem_2
#pragma HLS interface port = dram_input_p3 mode = m_axi offset = direct bundle = gmem_3
#pragma HLS interface port = dram_input_p4 mode = m_axi offset = direct bundle = gmem_4
#pragma HLS interface port = dram_weight_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_weight_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_weight_p2 mode = m_axi offset = direct bundle = gmem_2
#pragma HLS interface port = dram_weight_p3 mode = m_axi offset = direct bundle = gmem_3
#pragma HLS interface port = dram_weight_p4 mode = m_axi offset = direct bundle = gmem_4
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

// GlobalBuffer scratchpads — filled once per top_level call from AXI ports
static DTYPE gb_weight[100][100][16][16];
static DTYPE gb_input[100][115][115];
void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_input_p2, DTYPE *dram_input_p3, DTYPE *dram_input_p4, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_weight_p2, DTYPE *dram_weight_p3, DTYPE *dram_weight_p4, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7, DTYPE *dram_output_p8, DTYPE *dram_output_p9)
{
    // SA (weight-preload) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=100, P=100, Q=100, C=100, R=16, S=16;
    const int H=115, W=115;
    const int Ptiles=100, Qtiles=50;
    const int input_ports=5;

    // sarows_0 → SARows_0 = S:2
    // sarows_1 → SARows_1 = C:5
    // sacols_0 → SACols_0 = Q:2
    // sacols_1 → SACols_1 = M:5
    // 100 PE accumulators: accumulator[2][5][2][5]
    DTYPE accumulator[2][5][2][5];

    // ---- GlobalBuffer weight preload: wt_ideal = 100*100*16*16 AXI reads ----
    for (int _gm = 0; _gm < 100; ++_gm) {
      for (int _gc = 0; _gc < 100; ++_gc) {
        for (int _gr = 0; _gr < 16; ++_gr) {
          for (int _gs = 0; _gs < 16; ++_gs) {
            int weight_port_index = _gc % 5;
            int _cb = _gc / 5;
            int _wa = (_gm * ((100 + 5 - 1) / 5) + _cb) * (16 * 16) + _gr * 16 + _gs;
            switch(weight_port_index) {
              case 0: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p0[_wa]; break;
              case 1: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p1[_wa]; break;
              case 2: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p2[_wa]; break;
              case 3: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p3[_wa]; break;
              case 4: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p4[_wa]; break;
              default: gb_weight[_gm][_gc][_gr][_gs] = 0.0f; break;
            }
          }
        }
      }
    }

    // ---- GlobalBuffer input preload: in_ideal = 100*115*115 AXI reads ----
    for (int _gc = 0; _gc < 100; ++_gc) {
      for (int _gr = 0; _gr < 115; ++_gr) {
        for (int _gw = 0; _gw < 115; ++_gw) {
          int input_port_index = _gc % 5;
          int _cb = _gc / 5;
          int _ia = _cb * (115 * 115) + _gr * 115 + _gw;
          switch(input_port_index) {
            case 0: gb_input[_gc][_gr][_gw] = dram_input_p0[_ia]; break;
            case 1: gb_input[_gc][_gr][_gw] = dram_input_p1[_ia]; break;
            case 2: gb_input[_gc][_gr][_gw] = dram_input_p2[_ia]; break;
            case 3: gb_input[_gc][_gr][_gw] = dram_input_p3[_ia]; break;
            case 4: gb_input[_gc][_gr][_gw] = dram_input_p4[_ia]; break;
            default: gb_input[_gc][_gr][_gw] = 0.0f; break;
          }
        }
      }
    }

    // DRAM_0 = Q:5
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 5; ++dram_0) {
      // DRAM_1 = M:2
      #pragma GCC nounroll
      for (int dram_1 = 0; dram_1 < 2; ++dram_1) {
        // GlobalBuffer_1 = Q:10
        #pragma GCC nounroll
        for (int globalbuffer_1 = 0; globalbuffer_1 < 10; ++globalbuffer_1) {
          // GlobalBuffer_2 = P:100
          #pragma GCC nounroll
          for (int globalbuffer_2 = 0; globalbuffer_2 < 100; ++globalbuffer_2) {
            // OutRegister_0 = M:10
            #pragma GCC nounroll
            for (int outregister_0 = 0; outregister_0 < 10; ++outregister_0) {
              // Zero 100 PE accumulators (nounroll — non-spatial init)
              #pragma GCC nounroll
              for (int sarows_0 = 0; sarows_0 < 2; ++sarows_0) {
                #pragma GCC nounroll
                for (int sarows_1 = 0; sarows_1 < 5; ++sarows_1) {
                  #pragma GCC nounroll
                  for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
                    #pragma GCC nounroll
                    for (int sacols_1 = 0; sacols_1 < 5; ++sacols_1) {
                      accumulator[sarows_0][sarows_1][sacols_0][sacols_1] = 0.0f;
                    }
                  }
                }
              }

              // DRAM_2 = C:20
              #pragma GCC nounroll
              for (int dram_2 = 0; dram_2 < 20; ++dram_2) {
                // GlobalBuffer_0 = S:8
                #pragma GCC nounroll
                for (int globalbuffer_0 = 0; globalbuffer_0 < 8; ++globalbuffer_0) {
                  // WRegister → R:16 (sequential)
                  #pragma GCC nounroll
                  for (int wregister_0 = 0; wregister_0 < 16; ++wregister_0) {
                    // ---- Phase 1: preload weights — 50 elems, no Q loop ----
                    // weight_tile[2][5][5]: level-indexed, Q absent (weight is Q-independent)
                    DTYPE weight_tile[2][5][5];
                    #pragma GCC unroll 2
                    for (int sarows_0 = 0; sarows_0 < 2; ++sarows_0) {
                      #pragma GCC unroll 5
                      for (int sarows_1 = 0; sarows_1 < 5; ++sarows_1) {
                        #pragma GCC unroll 5
                        for (int sacols_1 = 0; sacols_1 < 5; ++sacols_1) {
                          int global_channel_index = (dram_2 * 5 + sarows_1);
                          weight_tile[sarows_0][sarows_1][sacols_1] = gb_weight[((dram_1 * 10 + outregister_0) * 5 + (sacols_1))][global_channel_index][wregister_0][(globalbuffer_0 * 2 + (sarows_0))];
                        }  // sacols_1 (preload)
                      }  // sarows_1 (preload)
                    }  // sarows_0 (preload)

                    // ---- Phase 2a: multiply — 100 independent products ----
                    // product[2][5][2][5]: GCC SROA → 100 scalar float regs
                    DTYPE product[2][5][2][5];
                    int output_col_base = (dram_0 * 10 + globalbuffer_1) * 2;
                    #pragma GCC unroll 2
                    for (int sarows_0 = 0; sarows_0 < 2; ++sarows_0) {  // S:2
                      #pragma GCC unroll 5
                      for (int sarows_1 = 0; sarows_1 < 5; ++sarows_1) {  // C:5
                        #pragma GCC unroll 2
                        for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {  // Q:2
                          #pragma GCC unroll 5
                          for (int sacols_1 = 0; sacols_1 < 5; ++sacols_1) {  // M:5
                            int global_channel_index = (dram_2 * 5 + sarows_1);
                            int input_col = output_col_base + sacols_0 + (globalbuffer_0 * 2 + (sarows_0));
                            DTYPE weight_value = weight_tile[sarows_0][sarows_1][sacols_1];
                            DTYPE input_value = gb_input[global_channel_index][(globalbuffer_2 + wregister_0)][input_col];
                            product[sarows_0][sarows_1][sacols_0][sacols_1] = weight_value * input_value;
                          }  // sacols_1 (M:5)
                        }  // sacols_0 (Q:2)
                      }  // sarows_1 (C:5)
                    }  // sarows_0 (S:2)

                    // ---- Phase 2b: accumulate — 100 independent, no RAW chain ----
                    #pragma GCC unroll 2
                    for (int sarows_0 = 0; sarows_0 < 2; ++sarows_0) {
                      #pragma GCC unroll 5
                      for (int sarows_1 = 0; sarows_1 < 5; ++sarows_1) {
                        #pragma GCC unroll 2
                        for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
                          #pragma GCC unroll 5
                          for (int sacols_1 = 0; sacols_1 < 5; ++sacols_1) {
                            accumulator[sarows_0][sarows_1][sacols_0][sacols_1] += product[sarows_0][sarows_1][sacols_0][sacols_1];
                          }  // sacols_1
                        }  // sacols_0
                      }  // sarows_1
                    }  // sarows_0

                  }  // wregister_0

                }  // globalbuffer_0
              }  // dram_2

              // ---- reduction: 100 acc → 10 outputs (10 inputs each) ----
              DTYPE reduced_output[2][5];
              #pragma GCC unroll 2
              for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
                #pragma GCC unroll 5
                for (int sacols_1 = 0; sacols_1 < 5; ++sacols_1) {
                  DTYPE partial_sum_0_0 = accumulator[0][0][sacols_0][sacols_1] + accumulator[0][1][sacols_0][sacols_1];
                  DTYPE partial_sum_0_1 = accumulator[0][2][sacols_0][sacols_1] + accumulator[0][3][sacols_0][sacols_1];
                  DTYPE partial_sum_0_2 = accumulator[0][4][sacols_0][sacols_1] + accumulator[1][0][sacols_0][sacols_1];
                  DTYPE partial_sum_0_3 = accumulator[1][1][sacols_0][sacols_1] + accumulator[1][2][sacols_0][sacols_1];
                  DTYPE partial_sum_0_4 = accumulator[1][3][sacols_0][sacols_1] + accumulator[1][4][sacols_0][sacols_1];
                  DTYPE partial_sum_1_0 = partial_sum_0_0 + partial_sum_0_1;
                  DTYPE partial_sum_1_1 = partial_sum_0_2 + partial_sum_0_3;
                  DTYPE partial_sum_2_0 = partial_sum_1_0 + partial_sum_1_1;
                  DTYPE partial_sum_3_0 = partial_sum_2_0 + partial_sum_0_4;
                  reduced_output[sacols_0][sacols_1] = partial_sum_3_0;
                }  // sacols_1 (reduction)
              }  // sacols_0 (reduction)

              // OutRegister: write 10 outputs to 10 port(s), folding=1
              int output_filter_tile = (dram_1 * 10 + outregister_0);
              int output_row_tile = globalbuffer_2;
              int output_col_tile = (dram_0 * 10 + globalbuffer_1);
              int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
              dram_output_p0[output_dram_offset] = reduced_output[0][0];
              dram_output_p1[output_dram_offset] = reduced_output[0][1];
              dram_output_p2[output_dram_offset] = reduced_output[0][2];
              dram_output_p3[output_dram_offset] = reduced_output[0][3];
              dram_output_p4[output_dram_offset] = reduced_output[0][4];
              dram_output_p5[output_dram_offset] = reduced_output[1][0];
              dram_output_p6[output_dram_offset] = reduced_output[1][1];
              dram_output_p7[output_dram_offset] = reduced_output[1][2];
              dram_output_p8[output_dram_offset] = reduced_output[1][3];
              dram_output_p9[output_dram_offset] = reduced_output[1][4];
            }  // outregister_0
          }  // globalbuffer_2
        }  // globalbuffer_1
      }  // dram_1
    }  // dram_0
}
