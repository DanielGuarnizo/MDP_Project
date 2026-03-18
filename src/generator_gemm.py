# from generator_common import CodeGenBase

# class CodeGeneratorGEMM(CodeGenBase):
#     def _adder_tree(self, indent, terms, prefix="t_"):
#         code = ""
#         stage = 0
#         cur = list(terms)
#         while len(cur) > 1:
#             stage += 1
#             nxt = []
#             code += f"{indent}// Adder tree stage {stage}\n"
#             for i in range(0, len(cur), 2):
#                 if i+1 < len(cur):
#                     v = f"{prefix}s{stage}_{i//2}"
#                     code += f"{indent}DTYPE {v} = {cur[i]} + {cur[i+1]};\n"
#                     nxt.append(v)
#                 else:
#                     nxt.append(cur[i])
#             cur = nxt
#         return code, cur[0]

#     def top_level_body(self):
#         m = self.info.total_dims['M']
#         k = self.info.total_dims['K']
#         n = self.info.total_dims['N']

#         indent = "    "
#         open_loops = 0
#         code = ""

#         # Promotion buffer
#         code += f"{indent}// --- LOCAL MEMORY PROMOTION (Solves AXI RAW Hazard) ---\n"
#         code += f"{indent}DTYPE local_dram_out[{m} * {n}];\n"
#         code += f"{indent}for(int i=0;i<{m}*{n};++i) local_dram_out[i]=dram_out[i];\n\n"

#         # Identify first spatial M and K levels
#         m_level = next((lvl for lvl in self.info.spatial_levels if 'M' in self.info.tiling.get(lvl,{})), None)
#         k_level = next((lvl for lvl in self.info.spatial_levels if 'K' in self.info.tiling.get(lvl,{})), None)
#         apply_fix = bool(m_level and k_level)
#         m_pe = self.info.tiling[m_level]['M'] if m_level else 1
#         k_pe = self.info.tiling[k_level]['K'] if k_level else 1

#         # Emit loops, skipping postponed spatial levels if fix
#         for lvl in self.info.levels:
#             if lvl == 'Compute': 
#                 continue
#             if apply_fix and lvl in (m_level, k_level):
#                 continue
#             code += f"{indent}// Level: {lvl}\n"
#             til = self.info.tiling.get(lvl,{})
#             is_spatial = lvl in self.info.spatial_levels
#             for dim in self.loop_order:
#                 if dim in til:
#                     b = til[dim]
#                     var = f"{dim.lower()}_{lvl.lower()}"
#                     if is_spatial:
#                         code += f"{indent}#pragma GCC unroll {b}\n"
#                     code += f"{indent}for(int {var}=0; {var}<{b}; ++{var}) {{\n"
#                     indent += "    "
#                     open_loops += 1

#         if apply_fix:
#             # Load output column
#             code += f"{indent}// STEP 1: Fetch current output column\n"
#             code += f"{indent}DTYPE local_acc[{m}];\n"
#             code += f"{indent}for(int mm=0; mm<{m}; ++mm) local_acc[mm] = local_dram_out[mm*{n} + ({self.dim_formula('N')})];\n\n"

#             code += f"{indent}// STEP 2: Multiply into isolated PE registers\n"
#             code += f"{indent}DTYPE pe_macs[{m_pe}][{k_pe}];\n"
#             code += f"{indent}#pragma GCC unroll {k_pe}\n"
#             code += f"{indent}for(int k_{k_level.lower()}=0; k_{k_level.lower()}<{k_pe}; ++k_{k_level.lower()}) {{\n"
#             indk = indent + "    "
#             code += f"{indk}#pragma GCC unroll {m_pe}\n"
#             code += f"{indk}for(int m_{m_level.lower()}=0; m_{m_level.lower()}<{m_pe}; ++m_{m_level.lower()}) {{\n"
#             indm = indk + "    "
#             code += f"{indm}int global_n = {self.dim_formula('N')};\n"
#             code += f"{indm}int global_m = {self.dim_formula('M')};\n"
#             code += f"{indm}int global_k = {self.dim_formula('K')};\n"
#             code += f"{indm}pe_macs[m_{m_level.lower()}][k_{k_level.lower()}] = dram_w[global_m*{k}+global_k] * dram_in[global_k*{n}+global_n];\n"
#             code += f"{indk}}}\n"
#             code += f"{indent}}}\n\n"

#             code += f"{indent}// STEP 3: Explicit adder tree reduction over K\n"
#             code += f"{indent}for(int m_{m_level.lower()}=0; m_{m_level.lower()}<{m_pe}; ++m_{m_level.lower()}) {{\n"
#             indr = indent + "    "
#             terms = [f"pe_macs[m_{m_level.lower()}][{i}]" for i in range(k_pe)]
#             tree, finalv = self._adder_tree(indr, terms)
#             code += tree
#             code += f"{indr}DTYPE sum = {finalv};\n"
#             code += f"{indr}int global_m = {self.dim_formula('M')};\n"
#             code += f"{indr}local_acc[global_m] += sum;\n"
#             code += f"{indent}}}\n\n"

#             code += f"{indent}// STEP 4: Write column back\n"
#             code += f"{indent}for(int mm=0; mm<{m}; ++mm) local_dram_out[mm*{n} + ({self.dim_formula('N')})] = local_acc[mm];\n"
#         else:
#             # Original MAC
#             code += f"{indent}// Reconstruct globals\n"
#             code += f"{indent}int global_n = {self.dim_formula('N')};\n"
#             code += f"{indent}int global_m = {self.dim_formula('M')};\n"
#             code += f"{indent}int global_k = {self.dim_formula('K')};\n"
#             code += f"{indent}local_dram_out[global_m*{n}+global_n] += dram_w[global_m*{k}+global_k]*dram_in[global_k*{n}+global_n];\n"

#         # Close mapping loops
#         for _ in range(open_loops):
#             indent = indent[:-4]
#             code += f"{indent}}}\n"

#         code += f"\n    // --- WRITE BACK TO EXTERNAL SLOW MEMORY ---\n"
#         code += f"    for(int i=0;i<{m}*{n};++i) dram_out[i]=local_dram_out[i];\n"
#         return code

#!/usr/bin/env python3
from __future__ import annotations
from generator_common import MappingInfo, CodeGenBase

class CodeGeneratorGEMM(CodeGenBase):
    def __init__(self, info: MappingInfo):
        super().__init__(info)

    def top_signature(self) -> str:
        return "void top_level(DTYPE *A, DTYPE *B, DTYPE *C)"

    def top_pragmas(self) -> str:
        return ""

    def top_level_body(self) -> str:
        return "    // GEMM not implemented in this minimal stub\n"

    def test_harness_body(self) -> str:
        return "int main(){return 0;}\n"