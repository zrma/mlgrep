# v0.3.0 Multiple Files

상태: complete; released as v0.3.0 on 2026-07-17

## Goal

Process multiple explicit files deterministically while retaining the v0.2.0
single-file interface and bounded-memory streaming implementation.

## CLI Contract

- `mlgrep <pattern> <file> [file...]` accepts one or more explicit paths.
- Files are opened and processed one at a time in command-line order.
- A single file preserves v0.2.0 output: `<line>:<content>` or a bare count.
- Multiple files render `<path>:<line>:<content>` by default.
- Multiple-file count mode renders `<path>:<count>` for every operand, including
  zero-count and duplicate operands, in command-line order.
- Paths are emitted verbatim. The colon-delimited output is human-oriented, not
  an escaped record format.

## Exit And Error Contract

- Exit `0` when any processed file contains a match.
- Exit `1` when all files are processed successfully and none contains a match.
- Exit `2` on the first usage, read or output error; processing stops immediately.
- Output completed before a later error remains observable.
- Single-file read errors retain `mlgrep: read failed: <Kind>`.
- Multiple-file read errors include the failed operand:
  `mlgrep: read <path> failed: <Kind>`.

## Acceptance Criteria

- [x] preserve exact v0.2.0 single-file output, count and exit behavior
- [x] cover ordered matches, ordered per-file counts and duplicate operands
- [x] cover aggregate match/no-match status and first-error short-circuiting
- [x] prove bounded peak memory when large files are processed sequentially
- [x] publish signed v0.3.0 archives, checksums and installer

## Deferred

Directory traversal, glob expansion, stdin, parallel search, filename escaping,
regex and case folding remain outside v0.3.0.

Product positioning and the post-v0.3 evidence gate are defined in
`docs/product-positioning.md`.
