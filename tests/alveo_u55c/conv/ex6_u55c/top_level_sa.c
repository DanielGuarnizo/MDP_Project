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

// Internal scratchpads — filled once per top_level call from AXI ports
static DTYPE gb_weight[4][4][3][1];
static DTYPE gb_input[4][8][6];
void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_input_p2, DTYPE *dram_input_p3, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_weight_p2, DTYPE *dram_weight_p3, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7, DTYPE *dram_output_p8, DTYPE *dram_output_p9, DTYPE *dram_output_p10, DTYPE *dram_output_p11, DTYPE *dram_output_p12, DTYPE *dram_output_p13, DTYPE *dram_output_p14, DTYPE *dram_output_p15, DTYPE *dram_output_p16, DTYPE *dram_output_p17, DTYPE *dram_output_p18, DTYPE *dram_output_p19, DTYPE *dram_output_p20, DTYPE *dram_output_p21, DTYPE *dram_output_p22, DTYPE *dram_output_p23)
{
    // SA (weight-preload) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=4, P=6, Q=6, C=4, R=3, S=1;
    const int H=8, W=6;
    const int Ptiles=6, Qtiles=1;
    const int input_ports=4;

    // sarows_0 → SARows_0 = C:4
    // sacols_0 → SACols_0 = Q:6
    // sacols_1 → SACols_1 = M:4
    // 96 PE accumulators: accumulator[4][6][4]
    DTYPE accumulator[4][6][4];

    // ---- GlobalBuffer weight preload: wt_ideal = 4*4*3*1 AXI reads ----
    for (int _gm = 0; _gm < 4; ++_gm) {
      for (int _gc = 0; _gc < 4; ++_gc) {
        for (int _gr = 0; _gr < 3; ++_gr) {
          for (int _gs = 0; _gs < 1; ++_gs) {
            int weight_port_index = _gc % 4;
            int _cb = _gc / 4;
            int _wa = (_gm * ((4 + 4 - 1) / 4) + _cb) * (3 * 1) + _gr * 1 + _gs;
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

    // ---- GlobalBuffer input preload: in_ideal = 4*8*6 AXI reads ----
    for (int _gc = 0; _gc < 4; ++_gc) {
      for (int _gr = 0; _gr < 8; ++_gr) {
        for (int _gw = 0; _gw < 6; ++_gw) {
          int input_port_index = _gc % 4;
          int _cb = _gc / 4;
          int _ia = _cb * (8 * 6) + _gr * 6 + _gw;
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

    // DRAM_0 = P:6
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 6; ++dram_0) {
      // Zero 96 PE accumulators (nounroll — non-spatial init)
      #pragma GCC nounroll
      for (int sarows_0 = 0; sarows_0 < 4; ++sarows_0) {
        #pragma GCC nounroll
        for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {
          #pragma GCC nounroll
          for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
            accumulator[sarows_0][sacols_0][sacols_1] = 0.0f;
          }
        }
      }

      // WRegister → R:3 (sequential)
      #pragma GCC nounroll
      for (int wregister_0 = 0; wregister_0 < 3; ++wregister_0) {
        // ---- Phase 1: preload weights — 16 elems, no Q loop ----
        // weight_tile[4][4]: level-indexed, Q absent (weight is Q-independent)
        DTYPE weight_tile[4][4];
        #pragma GCC unroll 4
        for (int sarows_0 = 0; sarows_0 < 4; ++sarows_0) {
          #pragma GCC unroll 4
          for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
            int global_channel_index = (sarows_0);
            weight_tile[sarows_0][sacols_1] = gb_weight[(sacols_1)][global_channel_index][wregister_0][0];
          }  // sacols_1 (preload)
        }  // sarows_0 (preload)

        // ---- Phase 2a: multiply — 96 independent products ----
        // product[4][6][4]: GCC SROA → 96 scalar float regs
        DTYPE product[4][6][4];
        int output_col_base = 0;
        #pragma GCC unroll 4
        for (int sarows_0 = 0; sarows_0 < 4; ++sarows_0) {  // C:4
          #pragma GCC unroll 6
          for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {  // Q:6
            #pragma GCC unroll 4
            for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {  // M:4
              int global_channel_index = (sarows_0);
              int input_col = output_col_base + sacols_0 + 0;
              DTYPE weight_value = weight_tile[sarows_0][sacols_1];
              DTYPE input_value = gb_input[global_channel_index][(dram_0 + wregister_0)][input_col];
              product[sarows_0][sacols_0][sacols_1] = weight_value * input_value;
            }  // sacols_1 (M:4)
          }  // sacols_0 (Q:6)
        }  // sarows_0 (C:4)

        // ---- Phase 2b: accumulate — 96 independent, no RAW chain ----
        #pragma GCC unroll 4
        for (int sarows_0 = 0; sarows_0 < 4; ++sarows_0) {
          #pragma GCC unroll 6
          for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {
            #pragma GCC unroll 4
            for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
              accumulator[sarows_0][sacols_0][sacols_1] += product[sarows_0][sacols_0][sacols_1];
            }  // sacols_1
          }  // sacols_0
        }  // sarows_0

      }  // wregister_0

      // ---- reduction: 96 acc → 24 outputs (4 inputs each) ----
      DTYPE reduced_output[6][4];
      #pragma GCC unroll 6
      for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {
        #pragma GCC unroll 4
        for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
          DTYPE partial_sum_0_0 = accumulator[0][sacols_0][sacols_1] + accumulator[1][sacols_0][sacols_1];
          DTYPE partial_sum_0_1 = accumulator[2][sacols_0][sacols_1] + accumulator[3][sacols_0][sacols_1];
          DTYPE partial_sum_1_0 = partial_sum_0_0 + partial_sum_0_1;
          reduced_output[sacols_0][sacols_1] = partial_sum_1_0;
        }  // sacols_1 (reduction)
      }  // sacols_0 (reduction)

      // OutRegister: write 24 outputs to 24 port(s), folding=1
      int output_filter_tile = 0;
      int output_row_tile = dram_0;
      int output_col_tile = 0;
      int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;
      dram_output_p0[output_dram_offset] = reduced_output[0][0];
      dram_output_p1[output_dram_offset] = reduced_output[0][1];
      dram_output_p2[output_dram_offset] = reduced_output[0][2];
      dram_output_p3[output_dram_offset] = reduced_output[0][3];
      dram_output_p4[output_dram_offset] = reduced_output[1][0];
      dram_output_p5[output_dram_offset] = reduced_output[1][1];
      dram_output_p6[output_dram_offset] = reduced_output[1][2];
      dram_output_p7[output_dram_offset] = reduced_output[1][3];
      dram_output_p8[output_dram_offset] = reduced_output[2][0];
      dram_output_p9[output_dram_offset] = reduced_output[2][1];
      dram_output_p10[output_dram_offset] = reduced_output[2][2];
      dram_output_p11[output_dram_offset] = reduced_output[2][3];
      dram_output_p12[output_dram_offset] = reduced_output[3][0];
      dram_output_p13[output_dram_offset] = reduced_output[3][1];
      dram_output_p14[output_dram_offset] = reduced_output[3][2];
      dram_output_p15[output_dram_offset] = reduced_output[3][3];
      dram_output_p16[output_dram_offset] = reduced_output[4][0];
      dram_output_p17[output_dram_offset] = reduced_output[4][1];
      dram_output_p18[output_dram_offset] = reduced_output[4][2];
      dram_output_p19[output_dram_offset] = reduced_output[4][3];
      dram_output_p20[output_dram_offset] = reduced_output[5][0];
      dram_output_p21[output_dram_offset] = reduced_output[5][1];
      dram_output_p22[output_dram_offset] = reduced_output[5][2];
      dram_output_p23[output_dram_offset] = reduced_output[5][3];
    }  // dram_0
}
