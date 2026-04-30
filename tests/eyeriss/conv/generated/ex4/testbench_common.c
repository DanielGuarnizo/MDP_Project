#define DTYPE float
#define M_TOTAL 4
#define P_TOTAL 4
#define Q_TOTAL 4
#define C_TOTAL 4
#define R_TOTAL 1
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

void top_level(DTYPE *dram_input_p0, DTYPE *dram_input_p1, DTYPE *dram_input_p2, DTYPE *dram_input_p3, DTYPE *dram_weight_p0, DTYPE *dram_weight_p1, DTYPE *dram_weight_p2, DTYPE *dram_weight_p3, DTYPE *dram_output_p0, DTYPE *dram_output_p1, DTYPE *dram_output_p2, DTYPE *dram_output_p3, DTYPE *dram_output_p4, DTYPE *dram_output_p5, DTYPE *dram_output_p6, DTYPE *dram_output_p7);



static void init(DTYPE *in_full, DTYPE *w_full, DTYPE *out_full, DTYPE *gold,
                 size_t si, size_t sw, size_t so) {
    for (size_t i = 0; i < si; ++i) in_full[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < sw; ++i) w_full[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < so; ++i) { out_full[i] = 0.0f; gold[i] = 0.0f; }
}

static void golden_reference(DTYPE *in_full, DTYPE *w_full, DTYPE *out_golden) {
    for (int m = 0; m < 4; ++m)
      for (int c = 0; c < 4; ++c)
        for (int r = 0; r < 1; ++r)
          for (int s = 0; s < 1; ++s)
            for (int p = 0; p < 4; ++p)
              for (int q = 0; q < 4; ++q) {
                int out_idx = m*4*4 + p*4 + q;
                int w_idx   = m*4*1*1 + c*1*1 + r*1 + s;
                int in_idx  = c*4*4 + (p+r)*4 + (q+s);
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
    size_t in_full_e  = 64;
    size_t w_full_e   = 16;
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

    // Input ports
    DTYPE *dram_input_p0  = (DTYPE*)malloc(16 * sizeof(DTYPE));
    DTYPE *dram_input_p1  = (DTYPE*)malloc(16 * sizeof(DTYPE));
    DTYPE *dram_input_p2  = (DTYPE*)malloc(16 * sizeof(DTYPE));
    DTYPE *dram_input_p3  = (DTYPE*)malloc(16 * sizeof(DTYPE));

    if (!dram_input_p0 || !dram_input_p1 || !dram_input_p2 || !dram_input_p3) {
        printf("Input port allocation failed!\n");
        return -1;
    }

    // Weight ports
    DTYPE *dram_weight_p0 = (DTYPE*)malloc(4 * sizeof(DTYPE));
    DTYPE *dram_weight_p1 = (DTYPE*)malloc(4 * sizeof(DTYPE));
    DTYPE *dram_weight_p2 = (DTYPE*)malloc(4 * sizeof(DTYPE));
    DTYPE *dram_weight_p3 = (DTYPE*)malloc(4 * sizeof(DTYPE));

    if (!dram_weight_p0 || !dram_weight_p1 || !dram_weight_p2 || !dram_weight_p3) {
        printf("Weight port allocation failed!\n");
        return -1;
    }

    // Output ports
    DTYPE *dram_output_p0 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_output_p0) { printf("Output port 0 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p1 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_output_p1) { printf("Output port 1 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p2 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_output_p2) { printf("Output port 2 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p3 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_output_p3) { printf("Output port 3 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p4 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_output_p4) { printf("Output port 4 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p5 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_output_p5) { printf("Output port 5 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p6 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_output_p6) { printf("Output port 6 alloc failed!\n"); return -1; }
    DTYPE *dram_output_p7 = (DTYPE*)malloc(8 * sizeof(DTYPE));
    if (!dram_output_p7) { printf("Output port 7 alloc failed!\n"); return -1; }


    // Zero all ports
    for (size_t i = 0; i < 16; ++i) dram_input_p0[i] = 0.0f;
    for (size_t i = 0; i < 16; ++i) dram_input_p1[i] = 0.0f;
    for (size_t i = 0; i < 16; ++i) dram_input_p2[i] = 0.0f;
    for (size_t i = 0; i < 16; ++i) dram_input_p3[i] = 0.0f;
    for (size_t i = 0; i < 4; ++i) dram_weight_p0[i] = 0.0f;
    for (size_t i = 0; i < 4; ++i) dram_weight_p1[i] = 0.0f;
    for (size_t i = 0; i < 4; ++i) dram_weight_p2[i] = 0.0f;
    for (size_t i = 0; i < 4; ++i) dram_weight_p3[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_output_p0[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_output_p1[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_output_p2[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_output_p3[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_output_p4[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_output_p5[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_output_p6[i] = 0.0f;
    for (size_t i = 0; i < 8; ++i) dram_output_p7[i] = 0.0f;

    // Scatter input into 4 ports by c % 4
    for (int c = 0; c < 4; ++c) {
        int port_index = c % 4;
        int blk        = c / 4;
        for (int y = 0; y < 4; ++y) {
            for (int x = 0; x < 4; ++x) {
                int full_idx = c*4*4 + y*4 + x;
                int b_idx    = blk*4*4 + y*4 + x;
                if (port_index == 0) dram_input_p0[b_idx] = in_full[full_idx];
                if (port_index == 1) dram_input_p1[b_idx] = in_full[full_idx];
                if (port_index == 2) dram_input_p2[b_idx] = in_full[full_idx];
                if (port_index == 3) dram_input_p3[b_idx] = in_full[full_idx];
            }
        }
    }

    // Scatter weights into 4 ports by c % 4
    for (int m = 0; m < 4; ++m) {
      for (int c = 0; c < 4; ++c) {
        int port_index = c % 4;
        int blk        = c / 4;
        for (int r = 0; r < 1; ++r)
          for (int s = 0; s < 1; ++s) {
            int full_idx = m*4*1*1 + c*1*1 + r*1 + s;
            int b_idx    = (m*1 + blk)*1*1 + r*1 + s;
                if (port_index == 0) dram_weight_p0[b_idx] = w_full[full_idx];
                if (port_index == 1) dram_weight_p1[b_idx] = w_full[full_idx];
                if (port_index == 2) dram_weight_p2[b_idx] = w_full[full_idx];
                if (port_index == 3) dram_weight_p3[b_idx] = w_full[full_idx];
          }
      }
    }

#ifdef __BAMBU_SIM__
    m_param_alloc(0, 16 * sizeof(DTYPE));
    m_param_alloc(1, 16 * sizeof(DTYPE));
    m_param_alloc(2, 16 * sizeof(DTYPE));
    m_param_alloc(3, 16 * sizeof(DTYPE));
    m_param_alloc(4, 4 * sizeof(DTYPE));
    m_param_alloc(5, 4 * sizeof(DTYPE));
    m_param_alloc(6, 4 * sizeof(DTYPE));
    m_param_alloc(7, 4 * sizeof(DTYPE));
    m_param_alloc(8, 8 * sizeof(DTYPE));
    m_param_alloc(9, 8 * sizeof(DTYPE));
    m_param_alloc(10, 8 * sizeof(DTYPE));
    m_param_alloc(11, 8 * sizeof(DTYPE));
    m_param_alloc(12, 8 * sizeof(DTYPE));
    m_param_alloc(13, 8 * sizeof(DTYPE));
    m_param_alloc(14, 8 * sizeof(DTYPE));
    m_param_alloc(15, 8 * sizeof(DTYPE));

#endif

    printf("Running HLS top_level function...\n");
    top_level(dram_input_p0, dram_input_p1, dram_input_p2, dram_input_p3, dram_weight_p0, dram_weight_p1, dram_weight_p2, dram_weight_p3, dram_output_p0, dram_output_p1, dram_output_p2, dram_output_p3, dram_output_p4, dram_output_p5, dram_output_p6, dram_output_p7);

    // Gather output ports into out_full
    for (int m = 0; m < 4; ++m)
      for (int p = 0; p < 4; ++p)
        for (int q = 0; q < 4; ++q) {

          int local_filter_index = m % 2;
          int sarows_1 = local_filter_index;
          int local_col_index = q % 4;
          int sacols_0 = local_col_index;
          int output_bank_index = sarows_1*4 + sacols_0;
          int output_filter_tile = m / 2;
          int output_col_tile = q / 4;
          int output_row_tile = p;
          int output_dram_offset = (output_filter_tile * 4 + output_row_tile) * 1 + output_col_tile;

          int out_idx = m*4*4 + p*4 + q;
          switch(output_bank_index) {
            case 0: out_full[out_idx] = dram_output_p0[output_dram_offset]; break;
            case 1: out_full[out_idx] = dram_output_p1[output_dram_offset]; break;
            case 2: out_full[out_idx] = dram_output_p2[output_dram_offset]; break;
            case 3: out_full[out_idx] = dram_output_p3[output_dram_offset]; break;
            case 4: out_full[out_idx] = dram_output_p4[output_dram_offset]; break;
            case 5: out_full[out_idx] = dram_output_p5[output_dram_offset]; break;
            case 6: out_full[out_idx] = dram_output_p6[output_dram_offset]; break;
            case 7: out_full[out_idx] = dram_output_p7[output_dram_offset]; break;
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
    free(dram_input_p2);
    free(dram_input_p3);
    free(dram_weight_p0);
    free(dram_weight_p1);
    free(dram_weight_p2);
    free(dram_weight_p3);
    free(dram_output_p0);
    free(dram_output_p1);
    free(dram_output_p2);
    free(dram_output_p3);
    free(dram_output_p4);
    free(dram_output_p5);
    free(dram_output_p6);
    free(dram_output_p7);

    return e;
}
