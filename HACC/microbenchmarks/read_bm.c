/* read_bm.c
 * AXI read latency microbenchmark for Alveo U55C / Bambu HLS.
 *
 * Reads N floats sequentially from one HBM port (dram_input_p0) and
 * returns their sum via dram_output_p0[0].  The accumulation into `sum`
 * forces every load to be architecturally visible — no dead-code elimination.
 *
 * Sequential loop (no unroll) guarantees one AXI transaction per iteration,
 * giving a clean per-access latency signal.
 *
 * Bambu synthesis command:
 *   bambu read_bm.c \
 *     --top-fname=read_bm \
 *     --device-name=xcu55c-fsvh2892-2L-e \
 *     --clock-period=3.333 \
 *     --generate-interface=WB4 \
 *     --experimental-set=BAMBU \
 *     --compiler=I386_GCC8 \
 *     -O3 \
 *     --backend-script-extensions=<vivado_backend.tcl>
 */

#pragma HLS interface port = dram_input_p0  mode = m_axi offset = direct bundle = gmem_0
#pragma HLS interface port = dram_output_p0 mode = m_axi offset = direct bundle = gmem_0

__attribute__((noinline))
void read_bm(float* dram_input_p0, float* dram_output_p0, int n)
{
    float sum = 0.0f;

    #pragma GCC nounroll
    for (int i = 0; i < n; ++i) {
        sum += dram_input_p0[i];
    }

    /* Write sum to prevent dead-code elimination of the entire read loop */
    dram_output_p0[0] = sum;
}
