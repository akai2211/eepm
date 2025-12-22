#!/usr/bin/env bash
set -euo pipefail


# detect OS
. /etc/os-release
CI_SYSTEM_ID="$ID-$VERSION_ID"

# args
APP="${1:?usage: tests/run_one_ci.sh <app>}"
shift || true
EPM_FLAGS="$*"

# layout
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"       # .../repo/tests
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"         # .../repo

PROJECT_DIR="${CI_PROJECT_DIR:-$REPO_ROOT}"
RESULTS_ROOT="$PROJECT_DIR/epm-results/$CI_SYSTEM_ID"
LOGDIR="$RESULTS_ROOT"

PLAY_DIR="$LOGDIR/epm-play-versions"
ERR_DIR="$LOGDIR/epm-errors"
LOG_DIR="$LOGDIR/epm-logs"
REQ_DIR="$LOGDIR/epm-requires"

mkdir -p "$PLAY_DIR" "$ERR_DIR" "$LOG_DIR" "$REQ_DIR"

# env
cd "$REPO_ROOT/bin"

# IPFS db 
USE_IPFS=0
for arg in $EPM_FLAGS; do
  [ "$arg" = "--ipfs" ] && USE_IPFS=1
done

if [ "$USE_IPFS" -eq 1 ]; then
  echo "IPFS mode enabled"

  IPFS_DB_DIR="${CI_IPFS_DB_DIR:-$PROJECT_DIR/.cache/ipfs/db}"
  mkdir -p "$IPFS_DB_DIR"
  export IPFS_PATH="$IPFS_DB_DIR"

  export EGET_IPFS_FORCE_LOAD=1
  export EPM_IPFS_DB_UPDATE_SKIPPING=1
  export EGET_IPFS_API=/ip4/91.232.225.49/tcp/5001
else
  echo "IPFS mode disabled (site repositories)"
fi

# run updater 
echo "Installing $APP $EPM_FLAGS"

set +e
./epm play $EPM_FLAGS --auto "$APP" 2>&1 | tee "$LOG_DIR/$APP.log"
rc=$?
set -e

# result

if [ "$rc" -eq 0 ]; then
  
  echo "V $APP: PASS"

  package_name="$(./epm play --package-name "$APP")"
  version_file="$PLAY_DIR/$package_name"

  ./epm print version for package "$package_name" \
    >"$PLAY_DIR/$package_name" \
    2>"$ERR_DIR/$package_name" || true
  
  ./epm req "$package_name" >"$REQ_DIR/$package_name" 2>&1 || true  

else
  echo "X $APP: FAIL"

  mv -f "$LOG_DIR/$APP.log" "$ERR_DIR/$APP.log"
fi

# cleanup empty error files and dir
if [ -d "$ERR_DIR" ]; then
  find "$ERR_DIR" -type f -size 0 -delete
  rmdir "$ERR_DIR" 2>/dev/null || true
fi

echo "Exit code: $rc"
exit "$rc"
