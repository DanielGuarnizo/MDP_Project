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

// GlobalBuffer scratchpads — filled once per top_level call from AXI ports
static DTYPE gb_weight[4][4][3][3];
static DTYPE gb_input[4][6][6];
void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_input_p2, DTYPE *dram_input_p3, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_weight_p2, DTYPE *dram_weight_p3, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3)
{
    // seq (all-nounroll) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=4, P=4, Q=4, C=4, R=3, S=3;
    const int H=6, W=6;
    const int Ptiles=4, Qtiles=2;
    const int input_ports=4;

    // Accumulator: flat 1D at function scope → GCC SROA → 8 scalar regs
    DTYPE accumulator[8];

    // ---- GlobalBuffer weight preload: wt_ideal = 4*4*3*3 AXI reads ----
    for (int _gm = 0; _gm < 4; ++_gm) {
      for (int _gc = 0; _gc < 4; ++_gc) {
        for (int _gr = 0; _gr < 3; ++_gr) {
          for (int _gs = 0; _gs < 3; ++_gs) {
            int weight_port_index = _gc % 4;
            int _cb = _gc / 4;
            int _wa = (_gm * ((4 + 4 - 1) / 4) + _cb) * (3 * 3) + _gr * 3 + _gs;
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

    // ---- GlobalBuffer input preload: in_ideal = 4*6*6 AXI reads ----
    for (int _gc = 0; _gc < 4; ++_gc) {
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

    // DRAM_0 = Q:2
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 2; ++dram_0) {
      // GlobalBuffer_0 = P:4
      #pragma GCC nounroll
      for (int globalbuffer_0 = 0; globalbuffer_0 < 4; ++globalbuffer_0) {
        // Zero accumulator (nounroll — non-spatial init)
        #pragma GCC nounroll
        for (int accumulator_dim_index = 0; accumulator_dim_index < 8; ++accumulator_dim_index) accumulator[accumulator_dim_index] = 0.0f;

        // WRegister → R:3 (sequential)
        #pragma GCC nounroll
        for (int wregister_0 = 0; wregister_0 < 3; ++wregister_0) {
          // SARows C:4 -- sequential (reduction)
          #pragma GCC nounroll
          for (int c = 0; c < 4; ++c) {
            int global_channel_index = c;
            int output_col_base = dram_0 * 2;

            // SARows S:3
            #pragma GCC nounroll
            for (int s = 0; s < 3; ++s) {
              #pragma GCC nounroll
              for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {  // Q:2
                #pragma GCC nounroll
                for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {  // M:4
                  DTYPE weight_value = gb_weight[sacols_1][global_channel_index][wregister_0][s];
                  DTYPE input_value = gb_input[global_channel_index][(globalbuffer_0 + wregister_0)][output_col_base + sacols_0 + s];
                  accumulator[sacols_0*4 + sacols_1] += weight_value * input_value;
                }  // sacols_1 (M:4)
              }  // sacols_0 (Q:2)
            }  // s
          }  // c

        }  // wregister_0

        // OutRegister: write 8 outputs to 4 port(s), folding=2
        int output_filter_tile = 0;
        int output_row_tile = globalbuffer_0;
        int output_col_tile = dram_0;
        int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
        dram_output_p0[output_dram_offset * 2 + 0] = accumulator[0];
        dram_output_p1[output_dram_offset * 2 + 0] = accumulator[1];
        dram_output_p2[output_dram_offset * 2 + 0] = accumulator[2];
        dram_output_p3[output_dram_offset * 2 + 0] = accumulator[3];
        dram_output_p0[output_dram_offset * 2 + 1] = accumulator[4];
        dram_output_p1[output_dram_offset * 2 + 1] = accumulator[5];
        dram_output_p2[output_dram_offset * 2 + 1] = accumulator[6];
        dram_output_p3[output_dram_offset * 2 + 1] = accumulator[7];
      }  // globalbuffer_0
    }  // dram_0
}
