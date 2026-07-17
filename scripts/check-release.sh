#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

scripts/check.sh
scripts/check-version.sh
sh -n install.sh scripts/read-version.sh scripts/check-version.sh scripts/install-mallang-compiler.sh
bash -n scripts/build-release-artifact.sh scripts/check-release-artifacts.sh scripts/check-published-release.sh
python3 -m py_compile \
  scripts/create-release-archive.py \
  scripts/measure-streaming-memory.py \
  scripts/write-release-checksums.py
scripts/check-release-artifacts.sh

printf 'mlgrep release gate passed\n'
