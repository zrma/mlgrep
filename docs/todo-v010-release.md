# v0.1.0 First Binary Release

상태: complete; released as v0.1.0 on 2026-07-17

## Goal

Turn the validated v0.1 CLI into an installable, checksummed two-platform binary release.

## Acceptance

- [x] canonical `VERSION` and `mlgrep --version` identity
- [x] deterministic native archive builder and strict archive entry contract
- [x] macOS arm64 and Linux x86_64 checksum bundle
- [x] offline/online installer with checksum and atomic replacement
- [x] local release artifact and installer regression gate
- [x] tag-triggered release workflow with least-privilege publication job
- [x] release-ready `main` CI success
- [x] signed `v0.1.0` tag and public GitHub Release
- [x] published archive, checksum and clean-prefix installer smoke

## Out Of Scope

- streaming I/O, multiple-file search, regex and recursive traversal
- source changes to Mallang before the v0.1.0 distribution contract is closed
