#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
version_file=$repo_root/VERSION

[ -f "$version_file" ] && [ ! -L "$version_file" ] || {
  echo "VERSION must be a regular file" >&2
  exit 1
}
[ "$(wc -l <"$version_file" | tr -d ' ')" = "1" ] || {
  echo "VERSION must contain exactly one line" >&2
  exit 1
}
version=$(cat "$version_file")
printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$' || {
  echo "VERSION must be major.minor.patch[-prerelease]" >&2
  exit 1
}

printf '%s\n' "$version"
