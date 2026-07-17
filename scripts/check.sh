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
  fail "mlg 1.1.0 is not installed"
fi

[ "$($mlg --version)" = "mlg 1.1.0" ] || fail "expected mlg 1.1.0"
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
[ "$(target/mlgrep --help)" = "usage: mlgrep [--count] <pattern> <file> [file...]
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
target/mlgrep ERROR tests/fixtures/sample.log target/missing.log >target/multi-io-error.stdout 2>target/multi-io-error.stderr
multi_io_error_status=$?
target/mlgrep MISSING tests/fixtures/sample.log tests/fixtures/clean.log >target/multi-no-match.stdout 2>target/multi-no-match.stderr
multi_no_match_status=$?
target/mlgrep --count MISSING tests/fixtures/sample.log tests/fixtures/clean.log >target/multi-no-match-count.stdout 2>target/multi-no-match-count.stderr
multi_no_match_count_status=$?
target/mlgrep --count tests/fixtures/sample.log >target/count-usage.stdout 2>target/count-usage.stderr
count_usage_status=$?
printf '\377' >target/invalid-utf8.log
target/mlgrep ERROR target/invalid-utf8.log >target/invalid-utf8.stdout 2>target/invalid-utf8.stderr
invalid_utf8_status=$?
printf '' >target/empty.log
target/mlgrep '' target/empty.log >target/empty.stdout 2>target/empty.stderr
empty_status=$?
set -e

[ "$no_match_status" -eq 1 ] || fail "no-match status must be 1"
[ ! -s target/no-match.stdout ] || fail "no-match stdout must be empty"
[ ! -s target/no-match.stderr ] || fail "no-match stderr must be empty"
[ "$no_match_count_status" -eq 1 ] || fail "count no-match status must be 1"
[ "$(cat target/no-match-count.stdout)" = "0" ] || fail "count no-match output must be 0"
[ ! -s target/no-match-count.stderr ] || fail "count no-match stderr must be empty"
[ "$usage_status" -eq 2 ] || fail "usage status must be 2"
[ ! -s target/usage.stdout ] || fail "usage stdout must be empty"
[ "$(cat target/usage.stderr)" = "usage: mlgrep [--count] <pattern> <file> [file...]
       mlgrep --version" ] ||
  fail "usage stderr mismatch"
[ "$io_error_status" -eq 2 ] || fail "I/O error status must be 2"
[ ! -s target/io-error.stdout ] || fail "I/O error stdout must be empty"
[ "$(cat target/io-error.stderr)" = "mlgrep: read failed: NotFound" ] ||
  fail "I/O error stderr mismatch"
[ "$multi_io_error_status" -eq 2 ] || fail "multiple-file I/O error status must be 2"
cmp tests/fixtures/multiple-before-error.expected target/multi-io-error.stdout
[ "$(cat target/multi-io-error.stderr)" = "mlgrep: read target/missing.log failed: NotFound" ] ||
  fail "multiple-file I/O error stderr mismatch"
[ "$multi_no_match_status" -eq 1 ] || fail "multiple-file no-match status must be 1"
[ ! -s target/multi-no-match.stdout ] || fail "multiple-file no-match stdout must be empty"
[ ! -s target/multi-no-match.stderr ] || fail "multiple-file no-match stderr must be empty"
[ "$multi_no_match_count_status" -eq 1 ] || fail "multiple-file count no-match status must be 1"
cmp tests/fixtures/multiple-zero-count.expected target/multi-no-match-count.stdout
[ ! -s target/multi-no-match-count.stderr ] || fail "multiple-file count no-match stderr must be empty"
[ "$count_usage_status" -eq 2 ] || fail "--count without a path must be usage error 2"
[ ! -s target/count-usage.stdout ] || fail "--count usage stdout must be empty"
[ "$(cat target/count-usage.stderr)" = "usage: mlgrep [--count] <pattern> <file> [file...]
       mlgrep --version" ] ||
  fail "--count usage stderr mismatch"
[ "$invalid_utf8_status" -eq 2 ] || fail "invalid UTF-8 status must be 2"
[ ! -s target/invalid-utf8.stdout ] || fail "invalid UTF-8 stdout must be empty"
[ "$(cat target/invalid-utf8.stderr)" = "mlgrep: read failed: InvalidData" ] ||
  fail "invalid UTF-8 stderr mismatch"
[ "$empty_status" -eq 1 ] || fail "empty input with empty pattern must not match"
[ ! -s target/empty.stdout ] || fail "empty input stdout must be empty"
[ ! -s target/empty.stderr ] || fail "empty input stderr must be empty"

target/mlgrep '' tests/fixtures/sample.log >target/empty-pattern.actual
[ "$(wc -l <target/empty-pattern.actual | tr -d ' ')" = "4" ] ||
  fail "terminal newline must not create an extra searchable line"

printf 'ready\n오류\n' >target/unicode.log
[ "$(target/mlgrep 오류 target/unicode.log)" = "2:오류" ] || fail "Unicode output mismatch"

printf 'first\nERROR final' >target/no-final-newline.log
[ "$(target/mlgrep ERROR target/no-final-newline.log)" = "2:ERROR final" ] ||
  fail "final line without LF mismatch"

LC_ALL=C awk 'BEGIN { for (i = 1; i <= 100000; i++) { if (i % 1000 == 0) print i " ERROR request failed"; else print i " INFO request complete" } }' >target/large.log
[ "$(target/mlgrep --count ERROR target/large.log)" = "100" ] ||
  fail "large-input count mismatch"

target/mlgrep ERROR tests/fixtures/sample.log tests/fixtures/secondary.log >target/multiple.actual
cmp tests/fixtures/multiple.expected target/multiple.actual

target/mlgrep --count ERROR tests/fixtures/sample.log tests/fixtures/clean.log tests/fixtures/secondary.log >target/multiple-count.actual
cmp tests/fixtures/multiple-count.expected target/multiple-count.actual

target/mlgrep ERROR tests/fixtures/secondary.log tests/fixtures/secondary.log >target/duplicate.actual
cmp tests/fixtures/duplicate.expected target/duplicate.actual

python3 scripts/measure-streaming-memory.py \
  --binary target/mlgrep \
  --output target/streaming-memory.json \
  --enforce-bounded

printf 'mlgrep checks passed with mlg 1.1.0; streaming CLI, exit-status, and bounded-memory smoke are green\n'
