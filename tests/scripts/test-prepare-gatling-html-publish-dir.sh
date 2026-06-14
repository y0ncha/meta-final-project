#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/gatling-html-publish.XXXXXX")
trap 'rm -rf "$TMP_ROOT"' EXIT

SRC="$TMP_ROOT/source"
DEST="$TMP_ROOT/dest"

mkdir -p "$SRC/raw/run-1" "$SRC/assets" "$SRC/nested"
printf '%s\n' '<!doctype html>' > "$SRC/index.html"
printf '%s\n' '%PDF-1.4' > "$SRC/max-limit-report.pdf"
printf '%s\n' 'asset' > "$SRC/assets/app.js"
printf '%s\n' 'nested asset' > "$SRC/nested/data.json"
printf '%s\n' 'huge wrapper log' > "$SRC/max-limit-run.log"
printf '%s\n' 'huge simulation log' > "$SRC/simulation.log"
printf '%s\n' 'raw simulation log' > "$SRC/raw/run-1/simulation.log"

"$PROJECT_ROOT/scripts/prepare-gatling-html-publish-dir" "$SRC" "$DEST"

test -f "$DEST/index.html"
test -f "$DEST/max-limit-report.pdf"
test -f "$DEST/assets/app.js"
test -f "$DEST/nested/data.json"

if [ -e "$DEST/max-limit-run.log" ]; then
  printf '%s\n' 'Expected wrapper run log to be excluded from publish dir' >&2
  exit 1
fi

if [ -e "$DEST/simulation.log" ]; then
  printf '%s\n' 'Expected root simulation log to be excluded from publish dir' >&2
  exit 1
fi

if [ -e "$DEST/raw" ]; then
  printf '%s\n' 'Expected raw Gatling directory to be excluded from publish dir' >&2
  exit 1
fi

printf '%s\n' 'Gatling HTML publish directory preparation checks passed'
