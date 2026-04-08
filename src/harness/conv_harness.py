from __future__ import annotations
from typing import Union
from mapping_types import MappingInfo, ConvBankSpec

def conv_common_defs(mapping) -> str:
    d = mapping.dims
    return (
        f"#define DTYPE float\n"
        f"#define M_TOTAL {int(d['M'])}\n"
        f"#define P_TOTAL {int(d['P'])}\n"
        f"#define Q_TOTAL {int(d['Q'])}\n"
        f"#define C_TOTAL {int(d.get('C', 1))}\n"
        f"#define R_TOTAL {int(d.get('R', 1))}\n"
        f"#define S_TOTAL {int(d.get('S', 1))}\n\n"
    )

def conv_tb_param_sizes(mapping: MappingInfo, bank: ConvBankSpec, spec=None) -> dict:
    in_banks  = bank.in_banks
    d = mapping.dims
    M, P, Q, C, R, S = d["M"], d["P"], d["Q"], d["C"], d["R"], d["S"]
    H, W = P + R - 1, Q + S - 1
    c_blks = (C + in_banks - 1) // in_banks
    in_bank_elems = c_blks * H * W
    w_bank_elems  = M * c_blks * R * S

    if spec is not None:
        N_M_sp = 1
        for dim, f, _ in spec.out_dims:
            if dim == 'M': N_M_sp *= f
        N_Q_sp = 1
        for dim, f, _ in spec.out_dims:
            if dim == 'Q': N_Q_sp *= f
        N_P_sp = 1
        for dim, f, _ in spec.out_dims:
            if dim == 'P': N_P_sp *= f
        out_banks      = spec.N_out
        out_bank_elems = (M // N_M_sp) * (P // N_P_sp) * (Q // N_Q_sp)
    else:
        out_banks      = bank.out_banks
        m_sf, p_sf, q_sf = bank.m_sf, bank.p_sf, bank.q_sf
        Ptiles = bank.p_tiles
        Qtiles = bank.q_tiles
        out_bank_elems = ((M + m_sf - 1) // m_sf) * Ptiles * Qtiles

    sizes = {
        "dram_in_b0": in_bank_elems * 4,
        "dram_in_b1": in_bank_elems * 4,
        "dram_w_b0":  w_bank_elems * 4,
        "dram_w_b1":  w_bank_elems * 4,
    }
    for i in range(out_banks):
        sizes[f"dram_out_b{i}"] = out_bank_elems * 4
    return sizes


def make_conv_testbench(mapping: MappingInfo, bank: ConvBankSpec,
                        gather_bank_c: str = None,
                        out_banks_n: int = None,
                        out_bank_elems_n: int = None) -> str:
    in_banks  = bank.in_banks
    d = mapping.dims
    M, P, Q, C, R, S = d["M"], d["P"], d["Q"], d["C"], d["R"], d["S"]
    H, W = P + R - 1, Q + S - 1

    c_blks = (C + in_banks - 1) // in_banks
    in_bank_elems = c_blks * H * W
    w_bank_elems  = M * c_blks * R * S

    if out_banks_n is not None:
        out_banks      = out_banks_n
        out_bank_elems = out_bank_elems_n
    else:
        # legacy fallback
        m_sf = int(bank.m_sf)
        p_sf = int(bank.p_sf)
        q_sf = int(bank.q_sf)
        Ptiles = (P + p_sf - 1) // p_sf
        Qtiles = (Q + q_sf - 1) // q_sf
        out_banks      = bank.out_banks
        out_bank_elems = ((M + m_sf - 1) // m_sf) * Ptiles * Qtiles

    in_full_e  = C * H * W
    w_full_e   = M * C * R * S
    out_full_e = M * P * Q

    code = ""
    code += conv_common_defs(mapping)

    code += '''
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#ifdef __BAMBU_SIM__
#include <mdpi/mdpi_user.h>
#endif
''' + "\n"


    # top_level prototype
    args = ["DTYPE *dram_in_b0","DTYPE *dram_in_b1","DTYPE *dram_w_b0","DTYPE *dram_w_b1"]
    for i in range(out_banks):
        args.append(f"DTYPE *dram_out_b{i}")
    proto = "void top_level(" + ", ".join(args) + ");\n\n"

    # output gather switch
    gather_switch = ""
    for i in range(out_banks):
        gather_switch += f"            case {i}: out_full[out_idx] = dram_out_b{i}[idx_b]; break;\n"
    if not gather_switch:
        gather_switch = "            default: out_full[out_idx] = 0.0f; break;\n"

    # alloc out banks
    out_alloc = ""
    out_free = ""
    call_args = "dram_in_b0, dram_in_b1, dram_w_b0, dram_w_b1"
    for i in range(out_banks):
        out_alloc += f"    DTYPE *dram_out_b{i} = (DTYPE*)malloc({out_bank_elems} * sizeof(DTYPE));\n"
        out_alloc += f"    if (!dram_out_b{i}) {{ printf(\"Out bank {i} alloc failed!\\n\"); return -1; }}\n"
        out_free += f"    free(dram_out_b{i});\n"
        call_args += f", dram_out_b{i}"

    # mdpi allocs
    mdpi_alloc = ""
    mdpi_alloc += f"    m_param_alloc(0, {in_bank_elems} * sizeof(DTYPE));\n"
    mdpi_alloc += f"    m_param_alloc(1, {in_bank_elems} * sizeof(DTYPE));\n"
    mdpi_alloc += f"    m_param_alloc(2, {w_bank_elems} * sizeof(DTYPE));\n"
    mdpi_alloc += f"    m_param_alloc(3, {w_bank_elems} * sizeof(DTYPE));\n"
    for i in range(out_banks):
        mdpi_alloc += f"    m_param_alloc({4+i}, {out_bank_elems} * sizeof(DTYPE));\n"

    # Build gather block: use FF-order decomposition if provided, else legacy
    if gather_bank_c is not None:
        gather_block = gather_bank_c
    else:
        m_sf = int(bank.m_sf); p_sf = int(bank.p_sf); q_sf = int(bank.q_sf)
        Ptiles = (P + p_sf - 1) // p_sf; Qtiles = (Q + q_sf - 1) // q_sf
        gather_block = (
            f"int lane_m = ({m_sf}==1)?0:(m % {m_sf});\n"
            f"          int lane_p = ({p_sf}==1)?0:(p % {p_sf});\n"
            f"          int lane_q = ({q_sf}==1)?0:(q % {q_sf});\n"
            f"          int bank = (lane_m*{p_sf} + lane_p)*{q_sf} + lane_q;\n"
            f"          int cm = ({m_sf}==1)?m:(m / {m_sf});\n"
            f"          int cp = ({p_sf}==1)?p:(p / {p_sf});\n"
            f"          int cq = ({q_sf}==1)?q:(q / {q_sf});\n"
            f"          int idx_b = (cm*{Ptiles} + cp)*{Qtiles} + cq;"
        )

    code += f"""
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#ifdef __BAMBU_SIM__
#include <mdpi/mdpi_user.h>
#endif

{proto}

static void init(DTYPE *in_full, DTYPE *w_full, DTYPE *out_full, DTYPE *gold,
                 size_t si, size_t sw, size_t so) {{
    for (size_t i = 0; i < si; ++i) in_full[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < sw; ++i) w_full[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < so; ++i) {{ out_full[i] = 0.0f; gold[i] = 0.0f; }}
}}

static void golden_reference(DTYPE *in_full, DTYPE *w_full, DTYPE *out_golden) {{
    for (int m = 0; m < {M}; ++m)
      for (int c = 0; c < {C}; ++c)
        for (int r = 0; r < {R}; ++r)
          for (int s = 0; s < {S}; ++s)
            for (int p = 0; p < {P}; ++p)
              for (int q = 0; q < {Q}; ++q) {{
                int out_idx = m*{P}*{Q} + p*{Q} + q;
                int w_idx   = m*{C}*{R}*{S} + c*{R}*{S} + r*{S} + s;
                int in_idx  = c*{H}*{W} + (p+r)*{W} + (q+s);
                out_golden[out_idx] += w_full[w_idx] * in_full[in_idx];
              }}
}}

static int compare(DTYPE *out, DTYPE *gold, size_t so) {{
    const float eps = 1e-3f;
    int errs = 0;
    for (size_t i = 0; i < so; ++i) {{
        float diff = fabs(out[i]-gold[i]);
        if (diff > eps) {{
            printf("ERROR at index %zu: HLS=%.6f Gold=%.6f diff=%.6f\\n", i, out[i], gold[i], diff);
            if (++errs > 20) return errs;
        }}
    }}
    return errs;
}}

int main() {{
    size_t in_full_e  = {in_full_e};
    size_t w_full_e   = {w_full_e};
    size_t out_full_e = {out_full_e};

    DTYPE *in_full  = (DTYPE*)malloc(in_full_e  * sizeof(DTYPE));
    DTYPE *w_full   = (DTYPE*)malloc(w_full_e   * sizeof(DTYPE));
    DTYPE *out_full = (DTYPE*)malloc(out_full_e * sizeof(DTYPE));
    DTYPE *gold     = (DTYPE*)malloc(out_full_e * sizeof(DTYPE));

    if (!in_full || !w_full || !out_full || !gold) {{
        printf("Memory allocation failed!\\n");
        return -1;
    }}

    init(in_full, w_full, out_full, gold, in_full_e, w_full_e, out_full_e);
    golden_reference(in_full, w_full, gold);

    // Banked inputs/weights
    DTYPE *dram_in_b0 = (DTYPE*)malloc({in_bank_elems} * sizeof(DTYPE));
    DTYPE *dram_in_b1 = (DTYPE*)malloc({in_bank_elems} * sizeof(DTYPE));
    DTYPE *dram_w_b0  = (DTYPE*)malloc({w_bank_elems} * sizeof(DTYPE));
    DTYPE *dram_w_b1  = (DTYPE*)malloc({w_bank_elems} * sizeof(DTYPE));
    if (!dram_in_b0 || !dram_in_b1 || !dram_w_b0 || !dram_w_b1) {{
        printf("Bank allocation failed!\\n");
        return -1;
    }}

    // Outputs
{out_alloc}

    // Zero
    for (size_t i = 0; i < {in_bank_elems}; ++i) {{ dram_in_b0[i]=0.0f; dram_in_b1[i]=0.0f; }}
    for (size_t i = 0; i < {w_bank_elems};  ++i) {{ dram_w_b0[i]=0.0f; dram_w_b1[i]=0.0f; }}
"""
    for i in range(out_banks):
        code += f"    for (size_t i = 0; i < {out_bank_elems}; ++i) dram_out_b{i}[i] = 0.0f;\n"

    code += f"""
    // Scatter input into 2 banks by c%2
    for (int c = 0; c < {C}; ++c) {{
        int bank = c & 1;
        int blk  = c >> 1;
        for (int y = 0; y < {H}; ++y) {{
            for (int x = 0; x < {W}; ++x) {{
                int full_idx = c*{H}*{W} + y*{W} + x;
                int b_idx    = blk*{H}*{W} + y*{W} + x;
                if (bank==0) dram_in_b0[b_idx] = in_full[full_idx];
                else         dram_in_b1[b_idx] = in_full[full_idx];
            }}
        }}
    }}

    // Scatter weights into 2 banks by c%2
    for (int m = 0; m < {M}; ++m) {{
      for (int c = 0; c < {C}; ++c) {{
        int bank = c & 1;
        int blk  = c >> 1;
        for (int r = 0; r < {R}; ++r)
          for (int s = 0; s < {S}; ++s) {{
            int full_idx = m*{C}*{R}*{S} + c*{R}*{S} + r*{S} + s;
            int b_idx    = (m*{c_blks} + blk)*{R}*{S} + r*{S} + s;
            if (bank==0) dram_w_b0[b_idx] = w_full[full_idx];
            else         dram_w_b1[b_idx] = w_full[full_idx];
          }}
      }}
    }}

#ifdef __BAMBU_SIM__
{mdpi_alloc}
#endif

    printf("Running HLS top_level function...\\n");
    top_level({call_args});

    // Gather out banks into out_full
    for (int m = 0; m < {M}; ++m)
      for (int p = 0; p < {P}; ++p)
        for (int q = 0; q < {Q}; ++q) {{

          {gather_block}

          int out_idx = m*{P}*{Q} + p*{Q} + q;
          switch(bank) {{
{gather_switch}            default: out_full[out_idx] = 0.0f; break;
          }}
        }}

    printf("Comparing results...\\n");
    int e = compare(out_full, gold, out_full_e);
    if (e==0) printf("SUCCESS: The results match the golden reference!\\n");
    else printf("FAILURE: Found %d mismatches.\\n", e);

    free(in_full); free(w_full); free(out_full); free(gold);
    free(dram_in_b0); free(dram_in_b1); free(dram_w_b0); free(dram_w_b1);
{out_free}
    return e;
}}
"""
    return code