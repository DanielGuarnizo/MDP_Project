#define DTYPE float
#define M_TOTAL 8
#define K_TOTAL 8
#define N_TOTAL 8


// --- HARDWARE KERNEL (top_level) ---
void top_level(DTYPE *dram_in, DTYPE *dram_w, DTYPE *dram_out) {
    // --- LOCAL MEMORY PROMOTION (Solves AXI RAW Hazard) ---
    DTYPE local_dram_out[8 * 8];
    for(int i=0;i<8*8;++i) local_dram_out[i]=dram_out[i];

    // Level: DRAM
    for(int n_dram=0; n_dram<2; ++n_dram) {
        // Level: GlobalBuffer
        for(int n_globalbuffer=0; n_globalbuffer<4; ++n_globalbuffer) {
            // Level: InRegister
            // Level: WRegister
            // Level: OutRegister
            // STEP 1: Fetch current output column
            DTYPE local_acc[8];
            for(int mm=0; mm<8; ++mm) local_acc[mm] = local_dram_out[mm*8 + (n_dram * 4 + n_globalbuffer)];

            // STEP 2: Multiply into isolated PE registers
            DTYPE pe_macs[8][8];
            #pragma GCC unroll 8
            for(int k_sacols=0; k_sacols<8; ++k_sacols) {
                #pragma GCC unroll 8
                for(int m_sarows=0; m_sarows<8; ++m_sarows) {
                    int global_n = n_dram * 4 + n_globalbuffer;
                    int global_m = m_sarows;
                    int global_k = k_sacols;
                    pe_macs[m_sarows][k_sacols] = dram_w[global_m*8+global_k] * dram_in[global_k*8+global_n];
                }
            }

            // STEP 3: Explicit adder tree reduction over K
            for(int m_sarows=0; m_sarows<8; ++m_sarows) {
                // Adder tree stage 1
                DTYPE t_s1_0 = pe_macs[m_sarows][0] + pe_macs[m_sarows][1];
                DTYPE t_s1_1 = pe_macs[m_sarows][2] + pe_macs[m_sarows][3];
                DTYPE t_s1_2 = pe_macs[m_sarows][4] + pe_macs[m_sarows][5];
                DTYPE t_s1_3 = pe_macs[m_sarows][6] + pe_macs[m_sarows][7];
                // Adder tree stage 2
                DTYPE t_s2_0 = t_s1_0 + t_s1_1;
                DTYPE t_s2_1 = t_s1_2 + t_s1_3;
                // Adder tree stage 3
                DTYPE t_s3_0 = t_s2_0 + t_s2_1;
                DTYPE sum = t_s3_0;
                int global_m = m_sarows;
                local_acc[global_m] += sum;
            }

            // STEP 4: Write column back
            for(int mm=0; mm<8; ++mm) local_dram_out[mm*8 + (n_dram * 4 + n_globalbuffer)] = local_acc[mm];
        }
    }

    // --- WRITE BACK TO EXTERNAL SLOW MEMORY ---
    for(int i=0;i<8*8;++i) dram_out[i]=local_dram_out[i];
}

// --- TEST HARNESS ---

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
