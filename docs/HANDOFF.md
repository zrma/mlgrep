# mlgrep Handoff

## Start Here

1. Read `AGENTS.md` and `docs/agent-harness.md`.
2. Check `jj status`, `docs/status.md`, `docs/roadmap.md` and active `docs/todo-*.md`.
3. Read `docs/mallang-v1-findings.md` before changing I/O or string ownership boundaries.
4. Run `scripts/check.sh` before closing an implementation slice.

## Product Contract

- Input: one UTF-8 file and one literal UTF-8 pattern.
- Default output: matching lines as 1-based `line:content` records.
- `--count`: match count only, without constructing rendered line output.
- Exit status: match `0`, no-match `1`, usage or I/O failure `2`.
- v0.1 exclusions: regex, case folding, binary input, recursive directory search and streaming I/O.

## Toolchain

- Required compiler: `mlg 1.0.0` from the public Mallang stable release.
- Required native backend: `clang` available to `mlg build` and `mlg test`.
- Canonical local gate: `scripts/check.sh`.
- Canonical release gate: `scripts/check-release.sh`.

## Durable Boundaries

- Do not depend on a Mallang compiler checkout or unpublished language behavior.
- Treat whole-file reads as the current standard-library boundary, not as a claim of streaming scalability.
- Record concrete language/tooling friction in status/roadmap before proposing a compiler change.
- Close v0.2.0 streaming I/O before starting v0.3.0 multiple-file semantics.
- Public push, tag, release or visibility mutation remains an explicit external-write boundary.
