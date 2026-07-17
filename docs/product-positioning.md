# Product Positioning

## Current Role

`mlgrep` is Mallang's first separately versioned external reference application.
Its job through v0.3.0 is to exercise and publish evidence for:

- read-only borrows and mutable accumulators across a generic streaming callback
- deterministic `Result`-based filesystem and process I/O behavior
- bounded-memory processing across multiple sequential inputs
- native cross-platform archives, checksums and clean installation

This validates Mallang as an application language. It does not create a reason
for general users to replace mature tools such as `grep` or `ripgrep`.

## v0.3 Boundary

Multiple explicit files complete the grep-shaped reference workload. After
v0.3.0, commodity grep features are not added merely to grow a checklist.
Performance claims against other tools require a reproducible benchmark and a
user-relevant advantage; none is currently claimed.

## Evidence-Gated Product Direction

A future product pivot should exploit Mallang's combination of Go-like surface
syntax, ownership-checked native execution and functional composition. The
leading hypothesis is a typed streaming tool for structured and multiline logs:

- JSONL field predicates and typed extraction
- stack-trace or event-boundary matching rather than isolated physical lines
- `filter`, `map` and aggregate pipelines compiled from Mallang modules
- deterministic text or machine-readable output without a VM dependency

That direction requires its own user problem, CLI contract and milestone before
implementation. Until then, `mlgrep` remains a reference implementation rather
than a differentiated grep replacement.
