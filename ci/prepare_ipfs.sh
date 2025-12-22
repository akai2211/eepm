#!/usr/bin/env bash
set -euo pipefail

APP="${1:?usage: ci/prepare_ipfs.sh <app>}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="${CI_PROJECT_DIR:-$REPO_ROOT}"

IPFS_DIR="$PROJECT_DIR/ipfs"
DB_FILE="$IPFS_DIR/eget-ipfs-db.txt"
LOG_DIR="$IPFS_DIR/log"
ERR_DIR="$IPFS_DIR/errors"

mkdir -p "$IPFS_DIR" "$LOG_DIR" "$ERR_DIR"

LOG_FILE="$LOG_DIR/$APP-download.log"
ERR_FILE="$ERR_DIR/$APP-download.log"

cd "$REPO_ROOT/bin"

echo "=== IPFS PREPARE (producer) ==="
echo "App: $APP"

# Producer behaviour: always fetch from upstream
export EGET_IPFS_FORCE_LOAD=1
export EGET_IPFS_API=/ip4/91.232.225.49/tcp/5001

# Temporary workspace
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading package from upstream"

set +e
./epm play --auto --download-only "$APP" >"$LOG_FILE" 2>"$ERR_FILE"
rc=$?
set -e

if [ "$rc" -ne 0 ]; then
  echo "ERROR: download failed for $APP (exit code $rc)"
  echo "See: ipfs/errors/$APP-download.log"
  exit "$rc"
fi

# Find downloaded file (expect exactly one)
DOWNLOADED_FILE="$(find "$TMPDIR" -type f | head -n 1)"

if [ -z "$DOWNLOADED_FILE" ] || [ ! -f "$DOWNLOADED_FILE" ]; then
  echo "ERROR: downloaded file not found for $APP"
  exit 1
fi

FILENAME="$(basename "$DOWNLOADED_FILE")"

echo "Downloaded file:"
echo "  $FILENAME"

# Extract URL from log (last URL wget followed)
URL="$(grep -Eo 'https?://[^ ]+' "$LOG_FILE" | tail -n 1 || true)"

if [ -z "$URL" ]; then
  echo "ERROR: failed to determine source URL for $APP"
  exit 1
fi

echo "Source URL:"
echo "  $URL"

# Publish to IPFS
echo "Publishing to IPFS"

CID="$(ipfs add -q "$DOWNLOADED_FILE")"

if [ -z "$CID" ]; then
  echo "ERROR: ipfs add returned empty CID"
  exit 1
fi

echo "IPFS CID:"
echo "  $CID"

# Update IPFS DB (idempotent)
touch "$DB_FILE"

# Remove old entries for the same URL
grep -v "^$URL " "$DB_FILE" >"$DB_FILE.tmp" || true
mv "$DB_FILE.tmp" "$DB_FILE"

# Append new entry
echo "$URL $CID $FILENAME" >>"$DB_FILE"

# Cleanup empty error log
[ -s "$ERR_FILE" ] || rm -f "$ERR_FILE"

echo "IPFS DB updated:"
echo "  ipfs/eget-ipfs-db.txt"

echo "=== IPFS PREPARE COMPLETED ==="
