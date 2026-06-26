#!/bin/bash
set -euo pipefail

SEQ="top_level_seq.c"
SA="top_level_sa.c"
TB="testbench_common.c"

BAMBU_OUT_ROOT="Bambu_outputs"

# Optional first argument: N_MUL overrides -C=__float_mule8m23b_127nih=N
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

  local nmul_tag="n${N_MUL:-1}"
  local outdir="${BAMBU_OUT_ROOT}/${tag}/${nmul_tag}"
  local log="${outdir}/bambu_${tag}_${nmul_tag}.log"

  local float_mul_flag=""
  if [[ -n "$N_MUL" ]]; then
    float_mul_flag="-C=__float_mule8m23b_127nih=$N_MUL"
  fi

  rm -rf "${outdir}"
  mkdir -p "${outdir}"

  (
    cd "${outdir}"
    bambu "../../../${top}" \
      --top-fname=top_level \
      --generate-interface=INFER \
      --compiler=I386_GCC8 \
      --clock-period=8 \
      --device-name=xcu55c-2Lfsvh2892-VVD \
      -O3 -v4 \
      --generate-tb="../../../${TB}" \
      --tb-param-size=dram_input_p0:53824 \
      --tb-param-size=dram_input_p1:53824 \
      --tb-param-size=dram_input_p2:53824 \
      --tb-param-size=dram_input_p3:53824 \
      --tb-param-size=dram_input_p4:53824 \
      --tb-param-size=dram_input_p5:53824 \
      --tb-param-size=dram_input_p6:53824 \
      --tb-param-size=dram_input_p7:53824 \
      --tb-param-size=dram_input_p8:53824 \
      --tb-param-size=dram_input_p9:53824 \
      --tb-param-size=dram_input_p10:53824 \
      --tb-param-size=dram_input_p11:53824 \
      --tb-param-size=dram_input_p12:53824 \
      --tb-param-size=dram_input_p13:53824 \
      --tb-param-size=dram_input_p14:53824 \
      --tb-param-size=dram_input_p15:53824 \
      --tb-param-size=dram_weight_p0:9216 \
      --tb-param-size=dram_weight_p1:9216 \
      --tb-param-size=dram_weight_p2:9216 \
      --tb-param-size=dram_weight_p3:9216 \
      --tb-param-size=dram_weight_p4:9216 \
      --tb-param-size=dram_weight_p5:9216 \
      --tb-param-size=dram_weight_p6:9216 \
      --tb-param-size=dram_weight_p7:9216 \
      --tb-param-size=dram_weight_p8:9216 \
      --tb-param-size=dram_weight_p9:9216 \
      --tb-param-size=dram_weight_p10:9216 \
      --tb-param-size=dram_weight_p11:9216 \
      --tb-param-size=dram_weight_p12:9216 \
      --tb-param-size=dram_weight_p13:9216 \
      --tb-param-size=dram_weight_p14:9216 \
      --tb-param-size=dram_weight_p15:9216 \
      --tb-param-size=dram_output_p0:25088 \
      --tb-param-size=dram_output_p1:25088 \
      --tb-param-size=dram_output_p2:25088 \
      --tb-param-size=dram_output_p3:25088 \
      --tb-param-size=dram_output_p4:25088 \
      --tb-param-size=dram_output_p5:25088 \
      --tb-param-size=dram_output_p6:25088 \
      --tb-param-size=dram_output_p7:25088 \
      --tb-param-size=dram_output_p8:25088 \
      --tb-param-size=dram_output_p9:25088 \
      --tb-param-size=dram_output_p10:25088 \
      --tb-param-size=dram_output_p11:25088 \
      --tb-param-size=dram_output_p12:25088 \
      --tb-param-size=dram_output_p13:25088 \
      --tb-param-size=dram_output_p14:25088 \
      --tb-param-size=dram_output_p15:25088 \
      --tb-param-size=dram_output_p16:25088 \
      --tb-param-size=dram_output_p17:25088 \
      --tb-param-size=dram_output_p18:25088 \
      --tb-param-size=dram_output_p19:25088 \
      --tb-param-size=dram_output_p20:25088 \
      --tb-param-size=dram_output_p21:25088 \
      --tb-param-size=dram_output_p22:25088 \
      --tb-param-size=dram_output_p23:25088 \
      --tb-param-size=dram_output_p24:25088 \
      --tb-param-size=dram_output_p25:25088 \
      --tb-param-size=dram_output_p26:25088 \
      --tb-param-size=dram_output_p27:25088 \
      --tb-param-size=dram_output_p28:25088 \
      --tb-param-size=dram_output_p29:25088 \
      --tb-param-size=dram_output_p30:25088 \
      --tb-param-size=dram_output_p31:25088 \
${float_mul_flag:+${float_mul_flag}} \
      --simulate
  ) > "${log}" 2>&1

  # Extract cycles from the log inside outdir
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
echo "  $BAMBU_OUT_ROOT/seq/n${N_MUL:-1}/bambu_seq_n${N_MUL:-1}.log"
echo "  $BAMBU_OUT_ROOT/sa/n${N_MUL:-1}/bambu_sa_n${N_MUL:-1}.log"
echo "Bambu outputs:"
echo "  $BAMBU_OUT_ROOT/seq/n${N_MUL:-1}"
echo "  $BAMBU_OUT_ROOT/sa/n${N_MUL:-1}"
