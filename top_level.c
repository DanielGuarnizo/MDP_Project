#define DTYPE float
#define M_TOTAL 4
#define P_TOTAL 4
#define Q_TOTAL 4
#define C_TOTAL 4
#define R_TOTAL 3
#define S_TOTAL 3


/* AXI pragmas for parallel memory buses */
#pragma HLS interface port = dram_in mode = m_axi offset = direct bundle = gmem0
#pragma HLS interface port = dram_w mode = m_axi offset = direct bundle = gmem1
#pragma HLS interface port = dram_out_b0 mode = m_axi offset = direct bundle = gmem2_b0
#pragma HLS interface port = dram_out_b1 mode = m_axi offset = direct bundle = gmem2_b1
#pragma HLS interface port = dram_out_b2 mode = m_axi offset = direct bundle = gmem2_b2
#pragma HLS interface port = dram_out_b3 mode = m_axi offset = direct bundle = gmem2_b3
#pragma HLS interface port = dram_out_b4 mode = m_axi offset = direct bundle = gmem2_b4
#pragma HLS interface port = dram_out_b5 mode = m_axi offset = direct bundle = gmem2_b5
#pragma HLS interface port = dram_out_b6 mode = m_axi offset = direct bundle = gmem2_b6
#pragma HLS interface port = dram_out_b7 mode = m_axi offset = direct bundle = gmem2_b7

void top_level(DTYPE *dram_in, DTYPE *dram_w, DTYPE *dram_out_b0, DTYPE *dram_out_b1, DTYPE *dram_out_b2, DTYPE *dram_out_b3, DTYPE *dram_out_b4, DTYPE *dram_out_b5, DTYPE *dram_out_b6, DTYPE *dram_out_b7) {
    // Pointers to output banks
    DTYPE* out_banks[8] = {dram_out_b0, dram_out_b1, dram_out_b2, dram_out_b3, dram_out_b4, dram_out_b5, dram_out_b6, dram_out_b7};

    // Level: DRAM
    for (int q_dram = 0; q_dram < 2; ++q_dram) {
        // Level: GlobalBuffer
        for (int p_globalbuffer = 0; p_globalbuffer < 4; ++p_globalbuffer) {
            // Level: SACols
            #pragma GCC unroll 4
            for (int m_sacols = 0; m_sacols < 4; ++m_sacols) {
                #pragma GCC unroll 2
                for (int q_sacols = 0; q_sacols < 2; ++q_sacols) {
                    // Level: SARows
                    // Level: InRegister
                    // Level: WRegister
                    for (int r_wregister = 0; r_wregister < 3; ++r_wregister) {
                        // Level: OutRegister
                        int global_m = m_sacols;
                        int global_p = p_globalbuffer;
                        int global_q = q_dram * 2 + q_sacols;
                        int lane_m = global_m % 4;
                        int lane_p = global_p % 1;
                        int lane_q = global_q % 2;
                        int out_bank = ((lane_m)*1 + (lane_p))*2 + (lane_q);
                        int coarse_m = global_m / 4;
                        int coarse_p = global_p / 1;
                        int coarse_q = global_q / 2;
                        int out_idx_b = ((coarse_m)*4 + (coarse_p))*2 + (coarse_q);
                        DTYPE acc = out_banks[out_bank][out_idx_b];
                        DTYPE mac_0 = dram_w[global_m*(4*3*3) + (((0) + 0*1))*(3*3) + (r_wregister)*3 + (((0) + 0*1))] * dram_in[(((0) + 0*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 0*1)))];
                        DTYPE mac_1 = dram_w[global_m*(4*3*3) + (((0) + 1*1))*(3*3) + (r_wregister)*3 + (((0) + 0*1))] * dram_in[(((0) + 1*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 0*1)))];
                        DTYPE mac_2 = dram_w[global_m*(4*3*3) + (((0) + 2*1))*(3*3) + (r_wregister)*3 + (((0) + 0*1))] * dram_in[(((0) + 2*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 0*1)))];
                        DTYPE mac_3 = dram_w[global_m*(4*3*3) + (((0) + 3*1))*(3*3) + (r_wregister)*3 + (((0) + 0*1))] * dram_in[(((0) + 3*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 0*1)))];
                        DTYPE mac_4 = dram_w[global_m*(4*3*3) + (((0) + 0*1))*(3*3) + (r_wregister)*3 + (((0) + 1*1))] * dram_in[(((0) + 0*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 1*1)))];
                        DTYPE mac_5 = dram_w[global_m*(4*3*3) + (((0) + 1*1))*(3*3) + (r_wregister)*3 + (((0) + 1*1))] * dram_in[(((0) + 1*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 1*1)))];
                        DTYPE mac_6 = dram_w[global_m*(4*3*3) + (((0) + 2*1))*(3*3) + (r_wregister)*3 + (((0) + 1*1))] * dram_in[(((0) + 2*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 1*1)))];
                        DTYPE mac_7 = dram_w[global_m*(4*3*3) + (((0) + 3*1))*(3*3) + (r_wregister)*3 + (((0) + 1*1))] * dram_in[(((0) + 3*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 1*1)))];
                        DTYPE mac_8 = dram_w[global_m*(4*3*3) + (((0) + 0*1))*(3*3) + (r_wregister)*3 + (((0) + 2*1))] * dram_in[(((0) + 0*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 2*1)))];
                        DTYPE mac_9 = dram_w[global_m*(4*3*3) + (((0) + 1*1))*(3*3) + (r_wregister)*3 + (((0) + 2*1))] * dram_in[(((0) + 1*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 2*1)))];
                        DTYPE mac_10 = dram_w[global_m*(4*3*3) + (((0) + 2*1))*(3*3) + (r_wregister)*3 + (((0) + 2*1))] * dram_in[(((0) + 2*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 2*1)))];
                        DTYPE mac_11 = dram_w[global_m*(4*3*3) + (((0) + 3*1))*(3*3) + (r_wregister)*3 + (((0) + 2*1))] * dram_in[(((0) + 3*1))*(6*6) + (global_p + (r_wregister))*6 + (global_q + (((0) + 2*1)))];
                        // Adder tree stage 1
                        DTYPE rc_s1_0 = mac_0 + mac_1;
                        DTYPE rc_s1_1 = mac_2 + mac_3;
                        DTYPE rc_s1_2 = mac_4 + mac_5;
                        DTYPE rc_s1_3 = mac_6 + mac_7;
                        DTYPE rc_s1_4 = mac_8 + mac_9;
                        DTYPE rc_s1_5 = mac_10 + mac_11;
                        // Adder tree stage 2
                        DTYPE rc_s2_0 = rc_s1_0 + rc_s1_1;
                        DTYPE rc_s2_1 = rc_s1_2 + rc_s1_3;
                        DTYPE rc_s2_2 = rc_s1_4 + rc_s1_5;
                        // Adder tree stage 3
                        DTYPE rc_s3_0 = rc_s2_0 + rc_s2_1;
                        // Adder tree stage 4
                        DTYPE rc_s4_0 = rc_s3_0 + rc_s2_2;
                        acc += rc_s4_0;
                        out_banks[out_bank][out_idx_b] = acc;
                    }
                }
            }
        }
    }
}
