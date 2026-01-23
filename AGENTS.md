# Repository Guidelines

Start by reading `AGENTS.md` at the beginning of each session.

## Project Structure & Module Organization

- `bin/` holds the core shell entry points (`epm`, `serv`, `distr_info`) plus command helpers (`epm-*`, `serv-*`, `tools_*`).
- `play.d/` contains “epm play” install scripts; `repack.d/` converts packages between formats; `pack.d/` builds packages from upstream bundles.
- `prescription.d/` defines meta-package recipes and `desktop.d/` provides desktop integration data.
- `etc/` stores default configuration and allow/stop lists (see `etc/eepm.conf`).
- `tests/` has shell test scripts and Bats suites; `docs/` and `man/` hold documentation.

## Build, Test, and Development Commands

- No build step required. Run scripts directly, e.g. `./bin/epm --help` or `./bin/serv --help`.
- Packaging install target: `make install DESTDIR=/tmp/pkgroot` to stage files.
- Linting: `./check_code.sh` (runs `shellcheck` and `checkbashisms`); use `./check_code.sh bin/epm-install` for a single file.
- Tests: `./tests/run_bats.sh` (all Bats tests) or `./tests/run_bats.sh tests/search/test_search.bats`; run individual scripts like `./tests/test_versions.sh`.

## Coding Style & Naming Conventions

- Prefer POSIX `sh` (`#!/bin/sh`) and avoid bashisms; `checkbashisms` enforces this.
- Follow existing naming: command implementations `bin/epm-*`, service commands `bin/serv-*`, helpers `bin/tools_*`.
- New app scripts should be named `play.d/<app>.sh`, `repack.d/<app>.sh`, or `pack.d/<app>.sh`.
- Keep Makefile commands tab-indented; use consistent shell formatting and single quotes for user-facing messages where possible.

## Testing Guidelines

- Bats tests live in `tests/*.bats` (helpers in `tests/*/helpers.bash`).
- Shell tests are `tests/test_*.sh`; name new tests after the feature under test.
- No formal coverage target; add or update tests when behavior changes.

## Commit & Pull Request Guidelines

- Commit messages are short and scoped, usually `area: description` (e.g., `tests: add ...`, `epm play fresh: add ...`).
- PRs should include a clear summary, relevant commands run, and doc updates for user-facing changes.

## Configuration & Safety Notes

- Default configuration lives in `etc/eepm.conf`; local repo details are in `docs/local-repo.md`.
- Use `/tmp` for temporary downloads or scratch files during development.
- In repack scripts, `PRODUCT` is the internal app name (e.g., `/opt/$PRODUCT`, `/usr/bin/$PRODUCT) and may differ from the package name. Use the repack script’s third argument (package `Name:`) when you need the actual `PKGNAME`.
