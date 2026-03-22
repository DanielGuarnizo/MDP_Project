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
    // SA-shaped Eyeriss CONV (write-only outputs)
    const int M=4, P=4, Q=4, C=4, R=3, S=3;
    const int H=6, W=6;
    const int m_sf=4, p_sf=1, q_sf=2;
    const int Ptiles=4, Qtiles=2;

    // DRAM level: Q tiles (q_sf==2 => Qtiles=Q/2)
    for (int q_dram = 0; q_dram < Qtiles; ++q_dram) {
      // GlobalBuffer level: P tiles (p_sf==1 => full P)
      for (int p = 0; p < P; ++p) {
        // SACols: compute M lanes x 2 q-lanes per tile
        DTYPE acc[4][2];
        #pragma HLS unroll
        for (int mi = 0; mi < 4; ++mi) {
          #pragma HLS unroll
          for (int qi = 0; qi < 2; ++qi) {
            acc[mi][qi] = 0.0f;
          }
        }

        // WRegister: R sequential (this is the best-performing setting you measured)
        for (int r = 0; r < R; ++r) {
          #pragma HLS unroll
          for (int c = 0; c < C; ++c) {
            int c_bank = c & 1;
            int c_blk  = c >> 1;
            int in_c_base  = c_blk * (H * W);
            int in_row_base = in_c_base + (p + r) * W;
            int q_base = q_dram * 2;  // global_q = q_base + q_lane

            #pragma HLS unroll
            for (int s = 0; s < S; ++s) {
              DTYPE in_q0 = (c_bank==0) ? dram_in_b0[in_row_base + (q_base + 0 + s)]
                                        : dram_in_b1[in_row_base + (q_base + 0 + s)];
              DTYPE in_q1 = (c_bank==0) ? dram_in_b0[in_row_base + (q_base + 1 + s)]
                                        : dram_in_b1[in_row_base + (q_base + 1 + s)];

              #pragma HLS unroll
              for (int m_lane = 0; m_lane < 4; ++m_lane) {
                int w_idx = (m_lane * (C/2) + c_blk) * (R * S) + r * S + s;
                DTYPE wv  = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];
                acc[m_lane][0] += wv * in_q0;
                acc[m_lane][1] += wv * in_q1;
              }
            }
          }
        }

        // OutRegister: write once per output (banked by lane_m and lane_q)
        for (int m_lane = 0; m_lane < 4; ++m_lane) {
          int lane_m = m_lane;
          int cm = 0;            // m_sf==M => cm always 0
          int cp = p;            // p_sf==1
          int cq = q_dram;       // q_sf==2
          int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;
          int out_bank0 = (lane_m * 1 + 0) * 2 + 0;
          int out_bank1 = (lane_m * 1 + 0) * 2 + 1;
          DTYPE v0 = acc[m_lane][0];
          DTYPE v1 = acc[m_lane][1];
          switch(out_bank0) {
            case 0: dram_out_b0[out_idx_b] = v0; break;
            case 1: dram_out_b1[out_idx_b] = v0; break;
            case 2: dram_out_b2[out_idx_b] = v0; break;
            case 3: dram_out_b3[out_idx_b] = v0; break;
            case 4: dram_out_b4[out_idx_b] = v0; break;
            case 5: dram_out_b5[out_idx_b] = v0; break;
            case 6: dram_out_b6[out_idx_b] = v0; break;
            case 7: dram_out_b7[out_idx_b] = v0; break;
            default: break;
          }
          switch(out_bank1) {
            case 0: dram_out_b0[out_idx_b] = v1; break;
            case 1: dram_out_b1[out_idx_b] = v1; break;
            case 2: dram_out_b2[out_idx_b] = v1; break;
            case 3: dram_out_b3[out_idx_b] = v1; break;
            case 4: dram_out_b4[out_idx_b] = v1; break;
            case 5: dram_out_b5[out_idx_b] = v1; break;
            case 6: dram_out_b6[out_idx_b] = v1; break;
            case 7: dram_out_b7[out_idx_b] = v1; break;
            default: break;
          }
        }
      }
    }
}
