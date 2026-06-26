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
#pragma HLS interface port = dram_output_p8 mode = m_axi offset = direct bundle = gmem_8
#pragma HLS interface port = dram_output_p9 mode = m_axi offset = direct bundle = gmem_9
#pragma HLS interface port = dram_output_p10 mode = m_axi offset = direct bundle = gmem_10
#pragma HLS interface port = dram_output_p11 mode = m_axi offset = direct bundle = gmem_11
#pragma HLS interface port = dram_output_p12 mode = m_axi offset = direct bundle = gmem_12
#pragma HLS interface port = dram_output_p13 mode = m_axi offset = direct bundle = gmem_13
#pragma HLS interface port = dram_output_p14 mode = m_axi offset = direct bundle = gmem_14
#pragma HLS interface port = dram_output_p15 mode = m_axi offset = direct bundle = gmem_15

// GlobalBuffer scratchpads — filled once per top_level call from AXI ports
static DTYPE gb_weight[64][64][3][3];
static DTYPE gb_input[64][58][58];
void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7, DTYPE *dram_output_p8, DTYPE *dram_output_p9, DTYPE *dram_output_p10, DTYPE *dram_output_p11, DTYPE *dram_output_p12, DTYPE *dram_output_p13, DTYPE *dram_output_p14, DTYPE *dram_output_p15)
{
    // seq (all-nounroll) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=64, P=56, Q=56, C=64, R=3, S=3;
    const int H=58, W=58;
    const int Ptiles=56, Qtiles=8;
    const int input_ports=2;

    // Accumulator: flat 1D at function scope → GCC SROA → 28 scalar regs
    DTYPE accumulator[28];

    // ---- GlobalBuffer weight preload: wt_ideal = 64*64*3*3 AXI reads ----
    for (int _gm = 0; _gm < 64; ++_gm) {
      for (int _gc = 0; _gc < 64; ++_gc) {
        for (int _gr = 0; _gr < 3; ++_gr) {
          for (int _gs = 0; _gs < 3; ++_gs) {
            int weight_port_index = _gc % 2;
            int _cb = _gc / 2;
            int _wa = (_gm * ((64 + 2 - 1) / 2) + _cb) * (3 * 3) + _gr * 3 + _gs;
            switch(weight_port_index) {
              case 0: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p0[_wa]; break;
              case 1: gb_weight[_gm][_gc][_gr][_gs] = dram_weight_p1[_wa]; break;
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
          int input_port_index = _gc % 2;
          int _cb = _gc / 2;
          int _ia = _cb * (58 * 58) + _gr * 58 + _gw;
          switch(input_port_index) {
            case 0: gb_input[_gc][_gr][_gw] = dram_input_p0[_ia]; break;
            case 1: gb_input[_gc][_gr][_gw] = dram_input_p1[_ia]; break;
            default: gb_input[_gc][_gr][_gw] = 0.0f; break;
          }
        }
      }
    }

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
                            DTYPE weight_value = gb_weight[(outregister_0 * 4 + (sarows_2*2 + sacols_1))][global_channel_index][wregister_1][s];
                            DTYPE input_value = gb_input[global_channel_index][(globalbuffer_1 + wregister_1)][output_col_base + sacols_0 + s];
                            accumulator[sarows_2*14 + sacols_0*2 + sacols_1] += weight_value * input_value;
                          }  // sacols_1 (M:2)
                        }  // sacols_0 (Q:7)
                      }  // sarows_2 (M:2)
                    }  // s
                  }  // c

                }  // wregister_1
              }  // wregister_0

            }  // dram_1

            // OutRegister: write 28 outputs to 16 port(s), folding=2
            int output_filter_tile = outregister_0;
            int output_row_tile = globalbuffer_1;
            int output_col_tile = (dram_0 * 4 + globalbuffer_0);
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
            dram_output_p0[output_dram_offset * 2 + 1] = accumulator[16];
            dram_output_p1[output_dram_offset * 2 + 1] = accumulator[17];
            dram_output_p2[output_dram_offset * 2 + 1] = accumulator[18];
            dram_output_p3[output_dram_offset * 2 + 1] = accumulator[19];
            dram_output_p4[output_dram_offset * 2 + 1] = accumulator[20];
            dram_output_p5[output_dram_offset * 2 + 1] = accumulator[21];
            dram_output_p6[output_dram_offset * 2 + 1] = accumulator[22];
            dram_output_p7[output_dram_offset * 2 + 1] = accumulator[23];
            dram_output_p8[output_dram_offset * 2 + 1] = accumulator[24];
            dram_output_p9[output_dram_offset * 2 + 1] = accumulator[25];
            dram_output_p10[output_dram_offset * 2 + 1] = accumulator[26];
            dram_output_p11[output_dram_offset * 2 + 1] = accumulator[27];
          }  // outregister_0
        }  // globalbuffer_1
      }  // globalbuffer_0
    }  // dram_0
}
