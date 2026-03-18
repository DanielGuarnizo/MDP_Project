#define DTYPE float
#define M_TOTAL 4
#define P_TOTAL 4
#define Q_TOTAL 4
#define C_TOTAL 4
#define R_TOTAL 3
#define S_TOTAL 3


// --- HARDWARE KERNEL (top_level) ---
void top_level(DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7) {
    // ---- CONV kernel (banked in/w/out, Bambu-safe; write-only outputs) ----
    const int M = 4, P = 4, Q = 4, C = 4, R = 3, S = 3;
    const int H = 6, W = 6;
    const int m_sf = 4, p_sf = 1, q_sf = 2;
    const int Ptiles = 4, Qtiles = 2;

    if (q_sf == 2) {
      for (int m = 0; m < M; ++m) {
        int lane_m = (m_sf==1)?0:(m % m_sf);
        int cm     = (m_sf==1)?m:(m / m_sf);
        for (int p = 0; p < P; ++p) {
          int lane_p = (p_sf==1)?0:(p % p_sf);
          int cp     = (p_sf==1)?p:(p / p_sf);
          for (int q0 = 0; q0 < Q; q0 += 2) {
            int q1 = q0 + 1;
            int cq = q0 / 2;  // since q_sf==2
            int out_idx_b = (cm*Ptiles + cp)*Qtiles + cq;
            int out_bank0 = (lane_m*p_sf + lane_p)*2 + 0;
            int out_bank1 = (lane_m*p_sf + lane_p)*2 + 1;

            DTYPE acc0 = 0.0f;
            DTYPE acc1 = 0.0f;

            for (int c = 0; c < C; ++c) {
              int c_bank = c & 1;
              int c_blk  = c >> 1;
              int in_c_base = c_blk * (H * W);
              int w_mc_base = (m * (C/2) + c_blk) * (R * S);

              if (q1 < Q) {
                for (int r = 0; r < R; ++r) {
                  int in_row_base = in_c_base + (p + r) * W;
                  int w_r_base    = w_mc_base + r * S;

                  for (int s = 0; s < S; ++s) {
                    int w_idx = w_r_base + s;
                    DTYPE wv  = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];
                    DTYPE in0 = (c_bank==0) ? dram_in_b0[in_row_base + (q0 + s)] : dram_in_b1[in_row_base + (q0 + s)];
                    DTYPE in1 = (c_bank==0) ? dram_in_b0[in_row_base + (q1 + s)] : dram_in_b1[in_row_base + (q1 + s)];
                    acc0 += wv * in0;
                    acc1 += wv * in1;
                  }
                }
              } else {
                // tail: only q0 valid
                for (int r = 0; r < R; ++r) {
                  int in_row_base = in_c_base + (p + r) * W;
                  int w_r_base    = w_mc_base + r * S;
                  for (int s = 0; s < S; ++s) {
                    int w_idx = w_r_base + s;
                    DTYPE wv  = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];
                    DTYPE in0 = (c_bank==0) ? dram_in_b0[in_row_base + (q0 + s)] : dram_in_b1[in_row_base + (q0 + s)];
                    acc0 += wv * in0;
                  }
                }
              }
            }

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
        for (int p = 0; p < P; ++p) {
          for (int q = 0; q < Q; ++q) {
            int lane_m = (m_sf==1)?0:(m % m_sf);
            int lane_p = (p_sf==1)?0:(p % p_sf);
            int lane_q = (q_sf==1)?0:(q % q_sf);
            int out_bank = (lane_m*p_sf + lane_p)*q_sf + lane_q;
            int cm = (m_sf==1)?m:(m / m_sf);
            int cp = (p_sf==1)?p:(p / p_sf);
            int cq = (q_sf==1)?q:(q / q_sf);
            int out_idx_b = (cm*Ptiles + cp)*Qtiles + cq;
            DTYPE acc = 0.0f;
            for (int c = 0; c < C; ++c) {
              int c_bank = c & 1;
              int c_blk  = c >> 1;
              for (int r = 0; r < R; ++r) {
                for (int s = 0; s < S; ++s) {
                  int in_idx = c_blk*(H*W) + (p+r)*W + (q+s);
                  int w_idx  = (m*(C/2) + c_blk)*(R*S) + r*S + s;
                  DTYPE in_v = (c_bank==0) ? dram_in_b0[in_idx] : dram_in_b1[in_idx];
                  DTYPE w_v  = (c_bank==0) ? dram_w_b0[w_idx]  : dram_w_b1[w_idx];
                  acc += w_v * in_v;
                }
              }
            }
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

// --- TEST HARNESS ---

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#ifdef __BAMBU_SIM__
#include <mdpi/mdpi_user.h>
#endif

void top_level(DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7);


static void init(DTYPE *in_full, DTYPE *w_full, DTYPE *out_full, DTYPE *gold,
                 size_t si, size_t sw, size_t so) {
    for (size_t i = 0; i < si; ++i) in_full[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < sw; ++i) w_full[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < so; ++i) { out_full[i] = 0.0f; gold[i] = 0.0f; }
}

static void golden_reference(DTYPE *in_full, DTYPE *w_full, DTYPE *out_golden) {
    for (int m = 0; m < 4; ++m)
      for (int c = 0; c < 4; ++c)
        for (int r = 0; r < 3; ++r)
          for (int s = 0; s < 3; ++s)
            for (int p = 0; p < 4; ++p)
              for (int q = 0; q < 4; ++q) {
                int out_idx = m*4*4 + p*4 + q;
                int w_idx   = m*4*3*3 + c*3*3 + r*3 + s;
                int in_idx  = c*6*6 + (p+r)*6 + (q+s);
                out_golden[out_idx] += w_full[w_idx] * in_full[in_idx];
              }
}

static int compare(DTYPE *out, DTYPE *gold, size_t so) {
    const float eps = 1e-3f;
    int errs = 0;
    for (size_t i = 0; i < so; ++i) {
        if (fabs(out[i]-gold[i]) > eps) {
            printf("ERROR at index %zu: HLS_val=%.6f, Golden_val=%.6f\n", i, out[i], gold[i]);
            if (++errs > 20) return errs;
        }
    }
    return errs;
}

int main() {
    size_t in_full_e  = 144;
    size_t w_full_e   = 144;
    size_t out_full_e = 64;

    DTYPE *in_full  = (DTYPE*)malloc(in_full_e  * sizeof(DTYPE));
    DTYPE *w_full   = (DTYPE*)malloc(w_full_e   * sizeof(DTYPE));
    DTYPE *out_full = (DTYPE*)malloc(out_full_e * sizeof(DTYPE));
    DTYPE *gold     = (DTYPE*)malloc(out_full_e * sizeof(DTYPE));

    if (!in_full || !w_full || !out_full || !gold) {
        printf("Memory allocation failed!\n");
        return -1;
    }

    init(in_full, w_full, out_full, gold, in_full_e, w_full_e, out_full_e);
    golden_reference(in_full, w_full, gold);

    // Banked inputs/weights
    DTYPE *dram_in_b0 = (DTYPE*)malloc(72 * sizeof(DTYPE));
    DTYPE *dram_in_b1 = (DTYPE*)malloc(72 * sizeof(DTYPE));
    DTYPE *dram_w_b0  = (DTYPE*)malloc(72 * sizeof(DTYPE));
    DTYPE *dram_w_b1  = (DTYPE*)malloc(72 * sizeof(DTYPE));
    if (!dram_in_b0 || !dram_in_b1 || !dram_w_b0 || !dram_w_b1) {
        printf("Bank allocation failed!\n");
        return -1;
    }

    // Banked outputs
    DTYPE *dram_out_b0 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_out_b0) { printf("Out bank 0 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b1 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_out_b1) { printf("Out bank 1 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b2 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_out_b2) { printf("Out bank 2 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b3 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_out_b3) { printf("Out bank 3 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b4 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_out_b4) { printf("Out bank 4 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b5 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_out_b5) { printf("Out bank 5 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b6 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_out_b6) { printf("Out bank 6 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b7 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_out_b7) { printf("Out bank 7 alloc failed!\n"); return -1; }


    for (size_t i = 0; i < 72; ++i) { dram_in_b0[i]=0.0f; dram_in_b1[i]=0.0f; }
    for (size_t i = 0; i < 72;  ++i) { dram_w_b0[i]=0.0f;  dram_w_b1[i]=0.0f;  }
    for (size_t i = 0; i < 8; ++i) dram_out_b0[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_out_b1[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_out_b2[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_out_b3[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_out_b4[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_out_b5[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_out_b6[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_out_b7[i] = 0.0f;


    // Scatter input into 2 banks by c%2
    for (int c = 0; c < 4; ++c) {
        int bank = c & 1;
        int blk  = c >> 1;
        for (int y = 0; y < 6; ++y) {
            for (int x = 0; x < 6; ++x) {
                int full_idx = c*6*6 + y*6 + x;
                int b_idx    = blk*6*6 + y*6 + x;
                if (bank==0) dram_in_b0[b_idx] = in_full[full_idx];
                else         dram_in_b1[b_idx] = in_full[full_idx];
            }
        }
    }

    // Scatter weights into 2 banks by c%2
    for (int m = 0; m < 4; ++m) {
      for (int c = 0; c < 4; ++c) {
        int bank = c & 1;
        int blk  = c >> 1;
        for (int r = 0; r < 3; ++r)
          for (int s = 0; s < 3; ++s) {
            int full_idx = m*4*3*3 + c*3*3 + r*3 + s;
            int b_idx    = (m*2 + blk)*3*3 + r*3 + s;
            if (bank==0) dram_w_b0[b_idx] = w_full[full_idx];
            else         dram_w_b1[b_idx] = w_full[full_idx];
          }
      }
    }

#ifdef __BAMBU_SIM__
    m_param_alloc(0, 72 * sizeof(DTYPE));
    m_param_alloc(1, 72 * sizeof(DTYPE));
    m_param_alloc(2, 72  * sizeof(DTYPE));
    m_param_alloc(3, 72  * sizeof(DTYPE));
    m_param_alloc(4, 8 * sizeof(DTYPE));
    m_param_alloc(5, 8 * sizeof(DTYPE));
    m_param_alloc(6, 8 * sizeof(DTYPE));
    m_param_alloc(7, 8 * sizeof(DTYPE));
    m_param_alloc(8, 8 * sizeof(DTYPE));
    m_param_alloc(9, 8 * sizeof(DTYPE));
    m_param_alloc(10, 8 * sizeof(DTYPE));
    m_param_alloc(11, 8 * sizeof(DTYPE));
#endif


    printf("Running HLS top_level function...\n");
    top_level(dram_in_b0, dram_in_b1, dram_w_b0, dram_w_b1, dram_out_b0, dram_out_b1, dram_out_b2, dram_out_b3, dram_out_b4, dram_out_b5, dram_out_b6, dram_out_b7);

    // Gather out banks into out_full
    for (int m = 0; m < 4; ++m)
      for (int p = 0; p < 4; ++p)
        for (int q = 0; q < 4; ++q) {
          int lane_m = (4==1)?0:(m % 4);
          int lane_p = (1==1)?0:(p % 1);
          int lane_q = (2==1)?0:(q % 2);
          int bank = (lane_m*1 + lane_p)*2 + lane_q;

          int cm = (4==1)?m:(m / 4);
          int cp = (1==1)?p:(p / 1);
          int cq = (2==1)?q:(q / 2);
          int idx_b = (cm*4 + cp)*2 + cq;

          int out_idx = m*4*4 + p*4 + q;
          switch(bank) {
            case 0: out_full[out_idx] = dram_out_b0[idx_b]; break;
            case 1: out_full[out_idx] = dram_out_b1[idx_b]; break;
            case 2: out_full[out_idx] = dram_out_b2[idx_b]; break;
            case 3: out_full[out_idx] = dram_out_b3[idx_b]; break;
            case 4: out_full[out_idx] = dram_out_b4[idx_b]; break;
            case 5: out_full[out_idx] = dram_out_b5[idx_b]; break;
            case 6: out_full[out_idx] = dram_out_b6[idx_b]; break;
            case 7: out_full[out_idx] = dram_out_b7[idx_b]; break;
            default: out_full[out_idx] = 0.0f; break;
          }
        }

    printf("Comparing results...\n");
    int e = compare(out_full, gold, out_full_e);
    if (e==0) printf("SUCCESS: The results match the golden reference!\n");
    else printf("FAILURE: Found %d mismatches.\n", e);

    return e;
}
