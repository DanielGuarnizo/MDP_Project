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
    // seq (all-nounroll) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=64, P=56, Q=56, C=64, R=3, S=3;
    const int H=58, W=58;
    const int Ptiles=56, Qtiles=7;
    const int input_ports=16;

    // Accumulator: flat 1D at function scope → GCC SROA → 64 scalar regs
    DTYPE accumulator[64];

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
          // Zero accumulator (nounroll — non-spatial init)
          #pragma GCC nounroll
          for (int accumulator_dim_index = 0; accumulator_dim_index < 64; ++accumulator_dim_index) accumulator[accumulator_dim_index] = 0.0f;

          // WRegister → C:4 (sequential)
          #pragma GCC nounroll
          for (int wregister_0 = 0; wregister_0 < 4; ++wregister_0) {
            // WRegister → R:3 (sequential)
            #pragma GCC nounroll
            for (int wregister_1 = 0; wregister_1 < 3; ++wregister_1) {
              // SARows C:16 -- sequential (reduction)
              #pragma GCC nounroll
              for (int c = 0; c < 16; ++c) {
                int global_channel_index = wregister_0 * 16 + c;
                int output_col_base = dram_0 * 8;

                // SARows S:3
                #pragma GCC nounroll
                for (int s = 0; s < 3; ++s) {
                  #pragma GCC nounroll
                  for (int sacols_0 = 0; sacols_0 < 8; ++sacols_0) {  // Q:8
                    #pragma GCC nounroll
                    for (int sacols_1 = 0; sacols_1 < 8; ++sacols_1) {  // M:8
                      DTYPE weight_value = gb_weight[(outregister_0 * 8 + (sacols_1))][global_channel_index][wregister_1][s];
                      DTYPE input_value = gb_input[global_channel_index][(dram_1 + wregister_1)][output_col_base + sacols_0 + s];
                      accumulator[sacols_0*8 + sacols_1] += weight_value * input_value;
                    }  // sacols_1 (M:8)
                  }  // sacols_0 (Q:8)
                }  // s
              }  // c

            }  // wregister_1
          }  // wregister_0

          // OutRegister: write 64 outputs to 32 port(s), folding=2
          int output_filter_tile = outregister_0;
          int output_row_tile = dram_1;
          int output_col_tile = dram_0;
          int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
          dram_output_p0[output_dram_offset * 2 + 0] = accumulator[0];
          dram_output_p1[output_dram_offset * 2 + 0] = accumulator[1];
          dram_output_p2[output_dram_offset * 2 + 0] = accumulator[2];
          dram_output_p3[output_dram_offset * 2 + 0] = accumulator[3];
          dram_output_p4[output_dram_offset * 2 + 0] = accumulator[4];
          dram_output_p5[output_dram_offset * 2 + 0] = accumulator[5];
          dram_output_p6[output_dram_offset * 2 + 0] = accumulator[6];
          dram_output_p7[output_dram_offset * 2 + 0] = accumulator[7];
          dram_output_p8[output_dram_offset * 2 + 0] = accumulator[8];
          dram_output_p9[output_dram_offset * 2 + 0] = accumulator[9];
          dram_output_p10[output_dram_offset * 2 + 0] = accumulator[10];
          dram_output_p11[output_dram_offset * 2 + 0] = accumulator[11];
          dram_output_p12[output_dram_offset * 2 + 0] = accumulator[12];
          dram_output_p13[output_dram_offset * 2 + 0] = accumulator[13];
          dram_output_p14[output_dram_offset * 2 + 0] = accumulator[14];
          dram_output_p15[output_dram_offset * 2 + 0] = accumulator[15];
          dram_output_p16[output_dram_offset * 2 + 0] = accumulator[16];
          dram_output_p17[output_dram_offset * 2 + 0] = accumulator[17];
          dram_output_p18[output_dram_offset * 2 + 0] = accumulator[18];
          dram_output_p19[output_dram_offset * 2 + 0] = accumulator[19];
          dram_output_p20[output_dram_offset * 2 + 0] = accumulator[20];
          dram_output_p21[output_dram_offset * 2 + 0] = accumulator[21];
          dram_output_p22[output_dram_offset * 2 + 0] = accumulator[22];
          dram_output_p23[output_dram_offset * 2 + 0] = accumulator[23];
          dram_output_p24[output_dram_offset * 2 + 0] = accumulator[24];
          dram_output_p25[output_dram_offset * 2 + 0] = accumulator[25];
          dram_output_p26[output_dram_offset * 2 + 0] = accumulator[26];
          dram_output_p27[output_dram_offset * 2 + 0] = accumulator[27];
          dram_output_p28[output_dram_offset * 2 + 0] = accumulator[28];
          dram_output_p29[output_dram_offset * 2 + 0] = accumulator[29];
          dram_output_p30[output_dram_offset * 2 + 0] = accumulator[30];
          dram_output_p31[output_dram_offset * 2 + 0] = accumulator[31];
          dram_output_p0[output_dram_offset * 2 + 1] = accumulator[32];
          dram_output_p1[output_dram_offset * 2 + 1] = accumulator[33];
          dram_output_p2[output_dram_offset * 2 + 1] = accumulator[34];
          dram_output_p3[output_dram_offset * 2 + 1] = accumulator[35];
          dram_output_p4[output_dram_offset * 2 + 1] = accumulator[36];
          dram_output_p5[output_dram_offset * 2 + 1] = accumulator[37];
          dram_output_p6[output_dram_offset * 2 + 1] = accumulator[38];
          dram_output_p7[output_dram_offset * 2 + 1] = accumulator[39];
          dram_output_p8[output_dram_offset * 2 + 1] = accumulator[40];
          dram_output_p9[output_dram_offset * 2 + 1] = accumulator[41];
          dram_output_p10[output_dram_offset * 2 + 1] = accumulator[42];
          dram_output_p11[output_dram_offset * 2 + 1] = accumulator[43];
          dram_output_p12[output_dram_offset * 2 + 1] = accumulator[44];
          dram_output_p13[output_dram_offset * 2 + 1] = accumulator[45];
          dram_output_p14[output_dram_offset * 2 + 1] = accumulator[46];
          dram_output_p15[output_dram_offset * 2 + 1] = accumulator[47];
          dram_output_p16[output_dram_offset * 2 + 1] = accumulator[48];
          dram_output_p17[output_dram_offset * 2 + 1] = accumulator[49];
          dram_output_p18[output_dram_offset * 2 + 1] = accumulator[50];
          dram_output_p19[output_dram_offset * 2 + 1] = accumulator[51];
          dram_output_p20[output_dram_offset * 2 + 1] = accumulator[52];
          dram_output_p21[output_dram_offset * 2 + 1] = accumulator[53];
          dram_output_p22[output_dram_offset * 2 + 1] = accumulator[54];
          dram_output_p23[output_dram_offset * 2 + 1] = accumulator[55];
          dram_output_p24[output_dram_offset * 2 + 1] = accumulator[56];
          dram_output_p25[output_dram_offset * 2 + 1] = accumulator[57];
          dram_output_p26[output_dram_offset * 2 + 1] = accumulator[58];
          dram_output_p27[output_dram_offset * 2 + 1] = accumulator[59];
          dram_output_p28[output_dram_offset * 2 + 1] = accumulator[60];
          dram_output_p29[output_dram_offset * 2 + 1] = accumulator[61];
          dram_output_p30[output_dram_offset * 2 + 1] = accumulator[62];
          dram_output_p31[output_dram_offset * 2 + 1] = accumulator[63];
        }  // outregister_0
      }  // dram_1
    }  // dram_0
}
