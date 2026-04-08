#!/usr/bin/env python3
"""
Populate experiments/ for every shape defined in the correctness test files.

Shape → experiment directory mapping (1-based index in SHAPES list):
  GEMM: experiments/eyeriss/gemm/ex1..ex7
  CONV: experiments/eyeriss/conv/ex1..ex6

By default, existing experiments are skipped (checked via FF_output/FF_output.txt).
Use --force to regenerate them.

Usage:
    python scripts/setup_experiments.py              # gemm + conv
    python scripts/setup_experiments.py --arch gemm  # gemm only
    python scripts/setup_experiments.py --arch conv  # conv only
    python scripts/setup_experiments.py --force      # regenerate even if exists
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path

WORKSPACE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WORKSPACE))

from tests.test_eyeriss_gemm import SHAPES as GEMM_SHAPES, ARCH as GEMM_ARCH
from tests.test_eyeriss_conv  import SHAPES as CONV_SHAPES,  ARCH as CONV_ARCH


def _shape_args(param) -> list:
    return param.values[0]


def _shape_id(param) -> str:
    return param.id


def _config(arch: str, args: list) -> dict:
    return {
        "factorflow": {
            "main_cli": "./FactorFlow/main_cli.py",
            "architecture": arch,
            "args": args,
            "force": False,
        },
        "bambu": {
            "clock_period": 5,
            "compiler": "I386_GCC8",
            "opt_level": 3,
            "v": 4,
            "extra_args": [],
        },
    }


def setup(arch_key: str, force: bool) -> None:
    if arch_key == "gemm":
        shapes, arch, workload = GEMM_SHAPES, GEMM_ARCH, "gemm"
    else:
        shapes, arch, workload = CONV_SHAPES, CONV_ARCH, "conv"

    base = WORKSPACE / "experiments" / "eyeriss" / workload

    for i, param in enumerate(shapes, start=1):
        args     = _shape_args(param)
        shape_id = _shape_id(param)
        ex_dir   = base / f"ex{i}"
        ff_out   = ex_dir / "FF_output" / "FF_output.txt"

        if ff_out.exists() and not force:
            print(f"[SKIP] {workload}/ex{i}  ({shape_id}  {args})")
            continue

        print(f"[GEN]  {workload}/ex{i}  ({shape_id}  {args})")
        ex_dir.mkdir(parents=True, exist_ok=True)

        cfg_path = ex_dir / "config.json"
        cfg_path.write_text(json.dumps(_config(arch, args), indent=2))

        result = subprocess.run(
            [sys.executable, str(WORKSPACE / "src" / "main.py"),
             "--config", str(cfg_path)],
            cwd=WORKSPACE,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            print(f"  ERROR: code generation failed for {workload}/ex{i}")
            print(result.stdout)
            print(result.stderr)
        else:
            print(f"  OK → {ex_dir}")


def main():
    parser = argparse.ArgumentParser(
        description="Create experiments/ directories for all test shapes")
    parser.add_argument("--arch",  choices=["gemm", "conv", "all"], default="all")
    parser.add_argument("--force", action="store_true",
                        help="Regenerate even if experiment already exists")
    args = parser.parse_args()

    targets = ["gemm", "conv"] if args.arch == "all" else [args.arch]
    for key in targets:
        setup(key, args.force)


if __name__ == "__main__":
    main()
