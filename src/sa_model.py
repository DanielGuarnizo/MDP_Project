#!/usr/bin/env python3
"""
Analytical cycle model for top_level_sa.c kernels.

Fitted 4-parameter formula:
  C = alpha_acc * X_acc + alpha_body_fixed * X_bf + alpha_post * X_post + alpha_func

For inner r-loop kernels (n_seq_loops >= 1):
  B_acc  = ceil(N_PE / N_mul)
  X_acc  = n_outer * n_inner * B_acc
  X_bf   = n_outer * n_inner * body_const       (body_const from calib)
  X_post = n_outer * post_rloop_states           (computed analytically)

For outer-body kernels (no inner r-loop, n_seq_loops=0):
  X_acc  = n_outer * (B_acc + red_batches)       (compute + reduction FP batches)
  X_bf   = n_outer * body_const                  (non-FP outer-body overhead)
  X_post = 0

body_const for n_seq=0 includes a zero-init correction: ceil(N_PE / P_write) states,
where P_write is the number of register writes Bambu can schedule per FSM state
(a platform constant fitted alongside the alphas). P_write=None disables this term.

Usage:
    python sa_model.py <top_level_sa.c> [--sweep] [--calib PATH] [--compare]
"""
from __future__ import annotations

import argparse
import json
import math
import re
import sys
import xml.etree.ElementTree as ET
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

    if zero_pos != -1 and phase1_pos != -1:
        inner_region = text[zero_pos:phase1_pos]
        inner_bounds = [int(b) for b in re.findall(
            r'#pragma GCC nounroll\s+for\s*\(\s*int\s+(?!sarows_|sacols_)\w[^;]+;\s*\w+\s*<\s*(\d+)',
            inner_region)]
    else:
        inner_bounds = []

    n_inner     = math.prod(inner_bounds) if inner_bounds else 1
    n_seq_loops = len(inner_bounds)

    # ---- Phase 2a metadata for analytical body_const ----
    p2a_start = text.find('Phase 2a')
    p2b_start = text.find('Phase 2b')
    p2a_text  = text[p2a_start:p2b_start] if p2a_start != -1 and p2b_start != -1 else ""

    sa_dims: dict[str, int] = {}
    for label in ('S', 'C', 'Q', 'M'):
        m2 = re.search(rf'//\s+{label}:(\d+)', p2a_text)
        if m2:
            sa_dims[label] = int(m2.group(1))

    m2 = re.search(r'int c_global\s*=[^;]+?(sarows_\d+)', p2a_text)
    c_global_var = m2.group(1) if m2 else None

    sarows0_in_col = bool(re.search(r'in_col\s*=.*\+\s*sarows_0', p2a_text))

    # ---- Port counts ----
    m_ip = re.search(r'const\s+int\s+input_ports\s*=\s*(\d+)', text)
    input_ports = int(m_ip.group(1)) if m_ip else 2   # default: 2-bank split

    P_out = len(re.findall(r'#pragma HLS interface port = dram_output_p', text))
    if P_out == 0:
        P_out = 1   # default: all writes serialized (single port)

    return {
        'N_PE': N_PE, 'N_W': N_W, 'N_out': N_out, 'N_red': N_red,
        'n_outer': n_outer, 'n_inner': n_inner, 'n_seq_loops': n_seq_loops,
        'sa_dims': sa_dims, 'c_global_var': c_global_var,
        'sarows0_in_col': sarows0_in_col,
        'input_ports': input_ports, 'P_out': P_out,
    }


# =============================================================================
# Analytical body_const derivation
# =============================================================================

def compute_body_const(params: dict, P_write: int | None = None) -> int:
    """
    Derive body_const analytically from Phase 2a structure.

    For n_seq >= 1 (inner r-loop kernels):
      body_const = reads_bottleneck + 9 + 4*(n_seq-1) + 2*(weight==input)
      where reads_bottleneck = max(weight_reads_bank0, input_reads_bank0)
      bank0_count = ceil(C_dim / input_ports)
      9 = fixed r-loop overhead (setup + mul-chain + READ_COND)
      4*(n_seq-1) = extra phi/prologue per extra sequential dimension
      2*(tie) = tied-bank sync cost

    For n_seq == 0 (outer-body kernels):
      body_const = reads_bottleneck + ceil(N_out/P_out) + ceil(N_PE/P_write) + 4 + 2*(tie)
      ceil(N_out/P_out): write states (Bambu serializes writes over P_out ports)
      ceil(N_PE/P_write): zero-init states (exposed only when n_seq=0, no inner loop to overlap)
      P_write=None → zinit_states=0 (backward compat for platforms without this constant)
    """
    n_seq = params['n_seq_loops']

    sa_dims        = params.get('sa_dims', {})
    c_global_var   = params.get('c_global_var')
    sarows0_in_col = params.get('sarows0_in_col', False)
    N_W            = params['N_W']
    N_out          = params['N_out']
    N_PE           = params['N_PE']
    input_ports    = params.get('input_ports', 2)
    P_out          = params.get('P_out', 1)

    C_dim = sa_dims.get('C', 1)
    Q_dim = sa_dims.get('Q', 1)
    S_dim = sa_dims.get('S', 0)
    M_dim = sa_dims.get('M', 1)

    bank0_count = math.ceil(C_dim / input_ports)

    if c_global_var == 'sarows_1':
        weight_bank0 = bank0_count * S_dim * M_dim
    else:
        weight_bank0 = bank0_count * (N_W // C_dim)

    in_row_base     = 1 if n_seq >= 2 else bank0_count
    in_col_distinct = (Q_dim + S_dim - 1) if sarows0_in_col else Q_dim
    input_bank0     = in_row_base * in_col_distinct

    reads_bottleneck = max(weight_bank0, input_bank0)
    tie = int(weight_bank0 == input_bank0)

    if n_seq == 0:
        N_write_states = math.ceil(N_out / P_out)
        zinit_states   = math.ceil(N_PE / P_write) if P_write is not None else 0
        return reads_bottleneck + N_write_states + zinit_states + 4 + 2 * tie
    else:
        return reads_bottleneck + 9 + 4 * max(0, n_seq - 1) + 2 * tie


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


def compute_post_rloop(N_out: int, N_red: int, N_mul: int, N_PE: int,
                       P_out: int = 1) -> int:
    """
    Analytical post_rloop_states for inner r-loop kernels.

      post_rloop = 1(entry) + 7*red_batches + n_gaps
                   + extra_write0 + (ceil(N_out/P_out)-1)(writes) + 1(outer_check)

    extra_write0 = 0 if N_mul >= N_PE (write0 parallel with last reduction state),
                   1 otherwise.
    P_out physical output ports allow ceil(N_out/P_out) write states instead of N_out.
    """
    rb    = compute_red_batches(N_out, N_red, N_mul)
    gaps  = compute_red_gaps(N_out, N_red, N_mul, N_PE)
    ew0   = 0 if N_mul >= N_PE else 1
    return 1 + 7 * rb + gaps + ew0 + (math.ceil(N_out / P_out) - 1) + 1


# =============================================================================
# Prediction
# =============================================================================

def predict(params: dict, N_mul: int, calib: dict) -> dict:
    """
    Predict total cycles using the 4-parameter formula:
      C = alpha_acc*X_acc + alpha_body_fixed*X_bf + alpha_post*X_post + alpha_func

    calib must contain: alpha_acc, alpha_body_fixed, alpha_post, alpha_func.
    Optional:
      P_write        — platform constant for zero-init correction in n_seq=0 kernels.
      alpha_outer_body — legacy additive correction for n_seq=0 (0.0 if absent).
                        Used for old single-port platforms where write states inflate X_bf.

    body_const is always derived analytically from params via compute_body_const(P_write).
    """
    alpha_acc        = calib['alpha_acc']
    alpha_bf         = calib['alpha_body_fixed']
    alpha_post       = calib['alpha_post']
    alpha_func       = calib['alpha_func']
    P_write          = calib.get('P_write')
    alpha_outer_body = calib.get('alpha_outer_body', 0.0)

    body_const = compute_body_const(params, P_write)

    n_outer       = params['n_outer']
    n_inner       = params['n_inner']
    N_PE          = params['N_PE']
    N_out         = params['N_out']
    N_red         = params['N_red']
    P_out         = params.get('P_out', 1)
    is_outer_body = params['n_seq_loops'] == 0

    B_acc = math.ceil(N_PE / N_mul)

    if is_outer_body:
        rb     = compute_red_batches(N_out, N_red, N_mul)
        X_acc  = n_outer * (B_acc + rb)
        X_bf   = n_outer * body_const
        X_post = 0
    else:
        post   = compute_post_rloop(N_out, N_red, N_mul, N_PE, P_out)
        X_acc  = n_outer * n_inner * B_acc
        X_bf   = n_outer * n_inner * body_const
        X_post = n_outer * post

    C_total = (alpha_acc * X_acc + alpha_bf * X_bf + alpha_post * X_post + alpha_func
               + alpha_outer_body * int(is_outer_body))

    return {
        'C_total': round(C_total),
        'features': {'X_acc': X_acc, 'X_bf': X_bf, 'X_post': X_post,
                     'body_const': body_const},
        'B_acc': B_acc,
    }


def predict_sweep(params: dict, calib: dict,
                  n_muls: list[int] | None = None) -> list[dict]:
    if n_muls is None:
        n_muls = [1, 2, 4, 8, 16, 24, 32, 48, 64, 96]
    return [{'N_mul': n, **predict(params, n, calib)} for n in n_muls]


# =============================================================================
# Platform / calibration helpers
# =============================================================================

def _load_config(c_path: Path) -> dict | None:
    """Search for config.json in the same dir or its parent."""
    for d in [c_path.parent, c_path.parent.parent]:
        p = d / "config.json"
        if p.exists():
            return json.loads(p.read_text())
    return None


def _platform_key(cfg: dict) -> str:
    """Derive a platform identifier string from a config dict."""
    b   = cfg.get("bambu", {})
    dev = b.get("device", {}).get("name", "default")
    return f"{b.get('compiler', 'unknown')}|{b.get('clock_period', '?')}|{dev}"


def load_calib(calib_path: Path, ex_key: str | None = None,
               platform_key: str | None = None) -> dict:
    """
    Load platform alphas + experiment measured cycles from bambu_calibration.json.

    Supports both the new 'platforms' dict format and the legacy flat 'platform' key.
    """
    raw = json.loads(calib_path.read_text())

    if "platforms" in raw:
        if platform_key is None:
            # Auto-infer platform from experiments dict when ex_key is given
            if ex_key and ex_key in raw.get('experiments', {}):
                platform_key = raw['experiments'][ex_key].get('platform')
        if platform_key is None:
            # Last resort: use the first platform (matches legacy single-platform behaviour)
            platform_key = next(iter(raw["platforms"]))
        plat_data = raw["platforms"].get(platform_key)
        if plat_data is None:
            available = ", ".join(f"'{k}'" for k in raw["platforms"])
            print(f"Error: No calibration found for platform '{platform_key}'.")
            print(f"  Available platforms: {available}")
            print(f"  To add calibration, run Bambu with varying N_mul and fit the alphas.")
            sys.exit(1)
    else:
        # Legacy flat format
        plat_data = raw.get("platform", {})

    calib = {
        'alpha_acc':        plat_data.get('alpha_acc',        7.003),
        'alpha_body_fixed': plat_data.get('alpha_body_fixed', 2.180),
        'alpha_post':       plat_data.get('alpha_post',       1.004),
        'alpha_func':       plat_data.get('alpha_func',       361.0),
        'P_write':          plat_data.get('P_write'),           # None = no zero-init correction
        'alpha_outer_body': plat_data.get('alpha_outer_body', 0.0),  # 0 = no legacy correction
        'measured_cycles':  {},
    }
    if ex_key and ex_key in raw.get('experiments', {}):
        ex = raw['experiments'][ex_key]
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


def _parse_cycles_xml(xml_path: Path) -> int:
    root = ET.parse(xml_path).getroot()
    el = root.find('CYCLES')
    if el is None:
        raise ValueError(f"No <CYCLES> element in {xml_path}")
    return int(el.get('value'))


def _load_measured_from_bambu(c_path: Path) -> dict[int, int]:
    """Read measured cycle counts from Bambu_outputs/sa/nX/bambu_results_0.xml."""
    sa_dir = c_path.parent / "Bambu_outputs" / "sa"
    if not sa_dir.is_dir():
        return {}
    measured: dict[int, int] = {}
    for d in sa_dir.iterdir():
        if d.is_dir() and d.name.startswith('n') and d.name[1:].isdigit():
            xml = d / "bambu_results_0.xml"
            if xml.exists():
                measured[int(d.name[1:])] = _parse_cycles_xml(xml)
    return measured


# =============================================================================
# CLI
# =============================================================================

def main() -> None:
    parser = argparse.ArgumentParser(description="Analytical cycle model for top_level_sa.c")
    parser.add_argument("c_file", help="Path to top_level_sa.c")
    parser.add_argument("N_mul", nargs="*", type=int,
                        help="Number of multipliers (can specify multiple)")
    parser.add_argument("--sweep", action="store_true",
                        help="Sweep N_mul = 1,2,4,8,16,32,64,N_PE")
    parser.add_argument("--calib", default=None,
                        help="Path to bambu_calibration.json (default: auto-locate)")
    parser.add_argument("--compare", action="store_true",
                        help="Compare against measured data in calibration file")
    args = parser.parse_args()

    c_path = Path(args.c_file)
    if not c_path.exists():
        raise FileNotFoundError(c_path)

    # Require config.json to determine the platform
    cfg = _load_config(c_path)
    if cfg is None:
        print(f"Error: No config.json found near '{c_path}'.")
        print("  A config.json with 'bambu.compiler', 'bambu.clock_period', and optionally")
        print("  'bambu.device.name' is required to select the correct calibration platform.")
        sys.exit(1)
    platform_key = _platform_key(cfg)

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
    calib  = load_calib(calib_path, ex_key, platform_key)
    params = parse_sa_c(c_path.read_text())

    P_write = calib.get('P_write')
    body_const_analytical = compute_body_const(params, P_write)

    print(f"\nFile    : {c_path.name}  [{ex_key or 'unknown'}]")
    print(f"Platform: {platform_key}")
    print(f"Params  : N_PE={params['N_PE']}, N_W={params['N_W']}, "
          f"N_out={params['N_out']}, N_red={params['N_red']}, "
          f"n_outer={params['n_outer']}, n_inner={params['n_inner']}, "
          f"n_seq={params['n_seq_loops']}, "
          f"input_ports={params['input_ports']}, P_out={params['P_out']}")
    p_write_str = str(P_write) if P_write is not None else "None"
    print(f"Calib   : α_acc={calib['alpha_acc']:.4f}, α_bf={calib['alpha_body_fixed']:.4f}, "
          f"α_post={calib['alpha_post']:.4f}, α_func={calib['alpha_func']:.1f}, "
          f"P_write={p_write_str}, body_const={body_const_analytical} [analytical]")

    if args.sweep or not args.N_mul:
        N_PE   = params['N_PE']
        n_muls = sorted(set([1, 2, 4, 8, 16, 32, 64, N_PE]))
        results = predict_sweep(params, calib, n_muls)

        # Prefer measured cycles from local Bambu XML files; fall back to JSON
        measured = _load_measured_from_bambu(c_path)
        if not measured:
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
                  f"X_post={feat['X_post']:,}  body_const={feat['body_const']}")

    print()


if __name__ == "__main__":
    main()
