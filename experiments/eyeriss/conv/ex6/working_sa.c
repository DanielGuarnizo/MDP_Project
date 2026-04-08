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
    // SA (weight-preload) Eyeriss CONV -- loop structure mirrors FF mapping hierarchy
    const int M=4, P=6, Q=6, C=4, R=3, S=1;
    const int H=8, W=6;
    const int m_sf=4, p_sf=1, q_sf=6;
    const int Ptiles=6, Qtiles=1;
    const int in_banks=2;

    // 96 PE accumulators: acc[c][m_row][q][m_col]
    // SARows: C:4 × M_row:2 = 8 rows;  SACols: Q:6 × M_col:2 = 12 cols
    // All 96 elements independent — no cross-PE RAW dependency.
    DTYPE acc[4][2][6][2];

    // DRAM → P:2
    #pragma GCC nounroll
    for (int p_dram = 0; p_dram < 2; ++p_dram) {
      // GlobalBuffer → P:3
      #pragma GCC nounroll
      for (int p_gb = 0; p_gb < 3; ++p_gb) {
        // Zero all 96 PE accumulators (nounroll — non-spatial init)
        #pragma GCC nounroll
        for (int c = 0; c < 4; ++c) {
          #pragma GCC nounroll
          for (int mr = 0; mr < 2; ++mr) {
            #pragma GCC nounroll
            for (int q = 0; q < 6; ++q) {
              #pragma GCC nounroll
              for (int mc = 0; mc < 2; ++mc) {
                acc[c][mr][q][mc] = 0.0f;
              }
            }
          }
        }

        // WRegister → R:3 (sequential)
        #pragma GCC nounroll
        for (int r = 0; r < 3; ++r) {
          // ---- Phase 1: preload weights for this r ----
          // w_tile[c][s][ml]: 4*1*4 = 16 elems.
          // GCC unroll c,s,ml + SROA → 16 scalar float regs.
          DTYPE w_tile[4][1][4];
          #pragma GCC unroll 4
          for (int c = 0; c < 4; ++c) {
            int c_bank = c & 1;
            int c_blk  = c >> 1;
            #pragma GCC unroll 1
            for (int s = 0; s < 1; ++s) {
              #pragma GCC unroll 4
              for (int ml = 0; ml < 4; ++ml) {
                int w_idx = (ml * ((C + in_banks - 1) / in_banks) + c_blk) * (R * S) + r * S + s;
                w_tile[c][s][ml] = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];
              }
            }
          }

          // ---- Phase 2a: multiply — all 96 ops independent, no acc dependency ----
          // Loop order c→s→ql→ml: inv loaded ONCE per (c,s,ql), reused for all ml.
          // AXI loads per r-iter: 96 → 24 (12 per bank).
          // p[4][1][4][6]: GCC SROA → scalar regs.
          DTYPE p[4][1][4][6];
          // SARows C:4 -- unrolled
          #pragma GCC unroll 4
          for (int c = 0; c < 4; ++c) {
            int c_bank = c & 1;
            int c_blk  = c >> 1;
            int in_row_base = c_blk * (H * W) + ((p_dram * 3 + p_gb) + r) * W;

            // SARows S:1
            #pragma GCC unroll 1
            for (int s = 0; s < 1; ++s) {
              // SACols Q:6 — one AXI load per ql, shared across all ml
              #pragma GCC unroll 6
              for (int ql = 0; ql < 6; ++ql) {
                DTYPE inv = (c_bank==0) ? dram_in_b0[in_row_base + ql + s]
                                        : dram_in_b1[in_row_base + ql + s];
                // SACols M:4 — 4 independent mults from same inv
                #pragma GCC unroll 4
                for (int ml = 0; ml < 4; ++ml) {
                  p[c][s][ml][ql] = w_tile[c][s][ml] * inv;
                }  // ml
              }  // ql
            }  // s
          }  // c

          // ---- Phase 2b: per-PE independent accumulation (96 independent updates) ----
          // Each PE (c, mr, q, mc) updates only its own acc element once per r-iter.
          // No cross-PE RAW dependency. ml = mr*2+mc maps to flat M index in p[].
          #pragma GCC unroll 4
          for (int c = 0; c < 4; ++c) {
            #pragma GCC unroll 2
            for (int mr = 0; mr < 2; ++mr) {
              #pragma GCC unroll 6
              for (int q = 0; q < 6; ++q) {
                #pragma GCC unroll 2
                for (int mc = 0; mc < 2; ++mc) {
                  acc[c][mr][q][mc] += p[c][0][mr * 2 + mc][q];
                }  // mc
              }  // q
            }  // mr
          }  // c

        }  // inner seq

        // ---- C-reduction: depth-2 tree over C=4, 24 independent outputs ----
        // Corresponds to the hardware column adder tree in the SA.
        // reduced[mr][q][mc] = sum_{c=0..3} acc[c][mr][q][mc]
        DTYPE reduced[2][6][2];
        #pragma GCC unroll 2
        for (int mr = 0; mr < 2; ++mr) {
          #pragma GCC unroll 6
          for (int q = 0; q < 6; ++q) {
            #pragma GCC unroll 2
            for (int mc = 0; mc < 2; ++mc) {
              DTYPE s01 = acc[0][mr][q][mc] + acc[1][mr][q][mc];
              DTYPE s23 = acc[2][mr][q][mc] + acc[3][mr][q][mc];
              reduced[mr][q][mc] = s01 + s23;
            }
          }
        }

        // OutRegister: write reduced values to banked output ports
        // out_bank = ml*6 + q,  ml = mr*2 + mc
        #pragma GCC unroll 2
        for (int mr = 0; mr < 2; ++mr) {
          #pragma GCC unroll 6
          for (int q = 0; q < 6; ++q) {
            #pragma GCC unroll 2
            for (int mc = 0; mc < 2; ++mc) {
              int out_bank = (mr * 2 + mc) * 6 + q;
              int out_idx_b = (p_dram * 3 + p_gb) * Qtiles + 0;
              DTYPE v = reduced[mr][q][mc];
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
            }  // mc
          }  // q
        }  // mr
      }  // outer
    }  // outer
}
