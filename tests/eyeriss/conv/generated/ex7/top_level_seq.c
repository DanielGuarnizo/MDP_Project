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
#pragma HLS interface port = dram_out_b8 mode = m_axi offset = direct bundle = gmem_out8
#pragma HLS interface port = dram_out_b9 mode = m_axi offset = direct bundle = gmem_out9

void top_level(DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7, DTYPE *dram_out_b8, DTYPE *dram_out_b9)
{
    // seq (all-nounroll) Eyeriss CONV — loop structure mirrors FF mapping hierarchy
    const int M=100, P=100, Q=100, C=100, R=16, S=16;
    const int H=115, W=115;
    const int Ptiles=100, Qtiles=50;
    const int in_banks=2;

    // Accumulator: flat 1D at function scope → GCC SROA → 10 scalar regs
    DTYPE acc[10];

    // DRAM_0 = Q:5
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 5; ++dram_0) {
      // DRAM_1 = M:2
      #pragma GCC nounroll
      for (int dram_1 = 0; dram_1 < 2; ++dram_1) {
        // GlobalBuffer_1 = Q:10
        #pragma GCC nounroll
        for (int gb_1 = 0; gb_1 < 10; ++gb_1) {
          // GlobalBuffer_2 = P:100
          #pragma GCC nounroll
          for (int gb_2 = 0; gb_2 < 100; ++gb_2) {
            // OutRegister_0 = M:10
            #pragma GCC nounroll
            for (int or_0 = 0; or_0 < 10; ++or_0) {
              // Zero accumulator (nounroll — non-spatial init)
              #pragma GCC nounroll
              for (int _i = 0; _i < 10; ++_i) acc[_i] = 0.0f;

              // DRAM_2 = C:20
              #pragma GCC nounroll
              for (int dram_2 = 0; dram_2 < 20; ++dram_2) {
                // GlobalBuffer_0 = S:8
                #pragma GCC nounroll
                for (int gb_0 = 0; gb_0 < 8; ++gb_0) {
                  // WRegister → R:16 (sequential)
                  #pragma GCC nounroll
                  for (int r = 0; r < 16; ++r) {
                    // SARows C:5 -- sequential (reduction)
                    #pragma GCC nounroll
                    for (int c = 0; c < 5; ++c) {
                      int c_global = dram_2 * 5 + c;
                      int c_bank = c_global & 1;
                      int c_blk  = c_global >> 1;
                      int in_c_base = c_blk * (H * W);
                      int q_base = (dram_0 * 10 + gb_1) * 2;

                      // SARows S:2
                      #pragma GCC nounroll
                      for (int s = 0; s < 2; ++s) {
                        #pragma GCC nounroll
                        for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {  // Q:2
                          #pragma GCC nounroll
                          for (int sacols_1 = 0; sacols_1 < 5; ++sacols_1) {  // M:5
                            int w_idx = ((((dram_1 * 10 + or_0) * 5 + (sacols_1))) * ((C + in_banks - 1) / in_banks) + c_blk) * (R * S) + r * S + (gb_0 * 2 + s);
                            DTYPE wv = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];
                            int in_row_base = in_c_base + (gb_2 + r) * W;
                            int in_col = q_base + sacols_0 + (gb_0 * 2 + s);
                            DTYPE inv = (c_bank==0) ? dram_in_b0[in_row_base + in_col]
                                                    : dram_in_b1[in_row_base + in_col];
                            acc[sacols_0*5 + sacols_1] += wv * inv;
                          }  // sacols_1 (M:5)
                        }  // sacols_0 (Q:2)
                      }  // s
                    }  // c

                  }  // inner seq

                }  // outer_red
              }  // outer_red

              // OutRegister: write acc to banked output ports
              #pragma GCC nounroll 2
              for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
                #pragma GCC nounroll 5
                for (int sacols_1 = 0; sacols_1 < 5; ++sacols_1) {
                  int out_bank = sacols_0*5 + sacols_1;
                  int cm = (dram_1 * 10 + or_0);
                  int cp = gb_2;
                  int cq = (dram_0 * 10 + gb_1);
                  int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;
                  DTYPE v = acc[sacols_0*5 + sacols_1];
                  switch(out_bank) {
                    case 0: dram_out_b0[out_idx_b] = v; break;
                    case 1: dram_out_b1[out_idx_b] = v; break;
                    case 2: dram_out_b2[out_idx_b] = v; break;
                    case 3: dram_out_b3[out_idx_b] = v; break;
                    case 4: dram_out_b4[out_idx_b] = v; break;
                    case 5: dram_out_b5[out_idx_b] = v; break;
                    case 6: dram_out_b6[out_idx_b] = v; break;
                    case 7: dram_out_b7[out_idx_b] = v; break;
                    case 8: dram_out_b8[out_idx_b] = v; break;
                    case 9: dram_out_b9[out_idx_b] = v; break;
                    default: break;
                  }
                }
              }
            }  // outer_out
          }  // outer_out
        }  // outer_out
      }  // outer_out
    }  // outer_out
}
