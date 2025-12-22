#!/usr/bin/env bash
set -euo pipefail

APP="$1"

# vars
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PROJECT_DIR="${CI_PROJECT_DIR:-$REPO_ROOT}"
RESULTS_ROOT="$PROJECT_DIR/ipfs/"

ERR_DIR="$RESULTS_ROOT/errors"
LOG_DIR="$RESULTS_ROOT/logs"

mkdir -p "$LOG_DIR" "$ERR_DIR"

LOG_FILE="$LOG_DIR/$APP-download.log"
ERR_FILE="$ERR_DIR/$APP-download.log"

cd "$REPO_ROOT/bin"

# ipfs flags
export EGET_IPFS_FORCE_LOAD=1
export EGET_IPFS_API=/ip4/91.232.225.49/tcp/5001

echo "=== Download test and IPFS update ==="
echo "App: $APP"

set +e
./epm play --latest --auto --download-only --ipfs "$APP" 2>&1 | tee "$LOG_FILE"
rc=${PIPESTATUS[0]}
set -e

if [ "$rc" -ne 0 ]; then
  echo "ERROR: fail to download"
  mv -vf "$LOG_FILE" "$ERR_FILE"
  exit "$rc"
fi

cp /var/lib/eepm/eget-ipfs-db.txt "$RESULTS_ROOT/eget-ipfs-db.txt"

# cleanup empty error log
[ -s "$ERR_FILE" ] || rm -f "$ERR_FILE"

echo "IPFS DB updated by eget:"
tail -n 1 "$RESULTS_ROOT/eget-ipfs-db.txt"
echo "=== DONE ==="
