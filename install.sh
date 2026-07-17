#!/usr/bin/env sh
set -eu

usage() {
  cat <<'EOF'
usage: sh install.sh --version <major.minor.patch[-prerelease]> [--bin-dir <directory>]
       sh install.sh --version <major.minor.patch[-prerelease]> [--bin-dir <directory>] --archive <path> --checksums <path>
EOF
}

fail_usage() {
  echo "$1" >&2
  usage >&2
  exit 2
}

version=""
bin_dir=""
archive_input=""
checksums_input=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      [ "$#" -ge 2 ] && [ -n "$2" ] || fail_usage "missing value for --version"
      version="$2"
      shift 2
      ;;
    --bin-dir)
      [ "$#" -ge 2 ] && [ -n "$2" ] || fail_usage "missing value for --bin-dir"
      bin_dir="$2"
      shift 2
      ;;
    --archive)
      [ "$#" -ge 2 ] && [ -n "$2" ] || fail_usage "missing value for --archive"
      archive_input="$2"
      shift 2
      ;;
    --checksums)
      [ "$#" -ge 2 ] && [ -n "$2" ] || fail_usage "missing value for --checksums"
      checksums_input="$2"
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

printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$' ||
  fail_usage "--version must be major.minor.patch[-prerelease]"

if [ -z "$bin_dir" ]; then
  [ -n "${HOME:-}" ] || {
    echo "HOME is required when --bin-dir is not specified" >&2
    exit 1
  }
  bin_dir="$HOME/.local/bin"
fi

if { [ -n "$archive_input" ] && [ -z "$checksums_input" ]; } || \
   { [ -z "$archive_input" ] && [ -n "$checksums_input" ]; }; then
  fail_usage "--archive and --checksums must be provided together"
fi

case "$(uname -s):$(uname -m)" in
  Darwin:arm64|Darwin:aarch64)
    target="aarch64-apple-darwin"
    ;;
  Linux:x86_64|Linux:amd64)
    target="x86_64-unknown-linux-gnu"
    ;;
  *)
    echo "unsupported install host: $(uname -s) $(uname -m)" >&2
    exit 1
    ;;
esac

for command_name in awk chmod cmp cp grep mktemp mv sort tar; do
  command -v "$command_name" >/dev/null 2>&1 || {
    echo "$command_name is required to install mlgrep" >&2
    exit 1
  }
done

if command -v sha256sum >/dev/null 2>&1; then
  sha256_file() {
    sha256sum "$1" | awk '{print $1}'
  }
elif command -v shasum >/dev/null 2>&1; then
  sha256_file() {
    shasum -a 256 "$1" | awk '{print $1}'
  }
else
  echo "sha256sum or shasum is required to install mlgrep" >&2
  exit 1
fi

archive_name="mlgrep-v${version}-${target}.tar.gz"
root_name="mlgrep-v${version}-${target}"
temporary="$(mktemp -d "${TMPDIR:-/tmp}/mlgrep-install.XXXXXX")"
staged_binary=""
cleanup() {
  [ -z "$staged_binary" ] || rm -f "$staged_binary"
  rm -rf "$temporary"
}
trap cleanup EXIT HUP INT TERM

archive="$temporary/$archive_name"
checksums="$temporary/SHA256SUMS"
if [ -n "$archive_input" ]; then
  [ -f "$archive_input" ] && [ ! -L "$archive_input" ] || {
    echo "archive is not a regular file: $archive_input" >&2
    exit 1
  }
  [ -f "$checksums_input" ] && [ ! -L "$checksums_input" ] || {
    echo "checksums file is not a regular file: $checksums_input" >&2
    exit 1
  }
  cp "$archive_input" "$archive"
  cp "$checksums_input" "$checksums"
else
  command -v curl >/dev/null 2>&1 || {
    echo "curl is required to download mlgrep release files" >&2
    exit 1
  }
  base_url="https://github.com/zrma/mlgrep/releases/download/v${version}"
  curl --fail --location --silent --show-error --proto '=https' --proto-redir '=https' \
    --tlsv1.2 --retry 3 "$base_url/$archive_name" --output "$archive"
  curl --fail --location --silent --show-error --proto '=https' --proto-redir '=https' \
    --tlsv1.2 --retry 3 "$base_url/SHA256SUMS" --output "$checksums"
fi

match_count="$(
  awk -v name="$archive_name" '
    NF == 2 && $2 == name && length($1) == 64 &&
      $1 !~ /[^0-9a-f]/ && $0 == $1 "  " $2 { count += 1 }
    END { print count + 0 }
  ' "$checksums"
)"
if [ "$match_count" -ne 1 ]; then
  echo "SHA256SUMS must contain exactly one valid entry for $archive_name" >&2
  exit 1
fi
expected_checksum="$(
  awk -v name="$archive_name" '
    NF == 2 && $2 == name && length($1) == 64 &&
      $1 !~ /[^0-9a-f]/ && $0 == $1 "  " $2 { print $1 }
  ' "$checksums"
)"
actual_checksum="$(sha256_file "$archive")"
if [ "$actual_checksum" != "$expected_checksum" ]; then
  echo "checksum mismatch for $archive_name" >&2
  exit 1
fi

actual_entries="$temporary/actual-entries"
expected_entries="$temporary/expected-entries"
tar -tvzf "$archive" | awk 'NF { print substr($1, 1, 1) " " $NF }' | LC_ALL=C sort >"$actual_entries"
cat >"$expected_entries" <<EOF
d $root_name/
- $root_name/LICENSE-APACHE
- $root_name/LICENSE-MIT
- $root_name/README.md
d $root_name/bin/
- $root_name/bin/mlgrep
EOF
LC_ALL=C sort -o "$expected_entries" "$expected_entries"
if ! cmp -s "$actual_entries" "$expected_entries"; then
  echo "archive entry set mismatch for $archive_name" >&2
  exit 1
fi

extract_dir="$temporary/extract"
mkdir -p "$extract_dir"
tar -xzf "$archive" -C "$extract_dir"
for relative in bin/mlgrep LICENSE-MIT LICENSE-APACHE README.md; do
  extracted="$extract_dir/$root_name/$relative"
  [ -f "$extracted" ] && [ ! -L "$extracted" ] || {
    echo "archive contains an invalid file: $relative" >&2
    exit 1
  }
done

mkdir -p "$bin_dir"
if [ -d "$bin_dir/mlgrep" ]; then
  echo "install destination is a directory: $bin_dir/mlgrep" >&2
  exit 1
fi
staged_binary="$bin_dir/.mlgrep.install.$$"
cp "$extract_dir/$root_name/bin/mlgrep" "$staged_binary"
chmod 0755 "$staged_binary"
staged_version="$($staged_binary --version)"
if [ "$staged_version" != "mlgrep $version" ]; then
  echo "installed binary version mismatch: expected mlgrep $version, got $staged_version" >&2
  exit 1
fi
mv -f "$staged_binary" "$bin_dir/mlgrep"
staged_binary=""

printf 'installed mlgrep %s to %s\n' "$version" "$bin_dir/mlgrep"
