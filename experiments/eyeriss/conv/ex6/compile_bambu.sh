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
  --tb-param-size=dram_in_b0:384 \
  --tb-param-size=dram_in_b1:384 \
  --tb-param-size=dram_w_b0:96 \
  --tb-param-size=dram_w_b1:96 \
  --tb-param-size=dram_out_b0:24 \
  --tb-param-size=dram_out_b1:24 \
  --tb-param-size=dram_out_b2:24 \
  --tb-param-size=dram_out_b3:24 \
  --tb-param-size=dram_out_b4:24 \
  --tb-param-size=dram_out_b5:24 \
  --tb-param-size=dram_out_b6:24 \
  --tb-param-size=dram_out_b7:24 \
  --tb-param-size=dram_out_b8:24 \
  --tb-param-size=dram_out_b9:24 \
  --tb-param-size=dram_out_b10:24 \
  --tb-param-size=dram_out_b11:24 \
  --tb-param-size=dram_out_b12:24 \
  --tb-param-size=dram_out_b13:24 \
  --tb-param-size=dram_out_b14:24 \
  --tb-param-size=dram_out_b15:24 \
  --tb-param-size=dram_out_b16:24 \
  --tb-param-size=dram_out_b17:24 \
  --tb-param-size=dram_out_b18:24 \
  --tb-param-size=dram_out_b19:24 \
  --tb-param-size=dram_out_b20:24 \
  --tb-param-size=dram_out_b21:24 \
  --tb-param-size=dram_out_b22:24 \
  --tb-param-size=dram_out_b23:24 \
${FLOAT_MUL_FLAG:+$FLOAT_MUL_FLAG} \
  ${FLOAT_ADD_FLAG:+$FLOAT_ADD_FLAG} \
  --simulate
