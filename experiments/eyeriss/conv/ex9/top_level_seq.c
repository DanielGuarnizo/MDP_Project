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
    // seq (all-nounroll) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=4, P=4, Q=4, C=4, R=3, S=6;
    const int H=6, W=9;
    const int Ptiles=4, Qtiles=2;
    const int in_banks=2;

    // Accumulator: flat 1D at function scope → GCC SROA → 8 scalar regs
    DTYPE acc[8];

    // GlobalBuffer_0 = Q:2
    #pragma GCC nounroll
    for (int gb_0 = 0; gb_0 < 2; ++gb_0) {
      // GlobalBuffer_1 = P:4
      #pragma GCC nounroll
      for (int gb_1 = 0; gb_1 < 4; ++gb_1) {
        // Zero accumulator (nounroll — non-spatial init)
        #pragma GCC nounroll
        for (int _i = 0; _i < 8; ++_i) acc[_i] = 0.0f;

        // WRegister → C:2 (sequential)
        #pragma GCC nounroll
        for (int c_seq = 0; c_seq < 2; ++c_seq) {
          // WRegister → R:3 (sequential)
          #pragma GCC nounroll
          for (int r = 0; r < 3; ++r) {
            // SARows C:2 -- sequential (reduction)
            #pragma GCC nounroll
            for (int c = 0; c < 2; ++c) {
              int c_global = c_seq * 2 + c;
              int c_bank = c_global & 1;
              int c_blk  = c_global >> 1;
              int in_c_base = c_blk * (H * W);
              int q_base = gb_0 * 2;

              // SARows S:6
              #pragma GCC nounroll
              for (int s = 0; s < 6; ++s) {
                #pragma GCC nounroll
                for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {  // Q:2
                  #pragma GCC nounroll
                  for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {  // M:4
                    int w_idx = ((sacols_1) * ((C + in_banks - 1) / in_banks) + c_blk) * (R * S) + r * S + s;
                    DTYPE wv = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];
                    int in_row_base = in_c_base + (gb_1 + r) * W;
                    int in_col = q_base + sacols_0 + s;
                    DTYPE inv = (c_bank==0) ? dram_in_b0[in_row_base + in_col]
                                            : dram_in_b1[in_row_base + in_col];
                    acc[sacols_0*4 + sacols_1] += wv * inv;
                  }  // sacols_1 (M:4)
                }  // sacols_0 (Q:2)
              }  // s
            }  // c

          }  // inner seq
        }  // inner seq

        // OutRegister: write acc to banked output ports
        #pragma GCC nounroll 2
        for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
          #pragma GCC nounroll 4
          for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
            int out_bank = sacols_0*4 + sacols_1;
            int cm = 0;
            int cp = gb_1;
            int cq = gb_0;
            int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;
            DTYPE v = acc[sacols_0*4 + sacols_1];
            switch(out_bank) {
              case 0: dram_out_b0[out_idx_b] = v; break;
              case 1: dram_out_b1[out_idx_b] = v; break;
              case 2: dram_out_b2[out_idx_b] = v; break;
              case 3: dram_out_b3[out_idx_b] = v; break;
              case 4: dram_out_b4[out_idx_b] = v; break;
              case 5: dram_out_b5[out_idx_b] = v; break;
              case 6: dram_out_b6[out_idx_b] = v; break;
              case 7: dram_out_b7[out_idx_b] = v; break;
              default: break;
            }
          }
        }
      }  // outer_out
    }  // outer_out
}
