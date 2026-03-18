#!/usr/bin/env python3
from __future__ import annotations
from typing import Optional
from generator_common import MappingInfo


def make_conv_testbench(gen, out_banks: int, in_banks: int = 2, w_banks: int = 2) -> str:
    """
    Generates a C testbench for banked CONV.

    Assumptions:
      - in banks split by c%2 and c_blk=c>>1, layout: [c_blk][H][W]
      - w banks split by c%2 and c_blk=c>>1, layout: [m][c_blk][R][S]
      - out banks use gen.out_bank_factors() mapping and per-bank layout [cm][cp][cq]
    """
    info: MappingInfo = gen.info
    d = info.dims
    M = d["M"]; P = d["P"]; Q = d["Q"]; C = d["C"]; R = d["R"]; S = d["S"]
    H = P + R - 1
    W = Q + S - 1

    m_sf, p_sf, q_sf = gen.out_bank_factors()
    Ptiles = (P + p_sf - 1) // p_sf
    Qtiles = (Q + q_sf - 1) // q_sf
    # each out bank length
    out_bank_elems = ((M + m_sf - 1)//m_sf) * Ptiles * Qtiles

    # in/w bank lengths
    c_blks = (C + in_banks - 1)//in_banks  # with 2 banks and C=4 => 2
    in_bank_elems = c_blks * H * W
    w_bank_elems  = M * c_blks * R * S

    # full tensors
    in_full_e  = C * H * W
    w_full_e   = M * C * R * S
    out_full_e = M * P * Q

    code = r'''
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#ifdef __BAMBU_SIM__
#include <mdpi/mdpi_user.h>
#endif
''' + "\n"

    # prototype
    args = ["DTYPE *dram_in_b0","DTYPE *dram_in_b1","DTYPE *dram_w_b0","DTYPE *dram_w_b1"]
    for i in range(out_banks):
        args.append(f"DTYPE *dram_out_b{i}")
    code += "void top_level(" + ", ".join(args) + ");\n\n"

    code += f"""
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
        if (fabs(out[i]-gold[i]) > eps) {{
            printf("ERROR at index %zu: HLS_val=%.6f, Golden_val=%.6f\\n", i, out[i], gold[i]);
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

    // Banked outputs
"""
    for i in range(out_banks):
        code += f"    DTYPE *dram_out_b{i} = (DTYPE*)malloc({out_bank_elems} * sizeof(DTYPE));\n"
        code += f"    if (!dram_out_b{i}) {{ printf(\"Out bank {i} alloc failed!\\n\"); return -1; }}\n"
    code += "\n"

    # zero banks
    code += f"""
    for (size_t i = 0; i < {in_bank_elems}; ++i) {{ dram_in_b0[i]=0.0f; dram_in_b1[i]=0.0f; }}
    for (size_t i = 0; i < {w_bank_elems};  ++i) {{ dram_w_b0[i]=0.0f;  dram_w_b1[i]=0.0f;  }}
"""
    for i in range(out_banks):
        code += f"    for (size_t i = 0; i < {out_bank_elems}; ++i) dram_out_b{i}[i] = 0.0f;\n"
    code += "\n"

    # scatter in
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
"""

    # mdpi allocs
    code += "\n#ifdef __BAMBU_SIM__\n"
    code += f"    m_param_alloc(0, {in_bank_elems} * sizeof(DTYPE));\n"
    code += f"    m_param_alloc(1, {in_bank_elems} * sizeof(DTYPE));\n"
    code += f"    m_param_alloc(2, {w_bank_elems}  * sizeof(DTYPE));\n"
    code += f"    m_param_alloc(3, {w_bank_elems}  * sizeof(DTYPE));\n"
    for i in range(out_banks):
        code += f"    m_param_alloc({4+i}, {out_bank_elems} * sizeof(DTYPE));\n"
    code += "#endif\n\n"

    # call top_level
    call_args = ["dram_in_b0","dram_in_b1","dram_w_b0","dram_w_b1"] + [f"dram_out_b{i}" for i in range(out_banks)]
    code += f"""
    printf("Running HLS top_level function...\\n");
    top_level({", ".join(call_args)});

    // Gather out banks into out_full
    for (int m = 0; m < {M}; ++m)
      for (int p = 0; p < {P}; ++p)
        for (int q = 0; q < {Q}; ++q) {{
          int lane_m = ({m_sf}==1)?0:(m % {m_sf});
          int lane_p = ({p_sf}==1)?0:(p % {p_sf});
          int lane_q = ({q_sf}==1)?0:(q % {q_sf});
          int bank = (lane_m*{p_sf} + lane_p)*{q_sf} + lane_q;

          int cm = ({m_sf}==1)?m:(m / {m_sf});
          int cp = ({p_sf}==1)?p:(p / {p_sf});
          int cq = ({q_sf}==1)?q:(q / {q_sf});
          int idx_b = (cm*{Ptiles} + cp)*{Qtiles} + cq;

          int out_idx = m*{P}*{Q} + p*{Q} + q;
          switch(bank) {{
"""
    for i in range(out_banks):
        code += f"            case {i}: out_full[out_idx] = dram_out_b{i}[idx_b]; break;\n"
    code += """            default: out_full[out_idx] = 0.0f; break;
          }
        }

    printf("Comparing results...\\n");
    int e = compare(out_full, gold, out_full_e);
    if (e==0) printf("SUCCESS: The results match the golden reference!\\n");
    else printf("FAILURE: Found %d mismatches.\\n", e);

    return e;
}
"""
    return code

def conv_tb_param_sizes(gen, out_banks: int, in_banks: int = 2, w_banks: int = 2) -> dict:
    info: MappingInfo = gen.info
    d = info.dims
    M = d["M"]; P = d["P"]; Q = d["Q"]; C = d["C"]; R = d["R"]; S = d["S"]
    H = P + R - 1
    W = Q + S - 1

    # same as harness
    c_blks = (C + in_banks - 1) // in_banks
    in_bank_elems = c_blks * H * W
    w_bank_elems  = M * c_blks * R * S

    m_sf, p_sf, q_sf = gen.out_bank_factors()
    Ptiles = (P + p_sf - 1) // p_sf
    Qtiles = (Q + q_sf - 1) // q_sf
    out_bank_elems = ((M + m_sf - 1)//m_sf) * Ptiles * Qtiles

    sizeof = 4  # DTYPE=float

    sizes = {
        "dram_in_b0": in_bank_elems * sizeof,
        "dram_in_b1": in_bank_elems * sizeof,
        "dram_w_b0":  w_bank_elems  * sizeof,
        "dram_w_b1":  w_bank_elems  * sizeof,
    }
    for i in range(out_banks):
        sizes[f"dram_out_b{i}"] = out_bank_elems * sizeof
    return sizes