#!/bin/bash
set -euo pipefail

SEQ="top_level_seq.c"
SA="top_level_sa.c"
TB="testbench_common.c"

BAMBU_OUT_ROOT="Bambu_outputs"

# Optional first argument: N_MUL overrides -C=__float_mul=N
N_MUL_DEFAULT=""
N_MUL="${1:-$N_MUL_DEFAULT}"

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

run_bambu () {
  local tag="$1"   # seq / sa
  local top="$2"   # top_level_*.c

  local outdir="${BAMBU_OUT_ROOT}/${tag}"
  local log="${outdir}/bambu_${tag}.log"

  local float_mul_flag=""
  if [[ -n "$N_MUL" ]]; then
    float_mul_flag="-C=__float_mul=$N_MUL"
  fi

  rm -rf "${outdir}"
  mkdir -p "${outdir}"

  (
    cd "${outdir}"
    bambu "../../${top}" \
      --top-fname=top_level \
      --generate-interface=INFER \
      --compiler=I386_GCC8 \
      --clock-period=5 \
      -O3 -v4 \
      --generate-tb="../../${TB}" \
      --tb-param-size=dram_w_b0:2048 \
      --tb-param-size=dram_w_b1:2048 \
      --tb-param-size=dram_in_b0:2048 \
      --tb-param-size=dram_in_b1:2048 \
      --tb-param-size=dram_out_b0:512 \
      --tb-param-size=dram_out_b1:512 \
      --tb-param-size=dram_out_b2:512 \
      --tb-param-size=dram_out_b3:512 \
      --tb-param-size=dram_out_b4:512 \
      --tb-param-size=dram_out_b5:512 \
      --tb-param-size=dram_out_b6:512 \
      --tb-param-size=dram_out_b7:512 \
${float_mul_flag:+${float_mul_flag}} \
      --simulate
  ) > "${log}" 2>&1

  grep -E "Run 1 execution time" -m1 "${log}" | awk '{print $(NF-1)}'
}

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
echo "  $BAMBU_OUT_ROOT/seq/bambu_seq.log"
echo "  $BAMBU_OUT_ROOT/sa/bambu_sa.log"
echo "Bambu outputs:"
echo "  $BAMBU_OUT_ROOT/seq"
echo "  $BAMBU_OUT_ROOT/sa"
