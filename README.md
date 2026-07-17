# mlgrep

`mlgrep` is a small native streaming literal text-search CLI written in Mallang v1. Its primary
role is to be an external reference implementation for the Mallang stable toolchain.

## Why It Exists

`mlgrep` proves that a separately versioned Mallang application can combine borrowed input,
mutable streaming state, `Result`-based I/O and native distribution without retaining whole files.
It is not presented as a faster or more capable replacement for `grep` or `ripgrep`.

Version 0.3 is the planned boundary for the grep-shaped reference workload. Further product work
requires a separate evidence-backed problem, such as typed structured or multiline log pipelines,
rather than continuing a feature-for-feature grep clone. See
[docs/product-positioning.md](docs/product-positioning.md).

## Usage

```sh
mlgrep <pattern> <file> [file...]
mlgrep --count <pattern> <file> [file...]
mlgrep --version
```

Default output uses 1-based line numbers:

```text
2:2026-07-17 ERROR database timeout
4:2026-07-17 ERROR retry exhausted
```

Multiple files are processed in command-line order and include their path:

```text
api.log:2:2026-07-17 ERROR database timeout
worker.log:4:2026-07-17 ERROR retry exhausted
```

Exit status is `0` when at least one line matches, `1` when no line matches and `2` for usage or
I/O failure. Search is an exact UTF-8 substring match. Files are processed one at a time with
memory bounded by the longest line instead of total input size. Multiple-file count mode emits one
`path:count` record per operand. Regex, case folding, binary files, stdin and directory walking are
outside v0.3.

## Build And Test

Install Mallang v1.1.0 and ensure `clang` is available, then run:

```sh
scripts/check.sh
```

The gate uses the installed compiler for format, check, test and native build, verifies CLI output
and exit classes, searches a deterministic 100,000-line fixture, and checks peak RSS on 1, 10, 100
and sequential 200 MiB aggregate deterministic workloads.

## Install

The supported binary targets are macOS arm64 and Linux x86_64:

```sh
curl -fsSLO https://github.com/zrma/mlgrep/releases/download/v0.2.0/install.sh
sh install.sh --version 0.2.0
```

The installer verifies the matching archive against `SHA256SUMS` before atomically replacing
`$HOME/.local/bin/mlgrep`. Release maintainers run `scripts/check-release.sh` before publishing.

## License

Licensed under either the MIT License or Apache License 2.0, at your option.

## Security

Report suspected vulnerabilities through the private process in [SECURITY.md](SECURITY.md), not a public issue.
