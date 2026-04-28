#define DTYPE float
#define M_TOTAL 4
#define P_TOTAL 6
#define Q_TOTAL 6
#define C_TOTAL 4
#define R_TOTAL 3
#define S_TOTAL 1


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

void top_level(DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7, DTYPE *dram_out_b8, DTYPE *dram_out_b9, DTYPE *dram_out_b10, DTYPE *dram_out_b11, DTYPE *dram_out_b12, DTYPE *dram_out_b13, DTYPE *dram_out_b14, DTYPE *dram_out_b15, DTYPE *dram_out_b16, DTYPE *dram_out_b17, DTYPE *dram_out_b18, DTYPE *dram_out_b19, DTYPE *dram_out_b20, DTYPE *dram_out_b21, DTYPE *dram_out_b22, DTYPE *dram_out_b23);



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
          for (int s = 0; s < 1; ++s)
            for (int p = 0; p < 6; ++p)
              for (int q = 0; q < 6; ++q) {
                int out_idx = m*6*6 + p*6 + q;
                int w_idx   = m*4*3*1 + c*3*1 + r*1 + s;
                int in_idx  = c*8*6 + (p+r)*6 + (q+s);
                out_golden[out_idx] += w_full[w_idx] * in_full[in_idx];
              }
}

static int compare(DTYPE *out, DTYPE *gold, size_t so) {
    /* Relative+absolute tolerance: handles both tiny outputs and large-sum outputs.
       1e-3 absolute prevents false positives near zero; 1e-3 relative catches
       floating-point accumulation differences on large convolutions (C*R*S up to ~25k).
       Real bugs (wrong loop structure) produce diffs 100-1000x larger than tolerance. */
    const float eps_abs = 1e-3f;
    const float eps_rel = 1e-3f;
    int errs = 0;
    for (size_t i = 0; i < so; ++i) {
        float diff = fabs(out[i]-gold[i]);
        float tol  = eps_abs + eps_rel * fabs(gold[i]);
        if (diff > tol) {
            printf("ERROR at index %zu: HLS=%.6f Gold=%.6f diff=%.6f tol=%.6f\n", i, out[i], gold[i], diff, tol);
            if (++errs > 20) return errs;
        }
    }
    return errs;
}

int main() {
    size_t in_full_e  = 192;
    size_t w_full_e   = 48;
    size_t out_full_e = 144;

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
    DTYPE *dram_in_b0 = (DTYPE*)malloc(96 * sizeof(DTYPE));
    DTYPE *dram_in_b1 = (DTYPE*)malloc(96 * sizeof(DTYPE));
    DTYPE *dram_w_b0  = (DTYPE*)malloc(24 * sizeof(DTYPE));
    DTYPE *dram_w_b1  = (DTYPE*)malloc(24 * sizeof(DTYPE));
    if (!dram_in_b0 || !dram_in_b1 || !dram_w_b0 || !dram_w_b1) {
        printf("Bank allocation failed!\n");
        return -1;
    }

    // Outputs
    DTYPE *dram_out_b0 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b0) { printf("Out bank 0 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b1 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b1) { printf("Out bank 1 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b2 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b2) { printf("Out bank 2 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b3 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b3) { printf("Out bank 3 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b4 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b4) { printf("Out bank 4 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b5 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b5) { printf("Out bank 5 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b6 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b6) { printf("Out bank 6 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b7 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b7) { printf("Out bank 7 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b8 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b8) { printf("Out bank 8 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b9 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b9) { printf("Out bank 9 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b10 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b10) { printf("Out bank 10 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b11 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b11) { printf("Out bank 11 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b12 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b12) { printf("Out bank 12 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b13 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b13) { printf("Out bank 13 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b14 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b14) { printf("Out bank 14 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b15 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b15) { printf("Out bank 15 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b16 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b16) { printf("Out bank 16 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b17 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b17) { printf("Out bank 17 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b18 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b18) { printf("Out bank 18 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b19 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b19) { printf("Out bank 19 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b20 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b20) { printf("Out bank 20 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b21 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b21) { printf("Out bank 21 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b22 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b22) { printf("Out bank 22 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b23 = (DTYPE*)malloc(6 * sizeof(DTYPE));
    if (!dram_out_b23) { printf("Out bank 23 alloc failed!\n"); return -1; }


    // Zero
    for (size_t i = 0; i < 96; ++i) { dram_in_b0[i]=0.0f; dram_in_b1[i]=0.0f; }
    for (size_t i = 0; i < 24;  ++i) { dram_w_b0[i]=0.0f; dram_w_b1[i]=0.0f; }
    for (size_t i = 0; i < 6; ++i) dram_out_b0[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b1[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b2[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b3[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b4[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b5[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b6[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b7[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b8[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b9[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b10[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b11[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b12[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b13[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b14[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b15[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b16[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b17[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b18[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b19[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b20[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b21[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b22[i] = 0.0f;
    for (size_t i = 0; i < 6; ++i) dram_out_b23[i] = 0.0f;

    // Scatter input into 2 banks by c%2
    for (int c = 0; c < 4; ++c) {
        int bank = c & 1;
        int blk  = c >> 1;
        for (int y = 0; y < 8; ++y) {
            for (int x = 0; x < 6; ++x) {
                int full_idx = c*8*6 + y*6 + x;
                int b_idx    = blk*8*6 + y*6 + x;
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
          for (int s = 0; s < 1; ++s) {
            int full_idx = m*4*3*1 + c*3*1 + r*1 + s;
            int b_idx    = (m*2 + blk)*3*1 + r*1 + s;
            if (bank==0) dram_w_b0[b_idx] = w_full[full_idx];
            else         dram_w_b1[b_idx] = w_full[full_idx];
          }
      }
    }

#ifdef __BAMBU_SIM__
    m_param_alloc(0, 96 * sizeof(DTYPE));
    m_param_alloc(1, 96 * sizeof(DTYPE));
    m_param_alloc(2, 24 * sizeof(DTYPE));
    m_param_alloc(3, 24 * sizeof(DTYPE));
    m_param_alloc(4, 6 * sizeof(DTYPE));
    m_param_alloc(5, 6 * sizeof(DTYPE));
    m_param_alloc(6, 6 * sizeof(DTYPE));
    m_param_alloc(7, 6 * sizeof(DTYPE));
    m_param_alloc(8, 6 * sizeof(DTYPE));
    m_param_alloc(9, 6 * sizeof(DTYPE));
    m_param_alloc(10, 6 * sizeof(DTYPE));
    m_param_alloc(11, 6 * sizeof(DTYPE));
    m_param_alloc(12, 6 * sizeof(DTYPE));
    m_param_alloc(13, 6 * sizeof(DTYPE));
    m_param_alloc(14, 6 * sizeof(DTYPE));
    m_param_alloc(15, 6 * sizeof(DTYPE));
    m_param_alloc(16, 6 * sizeof(DTYPE));
    m_param_alloc(17, 6 * sizeof(DTYPE));
    m_param_alloc(18, 6 * sizeof(DTYPE));
    m_param_alloc(19, 6 * sizeof(DTYPE));
    m_param_alloc(20, 6 * sizeof(DTYPE));
    m_param_alloc(21, 6 * sizeof(DTYPE));
    m_param_alloc(22, 6 * sizeof(DTYPE));
    m_param_alloc(23, 6 * sizeof(DTYPE));
    m_param_alloc(24, 6 * sizeof(DTYPE));
    m_param_alloc(25, 6 * sizeof(DTYPE));
    m_param_alloc(26, 6 * sizeof(DTYPE));
    m_param_alloc(27, 6 * sizeof(DTYPE));

#endif

    printf("Running HLS top_level function...\n");
    top_level(dram_in_b0, dram_in_b1, dram_w_b0, dram_w_b1, dram_out_b0, dram_out_b1, dram_out_b2, dram_out_b3, dram_out_b4, dram_out_b5, dram_out_b6, dram_out_b7, dram_out_b8, dram_out_b9, dram_out_b10, dram_out_b11, dram_out_b12, dram_out_b13, dram_out_b14, dram_out_b15, dram_out_b16, dram_out_b17, dram_out_b18, dram_out_b19, dram_out_b20, dram_out_b21, dram_out_b22, dram_out_b23);

    // Gather out banks into out_full
    for (int m = 0; m < 4; ++m)
      for (int p = 0; p < 6; ++p)
        for (int q = 0; q < 6; ++q) {

          int m_local = m % 4;
          int sarows_1 = m_local / 2;
          int sacols_1 = m_local % 2;
          int q_local = q % 6;
          int sacols_0 = q_local;
          int bank = sarows_1*12 + sacols_0*2 + sacols_1;
          int cm = m / 4;
          int cq = q / 6;
          int cp = p;
          int idx_b = (cm * 6 + cp) * 1 + cq;

          int out_idx = m*6*6 + p*6 + q;
          switch(bank) {
            case 0: out_full[out_idx] = dram_out_b0[idx_b]; break;
            case 1: out_full[out_idx] = dram_out_b1[idx_b]; break;
            case 2: out_full[out_idx] = dram_out_b2[idx_b]; break;
            case 3: out_full[out_idx] = dram_out_b3[idx_b]; break;
            case 4: out_full[out_idx] = dram_out_b4[idx_b]; break;
            case 5: out_full[out_idx] = dram_out_b5[idx_b]; break;
            case 6: out_full[out_idx] = dram_out_b6[idx_b]; break;
            case 7: out_full[out_idx] = dram_out_b7[idx_b]; break;
            case 8: out_full[out_idx] = dram_out_b8[idx_b]; break;
            case 9: out_full[out_idx] = dram_out_b9[idx_b]; break;
            case 10: out_full[out_idx] = dram_out_b10[idx_b]; break;
            case 11: out_full[out_idx] = dram_out_b11[idx_b]; break;
            case 12: out_full[out_idx] = dram_out_b12[idx_b]; break;
            case 13: out_full[out_idx] = dram_out_b13[idx_b]; break;
            case 14: out_full[out_idx] = dram_out_b14[idx_b]; break;
            case 15: out_full[out_idx] = dram_out_b15[idx_b]; break;
            case 16: out_full[out_idx] = dram_out_b16[idx_b]; break;
            case 17: out_full[out_idx] = dram_out_b17[idx_b]; break;
            case 18: out_full[out_idx] = dram_out_b18[idx_b]; break;
            case 19: out_full[out_idx] = dram_out_b19[idx_b]; break;
            case 20: out_full[out_idx] = dram_out_b20[idx_b]; break;
            case 21: out_full[out_idx] = dram_out_b21[idx_b]; break;
            case 22: out_full[out_idx] = dram_out_b22[idx_b]; break;
            case 23: out_full[out_idx] = dram_out_b23[idx_b]; break;
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
    free(dram_out_b8);
    free(dram_out_b9);
    free(dram_out_b10);
    free(dram_out_b11);
    free(dram_out_b12);
    free(dram_out_b13);
    free(dram_out_b14);
    free(dram_out_b15);
    free(dram_out_b16);
    free(dram_out_b17);
    free(dram_out_b18);
    free(dram_out_b19);
    free(dram_out_b20);
    free(dram_out_b21);
    free(dram_out_b22);
    free(dram_out_b23);

    return e;
}
