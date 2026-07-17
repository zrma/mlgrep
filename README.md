# mlgrep

`mlgrep` is a small native literal text-search CLI written in Mallang v1. It is both a useful log
inspection tool and an external dogfood project for the Mallang stable toolchain.

## Usage

```sh
mlgrep <pattern> <file>
mlgrep --count <pattern> <file>
mlgrep --version
```

Default output uses 1-based line numbers:

```text
2:2026-07-17 ERROR database timeout
4:2026-07-17 ERROR retry exhausted
```

Exit status is `0` when at least one line matches, `1` when no line matches and `2` for usage or
I/O failure. Search is an exact UTF-8 substring match. Regex, case folding, binary files, directory
walking and streaming I/O are intentionally outside v0.1.

## Build And Test

Install Mallang v1.0.0 and ensure `clang` is available, then run:

```sh
scripts/check.sh
```

The gate uses the installed compiler for format, check, test and native build, verifies CLI output
and exit classes, and searches a deterministic 100,000-line fixture.

## Install

The supported binary targets are macOS arm64 and Linux x86_64:

```sh
curl -fsSLO https://github.com/zrma/mlgrep/releases/download/v0.1.0/install.sh
sh install.sh --version 0.1.0
```

The installer verifies the matching archive against `SHA256SUMS` before atomically replacing
`$HOME/.local/bin/mlgrep`. Release maintainers run `scripts/check-release.sh` before publishing.

## License

Licensed under either the MIT License or Apache License 2.0, at your option.

## Security

Report suspected vulnerabilities through the private process in [SECURITY.md](SECURITY.md), not a public issue.
