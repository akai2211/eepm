#!/usr/bin/env bash
set -euo pipefail

echo "Collecting CI results"

# Get epm version (major.minor)
EPM_VERSION=$("$CI_PROJECT_DIR/bin/epm" --version --short | cut -d. -f1,2)
echo "EPM version: $EPM_VERSION"

RESULTS_REPO_URL="https://gitlab.eterfund.ru/etersoft/epm-play-ci-results.git"
WORKDIR="results"
RESULTS_DIR="${CI_RESULTS_DIR:-epm-results}"
RESULTS_LABEL="${CI_RESULTS_LABEL:-custom}"

META_DIR="meta"
if [ "$RESULTS_DIR" != "epm-results" ]; then
  META_DIR="${RESULTS_DIR}/meta"
fi

# Clone target branch if exists, otherwise clone default and create new branch
if git clone -b "${EPM_VERSION}" "$RESULTS_REPO_URL" "$WORKDIR" 2>/dev/null; then
    cd "$WORKDIR"
else
    git clone "$RESULTS_REPO_URL" "$WORKDIR"
    cd "$WORKDIR"
    git checkout -b "${EPM_VERSION}"
fi

# git configuration
git config user.name "Builder Robot"
git config user.email "builder-robot@etersoft.ru"

# clean old data
rm -rf "${RESULTS_DIR}"/*/epm-logs "${RESULTS_DIR}"/*/epm-errors "$META_DIR" || true

# copy all results
mkdir -p "$RESULTS_DIR"
rsync -a "$CI_PROJECT_DIR/epm-results/" "${RESULTS_DIR}/" || true

# ci info
mkdir -p "$META_DIR"
echo "$CI_PIPELINE_ID" > "${META_DIR}/pipeline-id"
echo "$CI_COMMIT_SHA" > "${META_DIR}/commit-sha"
date -u +%Y-%m-%dT%H:%M:%SZ > "${META_DIR}/timestamp"

# commit
git add .
git commit -m "CI results (${RESULTS_LABEL}): pipeline $CI_PIPELINE_ID" || {
    echo "Nothing to commit"
    exit 0
}

# push to version branch
git remote set-url origin "https://builder-robot:${CI_PUSH_TOKEN}@gitlab.eterfund.ru/etersoft/epm-play-ci-results.git"
git push origin "${EPM_VERSION}" 2>/dev/null
