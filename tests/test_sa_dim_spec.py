"""
Phase 1 unit tests for SADimSpec and _classify_sa_dims.

Tests the dataclass properties and loop_vars/loop_var_comments methods
against the known FF mappings for ex1–ex6 (no Bambu, no code generation).
"""

import sys
from pathlib import Path

_SRC = Path(__file__).parent.parent / "src"
if str(_SRC) not in sys.path:
    sys.path.insert(0, str(_SRC))

from codegen.conv.eyeriss_generator import SADimSpec, _classify_sa_dims
from mapping_types import MappingInfo


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def make_mapping(sarows: dict, sacols: dict) -> MappingInfo:
    """Build a minimal MappingInfo with only SARows/SACols tiling set."""
    return MappingInfo(
        arch="eyeriss",
        workload="CONV",
        tiling={"SARows": sarows, "SACols": sacols},
    )


# ---------------------------------------------------------------------------
# ex1: SARows={S:3,C:4}  SACols={Q:2,M:4}  → N_PE=96
# ---------------------------------------------------------------------------

def test_ex1_classify():
    m = make_mapping({"S": 3, "C": 4}, {"Q": 2, "M": 4})
    spec = _classify_sa_dims(m)
    assert spec.all_dims == [("S", 3, "SARows"), ("C", 4, "SARows"),
                              ("Q", 2, "SACols"), ("M", 4, "SACols")]
    assert spec.N_PE == 96
    assert spec.N_red == 12   # S×C = 3×4
    assert spec.N_out == 8    # Q×M = 2×4
    assert spec.red_dims == [("S", 3, "SARows"), ("C", 4, "SARows")]
    assert spec.out_dims == [("Q", 2, "SACols"), ("M", 4, "SACols")]
    assert spec.loop_vars() == ["sarows_0", "sarows_1", "sacols_0", "sacols_1"]
    assert spec.N_PE == spec.N_red * spec.N_out


# ---------------------------------------------------------------------------
# ex2: SARows={S:3,C:4}  SACols={Q:4,M:2}  → N_PE=96
# ---------------------------------------------------------------------------

def test_ex2_classify():
    m = make_mapping({"S": 3, "C": 4}, {"Q": 4, "M": 2})
    spec = _classify_sa_dims(m)
    assert spec.N_PE == 96
    assert spec.N_red == 12
    assert spec.N_out == 8
    assert spec.loop_vars() == ["sarows_0", "sarows_1", "sacols_0", "sacols_1"]
    assert spec.N_PE == spec.N_red * spec.N_out


# ---------------------------------------------------------------------------
# ex3: SARows={S:3,C:3}  SACols={Q:2,M:4}  → N_PE=72  (non-power-of-2 N_red=9)
# ---------------------------------------------------------------------------

def test_ex3_classify():
    m = make_mapping({"S": 3, "C": 3}, {"Q": 2, "M": 4})
    spec = _classify_sa_dims(m)
    assert spec.N_PE == 72
    assert spec.N_red == 9    # 3×3 — non power-of-2
    assert spec.N_out == 8
    assert spec.loop_vars() == ["sarows_0", "sarows_1", "sacols_0", "sacols_1"]
    assert spec.N_PE == spec.N_red * spec.N_out


# ---------------------------------------------------------------------------
# ex4: SARows={C:4,M:2}  SACols={Q:4,M:2}  → N_PE=64  (M at both levels)
# ---------------------------------------------------------------------------

def test_ex4_classify():
    m = make_mapping({"C": 4, "M": 2}, {"Q": 4, "M": 2})
    spec = _classify_sa_dims(m)
    assert spec.all_dims == [("C", 4, "SARows"), ("M", 2, "SARows"),
                              ("Q", 4, "SACols"), ("M", 2, "SACols")]
    assert spec.N_PE == 64
    assert spec.N_red == 4    # C only
    assert spec.N_out == 16   # M×Q×M = 2×4×2
    assert spec.red_dims == [("C", 4, "SARows")]
    assert spec.out_dims == [("M", 2, "SARows"), ("Q", 4, "SACols"), ("M", 2, "SACols")]
    assert spec.loop_vars() == ["sarows_0", "sarows_1", "sacols_0", "sacols_1"]
    # out_loop_vars = loop_vars filtered to out_dim positions
    lvars = spec.loop_vars()
    out_loop_vars = [v for v, (d, _, __) in zip(lvars, spec.all_dims) if d in {'M', 'P', 'Q'}]
    assert out_loop_vars == ["sarows_1", "sacols_0", "sacols_1"]
    assert spec.N_PE == spec.N_red * spec.N_out


# ---------------------------------------------------------------------------
# ex5: SARows={S:5,C:2}  SACols={Q:2,M:4}  → N_PE=80  (non-power-of-2 N_red=10)
# ---------------------------------------------------------------------------

def test_ex5_classify():
    m = make_mapping({"S": 5, "C": 2}, {"Q": 2, "M": 4})
    spec = _classify_sa_dims(m)
    assert spec.all_dims == [("S", 5, "SARows"), ("C", 2, "SARows"),
                              ("Q", 2, "SACols"), ("M", 4, "SACols")]
    assert spec.N_PE == 80
    assert spec.N_red == 10   # S×C = 5×2 — non power-of-2
    assert spec.N_out == 8
    assert spec.loop_vars() == ["sarows_0", "sarows_1", "sacols_0", "sacols_1"]
    assert spec.N_PE == spec.N_red * spec.N_out


def test_ex5_loop_var_comments():
    m = make_mapping({"S": 5, "C": 2}, {"Q": 2, "M": 4})
    spec = _classify_sa_dims(m)
    comments = spec.loop_var_comments()
    assert comments == [
        "// sarows_0 \u2192 SARows_0 = S:5",
        "// sarows_1 \u2192 SARows_1 = C:2",
        "// sacols_0 \u2192 SACols_0 = Q:2",
        "// sacols_1 \u2192 SACols_1 = M:4",
    ]


# ---------------------------------------------------------------------------
# ex6: SARows={C:4,M:2}  SACols={Q:6,M:2}  → N_PE=96  (M at both levels)
# ---------------------------------------------------------------------------

def test_ex6_classify():
    m = make_mapping({"C": 4, "M": 2}, {"Q": 6, "M": 2})
    spec = _classify_sa_dims(m)
    assert spec.all_dims == [("C", 4, "SARows"), ("M", 2, "SARows"),
                              ("Q", 6, "SACols"), ("M", 2, "SACols")]
    assert spec.N_PE == 96
    assert spec.N_red == 4    # C only
    assert spec.N_out == 24   # M×Q×M = 2×6×2
    assert spec.red_dims == [("C", 4, "SARows")]
    assert spec.out_dims == [("M", 2, "SARows"), ("Q", 6, "SACols"), ("M", 2, "SACols")]
    assert spec.loop_vars() == ["sarows_0", "sarows_1", "sacols_0", "sacols_1"]
    assert spec.N_PE == spec.N_red * spec.N_out


# ---------------------------------------------------------------------------
# Invariant: N_PE == N_red * N_out for all experiments
# ---------------------------------------------------------------------------

def test_npe_invariant_all():
    cases = [
        ({"S": 3, "C": 4}, {"Q": 2, "M": 4}, 96),
        ({"S": 3, "C": 4}, {"Q": 4, "M": 2}, 96),
        ({"S": 3, "C": 3}, {"Q": 2, "M": 4}, 72),
        ({"C": 4, "M": 2}, {"Q": 4, "M": 2}, 64),
        ({"S": 5, "C": 2}, {"Q": 2, "M": 4}, 80),
        ({"C": 4, "M": 2}, {"Q": 6, "M": 2}, 96),
    ]
    for sarows, sacols, expected_npe in cases:
        spec = _classify_sa_dims(make_mapping(sarows, sacols))
        assert spec.N_PE == expected_npe, f"N_PE mismatch for SARows={sarows} SACols={sacols}"
        assert spec.N_PE == spec.N_red * spec.N_out, \
            f"N_PE != N_red*N_out for SARows={sarows} SACols={sacols}"
