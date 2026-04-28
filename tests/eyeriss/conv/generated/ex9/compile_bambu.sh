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
  -O3 -v4 \
  --generate-tb="$TB" \
  --tb-param-size=dram_in_b0:432 \
  --tb-param-size=dram_in_b1:432 \
  --tb-param-size=dram_w_b0:576 \
  --tb-param-size=dram_w_b1:576 \
  --tb-param-size=dram_out_b0:32 \
  --tb-param-size=dram_out_b1:32 \
  --tb-param-size=dram_out_b2:32 \
  --tb-param-size=dram_out_b3:32 \
  --tb-param-size=dram_out_b4:32 \
  --tb-param-size=dram_out_b5:32 \
  --tb-param-size=dram_out_b6:32 \
  --tb-param-size=dram_out_b7:32 \
${FLOAT_MUL_FLAG:+$FLOAT_MUL_FLAG} \
  ${FLOAT_ADD_FLAG:+$FLOAT_ADD_FLAG} \
  --simulate
