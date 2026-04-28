"""
Phase 2: accuracy regression test for sa_model.py against Bambu_outputs_working.

Reads measured cycles from Bambu log files (no Bambu runs required — logs already exist).
Asserts all predictions within 5% of measured values for ex1-ex6.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

import pytest

SRC = Path(__file__).parents[1] / "src"
sys.path.insert(0, str(SRC))

from sa_model import parse_sa_c, predict, load_calib

REPO_ROOT  = Path(__file__).parents[1]
CONV_DIR   = REPO_ROOT / "experiments" / "eyeriss" / "conv"
CALIB_PATH = SRC / "bambu_calibration.json"
THRESHOLD  = 0.05   # 5%


def _measured_cycles(log_path: Path) -> int:
    """Extract cycle count from Bambu log: 'Run 1 execution time N cycles'."""
    text = log_path.read_text()
    m = re.search(r'Run 1 execution time\s+(\d+)', text)
    if not m:
        pytest.skip(f"No cycle count in {log_path}")
    return int(m.group(1))


def _collect_params() -> list[tuple[str, int, int]]:
    """Return (ex, N_mul, measured_cycles) for all available Bambu_outputs_working logs."""
    rows = []
    for ex_dir in sorted(CONV_DIR.glob("ex[1-6]")):
        ex = ex_dir.name
        working = ex_dir / "Bambu_outputs_working" / "sa"
        if not working.exists():
            continue
        c_file = ex_dir / "top_level_sa.c"
        if not c_file.exists():
            continue
        for n_dir in sorted(working.iterdir(), key=lambda p: int(p.name[1:])):
            if not n_dir.is_dir() or not n_dir.name.startswith("n"):
                continue
            log = n_dir / f"bambu_sa_{n_dir.name}.log"
            if not log.exists():
                continue
            n_mul = int(n_dir.name[1:])
            rows.append((ex, n_mul, log))
    return rows


_PARAMS = _collect_params()


@pytest.mark.parametrize("ex,N_mul,log_path", _PARAMS, ids=[f"{e}-n{n}" for e, n, _ in _PARAMS])
def test_accuracy(ex: str, N_mul: int, log_path: Path):
    measured = _measured_cycles(log_path)
    c_file   = CONV_DIR / ex / "top_level_sa.c"
    params   = parse_sa_c(c_file.read_text())
    calib    = load_calib(CALIB_PATH, ex)

    result  = predict(params, N_mul, calib)
    pred    = result["C_total"]
    err     = abs(pred - measured) / measured

    assert err < THRESHOLD, (
        f"{ex} N_mul={N_mul}: predicted={pred:,} measured={measured:,} "
        f"error={err:.1%} (limit {THRESHOLD:.0%})"
    )
