"""
Phase 1 & 3: parse correctness + body_const + prediction smoke tests for sa_model.py.

Covers ex1-ex10. No Bambu runs required.
"""
from __future__ import annotations

import sys
from pathlib import Path

import pytest

SRC = Path(__file__).parents[1] / "src"
sys.path.insert(0, str(SRC))

from sa_model import parse_sa_c, compute_body_const, predict, load_calib

REPO_ROOT = Path(__file__).parents[1]
CONV_DIR  = REPO_ROOT / "experiments" / "eyeriss" / "conv"
CALIB_PATH = SRC / "bambu_calibration.json"


# ---------------------------------------------------------------------------
# Expected parse values (verified from FF_output.txt + C file inspection)
# N_PE = product of all SARows and SACols dimensions
# n_seq_loops = number of sequential (nounroll) loops inside the r-loop body
# c_global_var = which sarows_X variable carries the bank bit
# body_const = expected analytical value (None for ex4 n_seq=0)
# ---------------------------------------------------------------------------
EXPECTED = {
    "ex1":  {"N_PE": 96,  "n_seq": 1, "c_global_var": "sarows_1", "body_const": 33},
    "ex2":  {"N_PE": 96,  "n_seq": 1, "c_global_var": "sarows_1", "body_const": 23},
    "ex3":  {"N_PE": 72,  "n_seq": 1, "c_global_var": "sarows_1", "body_const": 33},
    "ex4":  {"N_PE": 64,  "n_seq": 0, "c_global_var": "sarows_0", "body_const": 30},
    "ex5":  {"N_PE": 80,  "n_seq": 2, "c_global_var": "sarows_1", "body_const": 33},
    "ex6":  {"N_PE": 96,  "n_seq": 1, "c_global_var": "sarows_0", "body_const": 21},
    "ex7":  {"N_PE": 100, "n_seq": 3, "c_global_var": "sarows_1", "body_const": 47},
    "ex8":  {"N_PE": 96,  "n_seq": 2, "c_global_var": "sarows_1", "body_const": 37},
    "ex9":  {"N_PE": 96,  "n_seq": 2, "c_global_var": "sarows_1", "body_const": 37},
    "ex10": {"N_PE": 96,  "n_seq": 2, "c_global_var": "sarows_1", "body_const": 37},
}


def _c_file(ex: str) -> Path:
    p = CONV_DIR / ex / "top_level_sa.c"
    if not p.exists():
        pytest.skip(f"{ex}/top_level_sa.c not found")
    return p


@pytest.mark.parametrize("ex", sorted(EXPECTED))
def test_parse_N_PE(ex):
    params = parse_sa_c(_c_file(ex).read_text())
    assert params["N_PE"] == EXPECTED[ex]["N_PE"], (
        f"{ex}: N_PE={params['N_PE']}, expected {EXPECTED[ex]['N_PE']}"
    )


@pytest.mark.parametrize("ex", sorted(EXPECTED))
def test_parse_n_seq(ex):
    params = parse_sa_c(_c_file(ex).read_text())
    assert params["n_seq_loops"] == EXPECTED[ex]["n_seq"], (
        f"{ex}: n_seq_loops={params['n_seq_loops']}, expected {EXPECTED[ex]['n_seq']}"
    )


@pytest.mark.parametrize("ex", sorted(EXPECTED))
def test_parse_c_global_var(ex):
    params = parse_sa_c(_c_file(ex).read_text())
    assert params["c_global_var"] == EXPECTED[ex]["c_global_var"], (
        f"{ex}: c_global_var={params['c_global_var']!r}, expected {EXPECTED[ex]['c_global_var']!r}"
    )


@pytest.mark.parametrize("ex", sorted(EXPECTED))
def test_body_const(ex):
    params = parse_sa_c(_c_file(ex).read_text())
    bc = compute_body_const(params)
    expected_bc = EXPECTED[ex]["body_const"]
    assert bc == expected_bc, (
        f"{ex}: body_const={bc}, expected {expected_bc}"
    )


# ---------------------------------------------------------------------------
# Phase 3 smoke test: predict() for ex7-ex10
# No ground truth — just check non-negative, non-increasing with N_mul.
# ---------------------------------------------------------------------------
@pytest.mark.parametrize("ex", ["ex7", "ex8", "ex9", "ex10"])
def test_predict_smoke(ex):
    c_file = _c_file(ex)
    params = parse_sa_c(c_file.read_text())
    calib  = load_calib(CALIB_PATH)

    N_PE   = params["N_PE"]
    n_muls = sorted({1, 2, 4, 8, 16, 32, N_PE})
    preds  = []
    for n in n_muls:
        r = predict(params, n, calib)
        assert r["C_total"] > 0, f"{ex} N_mul={n}: C_total={r['C_total']} ≤ 0"
        preds.append(r["C_total"])

    # must be non-increasing (more multipliers → fewer or equal cycles)
    for i in range(len(preds) - 1):
        assert preds[i] >= preds[i + 1], (
            f"{ex}: C_total not non-increasing at N_mul={n_muls[i]}→{n_muls[i+1]}: "
            f"{preds[i]} < {preds[i+1]}"
        )
