from __future__ import annotations

import re
from pathlib import Path
from typing import Any, Dict, Tuple


def _extract_float_mul(extra_args: list) -> Tuple[str, list]:
    """Split extra_args into (float_mul_val, other_args)."""
    pat = re.compile(r"^-C=__float_mule8m23b_127nih=(\d+)$")
    val = ""
    other = []
    for a in extra_args:
        m = pat.match(a.strip())
        if m:
            val = m.group(1)
        else:
            other.append(a)
    return val, other


def _emit_compile_bambu_sh(bambu_cfg: Dict[str, Any], tb_sizes: Dict[str, int], n_pe: int = 0) -> str:
    """
    ./compile_bambu.sh [top_file.c [N_MUL [N_ADD]]]
    Defaults to top_level_sa.c; N_MUL/N_ADD override float-op counts.
    """
    clock = bambu_cfg.get("clock_period", 5)
    compiler = bambu_cfg.get("compiler", "I386_GCC8")
    opt = bambu_cfg.get("opt_level", 3)
    v = bambu_cfg.get("v", 4)
    extra_args = bambu_cfg.get("extra_args", []) or []
    device_name = (bambu_cfg.get("device") or {}).get("name", None)

    float_mul_default, other_args = _extract_float_mul(extra_args)
    n_pe_str = str(n_pe) if n_pe else ""

    tb_flags = ""
    for name, sz in tb_sizes.items():
        tb_flags += f"  --tb-param-size={name}:{sz} \\\n"

    other_flags = ""
    for a in other_args:
        other_flags += f"  {a} \\\n"

    device_flag = f"  --device-name={device_name} \\\n" if device_name else ""

    return f"""#!/bin/bash
set -euo pipefail

TOP="${{1:-top_level_sa.c}}"
TB="$(dirname "$0")/testbench_common.c"
N_MUL_DEFAULT="{float_mul_default}"
N_MUL="${{2:-$N_MUL_DEFAULT}}"
N_ADD_DEFAULT="{n_pe_str}"
N_ADD="${{3:-$N_ADD_DEFAULT}}"

FLOAT_MUL_FLAG=""
if [[ -n "$N_MUL" ]]; then
  FLOAT_MUL_FLAG="-C=__float_mule8m23b_127nih=$N_MUL"
fi
FLOAT_ADD_FLAG=""
if [[ -n "$N_ADD" ]]; then
  FLOAT_ADD_FLAG="-C=__float_adde8m23b_127nih=$N_ADD"
fi

bambu "$TOP" \\
  --top-fname=top_level \\
  --generate-interface=INFER \\
  --compiler={compiler} \\
  --clock-period={clock} \\
{device_flag}  -O{opt} -v{v} \\
  --generate-tb="$TB" \\
{tb_flags}{other_flags}${{FLOAT_MUL_FLAG:+$FLOAT_MUL_FLAG}} \\
  ${{FLOAT_ADD_FLAG:+$FLOAT_ADD_FLAG}} \\
  --simulate
"""


def _emit_run_compare_sh(bambu_cfg: Dict[str, Any], tb_sizes: Dict[str, int]) -> str:
    """
    One-command runner:
      - CPU correctness for seq + sa
      - Bambu cosim for seq + sa
      - prints only cycle counts
      - stores all bambu-generated files under Bambu_outputs/{seq,sa}
    """
    clock    = bambu_cfg.get("clock_period", 5)
    compiler = bambu_cfg.get("compiler", "I386_GCC8")
    opt      = bambu_cfg.get("opt_level", 3)
    v        = bambu_cfg.get("v", 4)
    extra_args = bambu_cfg.get("extra_args", []) or []
    device_name = (bambu_cfg.get("device") or {}).get("name", None)

    float_mul_default, other_args = _extract_float_mul(extra_args)

    tb_flags = ""
    for name, sz in tb_sizes.items():
        tb_flags += f'      --tb-param-size={name}:{sz} \\\n'

    other_flags = ""
    for a in other_args:
        other_flags += f'      {a} \\\n'

    device_flag = f'      --device-name={device_name} \\\n' if device_name else ""

    return f"""#!/bin/bash
set -euo pipefail

SEQ="top_level_seq.c"
SA="top_level_sa.c"
TB="testbench_common.c"

BAMBU_OUT_ROOT="Bambu_outputs"

# Optional first argument: N_MUL overrides -C=__float_mule8m23b_127nih=N
N_MUL_DEFAULT="{float_mul_default}"
N_MUL="${{1:-$N_MUL_DEFAULT}}"

echo
echo "============================================================"
echo "[CPU] correctness for $SEQ"
echo "============================================================"
gcc -O2 -o cpu_seq "$SEQ" "$TB" -lm
./cpu_seq

echo
echo "============================================================"
echo "[CPU] correctness for $SA"
echo "============================================================"
gcc -O2 -o cpu_sa "$SA" "$TB" -lm
./cpu_sa

run_bambu () {{
  local tag="$1"   # seq / sa
  local top="$2"   # top_level_*.c

  local nmul_tag="n${{N_MUL:-1}}"
  local outdir="${{BAMBU_OUT_ROOT}}/${{tag}}/${{nmul_tag}}"
  local log="${{outdir}}/bambu_${{tag}}_${{nmul_tag}}.log"

  local float_mul_flag=""
  if [[ -n "$N_MUL" ]]; then
    float_mul_flag="-C=__float_mule8m23b_127nih=$N_MUL"
  fi

  rm -rf "${{outdir}}"
  mkdir -p "${{outdir}}"

  (
    cd "${{outdir}}"
    bambu "../../../${{top}}" \\
      --top-fname=top_level \\
      --generate-interface=INFER \\
      --compiler={compiler} \\
      --clock-period={clock} \\
{device_flag}      -O{opt} -v{v} \\
      --generate-tb="../../../${{TB}}" \\
{tb_flags}{other_flags}${{float_mul_flag:+${{float_mul_flag}}}} \\
      --simulate
  ) > "${{log}}" 2>&1

  # Extract cycles from the log inside outdir
  grep -E "Run 1 execution time" -m1 "${{log}}" | awk '{{print $(NF-1)}}'
}}

echo
echo "============================================================"
echo "[BAMBU] cycles (seq)"
echo "============================================================"
SEQ_CYCLES="$(run_bambu "seq" "$SEQ")"
echo "seq cycles: $SEQ_CYCLES"

echo
echo "============================================================"
echo "[BAMBU] cycles (sa)"
echo "============================================================"
SA_CYCLES="$(run_bambu "sa" "$SA")"
echo "sa cycles: $SA_CYCLES"

echo
echo "==================== SUMMARY ===================="
echo "seq cycles: $SEQ_CYCLES"
echo " sa cycles: $SA_CYCLES"
echo "================================================="
echo "Logs:"
echo "  $BAMBU_OUT_ROOT/seq/n${{N_MUL:-1}}/bambu_seq_n${{N_MUL:-1}}.log"
echo "  $BAMBU_OUT_ROOT/sa/n${{N_MUL:-1}}/bambu_sa_n${{N_MUL:-1}}.log"
echo "Bambu outputs:"
echo "  $BAMBU_OUT_ROOT/seq/n${{N_MUL:-1}}"
echo "  $BAMBU_OUT_ROOT/sa/n${{N_MUL:-1}}"
"""


def _write(path: Path, content: str, make_executable: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not content.endswith("\n"):
        content += "\n"
    path.write_text(content)
    if make_executable:
        mode = path.stat().st_mode
        path.chmod(mode | 0o111)
