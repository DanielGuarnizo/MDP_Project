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

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

# ─── read run output (file or stdin) ──────────────────────────────────────────
# DEPLOY_DIR is derived from the log file's location so the report and all
# artifact searches (*.rpt, profile_summary.csv) always land in the right
# deploy folder — even when the script itself lives elsewhere (e.g. lib/).

if [[ -n "${1:-}" ]]; then
    [[ -f "$1" ]] || { echo "ERROR: file not found: $1" >&2; exit 1; }
    RUN_OUT="$(cat "$1")"
    DEPLOY_DIR="$(cd "$(dirname "$1")" && pwd)"
elif [[ ! -t 0 ]]; then
    RUN_OUT="$(cat)"
    DEPLOY_DIR="$(pwd)"
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

DEPLOY_NAME="$(basename "$DEPLOY_DIR")"
REPORT_FILE="$DEPLOY_DIR/perf_${TIMESTAMP}.txt"

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
EST_CYC_LINE="$(echo "$RUN_OUT" | grep '\[perf\] Est. kernel cycles' || true)"
H2F_MS="$(extract_ms "$H2F_LINE")"
KERN_MS="$(extract_ms "$KERN_LINE")"
F2H_MS="$(extract_ms "$F2H_LINE")"
TOTAL_MS="$(extract_ms "$TOTAL_LINE")"
EST_CYCLES="$(echo "$EST_CYC_LINE" | grep -oE '[0-9]+' | head -1)"

[[ -z "$KERN_MS" ]] && KERN_MS="N/A (no [perf] lines found — recompile with updated harness.cpp)"

# ─── find and parse Vivado reports ────────────────────────────────────────────

# Works for both old (_x/reports/) and new (build/vpp/reports/) build layouts
UTIL_RPT="$(find "$DEPLOY_DIR" -name 'impl_1_full_util_routed.rpt' 2>/dev/null | head -1)"
PWR_RPT="$(find "$DEPLOY_DIR"  -name 'impl_1_power_routed.rpt'     2>/dev/null | head -1)"
# Post-route phys-opt timing summary (preferred) or plain routed summary
TIMING_RPT="$(find "$DEPLOY_DIR" -name 'impl_1_hw_bb_locked_timing_summary_postroute_physopted.rpt' 2>/dev/null | head -1)"
[[ -z "$TIMING_RPT" ]] && \
    TIMING_RPT="$(find "$DEPLOY_DIR" -name 'impl_1_hw_bb_locked_timing_summary_routed.rpt' 2>/dev/null | head -1)"

parse_util_line() {
    # Vivado table: | Site Type | Used | Fixed | Unavailable | Available | Util% |
    awk -F'|' '{
        gsub(/ /, "", $3); gsub(/ /, "", $6); gsub(/ /, "", $7);
        printf "%s / %s  (%s%%)", $3, $6, $7
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
    UTIL_SRC="impl_1_full_util_routed.rpt not found under $DEPLOY_DIR"
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
    PWR_SRC="impl_1_power_routed.rpt not found under $DEPLOY_DIR"
fi

# ─── parse Vivado timing report ──────────────────────────────────────────────
# ACTUAL_FREQ_MHZ: implemented period of clk_kernel_00 from the timing report.
# Used for EST_CYCLES and summary labels. Falls back to 300 MHz (platform default)
# when no report is available. VIVADO_FREQ_MHZ (renamed to MAX_SAFE_FREQ_MHZ) is
# the frequency at which timing would be met — NOT the operating frequency.

ACTUAL_FREQ_MHZ="300.000"  # fallback
MAX_SAFE_FREQ_MHZ=""; VIVADO_PERIOD_NS=""; VIVADO_WNS_NS=""; TIMING_STATUS=""; TIMING_SRC=""
if [[ -n "$TIMING_RPT" ]]; then
    # Line 1 of clk_kernel_00: waveform + period + freq (3rd float = period in ns)
    VIVADO_PERIOD_NS="$(grep 'clk_kernel_00_unbuffered_net' "$TIMING_RPT" | head -1 \
                        | grep -oE '[0-9]+\.[0-9]+' | sed -n '3p' || true)"
    # Line 2 of clk_kernel_00: WNS table (first float, may be negative)
    VIVADO_WNS_NS="$(grep 'clk_kernel_00_unbuffered_net' "$TIMING_RPT" | sed -n '2p' \
                     | grep -oE '[-]?[0-9]+\.[0-9]+' | head -1 || true)"

    # Derive actual clock frequency from the implemented period
    if [[ -n "$VIVADO_PERIOD_NS" ]]; then
        ACTUAL_FREQ_MHZ="$(awk -v p="$VIVADO_PERIOD_NS" 'BEGIN{printf "%.3f", 1000/p}')"
    fi

    if [[ -n "$VIVADO_PERIOD_NS" && -n "$VIVADO_WNS_NS" ]]; then
        # max_safe_freq = 1000 / (period - WNS) — freq at which timing would be met
        MAX_SAFE_FREQ_MHZ="$(awk -v p="$VIVADO_PERIOD_NS" -v w="$VIVADO_WNS_NS" \
                            'BEGIN{ap=p-w; if(ap>0) printf "%.1f", 1000/ap; else print "N/A"}' 2>/dev/null || true)"
        TIMING_STATUS="$(awk -v w="$VIVADO_WNS_NS" -v f="$ACTUAL_FREQ_MHZ" \
                          'BEGIN{if(w+0>=0) print "TIMING MET"; else print "TIMING VIOLATION (design may be unreliable; FPGA clocked at " f " MHz)"}' 2>/dev/null || true)"
    fi
    TIMING_SRC="$(basename "$TIMING_RPT")"
fi

# Recalculate EST_CYCLES using actual clock period (overrides harness.cpp 300 MHz value)
if [[ -n "$KERN_MS" && "$KERN_MS" != N/A* && -n "$VIVADO_PERIOD_NS" ]]; then
    EST_CYCLES="$(awk -v ms="$KERN_MS" -v p="$VIVADO_PERIOD_NS" \
                  'BEGIN{printf "%lld", ms * 1000000 / p}')"
fi

# ─── formatted summary ────────────────────────────────────────────────────────

cat <<SUMMARY

================================================================
  PERFORMANCE ANALYSIS — $DEPLOY_NAME
  $(date '+%Y-%m-%d %H:%M:%S')
================================================================

--- Execution Time (host wall-clock) --------------------------------
  CPU->FPGA transfer  : ${H2F_MS:-N/A} ms    <- PCIe DMA + XRT sync
  Kernel execution    : ${KERN_MS} ms        <- host stopwatch (includes PCIe round-trip ~0.1-0.2 ms)
  FPGA->CPU transfer  : ${F2H_MS:-N/A} ms    <- PCIe DMA + XRT sync
  Total (steps 4-7)   : ${TOTAL_MS:-N/A} ms
  Kernel cycles (@${ACTUAL_FREQ_MHZ} MHz): ${EST_CYCLES:-N/A}  <- kern_ms / clk_period (from timing report; fallback 300 MHz)

SUMMARY

if [[ -n "$MAX_SAFE_FREQ_MHZ" ]]; then
    cat <<VIVSUMMARY
--- Timing (Vivado post-route) ---------------------------------------
  Status              : ${TIMING_STATUS:-N/A}
  Operating clock     : ${ACTUAL_FREQ_MHZ} MHz  (${VIVADO_PERIOD_NS} ns period from timing report)
  WNS                 : ${VIVADO_WNS_NS:-N/A} ns
  Max timing-met freq : ${MAX_SAFE_FREQ_MHZ} MHz   <- 1000/(period-WNS); NOT the operating freq
  Source              : ${TIMING_SRC}

VIVSUMMARY
fi


cat <<SUMMARY2
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
SUMMARY2
