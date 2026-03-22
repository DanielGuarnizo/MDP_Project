#!/bin/bash
set -euo pipefail

SEQ=top_level_seq.c
SA=top_level_sa.c
TB=testbench_common.c

# Bambu settings (match your working compile_bambu.sh)
BAMBU_COMMON_ARGS=(
  --top-fname=top_level
  --generate-interface=INFER
  --compiler=I386_GCC8
  --clock-period=5
  -O3 -v4
  --generate-tb=$TB
  --tb-param-size=dram_in_b0:288
  --tb-param-size=dram_in_b1:288
  --tb-param-size=dram_w_b0:288
  --tb-param-size=dram_w_b1:288
  --tb-param-size=dram_out_b0:32
  --tb-param-size=dram_out_b1:32
  --tb-param-size=dram_out_b2:32
  --tb-param-size=dram_out_b3:32
  --tb-param-size=dram_out_b4:32
  --tb-param-size=dram_out_b5:32
  --tb-param-size=dram_out_b6:32
  --tb-param-size=dram_out_b7:32
  --simulate
)

make_cpu() {
  local KERNEL="$1"
  local OUT_C="$2"
  local OUT_BIN="$3"

  # IMPORTANT: force a newline between kernel and TB to avoid "}#define"
  cat "$KERNEL" > "$OUT_C"
  printf "\n\n" >> "$OUT_C"
  cat "$TB" >> "$OUT_C"

  gcc -O2 -o "$OUT_BIN" "$OUT_C" -lm
}

run_cpu() {
  local KERNEL="$1"
  local TAG="$2"

  echo
  echo "============================================================"
  echo "[CPU] correctness for $KERNEL"
  echo "============================================================"

  make_cpu "$KERNEL" "cpu_${TAG}.c" "cpu_${TAG}.out"
  ./cpu_${TAG}.out
}

run_bambu() {
  local KERNEL="$1"
  local TAG="$2"
  local LOG="bambu_${TAG}.log"

  bambu "${BAMBU_COMMON_ARGS[@]}" "$KERNEL" > "$LOG" 2>&1

  # Extract the last occurrence of the cycle line in a portable way.
  # Example line: "Run 1 execution time 23358 cycles;"
  local line
  line=$(grep -E "Run 1 execution time [0-9]+ cycles;" "$LOG" | tail -n 1 || true)
  if [ -z "$line" ]; then
    echo "ERROR: Could not find cycle count in $LOG" >&2
    exit 2
  fi

  # Pull just the number
  echo "$line" | sed -E 's/.*Run 1 execution time ([0-9]+) cycles;.*/\1/'
}

# ---- Run CPU correctness first ----
run_cpu "$SEQ" "seq"
run_cpu "$SA"  "sa"

# ---- Then run bambu cosim and extract cycles only ----
echo
echo "============================================================"
echo "[BAMBU] cycles (seq)"
echo "============================================================"
SEQ_CYC=$(run_bambu "$SEQ" "seq")
echo "seq cycles: $SEQ_CYC"

echo
echo "============================================================"
echo "[BAMBU] cycles (sa)"
echo "============================================================"
SA_CYC=$(run_bambu "$SA" "sa")
echo " sa cycles: $SA_CYC"

echo
echo "==================== SUMMARY ===================="
echo "seq cycles: $SEQ_CYC"
echo " sa cycles: $SA_CYC"
echo "================================================="
echo "Logs: bambu_seq.log, bambu_sa.log"