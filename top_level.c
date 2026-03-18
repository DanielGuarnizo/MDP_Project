#define DTYPE float
#define M_TOTAL 8
#define K_TOTAL 8
#define N_TOTAL 8


/* AXI pragmas for parallel memory buses */
#pragma HLS interface port = dram_in mode = m_axi offset = direct bundle = gmem0
#pragma HLS interface port = dram_w mode = m_axi offset = direct bundle = gmem1
#pragma HLS interface port = dram_out mode = m_axi offset = direct bundle = gmem2

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
