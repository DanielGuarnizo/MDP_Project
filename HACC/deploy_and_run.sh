#!/usr/bin/env bash
# deploy_and_run.sh — full local → hacc-build-01 → alveo pipeline
#
# WHY TWO SUBCOMMANDS
#   The FPGA build (v++ -t hw) takes 4-8 hours. Splitting into 'build' and
#   'run' lets you launch the build, disconnect, come back later and run.
#
# SUBCOMMAND: build <local_deploy_dir>
#   What it does:
#     1. rsync the deploy folder (source + scripts, NO input_data) to hacc-build-01
#     2. Clears any previous build sentinel (.build_done)
#     3. Starts build_all.sh in a detached tmux session named 'hacc_build'
#        build_all.sh runs: vivado (.v→.xo) → v++ (.xo→.xclbin) → cmake (host binary)
#     4. Prints monitoring commands and exits immediately
#   What it does NOT do: wait for the build, touch the alveo node, or copy input data
#
# SUBCOMMAND: run <local_deploy_dir> <alveo_host> [<input_data_dir>]
#   What it does (only after build is complete):
#     1. Verifies .build_done sentinel exists on hacc-build-01
#     2. build-01 → alveo: copies panda.xclbin, bambu_application, accel_config.json
#        (uses ForwardAgent so build-01 can reach alveo with your local key)
#     3. local → alveo: copies input_data DIRECTLY (skips build-01 to avoid
#        transferring the same data twice)
#     4. Runs ./bambu_application on the alveo node
#     5. alveo → local: copies output_data/ back to local machine
#     6. Runs verify.py locally against the downloaded outputs and the local
#        golden reference in input_data/ — result preserved on local disk
#
# EXAMPLES
#   ./deploy_and_run.sh build 20260514_170825
#   ./deploy_and_run.sh run   20260514_170825 hacc-alveo-u55c-01 ./input_data

set -eo pipefail

BUILD_NODE="hacc-build-01"
REMOTE_DEPLOY_BASE="workspace/deploy"
REMOTE_RUN_BASE="workspace/run"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── helpers ──────────────────────────────────────────────────────────────────

usage() {
    cat <<EOF
Usage:
  $0 build         <local_deploy_dir>
  $0 run           <local_deploy_dir> <alveo_host> [<input_data_dir>]
  $0 fetch-reports <local_deploy_dir>

  build         — rsync source to $BUILD_NODE, start Vivado+v++cmake in tmux, exit immediately
  run           — (after build) copy artifacts to alveo, copy input_data from local→alveo,
                  run accelerator, pull output_data + reports back to local, run perf analysis
  fetch-reports — pull Vivado .rpt files from $BUILD_NODE to local without running the accelerator
                  (works even for a partial/failed build; used to get utilization + timing reports)

  <alveo_host>     SSH alias for the booked alveo node (e.g. hacc-alveo-u55c-01)
  <input_data_dir> directory with *.bin input files (default: <deploy_dir>/input_data)
EOF
    exit 1
}

die() { echo "ERROR: $*" >&2; exit 1; }

# ─── build subcommand ─────────────────────────────────────────────────────────

cmd_build() {
    local local_dir="${1:?$(usage)}"
    local_dir="$(cd "$local_dir" && pwd)"          # absolute
    local deploy_name
    deploy_name="$(basename "$local_dir")"
    local remote_build="~/$REMOTE_DEPLOY_BASE/$deploy_name"

    echo "=== [build] deploy_name : $deploy_name"
    echo "=== [build] build node  : $BUILD_NODE"
    echo "=== [build] remote path : $remote_build"
    echo

    # Create remote dir structure
    ssh "$BUILD_NODE" "mkdir -p $remote_build/xo $remote_build/src $remote_build/host"

    # rsync source — skip input/output data and existing build artifacts
    echo "--- Syncing source to $BUILD_NODE ..."
    rsync -av --progress \
        --exclude='input_data/' \
        --exclude='output_data/' \
        --exclude='xo/*.xclbin' \
        --exclude='xo/*.xo' \
        --exclude='build/' \
        --exclude='*.log' \
        --exclude='.build_done' \
        "$local_dir/" "$BUILD_NODE:$remote_build/"

    # Clear previous sentinel so 'run' doesn't think an old build counts
    ssh "$BUILD_NODE" "rm -f $remote_build/.build_done"

    # Kill any leftover tmux session with the same name
    ssh "$BUILD_NODE" "tmux kill-session -t hacc_build 2>/dev/null || true"

    # Start build — touch sentinel on success
    echo
    echo "--- Launching build in tmux session 'hacc_build' on $BUILD_NODE ..."
    ssh "$BUILD_NODE" \
        "tmux new-session -d -s hacc_build \
         'bash $remote_build/build_all.sh \
          && touch $remote_build/.build_done \
          && echo BUILD_DONE; \
          echo EXIT=\$?; read'"

    cat <<EOF

Build started. Monitor with:
  ssh $BUILD_NODE 'tail -f $remote_build/build_all.log'
  ssh $BUILD_NODE 'tmux attach -t hacc_build'

Check if done:
  ssh $BUILD_NODE 'test -f $remote_build/.build_done && echo DONE || echo BUILDING'

When done, run the accelerator:
  $0 run $deploy_name <alveo_host> [<input_data_dir>]
EOF
}

# ─── run subcommand ───────────────────────────────────────────────────────────

cmd_run() {
    local local_dir="${1:?$(usage)}"
    local alveo_host="${2:?$(usage)}"

    local_dir="$(cd "$local_dir" && pwd)"
    local input_data="${3:-$local_dir/input_data}"
    local deploy_name
    deploy_name="$(basename "$local_dir")"
    local remote_build="~/$REMOTE_DEPLOY_BASE/$deploy_name"
    local remote_run="~/$REMOTE_RUN_BASE/$deploy_name"

    # Resolve SSH alias → real user@host so build-01 can scp to alveo directly
    local alveo_real_host alveo_real_user
    alveo_real_host=$(ssh -G "$alveo_host" 2>/dev/null | awk '/^hostname / {print $2; exit}')
    alveo_real_user=$(ssh -G "$alveo_host" 2>/dev/null | awk '/^user /    {print $2; exit}')
    alveo_real_host="${alveo_real_host:-$alveo_host}"
    local alveo_at="${alveo_real_user:+${alveo_real_user}@}${alveo_real_host}"

    echo "=== [run] deploy_name  : $deploy_name"
    echo "=== [run] alveo host   : $alveo_host"
    echo "=== [run] input_data   : $input_data"
    echo "=== [run] alveo rundir : $remote_run"
    echo

    # Check build is complete
    if ! ssh "$BUILD_NODE" "test -f $remote_build/.build_done" 2>/dev/null; then
        die "Build not finished yet on $BUILD_NODE. Check with:\n  ssh $BUILD_NODE 'tail -20 $remote_build/build_all.log'"
    fi
    echo "--- Build confirmed complete."

    # Prepare run dir on alveo
    ssh "$alveo_host" "mkdir -p $remote_run/input_data $remote_run/output_data"

    # build-01 → alveo: xclbin + binary + config (forwarded agent)
    # Use real user@host (not local SSH alias) so build-01 can resolve the name
    echo "--- Copying artifacts $BUILD_NODE → $alveo_at ..."
    ssh "$BUILD_NODE" \
        "scp -o StrictHostKeyChecking=accept-new \
             $remote_build/xo/panda.xclbin \
             $remote_build/build/host/bambu_application \
             $remote_build/accel_config.json \
             $alveo_at:$remote_run/"

    # local → alveo: input_data + xrt.ini (direct, avoids double transfer via build node)
    echo "--- Copying input_data local → $alveo_host ..."
    [[ -d "$input_data" ]] || die "input_data dir not found: $input_data"
    scp -r "$input_data/." "$alveo_host:$remote_run/input_data/"

    if [[ -f "$local_dir/xrt.ini" ]]; then
        echo "--- Copying xrt.ini local → $alveo_host ..."
        scp "$local_dir/xrt.ini" "$alveo_host:$remote_run/xrt.ini"
    fi

    # Run accelerator on alveo — capture stdout to run.log
    echo
    echo "--- Running bambu_application on $alveo_host ..."
    ssh "$alveo_host" bash <<REMOTE
set -eo pipefail
cd $remote_run
export LD_LIBRARY_PATH=/opt/xilinx/xrt/lib:\${LD_LIBRARY_PATH:-}
./bambu_application panda.xclbin accel_config.json input_data/ output_data/ | tee run.log
REMOTE

    # alveo → local: pull output_data + run.log
    local local_output="$local_dir/output_data"
    echo
    echo "--- Copying output_data $alveo_host → local ($local_output) ..."
    mkdir -p "$local_output"
    scp -r "$alveo_host:$remote_run/output_data/." "$local_output/"

    echo "--- Copying run.log $alveo_host → local ..."
    scp "$alveo_host:$remote_run/run.log" "$local_dir/run.log"

    echo "--- Copying profile data $alveo_host → local ..."
    scp "$alveo_host:$remote_run/profile_summary.csv" \
        "$local_dir/profile_summary.csv" 2>/dev/null || true
    scp "$alveo_host:$remote_run/timeline_trace.csv" \
        "$local_dir/timeline_trace.csv" 2>/dev/null || true

    # build-01 → local: Vivado report files only (not the full multi-GB build tree)
    echo "--- Syncing build reports $BUILD_NODE → local ..."
    rsync -a --include='*/' --include='*.rpt' --exclude='*' \
        "$BUILD_NODE:$remote_build/build/" "$local_dir/build/" || true
    # Also grab any .rpt files written to the deploy root (e.g. impl_1_power_routed.rpt
    # from post_route.tcl, which uses [info script] to write next to itself)
    rsync -a --include='*.rpt' --exclude='*' \
        "$BUILD_NODE:$remote_build/" "$local_dir/" || true

    # Run performance analysis locally (reads run.log + any .rpt files now present)
    echo
    echo "--- Running performance analysis locally ..."
    bash "$SCRIPT_DIR/performance_analysis.sh" "$local_dir/run.log"

    # Verify locally
    echo
    echo "--- Verifying outputs locally ..."
    python3 "$SCRIPT_DIR/verify.py" "$local_dir"

    echo
    echo "=== Done."
    echo "    Outputs preserved at : $local_output"
    echo "    Run log              : $local_dir/run.log"
    echo "    Perf report          : $local_dir/perf_*.txt"
    echo "    Alveo copy at        : $alveo_host:$remote_run/"
}

# ─── fetch-reports subcommand ─────────────────────────────────────────────────
# Pull Vivado .rpt files from build-01 without requiring a full build+run.
# Useful when: build completed or partially completed but 'run' hasn't been called;
# or to refresh reports after fixing a deploy.

cmd_fetch_reports() {
    local local_dir="${1:?$(usage)}"
    local_dir="$(cd "$local_dir" && pwd)"
    local deploy_name
    deploy_name="$(basename "$local_dir")"
    local remote_build="~/$REMOTE_DEPLOY_BASE/$deploy_name"

    echo "=== [fetch-reports] deploy : $deploy_name"
    echo "=== [fetch-reports] source : $BUILD_NODE:$remote_build/build/"
    echo "=== [fetch-reports] dest   : $local_dir/build/"
    echo

    echo "--- Syncing Vivado .rpt files $BUILD_NODE → local ..."
    rsync -a --include='*/' --include='*.rpt' --exclude='*' \
        "$BUILD_NODE:$remote_build/build/" "$local_dir/build/" || true

    local n
    n="$(find "$local_dir/build" -name '*.rpt' 2>/dev/null | wc -l | tr -d ' ')"
    echo "--- Fetched $n .rpt file(s) to $local_dir/build/"
    echo
    echo "=== Done. Run performance analysis with:"
    echo "    bash $SCRIPT_DIR/performance_analysis.sh $local_dir/run.log"
}

# ─── dispatch ─────────────────────────────────────────────────────────────────

SUBCMD="${1:-}"
shift || true

case "$SUBCMD" in
    build)         cmd_build         "$@" ;;
    run)           cmd_run           "$@" ;;
    fetch-reports) cmd_fetch_reports "$@" ;;
    *)             usage ;;
esac
