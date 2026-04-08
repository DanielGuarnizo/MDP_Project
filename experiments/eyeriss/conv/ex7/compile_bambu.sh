#!/bin/bash
set -euo pipefail

TOP="${1:-top_level_sa.c}"
TB="$(dirname "$0")/testbench_common.c"
N_MUL_DEFAULT=""
N_MUL="${2:-$N_MUL_DEFAULT}"
N_ADD_DEFAULT="100"
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
  --tb-param-size=dram_in_b0:2645000 \
  --tb-param-size=dram_in_b1:2645000 \
  --tb-param-size=dram_w_b0:5120000 \
  --tb-param-size=dram_w_b1:5120000 \
  --tb-param-size=dram_out_b0:400000 \
  --tb-param-size=dram_out_b1:400000 \
  --tb-param-size=dram_out_b2:400000 \
  --tb-param-size=dram_out_b3:400000 \
  --tb-param-size=dram_out_b4:400000 \
  --tb-param-size=dram_out_b5:400000 \
  --tb-param-size=dram_out_b6:400000 \
  --tb-param-size=dram_out_b7:400000 \
  --tb-param-size=dram_out_b8:400000 \
  --tb-param-size=dram_out_b9:400000 \
${FLOAT_MUL_FLAG:+$FLOAT_MUL_FLAG} \
  ${FLOAT_ADD_FLAG:+$FLOAT_ADD_FLAG} \
  --simulate
