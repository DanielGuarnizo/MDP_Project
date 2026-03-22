/*
 * Politecnico di Milano
 * Code created using PandA - Version: PandA 2024.10 - Revision c2ba6936ca2ed63137095fea0b630a1c66e20e63-main - Date 2026-03-20T17:58:29
 * Bambu executed with: bambu --top-fname=top_level --generate-interface=INFER --compiler=I386_GCC8 --clock-period=5 -O3 -v4 --generate-tb=../../testbench_common.c --tb-param-size=dram_in_b0:288 --tb-param-size=dram_in_b1:288 --tb-param-size=dram_w_b0:288 --tb-param-size=dram_w_b1:288 --tb-param-size=dram_out_b0:4 --tb-param-size=dram_out_b1:4 --tb-param-size=dram_out_b2:4 --tb-param-size=dram_out_b3:4 --tb-param-size=dram_out_b4:4 --tb-param-size=dram_out_b5:4 --tb-param-size=dram_out_b6:4 --tb-param-size=dram_out_b7:4 --simulate ../../top_level_seq.c 
 */

#define _FILE_OFFSET_BITS 64

#define __Inf (1.0 / 0.0)
#define __Nan (0.0 / 0.0)

#ifdef __cplusplus
#undef printf

#include <cstdio>
#include <cstdlib>

typedef bool _Bool;
#else
#include <stdio.h>
#include <stdlib.h>

extern void exit(int status);
#endif

#include <sys/types.h>

#ifdef __AC_NAMESPACE
using namespace __AC_NAMESPACE;
#endif



#ifndef CDECL
#ifdef __cplusplus
#define CDECL extern "C"
#else
#define CDECL
#endif
#endif

#ifndef EXTERN_CDECL
#ifdef __cplusplus
#define EXTERN_CDECL extern "C"
#else
#define EXTERN_CDECL extern
#endif
#endif

#include <mdpi/mdpi_user.h>

CDECL void top_level(float*, float*, float*, float*, float*, float*, float*, float*, float*, float*, float*, float*);


