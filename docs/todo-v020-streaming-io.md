# v0.2.0 Streaming I/O

상태: complete; released as v0.2.0 on 2026-07-17

## Goal

Replace whole-file loading with incremental UTF-8 line processing before expanding search to
multiple files.

## Acceptance

- [x] measure current time and peak memory at deterministic 1, 10 and 100 MiB inputs
- [x] define the smallest additive Mallang standard I/O contract needed by an external consumer
- [x] publish the Mallang compiler/runtime version that provides the streaming API
- [x] preserve literal matching, line numbering, Unicode behavior and exit classes
- [x] prove bounded peak memory as input size grows
- [x] keep the whole-file implementation out of the default runtime path
- [x] publish signed v0.2.0 archives, checksums and installer

## Sequence Boundary

Multiple-file search starts only after this milestone is released as `v0.2.0`. It is planned as
the `v0.3.0` milestone so file-prefix output and aggregate exit semantics are designed on top of
the streaming implementation rather than the current whole-file model.

## Evidence

- Canonical gate: `scripts/check.sh`
- Memory gate: `scripts/measure-streaming-memory.py --binary target/mlgrep --output
  target/streaming-memory.json --enforce-bounded`
- Baseline and current observations: `docs/performance/v0.2-streaming-memory.md`
- Compiler dependency: published Mallang `mlg 1.1.0`
