# Status

상태: v0.2.0 streaming implementation complete; release pending

- Public `mlg 1.1.0` format, check, 5 focused unit tests and native build are green.
- CLI fixtures cover literal/Unicode output, count mode and exit classes `0/1/2`.
- The default path uses `fs.forEachLine`; no whole-file read or split remains in runtime search.
- Deterministic 1/10/100 MiB measurements keep peak RSS near 1.3 MiB on the recorded macOS arm64
  run, and the cross-platform gate enforces conservative peak and growth ceilings.
- External-consumer findings are recorded in `docs/mallang-v1-findings.md`.
- Publication target is a public GitHub repository; remote state and CI are verified after each push.
- The next boundary is the v0.2.0 binary release; multiple-file search follows in v0.3.0.
- Signed `v0.1.0` archives, checksums and installer are published for macOS arm64 and Linux x86_64.
