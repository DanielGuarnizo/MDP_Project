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

void top_level(DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7) {
    // ---- CONV kernel (banked in/w/out, Bambu-safe; write-only outputs) ----
    const int M = 4, P = 4, Q = 4, C = 4, R = 3, S = 3;
    const int H = 6, W = 6;
    const int m_sf = 4, p_sf = 1, q_sf = 2;
    const int Ptiles = 4, Qtiles = 2;

    if (q_sf == 2) {
      // Accumulate full output in local buffer (write outputs once at the end)
      for (int m = 0; m < M; ++m) {
        int lane_m = (m_sf==1)?0:(m % m_sf);
        int cm     = (m_sf==1)?m:(m / m_sf);

        DTYPE acc_buf[4][4];
        for (int p = 0; p < P; ++p) {
          for (int q = 0; q < Q; ++q) acc_buf[p][q] = 0.0f;
        }

        for (int c = 0; c < C; ++c) {
          int c_bank = c & 1;
          int c_blk  = c >> 1;
          int in_c_base = c_blk * (H * W);
          int w_mc_base = (m * (C/2) + c_blk) * (R * S);

          // Cache weights w_local[r][s] for this (m,c)
          DTYPE w_local[3][3];
          for (int r = 0; r < R; ++r) {
            for (int s = 0; s < S; ++s) {
              int w_idx = w_mc_base + r * S + s;
              w_local[r][s] = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];
            }
          }

          for (int p = 0; p < P; ++p) {
            for (int q0 = 0; q0 < Q; q0 += 2) {
              int q1 = q0 + 1;
              // If q1 exists, compute both
              if (q1 < Q) {
                for (int r = 0; r < R; ++r) {
                  int in_row_base = in_c_base + (p + r) * W;
                  for (int s = 0; s < S; ++s) {
                    DTYPE wv = w_local[r][s];
                    DTYPE in0 = (c_bank==0) ? dram_in_b0[in_row_base + (q0 + s)] : dram_in_b1[in_row_base + (q0 + s)];
                    DTYPE in1 = (c_bank==0) ? dram_in_b0[in_row_base + (q1 + s)] : dram_in_b1[in_row_base + (q1 + s)];
                    acc_buf[p][q0] += wv * in0;
                    acc_buf[p][q1] += wv * in1;
                  }
                }
              } else {
                // tail: only q0 valid
                for (int r = 0; r < R; ++r) {
                  int in_row_base = in_c_base + (p + r) * W;
                  for (int s = 0; s < S; ++s) {
                    DTYPE wv = w_local[r][s];
                    DTYPE in0 = (c_bank==0) ? dram_in_b0[in_row_base + (q0 + s)] : dram_in_b1[in_row_base + (q0 + s)];
                    acc_buf[p][q0] += wv * in0;
                  }
                }
              }
            }
          }
        }

        for (int p = 0; p < P; ++p) {
          int lane_p = (p_sf==1)?0:(p % p_sf);
          int cp     = (p_sf==1)?p:(p / p_sf);
          for (int q0 = 0; q0 < Q; q0 += 2) {
            int q1 = q0 + 1;
            int cq = q0 / 2;
            int out_idx_b = (cm*Ptiles + cp)*Qtiles + cq;
            int out_bank0 = (lane_m*p_sf + lane_p)*2 + 0;
            int out_bank1 = (lane_m*p_sf + lane_p)*2 + 1;

            DTYPE acc0 = acc_buf[p][q0];
            switch(out_bank0) {
              case 0: dram_out_b0[out_idx_b] = acc0; break;
              case 1: dram_out_b1[out_idx_b] = acc0; break;
              case 2: dram_out_b2[out_idx_b] = acc0; break;
              case 3: dram_out_b3[out_idx_b] = acc0; break;
              case 4: dram_out_b4[out_idx_b] = acc0; break;
              case 5: dram_out_b5[out_idx_b] = acc0; break;
              case 6: dram_out_b6[out_idx_b] = acc0; break;
              case 7: dram_out_b7[out_idx_b] = acc0; break;
              default: break;
            }

            if (q1 < Q) {
              DTYPE acc1 = acc_buf[p][q1];
              switch(out_bank1) {
                case 0: dram_out_b0[out_idx_b] = acc1; break;
                case 1: dram_out_b1[out_idx_b] = acc1; break;
                case 2: dram_out_b2[out_idx_b] = acc1; break;
                case 3: dram_out_b3[out_idx_b] = acc1; break;
                case 4: dram_out_b4[out_idx_b] = acc1; break;
                case 5: dram_out_b5[out_idx_b] = acc1; break;
                case 6: dram_out_b6[out_idx_b] = acc1; break;
                case 7: dram_out_b7[out_idx_b] = acc1; break;
                default: break;
              }
            }
          }
        }
      }
    } else {
      for (int m = 0; m < M; ++m) {
        int lane_m = (m_sf==1)?0:(m % m_sf);
        int cm     = (m_sf==1)?m:(m / m_sf);

        DTYPE acc_buf[4][4];
        for (int p = 0; p < P; ++p) {
          for (int q = 0; q < Q; ++q) acc_buf[p][q] = 0.0f;
        }

        for (int c = 0; c < C; ++c) {
          int c_bank = c & 1;
          int c_blk  = c >> 1;
          int in_c_base = c_blk * (H * W);
          int w_mc_base = (m * (C/2) + c_blk) * (R * S);

          DTYPE w_local[3][3];
          for (int r = 0; r < R; ++r) {
            for (int s = 0; s < S; ++s) {
              int w_idx = w_mc_base + r * S + s;
              w_local[r][s] = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];
            }
          }

          for (int p = 0; p < P; ++p) {
            for (int q = 0; q < Q; ++q) {
              for (int r = 0; r < R; ++r) {
                int in_row_base = in_c_base + (p + r) * W;
                for (int s = 0; s < S; ++s) {
                  DTYPE wv = w_local[r][s];
                  DTYPE in_v = (c_bank==0) ? dram_in_b0[in_row_base + (q + s)] : dram_in_b1[in_row_base + (q + s)];
                  acc_buf[p][q] += wv * in_v;
                }
              }
            }
          }
        }

        for (int p = 0; p < P; ++p) {
          int lane_p = (p_sf==1)?0:(p % p_sf);
          int cp     = (p_sf==1)?p:(p / p_sf);
          for (int q = 0; q < Q; ++q) {
            int lane_q = (q_sf==1)?0:(q % q_sf);
            int out_bank = (lane_m*p_sf + lane_p)*q_sf + lane_q;
            int cq = (q_sf==1)?q:(q / q_sf);
            int out_idx_b = (cm*Ptiles + cp)*Qtiles + cq;
            DTYPE acc = acc_buf[p][q];
            switch(out_bank) {
              case 0: dram_out_b0[out_idx_b] = acc; break;
              case 1: dram_out_b1[out_idx_b] = acc; break;
              case 2: dram_out_b2[out_idx_b] = acc; break;
              case 3: dram_out_b3[out_idx_b] = acc; break;
              case 4: dram_out_b4[out_idx_b] = acc; break;
              case 5: dram_out_b5[out_idx_b] = acc; break;
              case 6: dram_out_b6[out_idx_b] = acc; break;
              case 7: dram_out_b7[out_idx_b] = acc; break;
              default: break;
            }
          }
        }
      }
    }
}
