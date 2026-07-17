# Roadmap

## v0.1: Literal Search Foundation

- [x] literal UTF-8 line search with deterministic output
- [x] count mode without rendered output allocation
- [x] grep-compatible match/no-match/usage exit classes
- [x] Mallang unit tests and native CLI fixture smoke
- [x] deterministic large-input validation
- [x] AI-first harness, publication and VCS gates

## v0.1.0: First Binary Release

- [x] CLI version identity
- [x] deterministic native archives for macOS arm64 and Linux x86_64
- [x] checksums and atomic installer contract
- [ ] signed tag, public assets and published installer smoke

## v0.2.0: Streaming I/O

- [ ] establish 1/10/100 MiB time and peak-memory baselines
- [ ] add the smallest required streaming API to the published Mallang standard library
- [ ] search incrementally with bounded memory while preserving v0.1 behavior
- [ ] release streaming search before adding multiple-file semantics

## v0.3.0: Multiple Files

- [ ] accept multiple explicit file paths
- [ ] define deterministic filename/line output and count aggregation
- [ ] preserve streaming bounds independently for each file

## Later Evidence-Gated Follow-ups

- directory traversal after explicit multiple-file CLI ergonomics are validated
- case-insensitive search after Unicode case-folding semantics are decided
- regex only after a proven user need and an engine/library decision gate
