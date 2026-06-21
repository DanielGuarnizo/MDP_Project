#!/usr/bin/env bash
# run_bm_on_alveo.sh — deploy and run read_bm + write_bm on alveo
# Usage: bash run_bm_on_alveo.sh <alveo_host>
# Example: bash HACC/microbenchmarks/run_bm_on_alveo.sh hacc-alveo-u55c-01
set -euo pipefail

ALVEO="${1:-hacc-alveo-u55c-01}"
BUILD_NODE="hacc-build-01"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HACC_DIR="$(dirname "$SCRIPT_DIR")"
REMOTE_BASE="~/workspace/run/bm"
XRT_LIB="/opt/xilinx/xrt/lib"

echo "=== Microbenchmark run: build=$BUILD_NODE  alveo=$ALVEO ==="

for KN in read_bm_krnl write_bm_krnl; do
    DEPLOY="${KN%_krnl}_deploy"
    REMOTE_RUN="$REMOTE_BASE/$KN"
    LOCAL_OUT="$HACC_DIR/${DEPLOY/bm_deploy/bm_result}/$KN"

    echo ""
    echo "--- $KN ---"

    # Check xclbin exists on build node
    XCLBIN="~/workspace/deploy/$DEPLOY/xo/$KN.xclbin"
    if ! ssh "$BUILD_NODE" "test -f $XCLBIN"; then
        echo "ERROR: $XCLBIN not found on $BUILD_NODE"
        exit 1
    fi

    # Setup run dir on alveo
    ssh "$ALVEO" "mkdir -p $REMOTE_RUN"

    # Copy xclbin: build-01 → local tmp → alveo
    TMP_XCLBIN="/tmp/${KN}.xclbin"
    scp "${BUILD_NODE}:${XCLBIN}" "$TMP_XCLBIN"
    scp "$TMP_XCLBIN" "${ALVEO}:${REMOTE_RUN}/${KN}.xclbin"
    rm -f "$TMP_XCLBIN"

    # Copy host binary: build-01 → local tmp → alveo
    TMP_HOST="/tmp/bm_host_${KN}"
    scp "${BUILD_NODE}:~/workspace/deploy/${DEPLOY}/bm_host" "$TMP_HOST"
    scp "$TMP_HOST" "${ALVEO}:${REMOTE_RUN}/bm_host"
    ssh "$ALVEO" "chmod +x ${REMOTE_RUN}/bm_host"
    rm -f "$TMP_HOST"

    # Copy xrt.ini
    scp "${HACC_DIR}/${DEPLOY}/xrt.ini" "${ALVEO}:${REMOTE_RUN}/xrt.ini" 2>/dev/null || true

    # Run
    echo "[run] $KN on $ALVEO ..."
    ssh "$ALVEO" "
        cd $REMOTE_RUN
        export LD_LIBRARY_PATH=${XRT_LIB}\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}
        ./bm_host ${KN}.xclbin 2>&1 | tee bm_run.log
    "

    # Fetch result
    mkdir -p "$LOCAL_OUT"
    scp "${ALVEO}:${REMOTE_RUN}/bm_run.log" "$LOCAL_OUT/bm_run.log"
    echo "[done] result saved to $LOCAL_OUT/bm_run.log"
done

echo ""
echo "=== All benchmarks complete ==="
