from parser import parse_ff_output
from collections import OrderedDict

class CodeGenerator:
    def __init__(self, mapping_info):
        self.info = mapping_info
        self.c_code = ""
        self.ordered_levels = self.info.levels
        # Define the canonical loop order for consistency
        self.loop_order = ['N', 'M', 'P', 'Q', 'C', 'R', 'S']

    def _get_inner_tile_product(self, dim, start_level_name):
        """
        Calculates the product of all tile sizes for a dimension *inside*
        of a given level. This is the 'weight' for the reconstruction formula.
        """
        product = 1
        start_idx = self.ordered_levels.index(start_level_name)
        
        # Iterate through levels from the one *inside* the start_level
        for i in range(start_idx + 1, len(self.ordered_levels)):
            level = self.ordered_levels[i]
            if level == 'Compute': continue
            if dim in self.info.tiling.get(level, {}):
                product *= self.info.tiling[level][dim]
        return product

    def _generate_index_reconstruction_code(self, indent_str):
        """
        Generates the C code lines for calculating all global indices.
        """
        code = f"{indent_str}// Reconstruct global indices from tiled loop variables\n"
        
        for dim in self.loop_order:
            if dim not in self.info.total_dims: continue # Skip if dim not in workload

            formula_parts = []
            for i, level_name in enumerate(self.ordered_levels):
                if level_name == 'Compute': continue
                
                tiling_at_level = self.info.tiling.get(level_name, {})
                if dim in tiling_at_level:
                    loop_var = f"{dim.lower()}_{level_name.lower()}"
                    inner_prod = self._get_inner_tile_product(dim, level_name)
                    if inner_prod > 1:
                        formula_parts.append(f"{loop_var} * {inner_prod}")
                    else:
                        formula_parts.append(loop_var)
            
            if formula_parts:
                formula = " + ".join(formula_parts)
                code += f"{indent_str}int global_{dim.lower()} = {formula};\n"
        
        # Add special indices for CNN inputs
        if self.info.workload_type == 'CONV':
            code += f"{indent_str}int global_input_p = global_p + global_r; // Assuming stride 1\n"
            code += f"{indent_str}int global_input_q = global_q + global_s; // Assuming stride 1\n"

        return code

    def _generate_array_access_code(self, indent_str):
        """
        Generates the C code for the final memory access using global indices.
        """
        code = f"{indent_str}// Calculate flat array indices for DRAM access\n"
        
        # This is complex in reality. For now, we'll create a simplified but
        # representative version. A real implementation would need to know
        # the memory layout (e.g., row-major).

        if self.info.workload_type == 'GEMM':
            # Out[m][n] += W[m][k] * In[k][n]
            # Flat index for Out[m][n] = m * N_TOTAL + n
            out_idx = f"global_m * N_TOTAL + global_n"
            w_idx = f"global_m * K_TOTAL + global_k"
            in_idx = f"global_k * N_TOTAL + global_n"
            code += f"{indent_str}dram_out[{out_idx}] += dram_w[{w_idx}] * dram_in[{in_idx}];\n"
        
        elif self.info.workload_type == 'CONV':
            # Out[m][p][q] += W[m][c][r][s] * In[c][p+r][q+s]
            # This requires multi-dimensional strides. Let's make a conceptual formula.
            # Stride_Out_P = Q_TOTAL
            # Stride_Out_M = P_TOTAL * Q_TOTAL
            # ... and so on ...
            out_idx = f"global_m*(P_TOTAL*Q_TOTAL) + global_p*Q_TOTAL + global_q"
            w_idx = f"global_m*(C_TOTAL*R_TOTAL*S_TOTAL) + global_c*(R_TOTAL*S_TOTAL) + global_r*S_TOTAL + global_s"
            in_idx = f"global_c*( (P_TOTAL+R_TOTAL-1)*(Q_TOTAL+S_TOTAL-1) ) + global_input_p*(Q_TOTAL+S_TOTAL-1) + global_input_q"
            
            code += f"{indent_str}dram_out[{out_idx}] += dram_w[{w_idx}] * dram_in[{in_idx}];\n"
            
        return code

    def write_c_file(self, output_path="generated_systolic.c", include_harness=True):
        # Reset and generate headers
        self.c_code = ""
        self.generate_headers_and_defines()
        
        # Generate the full nested loop structure
        full_code = "void top_level(DTYPE *dram_in, DTYPE *dram_w, DTYPE *dram_out) {\n"
        indent_str = "    "
        for level_name in self.ordered_levels:
            if level_name == 'Compute': continue

            full_code += f"{indent_str}// Level: {level_name}\n"
            tiling_at_level = self.info.tiling.get(level_name, {})
            is_spatial = level_name in self.info.spatial_levels

            for dim in self.loop_order:
                if dim in tiling_at_level:
                    loop_bound = tiling_at_level[dim]
                    loop_var = f"{dim.lower()}_{level_name.lower()}"
                    
                    if is_spatial:
                        full_code += f"{indent_str}#pragma GCC unroll {loop_bound}\n"
                    
                    full_code += f"{indent_str}for (int {loop_var} = 0; {loop_var} < {loop_bound}; ++{loop_var}) {{\n"
                    indent_str += "    "
        
        # ----- CORE LOGIC INSERTION -----
        # 1. Reconstruct global indices
        full_code += self._generate_index_reconstruction_code(indent_str)
        # 2. Perform the memory access / MAC operation
        full_code += self._generate_array_access_code(indent_str)
        # ---------------------------------
        
        # Close all loops
        for _ in range(full_code.count("{")):
            indent_str = indent_str[:-4]
            full_code += f"{indent_str}}}\n"
        
        self.c_code += full_code
        
        if include_harness:
            self.generate_test_harness()

        with open(output_path, 'w') as f:
            f.write(self.c_code)
        print(f"Generated C code at {output_path}")

    def generate_headers_and_defines(self):
        self.c_code += "#include <stdio.h>\n\n"
        self.c_code += "#define DTYPE float\n"
        
        # Calculate PE grid size. Let's assume a 1D array for this version.
        self.pe_count = self.info.get_grid_size()
        self.c_code += f"#define PE_COUNT {self.pe_count}\n\n"

        for dim, size in self.info.total_dims.items():
            self.c_code += f"#define {dim}_TOTAL {size}\n"
        self.c_code += "\n"

    def _generate_nested_loops(self, start_level_idx, stop_level_name, indent=1):
        """
        A recursive helper function to generate nested for-loops from a
        starting memory level down to a stopping level.
        """
        loop_code = ""
        indent_str = "    " * indent
        
        # Find the index of the stop level
        stop_level_idx = self.ordered_levels.index(stop_level_name)

        # Iterate from the outer level inwards
        for i in range(start_level_idx, stop_level_idx + 1):
            level_name = self.ordered_levels[i]
            
            # Skip spatial levels in the temporal loop generation
            if level_name in self.info.spatial_levels:
                continue

            loop_code += f"{indent_str}// Loops for level: {level_name}\n"
            
            tiling_at_level = self.info.tiling.get(level_name, {})
            # We need a consistent order for the loops (e.g., M, N, K)
            # This order should come from the dataflow permutation
            loop_order = ['M', 'N', 'K'] # Assuming this order for now
            if self.info.workload_type == 'CONV':
                loop_order = ['P', 'Q', 'R', 'S', 'C', 'M'] # Example for CONV

            for dim in loop_order:
                if dim in tiling_at_level:
                    loop_var = f"{dim.lower()}_{level_name.lower()}"
                    loop_bound = tiling_at_level[dim]
                    loop_code += f"{indent_str}for (int {loop_var} = 0; {loop_var} < {loop_bound}; ++{loop_var}) {{\n"
                    indent_str += "    "
        
        return loop_code, indent_str

    def generate_pe_kernel(self):
        # The PE kernel executes the loops from the innermost non-compute level
        pe_kernel_start_level = ""
        # Find the first level above 'Compute'
        for level in reversed(self.ordered_levels):
            if level != "Compute":
                pe_kernel_start_level = level
                break
        
        if not pe_kernel_start_level:
             return # Should not happen

        # Find the start index for the recursive loop generator
        start_idx = self.ordered_levels.index(pe_kernel_start_level)

        loop_code, indent = self._generate_nested_loops(start_idx, pe_kernel_start_level, indent=1)

        pe_code = "void pe_kernel(volatile DTYPE *in, volatile DTYPE *w, volatile DTYPE *out) {\n"
        pe_code += "    // PE-local logic will be generated here\n"
        pe_code += loop_code
        pe_code += f"{indent}// MAC Operation\n"
        pe_code += f"{indent}*out += (*in) * (*w);\n"
        
        # Close all the loops
        for _ in range(loop_code.count("{")):
            indent = indent[:-4]
            pe_code += f"{indent}}}\n"
            
        pe_code += "}\n\n"
        self.c_code += pe_code

    def generate_top_level(self):
        # A simplified dataflow top-level function
        top_code = "void top_level(DTYPE *dram_in, DTYPE *dram_w, DTYPE *dram_out) {\n"
        top_code += f"    // On-chip buffers to act as streams\n"
        top_code += f"    DTYPE pe_ins[PE_COUNT], pe_ws[PE_COUNT], pe_outs[PE_COUNT];\n\n"
        
        # Generate the top-level temporal loops (DRAM to PE array)
        compute_level_idx = self.ordered_levels.index(self.spatial_levels[0]) -1
        outer_loops, indent = self._generate_nested_loops(0, self.ordered_levels[compute_level_idx])
        top_code += outer_loops
        
        # Inside the innermost temporal loop, unroll across all PEs
        top_code += f"{indent}// Unroll across the PE array\n"
        top_code += f"{indent}#pragma GCC unroll {self.pe_count}\n"
        top_code += f"{indent}for (int pe_id = 0; pe_id < PE_COUNT; ++pe_id) {{\n"
        top_code += f"{indent}    // In a real implementation, you'd calculate the correct\n"
        top_code += f"{indent}    // data indices for each PE here.\n"
        top_code += f"{indent}    pe_kernel(&pe_ins[pe_id], &pe_ws[pe_id], &pe_outs[pe_id]);\n"
        top_code += f"{indent}}}\n"

        # Close all outer loops
        for _ in range(outer_loops.count("{")):
            indent = indent[:-4]
            top_code += f"{indent}}}\n"

        top_code += "}\n"
        self.c_code += top_code

    def write_build_script(self, c_file="generated_systolic.c", output_path="compile.sh"):
        # This function remains the same
        script = f"""#!/bin/bash
bambu {c_file} \\
    --top-fname=top_level \\
    --pipelining=... # This needs to target the innermost loop, which is complex to name
    "$@"
"""
        with open(output_path, 'w') as f:
            f.write(script)
        print(f"Generated build script at {output_path}")

    def generate_test_harness(self):
        """
        Generates a main() function and helper utilities to verify the
        correctness of the generated top_level function against a standard
        golden implementation.
        """
        
        # Determine total sizes of the arrays for malloc
        if self.info.workload_type == 'GEMM':
            m, k, n = self.info.total_dims['M'], self.info.total_dims['K'], self.info.total_dims['N']
            size_in = k * n
            size_w = m * k
            size_out = m * n
        elif self.info.workload_type == 'CONV':
            p, q, r, s, c, m = (self.info.total_dims.get(d, 1) for d in ['P', 'Q', 'R', 'S', 'C', 'M'])
            size_in = c * (p + r - 1) * (q + s - 1)
            size_w = m * c * r * s
            size_out = m * p * q
        else:
            size_in = size_w = size_out = 1
            
        harness_code = f"""
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

// Helper function to initialize matrices with random data
void initialize_matrices(DTYPE *in, DTYPE *w, DTYPE *out, DTYPE *out_golden) {{
    for (int i = 0; i < {size_in}; ++i) in[i] = (DTYPE)rand() / RAND_MAX;
    for (int i = 0; i < {size_w}; ++i) w[i] = (DTYPE)rand() / RAND_MAX;
    for (int i = 0; i < {size_out}; ++i) {{
        out[i] = 0.0;
        out_golden[i] = 0.0;
    }}
}}

// Golden reference implementation
void golden_reference(DTYPE *in, DTYPE *w, DTYPE *out_golden) {{
"""
        # Dynamically generate the golden reference implementation
        if self.info.workload_type == 'GEMM':
            m, k, n = self.info.total_dims['M'], self.info.total_dims['K'], self.info.total_dims['N']
            harness_code += f"""
    for (int m_ = 0; m_ < {m}; ++m_) {{
        for (int n_ = 0; n_ < {n}; ++n_) {{
            for (int k_ = 0; k_ < {k}; ++k_) {{
                out_golden[m_ * {n} + n_] += w[m_ * {k} + k_] * in[k_ * {n} + n_];
            }}
        }}
    }}
"""
        elif self.info.workload_type == 'CONV':
            p, q, r, s, c, m = (self.info.total_dims.get(d, 1) for d in ['P', 'Q', 'R', 'S', 'C', 'M'])
            in_h, in_w = p + r - 1, q + s - 1
            harness_code += f"""
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

        harness_code += f"""
}}

// Comparison function
int compare_results(DTYPE *out, DTYPE *out_golden) {{
    // Increased epsilon to account for floating-point accumulation order differences.
    // A value of 1e-3 is a reasonable tolerance for this kind of complex MAC operation.
    const float epsilon = 1e-3; 
    int errors = 0;
    for (int i = 0; i < {size_out}; ++i) {{
        if (fabs(out[i] - out_golden[i]) > epsilon) {{
            printf("ERROR at index %d: HLS_val=%.6f, Golden_val=%.6f\\n", i, out[i], out_golden[i]);
            errors++;
            if (errors > 20) return errors; // Stop after 20 errors
        }}
    }}
    return errors;
}}

int main() {{
    printf("Allocating memory...\\n");
    DTYPE *dram_in = (DTYPE*)malloc({size_in} * sizeof(DTYPE));
    DTYPE *dram_w = (DTYPE*)malloc({size_w} * sizeof(DTYPE));
    DTYPE *dram_out = (DTYPE*)malloc({size_out} * sizeof(DTYPE));
    DTYPE *dram_out_golden = (DTYPE*)malloc({size_out} * sizeof(DTYPE));

    if (!dram_in || !dram_w || !dram_out || !dram_out_golden) {{
        printf("ERROR: Memory allocation failed!\\n");
        return -1;
    }}

    printf("Initializing matrices...\\n");
    initialize_matrices(dram_in, dram_w, dram_out, dram_out_golden);

    printf("Running golden reference implementation...\\n");
    golden_reference(dram_in, dram_w, dram_out_golden);

    printf("Running HLS top_level function...\\n");
    top_level(dram_in, dram_w, dram_out);

    printf("Comparing results...\\n");
    int num_errors = compare_results(dram_out, dram_out_golden);

    if (num_errors == 0) {{
        printf("SUCCESS: The results match the golden reference!\\n");
    }} else {{
        printf("FAILURE: Found %d mismatches.\\n", num_errors);
    }}

    free(dram_in);
    free(dram_w);
    free(dram_out);
    free(dram_out_golden);

    return num_errors;
}}
"""
        
        self.c_code += harness_code

if __name__ == '__main__':
    mapping_data = parse_ff_output("./output/FF_output.txt")
    generator = CodeGenerator(mapping_data)
    # Generate the file with the test harness included
    generator.write_c_file(include_harness=True)
    # You can keep the build script generation separate
    generator.write_build_script()