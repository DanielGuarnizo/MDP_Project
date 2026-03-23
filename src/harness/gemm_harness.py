from __future__ import annotations
from mapping_types import MappingInfo


def gemm_tb_param_sizes(mapping: MappingInfo, bank) -> dict:
    """Return {port_name: bytes} for each AXI port."""
    sizes = {
        "dram_w_b0":  bank.w_bank_elems * 4,
        "dram_w_b1":  bank.w_bank_elems * 4,
        "dram_in_b0": bank.in_bank_elems * 4,
        "dram_in_b1": bank.in_bank_elems * 4,
    }
    for i in range(bank.out_banks):
        sizes[f"dram_out_b{i}"] = bank.out_bank_elems * 4
    return sizes


def make_gemm_testbench(mapping: MappingInfo, bank) -> str:
    """Generate testbench_common.c for Eyeriss GEMM."""
    d = mapping.dims
    M = int(d["M"]); K = int(d["K"]); N = int(d["N"])
    m_sf          = bank.m_sf
    k_blks        = bank.k_blks
    out_banks     = bank.out_banks
    in_bank_elems  = bank.in_bank_elems
    w_bank_elems   = bank.w_bank_elems
    out_bank_elems = bank.out_bank_elems

    # top_level prototype (weights first, then inputs, then outputs)
    args = ["DTYPE *dram_w_b0", "DTYPE *dram_w_b1",
            "DTYPE *dram_in_b0", "DTYPE *dram_in_b1"]
    for i in range(out_banks):
        args.append(f"DTYPE *dram_out_b{i}")
    proto = "void top_level(" + ", ".join(args) + ");"

    # gather switch: bank = m % m_sf, idx_b = (m / m_sf) * N + n
    gather_switch = ""
    for i in range(out_banks):
        gather_switch += f"            case {i}: out_full[out_idx] = dram_out_b{i}[idx_b]; break;\n"

    # output bank alloc / free / call args
    out_alloc = ""
    out_free  = ""
    call_args = "dram_w_b0, dram_w_b1, dram_in_b0, dram_in_b1"
    for i in range(out_banks):
        out_alloc += (
            f"    DTYPE *dram_out_b{i} = (DTYPE*)malloc({out_bank_elems} * sizeof(DTYPE));\n"
            f"    if (!dram_out_b{i}) {{ printf(\"Out bank {i} alloc failed!\\n\"); return -1; }}\n"
        )
        out_free  += f"    free(dram_out_b{i});\n"
        call_args += f", dram_out_b{i}"

    # mdpi allocs (param order must match top_level signature)
    mdpi_alloc = (
        f"    m_param_alloc(0, {w_bank_elems} * sizeof(DTYPE));\n"
        f"    m_param_alloc(1, {w_bank_elems} * sizeof(DTYPE));\n"
        f"    m_param_alloc(2, {in_bank_elems} * sizeof(DTYPE));\n"
        f"    m_param_alloc(3, {in_bank_elems} * sizeof(DTYPE));\n"
    )
    for i in range(out_banks):
        mdpi_alloc += f"    m_param_alloc({4+i}, {out_bank_elems} * sizeof(DTYPE));\n"

    out_zeros = ""
    for i in range(out_banks):
        out_zeros += f"    for (size_t i = 0; i < {out_bank_elems}; ++i) dram_out_b{i}[i] = 0.0f;\n"

    return f"""#define DTYPE float
#define M_TOTAL {M}
#define K_TOTAL {K}
#define N_TOTAL {N}

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#ifdef __BAMBU_SIM__
#include <mdpi/mdpi_user.h>
#endif

{proto}

static void init(DTYPE *A, DTYPE *B, size_t sa, size_t sb) {{
    for (size_t i = 0; i < sa; ++i) A[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < sb; ++i) B[i] = (DTYPE)rand() / RAND_MAX;
}}

static void golden_reference(DTYPE *A, DTYPE *B, DTYPE *C) {{
    for (int m = 0; m < {M}; ++m)
      for (int n = 0; n < {N}; ++n) {{
        DTYPE acc = 0.0f;
        for (int k = 0; k < {K}; ++k)
            acc += A[m * {K} + k] * B[k * {N} + n];
        C[m * {N} + n] = acc;
      }}
}}

static int compare(DTYPE *out, DTYPE *gold, size_t n) {{
    const float eps = 1e-3f;
    int errs = 0;
    for (size_t i = 0; i < n; ++i) {{
        float diff = fabs(out[i] - gold[i]);
        if (diff > eps) {{
            printf("ERROR at %zu: HLS=%.6f Gold=%.6f diff=%.6f\\n", i, out[i], gold[i], diff);
            if (++errs > 20) return errs;
        }}
    }}
    return errs;
}}

int main() {{
    size_t A_elems = {M} * {K};
    size_t B_elems = {K} * {N};
    size_t C_elems = {M} * {N};

    DTYPE *A_full   = (DTYPE*)malloc(A_elems * sizeof(DTYPE));
    DTYPE *B_full   = (DTYPE*)malloc(B_elems * sizeof(DTYPE));
    DTYPE *out_full = (DTYPE*)malloc(C_elems * sizeof(DTYPE));
    DTYPE *gold     = (DTYPE*)malloc(C_elems * sizeof(DTYPE));

    if (!A_full || !B_full || !out_full || !gold) {{
        printf("Alloc failed!\\n"); return -1;
    }}

    for (size_t i = 0; i < C_elems; ++i) {{ out_full[i] = 0.0f; gold[i] = 0.0f; }}
    init(A_full, B_full, A_elems, B_elems);
    golden_reference(A_full, B_full, gold);

    DTYPE *dram_w_b0  = (DTYPE*)malloc({w_bank_elems}  * sizeof(DTYPE));
    DTYPE *dram_w_b1  = (DTYPE*)malloc({w_bank_elems}  * sizeof(DTYPE));
    DTYPE *dram_in_b0 = (DTYPE*)malloc({in_bank_elems} * sizeof(DTYPE));
    DTYPE *dram_in_b1 = (DTYPE*)malloc({in_bank_elems} * sizeof(DTYPE));
    if (!dram_w_b0 || !dram_w_b1 || !dram_in_b0 || !dram_in_b1) {{
        printf("Bank alloc failed!\\n"); return -1;
    }}
{out_alloc}
    for (size_t i = 0; i < {w_bank_elems};  ++i) {{ dram_w_b0[i] = 0.0f; dram_w_b1[i] = 0.0f; }}
    for (size_t i = 0; i < {in_bank_elems}; ++i) {{ dram_in_b0[i] = 0.0f; dram_in_b1[i] = 0.0f; }}
{out_zeros}
    // Scatter A[M x K] into 2 weight banks by k%2
    for (int m = 0; m < {M}; ++m) {{
      for (int k = 0; k < {K}; ++k) {{
        int k_bank = k & 1, k_blk = k >> 1;
        DTYPE v = A_full[m * {K} + k];
        if (k_bank == 0) dram_w_b0[m * {k_blks} + k_blk] = v;
        else             dram_w_b1[m * {k_blks} + k_blk] = v;
      }}
    }}

    // Scatter B[K x N] into 2 input banks by k%2
    for (int k = 0; k < {K}; ++k) {{
      int k_bank = k & 1, k_blk = k >> 1;
      for (int n = 0; n < {N}; ++n) {{
        DTYPE v = B_full[k * {N} + n];
        if (k_bank == 0) dram_in_b0[k_blk * {N} + n] = v;
        else             dram_in_b1[k_blk * {N} + n] = v;
      }}
    }}

#ifdef __BAMBU_SIM__
{mdpi_alloc}
#endif

    printf("Running HLS top_level function...\\n");
    top_level({call_args});

    // Gather C from output banks: bank = m % m_sf, idx_b = (m / m_sf) * N + n
    for (int m = 0; m < {M}; ++m)
      for (int n = 0; n < {N}; ++n) {{
        int bank  = m % {m_sf};
        int idx_b = (m / {m_sf}) * {N} + n;
        int out_idx = m * {N} + n;
        switch(bank) {{
{gather_switch}            default: out_full[out_idx] = 0.0f; break;
        }}
      }}

    printf("Comparing results...\\n");
    int e = compare(out_full, gold, C_elems);
    if (e == 0) printf("SUCCESS: Results match golden reference!\\n");
    else printf("FAILURE: Found %d mismatches.\\n", e);

    free(A_full); free(B_full); free(out_full); free(gold);
    free(dram_w_b0); free(dram_w_b1); free(dram_in_b0); free(dram_in_b1);
{out_free}
    return e;
}}
"""
