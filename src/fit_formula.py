#!/usr/bin/env python3
"""
src/fit_formula.py — Fit the 3-parameter cycle formula.

Reads src/schedule_data.json + parses structural params from top_level_sa.c files.
Computes per-data-point features and runs numpy.linalg.lstsq.

Writes src/formula_fit.json with fitted constants and per-point residuals.

Formula (Serena's 3-parameter framework):
    C_total ≈ α_inner × inner_state_visits
             + α_post  × post_state_visits
             + α_fixed

where:
    inner_state_visits = n_outer × n_inner × r_loop_body_states
    post_state_visits  = n_outer × post_rloop_states
    α_inner, α_post    — effective cycles per FSM-state-visit in each region
    α_fixed            — constant overhead (entry, prologue, return, exit)

Usage:
    python src/fit_formula.py
"""
from __future__ import annotations

import json
import math
import re
from pathlib import Path

import numpy as np

ROOT = Path(__file__).parent.parent
DATA_PATH = Path(__file__).parent / "schedule_data.json"

# Saturation+1 experiments to skip
SKIP_NMUL = {"n97", "n73", "n65", "n81"}

# ─────────────────────────────────────────────────────────────────────────────
# Reduction tree helper
# ─────────────────────────────────────────────────────────────────────────────

def compute_red_batches(N_out: int, N_red: int, N_mul: int) -> int:
    """Total FP-add batches in the reduction tree (binary halving at each level)."""
    adds = N_red
    total = 0
    while adds > 1:
        per_level = adds // 2
        total += math.ceil(N_out * per_level / N_mul)
        adds -= per_level
    return total


# ─────────────────────────────────────────────────────────────────────────────
# Parse structural params from top_level_sa.c
# ─────────────────────────────────────────────────────────────────────────────

def parse_sa_c(c_path: Path) -> dict:
    text = c_path.read_text()

    # N_PE
    m = re.search(r'(\d+)\s+PE accumulators', text)
    N_PE = int(m.group(1)) if m else None

    # N_W (Phase 1 weight count)
    m = re.search(r'Phase 1.*?(\d+)\s+elems', text)
    N_W = int(m.group(1)) if m else None

    # N_out, N_red from reduction comment
    m = re.search(r'reduction:\s*(\d+)\s*acc.*?(\d+)\s*outputs.*?\((\d+)', text)
    N_out = int(m.group(2)) if m else None
    N_red = int(m.group(3)) if m else None

    zero_pos   = text.find('// Zero')
    phase1_pos = text.find('Phase 1', zero_pos if zero_pos != -1 else 0)
    wreg_pos   = text.find('// WRegister', zero_pos if zero_pos != -1 else 0)

    # outer_bounds: nounroll loops before "// Zero"
    outer_region = text[:zero_pos] if zero_pos != -1 else ""
    outer_bounds = [int(b) for b in re.findall(
        r'#pragma GCC nounroll\s+for\s*\([^;]+;\s*\w+\s*<\s*(\d+)', outer_region)]
    n_outer = math.prod(outer_bounds) if outer_bounds else 1

    # inner sequential loops: between "// WRegister" and "Phase 1"
    if wreg_pos != -1 and phase1_pos != -1:
        inner_region = text[wreg_pos:phase1_pos]
        inner_bounds = [int(b) for b in re.findall(
            r'#pragma GCC nounroll\s+for\s*\([^;]+;\s*\w+\s*<\s*(\d+)', inner_region)]
    else:
        inner_bounds = []

    n_inner    = math.prod(inner_bounds) if inner_bounds else 1
    n_seq_loops = len(inner_bounds)

    return {
        'N_PE': N_PE, 'N_W': N_W, 'N_out': N_out, 'N_red': N_red,
        'n_outer': n_outer, 'n_inner': n_inner, 'n_seq_loops': n_seq_loops,
        'outer_bounds': outer_bounds, 'inner_bounds': inner_bounds,
    }


def load_all_params() -> dict[str, dict]:
    params = {}
    for ex in ['ex1', 'ex2', 'ex3', 'ex4', 'ex5', 'ex6']:
        c_path = ROOT / f'experiments/eyeriss/conv/{ex}/top_level_sa.c'
        if c_path.exists():
            params[ex] = parse_sa_c(c_path)
    return params


# ─────────────────────────────────────────────────────────────────────────────
# Feature computation
# ─────────────────────────────────────────────────────────────────────────────

def compute_features(key: str, sched: dict, params: dict) -> tuple | None:
    """
    Returns (X_acc, X_body_fixed, X_post, is_ex4, C_measured, key) or None if incomplete.

    Key structural fact: r_loop_body = body_const + 7×B_acc
    where body_const is fixed per experiment (reads + phi + RC).

    X_acc        = n_outer × n_inner × B_acc        [compute acc FP batches]
    X_body_fixed = n_outer × n_inner × body_const   [non-FP body states]
    X_post       = n_outer × post_rloop_states      [reduction + writes + outer check]
    is_ex4       = 1 for ex4 (different fixed overhead), 0 for others

    For ex4 (n_inner=1, outer_body contains compute + reduction):
      outer_body = non_FP_const + 7×B_acc + 7×red_batches
      X_acc        = n_outer × (B_acc + red_batches)  [compute + reduction FP batches]
      X_body_fixed = n_outer × non_FP_const           [derived from outer_body data]
      X_post       = 0
      is_ex4       = 1
    """
    ex   = key.split('/')[0]
    nmul = int(key.split('/n')[1])
    p    = params.get(ex)
    if p is None:
        return None

    C_meas = sched.get('measured_cycles')
    if C_meas is None:
        return None

    n_outer = p['n_outer']
    n_inner = p['n_inner']
    N_PE    = p['N_PE']
    N_out   = p['N_out']
    N_red   = p['N_red']
    B_acc   = math.ceil(N_PE / nmul)

    r_body   = sched.get('r_loop_body_states')
    post     = sched.get('post_rloop_states')
    out_body = sched.get('outer_body_states')

    # body_const: r_loop_body − 7×B_acc (from structural formula)
    body_const = (r_body - 7 * B_acc) if r_body is not None else None

    if r_body is not None and post is not None:
        X_acc        = n_outer * n_inner * B_acc
        X_body_fixed = n_outer * n_inner * body_const
        X_post       = n_outer * post
        is_ex4       = 0
    elif out_body is not None:
        # ex4: n_inner=1, outer_body holds compute + reduction + non-FP overhead
        # Decompose: outer_body = non_FP_const + 7×B_acc + 7×red_batches
        rb = compute_red_batches(N_out, N_red, nmul)
        non_fp_const = out_body - 7 * B_acc - 7 * rb
        X_acc        = n_outer * (B_acc + rb)    # all FP batches (compute + reduction)
        X_body_fixed = n_outer * non_fp_const    # non-FP overhead in outer body
        X_post       = 0
        is_ex4       = 1
    else:
        return None

    return (X_acc, X_body_fixed, X_post, is_ex4, C_meas, key)


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

def main():
    sched_data = json.loads(DATA_PATH.read_text())
    all_params = load_all_params()

    # Print structural params
    print("Structural params per experiment:")
    for ex, p in sorted(all_params.items()):
        print(f"  {ex}: n_outer={p['n_outer']:4d} n_inner={p['n_inner']:5d} "
              f"N_PE={p['N_PE']:3d} N_W={p['N_W']:3d} N_out={p['N_out']:3d} "
              f"N_red={p['N_red']:3d} n_seq={p['n_seq_loops']}")
    print()

    # Collect data points
    rows   = []
    labels = []
    for key in sorted(sched_data):
        nmul = key.split('/')[1]
        if nmul in SKIP_NMUL:
            continue
        sched = sched_data[key]
        result = compute_features(key, sched, all_params)
        if result is None:
            continue
        Xa, Xb, Xp, ie4, C_meas, lbl = result
        rows.append((Xa, Xb, Xp, ie4, C_meas))
        labels.append(lbl)

    print(f"Data points: {len(rows)} across all experiments and N_mul values.\n")

    # Show feature data
    print(f"{'Key':16s}  {'X_acc':>10s}  {'X_fixed':>10s}  {'X_post':>10s}  {'is_ex4':>6s}  {'C_meas':>10s}")
    for (Xa, Xb, Xp, ie4, C_meas), lbl in zip(rows, labels):
        print(f"  {lbl:14s}  {Xa:>10,d}  {Xb:>10,d}  {Xp:>10,d}  {ie4:>6d}  {C_meas:>10,d}")
    print()

    # Build regression matrix A (N×5) and target vector b (N)
    A = np.array([[Xa, Xb, Xp, ie4, 1.0] for Xa, Xb, Xp, ie4, C_meas in rows])
    b = np.array([C_meas for Xa, Xb, Xp, ie4, C_meas in rows])

    # Least-squares fit
    coeffs, _, _, _ = np.linalg.lstsq(A, b, rcond=None)
    alpha_acc, alpha_body_fixed, alpha_post, alpha_ex4, alpha_func = coeffs

    # Compute predictions and residuals
    b_pred = A @ coeffs
    ss_res = np.sum((b - b_pred) ** 2)
    ss_tot = np.sum((b - np.mean(b)) ** 2)
    r2     = 1.0 - ss_res / ss_tot

    print("=" * 70)
    print("FITTED PARAMETERS (5-param model):")
    print(f"  α_acc        (cycles per acc FP batch, main variable) = {alpha_acc:.8f}")
    print(f"  α_body_fixed (cycles per non-FP body state visit)     = {alpha_body_fixed:.8f}")
    print(f"  α_post       (cycles per post-rloop state visit)      = {alpha_post:.8f}")
    print(f"  α_ex4        (ex4 fixed-overhead correction)          = {alpha_ex4:.4f}")
    print(f"  α_func       (fixed overhead: entry+return+exit)      = {alpha_func:.4f}")
    print(f"  R²                                                     = {r2:.10f}")
    print()
    # Physical interpretation
    L_fp_eff  = 7 * alpha_acc   # total cycles for one acc batch (7 FP pipeline states)
    print(f"  [Derived] effective L_fp per batch  = 7×α_acc = {L_fp_eff:.4f} cycles")
    print(f"  [Compare] schedule L_add = 7 states → ratio = {L_fp_eff/7:.4f}x")
    print(f"  [ex4 effective constant] = α_func + α_ex4 = {alpha_func + alpha_ex4:.4f}")
    print()

    # Per-experiment residuals
    print(f"{'Key':16s}  {'Predicted':>10s}  {'Measured':>10s}  {'Error%':>8s}")
    residuals_dict = {}
    for i, ((Xa, Xb, Xp, ie4, C_meas), lbl) in enumerate(zip(rows, labels)):
        pred = b_pred[i]
        err  = 100 * (pred - C_meas) / C_meas
        residuals_dict[lbl] = {
            'predicted': round(pred, 1),
            'measured':  C_meas,
            'error_pct': round(err, 3),
        }
        ok = "✓" if abs(err) < 10 else "✗"
        print(f"  {ok} {lbl:14s}  {pred:>10.0f}  {C_meas:>10,d}  {err:>+7.2f}%")

    n_pass = sum(1 for v in residuals_dict.values() if abs(v['error_pct']) < 10)
    print(f"\nPass (<10% error): {n_pass}/{len(residuals_dict)}")
    print()

    # Check: separate R² per experiment
    print("R² per experiment:")
    for ex in ['ex1','ex2','ex3','ex4','ex5','ex6']:
        subset = [(i, lbl) for i, lbl in enumerate(labels) if lbl.startswith(ex+'/')]
        if not subset:
            continue
        idxs = [i for i, _ in subset]
        b_sub = b[idxs]; p_sub = b_pred[idxs]
        ss_r = np.sum((b_sub - p_sub)**2)
        ss_t = np.sum((b_sub - np.mean(b_sub))**2)
        r2_ex = 1 - ss_r/ss_t if ss_t > 0 else float('nan')
        print(f"  {ex}: R²={r2_ex:.6f}")
    print()

    # Write formula_fit.json
    out = {
        "fitted": {
            "alpha_acc":        round(alpha_acc, 8),
            "alpha_body_fixed": round(alpha_body_fixed, 8),
            "alpha_post":       round(alpha_post, 8),
            "alpha_ex4":        round(alpha_ex4, 4),
            "alpha_func":       round(alpha_func, 4),
        },
        "r2": round(r2, 10),
        "n_points": len(rows),
        "formula": (
            "C ≈ alpha_acc×X_acc + alpha_body_fixed×X_body_fixed"
            " + alpha_post×X_post + alpha_ex4×is_ex4 + alpha_func\n"
            "ex1-ex3,ex5,ex6: X_acc=n_outer×n_inner×B_acc, X_bf=n_outer×n_inner×body_const, X_post=n_outer×post\n"
            "ex4: X_acc=n_outer×(B_acc+red_batches), X_bf=n_outer×non_fp_const, X_post=0, is_ex4=1\n"
            "B_acc=ceil(N_PE/N_mul), body_const=r_body_sat−7"
        ),
        "residuals": residuals_dict,
    }
    dest = Path(__file__).parent / "formula_fit.json"
    dest.write_text(json.dumps(out, indent=2))
    print(f"Wrote → {dest}")


if __name__ == "__main__":
    main()
