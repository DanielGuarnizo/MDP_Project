#!/usr/bin/env bash
# performance_analysis.sh — post-run performance summary for this deploy
#
# Runs on hacc-build-01 from the deploy directory.
# Does NOT run the accelerator — reads the captured stdout of a previous run.
#
# Usage:
#   bash performance_analysis.sh <run_output.log>   # from a saved log file
#   bash performance_analysis.sh                    # reads stdin
#   ./bambu_application ... | tee run.log | bash performance_analysis.sh
#
# The run output must contain [perf] lines emitted by bambu_application.
# Vivado utilization and power reports are found automatically under this
# deploy folder (works for both old _x/ and new build/vpp/ layouts).
#
# Output: formatted summary printed to stdout + saved to perf_YYYYMMDD_HHMMSS.txt

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_NAME="$(basename "$SCRIPT_DIR")"
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
REPORT_FILE="$SCRIPT_DIR/perf_${TIMESTAMP}.txt"

# ─── read run output (file or stdin) ──────────────────────────────────────────

if [[ -n "${1:-}" ]]; then
    [[ -f "$1" ]] || { echo "ERROR: file not found: $1" >&2; exit 1; }
    RUN_OUT="$(cat "$1")"
elif [[ ! -t 0 ]]; then
    RUN_OUT="$(cat)"
else
    cat >&2 <<EOF
ERROR: No run output provided.

Usage:
  bash performance_analysis.sh <run_output.log>
  ./bambu_application ... | tee run.log | bash performance_analysis.sh
  cat run.log | bash performance_analysis.sh

The run output must contain [perf] lines from bambu_application.
EOF
    exit 1
fi

# All subsequent output goes to stdout AND the report file
exec > >(tee "$REPORT_FILE")

# ─── parse [perf] lines ───────────────────────────────────────────────────────

extract_ms() {
    # Extracts the decimal value from a [perf] line: "... :   X.XXX ms"
    echo "$1" | grep -oE '[0-9]+\.[0-9]+' | head -1
}

H2F_LINE="$(echo "$RUN_OUT"   | grep '\[perf\] CPU->FPGA'   || true)"
KERN_LINE="$(echo "$RUN_OUT"  | grep '\[perf\] Kernel exec'  || true)"
F2H_LINE="$(echo "$RUN_OUT"   | grep '\[perf\] FPGA->CPU'    || true)"
TOTAL_LINE="$(echo "$RUN_OUT" | grep '\[perf\] Total'         || true)"
CYCLE_LINE="$(echo "$RUN_OUT" | grep '\[perf\] Est\.'         || true)"

H2F_MS="$(extract_ms "$H2F_LINE")"
KERN_MS="$(extract_ms "$KERN_LINE")"
F2H_MS="$(extract_ms "$F2H_LINE")"
TOTAL_MS="$(extract_ms "$TOTAL_LINE")"
# Cycles: first integer in the Est. cycles line (before the "(@ 300 MHz)" part)
CYCLES="$(echo "$CYCLE_LINE" | grep -oE '[0-9]+' | head -1)"

[[ -z "$KERN_MS" ]] && KERN_MS="N/A (no [perf] lines found — recompile with updated harness.cpp)"

# ─── find and parse Vivado reports ────────────────────────────────────────────

# Works for both old (_x/reports/) and new (build/vpp/reports/) build layouts
UTIL_RPT="$(find "$SCRIPT_DIR" -name 'impl_1_full_util_routed.rpt' 2>/dev/null | head -1)"
PWR_RPT="$(find "$SCRIPT_DIR"  -name 'impl_1_power_routed.rpt'     2>/dev/null | head -1)"

parse_util_line() {
    # Vivado table: | Site Type | Used | Fixed | Available | Util% |
    awk -F'|' '{
        gsub(/ /, "", $3); gsub(/ /, "", $5); gsub(/ /, "", $6);
        printf "%s / %s  (%s%%)", $3, $5, $6
    }' <<< "$1"
}

if [[ -n "$UTIL_RPT" ]]; then
    UTIL_CONTENT="$(cat "$UTIL_RPT")"
    LUT_VAL="$(parse_util_line  "$(echo "$UTIL_CONTENT" | grep -E '^\| *CLB LUTs '     | head -1)")"
    FF_VAL="$(parse_util_line   "$(echo "$UTIL_CONTENT" | grep -E '^\| *CLB Registers' | head -1)")"
    BRAM_VAL="$(parse_util_line "$(echo "$UTIL_CONTENT" | grep -E '^\| *RAMB36'        | head -1)")"
    DSP_VAL="$(parse_util_line  "$(echo "$UTIL_CONTENT" | grep -E '^\| *DSPs '         | head -1)")"
    UTIL_SRC="$(basename "$UTIL_RPT")"
    [[ -z "$LUT_VAL"  ]] && LUT_VAL="(parse failed — check $UTIL_RPT)"
else
    LUT_VAL="N/A"; FF_VAL="N/A"; BRAM_VAL="N/A"; DSP_VAL="N/A"
    UTIL_SRC="impl_1_full_util_routed.rpt not found under $SCRIPT_DIR"
fi

if [[ -n "$PWR_RPT" ]]; then
    PWR_CONTENT="$(cat "$PWR_RPT")"
    TOT_PWR="$(echo "$PWR_CONTENT" | grep -i 'Total On-Chip Power' | grep -oE '[0-9]+\.[0-9]+' | head -1)"
    DYN_PWR="$(echo "$PWR_CONTENT" | grep -i 'Dynamic (W)'         | grep -oE '[0-9]+\.[0-9]+' | head -1)"
    STA_PWR="$(echo "$PWR_CONTENT" | grep -i 'Device Static'       | grep -oE '[0-9]+\.[0-9]+' | head -1)"
    [[ -z "$TOT_PWR" ]] && TOT_PWR="(see $PWR_RPT)"
    [[ -z "$DYN_PWR" ]] && DYN_PWR="(see $PWR_RPT)"
    [[ -z "$STA_PWR" ]] && STA_PWR="(see $PWR_RPT)"
    PWR_SRC="$(basename "$PWR_RPT")"
else
    TOT_PWR="N/A"; DYN_PWR="N/A"; STA_PWR="N/A"
    PWR_SRC="impl_1_power_routed.rpt not found under $SCRIPT_DIR"
fi

# ─── formatted summary ────────────────────────────────────────────────────────

cat <<SUMMARY

================================================================
  PERFORMANCE ANALYSIS — $DEPLOY_NAME
  $(date '+%Y-%m-%d %H:%M:%S')
================================================================

--- Execution Time -------------------------------------------------
  CPU->FPGA transfer  : ${H2F_MS:-N/A} ms
  Kernel execution    : ${KERN_MS} ms        <- key metric
  FPGA->CPU transfer  : ${F2H_MS:-N/A} ms
  Total (steps 4-7)   : ${TOTAL_MS:-N/A} ms

--- Estimated Clock Cycles -----------------------------------------
  Platform clock      : 300 MHz
  Kernel cycles       : ~${CYCLES:-N/A}
  Formula             : kernel_ms x 300,000

--- Resource Utilization -------------------------------------------
  CLB LUTs            : ${LUT_VAL}
  CLB Registers       : ${FF_VAL}
  RAMB36              : ${BRAM_VAL}
  DSPs                : ${DSP_VAL}
  Source              : ${UTIL_SRC}

--- Power (Vivado estimated, post-route) ---------------------------
  Total On-Chip       : ${TOT_PWR} W
  Dynamic             : ${DYN_PWR} W
  Static              : ${STA_PWR} W
  Source              : ${PWR_SRC}

================================================================
  Report saved: $REPORT_FILE
================================================================
SUMMARY
