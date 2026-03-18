#define DTYPE float
#define M_TOTAL 8
#define K_TOTAL 8
#define N_TOTAL 8


#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#ifdef __BAMBU_SIM__
#include <mdpi/mdpi_user.h>
#endif

void top_level(DTYPE *dram_in, DTYPE *dram_w, DTYPE *dram_out);

static void init(DTYPE *in, DTYPE *w, DTYPE *out, DTYPE *gold, size_t si, size_t sw, size_t so) {
    for (size_t i = 0; i < si; ++i) in[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < sw; ++i) w[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < so; ++i) { out[i]=0.0f; gold[i]=0.0f; }
}

static void golden_reference(DTYPE *in, DTYPE *w, DTYPE *out_golden) {
    for (int m_ = 0; m_ < 8; ++m_) {
        for (int n_ = 0; n_ < 8; ++n_) {
            for (int k_ = 0; k_ < 8; ++k_) {
                out_golden[m_ * 8 + n_] += w[m_ * 8 + k_] * in[k_ * 8 + n_];
            }
        }
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
    size_t in_e = 8 * 8;
    size_t w_e  = 8 * 8;
    size_t o_e  = 8 * 8;

    size_t in_b = in_e * sizeof(DTYPE);
    size_t w_b  = w_e  * sizeof(DTYPE);
    size_t o_b  = o_e  * sizeof(DTYPE);

    DTYPE *dram_in  = (DTYPE*)malloc(in_b);
    DTYPE *dram_w   = (DTYPE*)malloc(w_b);
    DTYPE *dram_out = (DTYPE*)malloc(o_b);
    DTYPE *gold     = (DTYPE*)malloc(o_b);

    if (!dram_in || !dram_w || !dram_out || !gold) {
        printf("Memory allocation failed!\n");
        return -1;
    }

    init(dram_in, dram_w, dram_out, gold, in_e, w_e, o_e);
    golden_reference(dram_in, dram_w, gold);

#ifdef __BAMBU_SIM__
    m_param_alloc(0, in_b);
    m_param_alloc(1, w_b);
    m_param_alloc(2, o_b);

#endif

    printf("Running HLS top_level function...\n");
    top_level(dram_in, dram_w, dram_out);

    printf("Comparing results...\n");
    int e = compare(dram_out, gold, o_e);
    if (e==0) printf("SUCCESS: The results match the golden reference!\n");
    else printf("FAILURE: Found %d mismatches.\n", e);

    free(dram_in); free(dram_w); free(dram_out); free(gold);
    return e;
}
