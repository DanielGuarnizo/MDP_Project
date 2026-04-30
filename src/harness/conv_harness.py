from __future__ import annotations
from typing import Any
from mapping_types import MappingInfo


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


def _get_input_ports(bank: Any) -> int:
    """Read input port count from either new ConvBankSpec (input_ports) or legacy (in_banks)."""
    return getattr(bank, 'input_ports', getattr(bank, 'in_banks', 2))


def conv_tb_param_sizes(mapping: MappingInfo, bank: Any, spec=None,
                        output_ports: int = None, folding_depth: int = 1) -> dict:
    input_ports = _get_input_ports(bank)
    d = mapping.dims
    M, P, Q, C, R, S = d["M"], d["P"], d["Q"], d["C"], d["R"], d["S"]
    H, W = P + R - 1, Q + S - 1
    c_blks = (C + input_ports - 1) // input_ports
    in_port_elems = c_blks * H * W
    w_port_elems  = M * c_blks * R * S

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
        n_out          = spec.N_out
        out_bank_elems = (M // N_M_sp) * (P // N_P_sp) * (Q // N_Q_sp)
    else:
        n_out          = getattr(bank, 'out_banks', 1)
        m_sf, p_sf, q_sf = bank.m_sf, bank.p_sf, bank.q_sf
        Ptiles = bank.p_tiles
        Qtiles = bank.q_tiles
        out_bank_elems = ((M + m_sf - 1) // m_sf) * Ptiles * Qtiles

    effective_output_ports = output_ports if output_ports is not None else n_out

    sizes = {}
    for i in range(input_ports):
        sizes[f"dram_input_p{i}"] = in_port_elems * 4
    weight_ports = getattr(bank, 'weight_ports', input_ports)
    for i in range(weight_ports):
        sizes[f"dram_weight_p{i}"] = w_port_elems * 4
    for i in range(effective_output_ports):
        sizes[f"dram_output_p{i}"] = out_bank_elems * folding_depth * 4
    return sizes


def make_conv_testbench(mapping: MappingInfo, bank: Any,
                        gather_bank_c: str = None,
                        out_banks_n: int = None,
                        out_bank_elems_n: int = None,
                        output_ports: int = None,
                        folding_depth: int = 1) -> str:
    input_ports  = _get_input_ports(bank)
    weight_ports = getattr(bank, 'weight_ports', input_ports)
    d = mapping.dims
    M, P, Q, C, R, S = d["M"], d["P"], d["Q"], d["C"], d["R"], d["S"]
    H, W = P + R - 1, Q + S - 1

    c_blks        = (C + input_ports - 1) // input_ports
    in_port_elems = c_blks * H * W
    w_port_elems  = M * c_blks * R * S

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

    effective_output_ports = output_ports if output_ports is not None else out_banks
    # Each physical output port holds folding_depth worth of data
    out_port_elems = out_bank_elems * folding_depth

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
    proto_args = []
    for i in range(input_ports):
        proto_args.append(f"DTYPE *dram_input_p{i}")
    for i in range(weight_ports):
        proto_args.append(f"DTYPE *dram_weight_p{i}")
    for i in range(effective_output_ports):
        proto_args.append(f"DTYPE *dram_output_p{i}")
    proto = "void top_level(" + ", ".join(proto_args) + ");\n\n"

    # output gather switch (folding-aware)
    if folding_depth == 1:
        gather_switch_pre = ""
        gather_switch_var = "output_bank_index"
        gather_offset_var = "output_dram_offset"
        gather_switch = ""
        for i in range(out_banks):
            gather_switch += f"            case {i}: out_full[out_idx] = dram_output_p{i}[{gather_offset_var}]; break;\n"
    else:
        gather_switch_pre = (
            f"          int output_port_index = output_bank_index % {effective_output_ports};\n"
            f"          int safe_dram_offset = output_dram_offset * {folding_depth} + output_bank_index / {effective_output_ports};"
        )
        gather_switch_var = "output_port_index"
        gather_offset_var = "safe_dram_offset"
        gather_switch = ""
        for i in range(effective_output_ports):
            gather_switch += f"            case {i}: out_full[out_idx] = dram_output_p{i}[{gather_offset_var}]; break;\n"
    if not gather_switch:
        gather_switch = "            default: out_full[out_idx] = 0.0f; break;\n"

    # alloc output ports
    out_alloc = ""
    out_free  = ""
    call_args = ", ".join([f"dram_input_p{i}" for i in range(input_ports)] +
                          [f"dram_weight_p{i}" for i in range(weight_ports)])
    for i in range(effective_output_ports):
        out_alloc += f"    DTYPE *dram_output_p{i} = (DTYPE*)malloc({out_port_elems} * sizeof(DTYPE));\n"
        out_alloc += f"    if (!dram_output_p{i}) {{ printf(\"Output port {i} alloc failed!\\n\"); return -1; }}\n"
        out_free  += f"    free(dram_output_p{i});\n"
        call_args += f", dram_output_p{i}"

    # mdpi allocs
    mdpi_alloc = ""
    param_idx = 0
    for i in range(input_ports):
        mdpi_alloc += f"    m_param_alloc({param_idx}, {in_port_elems} * sizeof(DTYPE));\n"
        param_idx += 1
    for i in range(weight_ports):
        mdpi_alloc += f"    m_param_alloc({param_idx}, {w_port_elems} * sizeof(DTYPE));\n"
        param_idx += 1
    for i in range(effective_output_ports):
        mdpi_alloc += f"    m_param_alloc({param_idx}, {out_port_elems} * sizeof(DTYPE));\n"
        param_idx += 1

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
            f"          int output_bank_index = (lane_m*{p_sf} + lane_p)*{q_sf} + lane_q;\n"
            f"          int output_filter_tile = ({m_sf}==1)?m:(m / {m_sf});\n"
            f"          int output_row_tile = ({p_sf}==1)?p:(p / {p_sf});\n"
            f"          int output_col_tile = ({q_sf}==1)?q:(q / {q_sf});\n"
            f"          int output_dram_offset = (output_filter_tile*{Ptiles} + output_row_tile)*{Qtiles} + output_col_tile;"
        )

    # input alloc lines
    input_alloc = ""
    input_alloc_check = ""
    input_free = ""
    input_zero = ""
    for i in range(input_ports):
        input_alloc += f"    DTYPE *dram_input_p{i}  = (DTYPE*)malloc({in_port_elems} * sizeof(DTYPE));\n"
        input_alloc_check += f"dram_input_p{i}"
        if i < input_ports - 1:
            input_alloc_check += " || "
        input_free += f"    free(dram_input_p{i});\n"
    input_alloc_check = "    if (" + input_alloc_check + ") {}\n"  # not used directly

    weight_alloc = ""
    weight_free = ""
    for i in range(weight_ports):
        weight_alloc += f"    DTYPE *dram_weight_p{i} = (DTYPE*)malloc({w_port_elems} * sizeof(DTYPE));\n"
        weight_free  += f"    free(dram_weight_p{i});\n"

    # input/weight zero init
    input_zero_lines = ""
    for i in range(input_ports):
        input_zero_lines += f"    for (size_t i = 0; i < {in_port_elems}; ++i) dram_input_p{i}[i] = 0.0f;\n"
    weight_zero_lines = ""
    for i in range(weight_ports):
        weight_zero_lines += f"    for (size_t i = 0; i < {w_port_elems}; ++i) dram_weight_p{i}[i] = 0.0f;\n"

    # output zero init
    output_zero_lines = ""
    for i in range(effective_output_ports):
        output_zero_lines += f"    for (size_t i = 0; i < {out_port_elems}; ++i) dram_output_p{i}[i] = 0.0f;\n"

    # scatter input: distribute channel c to port c%input_ports, block c/input_ports
    input_scatter_cases = ""
    for i in range(input_ports):
        input_scatter_cases += f"                if (port_index == {i}) dram_input_p{i}[b_idx] = in_full[full_idx];\n"

    weight_scatter_cases = ""
    for i in range(weight_ports):
        weight_scatter_cases += f"                if (port_index == {i}) dram_weight_p{i}[b_idx] = w_full[full_idx];\n"

    allnull_input  = " || ".join([f"!dram_input_p{i}"  for i in range(input_ports)])
    allnull_weight = " || ".join([f"!dram_weight_p{i}" for i in range(weight_ports)])
    free_input_weight = input_free + weight_free

    # optional gather_switch_pre line
    gather_pre_line = (f"\n          {gather_switch_pre}" if gather_switch_pre else "")

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
    /* Relative+absolute tolerance: handles both tiny outputs and large-sum outputs.
       1e-3 absolute prevents false positives near zero; 1e-3 relative catches
       floating-point accumulation differences on large convolutions (C*R*S up to ~25k).
       Real bugs (wrong loop structure) produce diffs 100-1000x larger than tolerance. */
    const float eps_abs = 1e-3f;
    const float eps_rel = 1e-3f;
    int errs = 0;
    for (size_t i = 0; i < so; ++i) {{
        float diff = fabs(out[i]-gold[i]);
        float tol  = eps_abs + eps_rel * fabs(gold[i]);
        if (diff > tol) {{
            printf("ERROR at index %zu: HLS=%.6f Gold=%.6f diff=%.6f tol=%.6f\\n", i, out[i], gold[i], diff, tol);
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

    // Input ports
{input_alloc}
    if ({allnull_input}) {{
        printf("Input port allocation failed!\\n");
        return -1;
    }}

    // Weight ports
{weight_alloc}
    if ({allnull_weight}) {{
        printf("Weight port allocation failed!\\n");
        return -1;
    }}

    // Output ports
{out_alloc}

    // Zero all ports
{input_zero_lines}{weight_zero_lines}{output_zero_lines}
    // Scatter input into {input_ports} ports by c % {input_ports}
    for (int c = 0; c < {C}; ++c) {{
        int port_index = c % {input_ports};
        int blk        = c / {input_ports};
        for (int y = 0; y < {H}; ++y) {{
            for (int x = 0; x < {W}; ++x) {{
                int full_idx = c*{H}*{W} + y*{W} + x;
                int b_idx    = blk*{H}*{W} + y*{W} + x;
{input_scatter_cases}            }}
        }}
    }}

    // Scatter weights into {weight_ports} ports by c % {weight_ports}
    for (int m = 0; m < {M}; ++m) {{
      for (int c = 0; c < {C}; ++c) {{
        int port_index = c % {weight_ports};
        int blk        = c / {weight_ports};
        for (int r = 0; r < {R}; ++r)
          for (int s = 0; s < {S}; ++s) {{
            int full_idx = m*{C}*{R}*{S} + c*{R}*{S} + r*{S} + s;
            int b_idx    = (m*{c_blks} + blk)*{R}*{S} + r*{S} + s;
{weight_scatter_cases}          }}
      }}
    }}

#ifdef __BAMBU_SIM__
{mdpi_alloc}
#endif

    printf("Running HLS top_level function...\\n");
    top_level({call_args});

    // Gather output ports into out_full
    for (int m = 0; m < {M}; ++m)
      for (int p = 0; p < {P}; ++p)
        for (int q = 0; q < {Q}; ++q) {{

          {gather_block}{gather_pre_line}

          int out_idx = m*{P}*{Q} + p*{Q} + q;
          switch({gather_switch_var}) {{
{gather_switch}            default: out_full[out_idx] = 0.0f; break;
          }}
        }}

    printf("Comparing results...\\n");
    int e = compare(out_full, gold, out_full_e);
    if (e==0) printf("SUCCESS: The results match the golden reference!\\n");
    else printf("FAILURE: Found %d mismatches.\\n", e);

    free(in_full); free(w_full); free(out_full); free(gold);
{free_input_weight}{out_free}
    return e;
}}
"""
    return code
