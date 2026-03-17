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

void top_level(DTYPE *dram_in, DTYPE *dram_w, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7);

static void init(DTYPE *in, DTYPE *w, DTYPE *out, DTYPE *gold, size_t si, size_t sw, size_t so) {
    for (size_t i = 0; i < si; ++i) in[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < sw; ++i) w[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < so; ++i) { out[i]=0.0f; gold[i]=0.0f; }
}

static void golden_reference(DTYPE *in, DTYPE *w, DTYPE *out_golden) {
    for (int m_ = 0; m_ < 4; ++m_) {
        for (int c_ = 0; c_ < 4; ++c_) {
            for (int r_ = 0; r_ < 3; ++r_) {
                for (int s_ = 0; s_ < 3; ++s_) {
                    for (int p_ = 0; p_ < 4; ++p_) {
                        for (int q_ = 0; q_ < 4; ++q_) {
                            int out_idx = m_*4*4 + p_*4 + q_;
                            int w_idx = m_*4*3*3 + c_*3*3 + r_*3 + s_;
                            int in_idx = c_*6*6 + (p_+r_)*6 + (q_+s_);
                            out_golden[out_idx] += w[w_idx] * in[in_idx];
                        }
                    }
                }
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
    size_t in_e = 4 * 6 * 6;
    size_t w_e  = 4 * 4 * 3 * 3;
    size_t o_e  = 4 * 4 * 4;

    size_t in_b = in_e * sizeof(DTYPE);
    size_t w_b  = w_e  * sizeof(DTYPE);
    size_t o_b  = o_e  * sizeof(DTYPE);

    DTYPE *dram_in  = (DTYPE*)malloc(in_b);
    DTYPE *dram_w   = (DTYPE*)malloc(w_b);
    DTYPE *dram_out = (DTYPE*)malloc(o_b);
    DTYPE *gold     = (DTYPE*)malloc(o_b);

    // Banked outputs
    DTYPE *dram_out_b0 = (DTYPE*)malloc((8 * sizeof(DTYPE)));
    DTYPE *dram_out_b1 = (DTYPE*)malloc((8 * sizeof(DTYPE)));
    DTYPE *dram_out_b2 = (DTYPE*)malloc((8 * sizeof(DTYPE)));
    DTYPE *dram_out_b3 = (DTYPE*)malloc((8 * sizeof(DTYPE)));
    DTYPE *dram_out_b4 = (DTYPE*)malloc((8 * sizeof(DTYPE)));
    DTYPE *dram_out_b5 = (DTYPE*)malloc((8 * sizeof(DTYPE)));
    DTYPE *dram_out_b6 = (DTYPE*)malloc((8 * sizeof(DTYPE)));
    DTYPE *dram_out_b7 = (DTYPE*)malloc((8 * sizeof(DTYPE)));


    if (!dram_in || !dram_w || !dram_out || !gold
        || !dram_out_b0
        || !dram_out_b1
        || !dram_out_b2
        || !dram_out_b3
        || !dram_out_b4
        || !dram_out_b5
        || !dram_out_b6
        || !dram_out_b7

    ) {
        printf("Memory allocation failed!\n");
        return -1;
    }

    init(dram_in, dram_w, dram_out, gold, in_e, w_e, o_e);
    golden_reference(dram_in, dram_w, gold);

    // SCATTER linear dram_out -> banks (initial values)
    for (int m = 0; m < 4; ++m) {
        for (int p_ = 0; p_ < 4; ++p_) {
            for (int q_ = 0; q_ < 4; ++q_) {
                int lane_m = m % 4;
                int lane_p = p_ % 1;
                int lane_q = q_ % 2;
                int bank = ((lane_m)*1 + (lane_p))*2 + (lane_q);
                int idx  = (((m / 4)*4 + (p_ / 1))*2 + (q_ / 2));
                switch(bank) {
            case 0: dram_out_b0[idx] = dram_out[m*4*4 + p_*4 + q_]; break;
            case 1: dram_out_b1[idx] = dram_out[m*4*4 + p_*4 + q_]; break;
            case 2: dram_out_b2[idx] = dram_out[m*4*4 + p_*4 + q_]; break;
            case 3: dram_out_b3[idx] = dram_out[m*4*4 + p_*4 + q_]; break;
            case 4: dram_out_b4[idx] = dram_out[m*4*4 + p_*4 + q_]; break;
            case 5: dram_out_b5[idx] = dram_out[m*4*4 + p_*4 + q_]; break;
            case 6: dram_out_b6[idx] = dram_out[m*4*4 + p_*4 + q_]; break;
            case 7: dram_out_b7[idx] = dram_out[m*4*4 + p_*4 + q_]; break;
                }
            }
        }
    }

#ifdef __BAMBU_SIM__
    m_param_alloc(0, in_b);
    m_param_alloc(1, w_b);
    m_param_alloc(2, (8 * sizeof(DTYPE)));
    m_param_alloc(3, (8 * sizeof(DTYPE)));
    m_param_alloc(4, (8 * sizeof(DTYPE)));
    m_param_alloc(5, (8 * sizeof(DTYPE)));
    m_param_alloc(6, (8 * sizeof(DTYPE)));
    m_param_alloc(7, (8 * sizeof(DTYPE)));
    m_param_alloc(8, (8 * sizeof(DTYPE)));
    m_param_alloc(9, (8 * sizeof(DTYPE)));

#endif

    printf("Running HLS top_level function...\n");
    top_level(dram_in, dram_w, dram_out_b0, dram_out_b1, dram_out_b2, dram_out_b3, dram_out_b4, dram_out_b5, dram_out_b6, dram_out_b7);

    // GATHER banks -> linear dram_out for comparison
    for (int m = 0; m < 4; ++m) {
        for (int p_ = 0; p_ < 4; ++p_) {
            for (int q_ = 0; q_ < 4; ++q_) {
                int lane_m = m % 4;
                int lane_p = p_ % 1;
                int lane_q = q_ % 2;
                int bank = ((lane_m)*1 + (lane_p))*2 + (lane_q);
                int idx  = (((m / 4)*4 + (p_ / 1))*2 + (q_ / 2));
                switch(bank) {
            case 0: dram_out[m*4*4 + p_*4 + q_] = dram_out_b0[idx]; break;
            case 1: dram_out[m*4*4 + p_*4 + q_] = dram_out_b1[idx]; break;
            case 2: dram_out[m*4*4 + p_*4 + q_] = dram_out_b2[idx]; break;
            case 3: dram_out[m*4*4 + p_*4 + q_] = dram_out_b3[idx]; break;
            case 4: dram_out[m*4*4 + p_*4 + q_] = dram_out_b4[idx]; break;
            case 5: dram_out[m*4*4 + p_*4 + q_] = dram_out_b5[idx]; break;
            case 6: dram_out[m*4*4 + p_*4 + q_] = dram_out_b6[idx]; break;
            case 7: dram_out[m*4*4 + p_*4 + q_] = dram_out_b7[idx]; break;
                }
            }
        }
    }

    printf("Comparing results...\n");
    int e = compare(dram_out, gold, o_e);
    if (e==0) printf("SUCCESS: The results match the golden reference!\n");
    else printf("FAILURE: Found %d mismatches.\n", e);

    free(dram_in); free(dram_w); free(dram_out); free(gold);
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
