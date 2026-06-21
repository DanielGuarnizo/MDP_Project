#!/bin/bash
# compile_bm.sh — synthesize read_bm and write_bm with Bambu (synthesis only, no simulation)
# Run from /workspace inside dev_mdp_container
# Output: Bambu_outputs/read_bm/ and Bambu_outputs/write_bm/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_BASE="$SCRIPT_DIR/Bambu_outputs"

COMMON_FLAGS="
  --generate-interface=INFER
  --compiler=I386_GCC8
  --clock-period=3.0
  --device-name=xcu55c-2Lfsvh2892-VVD
  -O3 -v4
"

echo "=== Synthesizing read_bm ==="
mkdir -p "$OUT_BASE/read_bm"
(cd "$OUT_BASE/read_bm" && bambu "$SCRIPT_DIR/read_bm.c" \
  --top-fname=read_bm \
  $COMMON_FLAGS \
  2>&1 | tee bambu_read_bm.log)

if grep -q "HLS synthesis completed" "$OUT_BASE/read_bm/bambu_read_bm.log" 2>/dev/null || \
   [ -f "$OUT_BASE/read_bm/top_level.v" ]; then
  echo "  read_bm: Verilog generated OK"
  ls -lh "$OUT_BASE/read_bm/"*.v 2>/dev/null | head -5
else
  echo "  read_bm: synthesis may have failed — check $OUT_BASE/read_bm/bambu_read_bm.log"
fi

echo ""
echo "=== Synthesizing write_bm ==="
mkdir -p "$OUT_BASE/write_bm"
(cd "$OUT_BASE/write_bm" && bambu "$SCRIPT_DIR/write_bm.c" \
  --top-fname=write_bm \
  $COMMON_FLAGS \
  2>&1 | tee bambu_write_bm.log)

if grep -q "HLS synthesis completed" "$OUT_BASE/write_bm/bambu_write_bm.log" 2>/dev/null || \
   [ -f "$OUT_BASE/write_bm/top_level.v" ]; then
  echo "  write_bm: Verilog generated OK"
  ls -lh "$OUT_BASE/write_bm/"*.v 2>/dev/null | head -5
else
  echo "  write_bm: synthesis may have failed — check $OUT_BASE/write_bm/bambu_write_bm.log"
fi

echo ""
echo "=== Done. Check AXI port names: ==="
grep -h "m_axi\|dram_input\|dram_output" \
  "$OUT_BASE/read_bm/top_level.v" \
  "$OUT_BASE/write_bm/top_level.v" 2>/dev/null | \
  grep -E "input|output" | head -20
