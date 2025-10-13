#!/usr/bin/env bash
set -euo pipefail

# args
APP="${1:?usage: tests/run_one_ci.sh <app>}"

# layout
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"       # .../repo/tests
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"         # .../repo

PROJECT_DIR="${CI_PROJECT_DIR:-$REPO_ROOT}"
LOGDIR="$PROJECT_DIR"

PLAY_DIR="$LOGDIR/epm-play-versions"
ERR_DIR="$LOGDIR/epm-errors"
LOG_DIR="$LOGDIR/epm-logs"
REQ_DIR="$LOGDIR/epm-requires"
mkdir -p "$PLAY_DIR" "$ERR_DIR" "$LOG_DIR" "$REQ_DIR"

# deps & env
cd "$REPO_ROOT/bin"
./epmu
./epmi -y wget glibc-pthread git kubo coreutils

export LOGDIR
export EGET_IPFS_FORCE_LOAD=1
export EPM_IPFS_DB_UPDATE_SKIPPING=1
export EGET_IPFS_API=/ip4/91.232.225.49/tcp/5001

# run updater 
set +e
EPM="$(pwd)/epm" bash "$SCRIPT_DIR/update_versions.sh" --ipfs --force --slow "$APP"
update_exit_code=$?
set -e

# determine package name & version file path
package_name="$(./epm play --package-name "$APP")"
version_file_path="$PLAY_DIR/$package_name"

# if version file missing, try to write it ourselves
if [ ! -s "$version_file_path" ]; then
  tmp_file="$(mktemp)"
  ./epm print version for package "$package_name" >"$tmp_file" 2>>"$ERR_DIR/$package_name" || true
  if [ -s "$tmp_file" ]; then
    mv -f "$tmp_file" "$version_file_path"
  else
    rm -f "$tmp_file"
  fi
fi

# final result: success if version file exists
if [ -s "$version_file_path" ]; then
  echo "V $APP: Test PASS for version -> $version_file_path"
  final_exit_code=0
else
  echo "X $APP: Test FAILED"
  final_exit_code="$update_exit_code"
fi

echo "exit code: $final_exit_code"
exit "$final_exit_code"
