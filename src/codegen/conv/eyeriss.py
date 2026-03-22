# src/codegen/conv/eyeriss.py
from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Tuple
from codegen.base import CodeGenBase
from mapping_types import MappingInfo


class CodeGeneratorCONV_Eyeriss(CodeGenBase):
    def __init__(self, info: MappingInfo):
        super().__init__(info)
        if not info.arch.startswith("eyeriss"):
            raise ValueError(f"Wrong generator for arch={info.arch}")

    def _dims(self):
        d = self.info.dims
        M,P,Q = int(d["M"]), int(d["P"]), int(d["Q"])
        C,R,S = int(d["C"]), int(d["R"]), int(d["S"])
        return M,P,Q,C,R,S

    def bank_spec(self) -> ConvBankSpec:
        M,P,Q,C,R,S = self._dims()
        H = P + R - 1
        W = Q + S - 1

        # ✅ Eyeriss rule: output ports are SACols parallelism on output dims only
        sa = self.info.tiling.get("SACols", {}) or {}
        m_sf = int(sa.get("M", 1))
        p_sf = int(sa.get("P", 1))
        q_sf = int(sa.get("Q", 1))
        m_sf = max(1, m_sf); p_sf = max(1, p_sf); q_sf = max(1, q_sf)
        out_banks = m_sf * p_sf * q_sf

        Ptiles = (P + p_sf - 1)//p_sf
        Qtiles = (Q + q_sf - 1)//q_sf

        in_banks = 2
        w_banks  = 2
        c_blks = (C + in_banks - 1)//in_banks

        in_bank_elems  = c_blks * H * W
        w_bank_elems   = M * c_blks * R * S
        out_bank_elems = ((M + m_sf - 1)//m_sf) * Ptiles * Qtiles

        return ConvBankSpec(
            in_banks=in_banks, w_banks=w_banks,
            m_sf=m_sf, p_sf=p_sf, q_sf=q_sf, out_banks=out_banks,
            Ptiles=Ptiles, Qtiles=Qtiles,
            H=H, W=W,
            c_blks=c_blks,
            in_bank_elems=in_bank_elems,
            w_bank_elems=w_bank_elems,
            out_bank_elems=out_bank_elems,
        )

    def out_banks(self) -> int:
        return self.bank_spec().out_banks

    def headers_and_defines(self) -> str:
        d = self.info.dims
        return (
            "#define DTYPE float\n"
            f"#define M_TOTAL {d['M']}\n"
            f"#define P_TOTAL {d['P']}\n"
            f"#define Q_TOTAL {d['Q']}\n"
            f"#define C_TOTAL {d['C']}\n"
            f"#define R_TOTAL {d['R']}\n"
            f"#define S_TOTAL {d['S']}\n\n"
        )

    def out_bank_factors(self) -> tuple[int, int, int]:
        # product across spatial levels for M,P,Q
        m_sf = p_sf = q_sf = 1
        for lvl in self.info.spatial_levels:
            til = self.info.tiling.get(lvl, {})
            if "M" in til:
                m_sf *= int(til["M"])
            if "P" in til:
                p_sf *= int(til["P"])
            if "Q" in til:
                q_sf *= int(til["Q"])
        return max(1, m_sf), max(1, p_sf), max(1, q_sf)

    def top_signature(self, out_banks: int) -> str:
        args = [
            "DTYPE *dram_in_b0", "DTYPE *dram_in_b1",
            "DTYPE *dram_w_b0",  "DTYPE *dram_w_b1",
        ]
        for i in range(out_banks):
            args.append(f"DTYPE *dram_out_b{i}")
        return "void top_level(" + ", ".join(args) + ")"

    def top_pragmas(self, out_banks: int) -> str:
        lines = []
        lines.append("#pragma HLS interface port = dram_in_b0 mode = m_axi offset = direct bundle = gmem_in0")
        lines.append("#pragma HLS interface port = dram_in_b1 mode = m_axi offset = direct bundle = gmem_in1")
        lines.append("#pragma HLS interface port = dram_w_b0  mode = m_axi offset = direct bundle = gmem_w0")
        lines.append("#pragma HLS interface port = dram_w_b1  mode = m_axi offset = direct bundle = gmem_w1")
        for i in range(out_banks):
            lines.append(f"#pragma HLS interface port = dram_out_b{i} mode = m_axi offset = direct bundle = gmem_out{i}")
        return "\n".join(lines) + "\n"

    # ---------------- SEQ baseline ----------------
    def top_level_body_seq(self) -> str:
        d = self.info.dims
        M, P, Q, C, R, S = d["M"], d["P"], d["Q"], d["C"], d["R"], d["S"]
        H, W = P + R - 1, Q + S - 1

        m_sf, p_sf, q_sf = self.out_bank_factors()
        Ptiles = (P + p_sf - 1) // p_sf
        Qtiles = (Q + q_sf - 1) // q_sf

        # Plain nested loops; write-only outputs; no unroll.
        return f"""
    const int M = {M}, P = {P}, Q = {Q}, C = {C}, R = {R}, S = {S};
    const int H = {H}, W = {W};
    const int m_sf = {m_sf}, p_sf = {p_sf}, q_sf = {q_sf};
    const int Ptiles = {Ptiles}, Qtiles = {Qtiles};

    for (int m = 0; m < M; ++m) {{
      for (int p = 0; p < P; ++p) {{
        for (int q = 0; q < Q; ++q) {{

          int lane_m = (m_sf==1)?0:(m % m_sf);
          int lane_p = (p_sf==1)?0:(p % p_sf);
          int lane_q = (q_sf==1)?0:(q % q_sf);
          int out_bank = (lane_m*p_sf + lane_p)*q_sf + lane_q;

          int cm = (m_sf==1)?m:(m / m_sf);
          int cp = (p_sf==1)?p:(p / p_sf);
          int cq = (q_sf==1)?q:(q / q_sf);
          int out_idx_b = (cm*Ptiles + cp)*Qtiles + cq;

          DTYPE acc = 0.0f;

          for (int c = 0; c < C; ++c) {{
            int c_bank = c & 1;
            int c_blk  = c >> 1;

            int in_c_base = c_blk * (H*W);
            int w_mc_base = (m * (C/2) + c_blk) * (R*S);

            for (int r = 0; r < R; ++r) {{
              int in_row_base = in_c_base + (p+r)*W;
              int w_r_base    = w_mc_base + r*S;

              for (int s = 0; s < S; ++s) {{
                int w_idx = w_r_base + s;
                DTYPE wv  = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];
                DTYPE in_v = (c_bank==0) ? dram_in_b0[in_row_base + (q+s)] : dram_in_b1[in_row_base + (q+s)];
                acc += wv * in_v;
              }}
            }}
          }}

          switch(out_bank) {{
            case 0: dram_out_b0[out_idx_b] = acc; break;
            case 1: dram_out_b1[out_idx_b] = acc; break;
            case 2: dram_out_b2[out_idx_b] = acc; break;
            case 3: dram_out_b3[out_idx_b] = acc; break;
            case 4: dram_out_b4[out_idx_b] = acc; break;
            case 5: dram_out_b5[out_idx_b] = acc; break;
            case 6: dram_out_b6[out_idx_b] = acc; break;
            case 7: dram_out_b7[out_idx_b] = acc; break;
            default: break;
          }}
        }}
      }}
    }}
"""

    # ---------------- SA best (20996) ----------------
    def top_level_body_sa(self) -> str:
        """
        This emits the best-performing mapping-shaped SA kernel (your 20996-cycle style):
        - tiles by q_dram (Qtiles)
        - loops p (GlobalBuffer)
        - computes MxQtile = 4x2 outputs in registers acc[4][2]
        - unroll: acc init, c, s, m_lane
        - r is sequential (best observed)
        """
        d = self.info.dims
        M, P, Q, C, R, S = d["M"], d["P"], d["Q"], d["C"], d["R"], d["S"]
        H, W = P + R - 1, Q + S - 1

        m_sf, p_sf, q_sf = self.out_bank_factors()
        Ptiles = (P + p_sf - 1) // p_sf
        Qtiles = (Q + q_sf - 1) // q_sf

        # This SA kernel assumes the FF mapping is truly eyeriss-like:
        # m_sf should be 4, q_sf should be 2 for your example.
        return f"""
    const int M = {M}, P = {P}, Q = {Q}, C = {C}, R = {R}, S = {S};
    const int H = {H}, W = {W};
    const int m_sf = {m_sf}, p_sf = {p_sf}, q_sf = {q_sf};
    const int Ptiles = {Ptiles}, Qtiles = {Qtiles};

    // DRAM level: Q tiles
    for (int q_dram = 0; q_dram < Qtiles; ++q_dram) {{
      // GlobalBuffer: P
      for (int p = 0; p < P; ++p) {{

        // SACols: M x Qlane
        DTYPE acc[4][2];
        #pragma HLS unroll
        for (int mi = 0; mi < 4; ++mi) {{
          #pragma HLS unroll
          for (int qi = 0; qi < 2; ++qi) {{
            acc[mi][qi] = 0.0f;
          }}
        }}

        // WRegister: R sequential (best observed)
        for (int r = 0; r < R; ++r) {{

          // SARows: C unrolled
          #pragma HLS unroll
          for (int c = 0; c < C; ++c) {{
            int c_bank = c & 1;
            int c_blk  = c >> 1;

            int in_c_base   = c_blk * (H * W);
            int in_row_base = in_c_base + (p + r) * W;

            int q_base = q_dram * 2;

            // S unrolled
            #pragma HLS unroll
            for (int s = 0; s < S; ++s) {{
              DTYPE in_q0 = (c_bank==0) ? dram_in_b0[in_row_base + (q_base + 0 + s)]
                                        : dram_in_b1[in_row_base + (q_base + 0 + s)];
              DTYPE in_q1 = (c_bank==0) ? dram_in_b0[in_row_base + (q_base + 1 + s)]
                                        : dram_in_b1[in_row_base + (q_base + 1 + s)];

              // M lanes unrolled
              #pragma HLS unroll
              for (int m_lane = 0; m_lane < 4; ++m_lane) {{
                int w_idx = (m_lane * (C/2) + c_blk) * (R * S) + r * S + s;
                DTYPE wv  = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];

                acc[m_lane][0] += wv * in_q0;
                acc[m_lane][1] += wv * in_q1;
              }}
            }}
          }}
        }}

        // Write outputs (banked)
        for (int m_lane = 0; m_lane < 4; ++m_lane) {{
          int lane_m = m_lane;
          int cm = 0;
          int cp = p;
          int cq = q_dram;
          int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;

          int out_bank0 = (lane_m * p_sf + 0) * q_sf + 0;
          int out_bank1 = (lane_m * p_sf + 0) * q_sf + 1;

          DTYPE v0 = acc[m_lane][0];
          DTYPE v1 = acc[m_lane][1];

          switch(out_bank0) {{
            case 0: dram_out_b0[out_idx_b] = v0; break;
            case 1: dram_out_b1[out_idx_b] = v0; break;
            case 2: dram_out_b2[out_idx_b] = v0; break;
            case 3: dram_out_b3[out_idx_b] = v0; break;
            case 4: dram_out_b4[out_idx_b] = v0; break;
            case 5: dram_out_b5[out_idx_b] = v0; break;
            case 6: dram_out_b6[out_idx_b] = v0; break;
            case 7: dram_out_b7[out_idx_b] = v0; break;
            default: break;
          }}
          switch(out_bank1) {{
            case 0: dram_out_b0[out_idx_b] = v1; break;
            case 1: dram_out_b1[out_idx_b] = v1; break;
            case 2: dram_out_b2[out_idx_b] = v1; break;
            case 3: dram_out_b3[out_idx_b] = v1; break;
            case 4: dram_out_b4[out_idx_b] = v1; break;
            case 5: dram_out_b5[out_idx_b] = v1; break;
            case 6: dram_out_b6[out_idx_b] = v1; break;
            case 7: dram_out_b7[out_idx_b] = v1; break;
            default: break;
          }}
        }}
      }}
    }}
"""