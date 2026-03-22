// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef _VBAMBU_TESTBENCH__SYMS_H_
#define _VBAMBU_TESTBENCH__SYMS_H_  // guard

#include "verilated_heavy.h"

// INCLUDE MODULE CLASSES
#include "Vbambu_testbench.h"
#include "Vbambu_testbench___024unit.h"

// DPI TYPES for DPI Export callbacks (Internal use)

// SYMS CLASS
class Vbambu_testbench__Syms : public VerilatedSyms {
  public:
    
    // LOCAL STATE
    const char* __Vm_namep;
    bool __Vm_didInit;
    
    // SUBCELL STATE
    Vbambu_testbench*              TOPp;
    
    // CREATORS
    Vbambu_testbench__Syms(Vbambu_testbench* topp, const char* namep);
    ~Vbambu_testbench__Syms() {}
    
    // METHODS
    inline const char* name() { return __Vm_namep; }
    
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard
