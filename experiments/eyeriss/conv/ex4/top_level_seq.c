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

void top_level(DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7, DTYPE *dram_out_b8, DTYPE *dram_out_b9, DTYPE *dram_out_b10, DTYPE *dram_out_b11, DTYPE *dram_out_b12, DTYPE *dram_out_b13, DTYPE *dram_out_b14, DTYPE *dram_out_b15)
{
    // seq (all-nounroll) Eyeriss CONV -- loop structure mirrors FF mapping hierarchy
    const int M=4, P=4, Q=4, C=4, R=1, S=1;
    const int H=4, W=4;
    const int Ptiles=4, Qtiles=1;
    const int in_banks=2;

    // Accumulator: flat 1D at function scope → GCC SROA → 16 scalar regs
    DTYPE acc[16];

    // GlobalBuffer → P:4
    #pragma GCC nounroll
    for (int p_gb = 0; p_gb < 4; ++p_gb) {
      // Zero accumulator (nounroll — non-spatial init)
      #pragma GCC nounroll
      for (int _i = 0; _i < 16; ++_i) acc[_i] = 0.0f;

      int r = 0;  // R=1 or no inner sequential R loop
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
            for (int sacols_0 = 0; sacols_0 < 4; ++sacols_0) {  // Q:4
              #pragma GCC nounroll
              for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {  // M:2
                int w_idx = ((sarows_1*2 + sacols_1) * ((C + in_banks - 1) / in_banks) + c_blk) * (R * S) + r * S + s;
                DTYPE wv = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];
                int in_row_base = in_c_base + (p_gb + r) * W;
                int in_col = q_base + sacols_0 + s;
                DTYPE inv = (c_bank==0) ? dram_in_b0[in_row_base + in_col]
                                        : dram_in_b1[in_row_base + in_col];
                acc[sarows_1*8 + sacols_0*2 + sacols_1] += wv * inv;
              }  // sacols_1 (M:2)
            }  // sacols_0 (Q:4)
          }  // sarows_1 (M:2)
        }  // s
      }  // c


      // OutRegister: write acc to banked output ports
      #pragma GCC nounroll
      for (int sarows_1 = 0; sarows_1 < 2; ++sarows_1) {
        #pragma GCC nounroll
        for (int sacols_0 = 0; sacols_0 < 4; ++sacols_0) {
          #pragma GCC nounroll
          for (int sacols_1 = 0; sacols_1 < 2; ++sacols_1) {
            int out_bank = sarows_1*8 + sacols_0*2 + sacols_1;
            int cm = 0;
            int cp = p_gb;
            int cq = 0;
            int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;
            DTYPE v = acc[sarows_1*8 + sacols_0*2 + sacols_1];
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
              default: break;
            }
          }
        }
      }
    }  // outer
}
