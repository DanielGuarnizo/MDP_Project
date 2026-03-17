#!/bin/bash
set -e

echo "Starting Bambu HLS Synthesis and Co-Simulation..."

bambu top_level.c \
    --top-fname=top_level \
    --generate-interface=INFER \
    --clock-period=3.33 \
    -O3 \
    -v4 \
    --generate-tb=testbench.c \
    --simulate \
    --compiler=I386_GCC8 \
    "$@"

echo "Bambu execution finished successfully!"
