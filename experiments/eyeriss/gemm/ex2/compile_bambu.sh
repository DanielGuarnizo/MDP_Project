#!/bin/bash
set -euo pipefail

TOP="${1:-top_level_sa.c}"
TB="testbench_common.c"
N_MUL_DEFAULT=""
N_MUL="${2:-$N_MUL_DEFAULT}"

FLOAT_MUL_FLAG=""
if [[ -n "$N_MUL" ]]; then
  FLOAT_MUL_FLAG="-C=__float_mul=$N_MUL"
fi

bambu "$TOP" \
  --top-fname=top_level \
  --generate-interface=INFER \
  --compiler=I386_GCC8 \
  --clock-period=5 \
  -O3 -v4 \
  --generate-tb="$TB" \
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
${FLOAT_MUL_FLAG:+$FLOAT_MUL_FLAG} \
  --simulate
