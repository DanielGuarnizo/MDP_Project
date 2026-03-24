#define DTYPE float
#define M_TOTAL 4
#define K_TOTAL 4
#define N_TOTAL 4

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#ifdef __BAMBU_SIM__
#include <mdpi/mdpi_user.h>
#endif

void top_level(DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3);

static void init(DTYPE *A, DTYPE *B, size_t sa, size_t sb) {
    for (size_t i = 0; i < sa; ++i) A[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < sb; ++i) B[i] = (DTYPE)rand() / RAND_MAX;
}

static void golden_reference(DTYPE *A, DTYPE *B, DTYPE *C) {
    for (int m = 0; m < 4; ++m)
      for (int n = 0; n < 4; ++n) {
        DTYPE acc = 0.0f;
        for (int k = 0; k < 4; ++k)
            acc += A[m * 4 + k] * B[k * 4 + n];
        C[m * 4 + n] = acc;
      }
}

static int compare(DTYPE *out, DTYPE *gold, size_t n) {
    const float eps = 1e-3f;
    int errs = 0;
    for (size_t i = 0; i < n; ++i) {
        float diff = fabs(out[i] - gold[i]);
        if (diff > eps) {
            printf("ERROR at %zu: HLS=%.6f Gold=%.6f diff=%.6f\n", i, out[i], gold[i], diff);
            if (++errs > 20) return errs;
        }
    }
    return errs;
}

int main() {
    size_t A_elems = 4 * 4;
    size_t B_elems = 4 * 4;
    size_t C_elems = 4 * 4;

    DTYPE *A_full   = (DTYPE*)malloc(A_elems * sizeof(DTYPE));
    DTYPE *B_full   = (DTYPE*)malloc(B_elems * sizeof(DTYPE));
    DTYPE *out_full = (DTYPE*)malloc(C_elems * sizeof(DTYPE));
    DTYPE *gold     = (DTYPE*)malloc(C_elems * sizeof(DTYPE));

    if (!A_full || !B_full || !out_full || !gold) {
        printf("Alloc failed!\n"); return -1;
    }

    for (size_t i = 0; i < C_elems; ++i) { out_full[i] = 0.0f; gold[i] = 0.0f; }
    init(A_full, B_full, A_elems, B_elems);
    golden_reference(A_full, B_full, gold);

    DTYPE *dram_w_b0  = (DTYPE*)malloc(8  * sizeof(DTYPE));
    DTYPE *dram_w_b1  = (DTYPE*)malloc(8  * sizeof(DTYPE));
    DTYPE *dram_in_b0 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    DTYPE *dram_in_b1 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_w_b0 || !dram_w_b1 || !dram_in_b0 || !dram_in_b1) {
        printf("Bank alloc failed!\n"); return -1;
    }
    DTYPE *dram_out_b0 = (DTYPE*)malloc(4 * sizeof(DTYPE));
    if (!dram_out_b0) { printf("Out bank 0 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b1 = (DTYPE*)malloc(4 * sizeof(DTYPE));
    if (!dram_out_b1) { printf("Out bank 1 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b2 = (DTYPE*)malloc(4 * sizeof(DTYPE));
    if (!dram_out_b2) { printf("Out bank 2 alloc failed!\n"); return -1; }
    DTYPE *dram_out_b3 = (DTYPE*)malloc(4 * sizeof(DTYPE));
    if (!dram_out_b3) { printf("Out bank 3 alloc failed!\n"); return -1; }

    for (size_t i = 0; i < 8;  ++i) { dram_w_b0[i] = 0.0f; dram_w_b1[i] = 0.0f; }
    for (size_t i = 0; i < 8; ++i) { dram_in_b0[i] = 0.0f; dram_in_b1[i] = 0.0f; }
    for (size_t i = 0; i < 4; ++i) dram_out_b0[i] = 0.0f;
    for (size_t i = 0; i < 4; ++i) dram_out_b1[i] = 0.0f;
    for (size_t i = 0; i < 4; ++i) dram_out_b2[i] = 0.0f;
    for (size_t i = 0; i < 4; ++i) dram_out_b3[i] = 0.0f;

    // Scatter A[M x K] into 2 weight banks by k%2
    for (int m = 0; m < 4; ++m) {
      for (int k = 0; k < 4; ++k) {
        int k_bank = k & 1, k_blk = k >> 1;
        DTYPE v = A_full[m * 4 + k];
        if (k_bank == 0) dram_w_b0[m * 2 + k_blk] = v;
        else             dram_w_b1[m * 2 + k_blk] = v;
      }
    }

    // Scatter B[K x N] into 2 input banks by k%2
    for (int k = 0; k < 4; ++k) {
      int k_bank = k & 1, k_blk = k >> 1;
      for (int n = 0; n < 4; ++n) {
        DTYPE v = B_full[k * 4 + n];
        if (k_bank == 0) dram_in_b0[k_blk * 4 + n] = v;
        else             dram_in_b1[k_blk * 4 + n] = v;
      }
    }

#ifdef __BAMBU_SIM__
    m_param_alloc(0, 8 * sizeof(DTYPE));
    m_param_alloc(1, 8 * sizeof(DTYPE));
    m_param_alloc(2, 8 * sizeof(DTYPE));
    m_param_alloc(3, 8 * sizeof(DTYPE));
    m_param_alloc(4, 4 * sizeof(DTYPE));
    m_param_alloc(5, 4 * sizeof(DTYPE));
    m_param_alloc(6, 4 * sizeof(DTYPE));
    m_param_alloc(7, 4 * sizeof(DTYPE));

#endif

    printf("Running HLS top_level function...\n");
    top_level(dram_w_b0, dram_w_b1, dram_in_b0, dram_in_b1, dram_out_b0, dram_out_b1, dram_out_b2, dram_out_b3);

    // Gather C from output banks: bank = m % m_sf, idx_b = (m / m_sf) * N + n
    for (int m = 0; m < 4; ++m)
      for (int n = 0; n < 4; ++n) {
        int bank  = m % 4;
        int idx_b = (m / 4) * 4 + n;
        int out_idx = m * 4 + n;
        switch(bank) {
            case 0: out_full[out_idx] = dram_out_b0[idx_b]; break;
            case 1: out_full[out_idx] = dram_out_b1[idx_b]; break;
            case 2: out_full[out_idx] = dram_out_b2[idx_b]; break;
            case 3: out_full[out_idx] = dram_out_b3[idx_b]; break;
            default: out_full[out_idx] = 0.0f; break;
        }
      }

    printf("Comparing results...\n");
    int e = compare(out_full, gold, C_elems);
    if (e == 0) printf("SUCCESS: Results match golden reference!\n");
    else printf("FAILURE: Found %d mismatches.\n", e);

    free(A_full); free(B_full); free(out_full); free(gold);
    free(dram_w_b0); free(dram_w_b1); free(dram_in_b0); free(dram_in_b1);
    free(dram_out_b0);
    free(dram_out_b1);
    free(dram_out_b2);
    free(dram_out_b3);

    return e;
}
