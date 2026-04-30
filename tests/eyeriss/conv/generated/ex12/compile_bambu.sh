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
  --tb-param-size=dram_output_p0:28672 \
  --tb-param-size=dram_output_p1:28672 \
  --tb-param-size=dram_output_p2:28672 \
  --tb-param-size=dram_output_p3:28672 \
  --tb-param-size=dram_output_p4:28672 \
  --tb-param-size=dram_output_p5:28672 \
  --tb-param-size=dram_output_p6:28672 \
  --tb-param-size=dram_output_p7:28672 \
  --tb-param-size=dram_output_p8:28672 \
  --tb-param-size=dram_output_p9:28672 \
  --tb-param-size=dram_output_p10:28672 \
  --tb-param-size=dram_output_p11:28672 \
  --tb-param-size=dram_output_p12:28672 \
  --tb-param-size=dram_output_p13:28672 \
  --tb-param-size=dram_output_p14:28672 \
  --tb-param-size=dram_output_p15:28672 \
  --tb-param-size=dram_output_p16:28672 \
  --tb-param-size=dram_output_p17:28672 \
  --tb-param-size=dram_output_p18:28672 \
  --tb-param-size=dram_output_p19:28672 \
  --tb-param-size=dram_output_p20:28672 \
  --tb-param-size=dram_output_p21:28672 \
  --tb-param-size=dram_output_p22:28672 \
  --tb-param-size=dram_output_p23:28672 \
  --tb-param-size=dram_output_p24:28672 \
  --tb-param-size=dram_output_p25:28672 \
  --tb-param-size=dram_output_p26:28672 \
  --tb-param-size=dram_output_p27:28672 \
${FLOAT_MUL_FLAG:+$FLOAT_MUL_FLAG} \
  ${FLOAT_ADD_FLAG:+$FLOAT_ADD_FLAG} \
  --simulate
