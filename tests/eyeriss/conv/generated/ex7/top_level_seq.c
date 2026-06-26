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
    // seq (all-nounroll) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=100, P=100, Q=100, C=100, R=16, S=16;
    const int H=115, W=115;
    const int Ptiles=100, Qtiles=50;
    const int input_ports=5;

    // Accumulator: flat 1D at function scope → GCC SROA → 10 scalar regs
    DTYPE accumulator[10];

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
              // Zero accumulator (nounroll — non-spatial init)
              #pragma GCC nounroll
              for (int accumulator_dim_index = 0; accumulator_dim_index < 10; ++accumulator_dim_index) accumulator[accumulator_dim_index] = 0.0f;

              // DRAM_2 = C:20
              #pragma GCC nounroll
              for (int dram_2 = 0; dram_2 < 20; ++dram_2) {
                // GlobalBuffer_0 = S:8
                #pragma GCC nounroll
                for (int globalbuffer_0 = 0; globalbuffer_0 < 8; ++globalbuffer_0) {
                  // WRegister → R:16 (sequential)
                  #pragma GCC nounroll
                  for (int wregister_0 = 0; wregister_0 < 16; ++wregister_0) {
                    // SARows C:5 -- sequential (reduction)
                    #pragma GCC nounroll
                    for (int c = 0; c < 5; ++c) {
                      int global_channel_index = dram_2 * 5 + c;
                      int output_col_base = (dram_0 * 10 + globalbuffer_1) * 2;

                      // SARows S:2
                      #pragma GCC nounroll
                      for (int s = 0; s < 2; ++s) {
                        #pragma GCC nounroll
                        for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {  // Q:2
                          #pragma GCC nounroll
                          for (int sacols_1 = 0; sacols_1 < 5; ++sacols_1) {  // M:5
                            DTYPE weight_value = gb_weight[((dram_1 * 10 + outregister_0) * 5 + (sacols_1))][global_channel_index][wregister_0][(globalbuffer_0 * 2 + s)];
                            DTYPE input_value = gb_input[global_channel_index][(globalbuffer_2 + wregister_0)][output_col_base + sacols_0 + (globalbuffer_0 * 2 + s)];
                            accumulator[sacols_0*5 + sacols_1] += weight_value * input_value;
                          }  // sacols_1 (M:5)
                        }  // sacols_0 (Q:2)
                      }  // s
                    }  // c

                  }  // wregister_0

                }  // globalbuffer_0
              }  // dram_2

              // OutRegister: write 10 outputs to 10 port(s), folding=1
              int output_filter_tile = (dram_1 * 10 + outregister_0);
              int output_row_tile = globalbuffer_2;
              int output_col_tile = (dram_0 * 10 + globalbuffer_1);
              int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
              dram_output_p0[output_dram_offset] = accumulator[0];
              dram_output_p1[output_dram_offset] = accumulator[1];
              dram_output_p2[output_dram_offset] = accumulator[2];
              dram_output_p3[output_dram_offset] = accumulator[3];
              dram_output_p4[output_dram_offset] = accumulator[4];
              dram_output_p5[output_dram_offset] = accumulator[5];
              dram_output_p6[output_dram_offset] = accumulator[6];
              dram_output_p7[output_dram_offset] = accumulator[7];
              dram_output_p8[output_dram_offset] = accumulator[8];
              dram_output_p9[output_dram_offset] = accumulator[9];
            }  // outregister_0
          }  // globalbuffer_2
        }  // globalbuffer_1
      }  // dram_1
    }  // dram_0
}
