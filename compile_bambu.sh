#!/bin/bash
bambu top_level.c \
  --top-fname=top_level \
  --generate-interface=INFER \
  --compiler=I386_GCC8 \
  --clock-period=5 \
  -O3 -v4 \
  --generate-tb=testbench.c \
  --tb-param-size=dram_in_b0:288 \
  --tb-param-size=dram_in_b1:288 \
  --tb-param-size=dram_w_b0:288 \
  --tb-param-size=dram_w_b1:288 \
  --tb-param-size=dram_out_b0:32 \
  --tb-param-size=dram_out_b1:32 \
  --tb-param-size=dram_out_b2:32 \
  --tb-param-size=dram_out_b3:32 \
  --tb-param-size=dram_out_b4:32 \
  --tb-param-size=dram_out_b5:32 \
  --tb-param-size=dram_out_b6:32 \
  --tb-param-size=dram_out_b7:32 \
  --simulate \
  "$@"
