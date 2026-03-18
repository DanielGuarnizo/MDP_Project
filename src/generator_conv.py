#!/usr/bin/env python3
from __future__ import annotations
from typing import Tuple
from generator_common import MappingInfo, CodeGenBase


class CodeGeneratorCONV(CodeGenBase):
    """
    CONV generator with:
      - 2 banks for input (split by c%2)
      - 2 banks for weights (split by c%2)
      - banked output based on spatial factors of M,P,Q from FF mapping
      - IMPORTANT: no pointer arrays inside top_level (Bambu-safe)
    """

    def __init__(self, info: MappingInfo):
        super().__init__(info)

    # ---------- banking factors ----------
    def out_bank_factors(self) -> Tuple[int, int, int]:
        """Return (m_sf, p_sf, q_sf) = product of spatial factors for dims M,P,Q across spatial levels."""
        m_sf = p_sf = q_sf = 1
        for lvl in self.info.spatial_levels:
            f = self.info.tiling.get(lvl, {})
            if "M" in f: m_sf *= int(f["M"])
            if "P" in f: p_sf *= int(f["P"])
            if "Q" in f: q_sf *= int(f["Q"])
        return max(1, m_sf), max(1, p_sf), max(1, q_sf)

    def out_bank_count(self) -> int:
        m_sf, p_sf, q_sf = self.out_bank_factors()
        return m_sf * p_sf * q_sf

    # ---------- top-level C signature / pragmas ----------
    def top_signature(self, out_banks: int) -> str:
        # fixed 2 in banks + 2 w banks + out_banks outputs
        args = [
            "DTYPE *dram_in_b0", "DTYPE *dram_in_b1",
            "DTYPE *dram_w_b0",  "DTYPE *dram_w_b1",
        ]
        for i in range(out_banks):
            args.append(f"DTYPE *dram_out_b{i}")
        return "void top_level(" + ", ".join(args) + ")"

    def top_pragmas(self, out_banks: int, enable_cache: bool = False) -> str:
        lines = []
        lines.append("#pragma HLS interface port = dram_in_b0 mode = m_axi offset = direct bundle = gmem_in0")
        lines.append("#pragma HLS interface port = dram_in_b1 mode = m_axi offset = direct bundle = gmem_in1")
        lines.append("#pragma HLS interface port = dram_w_b0  mode = m_axi offset = direct bundle = gmem_w0")
        lines.append("#pragma HLS interface port = dram_w_b1  mode = m_axi offset = direct bundle = gmem_w1")
        for i in range(out_banks):
            lines.append(f"#pragma HLS interface port = dram_out_b{i} mode = m_axi offset = direct bundle = gmem_out{i}")

        if enable_cache:
            lines.append("")
            lines.append("#pragma HLS cache bundle = gmem_in0 line_count = 32 line_size = 16 bus_size = 32 ways = 1 num_write_outstanding = 1 rep_policy = lru write_policy = wt")
            lines.append("#pragma HLS cache bundle = gmem_in1 line_count = 32 line_size = 16 bus_size = 32 ways = 1 num_write_outstanding = 1 rep_policy = lru write_policy = wt")
            lines.append("#pragma HLS cache bundle = gmem_w0  line_count = 32 line_size = 16 bus_size = 32 ways = 1 num_write_outstanding = 1 rep_policy = lru write_policy = wt")
            lines.append("#pragma HLS cache bundle = gmem_w1  line_count = 32 line_size = 16 bus_size = 32 ways = 1 num_write_outstanding = 1 rep_policy = lru write_policy = wt")

        return "\n".join(lines) + "\n"

    # ---------- kernel body ----------
    def top_level_body(self) -> str:
        """
        Banked CONV kernel (Bambu-safe):
        - inputs/weights split into 2 banks by c%2  (c_bank = c & 1, c_blk = c >> 1)
        - outputs split into (m_sf * p_sf * q_sf) banks from spatial factors on M,P,Q
        - IMPORTANT: do NOT read output (acc starts from 0) to avoid AXI read/ordering issues.

        Optimization implemented:
        - If q_sf == 2, compute two outputs at once (q0,q1) to reduce overhead and reuse address bases.
        This matches your mapping (q_sf=2) and the working fast kernel you validated (~24766 cycles).
        """

        # ---- 1) Get problem sizes robustly (handle different MappingInfo layouts) ----
        dims = None
        if hasattr(self.info, "total_dims"):
            dims = self.info.total_dims
        elif hasattr(self.info, "dims"):
            dims = self.info.dims
        elif hasattr(self.info, "computation_dims"):
            dims = self.info.computation_dims

        if not isinstance(dims, dict) or len(dims) == 0:
            raise RuntimeError(
                "MappingInfo does not expose conv dimensions. Expected info.total_dims "
                "(or info.dims / info.computation_dims) to be a dict like "
                "{'M':..., 'P':..., 'Q':..., 'C':..., 'R':..., 'S':...}."
            )

        M = int(dims["M"])
        P = int(dims["P"])
        Q = int(dims["Q"])
        C = int(dims.get("C", 1))
        R = int(dims.get("R", 1))
        S = int(dims.get("S", 1))

        H = P + R - 1
        W = Q + S - 1

        # ---- 2) Output banking factors from FF spatial mapping (product across spatial levels) ----
        m_sf = 1
        p_sf = 1
        q_sf = 1

        spatial_lvls = getattr(self.info, "spatial_levels", []) or []
        tiling = getattr(self.info, "tiling", {}) or {}

        for lvl in spatial_lvls:
            lvl_til = tiling.get(lvl, {}) or {}
            if "M" in lvl_til:
                m_sf *= int(lvl_til["M"])
            if "P" in lvl_til:
                p_sf *= int(lvl_til["P"])
            if "Q" in lvl_til:
                q_sf *= int(lvl_til["Q"])

        m_sf = max(1, m_sf)
        p_sf = max(1, p_sf)
        q_sf = max(1, q_sf)

        out_banks = max(1, m_sf * p_sf * q_sf)

        # number of coarse tiles in P and Q for the banked output layout
        Ptiles = (P + p_sf - 1) // p_sf
        Qtiles = (Q + q_sf - 1) // q_sf

        ind = "    "
        code = ""

        # ---- 3) Emit kernel header/consts ----
        code += f"{ind}// ---- CONV kernel (banked in/w/out, Bambu-safe; write-only outputs) ----\n"
        code += f"{ind}const int M = {M}, P = {P}, Q = {Q}, C = {C}, R = {R}, S = {S};\n"
        code += f"{ind}const int H = {H}, W = {W};\n"
        code += f"{ind}const int m_sf = {m_sf}, p_sf = {p_sf}, q_sf = {q_sf};\n"
        code += f"{ind}const int Ptiles = {Ptiles}, Qtiles = {Qtiles};\n\n"

        # If q_sf == 2 we use q-pair optimization; else fallback to scalar-q
        code += f"{ind}if (q_sf == 2) {{\n"
        # ---- q-pair version ----
        code += f"{ind}  for (int m = 0; m < M; ++m) {{\n"
        code += f"{ind}    int lane_m = (m_sf==1)?0:(m % m_sf);\n"
        code += f"{ind}    int cm     = (m_sf==1)?m:(m / m_sf);\n"
        code += f"{ind}    for (int p = 0; p < P; ++p) {{\n"
        code += f"{ind}      int lane_p = (p_sf==1)?0:(p % p_sf);\n"
        code += f"{ind}      int cp     = (p_sf==1)?p:(p / p_sf);\n"
        code += f"{ind}      for (int q0 = 0; q0 < Q; q0 += 2) {{\n"
        code += f"{ind}        int q1 = q0 + 1;\n"
        code += f"{ind}        int cq = q0 / 2;  // since q_sf==2\n"
        code += f"{ind}        int out_idx_b = (cm*Ptiles + cp)*Qtiles + cq;\n"
        code += f"{ind}        int out_bank0 = (lane_m*p_sf + lane_p)*2 + 0;\n"
        code += f"{ind}        int out_bank1 = (lane_m*p_sf + lane_p)*2 + 1;\n\n"
        code += f"{ind}        DTYPE acc0 = 0.0f;\n"
        code += f"{ind}        DTYPE acc1 = 0.0f;\n\n"

        # MAC loops with hoisted bases; handle q1 tail inside
        code += f"{ind}        for (int c = 0; c < C; ++c) {{\n"
        code += f"{ind}          int c_bank = c & 1;\n"
        code += f"{ind}          int c_blk  = c >> 1;\n"
        code += f"{ind}          int in_c_base = c_blk * (H * W);\n"
        code += f"{ind}          int w_mc_base = (m * (C/2) + c_blk) * (R * S);\n\n"

        code += f"{ind}          if (q1 < Q) {{\n"
        code += f"{ind}            for (int r = 0; r < R; ++r) {{\n"
        code += f"{ind}              int in_row_base = in_c_base + (p + r) * W;\n"
        code += f"{ind}              int w_r_base    = w_mc_base + r * S;\n\n"

        # s = 0..S-1, but we keep it generic; for your S=3 it will be small anyway
        code += f"{ind}              for (int s = 0; s < S; ++s) {{\n"
        code += f"{ind}                int w_idx = w_r_base + s;\n"
        code += f"{ind}                DTYPE wv  = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];\n"
        code += f"{ind}                DTYPE in0 = (c_bank==0) ? dram_in_b0[in_row_base + (q0 + s)] : dram_in_b1[in_row_base + (q0 + s)];\n"
        code += f"{ind}                DTYPE in1 = (c_bank==0) ? dram_in_b0[in_row_base + (q1 + s)] : dram_in_b1[in_row_base + (q1 + s)];\n"
        code += f"{ind}                acc0 += wv * in0;\n"
        code += f"{ind}                acc1 += wv * in1;\n"
        code += f"{ind}              }}\n"
        code += f"{ind}            }}\n"
        code += f"{ind}          }} else {{\n"
        code += f"{ind}            // tail: only q0 valid\n"
        code += f"{ind}            for (int r = 0; r < R; ++r) {{\n"
        code += f"{ind}              int in_row_base = in_c_base + (p + r) * W;\n"
        code += f"{ind}              int w_r_base    = w_mc_base + r * S;\n"
        code += f"{ind}              for (int s = 0; s < S; ++s) {{\n"
        code += f"{ind}                int w_idx = w_r_base + s;\n"
        code += f"{ind}                DTYPE wv  = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];\n"
        code += f"{ind}                DTYPE in0 = (c_bank==0) ? dram_in_b0[in_row_base + (q0 + s)] : dram_in_b1[in_row_base + (q0 + s)];\n"
        code += f"{ind}                acc0 += wv * in0;\n"
        code += f"{ind}              }}\n"
        code += f"{ind}            }}\n"
        code += f"{ind}          }}\n"
        code += f"{ind}        }}\n\n"

        # Store q0
        code += f"{ind}        switch(out_bank0) {{\n"
        for b in range(out_banks):
            code += f"{ind}          case {b}: dram_out_b{b}[out_idx_b] = acc0; break;\n"
        code += f"{ind}          default: break;\n"
        code += f"{ind}        }}\n\n"

        # Store q1 if valid
        code += f"{ind}        if (q1 < Q) {{\n"
        code += f"{ind}          switch(out_bank1) {{\n"
        for b in range(out_banks):
            code += f"{ind}            case {b}: dram_out_b{b}[out_idx_b] = acc1; break;\n"
        code += f"{ind}            default: break;\n"
        code += f"{ind}          }}\n"
        code += f"{ind}        }}\n"

        code += f"{ind}      }}\n"  # q0 loop
        code += f"{ind}    }}\n"    # p loop
        code += f"{ind}  }}\n"      # m loop
        code += f"{ind}}} else {{\n"

        # ---- fallback scalar-q version (your original, cleaned) ----
        code += f"{ind}  for (int m = 0; m < M; ++m) {{\n"
        code += f"{ind}    for (int p = 0; p < P; ++p) {{\n"
        code += f"{ind}      for (int q = 0; q < Q; ++q) {{\n"
        code += f"{ind}        int lane_m = (m_sf==1)?0:(m % m_sf);\n"
        code += f"{ind}        int lane_p = (p_sf==1)?0:(p % p_sf);\n"
        code += f"{ind}        int lane_q = (q_sf==1)?0:(q % q_sf);\n"
        code += f"{ind}        int out_bank = (lane_m*p_sf + lane_p)*q_sf + lane_q;\n"
        code += f"{ind}        int cm = (m_sf==1)?m:(m / m_sf);\n"
        code += f"{ind}        int cp = (p_sf==1)?p:(p / p_sf);\n"
        code += f"{ind}        int cq = (q_sf==1)?q:(q / q_sf);\n"
        code += f"{ind}        int out_idx_b = (cm*Ptiles + cp)*Qtiles + cq;\n"
        code += f"{ind}        DTYPE acc = 0.0f;\n"
        code += f"{ind}        for (int c = 0; c < C; ++c) {{\n"
        code += f"{ind}          int c_bank = c & 1;\n"
        code += f"{ind}          int c_blk  = c >> 1;\n"
        code += f"{ind}          for (int r = 0; r < R; ++r) {{\n"
        code += f"{ind}            for (int s = 0; s < S; ++s) {{\n"
        code += f"{ind}              int in_idx = c_blk*(H*W) + (p+r)*W + (q+s);\n"
        code += f"{ind}              int w_idx  = (m*(C/2) + c_blk)*(R*S) + r*S + s;\n"
        code += f"{ind}              DTYPE in_v = (c_bank==0) ? dram_in_b0[in_idx] : dram_in_b1[in_idx];\n"
        code += f"{ind}              DTYPE w_v  = (c_bank==0) ? dram_w_b0[w_idx]  : dram_w_b1[w_idx];\n"
        code += f"{ind}              acc += w_v * in_v;\n"
        code += f"{ind}            }}\n"
        code += f"{ind}          }}\n"
        code += f"{ind}        }}\n"
        code += f"{ind}        switch(out_bank) {{\n"
        for b in range(out_banks):
            code += f"{ind}          case {b}: dram_out_b{b}[out_idx_b] = acc; break;\n"
        code += f"{ind}          default: break;\n"
        code += f"{ind}        }}\n"
        code += f"{ind}      }}\n"
        code += f"{ind}    }}\n"
        code += f"{ind}  }}\n"

        code += f"{ind}}}\n"

        return code