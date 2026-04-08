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
    // Sequential GEMM baseline (banked I/O, write-only outputs)
    const int M=3, K=5, N=7;
    const int m_sf=1, k_blks=3, M_tiles=3;

    for (int m = 0; m < M; ++m) {
      for (int n = 0; n < N; ++n) {
        DTYPE acc = 0.0f;
        for (int k = 0; k < K; ++k) {
          int k_bank = k & 1;
          int k_blk  = k >> 1;
          DTYPE wv = (k_bank==0) ? dram_w_b0[m * k_blks + k_blk]
                                 : dram_w_b1[m * k_blks + k_blk];
          DTYPE iv = (k_bank==0) ? dram_in_b0[k_blk * N + n]
                                 : dram_in_b1[k_blk * N + n];
          acc += wv * iv;
        }
        int out_bank = m % m_sf;
        int m_tile   = m / m_sf;
        int out_idx  = m_tile * N + n;
        switch(out_bank) {
          case 0: dram_out_b0[out_idx] = acc; break;
          default: break;
        }
      }
    }
}
