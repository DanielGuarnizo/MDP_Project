/* write_bm.c
 * AXI write latency microbenchmark for Alveo U55C / Bambu HLS.
 *
 * Writes a constant float (1.0f) to N consecutive addresses on one HBM
 * port (dram_output_p0).  There are no reads — the AXI traffic is
 * 100 % writes, giving a clean per-write-transaction latency signal.
 *
 * Sequential loop (no unroll) guarantees one AXI transaction per iteration.
 *
 * Bambu synthesis command:
 *   bambu write_bm.c \
 *     --top-fname=write_bm \
 *     --device-name=xcu55c-fsvh2892-2L-e \
 *     --clock-period=3.333 \
 *     --generate-interface=WB4 \
 *     --experimental-set=BAMBU \
 *     --compiler=I386_GCC8 \
 *     -O3 \
 *     --backend-script-extensions=<vivado_backend.tcl>
 */

#pragma HLS interface port = dram_output_p0 mode = m_axi offset = direct bundle = gmem_0

__attribute__((noinline))
void write_bm(float* dram_output_p0, int n)
{
    #pragma GCC nounroll
    for (int i = 0; i < n; ++i) {
        dram_output_p0[i] = 1.0f;
    }
}
