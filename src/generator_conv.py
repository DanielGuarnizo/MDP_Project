import itertools

from generator_common import CodeGenBase

class CodeGeneratorCONV(CodeGenBase):
    """
    Manual output banking via multiple AXI ports (Serena) + SAFE reduction without array_partition.

    Problem observed:
      - Even after output banking, spatially-unrolled reduction dims (e.g., C,S) still cause
        multiple read-modify-write updates to the same banked output element in the same cycle.
        Bambu serializes/drops some updates -> MDPI mismatches in specific banks.

    Fix (Bambu-safe, still parallel MACs):
      - Keep spatial unrolling for OUTPUT dims (M/P/Q) -> selects bank.
      - DO NOT generate loops for spatial REDUCTION dims (C/R/S).
      - Instead, explicitly enumerate all reduction lanes as scalar temporaries mac_0..mac_{L-1}
        and reduce them with an explicit adder tree, then perform a SINGLE update:
            out = out + sum(mac_lanes)
    """

    def __init__(self, mapping_info):
        super().__init__(mapping_info)
        self.M = self.info.total_dims['M']
        self.P = self.info.total_dims['P']
        self.Q = self.info.total_dims['Q']
        self.C = self.info.total_dims.get('C', 1)
        self.R = self.info.total_dims.get('R', 1)
        self.S = self.info.total_dims.get('S', 1)

        # spatial output factors across spatial levels
        self.fM = 1
        self.fP = 1
        self.fQ = 1
        for lvl in self.info.spatial_levels:
            til = self.info.tiling.get(lvl, {})
            if 'M' in til: self.fM *= til['M']
            if 'P' in til: self.fP *= til['P']
            if 'Q' in til: self.fQ *= til['Q']

        self.OUT_BANKS = self.fM * self.fP * self.fQ
        self.Mc = self.M // self.fM
        self.Pc = self.P // self.fP
        self.Qc = self.Q // self.fQ
        self.BANK_ELEMS = self.Mc * self.Pc * self.Qc

        # identify spatial reduction dims and the level they come from
        self.postponed = []  # list of (dim, level, bound, inner_prod)
        for lvl in self.info.spatial_levels:
            til = self.info.tiling.get(lvl, {})
            for dim in ('C','R','S'):
                if dim in til:
                    inner = self._get_inner_tile_product(dim, lvl)
                    self.postponed.append((dim, lvl, til[dim], inner))

    def top_signature(self):
        args = ["DTYPE *dram_in", "DTYPE *dram_w"]
        for b in range(self.OUT_BANKS):
            args.append(f"DTYPE *dram_out_b{b}")
        return "void top_level(" + ", ".join(args) + ")"

    def top_pragmas(self):
        s = "/* AXI pragmas for parallel memory buses */\n"
        s += "#pragma HLS interface port = dram_in mode = m_axi offset = direct bundle = gmem0\n"
        s += "#pragma HLS interface port = dram_w mode = m_axi offset = direct bundle = gmem1\n"
        for b in range(self.OUT_BANKS):
            s += f"#pragma HLS interface port = dram_out_b{b} mode = m_axi offset = direct bundle = gmem2_b{b}\n"
        return s

    def tb_alloc_mdpi(self):
        out_bank_bytes = f"({self.BANK_ELEMS} * sizeof(DTYPE))"
        lines = ["    m_param_alloc(0, in_b);",
                 "    m_param_alloc(1, w_b);"]
        for b in range(self.OUT_BANKS):
            lines.append(f"    m_param_alloc({2+b}, {out_bank_bytes});")
        return "\n".join(lines) + "\n"

    def tb_call_top(self):
        args = ["dram_in", "dram_w"] + [f"dram_out_b{b}" for b in range(self.OUT_BANKS)]
        return "    top_level(" + ", ".join(args) + ");\n"

    def _dim_formula_excluding_level(self, dim, excluded_level):
        if dim not in self.info.total_dims:
            return "0"
        parts = []
        for lvl in self.info.levels:
            if lvl == 'Compute' or lvl == excluded_level:
                continue
            t = self.info.tiling.get(lvl, {})
            if dim in t:
                var = f"{dim.lower()}_{lvl.lower()}"
                inner = self._get_inner_tile_product(dim, lvl)
                parts.append(f"{var} * {inner}" if inner > 1 else var)
        return " + ".join(parts) if parts else "0"

    def _adder_tree(self, indent, terms, prefix="rc_"):
        code = ""
        cur = list(terms)
        stage = 0
        while len(cur) > 1:
            stage += 1
            nxt = []
            code += f"{indent}// Adder tree stage {stage}\n"
            for i in range(0, len(cur), 2):
                if i+1 < len(cur):
                    v = f"{prefix}s{stage}_{i//2}"
                    code += f"{indent}DTYPE {v} = {cur[i]} + {cur[i+1]};\n"
                    nxt.append(v)
                else:
                    nxt.append(cur[i])
            cur = nxt
        return code, cur[0]

    def top_level_body(self):
        in_h = self.P + self.R - 1
        in_w = self.Q + self.S - 1

        indent = "    "
        open_loops = 0
        code = ""

        code += f"{indent}// Pointers to output banks\n"
        code += f"{indent}DTYPE* out_banks[{self.OUT_BANKS}] = {{"
        code += ", ".join([f"dram_out_b{b}" for b in range(self.OUT_BANKS)])
        code += "};\n\n"

        # Emit mapping loops, but SKIP loops for postponed (spatial reduction) dims
        for lvl in self.info.levels:
            if lvl == 'Compute':
                continue
            til = self.info.tiling.get(lvl, {})
            is_spatial = lvl in self.info.spatial_levels
            code += f"{indent}// Level: {lvl}\n"
            for dim in self.loop_order:
                if dim in til:
                    if is_spatial and dim in ('C','R','S'):
                        continue
                    b = til[dim]
                    var = f"{dim.lower()}_{lvl.lower()}"
                    if is_spatial:
                        code += f"{indent}#pragma GCC unroll {b}\n"
                    code += f"{indent}for (int {var} = 0; {var} < {b}; ++{var}) {{\n"
                    indent += "    "
                    open_loops += 1

        code += f"{indent}int global_m = {self.dim_formula('M')};\n"
        code += f"{indent}int global_p = {self.dim_formula('P')};\n"
        code += f"{indent}int global_q = {self.dim_formula('Q')};\n"
        base_c = self.dim_formula('C')
        base_r = self.dim_formula('R')
        base_s = self.dim_formula('S')

        code += f"{indent}int lane_m = global_m % {self.fM};\n"
        code += f"{indent}int lane_p = global_p % {self.fP};\n"
        code += f"{indent}int lane_q = global_q % {self.fQ};\n"
        code += f"{indent}int out_bank = ((lane_m)*{self.fP} + (lane_p))*{self.fQ} + (lane_q);\n"
        code += f"{indent}int coarse_m = global_m / {self.fM};\n"
        code += f"{indent}int coarse_p = global_p / {self.fP};\n"
        code += f"{indent}int coarse_q = global_q / {self.fQ};\n"
        code += f"{indent}int out_idx_b = ((coarse_m)*{self.Pc} + (coarse_p))*{self.Qc} + (coarse_q);\n"

        # Enumerate postponed lanes in fixed order S,R,C
        lane_dims = {d: (lvl,b,inner) for (d,lvl,b,inner) in self.postponed}
        enum_order = [d for d in ('S','R','C') if d in lane_dims]
        ranges = [range(lane_dims[d][1]) for d in enum_order]
        combos = list(itertools.product(*ranges)) if ranges else [()]

        code += f"{indent}DTYPE acc = out_banks[out_bank][out_idx_b];\n"

        mac_terms = []
        for idx, combo in enumerate(combos):
            assigns = {}
            for d,val in zip(enum_order, combo):
                lvl,b,inner = lane_dims[d]
                base = self._dim_formula_excluding_level(d, lvl)
                assigns[d] = f"(({base}) + {val}*{inner})"
            g_c = assigns.get('C', base_c)
            g_r = assigns.get('R', base_r)
            g_s = assigns.get('S', base_s)

            w_idx = f"global_m*({self.C}*{self.R}*{self.S}) + ({g_c})*({self.R}*{self.S}) + ({g_r})*{self.S} + ({g_s})"
            in_idx = f"({g_c})*({in_h}*{in_w}) + (global_p + ({g_r}))*{in_w} + (global_q + ({g_s}))"

            var = f"mac_{idx}"
            code += f"{indent}DTYPE {var} = dram_w[{w_idx}] * dram_in[{in_idx}];\n"
            mac_terms.append(var)

        if len(mac_terms) == 1:
            code += f"{indent}acc += {mac_terms[0]};\n"
        else:
            tree, finalv = self._adder_tree(indent, mac_terms, prefix="rc_")
            code += tree
            code += f"{indent}acc += {finalv};\n"

        code += f"{indent}out_banks[out_bank][out_idx_b] = acc;\n"

        for _ in range(open_loops):
            indent = indent[:-4]
            code += f"{indent}}}\n"
        return code

    def test_harness(self):
        # Keep the working scatter/gather harness from previous version by importing it from the existing file in your repo.
        # In your project repo, you should keep the full custom harness version that scatters/gathers banks.
        return super().test_harness()


    def test_harness(self):
        # Full custom testbench with scatter/gather
        p,q,r,s,c,m = self.P, self.Q, self.R, self.S, self.C, self.M
        in_h, in_w = p + r - 1, q + s - 1

        size_in_expr  = f"{c} * {in_h} * {in_w}"
        size_w_expr   = f"{m} * {c} * {r} * {s}"
        size_out_expr = f"{m} * {p} * {q}"

        # Golden
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

        # banked bytes
        bank_bytes_expr = f"({self.BANK_ELEMS} * sizeof(DTYPE))"

        # scatter/gather switch bodies
        scatter_cases = "\n".join(
            [f"            case {b}: dram_out_b{b}[idx] = dram_out[m*{p}*{q} + p_*{q} + q_]; break;"
             for b in range(self.OUT_BANKS)]
        )
        gather_cases = "\n".join(
            [f"            case {b}: dram_out[m*{p}*{q} + p_*{q} + q_] = dram_out_b{b}[idx]; break;"
             for b in range(self.OUT_BANKS)]
        )

        # args for call
        call_args = ", ".join(["dram_in","dram_w"] + [f"dram_out_b{b}" for b in range(self.OUT_BANKS)])

        # mdpi allocs
        mdpi_lines = self.tb_alloc_mdpi()

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
    size_t in_e = {size_in_expr};
    size_t w_e  = {size_w_expr};
    size_t o_e  = {size_out_expr};

    size_t in_b = in_e * sizeof(DTYPE);
    size_t w_b  = w_e  * sizeof(DTYPE);
    size_t o_b  = o_e  * sizeof(DTYPE);

    DTYPE *dram_in  = (DTYPE*)malloc(in_b);
    DTYPE *dram_w   = (DTYPE*)malloc(w_b);
    DTYPE *dram_out = (DTYPE*)malloc(o_b);
    DTYPE *gold     = (DTYPE*)malloc(o_b);

    // Banked outputs
{"".join([f"    DTYPE *dram_out_b{b} = (DTYPE*)malloc({bank_bytes_expr});\n" for b in range(self.OUT_BANKS)])}

    if (!dram_in || !dram_w || !dram_out || !gold
{"".join([f"        || !dram_out_b{b}\n" for b in range(self.OUT_BANKS)])}
    ) {{
        printf("Memory allocation failed!\\n");
        return -1;
    }}

    init(dram_in, dram_w, dram_out, gold, in_e, w_e, o_e);
    golden_reference(dram_in, dram_w, gold);

    // SCATTER linear dram_out -> banks (initial values)
    for (int m = 0; m < {m}; ++m) {{
        for (int p_ = 0; p_ < {p}; ++p_) {{
            for (int q_ = 0; q_ < {q}; ++q_) {{
                int lane_m = m % {self.fM};
                int lane_p = p_ % {self.fP};
                int lane_q = q_ % {self.fQ};
                int bank = ((lane_m)*{self.fP} + (lane_p))*{self.fQ} + (lane_q);
                int idx  = (((m / {self.fM})*{self.Pc} + (p_ / {self.fP}))*{self.Qc} + (q_ / {self.fQ}));
                switch(bank) {{
{scatter_cases}
                }}
            }}
        }}
    }}

#ifdef __BAMBU_SIM__
{mdpi_lines}
#endif

    printf("Running HLS top_level function...\\n");
    top_level({call_args});

    // GATHER banks -> linear dram_out for comparison
    for (int m = 0; m < {m}; ++m) {{
        for (int p_ = 0; p_ < {p}; ++p_) {{
            for (int q_ = 0; q_ < {q}; ++q_) {{
                int lane_m = m % {self.fM};
                int lane_p = p_ % {self.fP};
                int lane_q = q_ % {self.fQ};
                int bank = ((lane_m)*{self.fP} + (lane_p))*{self.fQ} + (lane_q);
                int idx  = (((m / {self.fM})*{self.Pc} + (p_ / {self.fP}))*{self.Qc} + (q_ / {self.fQ}));
                switch(bank) {{
{gather_cases}
                }}
            }}
        }}
    }}

    printf("Comparing results...\\n");
    int e = compare(dram_out, gold, o_e);
    if (e==0) printf("SUCCESS: The results match the golden reference!\\n");
    else printf("FAILURE: Found %d mismatches.\\n", e);

    free(dram_in); free(dram_w); free(dram_out); free(gold);
{"".join([f"    free(dram_out_b{b});\n" for b in range(self.OUT_BANKS)])}
    return e;
}}
"""