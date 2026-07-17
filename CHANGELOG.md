# Changelog

All notable changes to mlgrep are documented in this file.

## [0.3.0] - 2026-07-17

- Accept multiple explicit file paths and process them sequentially in CLI order.
- Add deterministic path-prefixed matches, per-file counts and aggregate exit semantics.
- Preserve exact v0.2.0 single-file output and read-error behavior.
- Extend bounded-memory evidence with a sequential 200 MiB aggregate workload.
- Define v0.3 as the grep-shaped reference boundary rather than claiming to replace mature grep tools.

## [0.2.0] - 2026-07-17

- Replace whole-file loading and splitting with Mallang 1.1.0 `fs.forEachLine` streaming.
- Preserve literal matching, Unicode line output, count mode and exit classes.
- Add invalid UTF-8, empty input and final-line-without-LF regressions.
- Add deterministic 1/10/100 MiB time and peak-RSS evidence with bounded-memory CI gates.

## [0.1.0] - 2026-07-17

- Add literal UTF-8 line search with deterministic `line:content` output.
- Add count mode and stable match/no-match/error exit classes.
- Publish native archives for macOS arm64 and Linux x86_64 with checksums and an installer.
- Establish the GPT-5.6 AI-first repository, security and publication gates.
