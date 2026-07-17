# v0.2.0 Streaming I/O

상태: next

## Goal

Replace whole-file loading with incremental UTF-8 line processing before expanding search to
multiple files.

## Acceptance

- measure current time and peak memory at deterministic 1, 10 and 100 MiB inputs
- define the smallest additive Mallang standard I/O contract needed by an external consumer
- publish the Mallang compiler/runtime version that provides the streaming API
- preserve literal matching, line numbering, Unicode behavior and exit classes
- prove bounded peak memory as input size grows
- keep the whole-file implementation out of the default runtime path

## Sequence Boundary

Multiple-file search starts only after this milestone is released as `v0.2.0`. It is planned as
the `v0.3.0` milestone so file-prefix output and aggregate exit semantics are designed on top of
the streaming implementation rather than the current whole-file model.
