import re
import os

class MappingInfo:
    def __init__(self):
        self.workload_type = None
        self.total_dims = {}
        self.levels = []
        self.tiling = {}
        self.spatial_levels = []

def parse_ff_output(filepath="output/FF_output.txt"):
    info = MappingInfo()
    if not os.path.exists(filepath):
        raise FileNotFoundError(f"{filepath} not found. Run FactorFlow first.")

    with open(filepath, "r") as f:
        lines = [ln.strip() for ln in f.readlines()]

    in_mapping_section = False
    for line in lines:
        if line.startswith("Computation:"):
            dims_str = line.split('{')[1].split('}')[0]
            dims = dict(item.split(': ') for item in dims_str.split(', '))
            info.total_dims = {k: int(v) for k, v in dims.items()}
            info.workload_type = 'CONV' if 'P' in info.total_dims else 'GEMM'

        if line.startswith("Mapping:"):
            in_mapping_section = True
            continue

        if in_mapping_section and line:
            m = re.match(r"^([a-zA-Z0-9_]+)\s*[-=>]+\s*(.*)$", line)
            if m:
                level_name = m.group(1).strip()
                factors_str = m.group(2).strip()

                info.levels.append(level_name)
                info.tiling[level_name] = {}

                if any(s in level_name for s in ["SA", "PEs", "Fanout", "Distribution"]):
                    info.spatial_levels.append(level_name)

                if factors_str:
                    factors = dict(item.split(': ') for item in factors_str.split(', '))
                    info.tiling[level_name] = {k: int(v) for k, v in factors.items()}
        elif in_mapping_section and not line:
            in_mapping_section = False

    return info


class CodeGenBase:
    def __init__(self, mapping_info: MappingInfo):
        self.info = mapping_info
        self.loop_order = ['N', 'M', 'K', 'P', 'Q', 'R', 'S', 'C']

    def _get_inner_tile_product(self, dim, start_level_name):
        product = 1
        start_idx = self.info.levels.index(start_level_name)
        for i in range(start_idx + 1, len(self.info.levels)):
            lvl = self.info.levels[i]
            if lvl == 'Compute':
                continue
            if dim in self.info.tiling.get(lvl, {}):
                product *= self.info.tiling[lvl][dim]
        return product

    def dim_formula(self, dim):
        if dim not in self.info.total_dims:
            return "0"
        parts = []
        for lvl in self.info.levels:
            if lvl == 'Compute':
                continue
            t = self.info.tiling.get(lvl, {})
            if dim in t:
                var = f"{dim.lower()}_{lvl.lower()}"
                inner = self._get_inner_tile_product(dim, lvl)
                parts.append(f"{var} * {inner}" if inner > 1 else var)
        return " + ".join(parts) if parts else "0"

    def headers_and_defines(self):
        code = "#define DTYPE float\n"
        for dim, size in self.info.total_dims.items():
            code += f"#define {dim}_TOTAL {size}\n"
        code += "\n"
        return code

    # ----- overridable interface hooks -----
    def top_signature(self):
        return "void top_level(DTYPE *dram_in, DTYPE *dram_w, DTYPE *dram_out)"

    def top_pragmas(self):
        return (
            "/* AXI pragmas for parallel memory buses */\n"
            "#pragma HLS interface port = dram_in mode = m_axi offset = direct bundle = gmem0\n"
            "#pragma HLS interface port = dram_w mode = m_axi offset = direct bundle = gmem1\n"
            "#pragma HLS interface port = dram_out mode = m_axi offset = direct bundle = gmem2\n"
        )

    def tb_alloc_mdpi(self):
        return (
            "    m_param_alloc(0, in_b);\n"
            "    m_param_alloc(1, w_b);\n"
            "    m_param_alloc(2, o_b);\n"
        )

    def tb_call_top(self):
        return "    top_level(dram_in, dram_w, dram_out);\n"
    # --------------------------------------

    def test_harness(self):
        if self.info.workload_type == 'GEMM':
            m,k,n = self.info.total_dims['M'], self.info.total_dims['K'], self.info.total_dims['N']
            size_in = f"{k} * {n}"
            size_w  = f"{m} * {k}"
            size_o  = f"{m} * {n}"
            golden = f"""
    for (int m_ = 0; m_ < {m}; ++m_) {{
        for (int n_ = 0; n_ < {n}; ++n_) {{
            for (int k_ = 0; k_ < {k}; ++k_) {{
                out_golden[m_ * {n} + n_] += w[m_ * {k} + k_] * in[k_ * {n} + n_];
            }}
        }}
    }}
"""
        else:
            p,q,r,s,c,m = (self.info.total_dims.get(d,1) for d in ['P','Q','R','S','C','M'])
            in_h, in_w = p + r - 1, q + s - 1
            size_in = f"{c} * ({p} + {r} - 1) * ({q} + {s} - 1)"
            size_w  = f"{m} * {c} * {r} * {s}"
            size_o  = f"{m} * {p} * {q}"
            golden = f"""
    for (int m_ = 0; m_ < {m}; ++m_) {{
        for (int c_ = 0; c_ < {c}; ++c_) {{
            for (int r_ = 0; r_ < {r}; ++r_) {{
                for (int s_ = 0; s_ < {s}; ++s_) {{
                    for (int p_ = 0; p_ < {p}; ++p_) {{
                        for (int q_ = 0; q_ < {q}; ++q_) {{
                            int out_idx = m_*{p}*{q} + p_*{q} + q_;
                            int w_idx = m_*{c}*{r}*{s} + c_*{r}*{s} + r_*{s} + s_;
                            int in_idx = c_*{in_h}*{in_w} + (p_+r_)*{in_w} + (q_+s_);
                            out_golden[out_idx] += w[w_idx] * in[in_idx];
                        }}
                    }}
                }}
            }}
        }}
    }}
"""

        return f"""
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#ifdef __BAMBU_SIM__
#include <mdpi/mdpi_user.h>
#endif

{self.top_signature()};

static void init(DTYPE *in, DTYPE *w, DTYPE *out, DTYPE *gold, size_t si, size_t sw, size_t so) {{
    for (size_t i = 0; i < si; ++i) in[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < sw; ++i) w[i] = (DTYPE)rand() / RAND_MAX;
    for (size_t i = 0; i < so; ++i) {{ out[i]=0.0f; gold[i]=0.0f; }}
}}

static void golden_reference(DTYPE *in, DTYPE *w, DTYPE *out_golden) {{{golden}}}

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
    size_t in_e = {size_in};
    size_t w_e  = {size_w};
    size_t o_e  = {size_o};

    size_t in_b = in_e * sizeof(DTYPE);
    size_t w_b  = w_e  * sizeof(DTYPE);
    size_t o_b  = o_e  * sizeof(DTYPE);

    DTYPE *dram_in  = (DTYPE*)malloc(in_b);
    DTYPE *dram_w   = (DTYPE*)malloc(w_b);
    DTYPE *dram_out = (DTYPE*)malloc(o_b);
    DTYPE *gold     = (DTYPE*)malloc(o_b);

    if (!dram_in || !dram_w || !dram_out || !gold) {{
        printf("Memory allocation failed!\\n");
        return -1;
    }}

    init(dram_in, dram_w, dram_out, gold, in_e, w_e, o_e);
    golden_reference(dram_in, dram_w, gold);

#ifdef __BAMBU_SIM__
{self.tb_alloc_mdpi()}
#endif

    printf("Running HLS top_level function...\\n");
{self.tb_call_top()}
    printf("Comparing results...\\n");
    int e = compare(dram_out, gold, o_e);
    if (e==0) printf("SUCCESS: The results match the golden reference!\\n");
    else printf("FAILURE: Found %d mismatches.\\n", e);

    free(dram_in); free(dram_w); free(dram_out); free(gold);
    return e;
}}
"""

    def write_build_script(self, tb_file="testbench.c", top_file="top_level.c", output_path="compile_bambu.sh"):
        script = f"""#!/bin/bash
# Bambu compilation and simulation script

bambu {top_file} \\
    --top-fname=top_level \\
    --generate-interface=INFER \\
    --compiler=I386_GCC8 \\
    --clock-period=5 \\
    -O3 \\
    -v4 \\
    --generate-tb={tb_file} \\
    --simulate \\
    "$@"
"""
        with open(output_path, 'w') as f:
            f.write(script)
        print(f"Generated Bambu build script at {output_path}")