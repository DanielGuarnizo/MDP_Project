"""
Correctness tests for eyeriss × CONV.

Each test generates C code for a given (M, P, Q, C, R, S) shape, compiles both
the SA-shaped and sequential kernels, runs them, and asserts zero mismatches.
"""

import pytest

ARCH = "eyeriss-conv"

SHAPES = [
    pytest.param([4, 4, 4, 4, 3, 3], id="ref_4x4x4x4_3x3"),      # reference (ex1)
    pytest.param([8, 8, 8, 4, 3, 3], id="larger_8x8x8x4_3x3"),   # larger M/P/Q
    pytest.param([4, 4, 4, 3, 3, 3], id="odd_C3"),                # odd C — potential latent bug
    pytest.param([4, 4, 4, 4, 1, 1], id="1x1_filter"),            # trivial 1×1 filter
    pytest.param([8, 8, 8, 8, 5, 5], id="5x5_filter"),            # standard 5×5
    pytest.param([4, 6, 6, 4, 3, 1], id="asymmetric_filter"),     # rectangular R≠S
]


@pytest.mark.parametrize("args", SHAPES)
def test_correctness(args, experiment_runner):
    M, P, Q, C, R, S = args
    r = experiment_runner(ARCH, args)
    assert r["sa_rc"]  == 0, f"SA FAILED (M={M},P={P},Q={Q},C={C},R={R},S={S}):\n{r['sa_out']}"
    assert r["seq_rc"] == 0, f"SEQ FAILED (M={M},P={P},Q={Q},C={C},R={R},S={S}):\n{r['seq_out']}"
