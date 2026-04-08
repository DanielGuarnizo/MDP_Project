#!/bin/bash
# run_ex6_adder_sweep.sh
# Fix N_mul=96, sweep N_add for ex6 to find adder FU bottleneck.
# Resume-safe: skips runs whose log already contains "Run 1 execution time".
#
# Usage:
#   cd /workspace
#   bash scripts/run_ex6_adder_sweep.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXP_DIR="$REPO_ROOT/experiments/eyeriss/conv/ex6"

N_MUL=96
# Sweep adders: 1 (baseline) up to 48 (2× acc elements=24)
N_ADD_SWEEP="1 2 4 8 16 24 48 96"

extract_cycles () {
  grep -m1 "Run 1 execution time" "$1" 2>/dev/null | awk '{print $(NF-1)}'
}

echo ""
echo "════════════════════════════════════════════════════════"
echo "  ex6 adder sweep  N_mul=${N_MUL}  N_add ∈ {${N_ADD_SWEEP}}"
echo "════════════════════════════════════════════════════════"

TOTAL_START=$SECONDS
declare -A RESULTS

for N_ADD in $N_ADD_SWEEP; do
  TAG="nmul${N_MUL}_nadd${N_ADD}"
  outdir="${EXP_DIR}/Bambu_outputs/sa_adder/${TAG}"
  log="${outdir}/bambu_sa_${TAG}.log"

  if [[ -f "$log" ]] && grep -q "Run 1 execution time" "$log"; then
    cycles="$(extract_cycles "$log")"
    echo "  N_add=${N_ADD}: already done → ${cycles} cycles  [skip]"
    RESULTS[$N_ADD]="$cycles"
    continue
  fi

  printf "  N_add=%-4s running ... " "$N_ADD"
  t_start=$SECONDS
  rm -rf "${outdir}"
  mkdir -p "${outdir}"
  (cd "${outdir}" && bash "${EXP_DIR}/compile_bambu.sh" \
      "${EXP_DIR}/top_level_sa.c" "$N_MUL" "$N_ADD") \
    > "${log}" 2>&1
  rc=$?
  elapsed=$(( SECONDS - t_start ))

  if [[ -f "$log" ]] && grep -q "Run 1 execution time" "$log"; then
    cycles="$(extract_cycles "$log")"
    echo "${cycles} cycles  (${elapsed}s)"
    RESULTS[$N_ADD]="$cycles"
  else
    echo "FAILED (rc=$rc, ${elapsed}s) → see $log"
    RESULTS[$N_ADD]="FAILED"
  fi
done

echo ""
echo "════════════════════════════════════════════════════════"
echo "  SUMMARY — N_mul=${N_MUL}, varying N_add"
echo "════════════════════════════════════════════════════════"
printf "  %-8s %s\n" "N_add" "cycles"
printf "  %-8s %s\n" "------" "------"
for N_ADD in $N_ADD_SWEEP; do
  printf "  %-8s %s\n" "$N_ADD" "${RESULTS[$N_ADD]:-}"
done
echo ""
echo "Total elapsed: $(( SECONDS - TOTAL_START ))s"
