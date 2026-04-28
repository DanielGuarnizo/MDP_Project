#!/bin/bash
set -euo pipefail

TOP="${1:-top_level_sa.c}"
TB="testbench_common.c"
N_MUL_DEFAULT=""
N_MUL="${2:-$N_MUL_DEFAULT}"

FLOAT_MUL_FLAG=""
if [[ -n "$N_MUL" ]]; then
  FLOAT_MUL_FLAG="-C=__float_mule8m23b_127nih=$N_MUL"
fi

bambu "$TOP" \
  --top-fname=top_level \
  --generate-interface=INFER \
  --compiler=I386_GCC8 \
  --clock-period=5 \
  -O3 -v4 \
  --generate-tb="$TB" \
  --tb-param-size=dram_w_b0:32 \
  --tb-param-size=dram_w_b1:32 \
  --tb-param-size=dram_in_b0:8 \
  --tb-param-size=dram_in_b1:8 \
  --tb-param-size=dram_out_b0:4 \
  --tb-param-size=dram_out_b1:4 \
  --tb-param-size=dram_out_b2:4 \
  --tb-param-size=dram_out_b3:4 \
${FLOAT_MUL_FLAG:+$FLOAT_MUL_FLAG} \
  --simulate
