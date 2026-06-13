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
printf '%s\n' '> request count                                     10 (OK=10     KO=0     )'
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
grep -Fq -- '---- Global Information' "$TEST_ROOT/summary.out"
grep -Fq -- '> request count                                     10 (OK=10     KO=0     )' "$TEST_ROOT/summary.out"
if grep -Fq -- 'VERY NOISY GATLING DETAIL' "$TEST_ROOT/summary.out"; then
  printf '%s\n' 'Summary mode printed noisy Gatling detail' >&2
  exit 1
fi
grep -Fq -- 'VERY NOISY GATLING DETAIL' "$TEST_ROOT/output/gatling/load-5m/load-5m-run.log"

(
  cd "$TEST_ROOT"
  GATLING_DOCKER_PIPELINE=1 \
  GATLING_RUN_TYPE=stress-5m \
  GATLING_BIN="$FAKE_GATLING" \
  GATLING_CONSOLE_MODE=full \
    "$SCRIPT_DIR/run-gatling-container" > "$TEST_ROOT/full.out"
)

grep -Fq -- 'VERY NOISY GATLING DETAIL' "$TEST_ROOT/full.out"

printf '%s\n' 'run-gatling-container console mode checks passed'
