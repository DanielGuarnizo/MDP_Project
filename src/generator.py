from generator_common import parse_ff_output
from generator_gemm import CodeGeneratorGEMM
from generator_conv import CodeGeneratorCONV

def write_hls_files(gen, top_path="top_level.c", tb_path="testbench.c"):
    hw = gen.headers_and_defines()
    hw += "\n" + gen.top_pragmas() + "\n"
    hw += gen.top_signature() + " {\n"
    hw += gen.top_level_body()
    hw += "}\n"
    with open(top_path, "w") as f:
        f.write(hw)
    print(f"Generated HLS hardware file at {top_path}")

    tb = gen.headers_and_defines()
    tb += gen.test_harness()
    with open(tb_path, "w") as f:
        f.write(tb)
    print(f"Generated HLS testbench file at {tb_path}")

def write_cpu_verification_file(gen, output_path="generated_for_cpu.c"):
    code = gen.headers_and_defines()
    code += "\n// --- HARDWARE KERNEL (top_level) ---\n"
    code += gen.top_signature() + " {\n"
    code += gen.top_level_body()
    code += "}\n"
    code += "\n// --- TEST HARNESS ---\n"
    code += gen.test_harness()
    with open(output_path, "w") as f:
        f.write(code)
    print(f"Generated CPU verification file at {output_path}")

if __name__ == "__main__":
    info = parse_ff_output("output/FF_output.txt")
    gen = CodeGeneratorGEMM(info) if info.workload_type == "GEMM" else CodeGeneratorCONV(info)

    print("\n--- Generating files for local CPU verification ---")
    write_cpu_verification_file(gen)

    print("\n--- Generating separate files for Bambu HLS ---")
    write_hls_files(gen)

    print("\n--- Generating Bambu build script ---")
    gen.write_build_script()