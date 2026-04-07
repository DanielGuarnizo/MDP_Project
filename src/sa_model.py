#!/usr/bin/env python3
"""
Analytical cycle model for top_level_sa.c kernels.

Fitted 5-parameter formula (derived from lstsq over ex1-ex6 Bambu logs):
  C = alpha_acc * X_acc + alpha_body_fixed * X_bf + alpha_post * X_post
      + alpha_ex4 * is_ex4 + alpha_func

For ex1-ex3, ex5, ex6 (inner r-loop structure):
  B_acc  = ceil(N_PE / N_mul)
  X_acc  = n_outer * n_inner * B_acc
  X_bf   = n_outer * n_inner * body_const       (body_const from calib)
  X_post = n_outer * post_rloop_states           (computed analytically)

For ex4-type (no inner r-loop, n_seq_loops=0):
  X_acc  = n_outer * (B_acc + red_batches)       (compute + reduction FP batches)
  X_bf   = n_outer * body_const                  (non-FP outer-body overhead)
  X_post = 0
  is_ex4 = 1

Usage:
    python sa_model.py <top_level_sa.c> [--sweep] [--calib PATH] [--compare]
"""
from __future__ import annotations

import argparse
import json
import math
import re
from pathlib import Path


# =============================================================================
# Structural parser
# =============================================================================

def parse_sa_c(text: str) -> dict:
    """Extract structural parameters from a generated top_level_sa.c file."""
    m = re.search(r'(\d+)\s+PE accumulators', text)
    if not m:
        raise ValueError("Cannot find PE accumulators comment.")
    N_PE = int(m.group(1))

    m = re.search(r'Phase 1.*?(\d+)\s+elems', text)
    if not m:
        raise ValueError("Cannot find Phase 1 weight count.")
    N_W = int(m.group(1))

    m = re.search(r'reduction:\s*(\d+)\s*acc.*?(\d+)\s*outputs.*?\((\d+)', text)
    if not m:
        raise ValueError("Cannot find reduction summary comment.")
    N_out = int(m.group(2))
    N_red = int(m.group(3))

    zero_pos   = text.find('// Zero')
    phase1_pos = text.find('Phase 1', max(zero_pos, 0))
    wreg_pos   = text.find('// WRegister', max(zero_pos, 0))

    outer_region = text[:zero_pos] if zero_pos != -1 else ""
    outer_bounds = [int(b) for b in re.findall(
        r'#pragma GCC nounroll\s+for\s*\([^;]+;\s*\w+\s*<\s*(\d+)', outer_region)]
    n_outer = math.prod(outer_bounds) if outer_bounds else 1

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
    }


# =============================================================================
# Reduction tree helpers
# =============================================================================

def compute_red_batches(N_out: int, N_red: int, N_mul: int) -> int:
    """Total FP-add batches in the binary reduction tree."""
    adds, total = N_red, 0
    while adds > 1:
        per_level = adds // 2
        total += math.ceil(N_out * per_level / N_mul)
        adds -= per_level
    return total


def compute_red_gaps(N_out: int, N_red: int, N_mul: int, N_PE: int) -> int:
    """Empty FSM states between reduction levels (when N_mul < N_PE)."""
    if N_mul >= N_PE:
        return 0
    adds, gaps = N_red, 0
    while adds > 1:
        per_level = adds // 2
        adds -= per_level
        if adds > 1:
            next_total = N_out * (adds // 2)
            if next_total <= N_mul:
                gaps += 1
    return gaps


def compute_post_rloop(N_out: int, N_red: int, N_mul: int, N_PE: int) -> int:
    """
    Analytical post_rloop_states for ex1-ex3, ex5, ex6 kernels.

      post_rloop = 1(entry) + 7*red_batches + n_gaps
                   + extra_write0 + (N_out-1)(writes) + 1(outer_check)

    extra_write0 = 0 if N_mul >= N_PE (write0 parallel with last reduction state),
                   1 otherwise.
    """
    rb    = compute_red_batches(N_out, N_red, N_mul)
    gaps  = compute_red_gaps(N_out, N_red, N_mul, N_PE)
    ew0   = 0 if N_mul >= N_PE else 1
    return 1 + 7 * rb + gaps + ew0 + (N_out - 1) + 1


# =============================================================================
# Prediction
# =============================================================================

def predict(params: dict, N_mul: int, calib: dict) -> dict:
    """
    Predict total cycles using the fitted 5-parameter formula.

    calib must contain: alpha_acc, alpha_body_fixed, alpha_post, alpha_ex4,
                        alpha_func, body_const.
    """
    alpha_acc   = calib['alpha_acc']
    alpha_bf    = calib['alpha_body_fixed']
    alpha_post  = calib['alpha_post']
    alpha_ex4   = calib['alpha_ex4']
    alpha_func  = calib['alpha_func']
    body_const  = calib['body_const']

    n_outer = params['n_outer']
    n_inner = params['n_inner']
    N_PE    = params['N_PE']
    N_out   = params['N_out']
    N_red   = params['N_red']
    is_ex4  = 1 if params['n_seq_loops'] == 0 else 0

    B_acc = math.ceil(N_PE / N_mul)

    if is_ex4:
        rb     = compute_red_batches(N_out, N_red, N_mul)
        X_acc  = n_outer * (B_acc + rb)
        X_bf   = n_outer * body_const
        X_post = 0
    else:
        post   = compute_post_rloop(N_out, N_red, N_mul, N_PE)
        X_acc  = n_outer * n_inner * B_acc
        X_bf   = n_outer * n_inner * body_const
        X_post = n_outer * post

    C_total = (alpha_acc * X_acc + alpha_bf * X_bf +
               alpha_post * X_post + alpha_ex4 * is_ex4 + alpha_func)

    return {
        'C_total': round(C_total),
        'features': {'X_acc': X_acc, 'X_bf': X_bf, 'X_post': X_post, 'is_ex4': is_ex4},
        'B_acc': B_acc,
    }


def predict_sweep(params: dict, calib: dict,
                  n_muls: list[int] | None = None) -> list[dict]:
    if n_muls is None:
        n_muls = [1, 2, 4, 8, 16, 24, 32, 48, 64, 96]
    return [{'N_mul': n, **predict(params, n, calib)} for n in n_muls]


# =============================================================================
# Calibration loading
# =============================================================================

def load_calib(calib_path: Path, ex_key: str | None = None) -> dict:
    """
    Load platform constants + experiment body_const from bambu_calibration.json.
    ex_key: e.g. 'ex1', 'ex2', … Determines which body_const to use.
    """
    raw = json.loads(calib_path.read_text())
    plat = raw.get('platform', {})
    calib = {
        'alpha_acc':        plat.get('alpha_acc',        7.003),
        'alpha_body_fixed': plat.get('alpha_body_fixed', 2.180),
        'alpha_post':       plat.get('alpha_post',       1.004),
        'alpha_ex4':        plat.get('alpha_ex4',        -302.3),
        'alpha_func':       plat.get('alpha_func',        361.0),
        'body_const':       None,
        'measured_cycles':  {},
    }
    if ex_key and ex_key in raw.get('experiments', {}):
        ex = raw['experiments'][ex_key]
        calib['body_const'] = ex.get('body_const')
        calib['measured_cycles'] = {
            int(k): v for k, v in ex.get('measured_cycles', {}).items()
        }
    return calib


def _infer_ex_key(c_path: Path) -> str | None:
    """Extract experiment key from path, e.g. 'ex1' from '.../conv/ex1/...'."""
    for part in c_path.parts:
        if re.fullmatch(r'ex\d+', part):
            return part
    return None


# =============================================================================
# CLI
# =============================================================================

def main() -> None:
    parser = argparse.ArgumentParser(description="Analytical cycle model for top_level_sa.c")
    parser.add_argument("c_file", help="Path to top_level_sa.c")
    parser.add_argument("N_mul", nargs="*", type=int,
                        help="Number of multipliers (can specify multiple)")
    parser.add_argument("--sweep", action="store_true",
                        help="Sweep N_mul = 1,2,4,8,16,24,32,48,64,96")
    parser.add_argument("--calib", default=None,
                        help="Path to bambu_calibration.json (default: auto-locate)")
    parser.add_argument("--compare", action="store_true",
                        help="Compare against measured data in calibration file")
    args = parser.parse_args()

    c_path = Path(args.c_file)
    if not c_path.exists():
        raise FileNotFoundError(c_path)

    if args.calib:
        calib_path = Path(args.calib)
    else:
        candidates = [
            c_path.parent / "bambu_calibration.json",
            c_path.parent.parent / "bambu_calibration.json",
            Path(__file__).parent / "bambu_calibration.json",
        ]
        calib_path = next((p for p in candidates if p.exists()), None)
        if calib_path is None:
            raise FileNotFoundError("bambu_calibration.json not found; use --calib")

    ex_key = _infer_ex_key(c_path)
    calib  = load_calib(calib_path, ex_key)
    params = parse_sa_c(c_path.read_text())

    if calib['body_const'] is None:
        raise ValueError(
            f"body_const not found for '{ex_key}' in {calib_path}. "
            "Add it under experiments.<ex_key>.body_const (= r_loop_body_states "
            "at saturation minus 7)."
        )

    print(f"\nFile  : {c_path.name}  [{ex_key}]")
    print(f"Params: N_PE={params['N_PE']}, N_W={params['N_W']}, "
          f"N_out={params['N_out']}, N_red={params['N_red']}, "
          f"n_outer={params['n_outer']}, n_inner={params['n_inner']}, "
          f"n_seq={params['n_seq_loops']}")
    print(f"Calib : α_acc={calib['alpha_acc']:.4f}, α_bf={calib['alpha_body_fixed']:.4f}, "
          f"α_post={calib['alpha_post']:.4f}, α_func={calib['alpha_func']:.1f}, "
          f"body_const={calib['body_const']}")

    if args.sweep or not args.N_mul:
        N_PE   = params['N_PE']
        n_muls = sorted(set([1, 2, 4, 8, 16, 32, 64, N_PE]))
        results = predict_sweep(params, calib, n_muls)
        measured = calib['measured_cycles']

        print(f"\n{'N_mul':>6}  {'Predicted':>10}  {'Measured':>10}  {'Error%':>8}  B_acc")
        print("  " + "-" * 52)
        n_pass = 0
        for r in results:
            n    = r['N_mul']
            pred = r['C_total']
            bacc = r['B_acc']
            if n in measured and args.compare:
                meas = measured[n]
                err  = 100 * (pred - meas) / meas
                ok   = "✓" if abs(err) < 10 else "✗"
                print(f"  {ok} {n:>4d}   {pred:>10,d}  {meas:>10,d}  {err:>+7.1f}%  {bacc}")
                n_pass += (1 if abs(err) < 10 else 0)
            else:
                print(f"    {n:>4d}   {pred:>10,d}  {'—':>10}  {'—':>8}  {bacc}")

        if args.compare and measured:
            total = sum(1 for n in [r['N_mul'] for r in results] if n in measured)
            print(f"\nPass (<10% error): {n_pass}/{total}")
    else:
        for n in args.N_mul:
            r = predict(params, n, calib)
            feat = r['features']
            print(f"\n  N_mul={n}: C_total={r['C_total']:,}  B_acc={r['B_acc']}")
            print(f"    X_acc={feat['X_acc']:,}  X_bf={feat['X_bf']:,}  "
                  f"X_post={feat['X_post']:,}  is_ex4={feat['is_ex4']}")

    print()


if __name__ == "__main__":
    main()
