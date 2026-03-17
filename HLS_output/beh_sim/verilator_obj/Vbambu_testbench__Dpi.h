// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Prototypes for DPI import and export functions.
//
// Verilator includes this file in all generated .cpp files that use DPI functions.
// Manually include this file where DPI .c import functions are declared to ensure
// the C functions match the expectations of the DPI imports.

#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif
    
    
    // DPI IMPORTS
    // DPI import at HLS_output/simulation/bambu_testbench.v:1509
    extern int m_fini();
    // DPI import at HLS_output/simulation/bambu_testbench.v:1508
    extern unsigned int m_next(unsigned int state);
    // DPI import at HLS_output/simulation/bambu_testbench.v:1727
    extern int m_read(unsigned char id, svLogicVecVal* data, unsigned short int bitsize, unsigned int addr, unsigned char shift);
    // DPI import at HLS_output/simulation/bambu_testbench.v:1729
    extern int m_state(unsigned char id, int data);
    // DPI import at HLS_output/simulation/bambu_testbench.v:1728
    extern int m_write(unsigned char id, const svLogicVecVal* data, unsigned short int bitsize, unsigned int addr, unsigned char shift);
    
#ifdef __cplusplus
}
#endif
