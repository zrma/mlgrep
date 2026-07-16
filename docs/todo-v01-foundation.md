# v0.1 Literal Search Foundation

상태: complete

## Goal

Prove Mallang v1 as an external native CLI toolchain through a useful literal log search workflow.

## Acceptance

- [x] `mlg 1.0.0` format, check, test and native build
- [x] default and `--count` output fixtures
- [x] exit 0/1/2 behavior
- [x] no-match, Unicode and empty-pattern unit coverage
- [x] deterministic 100,000-line count smoke
- [x] harness and publication boundary checks
- [x] focused diff review and attributed local `jj` change

## Out Of Scope

- Mallang compiler changes
- regex, recursive traversal, binary input and streaming I/O
- remote creation, push, tag or release without explicit approval
