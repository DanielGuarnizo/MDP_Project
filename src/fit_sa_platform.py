#!/usr/bin/env python3
"""
src/fit_sa_platform.py — Fit alpha parameters for a Bambu platform.

Reads Bambu simulation results from one or more Bambu_outputs/sa directories,
computes feature vectors with the sa_model analytical formulas, and runs
least-squares regression to find platform-specific alpha coefficients.

P_write (register writes per FSM state) is found via grid search over
{None, 1, 2, 4, 8, 16, 32}. It corrects the zero-init cost exposed in
n_seq=0 (outer-body) kernels. At least one n_seq=0 experiment is required
to identify P_write; otherwise it defaults to None (no correction).

Two input modes:

  Mode 1 — from Bambu XML files (default):
    python src/fit_sa_platform.py <bambu_sa_dir> [<bambu_sa_dir> ...]

    # Single experiment:
    python src/fit_sa_platform.py tests/eyeriss/conv/generated/ex1/Bambu_outputs/sa

    # Multiple experiments:
    python src/fit_sa_platform.py tests/eyeriss/conv/generated/ex{1,4}/Bambu_outputs/sa

  Mode 2 — from JSON stored measured_cycles (--from-json):
    python src/fit_sa_platform.py --from-json <exp_dir> [<exp_dir> ...]

    # Re-fit default platform from JSON data:
    python src/fit_sa_platform.py --from-json experiments/eyeriss/conv/ex{1,2,3,4,5,6}

Options:
    --from-json    Read measured cycles from bambu_calibration.json instead of XML files
    --calib PATH   Path to bambu_calibration.json (default: auto-locate)
    --update       Write fitted parameters into bambu_calibration.json
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

import numpy as np

# Import analytical helpers from sa_model (same package directory)
sys.path.insert(0, str(Path(__file__).parent))
from sa_model import (
    parse_sa_c,
    compute_body_const,
    compute_red_batches,
    compute_post_rloop,
    _parse_cycles_xml,
    _load_config,
    _platform_key,
    _infer_ex_key,
)


# =============================================================================
# Data collection — from XML files
# =============================================================================

def collect_data_points(bambu_sa_dir: Path) -> list[dict]:
    """
    Scan all nX/ subdirs of bambu_sa_dir for bambu_results_0.xml.
    Returns list of {'N_mul': int, 'cycles': int, 'dir': Path}.
    """
    points = []
    for d in sorted(bambu_sa_dir.iterdir(), key=lambda p: int(p.name[1:])
                    if p.is_dir() and p.name[1:].isdigit() else 0):
        if not d.is_dir() or not (d.name.startswith('n') and d.name[1:].isdigit()):
            continue
        xml = d / 'bambu_results_0.xml'
        if not xml.exists():
            continue
        n_mul  = int(d.name[1:])
        cycles = _parse_cycles_xml(xml)
        points.append({'N_mul': n_mul, 'cycles': cycles, 'dir': d})
    return points


# =============================================================================
# Feature computation
# =============================================================================

def compute_features(params: dict, N_mul: int,
                     P_write: int | None) -> tuple[float, float, float]:
    """
    Return (X_acc, X_bf, X_post) for the 4-parameter model [X_acc, X_bf, X_post, 1].
    body_const is recomputed with the given P_write candidate.
    """
    n_outer       = params['n_outer']
    n_inner       = params['n_inner']
    N_PE          = params['N_PE']
    N_out         = params['N_out']
    N_red         = params['N_red']
    P_out         = params.get('P_out', 1)
    is_outer_body = params['n_seq_loops'] == 0

    body_const = compute_body_const(params, P_write)
    B_acc      = math.ceil(N_PE / N_mul)

    if is_outer_body:
        rb     = compute_red_batches(N_out, N_red, N_mul)
        X_acc  = float(n_outer * (B_acc + rb))
        X_bf   = float(n_outer * body_const)
        X_post = 0.0
    else:
        post   = compute_post_rloop(N_out, N_red, N_mul, N_PE, P_out)
        X_acc  = float(n_outer * n_inner * B_acc)
        X_bf   = float(n_outer * n_inner * body_const)
        X_post = float(n_outer * post)

    return X_acc, X_bf, X_post


# =============================================================================
# Grid search
# =============================================================================

def _fit_with_pwrite(
    all_data: list[tuple[dict, int, float]],
    P_write_candidate: int | None,
) -> tuple[np.ndarray, float, int]:
    """
    Build 4-column feature matrix [X_acc, X_bf, X_post, 1] using P_write_candidate,
    run lstsq, return (coeffs, r2, rank).
    """
    rows, targets = [], []
    for (params, N_mul, cycles) in all_data:
        Xa, Xb, Xp = compute_features(params, N_mul, P_write_candidate)
        rows.append((Xa, Xb, Xp, 1.0))
        targets.append(cycles)

    A = np.array(rows, dtype=float)
    b = np.array(targets, dtype=float)
    coeffs, _, rank, _ = np.linalg.lstsq(A, b, rcond=None)

    b_pred = A @ coeffs
    ss_res = float(np.sum((b - b_pred) ** 2))
    ss_tot = float(np.sum((b - np.mean(b)) ** 2))
    r2 = 1.0 - ss_res / ss_tot if ss_tot > 0 else float('nan')
    return coeffs, r2, rank


# =============================================================================
# Main
# =============================================================================

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fit sa_model alpha parameters from Bambu simulation results."
    )
    parser.add_argument("dirs", nargs="+",
                        help="Bambu_outputs/sa directories (default) or experiment "
                             "directories when --from-json is used")
    parser.add_argument("--from-json", action="store_true",
                        help="Read measured cycles from bambu_calibration.json "
                             "(dirs are experiment directories, not Bambu XML dirs)")
    parser.add_argument("--calib", default=None,
                        help="Path to bambu_calibration.json (default: auto-locate)")
    parser.add_argument("--update", action="store_true",
                        help="Write fitted parameters into bambu_calibration.json")
    args = parser.parse_args()

    # ── Locate calibration file ──────────────────────────────────────────────
    if args.calib:
        calib_path = Path(args.calib)
    else:
        candidates = [Path(__file__).parent / "bambu_calibration.json"]
        calib_path = next((p for p in candidates if p.exists()), None)
        if calib_path is None:
            print("Error: bambu_calibration.json not found; use --calib.")
            sys.exit(1)

    calib_raw = json.loads(calib_path.read_text())

    # ── Collect data ──────────────────────────────────────────────────────────
    platform_key_seen: str | None = None
    all_data: list[tuple[dict, int, float]] = []  # (params, N_mul, cycles)
    labels:  list[str]   = []
    source_summary: list[str] = []
    has_outer_body = False

    if args.from_json:
        # Mode 2: experiment dirs + JSON measured_cycles
        experiments_in_json = calib_raw.get('experiments', {})

        for dir_str in args.dirs:
            exp_dir = Path(dir_str).resolve()
            c_file  = exp_dir / "top_level_sa.c"
            if not c_file.exists():
                print(f"Warning: top_level_sa.c not found in '{exp_dir}' — skipping.")
                continue

            cfg = _load_config(c_file)
            if cfg is None:
                print(f"Warning: no config.json found near '{c_file}' — skipping.")
                continue

            pkey   = _platform_key(cfg)
            ex_key = _infer_ex_key(c_file) or exp_dir.name

            if platform_key_seen is None:
                platform_key_seen = pkey
            elif pkey != platform_key_seen:
                print(f"Error: mixed platforms — '{pkey}' vs '{platform_key_seen}'.")
                sys.exit(1)

            if ex_key not in experiments_in_json:
                print(f"Warning: '{ex_key}' not found in calibration JSON — skipping.")
                continue

            measured = experiments_in_json[ex_key].get('measured_cycles', {})
            if not measured:
                print(f"Warning: no measured_cycles for '{ex_key}' in JSON — skipping.")
                continue

            params = parse_sa_c(c_file.read_text())
            points = [(int(k), v) for k, v in measured.items()]

            if params['n_seq_loops'] == 0:
                has_outer_body = True

            for n_mul, cycles in points:
                all_data.append((params, n_mul, float(cycles)))
                labels.append(f"{ex_key}/n{n_mul}")

            nmuls_str = ",".join(str(k) for k, _ in points)
            source_summary.append(
                f"  {ex_key} [{exp_dir}]: {len(points)} points  "
                f"(n_seq={params['n_seq_loops']}, N_mul: {nmuls_str})"
            )
    else:
        # Mode 1: Bambu_outputs/sa directories
        for sa_dir_str in args.dirs:
            bambu_sa_dir = Path(sa_dir_str).resolve()
            if not bambu_sa_dir.is_dir():
                print(f"Warning: '{bambu_sa_dir}' is not a directory — skipping.")
                continue

            # Experiment dir is two levels up: .../Bambu_outputs/sa → experiment
            exp_dir = bambu_sa_dir.parent.parent
            c_file  = exp_dir / "top_level_sa.c"
            if not c_file.exists():
                print(f"Warning: top_level_sa.c not found in '{exp_dir}' — skipping.")
                continue

            cfg = _load_config(c_file)
            if cfg is None:
                print(f"Warning: no config.json found near '{c_file}' — skipping.")
                continue

            pkey   = _platform_key(cfg)
            ex_key = _infer_ex_key(c_file) or exp_dir.name

            if platform_key_seen is None:
                platform_key_seen = pkey
            elif pkey != platform_key_seen:
                print(f"Error: mixed platforms — '{pkey}' vs '{platform_key_seen}'.")
                print("  All dirs must belong to the same platform.")
                sys.exit(1)

            params = parse_sa_c(c_file.read_text())
            points = collect_data_points(bambu_sa_dir)

            if not points:
                print(f"Warning: no results found in '{bambu_sa_dir}' — skipping.")
                continue

            if params['n_seq_loops'] == 0:
                has_outer_body = True

            for pt in points:
                all_data.append((params, pt['N_mul'], float(pt['cycles'])))
                labels.append(f"{ex_key}/n{pt['N_mul']}")

            nmuls_str = ",".join(str(p['N_mul']) for p in points)
            source_summary.append(
                f"  {ex_key} [{exp_dir}]: {len(points)} points  "
                f"(n_seq={params['n_seq_loops']}, N_mul: {nmuls_str})"
            )

    if not all_data:
        print("Error: no data points collected.")
        sys.exit(1)

    if platform_key_seen is None:
        print("Error: could not determine platform key.")
        sys.exit(1)

    # ── Grid search for P_write ──────────────────────────────────────────────
    candidates: list[int | None] = [None, 1, 2, 4, 8, 16, 32]
    best_r2, best_P_write, best_coeffs, best_rank = -float('inf'), None, None, 0

    for pw in candidates:
        coeffs, r2, rank = _fit_with_pwrite(all_data, pw)
        if r2 > best_r2:
            best_r2, best_P_write, best_coeffs, best_rank = r2, pw, coeffs, rank

    alpha_acc, alpha_bf, alpha_post, alpha_func = best_coeffs

    # Recompute predictions for reporting
    rows, targets = [], []
    for (params, N_mul, cycles) in all_data:
        Xa, Xb, Xp = compute_features(params, N_mul, best_P_write)
        rows.append((Xa, Xb, Xp, 1.0))
        targets.append(cycles)
    A = np.array(rows, dtype=float)
    b = np.array(targets, dtype=float)
    b_pred = A @ best_coeffs

    if not has_outer_body:
        print("\nNote: no n_seq=0 (outer-body) data provided.")
        print("  P_write cannot be identified — set to None (no zero-init correction).")
        print("  Include an outer-body experiment (e.g. ex4) to identify P_write.")

    # ── Report ───────────────────────────────────────────────────────────────
    mode_str = "JSON" if args.from_json else "XML"
    n_exp = len(args.dirs)
    print(f"\nFitting platform : {platform_key_seen}  [{mode_str} mode]")
    print(f"Sources ({n_exp} director{'y' if n_exp == 1 else 'ies'}, "
          f"{len(all_data)} data points):")
    for s in source_summary:
        print(s)

    print(f"\n{'Label':>16s}  {'X_acc':>10s}  {'X_bf':>10s}  {'X_post':>10s}  "
          f"{'Measured':>10s}")
    for (Xa, Xb, Xp, _), cy, lbl in zip(rows, targets, labels):
        print(f"  {lbl:>14s}  {Xa:>10.0f}  {Xb:>10.0f}  {Xp:>10.0f}  {int(cy):>10,d}")

    print()
    print("=" * 65)
    print("FITTED PARAMETERS")
    print("=" * 65)
    print(f"  alpha_acc        = {alpha_acc:.8f}")
    print(f"  alpha_body_fixed = {alpha_bf:.8f}")
    print(f"  alpha_post       = {alpha_post:.8f}")
    print(f"  alpha_func       = {alpha_func:.4f}")
    print(f"  P_write          = {best_P_write}")
    print(f"  R²               = {best_r2:.10f}")
    print(f"  rank             = {best_rank} / 4  (matrix rank)")

    if has_outer_body:
        print(f"\n  P_write grid search results:")
        for pw in candidates:
            _, r2, _ = _fit_with_pwrite(all_data, pw)
            marker = " ← best" if pw == best_P_write else ""
            print(f"    P_write={str(pw):>4s}  R²={r2:.8f}{marker}")

    print()
    print(f"{'Label':>16s}  {'Predicted':>10s}  {'Measured':>10s}  {'Error%':>8s}")
    n_pass = 0
    for i, (cy, lbl) in enumerate(zip(targets, labels)):
        pred = b_pred[i]
        err  = 100.0 * (pred - cy) / cy
        ok   = "✓" if abs(err) < 10 else "✗"
        print(f"  {ok} {lbl:>14s}  {pred:>10.0f}  {int(cy):>10,d}  {err:>+7.2f}%")
        n_pass += 1 if abs(err) < 10 else 0
    print(f"\nPass (<10% error): {n_pass}/{len(all_data)}")

    # ── Optionally write to bambu_calibration.json ───────────────────────────
    fitted: dict = {
        "note": f"fitted via lstsq+P_write grid search over {len(all_data)} data points "
                f"({mode_str} mode) from: "
                + ", ".join(s.strip().split()[0] for s in source_summary),
        "alpha_acc":        round(float(alpha_acc), 8),
        "alpha_body_fixed": round(float(alpha_bf),  8),
        "alpha_post":       round(float(alpha_post), 8),
        "alpha_func":       round(float(alpha_func), 4),
        "r2":               round(best_r2, 10),
    }
    if best_P_write is not None:
        fitted["P_write"] = best_P_write

    if args.update:
        if "platforms" not in calib_raw:
            calib_raw["platforms"] = {}
        calib_raw["platforms"][platform_key_seen] = fitted
        calib_path.write_text(json.dumps(calib_raw, indent=2) + "\n")
        print(f"\nWrote platform '{platform_key_seen}' → {calib_path}")
    else:
        print("\nTo add these parameters to bambu_calibration.json, re-run with --update.")
        print(f"  Platform key: '{platform_key_seen}'")
        print("  Entry to add:")
        block = json.dumps({platform_key_seen: fitted}, indent=2)
        for line in block.splitlines():
            print("    " + line)


if __name__ == "__main__":
    main()
