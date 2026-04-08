#define DTYPE float
#define M_TOTAL 4
#define P_TOTAL 4
#define Q_TOTAL 4
#define C_TOTAL 4
#define R_TOTAL 3
#define S_TOTAL 3


#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#ifdef __BAMBU_SIM__
#include <mdpi/mdpi_user.h>
#endif


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
        float diff = fabs(out[i]-gold[i]);
        if (diff > eps) {
            printf("ERROR at index %zu: HLS=%.6f Gold=%.6f diff=%.6f\n", i, out[i], gold[i], diff);
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

    // Outputs
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


    // Zero
    for (size_t i = 0; i < 72; ++i) { dram_in_b0[i]=0.0f; dram_in_b1[i]=0.0f; }
    for (size_t i = 0; i < 72;  ++i) { dram_w_b0[i]=0.0f; dram_w_b1[i]=0.0f; }
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
    m_param_alloc(2, 72 * sizeof(DTYPE));
    m_param_alloc(3, 72 * sizeof(DTYPE));
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

          int m_local = m % 4;
          int sacols_1 = m_local;
          int q_local = q % 2;
          int sacols_0 = q_local;
          int bank = sacols_0*4 + sacols_1;
          int cm = m / 4;
          int cq = q / 2;
          int cp = p;
          int idx_b = (cm * 4 + cp) * 2 + cq;

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

    free(in_full); free(w_full); free(out_full); free(gold);
    free(dram_in_b0); free(dram_in_b1); free(dram_w_b0); free(dram_w_b1);
    free(dram_out_b0);
    free(dram_out_b1);
    free(dram_out_b2);
    free(dram_out_b3);
    free(dram_out_b4);
    free(dram_out_b5);
    free(dram_out_b6);
    free(dram_out_b7);

    return e;
}
