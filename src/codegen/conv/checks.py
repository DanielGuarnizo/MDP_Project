from __future__ import annotations

import math
import re
import subprocess
import tempfile
from pathlib import Path
from typing import Any, Dict, Optional

from mapping_types import MappingInfo
from codegen.conv.dim_spec import SADimSpec


# =========================
# Static checks
# =========================

def _tiling_completeness_check(mapping: MappingInfo, name: str) -> str:
    """Verify product of tile factors equals total dim size for every dim.

    Returns a human-readable summary string.
    Raises ValueError if any dim's product doesn't match dims[d].
    """
    tiling = mapping.tiling
    dims   = mapping.dims
    parts  = []
    for d in sorted(dims):
        total   = int(dims[d])
        factors = [int(til[d]) for til in tiling.values() if d in til]
        prod    = math.prod(factors) if factors else 1
        if prod != total:
            raise ValueError(
                f"[tiling_check] {name}: dim {d}: tile-factor product {prod} != dims[{d!r}]={total} "
                f"(per-level factors: {factors})"
            )
        if len(factors) > 1:
            parts.append(f"{d}:{total}={'x'.join(str(f) for f in factors)}")
        else:
            parts.append(f"{d}:{total}")
    return "  ".join(parts)


def _compute_expected_mops(mapping: MappingInfo, spec: SADimSpec) -> Dict[str, Any]:
    """Derive expected MOP counts analytically from mapping dims and SA spec.

    Keys returned:
      mac      = M*P*Q*C*R*S          (total multiply-accumulate ops)
      out      = M*P*Q                 (total output writes)
      sa_q_fac = product of Q factors in SA levels
      wt_rtl   = mac // sa_q_fac       (actual weight reads in generated C)
      wt_ideal = M*C*R*S              (unique weights, no P re-reads)
      in_ideal = C*(P+R-1)*(Q+S-1)   (unique input activations)
    """
    d = mapping.dims
    M = int(d["M"]); P = int(d["P"]); Q = int(d["Q"])
    C = int(d.get("C", 1)); R = int(d.get("R", 1)); S = int(d.get("S", 1))

    mac      = M * P * Q * C * R * S
    out      = M * P * Q
    wt_ideal = M * C * R * S
    in_ideal = C * (P + R - 1) * (Q + S - 1)

    sa_q_fac = math.prod(f for dm, f, _ in spec.all_dims if dm == 'Q') or 1
    # After GlobalBuffer preload: each weight/input loaded exactly once from AXI
    wt_rtl = wt_ideal
    in_rtl = in_ideal

    return {
        'mac': mac,
        'out': out,
        'wt_rtl': wt_rtl,
        'wt_ideal': wt_ideal,
        'in_rtl': in_rtl,
        'in_ideal': in_ideal,
        'sa_q_fac': sa_q_fac,
    }


# =========================
# MOP counter injection
# =========================

def _inject_mop_counters(sa_c: str) -> str:
    """Post-process SA C string to add 4 runtime MOP counters and a printf.

    Injections:
    1. #include <stdio.h> before #define DTYPE
    2. Four static long long globals before void top_level(
    3. ++__wt_read_count before switch(weight_port_index)  [Phase 1 / gb_weight preload]
    4. ++__mac_count after accumulator[...] += product[...]  [Phase 2b]
    5. ++__out_write_count before each dram_output_p{i}[...] = ...  [writeback]
    6. ++__in_read_count before switch(input_port_index)  [Phase 2a / gb_input preload]
    7. printf("[mop_counters] ...") before the final closing }

    Callable replacements are used for all re.sub calls so that the regex
    engine never processes backslash sequences in the replacement text
    (which would corrupt C escape sequences such as the literal backslash-n
    inside the printf format string).
    """
    text = sa_c

    # 1. stdio.h
    text = text.replace('#define DTYPE float',
                        '#include <stdio.h>\n#define DTYPE float', 1)

    # 2. Global counters before void top_level(
    counters = (
        'static long long __mac_count = 0;\n'
        'static long long __wt_read_count = 0;\n'
        'static long long __out_write_count = 0;\n'
        'static long long __in_read_count = 0;\n'
    )
    text = text.replace('void top_level(', counters + 'void top_level(', 1)

    # 3. Weight read counter — before switch(weight_port_index) in Phase 1
    def _add_wt(m):
        ind = m.group(1)
        return ind + '++__wt_read_count;\n' + ind + m.group(2)

    text = re.sub(r'([ \t]+)(switch\(weight_port_index\))', _add_wt, text)

    # 4. MAC counter — after accumulator[...] += product[...];
    def _add_mac(m):
        ind = m.group(1)
        return ind + m.group(2) + '\n' + ind + '++__mac_count;'

    text = re.sub(
        r'([ \t]+)(accumulator(?:\[[^\]]*\])+ \+= product(?:\[[^\]]*\])+;)',
        _add_mac, text,
    )

    # 5. Output write counter — before each dram_output_p{i}[...] = ...;
    def _add_out(m):
        ind = m.group(1)
        return ind + '++__out_write_count;\n' + ind + m.group(2)

    text = re.sub(r'([ \t]+)(dram_output_p\d+\[)', _add_out, text)

    # 6. Input read counter — before switch(input_port_index) [Phase 2a / gb_input preload]
    def _add_in(m):
        ind = m.group(1)
        return ind + '++__in_read_count;\n' + ind + m.group(2)

    text = re.sub(r'([ \t]+)(switch\(input_port_index\))', _add_in, text)

    # 7. Printf before the final closing } — rfind avoids regex backslash issues
    # The \\n in the format string is a literal backslash-n (C escape for newline).
    printf_stmt = (
        '    printf("[mop_counters] mac=%lld out=%lld wt=%lld in=%lld\\n",'
        ' __mac_count, __out_write_count, __wt_read_count, __in_read_count);'
    )
    last_brace = text.rfind('\n}')
    if last_brace != -1:
        text = text[:last_brace] + '\n' + printf_stmt + '\n}'

    return text


# =========================
# Runtime MOP check
# =========================

def _mop_runtime_check(out_dir: Path, name: str, sa_c: str,
                        expected: Dict[str, Any]) -> None:
    """Compile instrumented SA kernel with testbench, run, verify MOP counts.

    Compares actual (mac, out, wt) counters against expected values.
    Prints PASS with P-redundancy ratio on success; raises ValueError on mismatch.
    """
    instr_c = _inject_mop_counters(sa_c)
    tb = out_dir / "testbench_common.c"

    with tempfile.TemporaryDirectory(dir=out_dir) as tmp:
        instr_src = Path(tmp) / "top_level_sa_instr.c"
        instr_exe = Path(tmp) / "cpu_sa_instr"
        instr_src.write_text(instr_c)

        r = subprocess.run(
            ["gcc", "-O0", "-o", str(instr_exe), str(instr_src), str(tb), "-lm"],
            capture_output=True, text=True,
        )
        if r.returncode != 0:
            raise RuntimeError(
                f"[mop_check] {name}: instrumented compile FAILED\n{r.stderr}"
            )

        r = subprocess.run([str(instr_exe)], capture_output=True, text=True)

        m = re.search(
            r'\[mop_counters\] mac=(\d+) out=(\d+) wt=(\d+) in=(\d+)', r.stdout
        )
        if not m:
            raise RuntimeError(
                f"[mop_check] {name}: no [mop_counters] line in output\n"
                f"stdout:\n{r.stdout}\nstderr:\n{r.stderr}"
            )

        actual_mac = int(m.group(1))
        actual_out = int(m.group(2))
        actual_wt  = int(m.group(3))
        actual_in  = int(m.group(4))

        errors = []
        if actual_mac != expected['mac']:
            errors.append(f"mac: got {actual_mac}, expected {expected['mac']}")
        if actual_out != expected['out']:
            errors.append(f"out: got {actual_out}, expected {expected['out']}")
        if actual_wt != expected['wt_rtl']:
            errors.append(
                f"wt_rtl: got {actual_wt}, expected {expected['wt_rtl']}"
            )
        if actual_in != expected['in_rtl']:
            errors.append(
                f"in_rtl: got {actual_in}, expected {expected['in_rtl']}"
            )

        if errors:
            raise ValueError(f"[mop_check] {name}: FAIL -- " + ", ".join(errors))

        wt_gap = expected['wt_rtl'] / expected['wt_ideal']
        in_gap = expected['in_rtl'] / expected['in_ideal']
        print(
            f"[mop_check] {name} sa: PASS  "
            f"(mac={actual_mac}, out={actual_out}, "
            f"wt_rtl={actual_wt} vs ideal={expected['wt_ideal']} [{wt_gap:.1f}x wt-gap], "
            f"in_rtl={actual_in} vs ideal={expected['in_ideal']} [{in_gap:.1f}x in-gap])"
        )


# =========================
# Structure check
# =========================

def _verify_sa_structure(spec: SADimSpec, sa_text: str, name: str,
                          mapping: Optional[MappingInfo] = None,
                          expected: Optional[Dict[str, Any]] = None) -> None:
    """Verify generated SA C text matches the mapping's PE structure.

    Checks:
    1. DTYPE acc line exists and bracket product == spec.N_PE
    2. DTYPE product line has same bracket shape as acc
    3. 'reduction' appears in text OR spec.N_red == 1

    Optional info printed when mapping/expected are provided.
    """
    acc_match = re.search(r'DTYPE\s+accumulator(\[\d+\])+', sa_text)
    p_match   = re.search(r'DTYPE\s+product(\[\d+\])+',   sa_text)

    if not acc_match:
        raise ValueError(
            f"[verify_sa] {name}: 'DTYPE accumulator[...]' not found in generated SA code"
        )

    acc_nums  = [int(x) for x in re.findall(r'\[(\d+)\]', acc_match.group(0))]
    code_N_PE = math.prod(acc_nums)

    if code_N_PE != spec.N_PE:
        raise ValueError(
            f"[verify_sa] {name}: accumulator shape product={code_N_PE} != mapping N_PE={spec.N_PE} "
            f"(accumulator brackets: {acc_nums}, spec.all_dims={spec.all_dims})"
        )

    if not p_match:
        raise ValueError(
            f"[verify_sa] {name}: 'DTYPE product[...]' not found in generated SA code"
        )

    p_nums = [int(x) for x in re.findall(r'\[(\d+)\]', p_match.group(0))]
    if p_nums != acc_nums:
        raise ValueError(
            f"[verify_sa] {name}: product shape {p_nums} != accumulator shape {acc_nums}"
        )

    if spec.N_red > 1 and 'reduction' not in sa_text:
        raise ValueError(
            f"[verify_sa] {name}: N_red={spec.N_red} > 1 but no 'reduction' comment in SA code"
        )

    print(f"[struct_check] {name} sa: PASS  "
          f"({spec.N_PE}-PE, N_red={spec.N_red} x N_out={spec.N_out})")

    if mapping is not None:
        tiling_summary = _tiling_completeness_check(mapping, name)
        print(f"  tiling:   {tiling_summary}")

    if expected is not None:
        wt_gap = expected['wt_rtl'] / expected['wt_ideal']
        in_gap = expected['in_rtl'] / expected['in_ideal']
        print(
            f"  expected: MACs={expected['mac']}  out={expected['out']}  "
            f"wt_rtl={expected['wt_rtl']}  wt_ideal={expected['wt_ideal']}  "
            f"in_rtl={expected['in_rtl']}  in_ideal={expected['in_ideal']}  "
            f"({wt_gap:.1f}x wt-gap  {in_gap:.1f}x in-gap)"
        )


# =========================
# CPU golden check
# =========================

def _cpu_golden_check(out_dir: Path, name: str) -> None:
    tb = out_dir / "testbench_common.c"
    for variant in ("seq", "sa"):
        src = out_dir / f"top_level_{variant}.c"
        exe = out_dir / f"cpu_{variant}"
        r = subprocess.run(
            ["gcc", "-O2", "-o", str(exe), str(src), str(tb), "-lm"],
            capture_output=True, text=True,
        )
        if r.returncode != 0:
            raise RuntimeError(
                f"[cpu_check] {name} {variant}: compile FAILED\n{r.stderr}"
            )
        r = subprocess.run([str(exe)], capture_output=True, text=True)
        ok = "SUCCESS" in r.stdout
        print(f"[cpu_check] {name} {variant}: {'PASS' if ok else 'FAIL'}")
        if not ok:
            raise RuntimeError(
                f"[cpu_check] {name} {variant}: golden mismatch\n{r.stdout}"
            )
