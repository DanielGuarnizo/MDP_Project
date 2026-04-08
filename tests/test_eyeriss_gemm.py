"""
Correctness tests for eyeriss × GEMM.

Each test generates C code for a given (M, K, N) shape, compiles both the
SA-shaped and sequential kernels, runs them, and asserts zero mismatches.
"""

import pytest

ARCH = "eyeriss"

SHAPES = [
    pytest.param([4, 4, 4],    id="4x4x4"),       # reference (ex1)
    pytest.param([32, 32, 32], id="32x32x32"),     # medium (ex2)
    pytest.param([8, 16, 4],   id="non_square"),   # asymmetric dims
    pytest.param([3, 5, 7],    id="odd_prime"),    # odd non-power-of-2
    pytest.param([1, 4, 4],    id="M1"),           # M=1 edge case
    pytest.param([4, 1, 4],    id="K1"),           # K=1 edge case
    pytest.param([4, 4, 1],    id="N1"),           # N=1 edge case
]


@pytest.mark.parametrize("args", SHAPES)
def test_correctness(args, experiment_runner):
    r = experiment_runner(ARCH, args)
    assert r["sa_rc"]  == 0, f"SA FAILED (M={args[0]},K={args[1]},N={args[2]}):\n{r['sa_out']}"
    assert r["seq_rc"] == 0, f"SEQ FAILED (M={args[0]},K={args[1]},N={args[2]}):\n{r['seq_out']}"
