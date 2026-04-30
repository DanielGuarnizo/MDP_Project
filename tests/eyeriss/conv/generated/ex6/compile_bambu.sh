#!/bin/bash
set -euo pipefail

TOP="${1:-top_level_sa.c}"
TB="$(dirname "$0")/testbench_common.c"
N_MUL_DEFAULT=""
N_MUL="${2:-$N_MUL_DEFAULT}"
N_ADD_DEFAULT="96"
N_ADD="${3:-$N_ADD_DEFAULT}"

FLOAT_MUL_FLAG=""
if [[ -n "$N_MUL" ]]; then
  FLOAT_MUL_FLAG="-C=__float_mule8m23b_127nih=$N_MUL"
fi
FLOAT_ADD_FLAG=""
if [[ -n "$N_ADD" ]]; then
  FLOAT_ADD_FLAG="-C=__float_adde8m23b_127nih=$N_ADD"
fi

bambu "$TOP" \
  --top-fname=top_level \
  --generate-interface=INFER \
  --compiler=I386_GCC8 \
  --clock-period=5 \
  --device-name=xc7z020-1clg484-VVD \
  -O3 -v4 \
  --generate-tb="$TB" \
  --tb-param-size=dram_input_p0:192 \
  --tb-param-size=dram_input_p1:192 \
  --tb-param-size=dram_input_p2:192 \
  --tb-param-size=dram_input_p3:192 \
  --tb-param-size=dram_weight_p0:48 \
  --tb-param-size=dram_weight_p1:48 \
  --tb-param-size=dram_weight_p2:48 \
  --tb-param-size=dram_weight_p3:48 \
  --tb-param-size=dram_output_p0:24 \
  --tb-param-size=dram_output_p1:24 \
  --tb-param-size=dram_output_p2:24 \
  --tb-param-size=dram_output_p3:24 \
  --tb-param-size=dram_output_p4:24 \
  --tb-param-size=dram_output_p5:24 \
  --tb-param-size=dram_output_p6:24 \
  --tb-param-size=dram_output_p7:24 \
  --tb-param-size=dram_output_p8:24 \
  --tb-param-size=dram_output_p9:24 \
  --tb-param-size=dram_output_p10:24 \
  --tb-param-size=dram_output_p11:24 \
  --tb-param-size=dram_output_p12:24 \
  --tb-param-size=dram_output_p13:24 \
  --tb-param-size=dram_output_p14:24 \
  --tb-param-size=dram_output_p15:24 \
  --tb-param-size=dram_output_p16:24 \
  --tb-param-size=dram_output_p17:24 \
  --tb-param-size=dram_output_p18:24 \
  --tb-param-size=dram_output_p19:24 \
  --tb-param-size=dram_output_p20:24 \
  --tb-param-size=dram_output_p21:24 \
  --tb-param-size=dram_output_p22:24 \
  --tb-param-size=dram_output_p23:24 \
${FLOAT_MUL_FLAG:+$FLOAT_MUL_FLAG} \
  ${FLOAT_ADD_FLAG:+$FLOAT_ADD_FLAG} \
  --simulate
