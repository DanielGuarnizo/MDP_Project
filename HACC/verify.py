#!/usr/bin/env python3
"""
Verify accelerator output against the golden reference produced by gen_inputs.py.

Reads workload type, dimensions, and buffer list from <deploy_dir>/accel_config.json.

Usage:
  python3 verify.py <deploy_dir>

Expects:
  <deploy_dir>/accel_config.json     workload metadata + buffer list
  <deploy_dir>/input_data/golden_out.bin
  <deploy_dir>/output_data/<dram_output_pN>.bin   (one per output buffer)
"""

import json
import os
import struct
import sys


def read_bin(path: str, n: int) -> list:
    with open(path, "rb") as f:
        return list(struct.unpack(f"<{n}f", f.read(n * 4)))


def verify_conv(deploy_dir: str, M: int, P: int, Q: int,
                output_bufs: list) -> bool:
    gold = read_bin(os.path.join(deploy_dir, "input_data", "golden_out.bin"), M * P * Q)

    n_op           = len(output_bufs)
    floats_per_port = output_bufs[0]["size_bytes"] // 4

    banks = []
    for buf in output_bufs:
        path = os.path.join(deploy_dir, "output_data", buf["name"] + ".bin")
        banks.append(read_bin(path, floats_per_port))

    # Gather — general formula for any SA column fanout configuration.
    #
    # n_op = n_rows * M where n_rows = SACols_dim0 (spatial Q-split factor).
    # Each port (sacols_0, sacols_1) covers:
    #   sacols_0 = q % n_rows   → which Q-interleave group
    #   sacols_1 = m            → which output channel
    # Port index = sacols_0 * M + sacols_1 = (q % n_rows) * M + m
    # Offset within port = p * (Q // n_rows) + q // n_rows
    #
    # Degenerates to the trivial case when n_rows = 1 (n_op == M):
    #   port = m, offset = p*Q + q
    n_rows    = n_op // M
    q_per_row = Q // n_rows

    out_full = [0.0] * (M * P * Q)
    for m in range(M):
        for p in range(P):
            for q in range(Q):
                port   = (q % n_rows) * M + m
                offset = p * q_per_row + q // n_rows
                out_full[m * P * Q + p * Q + q] = banks[port][offset]

    eps_abs = 1e-3
    eps_rel = 1e-3
    errors  = 0
    for i in range(M * P * Q):
        diff = abs(out_full[i] - gold[i])
        tol  = eps_abs + eps_rel * abs(gold[i])
        if diff > tol:
            print(f"  MISMATCH at [{i}]: HW={out_full[i]:.6f}  gold={gold[i]:.6f}"
                  f"  diff={diff:.6f}  tol={tol:.6f}")
            errors += 1
            if errors > 20:
                print("  (stopping after 20 errors)")
                break

    print()
    if errors == 0:
        print("SUCCESS: all outputs match the golden reference.")
    else:
        print(f"FAILURE: {errors} mismatches out of {M*P*Q} outputs.")
    return errors == 0


def verify_gemm(deploy_dir: str, M: int, K: int, N: int,
                output_bufs: list) -> bool:
    raise NotImplementedError(
        "GEMM verify not yet implemented. "
        "Add gather logic here when needed."
    )


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: verify.py <deploy_dir>")
        sys.exit(1)

    deploy_dir = sys.argv[1]
    cfg_path   = os.path.join(deploy_dir, "accel_config.json")

    if not os.path.exists(cfg_path):
        sys.exit(f"ERROR: {cfg_path} not found.")

    with open(cfg_path) as f:
        cfg = json.load(f)

    if "workload" not in cfg:
        sys.exit(
            "ERROR: accel_config.json has no 'workload' section.\n"
            "Regenerate with:  generate_hacc_project.py --workload conv --dims M P Q C R S"
        )

    output_bufs = [b for b in cfg["buffers"] if b["direction"] == "output"]

    wl   = cfg["workload"]
    kind = wl["type"]

    print(f"Verifying {kind} outputs in {deploy_dir} ...")
    print(f"  output_ports={len(output_bufs)}")

    if kind == "conv":
        ok = verify_conv(deploy_dir, wl["M"], wl["P"], wl["Q"], output_bufs)
    elif kind == "gemm":
        ok = verify_gemm(deploy_dir, wl["M"], wl["K"], wl["N"], output_bufs)
    else:
        sys.exit(f"ERROR: unknown workload type '{kind}'")

    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
