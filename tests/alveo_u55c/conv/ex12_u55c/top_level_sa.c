#define DTYPE float

/* AXI pragmas: inputs and outputs share bundles (time-multiplexed) */
#pragma HLS interface port = dram_input_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_input_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_input_p2 mode = m_axi offset = direct bundle = gmem_2
#pragma HLS interface port = dram_input_p3 mode = m_axi offset = direct bundle = gmem_3
#pragma HLS interface port = dram_input_p4 mode = m_axi offset = direct bundle = gmem_4
#pragma HLS interface port = dram_input_p5 mode = m_axi offset = direct bundle = gmem_5
#pragma HLS interface port = dram_input_p6 mode = m_axi offset = direct bundle = gmem_6
#pragma HLS interface port = dram_input_p7 mode = m_axi offset = direct bundle = gmem_7
#pragma HLS interface port = dram_input_p8 mode = m_axi offset = direct bundle = gmem_8
#pragma HLS interface port = dram_input_p9 mode = m_axi offset = direct bundle = gmem_9
#pragma HLS interface port = dram_input_p10 mode = m_axi offset = direct bundle = gmem_10
#pragma HLS interface port = dram_input_p11 mode = m_axi offset = direct bundle = gmem_11
#pragma HLS interface port = dram_input_p12 mode = m_axi offset = direct bundle = gmem_12
#pragma HLS interface port = dram_input_p13 mode = m_axi offset = direct bundle = gmem_13
#pragma HLS interface port = dram_input_p14 mode = m_axi offset = direct bundle = gmem_14
#pragma HLS interface port = dram_input_p15 mode = m_axi offset = direct bundle = gmem_15
#pragma HLS interface port = dram_weight_p0 mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_weight_p1 mode = m_axi offset = direct bundle = gmem_1
#pragma HLS interface port = dram_weight_p2 mode = m_axi offset = direct bundle = gmem_2
#pragma HLS interface port = dram_weight_p3 mode = m_axi offset = direct bundle = gmem_3
#pragma HLS interface port = dram_weight_p4 mode = m_axi offset = direct bundle = gmem_4
#pragma HLS interface port = dram_weight_p5 mode = m_axi offset = direct bundle = gmem_5
#pragma HLS interface port = dram_weight_p6 mode = m_axi offset = direct bundle = gmem_6
#pragma HLS interface port = dram_weight_p7 mode = m_axi offset = direct bundle = gmem_7
#pragma HLS interface port = dram_weight_p8 mode = m_axi offset = direct bundle = gmem_8
#pragma HLS interface port = dram_weight_p9 mode = m_axi offset = direct bundle = gmem_9
#pragma HLS interface port = dram_weight_p10 mode = m_axi offset = direct bundle = gmem_10
#pragma HLS interface port = dram_weight_p11 mode = m_axi offset = direct bundle = gmem_11
#pragma HLS interface port = dram_weight_p12 mode = m_axi offset = direct bundle = gmem_12
#pragma HLS interface port = dram_weight_p13 mode = m_axi offset = direct bundle = gmem_13
#pragma HLS interface port = dram_weight_p14 mode = m_axi offset = direct bundle = gmem_14
#pragma HLS interface port = dram_weight_p15 mode = m_axi offset = direct bundle = gmem_15
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
#pragma HLS interface port = dram_output_p24 mode = m_axi offset = direct bundle = gmem_24
#pragma HLS interface port = dram_output_p25 mode = m_axi offset = direct bundle = gmem_25
#pragma HLS interface port = dram_output_p26 mode = m_axi offset = direct bundle = gmem_26
#pragma HLS interface port = dram_output_p27 mode = m_axi offset = direct bundle = gmem_27
#pragma HLS interface port = dram_output_p28 mode = m_axi offset = direct bundle = gmem_28
#pragma HLS interface port = dram_output_p29 mode = m_axi offset = direct bundle = gmem_29
#pragma HLS interface port = dram_output_p30 mode = m_axi offset = direct bundle = gmem_30
#pragma HLS interface port = dram_output_p31 mode = m_axi offset = direct bundle = gmem_31

// Internal scratchpads — filled once per top_level call from AXI ports
static DTYPE gb_weight[64][64][3][3];
static DTYPE gb_input[64][58][58];
void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_input_p2, DTYPE *dram_input_p3, DTYPE *dram_input_p4, DTYPE *dram_input_p5, DTYPE *dram_input_p6, DTYPE *dram_input_p7, DTYPE *dram_input_p8, DTYPE *dram_input_p9, DTYPE *dram_input_p10, DTYPE *dram_input_p11, DTYPE *dram_input_p12, DTYPE *dram_input_p13, DTYPE *dram_input_p14, DTYPE *dram_input_p15, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_weight_p2, DTYPE *dram_weight_p3, DTYPE *dram_weight_p4, DTYPE *dram_weight_p5, DTYPE *dram_weight_p6, DTYPE *dram_weight_p7, DTYPE *dram_weight_p8, DTYPE *dram_weight_p9, DTYPE *dram_weight_p10, DTYPE *dram_weight_p11, DTYPE *dram_weight_p12, DTYPE *dram_weight_p13, DTYPE *dram_weight_p14, DTYPE *dram_weight_p15, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7, DTYPE *dram_output_p8, DTYPE *dram_output_p9, DTYPE *dram_output_p10, DTYPE *dram_output_p11, DTYPE *dram_output_p12, DTYPE *dram_output_p13, DTYPE *dram_output_p14, DTYPE *dram_output_p15, DTYPE *dram_output_p16, DTYPE *dram_output_p17, DTYPE *dram_output_p18, DTYPE *dram_output_p19, DTYPE *dram_output_p20, DTYPE *dram_output_p21, DTYPE *dram_output_p22, DTYPE *dram_output_p23, DTYPE *dram_output_p24, DTYPE *dram_output_p25, DTYPE *dram_output_p26, DTYPE *dram_output_p27, DTYPE *dram_output_p28, DTYPE *dram_output_p29, DTYPE *dram_output_p30, DTYPE *dram_output_p31)
{
    // SA (weight-preload) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=64, P=56, Q=56, C=64, R=3, S=3;
    const int H=58, W=58;
    const int Ptiles=56, Qtiles=7;
    const int input_ports=16;

    // sarows_0 → SARows_0 = S:3
    // sarows_1 → SARows_1 = C:16
    // sacols_0 → SACols_0 = Q:8
    // sacols_1 → SACols_1 = M:8
    // 3072 PE accumulators: accumulator[3][16][8][8]
    DTYPE accumulator[3][16][8][8];

    // ---- GlobalBuffer weight preload: wt_ideal = 64*64*3*3 AXI reads ----
    for (int _gm = 0; _gm < 64; ++_gm) {
      for (int _gc = 0; _gc < 64; ++_gc) {
        for (int _gr = 0; _gr < 3; ++_gr) {
          for (int _gs = 0; _gs < 3; ++_gs) {
            int weight_port_index = _gc % 16;
            int _cb = _gc / 16;
            int _wa = (_gm * ((64 + 16 - 1) / 16) + _cb) * (3 * 3) + _gr * 3 + _gs;
            switch(weight_port_index) {
              case 0: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p0[_wa]; break;
              case 1: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p1[_wa]; break;
              case 2: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p2[_wa]; break;
              case 3: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p3[_wa]; break;
              case 4: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p4[_wa]; break;
              case 5: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p5[_wa]; break;
              case 6: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p6[_wa]; break;
              case 7: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p7[_wa]; break;
              case 8: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p8[_wa]; break;
              case 9: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p9[_wa]; break;
              case 10: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p10[_wa]; break;
              case 11: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p11[_wa]; break;
              case 12: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p12[_wa]; break;
              case 13: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p13[_wa]; break;
              case 14: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p14[_wa]; break;
              case 15: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p15[_wa]; break;
              default: gb_weight[_gm][_gc][_gr][_gs] = 0.0f; break;
            }
          }
        }
      }
    }

    // ---- GlobalBuffer input preload: in_ideal = 64*58*58 AXI reads ----
    for (int _gc = 0; _gc < 64; ++_gc) {
      for (int _gr = 0; _gr < 58; ++_gr) {
        for (int _gw = 0; _gw < 58; ++_gw) {
          int input_port_index = _gc % 16;
          int _cb = _gc / 16;
          int _ia = _cb * (58 * 58) + _gr * 58 + _gw;
          switch(input_port_index) {
            case 0: gb_input[_gc][_gr][_gw] = dram_input_p0[_ia]; break;
            case 1: gb_input[_gc][_gr][_gw] = dram_input_p1[_ia]; break;
            case 2: gb_input[_gc][_gr][_gw] = dram_input_p2[_ia]; break;
            case 3: gb_input[_gc][_gr][_gw] = dram_input_p3[_ia]; break;
            case 4: gb_input[_gc][_gr][_gw] = dram_input_p4[_ia]; break;
            case 5: gb_input[_gc][_gr][_gw] = dram_input_p5[_ia]; break;
            case 6: gb_input[_gc][_gr][_gw] = dram_input_p6[_ia]; break;
            case 7: gb_input[_gc][_gr][_gw] = dram_input_p7[_ia]; break;
            case 8: gb_input[_gc][_gr][_gw] = dram_input_p8[_ia]; break;
            case 9: gb_input[_gc][_gr][_gw] = dram_input_p9[_ia]; break;
            case 10: gb_input[_gc][_gr][_gw] = dram_input_p10[_ia]; break;
            case 11: gb_input[_gc][_gr][_gw] = dram_input_p11[_ia]; break;
            case 12: gb_input[_gc][_gr][_gw] = dram_input_p12[_ia]; break;
            case 13: gb_input[_gc][_gr][_gw] = dram_input_p13[_ia]; break;
            case 14: gb_input[_gc][_gr][_gw] = dram_input_p14[_ia]; break;
            case 15: gb_input[_gc][_gr][_gw] = dram_input_p15[_ia]; break;
            default: gb_input[_gc][_gr][_gw] = 0.0f; break;
          }
        }
      }
    }

    // DRAM_0 = Q:7
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 7; ++dram_0) {
      // DRAM_1 = P:56
      #pragma GCC nounroll
      for (int dram_1 = 0; dram_1 < 56; ++dram_1) {
        // OutRegister_0 = M:8
        #pragma GCC nounroll
        for (int outregister_0 = 0; outregister_0 < 8; ++outregister_0) {
          // Zero 3072 PE accumulators (nounroll — non-spatial init)
          #pragma GCC nounroll
          for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
            #pragma GCC nounroll
            for (int sarows_1 = 0; sarows_1 < 16; ++sarows_1) {
              #pragma GCC nounroll
              for (int sacols_0 = 0; sacols_0 < 8; ++sacols_0) {
                #pragma GCC nounroll
                for (int sacols_1 = 0; sacols_1 < 8; ++sacols_1) {
                  accumulator[sarows_0][sarows_1][sacols_0][sacols_1] = 0.0f;
                }
              }
            }
          }

          // WRegister → C:4 (sequential)
          #pragma GCC nounroll
          for (int wregister_0 = 0; wregister_0 < 4; ++wregister_0) {
            // WRegister → R:3 (sequential)
            #pragma GCC nounroll
            for (int wregister_1 = 0; wregister_1 < 3; ++wregister_1) {
              // ---- Phase 1: preload weights — 384 elems, no Q loop ----
              // weight_tile[3][16][8]: level-indexed, Q absent (weight is Q-independent)
              DTYPE weight_tile[3][16][8];
              #pragma GCC unroll 3
              for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
                #pragma GCC unroll 16
                for (int sarows_1 = 0; sarows_1 < 16; ++sarows_1) {
                  #pragma GCC unroll 8
                  for (int sacols_1 = 0; sacols_1 < 8; ++sacols_1) {
                    int global_channel_index = (wregister_0 * 16 + (sarows_1));
                    weight_tile[sarows_0][sarows_1][sacols_1] = gb_weight[(outregister_0 * 8 + (sacols_1))][global_channel_index][wregister_1][sarows_0];
                  }  // sacols_1 (preload)
                }  // sarows_1 (preload)
              }  // sarows_0 (preload)

              // ---- Phase 2a: multiply — 3072 independent products ----
              // product[3][16][8][8]: GCC SROA → 3072 scalar float regs
              DTYPE product[3][16][8][8];
              int output_col_base = dram_0 * 8;
              #pragma GCC unroll 3
              for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {  // S:3
                #pragma GCC unroll 16
                for (int sarows_1 = 0; sarows_1 < 16; ++sarows_1) {  // C:16
                  #pragma GCC unroll 8
                  for (int sacols_0 = 0; sacols_0 < 8; ++sacols_0) {  // Q:8
                    #pragma GCC unroll 8
                    for (int sacols_1 = 0; sacols_1 < 8; ++sacols_1) {  // M:8
                      int global_channel_index = (wregister_0 * 16 + (sarows_1));
                      int input_col = output_col_base + sacols_0 + sarows_0;
                      DTYPE weight_value = weight_tile[sarows_0][sarows_1][sacols_1];
                      DTYPE input_value = gb_input[global_channel_index][(dram_1 + wregister_1)][input_col];
                      product[sarows_0][sarows_1][sacols_0][sacols_1] = weight_value * input_value;
                    }  // sacols_1 (M:8)
                  }  // sacols_0 (Q:8)
                }  // sarows_1 (C:16)
              }  // sarows_0 (S:3)

              // ---- Phase 2b: accumulate — 3072 independent, no RAW chain ----
              #pragma GCC unroll 3
              for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
                #pragma GCC unroll 16
                for (int sarows_1 = 0; sarows_1 < 16; ++sarows_1) {
                  #pragma GCC unroll 8
                  for (int sacols_0 = 0; sacols_0 < 8; ++sacols_0) {
                    #pragma GCC unroll 8
                    for (int sacols_1 = 0; sacols_1 < 8; ++sacols_1) {
                      accumulator[sarows_0][sarows_1][sacols_0][sacols_1] += product[sarows_0][sarows_1][sacols_0][sacols_1];
                    }  // sacols_1
                  }  // sacols_0
                }  // sarows_1
              }  // sarows_0

            }  // wregister_1
          }  // wregister_0

          // ---- reduction: 3072 acc → 64 outputs (48 inputs each) ----
          DTYPE reduced_output[8][8];
          #pragma GCC unroll 8
          for (int sacols_0 = 0; sacols_0 < 8; ++sacols_0) {
            #pragma GCC unroll 8
            for (int sacols_1 = 0; sacols_1 < 8; ++sacols_1) {
              DTYPE partial_sum_0_0 = accumulator[0][0][sacols_0][sacols_1] + accumulator[0][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_1 = accumulator[0][2][sacols_0][sacols_1] + accumulator[0][3][sacols_0][sacols_1];
              DTYPE partial_sum_0_2 = accumulator[0][4][sacols_0][sacols_1] + accumulator[0][5][sacols_0][sacols_1];
              DTYPE partial_sum_0_3 = accumulator[0][6][sacols_0][sacols_1] + accumulator[0][7][sacols_0][sacols_1];
              DTYPE partial_sum_0_4 = accumulator[0][8][sacols_0][sacols_1] + accumulator[0][9][sacols_0][sacols_1];
              DTYPE partial_sum_0_5 = accumulator[0][10][sacols_0][sacols_1] + accumulator[0][11][sacols_0][sacols_1];
              DTYPE partial_sum_0_6 = accumulator[0][12][sacols_0][sacols_1] + accumulator[0][13][sacols_0][sacols_1];
              DTYPE partial_sum_0_7 = accumulator[0][14][sacols_0][sacols_1] + accumulator[0][15][sacols_0][sacols_1];
              DTYPE partial_sum_0_8 = accumulator[1][0][sacols_0][sacols_1] + accumulator[1][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_9 = accumulator[1][2][sacols_0][sacols_1] + accumulator[1][3][sacols_0][sacols_1];
              DTYPE partial_sum_0_10 = accumulator[1][4][sacols_0][sacols_1] + accumulator[1][5][sacols_0][sacols_1];
              DTYPE partial_sum_0_11 = accumulator[1][6][sacols_0][sacols_1] + accumulator[1][7][sacols_0][sacols_1];
              DTYPE partial_sum_0_12 = accumulator[1][8][sacols_0][sacols_1] + accumulator[1][9][sacols_0][sacols_1];
              DTYPE partial_sum_0_13 = accumulator[1][10][sacols_0][sacols_1] + accumulator[1][11][sacols_0][sacols_1];
              DTYPE partial_sum_0_14 = accumulator[1][12][sacols_0][sacols_1] + accumulator[1][13][sacols_0][sacols_1];
              DTYPE partial_sum_0_15 = accumulator[1][14][sacols_0][sacols_1] + accumulator[1][15][sacols_0][sacols_1];
              DTYPE partial_sum_0_16 = accumulator[2][0][sacols_0][sacols_1] + accumulator[2][1][sacols_0][sacols_1];
              DTYPE partial_sum_0_17 = accumulator[2][2][sacols_0][sacols_1] + accumulator[2][3][sacols_0][sacols_1];
              DTYPE partial_sum_0_18 = accumulator[2][4][sacols_0][sacols_1] + accumulator[2][5][sacols_0][sacols_1];
              DTYPE partial_sum_0_19 = accumulator[2][6][sacols_0][sacols_1] + accumulator[2][7][sacols_0][sacols_1];
              DTYPE partial_sum_0_20 = accumulator[2][8][sacols_0][sacols_1] + accumulator[2][9][sacols_0][sacols_1];
              DTYPE partial_sum_0_21 = accumulator[2][10][sacols_0][sacols_1] + accumulator[2][11][sacols_0][sacols_1];
              DTYPE partial_sum_0_22 = accumulator[2][12][sacols_0][sacols_1] + accumulator[2][13][sacols_0][sacols_1];
              DTYPE partial_sum_0_23 = accumulator[2][14][sacols_0][sacols_1] + accumulator[2][15][sacols_0][sacols_1];
              DTYPE partial_sum_1_0 = partial_sum_0_0 + partial_sum_0_1;
              DTYPE partial_sum_1_1 = partial_sum_0_2 + partial_sum_0_3;
              DTYPE partial_sum_1_2 = partial_sum_0_4 + partial_sum_0_5;
              DTYPE partial_sum_1_3 = partial_sum_0_6 + partial_sum_0_7;
              DTYPE partial_sum_1_4 = partial_sum_0_8 + partial_sum_0_9;
              DTYPE partial_sum_1_5 = partial_sum_0_10 + partial_sum_0_11;
              DTYPE partial_sum_1_6 = partial_sum_0_12 + partial_sum_0_13;
              DTYPE partial_sum_1_7 = partial_sum_0_14 + partial_sum_0_15;
              DTYPE partial_sum_1_8 = partial_sum_0_16 + partial_sum_0_17;
              DTYPE partial_sum_1_9 = partial_sum_0_18 + partial_sum_0_19;
              DTYPE partial_sum_1_10 = partial_sum_0_20 + partial_sum_0_21;
              DTYPE partial_sum_1_11 = partial_sum_0_22 + partial_sum_0_23;
              DTYPE partial_sum_2_0 = partial_sum_1_0 + partial_sum_1_1;
              DTYPE partial_sum_2_1 = partial_sum_1_2 + partial_sum_1_3;
              DTYPE partial_sum_2_2 = partial_sum_1_4 + partial_sum_1_5;
              DTYPE partial_sum_2_3 = partial_sum_1_6 + partial_sum_1_7;
              DTYPE partial_sum_2_4 = partial_sum_1_8 + partial_sum_1_9;
              DTYPE partial_sum_2_5 = partial_sum_1_10 + partial_sum_1_11;
              DTYPE partial_sum_3_0 = partial_sum_2_0 + partial_sum_2_1;
              DTYPE partial_sum_3_1 = partial_sum_2_2 + partial_sum_2_3;
              DTYPE partial_sum_3_2 = partial_sum_2_4 + partial_sum_2_5;
              DTYPE partial_sum_4_0 = partial_sum_3_0 + partial_sum_3_1;
              DTYPE partial_sum_5_0 = partial_sum_4_0 + partial_sum_3_2;
              reduced_output[sacols_0][sacols_1] = partial_sum_5_0;
            }  // sacols_1 (reduction)
          }  // sacols_0 (reduction)

          // OutRegister: write 64 outputs to 32 port(s), folding=2
          int output_filter_tile = outregister_0;
          int output_row_tile = dram_1;
          int output_col_tile = dram_0;
          int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
          dram_output_p0[output_dram_offset * 2 + 0] = reduced_output[0][0];
          dram_output_p1[output_dram_offset * 2 + 0] = reduced_output[0][1];
          dram_output_p2[output_dram_offset * 2 + 0] = reduced_output[0][2];
          dram_output_p3[output_dram_offset * 2 + 0] = reduced_output[0][3];
          dram_output_p4[output_dram_offset * 2 + 0] = reduced_output[0][4];
          dram_output_p5[output_dram_offset * 2 + 0] = reduced_output[0][5];
          dram_output_p6[output_dram_offset * 2 + 0] = reduced_output[0][6];
          dram_output_p7[output_dram_offset * 2 + 0] = reduced_output[0][7];
          dram_output_p8[output_dram_offset * 2 + 0] = reduced_output[1][0];
          dram_output_p9[output_dram_offset * 2 + 0] = reduced_output[1][1];
          dram_output_p10[output_dram_offset * 2 + 0] = reduced_output[1][2];
          dram_output_p11[output_dram_offset * 2 + 0] = reduced_output[1][3];
          dram_output_p12[output_dram_offset * 2 + 0] = reduced_output[1][4];
          dram_output_p13[output_dram_offset * 2 + 0] = reduced_output[1][5];
          dram_output_p14[output_dram_offset * 2 + 0] = reduced_output[1][6];
          dram_output_p15[output_dram_offset * 2 + 0] = reduced_output[1][7];
          dram_output_p16[output_dram_offset * 2 + 0] = reduced_output[2][0];
          dram_output_p17[output_dram_offset * 2 + 0] = reduced_output[2][1];
          dram_output_p18[output_dram_offset * 2 + 0] = reduced_output[2][2];
          dram_output_p19[output_dram_offset * 2 + 0] = reduced_output[2][3];
          dram_output_p20[output_dram_offset * 2 + 0] = reduced_output[2][4];
          dram_output_p21[output_dram_offset * 2 + 0] = reduced_output[2][5];
          dram_output_p22[output_dram_offset * 2 + 0] = reduced_output[2][6];
          dram_output_p23[output_dram_offset * 2 + 0] = reduced_output[2][7];
          dram_output_p24[output_dram_offset * 2 + 0] = reduced_output[3][0];
          dram_output_p25[output_dram_offset * 2 + 0] = reduced_output[3][1];
          dram_output_p26[output_dram_offset * 2 + 0] = reduced_output[3][2];
          dram_output_p27[output_dram_offset * 2 + 0] = reduced_output[3][3];
          dram_output_p28[output_dram_offset * 2 + 0] = reduced_output[3][4];
          dram_output_p29[output_dram_offset * 2 + 0] = reduced_output[3][5];
          dram_output_p30[output_dram_offset * 2 + 0] = reduced_output[3][6];
          dram_output_p31[output_dram_offset * 2 + 0] = reduced_output[3][7];
          dram_output_p0[output_dram_offset * 2 + 1] = reduced_output[4][0];
          dram_output_p1[output_dram_offset * 2 + 1] = reduced_output[4][1];
          dram_output_p2[output_dram_offset * 2 + 1] = reduced_output[4][2];
          dram_output_p3[output_dram_offset * 2 + 1] = reduced_output[4][3];
          dram_output_p4[output_dram_offset * 2 + 1] = reduced_output[4][4];
          dram_output_p5[output_dram_offset * 2 + 1] = reduced_output[4][5];
          dram_output_p6[output_dram_offset * 2 + 1] = reduced_output[4][6];
          dram_output_p7[output_dram_offset * 2 + 1] = reduced_output[4][7];
          dram_output_p8[output_dram_offset * 2 + 1] = reduced_output[5][0];
          dram_output_p9[output_dram_offset * 2 + 1] = reduced_output[5][1];
          dram_output_p10[output_dram_offset * 2 + 1] = reduced_output[5][2];
          dram_output_p11[output_dram_offset * 2 + 1] = reduced_output[5][3];
          dram_output_p12[output_dram_offset * 2 + 1] = reduced_output[5][4];
          dram_output_p13[output_dram_offset * 2 + 1] = reduced_output[5][5];
          dram_output_p14[output_dram_offset * 2 + 1] = reduced_output[5][6];
          dram_output_p15[output_dram_offset * 2 + 1] = reduced_output[5][7];
          dram_output_p16[output_dram_offset * 2 + 1] = reduced_output[6][0];
          dram_output_p17[output_dram_offset * 2 + 1] = reduced_output[6][1];
          dram_output_p18[output_dram_offset * 2 + 1] = reduced_output[6][2];
          dram_output_p19[output_dram_offset * 2 + 1] = reduced_output[6][3];
          dram_output_p20[output_dram_offset * 2 + 1] = reduced_output[6][4];
          dram_output_p21[output_dram_offset * 2 + 1] = reduced_output[6][5];
          dram_output_p22[output_dram_offset * 2 + 1] = reduced_output[6][6];
          dram_output_p23[output_dram_offset * 2 + 1] = reduced_output[6][7];
          dram_output_p24[output_dram_offset * 2 + 1] = reduced_output[7][0];
          dram_output_p25[output_dram_offset * 2 + 1] = reduced_output[7][1];
          dram_output_p26[output_dram_offset * 2 + 1] = reduced_output[7][2];
          dram_output_p27[output_dram_offset * 2 + 1] = reduced_output[7][3];
          dram_output_p28[output_dram_offset * 2 + 1] = reduced_output[7][4];
          dram_output_p29[output_dram_offset * 2 + 1] = reduced_output[7][5];
          dram_output_p30[output_dram_offset * 2 + 1] = reduced_output[7][6];
          dram_output_p31[output_dram_offset * 2 + 1] = reduced_output[7][7];
        }  // outregister_0
      }  // dram_1
    }  // dram_0
}
