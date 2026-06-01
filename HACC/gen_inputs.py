#!/usr/bin/env python3
"""
Generate banked input .bin files for the panda accelerator.

Reads workload type, dimensions, and buffer list from <deploy_dir>/accel_config.json.
Run `generate_hacc_project.py --workload conv --dims M P Q C R S` first.

Usage:
  python3 gen_inputs.py <deploy_dir> [--seed N]

Outputs written to <deploy_dir>/input_data/:
  <dram_input_pN>.bin    activation banks, port = c % n_input_ports
  <dram_weight_pN>.bin   weight banks,     port = c % n_weight_ports
  golden_out.bin          float32 golden output for verify.py
"""

import argparse
import json
import os
import random
import struct
import sys


def write_bin(path: str, data: list) -> None:
    with open(path, "wb") as f:
        f.write(struct.pack(f"<{len(data)}f", *data))
    print(f"  wrote {len(data)*4:5d} B  ({len(data):4d} float32)  ->  {path}")


def gen_conv(
    out_dir: str,
    M: int, P: int, Q: int, C: int, R: int, S: int,
    input_bufs: list, weight_bufs: list,
    seed: int,
) -> None:
    H = P + R - 1
    W = Q + S - 1
    random.seed(seed)

    in_full = [random.random() for _ in range(C * H * W)]
    w_full  = [random.random() for _ in range(M * C * R * S)]

    gold = [0.0] * (M * P * Q)
    for m in range(M):
        for c in range(C):
            for r in range(R):
                for s in range(S):
                    for p in range(P):
                        for q in range(Q):
                            gold[m*P*Q + p*Q + q] += (
                                w_full[m*C*R*S + c*R*S + r*S + s] *
                                in_full[c*H*W + (p+r)*W + (q+s)]
                            )

    # Scatter inputs: port = c % n_ip, block = c // n_ip
    n_ip = len(input_bufs)
    C_per_ip = (C + n_ip - 1) // n_ip
    dram_in = [[0.0] * (C_per_ip * H * W) for _ in range(n_ip)]
    for c in range(C):
        port  = c % n_ip
        block = c // n_ip
        for y in range(H):
            for x in range(W):
                dram_in[port][block * H * W + y * W + x] = in_full[c * H * W + y * W + x]

    # Scatter weights: port = c % n_wp, weight_dram_index = (m*C_per_wp + block)*R*S + r*S + s
    n_wp = len(weight_bufs)
    C_per_wp = (C + n_wp - 1) // n_wp
    dram_w = [[0.0] * (M * C_per_wp * R * S) for _ in range(n_wp)]
    for m in range(M):
        for c in range(C):
            port  = c % n_wp
            block = c // n_wp
            for r in range(R):
                for s in range(S):
                    dram_w[port][(m * C_per_wp + block) * R * S + r * S + s] = (
                        w_full[m * C * R * S + c * R * S + r * S + s]
                    )

    os.makedirs(out_dir, exist_ok=True)
    for i, buf in enumerate(input_bufs):
        write_bin(os.path.join(out_dir, buf["name"] + ".bin"), dram_in[i])
    for i, buf in enumerate(weight_bufs):
        write_bin(os.path.join(out_dir, buf["name"] + ".bin"), dram_w[i])

    gold_path = os.path.join(out_dir, "golden_out.bin")
    with open(gold_path, "wb") as f:
        f.write(struct.pack(f"<{len(gold)}f", *gold))
    print(f"  wrote {len(gold)*4:5d} B  ({len(gold):4d} float32)  ->  {gold_path}  [golden]")


def gen_gemm(
    out_dir: str,
    M: int, K: int, N: int,
    input_bufs: list, weight_bufs: list,
    seed: int,
) -> None:
    raise NotImplementedError(
        "GEMM gen_inputs not yet implemented. "
        "Add banking scatter and golden GEMM here when needed."
    )


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("deploy_dir", help="Deploy folder containing accel_config.json")
    p.add_argument("--seed", type=int, default=42, help="RNG seed (default: 42)")
    args = p.parse_args()

    cfg_path = os.path.join(args.deploy_dir, "accel_config.json")
    if not os.path.exists(cfg_path):
        sys.exit(f"ERROR: {cfg_path} not found.")

    with open(cfg_path) as f:
        cfg = json.load(f)

    if "workload" not in cfg:
        sys.exit(
            "ERROR: accel_config.json has no 'workload' section.\n"
            "Regenerate with:  generate_hacc_project.py --workload conv --dims M P Q C R S"
        )

    input_bufs  = [b for b in cfg["buffers"] if b["direction"] == "input"]
    weight_bufs = [b for b in cfg["buffers"] if b["direction"] == "inout"]

    wl   = cfg["workload"]
    kind = wl["type"]
    out  = os.path.join(args.deploy_dir, "input_data")

    print(f"\nGenerating {kind} inputs → {out}  (seed={args.seed})")
    print(f"  input_ports={len(input_bufs)}  weight_ports={len(weight_bufs)}")

    if kind == "conv":
        gen_conv(out, wl["M"], wl["P"], wl["Q"], wl["C"], wl["R"], wl["S"],
                 input_bufs, weight_bufs, args.seed)
    elif kind == "gemm":
        gen_gemm(out, wl["M"], wl["K"], wl["N"], input_bufs, weight_bufs, args.seed)
    else:
        sys.exit(f"ERROR: unknown workload type '{kind}'")

    print(f"\nSeed={args.seed}  done.")


if __name__ == "__main__":
    main()
