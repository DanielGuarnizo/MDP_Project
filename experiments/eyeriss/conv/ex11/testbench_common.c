#define DTYPE float
#define M_TOTAL 64
#define P_TOTAL 56
#define Q_TOTAL 56
#define C_TOTAL 64
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

void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7, DTYPE *dram_output_p8, DTYPE *dram_output_p9, DTYPE *dram_output_p10, DTYPE *dram_output_p11, DTYPE *dram_output_p12, DTYPE *dram_output_p13, DTYPE *dram_output_p14, DTYPE *dram_output_p15);



static void init(DTYPE *in_full, DTYPE *w_full, DTYPE *out_full, DTYPE *gold,
                 size_t si, size_t sw, size_t so) {
    for (size_t i = 0; i < si; ++i) in_full[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < sw; ++i) w_full[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < so; ++i) { out_full[i] = 0.0f; gold[i] = 0.0f; }
}

static void golden_reference(DTYPE *in_full, DTYPE *w_full, DTYPE *out_golden) {
    for (int m = 0; m < 64; ++m)
      for (int c = 0; c < 64; ++c)
        for (int r = 0; r < 3; ++r)
          for (int s = 0; s < 3; ++s)
            for (int p = 0; p < 56; ++p)
              for (int q = 0; q < 56; ++q) {
                int out_idx = m*56*56 + p*56 + q;
                int w_idx   = m*64*3*3 + c*3*3 + r*3 + s;
                int in_idx  = c*58*58 + (p+r)*58 + (q+s);
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
    size_t in_full_e  = 215296;
    size_t w_full_e   = 36864;
    size_t out_full_e = 200704;

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

    // Input ports
    DTYPE *dram_input_p0  = (DTYPE*)malloc(107648 * sizeof(DTYPE));
    DTYPE *dram_input_p1  = (DTYPE*)malloc(107648 * sizeof(DTYPE));

    if (!dram_input_p0 || !dram_input_p1) {
        printf("Input port allocation failed!\n");
        return -1;
    }

    // Weight ports
    DTYPE *dram_weight_p0 = (DTYPE*)malloc(18432 * sizeof(DTYPE));
    DTYPE *dram_weight_p1 = (DTYPE*)malloc(18432 * sizeof(DTYPE));

    if (!dram_weight_p0 || !dram_weight_p1) {
        printf("Weight port allocation failed!\n");
        return -1;
    }

    // Output ports
    DTYPE *dram_output_p0 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p0) { printf("Output port 0 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p1 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p1) { printf("Output port 1 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p2 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p2) { printf("Output port 2 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p3 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p3) { printf("Output port 3 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p4 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p4) { printf("Output port 4 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p5 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p5) { printf("Output port 5 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p6 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p6) { printf("Output port 6 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p7 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p7) { printf("Output port 7 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p8 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p8) { printf("Output port 8 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p9 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p9) { printf("Output port 9 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p10 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p10) { printf("Output port 10 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p11 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p11) { printf("Output port 11 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p12 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p12) { printf("Output port 12 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p13 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p13) { printf("Output port 13 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p14 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p14) { printf("Output port 14 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p15 = (DTYPE*)malloc(14336 * sizeof(DTYPE));
    if (!dram_output_p15) { printf("Output port 15 alloc failed!\n"); return -1; }


    // Zero all ports
    for (size_t i = 0; i < 107648; ++i) dram_input_p0[i] = 0.0f;
    for (size_t i = 0; i < 107648; ++i) dram_input_p1[i] = 0.0f;
    for (size_t i = 0; i < 18432; ++i) dram_weight_p0[i] = 0.0f;
    for (size_t i = 0; i < 18432; ++i) dram_weight_p1[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p0[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p1[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p2[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p3[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p4[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p5[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p6[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p7[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p8[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p9[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p10[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p11[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p12[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p13[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p14[i] = 0.0f;
    for (size_t i = 0; i < 14336; ++i) dram_output_p15[i] = 0.0f;

    // Scatter input into 2 ports by c % 2
    for (int c = 0; c < 64; ++c) {
        int port_index = c % 2;
        int blk        = c / 2;
        for (int y = 0; y < 58; ++y) {
            for (int x = 0; x < 58; ++x) {
                int full_idx = c*58*58 + y*58 + x;
                int b_idx    = blk*58*58 + y*58 + x;
                if (port_index == 0) dram_input_p0[b_idx] = in_full[full_idx];
                if (port_index == 1) dram_input_p1[b_idx] = in_full[full_idx];
            }
        }
    }

    // Scatter weights into 2 ports by c % 2
    for (int m = 0; m < 64; ++m) {
      for (int c = 0; c < 64; ++c) {
        int port_index = c % 2;
        int blk        = c / 2;
        for (int r = 0; r < 3; ++r)
          for (int s = 0; s < 3; ++s) {
            int full_idx = m*64*3*3 + c*3*3 + r*3 + s;
            int b_idx    = (m*32 + blk)*3*3 + r*3 + s;
                if (port_index == 0) dram_weight_p0[b_idx] = w_full[full_idx];
                if (port_index == 1) dram_weight_p1[b_idx] = w_full[full_idx];
          }
      }
    }

#ifdef __BAMBU_SIM__
    m_param_alloc(0, 107648 * sizeof(DTYPE));
    m_param_alloc(1, 107648 * sizeof(DTYPE));
    m_param_alloc(2, 18432 * sizeof(DTYPE));
    m_param_alloc(3, 18432 * sizeof(DTYPE));
    m_param_alloc(4, 14336 * sizeof(DTYPE));
    m_param_alloc(5, 14336 * sizeof(DTYPE));
    m_param_alloc(6, 14336 * sizeof(DTYPE));
    m_param_alloc(7, 14336 * sizeof(DTYPE));
    m_param_alloc(8, 14336 * sizeof(DTYPE));
    m_param_alloc(9, 14336 * sizeof(DTYPE));
    m_param_alloc(10, 14336 * sizeof(DTYPE));
    m_param_alloc(11, 14336 * sizeof(DTYPE));
    m_param_alloc(12, 14336 * sizeof(DTYPE));
    m_param_alloc(13, 14336 * sizeof(DTYPE));
    m_param_alloc(14, 14336 * sizeof(DTYPE));
    m_param_alloc(15, 14336 * sizeof(DTYPE));
    m_param_alloc(16, 14336 * sizeof(DTYPE));
    m_param_alloc(17, 14336 * sizeof(DTYPE));
    m_param_alloc(18, 14336 * sizeof(DTYPE));
    m_param_alloc(19, 14336 * sizeof(DTYPE));

#endif

    printf("Running HLS top_level function...\n");
    top_level(dram_input_p0, dram_input_p1, dram_weight_p0, dram_weight_p1, dram_output_p0, dram_output_p1, dram_output_p2, dram_output_p3, dram_output_p4, dram_output_p5, dram_output_p6, dram_output_p7, dram_output_p8, dram_output_p9, dram_output_p10, dram_output_p11, dram_output_p12, dram_output_p13, dram_output_p14, dram_output_p15);

    // Gather output ports into out_full
    for (int m = 0; m < 64; ++m)
      for (int p = 0; p < 56; ++p)
        for (int q = 0; q < 56; ++q) {

          int local_filter_index = m % 4;
          int sarows_2 = local_filter_index / 2;
          int sacols_1 = local_filter_index % 2;
          int local_col_index = q % 7;
          int sacols_0 = local_col_index;
          int output_bank_index = sarows_2*14 + sacols_0*2 + sacols_1;
          int output_filter_tile = m / 4;
          int output_col_tile = q / 7;
          int output_row_tile = p;
          int output_dram_offset = (output_filter_tile * 56 + output_row_tile) * 8 + output_col_tile;
                    int output_port_index = output_bank_index % 16;
          int safe_dram_offset = output_dram_offset * 2 + output_bank_index / 16;

          int out_idx = m*56*56 + p*56 + q;
          switch(output_port_index) {
            case 0: out_full[out_idx] = dram_output_p0[safe_dram_offset]; break;
            case 1: out_full[out_idx] = dram_output_p1[safe_dram_offset]; break;
            case 2: out_full[out_idx] = dram_output_p2[safe_dram_offset]; break;
            case 3: out_full[out_idx] = dram_output_p3[safe_dram_offset]; break;
            case 4: out_full[out_idx] = dram_output_p4[safe_dram_offset]; break;
            case 5: out_full[out_idx] = dram_output_p5[safe_dram_offset]; break;
            case 6: out_full[out_idx] = dram_output_p6[safe_dram_offset]; break;
            case 7: out_full[out_idx] = dram_output_p7[safe_dram_offset]; break;
            case 8: out_full[out_idx] = dram_output_p8[safe_dram_offset]; break;
            case 9: out_full[out_idx] = dram_output_p9[safe_dram_offset]; break;
            case 10: out_full[out_idx] = dram_output_p10[safe_dram_offset]; break;
            case 11: out_full[out_idx] = dram_output_p11[safe_dram_offset]; break;
            case 12: out_full[out_idx] = dram_output_p12[safe_dram_offset]; break;
            case 13: out_full[out_idx] = dram_output_p13[safe_dram_offset]; break;
            case 14: out_full[out_idx] = dram_output_p14[safe_dram_offset]; break;
            case 15: out_full[out_idx] = dram_output_p15[safe_dram_offset]; break;
            default: out_full[out_idx] = 0.0f; break;
          }
        }

    printf("Comparing results...\n");
    int e = compare(out_full, gold, out_full_e);
    if (e==0) printf("SUCCESS: The results match the golden reference!\n");
    else printf("FAILURE: Found %d mismatches.\n", e);

    free(in_full); free(w_full); free(out_full); free(gold);
    free(dram_input_p0);
    free(dram_input_p1);
    free(dram_weight_p0);
    free(dram_weight_p1);
    free(dram_output_p0);
    free(dram_output_p1);
    free(dram_output_p2);
    free(dram_output_p3);
    free(dram_output_p4);
    free(dram_output_p5);
    free(dram_output_p6);
    free(dram_output_p7);
    free(dram_output_p8);
    free(dram_output_p9);
    free(dram_output_p10);
    free(dram_output_p11);
    free(dram_output_p12);
    free(dram_output_p13);
    free(dram_output_p14);
    free(dram_output_p15);

    return e;
}
