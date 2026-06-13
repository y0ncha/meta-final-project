#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/gatling-console-mode-test.XXXXXX")
SCRIPT_DIR="$TEST_ROOT/scripts"
FAKE_GATLING="$TEST_ROOT/fake-gatling.sh"

mkdir -p "$SCRIPT_DIR" "$TEST_ROOT/src/gatling/user-files/simulations"
cp "$PROJECT_ROOT/scripts/run-gatling-container" "$SCRIPT_DIR/run-gatling-container"

cat > "$FAKE_GATLING" <<'SH'
#!/usr/bin/env sh
set -eu

raw_dir=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -rf)
      raw_dir="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [ -z "$raw_dir" ]; then
  printf '%s\n' 'missing -rf raw dir' >&2
  exit 1
fi

mkdir -p "$raw_dir/fake-run"
printf '<!doctype html><title>fake gatling report</title>\n' > "$raw_dir/fake-run/index.html"

printf '%s\n' 'VERY NOISY GATLING DETAIL THAT SHOULD BE HIDDEN IN SUMMARY MODE'
printf '%s\n' '================================================================================'
printf '%s\n' '---- Global Information --------------------------------------------------------'
printf '%s\n' '> request count                                      1 (OK=1      KO=0     )'
printf '%s\n' 'PROGRESS BLOCK THAT SHOULD BE HIDDEN IN SUMMARY MODE'
printf '%s\n' '================================================================================'
printf '%s\n' '---- Global Information --------------------------------------------------------'
printf '%s\n' '> request count                                     10 (OK=8      KO=2     )'
printf '%s\n' '> max response time                                  18446 (OK=18446  KO=-     )'
printf '%s\n' '> mean response time                                 12844 (OK=12844  KO=-     )'
printf '%s\n' '> response time 95th percentile                      15728 (OK=15728  KO=-     )'
printf '%s\n' '> response time 99th percentile                      16412 (OK=16412  KO=-     )'
printf '%s\n' '> mean requests/sec                                 440.96 (OK=440.96 KO=-     )'
printf '%s\n' '---- Response Time Distribution ------------------------------------------------'
printf '%s\n' '> failed                                                 2 ( 20%)'
printf '%s\n' '---- Errors --------------------------------------------------------------------'
printf '%s\n' '> j.i.IOException: Premature close                                    2 (100.0%)'
printf '%s\n' '================================================================================'
printf '%s\n' 'Reports generated in 1s.'
SH
chmod +x "$SCRIPT_DIR/run-gatling-container" "$FAKE_GATLING"

(
  cd "$TEST_ROOT"
  GATLING_DOCKER_PIPELINE=1 \
  GATLING_RUN_TYPE=load-5m \
  GATLING_BIN="$FAKE_GATLING" \
  GATLING_CONSOLE_MODE=summary \
    "$SCRIPT_DIR/run-gatling-container" > "$TEST_ROOT/summary.out"
)

grep -Fq -- 'Gatling console mode: summary. Full log saved to output/gatling/load-5m/load-5m-run.log' "$TEST_ROOT/summary.out"
grep -Fq -- 'load test started : 5 virtual users | duration: 300s' "$TEST_ROOT/summary.out"
grep -Fq -- '---- Global Information --------------------------------------------------------' "$TEST_ROOT/summary.out"
grep -Fq -- '> request count                                     10 (OK=8      KO=2     )' "$TEST_ROOT/summary.out"
grep -Fq -- '> j.i.IOException: Premature close                                    2 (100.0%)' "$TEST_ROOT/summary.out"
if grep -Fq -- 'Gatling summary:' "$TEST_ROOT/summary.out"; then
  printf '%s\n' 'Summary mode printed custom metrics instead of Gatling native summary' >&2
  exit 1
fi
if grep -Fq -- 'VERY NOISY GATLING DETAIL' "$TEST_ROOT/summary.out"; then
  printf '%s\n' 'Summary mode printed noisy Gatling detail' >&2
  exit 1
fi
if grep -Fq -- 'PROGRESS BLOCK THAT SHOULD BE HIDDEN' "$TEST_ROOT/summary.out"; then
  printf '%s\n' 'Summary mode printed an earlier progress block' >&2
  exit 1
fi
if grep -Fq -- '> request count                                      1 (OK=1      KO=0     )' "$TEST_ROOT/summary.out"; then
  printf '%s\n' 'Summary mode printed an earlier Gatling progress summary' >&2
  exit 1
fi
grep -Fq -- 'VERY NOISY GATLING DETAIL' "$TEST_ROOT/output/gatling/load-5m/load-5m-run.log"
grep -Fq -- 'PROGRESS BLOCK THAT SHOULD BE HIDDEN' "$TEST_ROOT/output/gatling/load-5m/load-5m-run.log"
grep -Fq -- '---- Global Information' "$TEST_ROOT/output/gatling/load-5m/load-5m-run.log"

(
  cd "$TEST_ROOT"
  GATLING_DOCKER_PIPELINE=1 \
  GATLING_RUN_TYPE=stress-5m \
  GATLING_BIN="$FAKE_GATLING" \
  GATLING_CONSOLE_MODE=full \
    "$SCRIPT_DIR/run-gatling-container" > "$TEST_ROOT/full.out"
)

grep -Fq -- 'VERY NOISY GATLING DETAIL' "$TEST_ROOT/full.out"

(
  cd "$TEST_ROOT"
  GATLING_DOCKER_PIPELINE=1 \
  GATLING_RUN_TYPE=max-limit \
  GATLING_BIN="$FAKE_GATLING" \
  GATLING_CONSOLE_MODE=summary \
    "$SCRIPT_DIR/run-gatling-container" > "$TEST_ROOT/max-limit-pass.out"
)

if grep -Fq -- 'Gatling summary:' "$TEST_ROOT/max-limit-pass.out"; then
  printf '%s\n' 'Summary mode printed max-limit metrics for a passing level' >&2
  exit 1
fi
if grep -Fq -- 'Gatling evidence:' "$TEST_ROOT/max-limit-pass.out"; then
  printf '%s\n' 'Summary mode printed max-limit evidence path noise for a passing level' >&2
  exit 1
fi

cat > "$FAKE_GATLING" <<'SH'
#!/usr/bin/env sh
set -eu

raw_dir=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -rf)
      raw_dir="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

mkdir -p "$raw_dir/fake-run"
printf '<!doctype html><title>fake gatling report</title>\n' > "$raw_dir/fake-run/index.html"
printf '%s\n' '---- Global Information --------------------------------------------------------'
printf '%s\n' '> request count                                     10 (OK=8      KO=2     )'
printf '%s\n' '> max response time                                  18446 (OK=18446  KO=-     )'
printf '%s\n' '> mean response time                                 12844 (OK=12844  KO=-     )'
printf '%s\n' '> response time 95th percentile                      15728 (OK=15728  KO=-     )'
printf '%s\n' '> response time 99th percentile                      16412 (OK=16412  KO=-     )'
printf '%s\n' '> mean requests/sec                                 440.96 (OK=440.96 KO=-     )'
printf '%s\n' '> failed                                                 2 ( 20%)'
exit 2
SH
chmod +x "$FAKE_GATLING"

status=0
(
  cd "$TEST_ROOT"
  GATLING_DOCKER_PIPELINE=1 \
  GATLING_RUN_TYPE=max-limit \
  GATLING_BIN="$FAKE_GATLING" \
  GATLING_CONSOLE_MODE=summary \
    "$SCRIPT_DIR/run-gatling-container" > "$TEST_ROOT/max-limit-fail.out"
) || status=$?

if [ "${status:-0}" -ne 2 ]; then
  printf 'Expected max-limit failing fake Gatling status 2, got %s\n' "${status:-0}" >&2
  exit 1
fi
grep -Fq -- '---- Global Information --------------------------------------------------------' "$TEST_ROOT/max-limit-fail.out"
grep -Fq -- '> request count                                     10 (OK=8      KO=2     )' "$TEST_ROOT/max-limit-fail.out"
if grep -Fq -- 'Gatling summary:' "$TEST_ROOT/max-limit-fail.out"; then
  printf '%s\n' 'Summary mode printed custom max-limit metrics instead of Gatling native summary' >&2
  exit 1
fi

printf '%s\n' 'run-gatling-container console mode checks passed'
