#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path
from typing import Dict, Any

from ff_parser import parse_ff_output
from mapping_types import MappingInfo

from pathlib import Path

def _repo_root() -> Path:
    # src/main.py -> src -> repo root
    return Path(__file__).resolve().parents[1]

def _resolve_path_maybe_relative(p: str, base: Path) -> Path:
    pp = Path(p)
    if pp.is_absolute():
        return pp.resolve()
    return (base / pp).resolve()


def main() -> int:
    args = _parse_args()
    config_path = Path(args.config).resolve()
    if not config_path.exists():
        raise FileNotFoundError(f"Config not found: {config_path}")

    config_dir = config_path.parent
    config = _load_json(config_path)

    # Layout (relative to config folder)
    layout = config.get("layout", {}) or {}
    ff_output_dirname = layout.get("ff_output_dir", "FF_output")
    bambu_output_dirname = layout.get("bambu_output_dir", "Bambu_outputs")  # not used by bambu itself yet
    # generator_expected_output_dir removed on purpose (no bridging)

    ff_dir = (config_dir / ff_output_dirname)
    ff_dir.mkdir(parents=True, exist_ok=True)

    bambu_dir = (config_dir / bambu_output_dirname)
    bambu_dir.mkdir(parents=True, exist_ok=True)

    ff_out_txt = ff_dir / "FF_output.txt"

    # 1) FactorFlow mapping
    _run_factorflow_if_needed(config=config, config_dir=config_dir, ff_out_txt=ff_out_txt)

    # 2) Parse mapping
    mapping: MappingInfo = parse_ff_output(str(ff_out_txt))
    # We rely on parser to set:
    #  - mapping.arch_workload (e.g., "eyeriss-conv")
    #  - mapping.arch (e.g., "eyeriss")
    #  - mapping.workload (e.g., "CONV")

    # 3) Dispatch to generator runner
    _dispatch_and_generate(mapping=mapping, config=config, out_dir=config_dir)

    print("\nAll set.")
    print(f"Config folder: {config_dir}")
    print("Run:")
    print(f"  cd {config_dir}")
    print("  ./run_compare.sh")
    return 0


# =========================
# Dispatch
# =========================


def _dispatch_and_generate(mapping, config, out_dir):
    wtype = (getattr(mapping, "workload", "") or "").strip().upper()
    arch  = (getattr(mapping, "arch", "") or "").strip().lower()

    # fallback if parser ever leaves them empty (shouldn't, but safe)
    if not wtype or not arch:
        aw = (getattr(mapping, "arch_workload", "") or "").strip().lower()
        if not arch and aw:
            arch = aw.split("-", 1)[0]
        if not wtype and aw:
            if "conv" in aw:
                wtype = "CONV"
            elif "gemm" in aw:
                wtype = "GEMM"

    if wtype == "CONV" and arch == "eyeriss":
        from codegen.conv.eyeriss_generator import generate_experiment
        generate_experiment(mapping=mapping, config=config, out_dir=out_dir)
        return

    if wtype == "GEMM" and arch == "eyeriss":
        from codegen.gemm.eyeriss_generator import generate_experiment
        generate_experiment(mapping=mapping, config=config, out_dir=out_dir)
        return

    raise NotImplementedError(
        f"No generator for arch={arch!r} workload={wtype!r} (arch_workload={mapping.arch_workload!r})"
    )
# =========================
# FactorFlow runner
# =========================
def _run_factorflow_if_needed(config: Dict[str, Any], config_dir: Path, ff_out_txt: Path) -> None:
    """
    Runs FactorFlow main_cli.py (or reuses existing mapping) and writes stdout to ff_out_txt.

    Resolution rules for factorflow.main_cli:
      1) If absolute: use it
      2) Else try relative to repo root (where src/ lives)
      3) Else try relative to the experiment folder (config_dir)
    """
    ff_cfg = config.get("factorflow", {}) or {}

    main_cli = ff_cfg.get("main_cli", "./FactorFlow/main_cli.py")
    architecture = ff_cfg.get("architecture", None)
    args = ff_cfg.get("args", [])
    force = bool(ff_cfg.get("force", False))

    if architecture is None:
        raise ValueError("config.factorflow.architecture is required (e.g., 'eyeriss-conv')")

    # Reuse existing mapping unless force=True
    if ff_out_txt.exists() and not force:
        print(f"[FactorFlow] Reusing existing mapping: {ff_out_txt}")
        return

    # Compute repo root robustly from this file location:
    # /workspace/src/main.py -> repo_root = /workspace
    repo_root = Path(__file__).resolve().parents[1]

    main_cli_path = Path(main_cli)
    if main_cli_path.is_absolute():
        candidates = [main_cli_path]
    else:
        # Try repo_root first, then config_dir
        candidates = [
            (repo_root / main_cli).resolve(),
            (config_dir / main_cli).resolve(),
        ]

    main_cli_path_resolved = None
    for cand in candidates:
        if cand.exists():
            main_cli_path_resolved = cand
            break

    if main_cli_path_resolved is None:
        cand_str = "\n  - " + "\n  - ".join(str(c) for c in candidates)
        raise FileNotFoundError(
            f"FactorFlow main_cli.py not found. Tried:{cand_str}\n"
            f"config.factorflow.main_cli was: {main_cli!r}"
        )

    import sys, subprocess
    py = sys.executable
    cmd = [py, str(main_cli_path_resolved), architecture] + [str(x) for x in args]

    ff_out_txt.parent.mkdir(parents=True, exist_ok=True)

    print(f"[FactorFlow] Running: {' '.join(cmd)}")
    out = subprocess.check_output(cmd, cwd=str(config_dir), text=True)
    ff_out_txt.write_text(out)
    print(f"[FactorFlow] Wrote: {ff_out_txt}")

def _python_executable() -> str:
    # In your container/venv context, sys.executable would also work.
    # Keeping this minimal and predictable:
    import sys
    return sys.executable


# =========================
# CLI + config I/O
# =========================

def _parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--config", required=True, help="Path to experiment config.json")
    return p.parse_args()


def _load_json(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text())


if __name__ == "__main__":
    raise SystemExit(main())