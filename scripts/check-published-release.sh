#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

version="$(scripts/read-version.sh)"
if [[ $# -gt 0 ]]; then
  if [[ $# -ne 2 || "$1" != "--version" || -z "$2" ]]; then
    echo "usage: scripts/check-published-release.sh [--version <version>]" >&2
    exit 2
  fi
  version="$2"
fi
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$ ]] || {
  echo "release version must be major.minor.patch[-prerelease]" >&2
  exit 2
}

work="$ROOT/target/published-release-$version"
rm -rf "$work"
mkdir -p "$work/bin"
base_url="https://github.com/zrma/mlgrep/releases/download/v$version"
curl --fail --location --silent --show-error --proto '=https' --proto-redir '=https' \
  --tlsv1.2 --retry 3 "$base_url/install.sh" --output "$work/install.sh"
cmp install.sh "$work/install.sh"
sh "$work/install.sh" --version "$version" --bin-dir "$work/bin"
[[ "$("$work/bin/mlgrep" --version)" == "mlgrep $version" ]]
"$work/bin/mlgrep" ERROR tests/fixtures/sample.log >"$work/search.actual"
cmp tests/fixtures/sample-error.expected "$work/search.actual"
case "$version" in
  0.1.0|0.2.0) ;;
  *)
    "$work/bin/mlgrep" ERROR tests/fixtures/sample.log tests/fixtures/secondary.log \
      >"$work/multiple.actual"
    cmp tests/fixtures/multiple.expected "$work/multiple.actual"
    ;;
esac

printf 'published release smoke passed: mlgrep %s\n' "$version"
