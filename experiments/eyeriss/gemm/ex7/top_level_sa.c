#define DTYPE float
#define M_TOTAL 4
#define K_TOTAL 4
#define N_TOTAL 1

/* AXI pragmas for parallel memory buses */
#pragma HLS interface port = dram_w_b0  mode = m_axi offset = direct bundle = gmem_w0
#pragma HLS interface port = dram_w_b1  mode = m_axi offset = direct bundle = gmem_w1
#pragma HLS interface port = dram_in_b0 mode = m_axi offset = direct bundle = gmem_in0
#pragma HLS interface port = dram_in_b1 mode = m_axi offset = direct bundle = gmem_in1
#pragma HLS interface port = dram_out_b0 mode = m_axi offset = direct bundle = gmem_out0
#pragma HLS interface port = dram_out_b1 mode = m_axi offset = direct bundle = gmem_out1
#pragma HLS interface port = dram_out_b2 mode = m_axi offset = direct bundle = gmem_out2
#pragma HLS interface port = dram_out_b3 mode = m_axi offset = direct bundle = gmem_out3

void top_level(DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3)
{
    // SA-shaped Eyeriss GEMM -- loop structure mirrors FF mapping hierarchy
    const int M=4, K=4, N=1;
    const int m_sf=4, m_sacols=2, m_sarows=2;
    const int k_sa=2, k_blks=2, M_tiles=1;

    // GlobalBuffer → K:2
    for (int k_gb = 0; k_gb < 2; ++k_gb) {
      // Accumulator: one element per M lane (N handled by outer loop)
      DTYPE acc[4];
      #pragma GCC unroll 4
      for (int mi = 0; mi < 4; ++mi) acc[mi] = 0.0f;

      // SARows M:2 × SACols M:2 × SACols K:2 — unrolled
      #pragma GCC unroll 2
      for (int mri = 0; mri < 2; ++mri) {
        #pragma GCC unroll 2
        for (int mci = 0; mci < 2; ++mci) {
          int acc_m = mri * 2 + mci;
          int m_global = acc_m;
          #pragma GCC unroll 2
          for (int kci = 0; kci < 2; ++kci) {
            int k_global = k_gb * 2 + kci;
            int k_bank = k_global & 1;
            int k_blk  = k_global >> 1;
            DTYPE wv = (k_bank==0) ? dram_w_b0[m_global * k_blks + k_blk]
                                   : dram_w_b1[m_global * k_blks + k_blk];
            DTYPE iv = (k_bank==0) ? dram_in_b0[k_blk * N + 0]
                                   : dram_in_b1[k_blk * N + 0];
            acc[acc_m] += wv * iv;
          }  // kci
        }  // mci
      }  // mri


      // Write accumulator to banked output ports
      #pragma GCC unroll 4
      for (int ml = 0; ml < 4; ++ml) {
        int out_idx = 0 * N + 0;
        switch(ml) {
          case 0: dram_out_b0[out_idx] = acc[ml]; break;
          case 1: dram_out_b1[out_idx] = acc[ml]; break;
          case 2: dram_out_b2[out_idx] = acc[ml]; break;
          case 3: dram_out_b3[out_idx] = acc[ml]; break;
          default: break;
        }
      }  // ml
    }  // outer
}
