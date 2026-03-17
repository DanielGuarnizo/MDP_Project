#!/bin/bash
# Bambu compilation and simulation script

bambu top_level.c \
    --top-fname=top_level \
    --generate-interface=INFER \
    --clock-period=5 \
    -O3 \
    -v4 \
    --generate-tb=testbench.c \
    --simulate \
    "$@"
