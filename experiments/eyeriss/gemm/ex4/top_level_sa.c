#define DTYPE float
#define M_TOTAL 3
#define K_TOTAL 5
#define N_TOTAL 7

/* AXI pragmas for parallel memory buses */
#pragma HLS interface port = dram_w_b0  mode = m_axi offset = direct bundle = gmem_w0
#pragma HLS interface port = dram_w_b1  mode = m_axi offset = direct bundle = gmem_w1
#pragma HLS interface port = dram_in_b0 mode = m_axi offset = direct bundle = gmem_in0
#pragma HLS interface port = dram_in_b1 mode = m_axi offset = direct bundle = gmem_in1
#pragma HLS interface port = dram_out_b0 mode = m_axi offset = direct bundle = gmem_out0

void top_level(DTYPE *dram_w_b0, DTYPE *dram_w_b1, DTYPE *dram_in_b0, DTYPE *dram_in_b1, DTYPE *dram_out_b0)
{
    // SA-shaped Eyeriss GEMM -- loop structure mirrors FF mapping hierarchy
    const int M=3, K=5, N=7;
    const int m_sf=1, m_sacols=1, m_sarows=1;
    const int k_sa=5, k_blks=3, M_tiles=3;

    // M tile (synthetic outer loop)
    for (int m_tile = 0; m_tile < 3; ++m_tile) {
      // DRAM → N:7
      for (int n_dram = 0; n_dram < 7; ++n_dram) {
        // Accumulator: one element per M lane (N handled by outer loop)
        DTYPE acc[1];
        #pragma GCC unroll 1
        for (int mi = 0; mi < 1; ++mi) acc[mi] = 0.0f;

        // SARows M:1 × SACols M:1 × SACols K:5 — unrolled
        #pragma GCC unroll 1
        for (int mri = 0; mri < 1; ++mri) {
          #pragma GCC unroll 1
          for (int mci = 0; mci < 1; ++mci) {
            int acc_m = mri * 1 + mci;
            int m_global = m_tile * 1 + acc_m;
            #pragma GCC unroll 5
            for (int kci = 0; kci < 5; ++kci) {
              int k_global = kci;
              int k_bank = k_global & 1;
              int k_blk  = k_global >> 1;
              DTYPE wv = (k_bank==0) ? dram_w_b0[m_global * k_blks + k_blk]
                                     : dram_w_b1[m_global * k_blks + k_blk];
              DTYPE iv = (k_bank==0) ? dram_in_b0[k_blk * N + n_dram]
                                     : dram_in_b1[k_blk * N + n_dram];
              acc[acc_m] += wv * iv;
            }  // kci
          }  // mci
        }  // mri


        // Write accumulator to banked output ports
        #pragma GCC unroll 1
        for (int ml = 0; ml < 1; ++ml) {
          int out_idx = m_tile * N + n_dram;
          switch(ml) {
            case 0: dram_out_b0[out_idx] = acc[ml]; break;
            default: break;
          }
        }  // ml
      }  // outer
    }  // outer
}
