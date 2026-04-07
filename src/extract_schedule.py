#!/usr/bin/env python3
"""
src/extract_schedule.py — one-shot Bambu log extractor.

Reads all canonical bambu_sa_*.log files under:
  experiments/eyeriss/conv/ex*/Bambu_outputs/sa/n[0-9]*/

Skips: Bambu_outputs_old, Bambu_outputs_new, sa_adder, sa_old variants.
Also skips N_mul > N_PE "saturation+1" experiments (n97, n73, n65, n81).

Writes src/schedule_data.json — the persistent artifact for Phase 2.

Usage:
    python src/extract_schedule.py
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).parent.parent
LOG_GLOB = "experiments/eyeriss/conv/ex*/Bambu_outputs/sa/n[0-9]*/bambu_sa_*.log"

# Saturation+1 experiments to skip (not part of standard sweep)
SKIP_NMUL = {"n97", "n73", "n65", "n81"}


def extract_log(log_path: Path) -> dict:
    text = log_path.read_text()

    # FP operation start steps — use literal "(READ_COND)" to avoid matching MULTI_READ_COND
    add_steps = sorted(set(
        int(m) for m in re.findall(
            r'__float_adde\S+\s+scheduled at control step \((\d+)-', text)
    ))
    mul_steps = sorted(set(
        int(m) for m in re.findall(
            r'__float_mule\S+\s+scheduled at control step \((\d+)-', text)
    ))

    # Memory write/read steps
    write_steps = sorted(set(
        int(m) for m in re.findall(
            r'gmem_out\d+\S+\s+scheduled at control step \((\d+)-', text)
    ))
    read_steps = sorted(set(
        int(m) for m in re.findall(
            r'gmem_(?:in|w)\d+\S+\s+scheduled at control step \((\d+)-', text)
    ))

    # Loop control steps
    # IMPORTANT: use \(READ_COND\) to avoid matching MULTI_READ_COND
    rc_steps  = [int(m) for m in re.findall(
        r'\(READ_COND\)\s+scheduled at control step \((\d+)-', text)]
    mrc_steps = [int(m) for m in re.findall(
        r'\(MULTI_READ_COND\)\s+scheduled at control step \((\d+)-', text)]
    ret_steps  = [int(m) for m in re.findall(
        r'\(gimple_return\)\s+scheduled at control step \((\d+)-', text)]
    exit_steps = [int(m) for m in re.findall(
        r'EXIT\(EXIT\)\s+scheduled at control step \((\d+)-', text)]

    exit_state = max(exit_steps) if exit_steps else None

    # Determine inner-loop check and outer-loop check steps.
    #
    # Cases:
    #   A) READ_COND + MULTI_READ_COND present (ex1-ex3, ex6):
    #      inner = min(READ_COND), outer = min(MULTI_READ_COND)
    #   B) Two MULTI_READ_CONDs, no READ_COND (ex5):
    #      inner = min(MULTI_READ_COND), outer = max(MULTI_READ_COND)
    #   C) One READ_COND only, no MULTI_READ_COND (ex4):
    #      outer = READ_COND, no inner (n_inner=1, everything in outer body)
    if rc_steps and mrc_steps:
        # Case A
        rc_step  = min(rc_steps)
        mrc_step = min(mrc_steps)
    elif not rc_steps and len(mrc_steps) == 2:
        # Case B (ex5)
        rc_step  = min(mrc_steps)
        mrc_step = max(mrc_steps)
    elif rc_steps and not mrc_steps:
        # Case C (ex4): single outer READ_COND, no inner loop
        rc_step  = None
        mrc_step = min(rc_steps)   # outer check
    else:
        rc_step  = min(rc_steps)  if rc_steps  else None
        mrc_step = min(mrc_steps) if mrc_steps else None

    # r_loop_body_states: FSM states 4 through rc_step inclusive = rc_step - 4 + 1
    r_loop_body = rc_step - 3 if rc_step is not None else None

    # post_rloop_states: from state after rc_step to mrc_step inclusive
    # For ex4 (rc_step=None): post_rloop = None; outer body = mrc_step - 3
    post_rloop = (mrc_step - rc_step) if (rc_step is not None and mrc_step is not None) else None

    # For ex4 (no inner loop): outer_body_states = mrc_step - 3
    outer_body = (mrc_step - 3) if (rc_step is None and mrc_step is not None) else None

    # Measured cycles from results.txt: (end - start) // 2
    results_path = log_path.parent / "results.txt"
    measured = None
    if results_path.exists():
        m = re.search(r'(\d+)\|(\d+),', results_path.read_text())
        if m:
            measured = (int(m.group(2)) - int(m.group(1))) // 2

    return {
        "exit_state":         exit_state,
        "total_states":       exit_state + 1 if exit_state is not None else None,
        "read_cond_step":     rc_step,
        "multi_read_step":    mrc_step,
        "return_step":        max(ret_steps) if ret_steps else None,
        "r_loop_body_states": r_loop_body,
        "post_rloop_states":  post_rloop,
        "outer_body_states":  outer_body,   # only for ex4 (no inner r-loop)
        "add_start_steps":    add_steps,
        "mul_start_steps":    mul_steps,
        "write_steps":        write_steps,
        "read_steps":         read_steps,
        "n_add_batches":      len(add_steps),
        "n_mul_batches":      len(mul_steps),
        "n_write_steps":      len(write_steps),
        "n_read_steps":       len(read_steps),
        "measured_cycles":    measured,
    }


def is_canonical(log_path: Path) -> bool:
    """Accept only Bambu_outputs/sa/nN/ — skip old/new/adder variants."""
    parts = log_path.parts
    bambu_idx = next((i for i, p in enumerate(parts) if p.startswith('Bambu_outputs')), None)
    if bambu_idx is None:
        return False
    if parts[bambu_idx] != 'Bambu_outputs':
        return False
    sa_idx = bambu_idx + 1
    if sa_idx >= len(parts) or parts[sa_idx] != 'sa':
        return False
    return True


def main():
    out = {}
    logs = sorted(ROOT.glob(LOG_GLOB))
    canonical = [l for l in logs if is_canonical(l)]
    canonical = [l for l in canonical if l.parts[l.parts.index('sa') + 1] not in SKIP_NMUL]

    total_found = len(sorted(ROOT.glob(LOG_GLOB)))
    print(f"Found {total_found} total logs, {len(canonical)} canonical (excl. sat+1).\n")

    for log in canonical:
        parts = log.parts
        ex   = parts[parts.index('conv') + 1]
        nmul = parts[parts.index('sa') + 1]
        key  = f"{ex}/{nmul}"
        try:
            data = extract_log(log)
            out[key] = data
            print(f"  {key:12s}: states={str(data['total_states']):>4}  "
                  f"rc={str(data['read_cond_step']):>4}  "
                  f"mrc={str(data['multi_read_step']):>4}  "
                  f"body={str(data['r_loop_body_states']):>4}  "
                  f"post={str(data['post_rloop_states']):>4}  "
                  f"meas={data['measured_cycles']}")
        except Exception as e:
            print(f"  {key:12s}: ERROR — {e}")
            out[key] = {"error": str(e)}

    dest = Path(__file__).parent / "schedule_data.json"
    dest.write_text(json.dumps(out, indent=2))
    print(f"\nWrote {len(out)} entries → {dest}")

    # Sanity checks against known-good values from memory
    checks = [
        ("ex1/n96", "total_states",       83),
        ("ex1/n96", "read_cond_step",     43),
        ("ex1/n96", "multi_read_step",    80),
        ("ex1/n96", "r_loop_body_states", 40),
        ("ex1/n96", "post_rloop_states",  37),
        ("ex1/n96", "measured_cycles",    2548),
        ("ex1/n64", "total_states",       94),
        ("ex1/n64", "read_cond_step",     50),
        ("ex1/n64", "multi_read_step",    91),
        ("ex1/n64", "r_loop_body_states", 47),
        ("ex1/n64", "post_rloop_states",  41),
        ("ex1/n16", "total_states",       135),
        ("ex1/n16", "read_cond_step",     78),
        ("ex1/n16", "multi_read_step",    132),
        ("ex1/n16", "r_loop_body_states", 75),
        ("ex1/n16", "post_rloop_states",  54),
        ("ex1/n4",  "total_states",       371),
        ("ex1/n4",  "read_cond_step",     204),
        ("ex1/n4",  "r_loop_body_states", 201),
    ]
    print("\nSanity checks:")
    all_ok = True
    for key, field, expected in checks:
        if key not in out:
            print(f"  ? {key}: missing"); all_ok = False; continue
        got = out[key].get(field)
        ok = "✓" if got == expected else "✗"
        if got != expected:
            all_ok = False
        print(f"  {ok} {key:12s} {field:24s}: got={str(got):>5}  expected={expected}")

    print("\n" + ("All checks passed." if all_ok else "SOME CHECKS FAILED."))


if __name__ == "__main__":
    main()
