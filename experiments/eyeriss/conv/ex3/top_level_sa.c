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
    // SA (weight-preload) Eyeriss CONV -- loop structure mirrors FF mapping hierarchy
    const int M=4, P=4, Q=4, C=3, R=3, S=3;
    const int H=6, W=6;
    const int Ptiles=4, Qtiles=2;
    const int in_banks=2;

    // sarows_0 → SARows_0 = S:3
    // sarows_1 → SARows_1 = C:3
    // sacols_0 → SACols_0 = Q:2
    // sacols_1 → SACols_1 = M:4
    // 72 PE accumulators: acc[3][3][2][4]
    DTYPE acc[3][3][2][4];

    // DRAM → Q:2
    #pragma GCC nounroll
    for (int q_dram = 0; q_dram < 2; ++q_dram) {
      // GlobalBuffer → P:4
      #pragma GCC nounroll
      for (int p_gb = 0; p_gb < 4; ++p_gb) {
        // Zero 72 PE accumulators (nounroll — non-spatial init)
        #pragma GCC nounroll
        for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
          #pragma GCC nounroll
          for (int sarows_1 = 0; sarows_1 < 3; ++sarows_1) {
            #pragma GCC nounroll
            for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
              #pragma GCC nounroll
              for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
                acc[sarows_0][sarows_1][sacols_0][sacols_1] = 0.0f;
              }
            }
          }
        }

        // WRegister → R:3 (sequential)
        #pragma GCC nounroll
        for (int r = 0; r < 3; ++r) {
          // ---- Phase 1: preload weights — 36 elems, no Q loop ----
          // w_tile[3][3][4]: level-indexed, Q absent (weight is Q-independent)
          DTYPE w_tile[3][3][4];
          #pragma GCC unroll 3
          for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
            #pragma GCC unroll 3
            for (int sarows_1 = 0; sarows_1 < 3; ++sarows_1) {
              #pragma GCC unroll 4
              for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
                int c_global = (sarows_1);
                int c_bank = c_global & 1;
                int c_blk  = c_global >> 1;
                int w_idx = ((sacols_1) * ((C + in_banks - 1) / in_banks) + c_blk) * (R * S) + r * S + sarows_0;
                w_tile[sarows_0][sarows_1][sacols_1] = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];
              }  // sacols_1 (preload)
            }  // sarows_1 (preload)
          }  // sarows_0 (preload)

          // ---- Phase 2a: multiply — 72 independent products ----
          // p[3][3][2][4]: GCC SROA → 72 scalar float regs
          DTYPE p[3][3][2][4];
          int q_base = q_dram * 2;
          #pragma GCC unroll 3
          for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {  // S:3
            #pragma GCC unroll 3
            for (int sarows_1 = 0; sarows_1 < 3; ++sarows_1) {  // C:3
              #pragma GCC unroll 2
              for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {  // Q:2
                #pragma GCC unroll 4
                for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {  // M:4
                  int c_global = (sarows_1);
                  int c_bank = c_global & 1;
                  int c_blk  = c_global >> 1;
                  int in_c_base = c_blk * (H * W);
                  int in_row_base = in_c_base + (p_gb + r) * W;
                  int in_col = q_base + sacols_0 + sarows_0;
                  DTYPE wv = w_tile[sarows_0][sarows_1][sacols_1];
                  DTYPE inv = (c_bank==0) ? dram_in_b0[in_row_base + in_col]
                                          : dram_in_b1[in_row_base + in_col];
                  p[sarows_0][sarows_1][sacols_0][sacols_1] = wv * inv;
                }  // sacols_1 (M:4)
              }  // sacols_0 (Q:2)
            }  // sarows_1 (C:3)
          }  // sarows_0 (S:3)

          // ---- Phase 2b: accumulate — 72 independent, no RAW chain ----
          #pragma GCC unroll 3
          for (int sarows_0 = 0; sarows_0 < 3; ++sarows_0) {
            #pragma GCC unroll 3
            for (int sarows_1 = 0; sarows_1 < 3; ++sarows_1) {
              #pragma GCC unroll 2
              for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
                #pragma GCC unroll 4
                for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
                  acc[sarows_0][sarows_1][sacols_0][sacols_1] += p[sarows_0][sarows_1][sacols_0][sacols_1];
                }  // sacols_1
              }  // sacols_0
            }  // sarows_1
          }  // sarows_0

        }  // inner seq

        // ---- reduction: 72 acc → 8 outputs (9 inputs each) ----
        DTYPE reduced[2][4];
        #pragma GCC unroll 2
        for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
          #pragma GCC unroll 4
          for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
            DTYPE _t0_0 = acc[0][0][sacols_0][sacols_1] + acc[0][1][sacols_0][sacols_1];
            DTYPE _t0_1 = acc[0][2][sacols_0][sacols_1] + acc[1][0][sacols_0][sacols_1];
            DTYPE _t0_2 = acc[1][1][sacols_0][sacols_1] + acc[1][2][sacols_0][sacols_1];
            DTYPE _t0_3 = acc[2][0][sacols_0][sacols_1] + acc[2][1][sacols_0][sacols_1];
            DTYPE _t1_0 = _t0_0 + _t0_1;
            DTYPE _t1_1 = _t0_2 + _t0_3;
            DTYPE _t2_0 = _t1_0 + _t1_1;
            DTYPE _t3_0 = _t2_0 + acc[2][2][sacols_0][sacols_1];
            reduced[sacols_0][sacols_1] = _t3_0;
          }  // sacols_1 (reduction)
        }  // sacols_0 (reduction)

        // OutRegister: write acc to banked output ports
        #pragma GCC unroll 2
        for (int sacols_0 = 0; sacols_0 < 2; ++sacols_0) {
          #pragma GCC unroll 4
          for (int sacols_1 = 0; sacols_1 < 4; ++sacols_1) {
            int out_bank = sacols_0*4 + sacols_1;
            int cm = 0;
            int cp = p_gb;
            int cq = q_dram;
            int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;
            DTYPE v = reduced[sacols_0][sacols_1];
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
      }  // outer
    }  // outer
}
