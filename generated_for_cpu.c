#define DTYPE float
#define M_TOTAL 4
#define P_TOTAL 4
#define Q_TOTAL 4
#define C_TOTAL 4
#define R_TOTAL 3
#define S_TOTAL 3


// --- HARDWARE KERNEL (top_level) ---
void top_level(DTYPE *dram_in, DTYPE *dram_w, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7) {
    // Pointers to output banks
    DTYPE* out_banks[8] = {dram_out_b0, dram_out_b1, dram_out_b2, dram_out_b3, dram_out_b4, dram_out_b5, dram_out_b6, dram_out_b7};

    // Level: DRAM
    for (int q_dram = 0; q_dram < 2; ++q_dram) {
        // Level: GlobalBuffer
        for (int p_globalbuffer = 0; p_globalbuffer < 4; ++p_globalbuffer) {
            // Level: SACols
            #pragma GCC unroll 4
            for (int m_sacols = 0; m_sacols < 4; ++m_sacols) {
                #pragma GCC unroll 2
                for (int q_sacols = 0; q_sacols < 2; ++q_sacols) {
                    // Level: SARows
                    // Level: InRegister
                    // Level: WRegister
                    for (int r_wregister = 0; r_wregister < 3; ++r_wregister) {
                        // Level: OutRegister
                        int global_m = m_sacols;
                        int global_p = p_globalbuffer;
                        int global_q = q_dram * 2 + q_sacols;
                        int lane_m = global_m % 4;
                        int lane_p = global_p % 1;
                        int lane_q = global_q % 2;
                        int out_bank = ((lane_m)*1 + (lane_p))*2 + (lane_q);
                        int coarse_m = global_m / 4;
                        int coarse_p = global_p / 1;
                        int coarse_q = global_q / 2;
                        int out_idx_b = ((coarse_m)*4 + (coarse_p))*2 + (coarse_q);
                        DTYPE acc = out_banks[out_bank][out_idx_b];
                        DTYPE mac_0 = dram_w[global_m*(4*3*3) + (((0) + 0*1))*(3*3) + (r_wregister)*3 + (((0) + 0*1))] * dram_in[(((0) + 0*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 0*1)))];
                        DTYPE mac_1 = dram_w[global_m*(4*3*3) + (((0) + 1*1))*(3*3) + (r_wregister)*3 + (((0) + 0*1))] * dram_in[(((0) + 1*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 0*1)))];
                        DTYPE mac_2 = dram_w[global_m*(4*3*3) + (((0) + 2*1))*(3*3) + (r_wregister)*3 + (((0) + 0*1))] * dram_in[(((0) + 2*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 0*1)))];
                        DTYPE mac_3 = dram_w[global_m*(4*3*3) + (((0) + 3*1))*(3*3) + (r_wregister)*3 + (((0) + 0*1))] * dram_in[(((0) + 3*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 0*1)))];
                        DTYPE mac_4 = dram_w[global_m*(4*3*3) + (((0) + 0*1))*(3*3) + (r_wregister)*3 + (((0) + 1*1))] * dram_in[(((0) + 0*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 1*1)))];
                        DTYPE mac_5 = dram_w[global_m*(4*3*3) + (((0) + 1*1))*(3*3) + (r_wregister)*3 + (((0) + 1*1))] * dram_in[(((0) + 1*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 1*1)))];
                        DTYPE mac_6 = dram_w[global_m*(4*3*3) + (((0) + 2*1))*(3*3) + (r_wregister)*3 + (((0) + 1*1))] * dram_in[(((0) + 2*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 1*1)))];
                        DTYPE mac_7 = dram_w[global_m*(4*3*3) + (((0) + 3*1))*(3*3) + (r_wregister)*3 + (((0) + 1*1))] * dram_in[(((0) + 3*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 1*1)))];
                        DTYPE mac_8 = dram_w[global_m*(4*3*3) + (((0) + 0*1))*(3*3) + (r_wregister)*3 + (((0) + 2*1))] * dram_in[(((0) + 0*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 2*1)))];
                        DTYPE mac_9 = dram_w[global_m*(4*3*3) + (((0) + 1*1))*(3*3) + (r_wregister)*3 + (((0) + 2*1))] * dram_in[(((0) + 1*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 2*1)))];
                        DTYPE mac_10 = dram_w[global_m*(4*3*3) + (((0) + 2*1))*(3*3) + (r_wregister)*3 + (((0) + 2*1))] * dram_in[(((0) + 2*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 2*1)))];
                        DTYPE mac_11 = dram_w[global_m*(4*3*3) + (((0) + 3*1))*(3*3) + (r_wregister)*3 + (((0) + 2*1))] * dram_in[(((0) + 3*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 2*1)))];
                        // Adder tree stage 1
                        DTYPE rc_s1_0 = mac_0 + mac_1;
                        DTYPE rc_s1_1 = mac_2 + mac_3;
                        DTYPE rc_s1_2 = mac_4 + mac_5;
                        DTYPE rc_s1_3 = mac_6 + mac_7;
                        DTYPE rc_s1_4 = mac_8 + mac_9;
                        DTYPE rc_s1_5 = mac_10 + mac_11;
                        // Adder tree stage 2
                        DTYPE rc_s2_0 = rc_s1_0 + rc_s1_1;
                        DTYPE rc_s2_1 = rc_s1_2 + rc_s1_3;
                        DTYPE rc_s2_2 = rc_s1_4 + rc_s1_5;
                        // Adder tree stage 3
                        DTYPE rc_s3_0 = rc_s2_0 + rc_s2_1;
                        // Adder tree stage 4
                        DTYPE rc_s4_0 = rc_s3_0 + rc_s2_2;
                        acc += rc_s4_0;
                        out_banks[out_bank][out_idx_b] = acc;
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
