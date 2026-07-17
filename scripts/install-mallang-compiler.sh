#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

version=1.0.0
expected=e223f952286ea1d0905eb53500410138aa00b56c14b25563f1eafecb4e138150
work=target/bootstrap
installer=$work/mallang-install.sh
mkdir -p "$work"

curl --fail --location --silent --show-error \
  --proto '=https' --proto-redir '=https' --tlsv1.2 --retry 3 \
  "https://github.com/zrma/mallang/releases/download/v$version/install.sh" \
  --output "$installer"

if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$installer" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
  actual=$(shasum -a 256 "$installer" | awk '{print $1}')
else
  echo "sha256sum or shasum is required" >&2
  exit 1
fi
[ "$actual" = "$expected" ] || {
  echo "Mallang installer checksum mismatch" >&2
  exit 1
}

sh "$installer" --version "$version"
"$HOME/.local/bin/mlg" --version
