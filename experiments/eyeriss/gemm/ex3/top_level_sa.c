#define DTYPE float
#define M_TOTAL 8
#define K_TOTAL 16
#define N_TOTAL 4

/* AXI pragmas for parallel memory buses */
#pragma HLS interface port = dram_w_b0  mode = m_axi offset = direct bundle = gmem_w0
#pragma HLS interface port = dram_w_b1  mode = m_axi offset = direct bundle = gmem_w1
#pragma HLS interface port = dram_in_b0 mode = m_axi offset = direct bundle = gmem_in0
#pragma HLS interface port = dram_in_b1 mode = m_axi offset = direct bundle = gmem_in1
#pragma HLS interface port = dram_out_b0 mode = m_axi offset = direct bundle = gmem_out0
#pragma HLS interface port = dram_out_b1 mode = m_axi offset = direct bundle = gmem_out1
#pragma HLS interface port = dram_out_b2 mode = m_axi offset = direct bundle = gmem_out2
#pragma HLS interface port = dram_out_b3 mode = m_axi offset = direct bundle = gmem_out3
#pragma HLS interface port = dram_out_b4 mode = m_axi offset = direct bundle = gmem_out4
#pragma HLS interface port = dram_out_b5 mode = m_axi offset = direct bundle = gmem_out5
#pragma HLS interface port = dram_out_b6 mode = m_axi offset = direct bundle = gmem_out6
#pragma HLS interface port = dram_out_b7 mode = m_axi offset = direct bundle = gmem_out7

void top_level(DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7)
{
    // SA-shaped Eyeriss GEMM -- loop structure mirrors FF mapping hierarchy
    const int M=8, K=16, N=4;
    const int m_sf=8, m_sacols=1, m_sarows=8;
    const int k_sa=8, k_blks=8, M_tiles=1;

    // GlobalBuffer → N:4
    for (int n_gb = 0; n_gb < 4; ++n_gb) {
      // Accumulator: one element per M lane (N handled by outer loop)
      DTYPE acc[8];
      #pragma GCC unroll 8
      for (int mi = 0; mi < 8; ++mi) acc[mi] = 0.0f;

      // WRegister → K:2 (sequential)
      for (int k = 0; k < 2; ++k) {
        // SARows M:8 × SACols M:1 × SACols K:8 — unrolled
        #pragma GCC unroll 8
        for (int mri = 0; mri < 8; ++mri) {
          #pragma GCC unroll 1
          for (int mci = 0; mci < 1; ++mci) {
            int acc_m = mri * 1 + mci;
            int m_global = acc_m;
            #pragma GCC unroll 8
            for (int kci = 0; kci < 8; ++kci) {
              int k_global = k * 8 + kci;
              int k_bank = k_global & 1;
              int k_blk  = k_global >> 1;
              DTYPE wv = (k_bank==0) ? dram_w_b0[m_global * k_blks + k_blk]
                                     : dram_w_b1[m_global * k_blks + k_blk];
              DTYPE iv = (k_bank==0) ? dram_in_b0[k_blk * N + n_gb]
                                     : dram_in_b1[k_blk * N + n_gb];
              acc[acc_m] += wv * iv;
            }  // kci
          }  // mci
        }  // mri

      }  // inner seq

      // Write accumulator to banked output ports
      #pragma GCC unroll 8
      for (int ml = 0; ml < 8; ++ml) {
        int out_idx = 0 * N + n_gb;
        switch(ml) {
          case 0: dram_out_b0[out_idx] = acc[ml]; break;
          case 1: dram_out_b1[out_idx] = acc[ml]; break;
          case 2: dram_out_b2[out_idx] = acc[ml]; break;
          case 3: dram_out_b3[out_idx] = acc[ml]; break;
          case 4: dram_out_b4[out_idx] = acc[ml]; break;
          case 5: dram_out_b5[out_idx] = acc[ml]; break;
          case 6: dram_out_b6[out_idx] = acc[ml]; break;
          case 7: dram_out_b7[out_idx] = acc[ml]; break;
          default: break;
        }
      }  // ml
    }  // outer
}
