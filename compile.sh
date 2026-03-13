#!/bin/bash
bambu generated_systolic.c \
    --top-fname=top_level \
    --pipelining=... # This needs to target the innermost loop, which is complex to name
    "$@"
