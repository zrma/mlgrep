#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

fail() {
  printf 'mlgrep check failed: %s\n' "$1" >&2
  exit 1
}

if [ -n "${MLG:-}" ]; then
  mlg=$MLG
elif command -v mlg >/dev/null 2>&1; then
  mlg=$(command -v mlg)
elif [ -x "$HOME/.local/bin/mlg" ]; then
  mlg=$HOME/.local/bin/mlg
else
  fail "mlg 1.0.0 is not installed"
fi

[ "$($mlg --version)" = "mlg 1.0.0" ] || fail "expected mlg 1.0.0"
command -v clang >/dev/null 2>&1 || fail "clang is required"

scripts/check-agent-harness-interface.sh
scripts/check-version.sh
"$mlg" fmt --check .
"$mlg" check .
"$mlg" test .

mkdir -p target
"$mlg" build . -o target/mlgrep

target/mlgrep ERROR tests/fixtures/sample.log >target/sample-error.actual
cmp tests/fixtures/sample-error.expected target/sample-error.actual

[ "$(target/mlgrep --count ERROR tests/fixtures/sample.log)" = "2" ] ||
  fail "count output mismatch"
[ "$(target/mlgrep --help)" = "usage: mlgrep [--count] <pattern> <file>
       mlgrep --version" ] ||
  fail "help output mismatch"
[ "$(target/mlgrep --version)" = "mlgrep $(scripts/read-version.sh)" ] ||
  fail "version output mismatch"

set +e
target/mlgrep MISSING tests/fixtures/sample.log >target/no-match.stdout 2>target/no-match.stderr
no_match_status=$?
target/mlgrep --count MISSING tests/fixtures/sample.log >target/no-match-count.stdout 2>target/no-match-count.stderr
no_match_count_status=$?
target/mlgrep >target/usage.stdout 2>target/usage.stderr
usage_status=$?
target/mlgrep ERROR target/missing.log >target/io-error.stdout 2>target/io-error.stderr
io_error_status=$?
set -e

[ "$no_match_status" -eq 1 ] || fail "no-match status must be 1"
[ ! -s target/no-match.stdout ] || fail "no-match stdout must be empty"
[ ! -s target/no-match.stderr ] || fail "no-match stderr must be empty"
[ "$no_match_count_status" -eq 1 ] || fail "count no-match status must be 1"
[ "$(cat target/no-match-count.stdout)" = "0" ] || fail "count no-match output must be 0"
[ ! -s target/no-match-count.stderr ] || fail "count no-match stderr must be empty"
[ "$usage_status" -eq 2 ] || fail "usage status must be 2"
[ ! -s target/usage.stdout ] || fail "usage stdout must be empty"
[ "$(cat target/usage.stderr)" = "usage: mlgrep [--count] <pattern> <file>
       mlgrep --version" ] ||
  fail "usage stderr mismatch"
[ "$io_error_status" -eq 2 ] || fail "I/O error status must be 2"
[ ! -s target/io-error.stdout ] || fail "I/O error stdout must be empty"
[ "$(cat target/io-error.stderr)" = "mlgrep: read failed: NotFound" ] ||
  fail "I/O error stderr mismatch"

target/mlgrep '' tests/fixtures/sample.log >target/empty-pattern.actual
[ "$(wc -l <target/empty-pattern.actual | tr -d ' ')" = "4" ] ||
  fail "terminal newline must not create an extra searchable line"

printf 'ready\n오류\n' >target/unicode.log
[ "$(target/mlgrep 오류 target/unicode.log)" = "2:오류" ] || fail "Unicode output mismatch"

LC_ALL=C awk 'BEGIN { for (i = 1; i <= 100000; i++) { if (i % 1000 == 0) print i " ERROR request failed"; else print i " INFO request complete" } }' >target/large.log
[ "$(target/mlgrep --count ERROR target/large.log)" = "100" ] ||
  fail "large-input count mismatch"

printf 'mlgrep checks passed with mlg 1.0.0; unit, CLI, exit-status, and 100000-line smoke are green\n'
