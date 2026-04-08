#!/usr/bin/env python3
"""
One-shot Bambu harvest script.

For each shape in the correctness test files, runs Bambu, extracts cycle counts,
and saves results to tests/fixtures/ as self-contained JSON fixtures.

Usage:
    python tests/harvest_bambu.py [--arch gemm|conv|all] [--n-mul 1 2 4] [--dry-run]

The fixture JSON format is:
    {
      "<shape_id>": {
        "arch": "<arch>",
        "args": [...],
        "ff_output": "<full FF_output.txt text>",
        "measurements": {"1": <cycles>, "2": <cycles>}
      }
    }

Regular pytest runs (test_model_*.py) only read fixture files — no Bambu needed.
"""

import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

# ── paths ───────────────────────────────────────────────────────────────────
WORKSPACE   = Path(__file__).parent.parent
FIXTURES    = Path(__file__).parent / "fixtures"
SRC_MAIN    = WORKSPACE / "src" / "main.py"

# ── import shape lists from correctness test files (single source of truth) ──
sys.path.insert(0, str(WORKSPACE))
from tests.test_eyeriss_gemm import SHAPES as GEMM_SHAPES, ARCH as GEMM_ARCH
from tests.test_eyeriss_conv  import SHAPES as CONV_SHAPES,  ARCH as CONV_ARCH

FIXTURE_PATHS = {
    "gemm": FIXTURES / "eyeriss_gemm_cycles.json",
    "conv": FIXTURES / "eyeriss_conv_cycles.json",
}

ARCH_SETS = {
    "gemm": (GEMM_ARCH, GEMM_SHAPES),
    "conv": (CONV_ARCH, CONV_SHAPES),
}


# ── helpers ──────────────────────────────────────────────────────────────────

def _shape_id(param) -> str:
    return param.id


def _shape_args(param) -> list:
    return param.values[0]


def _generate_files(arch: str, args: list, tmp_path: Path) -> Path:
    """Run main.py to generate C files + FF_output.txt; return FF_output.txt path."""
    config = {
        "factorflow": {
            "main_cli": "./FactorFlow/main_cli.py",
            "architecture": arch,
            "args": args,
            "force": True,
        },
        "bambu": {"clock_period": 5, "compiler": "I386_GCC8", "opt_level": 3, "v": 0, "extra_args": []},
    }
    cfg_path = tmp_path / "config.json"
    cfg_path.write_text(json.dumps(config))

    r = subprocess.run(
        ["python", str(SRC_MAIN), "--config", str(cfg_path)],
        cwd=WORKSPACE,
        capture_output=True,
        text=True,
    )
    if r.returncode != 0:
        raise RuntimeError(f"Code generation failed:\n{r.stdout}\n{r.stderr}")

    # main.py writes FF_output.txt into a subdirectory of tmp_path
    candidates = list(tmp_path.rglob("FF_output.txt"))
    if not candidates:
        raise FileNotFoundError("FF_output.txt not found after code generation")
    return candidates[0]


def _extract_cycles(log_text: str) -> int:
    m = re.search(r"Run 1 execution time\s*[=:]\s*([\d,]+)", log_text)
    if not m:
        raise ValueError("Could not find 'Run 1 execution time' in Bambu log")
    return int(m.group(1).replace(",", ""))


def _run_bambu(tmp_path: Path, n_mul: int) -> int:
    """Compile SA kernel with Bambu and return simulated cycle count."""
    script = tmp_path / "compile_bambu.sh"
    if not script.exists():
        raise FileNotFoundError(f"compile_bambu.sh not found in {tmp_path}")

    r = subprocess.run(
        ["bash", str(script), "top_level_sa.c", str(n_mul)],
        cwd=tmp_path,
        capture_output=True,
        text=True,
        timeout=7200,
    )

    # Find log
    logs = list(tmp_path.rglob("bambu_*.log"))
    if not logs:
        logs = list(tmp_path.rglob("*.log"))
    if not logs:
        raise FileNotFoundError("No Bambu log found")

    log_text = logs[-1].read_text()
    return _extract_cycles(log_text)


def harvest(arch_key: str, n_muls: list[int], dry_run: bool) -> None:
    arch, shapes = ARCH_SETS[arch_key]
    fixture_path = FIXTURE_PATHS[arch_key]
    FIXTURES.mkdir(exist_ok=True)

    # Load existing fixture (preserve untouched entries)
    existing: dict = {}
    if fixture_path.exists():
        existing = json.loads(fixture_path.read_text())

    for param in shapes:
        shape_id = _shape_id(param)
        args     = _shape_args(param)
        print(f"\n{'[DRY-RUN] ' if dry_run else ''}Shape: {shape_id}  arch={arch}  args={args}")

        if dry_run:
            print(f"  Would run Bambu with n_mul={n_muls}")
            continue

        with tempfile.TemporaryDirectory(prefix=f"harvest_{shape_id}_") as tmp:
            tmp_path = Path(tmp)

            print("  Generating C files + FF_output.txt …", flush=True)
            try:
                ff_path = _generate_files(arch, args, tmp_path)
            except Exception as e:
                print(f"  ERROR during generation: {e}")
                continue

            ff_text = ff_path.read_text()

            entry = existing.get(shape_id, {
                "arch": arch,
                "args": args,
                "ff_output": ff_text,
                "measurements": {},
            })

            for n_mul in n_muls:
                key = str(n_mul)
                if key in entry.get("measurements", {}):
                    print(f"  n_mul={n_mul}: already in fixture, skipping")
                    continue

                print(f"  Running Bambu n_mul={n_mul} …", flush=True)
                try:
                    cycles = _run_bambu(tmp_path, n_mul)
                    entry.setdefault("measurements", {})[key] = cycles
                    print(f"  n_mul={n_mul}: {cycles:,} cycles")
                except Exception as e:
                    print(f"  n_mul={n_mul}: ERROR — {e}")

            existing[shape_id] = entry

        fixture_path.write_text(json.dumps(existing, indent=2))
        print(f"  Fixture saved → {fixture_path}")

    if dry_run:
        print(f"\nDry run complete. Would write to {fixture_path}")
    else:
        print(f"\nHarvest complete. Fixture: {fixture_path}")


# ── CLI ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Harvest Bambu cycle counts into test fixtures")
    parser.add_argument("--arch",    choices=["gemm", "conv", "all"], default="all")
    parser.add_argument("--n-mul",   nargs="+", type=int, default=[1, 2], metavar="N")
    parser.add_argument("--dry-run", action="store_true", help="Print shapes without running Bambu")
    args = parser.parse_args()

    targets = ["gemm", "conv"] if args.arch == "all" else [args.arch]
    for key in targets:
        harvest(key, args.n_mul, args.dry_run)


if __name__ == "__main__":
    main()
