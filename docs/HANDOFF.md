# mlgrep Handoff

## Start Here

1. Read `AGENTS.md` and `docs/agent-harness.md`.
2. Check `jj status`, `docs/status.md`, `docs/roadmap.md` and active `docs/todo-*.md`.
3. Read `docs/mallang-v1-findings.md` before changing I/O or string ownership boundaries.
4. Run `scripts/check.sh` before closing an implementation slice.

## Product Contract

- Input: one literal UTF-8 pattern and one or more explicit UTF-8 file paths.
- Default output: single-file `line:content`; multiple-file `path:line:content`.
- `--count`: single-file bare count; multiple-file ordered `path:count` records.
- Exit status: any match `0`, aggregate no-match `1`, usage or first I/O failure `2`.
- v0.3 exclusions: regex, case folding, binary input, stdin and recursive directory search.

## Toolchain

- Required compiler: `mlg 1.1.0` from the public Mallang stable release.
- Required native backend: `clang` available to `mlg build` and `mlg test`.
- Canonical local gate: `scripts/check.sh`.
- Canonical release gate: `scripts/check-release.sh`.

## Durable Boundaries

- Do not depend on a Mallang compiler checkout or unpublished language behavior.
- Keep `fs.forEachLine` as the default runtime path and retain bounded-memory evidence.
- Record concrete language/tooling friction in status/roadmap before proposing a compiler change.
- v0.3.0 multiple-file streaming is released and closes the grep-shaped reference workload.
- Treat v0.3.0 as the grep-shaped reference boundary defined in `docs/product-positioning.md`.
- Public push, tag, release or visibility mutation remains an explicit external-write boundary.
