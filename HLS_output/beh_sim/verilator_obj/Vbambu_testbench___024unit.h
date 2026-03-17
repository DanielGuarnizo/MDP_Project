// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vbambu_testbench.h for the primary calling header

#ifndef _VBAMBU_TESTBENCH___024UNIT_H_
#define _VBAMBU_TESTBENCH___024UNIT_H_  // guard

#include "verilated_heavy.h"
#include "Vbambu_testbench__Dpi.h"

//==========

class Vbambu_testbench__Syms;

//----------

VL_MODULE(Vbambu_testbench___024unit) {
  public:
    
    // INTERNAL VARIABLES
  private:
    Vbambu_testbench__Syms* __VlSymsp;  // Symbol table
  public:
    
    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vbambu_testbench___024unit);  ///< Copying not allowed
  public:
    Vbambu_testbench___024unit(const char* name = "TOP");
    ~Vbambu_testbench___024unit();
    
    // INTERNAL METHODS
    void __Vconfigure(Vbambu_testbench__Syms* symsp, bool first);
  private:
    void _ctor_var_reset() VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
