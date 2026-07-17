#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

usage() {
  cat <<'EOF'
usage: scripts/build-release-artifact.sh [--version <major.minor.patch[-prerelease]>] [--output-dir <directory>]
EOF
}

fail_usage() {
  echo "$1" >&2
  usage >&2
  exit 2
}

version=""
output_dir="target/release-artifacts"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || fail_usage "missing value for --version"
      version="$2"
      shift 2
      ;;
    --output-dir)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || fail_usage "missing value for --output-dir"
      output_dir="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail_usage "unknown argument: $1"
      ;;
  esac
done

command -v python3 >/dev/null 2>&1 || {
  echo "python3 is required to build a deterministic release archive" >&2
  exit 1
}

release_version="$(scripts/read-version.sh)"
if [[ -z "$version" ]]; then
  version="$release_version"
elif [[ "$version" != "$release_version" ]]; then
  echo "release version $version does not match VERSION $release_version" >&2
  exit 1
fi
scripts/check-version.sh >/dev/null

if [[ -n "${MLG:-}" ]]; then
  mlg="$MLG"
elif command -v mlg >/dev/null 2>&1; then
  mlg="$(command -v mlg)"
elif [[ -x "$HOME/.local/bin/mlg" ]]; then
  mlg="$HOME/.local/bin/mlg"
else
  echo "mlg 1.1.0 is not installed" >&2
  exit 1
fi
[[ "$($mlg --version)" == "mlg 1.1.0" ]] || {
  echo "mlg 1.1.0 is required" >&2
  exit 1
}

case "$(uname -s):$(uname -m)" in
  Darwin:arm64|Darwin:aarch64)
    target="aarch64-apple-darwin"
    ;;
  Linux:x86_64|Linux:amd64)
    target="x86_64-unknown-linux-gnu"
    ;;
  *)
    echo "unsupported release host: $(uname -s) $(uname -m)" >&2
    exit 1
    ;;
esac

mkdir -p target/release "$output_dir"
"$mlg" build . -o target/release/mlgrep >/dev/null
binary="$ROOT/target/release/mlgrep"
[[ -x "$binary" ]] || {
  echo "release binary was not produced at $binary" >&2
  exit 1
}
[[ "$($binary --version)" == "mlgrep $version" ]] || {
  echo "release binary version mismatch" >&2
  exit 1
}

staging="$(mktemp -d "target/release-staging.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
mkdir -p "$staging/bin"
cp "$binary" "$staging/bin/mlgrep"
chmod 0755 "$staging/bin/mlgrep"
cp LICENSE-MIT LICENSE-APACHE "$staging/"
cp packaging/README.md "$staging/README.md"
chmod 0644 "$staging/LICENSE-MIT" "$staging/LICENSE-APACHE" "$staging/README.md"

root_name="mlgrep-v${version}-${target}"
archive="$output_dir/${root_name}.tar.gz"
python3 scripts/create-release-archive.py \
  --source-dir "$staging" \
  --output "$archive" \
  --root-name "$root_name"

printf '%s\n' "$archive"
