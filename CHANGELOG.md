# Changelog

All notable changes to mlgrep are documented in this file.

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
