#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

version="$(scripts/read-version.sh)"
work="target/release-artifact-smoke"
first="$work/first"
second="$work/second"
offline="$work/offline"
home="$ROOT/$work/home"
explicit_prefix="$ROOT/$work/explicit"
rm -rf "$work"
mkdir -p "$first" "$second" "$offline"

first_archive="$(scripts/build-release-artifact.sh --version "$version" --output-dir "$first")"
second_archive="$(scripts/build-release-artifact.sh --version "$version" --output-dir "$second")"
if ! cmp -s "$first_archive" "$second_archive"; then
  echo "repeated release archive builds are not byte-identical" >&2
  exit 1
fi

archive_name="$(basename "$first_archive")"
cp "$first_archive" "$offline/$archive_name"
python3 scripts/write-release-checksums.py \
  --output "$offline/SHA256SUMS" \
  "$offline/$archive_name"

if python3 scripts/write-release-checksums.py \
  --require-all-targets \
  --output "$work/incomplete/SHA256SUMS" \
  "$offline/$archive_name" >"$work/incomplete.stdout" 2>"$work/incomplete.stderr"; then
  echo "incomplete release target set unexpectedly succeeded" >&2
  exit 1
fi
grep -Fq "release target set mismatch" "$work/incomplete.stderr" || {
  echo "incomplete release target diagnostic mismatch" >&2
  exit 1
}

mkdir -p "$work/combined"
cp "$offline/$archive_name" "$work/combined/$archive_name"
case "$archive_name" in
  *-aarch64-apple-darwin.tar.gz)
    other_archive="mlgrep-v${version}-x86_64-unknown-linux-gnu.tar.gz"
    ;;
  *-x86_64-unknown-linux-gnu.tar.gz)
    other_archive="mlgrep-v${version}-aarch64-apple-darwin.tar.gz"
    ;;
  *)
    echo "unexpected release archive name: $archive_name" >&2
    exit 1
    ;;
esac
cp "$offline/$archive_name" "$work/combined/$other_archive"
python3 scripts/write-release-checksums.py \
  --require-all-targets \
  --output "$work/combined/SHA256SUMS" \
  "$work/combined"/*.tar.gz
[[ "$(wc -l <"$work/combined/SHA256SUMS" | tr -d ' ')" == "2" ]]
LC_ALL=C sort -c -k2,2 "$work/combined/SHA256SUMS"

mkdir -p "$work/tampered"
cp "$offline/$archive_name" "$work/tampered/$archive_name"
printf 'tampered' >>"$work/tampered/$archive_name"
if sh install.sh \
  --version "$version" \
  --bin-dir "$work/tampered-bin" \
  --archive "$work/tampered/$archive_name" \
  --checksums "$offline/SHA256SUMS" \
  >"$work/tampered.stdout" 2>"$work/tampered.stderr"; then
  echo "tampered release archive unexpectedly installed" >&2
  exit 1
fi
[[ ! -s "$work/tampered.stdout" ]]
[[ "$(cat "$work/tampered.stderr")" == "checksum mismatch for $archive_name" ]]

mkdir -p "$work/malformed"
python3 - "$offline/$archive_name" "$work/malformed/$archive_name" <<'PY'
import gzip
import io
from pathlib import Path
import sys
import tarfile

source_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])
with tarfile.open(source_path, "r:gz") as source:
    members = source.getmembers()
    root_name = members[0].name.rstrip("/")
    with output_path.open("wb") as raw:
        with gzip.GzipFile(filename="", mode="wb", fileobj=raw, mtime=0) as zipped:
            with tarfile.open(fileobj=zipped, mode="w", format=tarfile.USTAR_FORMAT) as output:
                for member in members:
                    extracted = source.extractfile(member) if member.isfile() else None
                    output.addfile(member, extracted)
                extra = tarfile.TarInfo(f"{root_name}/EXTRA")
                extra.mode = 0o644
                extra.size = 5
                extra.mtime = 0
                extra.uid = 0
                extra.gid = 0
                extra.uname = "root"
                extra.gname = "root"
                output.addfile(extra, io.BytesIO(b"extra"))
PY
python3 scripts/write-release-checksums.py \
  --output "$work/malformed/SHA256SUMS" \
  "$work/malformed/$archive_name"
if sh install.sh \
  --version "$version" \
  --bin-dir "$work/malformed-bin" \
  --archive "$work/malformed/$archive_name" \
  --checksums "$work/malformed/SHA256SUMS" \
  >"$work/malformed.stdout" 2>"$work/malformed.stderr"; then
  echo "malformed release archive unexpectedly installed" >&2
  exit 1
fi
[[ ! -s "$work/malformed.stdout" ]]
[[ "$(cat "$work/malformed.stderr")" == "archive entry set mismatch for $archive_name" ]]

install_args=(
  --version "$version"
  --archive "$offline/$archive_name"
  --checksums "$offline/SHA256SUMS"
)
HOME="$home" sh install.sh "${install_args[@]}" >"$work/install-default.stdout"
HOME="$home" sh install.sh "${install_args[@]}" >"$work/reinstall-default.stdout"
installed="$home/.local/bin/mlgrep"
[[ "$(cat "$work/install-default.stdout")" == "installed mlgrep $version to $installed" ]]
[[ "$(cat "$work/reinstall-default.stdout")" == "installed mlgrep $version to $installed" ]]

sh install.sh \
  --version "$version" \
  --bin-dir "$explicit_prefix/bin" \
  --archive "$offline/$archive_name" \
  --checksums "$offline/SHA256SUMS" \
  >"$work/install-explicit.stdout"
[[ -x "$explicit_prefix/bin/mlgrep" ]]
[[ "$($installed --version)" == "mlgrep $version" ]]

"$installed" ERROR tests/fixtures/sample.log >"$work/search.actual"
cmp tests/fixtures/sample-error.expected "$work/search.actual"
[[ "$($installed --count ERROR tests/fixtures/sample.log)" == "2" ]]

if sh install.sh --version invalid >"$work/invalid.stdout" 2>"$work/invalid.stderr"; then
  echo "invalid installer version unexpectedly succeeded" >&2
  exit 1
fi
[[ ! -s "$work/invalid.stdout" ]]
grep -Fq -- "--version must be major.minor.patch[-prerelease]" "$work/invalid.stderr"

printf 'release artifact checks passed: version=%s archive=%s\n' "$version" "$archive_name"
