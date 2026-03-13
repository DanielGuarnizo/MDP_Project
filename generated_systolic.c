#include <stdio.h>

#define DTYPE float
#define PE_COUNT 168

#define M_TOTAL 128
#define P_TOTAL 112
#define Q_TOTAL 112
#define C_TOTAL 64
#define R_TOTAL 3
#define S_TOTAL 3

void top_level(DTYPE *dram_in, DTYPE *dram_w, DTYPE *dram_out) {
    // Level: DRAM 
    for (int m_dram  = 0; m_dram  < 4; ++m_dram ) {
        for (int p_dram  = 0; p_dram  < 7; ++p_dram ) {
            for (int q_dram  = 0; q_dram  < 2; ++q_dram ) {
                // Level: GlobalBuffer
                for (int p_globalbuffer = 0; p_globalbuffer < 16; ++p_globalbuffer) {
                    for (int q_globalbuffer = 0; q_globalbuffer < 8; ++q_globalbuffer) {
                        for (int c_globalbuffer = 0; c_globalbuffer < 2; ++c_globalbuffer) {
                            // Level: SACols 
                            #pragma GCC unroll 2
                            for (int m_sacols  = 0; m_sacols  < 2; ++m_sacols ) {
                                #pragma GCC unroll 7
                                for (int q_sacols  = 0; q_sacols  < 7; ++q_sacols ) {
                                    // Level: SARows 
                                    #pragma GCC unroll 4
                                    for (int c_sarows  = 0; c_sarows  < 4; ++c_sarows ) {
                                        #pragma GCC unroll 3
                                        for (int s_sarows  = 0; s_sarows  < 3; ++s_sarows ) {
                                            // Level: WRegister 
                                            for (int c_wregister  = 0; c_wregister  < 8; ++c_wregister ) {
                                                for (int r_wregister  = 0; r_wregister  < 3; ++r_wregister ) {
                                                    // Level: OutRegister 
                                                    for (int m_outregister  = 0; m_outregister  < 16; ++m_outregister ) {
                                                        // Reconstruct global indices from tiled loop variables
                                                        int global_m = m_dram  * 32 + m_sacols  * 16 + m_outregister ;
                                                        int global_p = p_dram  * 16 + p_globalbuffer;
                                                        int global_q = q_dram  * 56 + q_globalbuffer * 7 + q_sacols ;
                                                        int global_c = c_globalbuffer * 32 + c_sarows  * 8 + c_wregister ;
                                                        int global_r = r_wregister ;
                                                        int global_s = s_sarows ;
                                                        int global_input_p = global_p + global_r; // Assuming stride 1
                                                        int global_input_q = global_q + global_s; // Assuming stride 1
                                                        // Calculate flat array indices for DRAM access
                                                        dram_out[global_m*(P_TOTAL*Q_TOTAL) + global_p*Q_TOTAL + global_q] += dram_w[global_m*(C_TOTAL*R_TOTAL*S_TOTAL) + global_c*(R_TOTAL*S_TOTAL) + global_r*S_TOTAL + global_s] * dram_in[global_c*( (P_TOTAL+R_TOTAL-1)*(Q_TOTAL+S_TOTAL-1) ) + global_input_p*(Q_TOTAL+S_TOTAL-1) + global_input_q];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

// Helper function to initialize matrices with random data
void initialize_matrices(DTYPE *in, DTYPE *w, DTYPE *out, DTYPE *out_golden) {
    for (int i = 0; i < 831744; ++i) in[i] = (DTYPE)rand() / RAND_MAX;
    for (int i = 0; i < 73728; ++i) w[i] = (DTYPE)rand() / RAND_MAX;
    for (int i = 0; i < 1605632; ++i) {
        out[i] = 0.0;
        out_golden[i] = 0.0;
    }
}

// Golden reference implementation
void golden_reference(DTYPE *in, DTYPE *w, DTYPE *out_golden) {

    for (int m_ = 0; m_ < 128; ++m_) {
        for (int c_ = 0; c_ < 64; ++c_) {
            for (int r_ = 0; r_ < 3; ++r_) {
                for (int s_ = 0; s_ < 3; ++s_) {
                    for (int p_ = 0; p_ < 112; ++p_) {
                        for (int q_ = 0; q_ < 112; ++q_) {
                            int out_idx = m_*112*112 + p_*112 + q_;
                            int w_idx = m_*64*3*3 + c_*3*3 + r_*3 + s_;
                            int in_idx = c_*114*114 + (p_+r_)*114 + (q_+s_);
                            out_golden[out_idx] += w[w_idx] * in[in_idx];
                        }
                    }
                }
            }
        }
    }

}

// Comparison function
int compare_results(DTYPE *out, DTYPE *out_golden) {
    // Increased epsilon to account for floating-point accumulation order differences.
    // A value of 1e-3 is a reasonable tolerance for this kind of complex MAC operation.
    const float epsilon = 1e-3; 
    int errors = 0;
    for (int i = 0; i < 1605632; ++i) {
        if (fabs(out[i] - out_golden[i]) > epsilon) {
            printf("ERROR at index %d: HLS_val=%.6f, Golden_val=%.6f\n", i, out[i], out_golden[i]);
            errors++;
            if (errors > 20) return errors; // Stop after 20 errors
        }
    }
    return errors;
}

int main() {
    printf("Allocating memory...\n");
    DTYPE *dram_in = (DTYPE*)malloc(831744 * sizeof(DTYPE));
    DTYPE *dram_w = (DTYPE*)malloc(73728 * sizeof(DTYPE));
    DTYPE *dram_out = (DTYPE*)malloc(1605632 * sizeof(DTYPE));
    DTYPE *dram_out_golden = (DTYPE*)malloc(1605632 * sizeof(DTYPE));

    if (!dram_in || !dram_w || !dram_out || !dram_out_golden) {
        printf("ERROR: Memory allocation failed!\n");
        return -1;
    }

    printf("Initializing matrices...\n");
    initialize_matrices(dram_in, dram_w, dram_out, dram_out_golden);

    printf("Running golden reference implementation...\n");
    golden_reference(dram_in, dram_w, dram_out_golden);

    printf("Running HLS top_level function...\n");
    top_level(dram_in, dram_w, dram_out);

    printf("Comparing results...\n");
    int num_errors = compare_results(dram_out, dram_out_golden);

    if (num_errors == 0) {
        printf("SUCCESS: The results match the golden reference!\n");
    } else {
        printf("FAILURE: Found %d mismatches.\n", num_errors);
    }

    free(dram_in);
    free(dram_w);
    free(dram_out);
    free(dram_out_golden);

    return num_errors;
}
