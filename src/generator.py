#!/usr/bin/env python3
from generator_common import parse_ff_output
from generator_gemm import CodeGeneratorGEMM
from generator_conv import CodeGeneratorCONV
from conv_harness import make_conv_testbench, conv_tb_param_sizes

def _as_str(x):
    return x[0] if isinstance(x, tuple) else x

def compute_out_banks_for_conv(mapping_info) -> int:
    # out banks = product of spatial factors that map output dims (M,P,Q)
    out_dims = {"M", "P", "Q"}
    banks = 1
    for lvl in mapping_info.spatial_levels:
        til = mapping_info.tiling.get(lvl, {})
        for d, f in til.items():
            if d in out_dims:
                banks *= int(f)
    return max(1, banks)

def write_cpu_verification_file(gen, out_banks=None, output_path="generated_for_cpu.c"):
    code = _as_str(gen.headers_and_defines())

    code += "\n// --- HARDWARE KERNEL (top_level) ---\n"
    try:
        sig = gen.top_signature()
    except TypeError:
        sig = gen.top_signature(out_banks)
    code += _as_str(sig) + " {\n"
    code += _as_str(gen.top_level_body())
    code += "}\n"

    code += "\n// --- TEST HARNESS ---\n"
    if gen.info.workload_type == "GEMM":
        code += _as_str(gen.test_harness_body())
    else:
        # CONV harness lives in conv_harness.py
        code += make_conv_testbench(gen, out_banks=out_banks, in_banks=2, w_banks=2)

    with open(output_path, "w") as f:
        f.write(code)
    print(f"Generated CPU verification file at {output_path}")

def write_hls_files(gen, out_banks=None, top_path="top_level.c", tb_path="testbench.c"):
    hw = _as_str(gen.headers_and_defines())
    hw += "\n/* AXI pragmas for parallel memory buses */\n"
    try:
        hw += _as_str(gen.top_pragmas())
    except TypeError:
        hw += _as_str(gen.top_pragmas(out_banks, enable_cache=False))

    try:
        sig = gen.top_signature()
    except TypeError:
        sig = gen.top_signature(out_banks)

    hw += "\n" + _as_str(sig) + " {\n"
    hw += _as_str(gen.top_level_body())
    hw += "}\n"

    with open(top_path, "w") as f:
        f.write(hw)
    print(f"Generated HLS hardware file at {top_path}")

    # Generate testbench.c (Bambu sim)
    tb = _as_str(gen.headers_and_defines())
    if gen.info.workload_type == "GEMM":
        tb += _as_str(gen.test_harness_body())
    else:
        tb += make_conv_testbench(gen, out_banks=out_banks, in_banks=2, w_banks=2)

    with open(tb_path, "w") as f:
        f.write(tb)
    print(f"Generated HLS testbench file at {tb_path}")

def write_build_script(tb_file="testbench.c", top_file="top_level.c",
                       output_path="compile_bambu.sh", tb_param_sizes=None):
    extra = ""
    if tb_param_sizes:
        for name, sz in tb_param_sizes.items():
            extra += f"  --tb-param-size={name}:{sz} \\\n"

    script = f"""#!/bin/bash
bambu {top_file} \\
  --top-fname=top_level \\
  --generate-interface=INFER \\
  --compiler=I386_GCC8 \\
  --clock-period=5 \\
  -O3 -v4 \\
  --generate-tb={tb_file} \\
{extra}  --simulate \\
  "$@"
"""
    with open(output_path, "w") as f:
        f.write(script)
    print(f"Generated Bambu build script at {output_path}")

if __name__ == "__main__":
    mapping = parse_ff_output("output/FF_output.txt")

    if mapping.workload_type == "GEMM":
        gen = CodeGeneratorGEMM(mapping)
        out_banks = None
        tb_sizes = None
    else:
        gen = CodeGeneratorCONV(mapping)
        out_banks = compute_out_banks_for_conv(mapping)
        tb_sizes = conv_tb_param_sizes(gen, out_banks=out_banks, in_banks=2, w_banks=2)

    print("\n--- Generating files for local CPU verification ---")
    write_cpu_verification_file(gen, out_banks=out_banks)

    print("\n--- Generating separate files for Bambu HLS ---")
    write_hls_files(gen, out_banks=out_banks)

    print("\n--- Generating Bambu build script ---")
    write_build_script(tb_param_sizes=tb_sizes)