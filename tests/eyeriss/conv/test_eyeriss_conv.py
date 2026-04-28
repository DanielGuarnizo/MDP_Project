"""
Correctness tests for eyeriss × CONV.

Each ex* folder under tests/eyeriss/conv/generated/ must contain:
  - FF_output/FF_output.txt  — the FactorFlow mapping (persistent, not regenerated)
  - config.json              — with force=false so main.py reuses FF_output.txt

To add a new test: create a new exN/ folder with those two files.
Generated C files (top_level_sa.c, top_level_seq.c, …) are written by main.py
on each run and do not need to be committed.

main.py internally runs _verify_sa_structure and _cpu_golden_check (seq + sa vs
golden CONV). A zero exit code guarantees the generated C is functionally correct.
"""

import subprocess
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).parents[3]      # tests/eyeriss/conv/ → repo root
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
