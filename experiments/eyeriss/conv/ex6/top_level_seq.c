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
#pragma HLS interface port = dram_out_b10 mode = m_axi offset = direct bundle = gmem_out10
#pragma HLS interface port = dram_out_b11 mode = m_axi offset = direct bundle = gmem_out11
#pragma HLS interface port = dram_out_b12 mode = m_axi offset = direct bundle = gmem_out12
#pragma HLS interface port = dram_out_b13 mode = m_axi offset = direct bundle = gmem_out13
#pragma HLS interface port = dram_out_b14 mode = m_axi offset = direct bundle = gmem_out14
#pragma HLS interface port = dram_out_b15 mode = m_axi offset = direct bundle = gmem_out15
#pragma HLS interface port = dram_out_b16 mode = m_axi offset = direct bundle = gmem_out16
#pragma HLS interface port = dram_out_b17 mode = m_axi offset = direct bundle = gmem_out17
#pragma HLS interface port = dram_out_b18 mode = m_axi offset = direct bundle = gmem_out18
#pragma HLS interface port = dram_out_b19 mode = m_axi offset = direct bundle = gmem_out19
#pragma HLS interface port = dram_out_b20 mode = m_axi offset = direct bundle = gmem_out20
#pragma HLS interface port = dram_out_b21 mode = m_axi offset = direct bundle = gmem_out21
#pragma HLS interface port = dram_out_b22 mode = m_axi offset = direct bundle = gmem_out22
#pragma HLS interface port = dram_out_b23 mode = m_axi offset = direct bundle = gmem_out23

void top_level(DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7, DTYPE *dram_out_b8, DTYPE *dram_out_b9, DTYPE *dram_out_b10, DTYPE *dram_out_b11, DTYPE *dram_out_b12, DTYPE *dram_out_b13, DTYPE *dram_out_b14, DTYPE *dram_out_b15, DTYPE *dram_out_b16, DTYPE *dram_out_b17, DTYPE *dram_out_b18, DTYPE *dram_out_b19, DTYPE *dram_out_b20, DTYPE *dram_out_b21, DTYPE *dram_out_b22, DTYPE *dram_out_b23)
{
    // seq (all-nounroll) Eyeriss CONV -- loop structure mirrors FF mapping hierarchy
    const int M=4, P=6, Q=6, C=4, R=3, S=1;
    const int H=8, W=6;
    const int Ptiles=6, Qtiles=1;
    const int in_banks=2;

    // Accumulator: flat 1D at function scope → GCC SROA → 24 scalar regs
    DTYPE acc[24];

    // DRAM_0 = P:2
    #pragma GCC nounroll
    for (int dram_0 = 0; dram_0 < 2; ++dram_0) {
      // GlobalBuffer_0 = P:3
      #pragma GCC nounroll
      for (int gb_0 = 0; gb_0 < 3; ++gb_0) {
        // Zero accumulator (nounroll — non-spatial init)
        #pragma GCC nounroll
        for (int _i = 0; _i < 24; ++_i) acc[_i] = 0.0f;

        // WRegister → R:3 (sequential)
        #pragma GCC nounroll
        for (int r = 0; r < 3; ++r) {
          // SARows C:4 -- sequential (reduction)
          #pragma GCC nounroll
          for (int c = 0; c < 4; ++c) {
            int c_bank = c & 1;
            int c_blk  = c >> 1;
            int in_c_base = c_blk * (H * W);
            int q_base = 0;

            // SARows S:1
            #pragma GCC nounroll
            for (int s = 0; s < 1; ++s) {
              #pragma GCC nounroll
              for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {  // M:2
                #pragma GCC nounroll
                for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {  // Q:6
                  #pragma GCC nounroll
                  for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {  // M:2
                    int w_idx = ((sarows_1*2 + sacols_1) * ((C + in_banks - 1) / in_banks) + c_blk) * (R * S) + r * S + s;
                    DTYPE wv = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];
                    int in_row_base = in_c_base + ((dram_0 * 3 + gb_0) + r) * W;
                    int in_col = q_base + sacols_0 + s;
                    DTYPE inv = (c_bank==0) ? dram_in_b0[in_row_base + in_col]
                                            : dram_in_b1[in_row_base + in_col];
                    acc[sarows_1*12 + sacols_0*2 + sacols_1] += wv * inv;
                  }  // sacols_1 (M:2)
                }  // sacols_0 (Q:6)
              }  // sarows_1 (M:2)
            }  // s
          }  // c

        }  // inner seq

        // OutRegister: write acc to banked output ports
        #pragma GCC nounroll
        for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
          #pragma GCC nounroll
          for (int sacols_0 = 0; sacols_0 < 6; ++sacols_0) {
            #pragma GCC nounroll
            for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
              int out_bank = sarows_1*12 + sacols_0*2 + sacols_1;
              int cm = 0;
              int cp = (dram_0 * 3 + gb_0);
              int cq = 0;
              int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;
              DTYPE v = acc[sarows_1*12 + sacols_0*2 + sacols_1];
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
                case 10: dram_out_b10[out_idx_b] = v; break;
                case 11: dram_out_b11[out_idx_b] = v; break;
                case 12: dram_out_b12[out_idx_b] = v; break;
                case 13: dram_out_b13[out_idx_b] = v; break;
                case 14: dram_out_b14[out_idx_b] = v; break;
                case 15: dram_out_b15[out_idx_b] = v; break;
                case 16: dram_out_b16[out_idx_b] = v; break;
                case 17: dram_out_b17[out_idx_b] = v; break;
                case 18: dram_out_b18[out_idx_b] = v; break;
                case 19: dram_out_b19[out_idx_b] = v; break;
                case 20: dram_out_b20[out_idx_b] = v; break;
                case 21: dram_out_b21[out_idx_b] = v; break;
                case 22: dram_out_b22[out_idx_b] = v; break;
                case 23: dram_out_b23[out_idx_b] = v; break;
                default: break;
              }
            }
          }
        }
      }  // outer_out
    }  // outer_out
}
