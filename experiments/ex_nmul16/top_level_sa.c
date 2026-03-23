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
    // SA-shaped Eyeriss CONV -- loop structure mirrors FF mapping hierarchy
    const int M=4, P=4, Q=4, C=4, R=3, S=3;
    const int H=6, W=6;
    const int m_sf=4, p_sf=1, q_sf=2;
    const int Ptiles=4, Qtiles=2;
    const int in_banks=2;

    // DRAM → Q:2
    for (int q_dram = 0; q_dram < 2; ++q_dram) {
      // GlobalBuffer → P:4
      for (int p_gb = 0; p_gb < 4; ++p_gb) {
        // Accumulator: acc[m_sf][q_sf] (p_sf=1, collapsed)
        DTYPE acc[4][2];
        #pragma GCC unroll 4
        for (int mi = 0; mi < 4; ++mi) {
          #pragma GCC unroll 2
          for (int qi = 0; qi < 2; ++qi) {
            acc[mi][qi] = 0.0f;
          }
        }

        // WRegister → R:3 (sequential)
        for (int r = 0; r < 3; ++r) {
          // SARows C:4 -- unrolled reduction (channels)
          #pragma GCC unroll 4
          for (int c = 0; c < 4; ++c) {
            int c_bank = c & 1;
            int c_blk  = c >> 1;  // c / in_banks
            int in_c_base = c_blk * (H * W);
            int q_base = q_dram * 2;
            // p_sf=1: p_base covers p_sf output rows per tile
            // SACols P lanes handled by pl loop below

            // SARows S:3 -- unrolled (filter cols)
            #pragma GCC unroll 3
            for (int s = 0; s < 3; ++s) {
              // SACols M:4 -- unrolled (output filter lanes)
              #pragma GCC unroll 4
              for (int ml = 0; ml < 4; ++ml) {
                int w_idx = (ml * (C / in_banks) + c_blk) * (R * S) + r * S + s;
                DTYPE wv = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];

                int in_row_base = in_c_base + (p_gb + r) * W;

                // SACols Q:2 -- unrolled (output col lanes)
                #pragma GCC unroll 2
                for (int ql = 0; ql < 2; ++ql) {
                  int in_col = q_base + ql + s;
                  DTYPE inv = (c_bank==0) ? dram_in_b0[in_row_base + in_col]
                                          : dram_in_b1[in_row_base + in_col];
                  acc[ml][ql] += wv * inv;
                }  // ql
              }  // ml
            }  // s
          }  // c

        }  // inner seq

        // OutRegister: write acc to banked output ports
        #pragma GCC unroll 4
        for (int ml = 0; ml < 4; ++ml) {
          #pragma GCC unroll 2
          for (int ql = 0; ql < 2; ++ql) {
            int out_bank = ml * 2 + ql;
            int cm = 0;
            int cp = p_gb;
            int cq = q_dram;
            int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;
            DTYPE v = acc[ml][ql];
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
          }  // ql
        }  // ml
      }  // outer
    }  // outer
}
