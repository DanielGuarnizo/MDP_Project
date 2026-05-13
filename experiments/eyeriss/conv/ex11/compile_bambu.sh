#!/bin/bash
set -euo pipefail

TOP="${1:-top_level_sa.c}"
TB="$(dirname "$0")/testbench_common.c"
N_MUL_DEFAULT=""
N_MUL="${2:-$N_MUL_DEFAULT}"
N_ADD_DEFAULT="168"
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
  --device-name=xcu55c-2Lfsvh2892-VVD \
  -O3 -v4 \
  --generate-tb="$TB" \
  --tb-param-size=dram_input_p0:430592 \
  --tb-param-size=dram_input_p1:430592 \
  --tb-param-size=dram_weight_p0:73728 \
  --tb-param-size=dram_weight_p1:73728 \
  --tb-param-size=dram_output_p0:57344 \
  --tb-param-size=dram_output_p1:57344 \
  --tb-param-size=dram_output_p2:57344 \
  --tb-param-size=dram_output_p3:57344 \
  --tb-param-size=dram_output_p4:57344 \
  --tb-param-size=dram_output_p5:57344 \
  --tb-param-size=dram_output_p6:57344 \
  --tb-param-size=dram_output_p7:57344 \
  --tb-param-size=dram_output_p8:57344 \
  --tb-param-size=dram_output_p9:57344 \
  --tb-param-size=dram_output_p10:57344 \
  --tb-param-size=dram_output_p11:57344 \
  --tb-param-size=dram_output_p12:57344 \
  --tb-param-size=dram_output_p13:57344 \
  --tb-param-size=dram_output_p14:57344 \
  --tb-param-size=dram_output_p15:57344 \
${FLOAT_MUL_FLAG:+$FLOAT_MUL_FLAG} \
  ${FLOAT_ADD_FLAG:+$FLOAT_ADD_FLAG} \
  --simulate
