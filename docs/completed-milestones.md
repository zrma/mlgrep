# Completed Milestones

## 2026-07-17: v0.1 Literal Search Foundation

- Bootstrapped the GPT-5.6 AI-first harness, public boundary gate and cross-platform CI.
- Implemented literal UTF-8 line search, count mode and stable exit classes in Mallang.
- Added 7 unit tests plus native CLI, Unicode, error and 100,000-line smoke coverage.
- Recorded external Mallang v1 ownership, line-splitting and whole-file I/O findings.

Evidence: `scripts/check.sh` passed with the installed public `mlg 1.0.0` compiler.

## 2026-07-17: v0.1.0 First Binary Release

- Added synchronized CLI/release version identity and deterministic archive tooling.
- Published macOS arm64 and Linux x86_64 native archives with `SHA256SUMS` and `install.sh`.
- Verified the signed tag, GitHub Release metadata, both archive checksums and online installation.
- Fixed the next sequence as v0.2.0 streaming I/O followed by v0.3.0 multiple-file search.

Evidence: release workflow and `scripts/check-published-release.sh --version 0.1.0` passed.

## 2026-07-17: v0.2.0 Streaming I/O

- Migrated the default runtime path from whole-file read/split to Mallang 1.1.0
  `fs.forEachLine` with borrowed context and mutable search state.
- Preserved literal/Unicode output, count mode, line numbering, empty/final-line
  behavior and exit classes while adding invalid UTF-8 coverage.
- Recorded deterministic 1/10/100 MiB observations and enforced conservative
  cross-platform peak-RSS and growth ceilings.
- Published signed macOS arm64 and Linux x86_64 archives, checksums and installer.

Evidence: `scripts/check-release.sh` and
`scripts/check-published-release.sh --version 0.2.0` passed.
