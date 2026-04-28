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
    // sequential baseline Eyeriss GEMM -- loop structure mirrors FF mapping hierarchy
    const int M=3, K=5, N=7;
    const int m_sf=1, m_sacols=1, m_sarows=1;
    const int k_sa=5, k_blks=3, M_tiles=3;

    // Accumulator: flat 1D at function scope → GCC SROA → 1 scalar regs
    DTYPE accumulator[1];

    // M tile (synthetic outer loop)
    #pragma GCC nounroll
    for (int m_tile = 0; m_tile < 3; ++m_tile) {
      // DRAM_0 = N:7
      #pragma GCC nounroll
      for (int dram_0 = 0; dram_0 < 7; ++dram_0) {
        // Zero accumulator (nounroll — non-spatial init)
        #pragma GCC nounroll
        for (int accumulator_reset_index = 0; accumulator_reset_index < 1; ++accumulator_reset_index) accumulator[accumulator_reset_index] = 0.0f;

        // SARows M:1 × SACols M:1 × SACols K:5
        #pragma GCC nounroll 1
        for (int sarows_0 = 0; sarows_0 < 1; ++sarows_0) {
          #pragma GCC nounroll 1
          for (int sacols_0 = 0; sacols_0 < 1; ++sacols_0) {
            int output_row_lane_index = sarows_0 * 1 + sacols_0;
            int global_m_index = m_tile * 1 + output_row_lane_index;
            #pragma GCC nounroll 5
            for (int sacols_1 = 0; sacols_1 < 5; ++sacols_1) {
              int global_k_index = sacols_1;
              int k_bank_selector = global_k_index & 1;
              int k_block_index  = global_k_index >> 1;
              DTYPE weight_value = (k_bank_selector==0) ? dram_w_b0[global_m_index * k_blks + k_block_index]
                                                         : dram_w_b1[global_m_index * k_blks + k_block_index];
              DTYPE input_value = (k_bank_selector==0) ? dram_in_b0[k_block_index * N + dram_0]
                                                        : dram_in_b1[k_block_index * N + dram_0];
              accumulator[output_row_lane_index] += weight_value * input_value;
            }  // sacols_1
          }  // sacols_0
        }  // sarows_0


        // Write accumulator to banked output ports
        #pragma GCC nounroll 1
        for (int output_row_lane_index = 0; output_row_lane_index < 1; ++output_row_lane_index) {
          int output_dram_offset = m_tile * N + dram_0;
          switch(output_row_lane_index) {
            case 0: dram_out_b0[output_dram_offset] = accumulator[output_row_lane_index]; break;
            default: break;
          }
        }  // output_row_lane_index
      }  // dram_0
    }  // m_tile
}
