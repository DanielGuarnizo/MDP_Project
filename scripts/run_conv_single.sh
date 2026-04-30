#!/bin/bash
# run_conv_sweep.sh
# Sweep N_mul for CONV SA experiments ex1-ex6 using each experiment's
# compile_bambu.sh (SA only — seq is not run).
#
# Usage:
#   cd /workspace
#   bash scripts/run_conv_sweep.sh [ex1 ex2 ...]   # optional: limit to specific experiments
#
# Resume-safe: skips N_mul runs whose log already contains "Run 1 execution time".

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONV_DIR="$REPO_ROOT/tests/eyeriss/conv/generated"

# N_mul sweep per experiment (powers of 2 from 1 to U, plus U if not power of 2)
declare -A SWEEP
SWEEP[ex11]="1 2 4 8 16 32 64 128 168"   # U=96
SWEEP[ex12]="1 2 4 8 16 32 64 128 168" 

# If experiments passed as args, use those; else run all
# EXPERIMENTS=("${@:-ex1 ex2 ex3 ex4 ex5 ex6}")
# EXPERIMENTS=("${@:-ex1 ex2 ex3 ex4 ex5 ex6 ex8 ex9 ex10}")
EXPERIMENTS=("${@:-ex11 ex12}")
if [[ ${#EXPERIMENTS[@]} -eq 1 && "${EXPERIMENTS[0]}" == *" "* ]]; then
  read -ra EXPERIMENTS <<< "${EXPERIMENTS[0]}"
fi

extract_cycles () {
  local log="$1"
  grep -m1 "Run 1 execution time" "$log" 2>/dev/null | awk '{print $(NF-1)}'
}

TOTAL_START=$SECONDS
declare -A RESULTS

for EX in "${EXPERIMENTS[@]}"; do
  EXP_DIR="$CONV_DIR/$EX"

  if [[ ! -f "$EXP_DIR/compile_bambu.sh" ]]; then
    echo "[warn] $EXP_DIR/compile_bambu.sh not found — regenerate code first"
    continue
  fi

  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "  $EX  →  ${SWEEP[$EX]}"
  echo "════════════════════════════════════════════════════════"

  for N_MUL in ${SWEEP[$EX]}; do
    LOG="$EXP_DIR/Bambu_outputs/sa/n${N_MUL}/bambu_sa_n${N_MUL}.log"

    # Resume: skip if already done
    if [[ -f "$LOG" ]] && grep -q "Run 1 execution time" "$LOG"; then
      echo "    N_mul=${N_MUL}: already done → $(extract_cycles "$LOG") cycles  [skip]"
      RESULTS["${EX}:${N_MUL}"]="$(extract_cycles "$LOG")"
      continue
    fi

    printf "    N_mul=%-4s running ... " "$N_MUL"
    t_start=$SECONDS

    # SA-only: set up outdir, run compile_bambu.sh from inside it
    outdir="${EXP_DIR}/Bambu_outputs/sa/n${N_MUL}"
    rm -rf "${outdir}"
    mkdir -p "${outdir}"
    (cd "${outdir}" && bash "${EXP_DIR}/compile_bambu.sh" "${EXP_DIR}/top_level_sa.c" "$N_MUL" "$N_MUL") \
      > "${LOG}" 2>&1
    rc=$?
    elapsed=$(( SECONDS - t_start ))

    if [[ -f "$LOG" ]] && grep -q "Run 1 execution time" "$LOG"; then
      cycles="$(extract_cycles "$LOG")"
      echo "${cycles} cycles  (${elapsed}s)"
      RESULTS["${EX}:${N_MUL}"]="$cycles"
    else
      echo "FAILED (rc=$rc, ${elapsed}s) → see $LOG"
      RESULTS["${EX}:${N_MUL}"]="FAILED"
    fi
  done
done

# ── Summary ──
echo ""
echo "════════════════════════════════════════════════════════"
echo "  SUMMARY — SA cycles"
echo "════════════════════════════════════════════════════════"
printf "%-6s" "N_mul"
for EX in "${EXPERIMENTS[@]}"; do printf "  %-12s" "$EX"; done
echo ""
printf "%-6s" "------"
for EX in "${EXPERIMENTS[@]}"; do printf "  %-12s" "------------"; done
echo ""

for N_MUL in ${SWEEP[$EX]}; do
  row=""; any=0
  for EX in "${EXPERIMENTS[@]}"; do
    if [[ " ${SWEEP[$EX]} " == *" ${N_MUL} "* ]]; then
      row+="  $(printf '%-12s' "${RESULTS[${EX}:${N_MUL}]:-}")"
      any=1
    else
      row+="  $(printf '%-12s' '-')"
    fi
  done
  [[ $any -eq 1 ]] && printf "%-6s%s\n" "$N_MUL" "$row"
done

echo ""
echo "Total elapsed: $(( SECONDS - TOTAL_START ))s"
