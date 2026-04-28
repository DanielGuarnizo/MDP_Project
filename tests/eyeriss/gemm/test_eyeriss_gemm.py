"""
Correctness tests for eyeriss × GEMM.

For each experiment in experiments/eyeriss/gemm/ex*, runs:
    python src/main.py --config <experiment>/config.json

main.py internally:
  - Reuses cached FF_output.txt (no FactorFlow re-run if mapping already exists)
  - Generates top_level_seq.c and top_level_sa.c
  - Runs _verify_sa_structure and _cpu_golden_check (seq + sa vs golden GEMM)

A zero exit code guarantees the generated C is functionally correct.
"""

import subprocess
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).parents[3]      # tests/eyeriss/gemm/ → repo root
GENERATED = Path(__file__).parent / "generated"


def _experiments():
    if not GENERATED.exists():
        return []
    return [
        pytest.param(d, id=d.name)
        for d in sorted(GENERATED.glob("ex*"))
        if (d / "config.json").exists()
    ]


@pytest.mark.parametrize("exp_dir", _experiments())
def test_correctness(exp_dir):
    r = subprocess.run(
        [sys.executable, "src/main.py", "--config", str(exp_dir / "config.json")],
        cwd=str(REPO_ROOT),
        capture_output=True,
        text=True,
    )
    assert r.returncode == 0, (
        f"{exp_dir.name} FAILED:\nstdout:\n{r.stdout}\nstderr:\n{r.stderr}"
    )
