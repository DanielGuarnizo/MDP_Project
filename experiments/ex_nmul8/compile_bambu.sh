#!/bin/bash
set -euo pipefail

TOP="${1:-top_level_sa.c}"
TB="testbench_common.c"

bambu "$TOP" \
  --top-fname=top_level \
  --generate-interface=INFER \
  --compiler=I386_GCC8 \
  --clock-period=5 \
  -O3 -v4 \
  --generate-tb="$TB" \
  --tb-param-size=dram_in_b0:288 \
  --tb-param-size=dram_in_b1:288 \
  --tb-param-size=dram_w_b0:288 \
  --tb-param-size=dram_w_b1:288 \
  --tb-param-size=dram_out_b0:4 \
  --tb-param-size=dram_out_b1:4 \
  --tb-param-size=dram_out_b2:4 \
  --tb-param-size=dram_out_b3:4 \
  --tb-param-size=dram_out_b4:4 \
  --tb-param-size=dram_out_b5:4 \
  --tb-param-size=dram_out_b6:4 \
  --tb-param-size=dram_out_b7:4 \
  -C=__float_mul=8 \
  --simulate \
  "${@:2}"
