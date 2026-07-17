#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import platform
import re
import statistics
import subprocess
import sys
import time
from pathlib import Path


MIB = 1024 * 1024
LINE_BYTES = 128
SIZES_MIB = (1, 10, 100)
REPEATS = 3
MAX_RSS_BYTES = 32 * MIB
MAX_RSS_GROWTH_BYTES = 16 * MIB


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Measure mlgrep wall time and peak RSS on deterministic inputs."
    )
    parser.add_argument("--binary", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--enforce-bounded", action="store_true")
    return parser.parse_args()


def write_fixture(path: Path, size_mib: int) -> int:
    line_count = size_mib * MIB // LINE_BYTES
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb") as output:
        block: list[bytes] = []
        for line_number in range(1, line_count + 1):
            marker = b"ERROR " if line_number % 1000 == 0 else b"INFO "
            block.append(marker + b"x" * (LINE_BYTES - len(marker) - 1) + b"\n")
            if len(block) == 10_000:
                output.write(b"".join(block))
                block.clear()
        if block:
            output.write(b"".join(block))
    if path.stat().st_size != size_mib * MIB:
        raise RuntimeError(f"fixture size mismatch: {path}")
    return line_count // 1000


def parse_rss(stderr: str) -> int:
    if sys.platform == "darwin":
        match = re.search(r"^\s*(\d+)\s+maximum resident set size$", stderr, re.MULTILINE)
        multiplier = 1
    else:
        match = re.search(r"Maximum resident set size \(kbytes\):\s*(\d+)", stderr)
        multiplier = 1024
    if match is None:
        raise RuntimeError(f"could not parse peak RSS from /usr/bin/time output:\n{stderr}")
    return int(match.group(1)) * multiplier


def measure(binary: Path, fixture: Path, expected_count: int) -> tuple[float, int]:
    time_args = ["/usr/bin/time", "-lp"] if sys.platform == "darwin" else ["/usr/bin/time", "-v"]
    started = time.perf_counter()
    completed = subprocess.run(
        [*time_args, str(binary), "--count", "ERROR", str(fixture)],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    elapsed = time.perf_counter() - started
    if completed.returncode != 0:
        raise RuntimeError(
            f"search failed for {fixture}: exit={completed.returncode}\n{completed.stderr}"
        )
    if completed.stdout != f"{expected_count}\n":
        raise RuntimeError(f"count mismatch for {fixture}: {completed.stdout!r}")
    return elapsed, parse_rss(completed.stderr)


def main() -> int:
    args = parse_args()
    binary = args.binary.resolve()
    if not binary.is_file():
        raise RuntimeError(f"binary does not exist: {binary}")

    fixture_root = args.output.parent / "streaming-memory-inputs"
    measurements: list[dict[str, object]] = []
    for size_mib in SIZES_MIB:
        fixture = fixture_root / f"{size_mib}mib.log"
        expected_count = write_fixture(fixture, size_mib)
        samples = [measure(binary, fixture, expected_count) for _ in range(REPEATS)]
        elapsed_samples = [sample[0] for sample in samples]
        rss_samples = [sample[1] for sample in samples]
        measurements.append(
            {
                "input_mib": size_mib,
                "line_bytes": LINE_BYTES,
                "repeats": REPEATS,
                "median_seconds": round(statistics.median(elapsed_samples), 6),
                "median_peak_rss_bytes": int(statistics.median(rss_samples)),
                "max_peak_rss_bytes": max(rss_samples),
            }
        )

    peak_values = [int(item["max_peak_rss_bytes"]) for item in measurements]
    rss_growth = max(peak_values) - min(peak_values)
    result = {
        "schema": "mlgrep.streaming-memory.v1",
        "platform": platform.system().lower(),
        "architecture": platform.machine(),
        "measurements": measurements,
        "bounded_check": {
            "max_peak_rss_bytes": max(peak_values),
            "rss_growth_bytes": rss_growth,
            "max_allowed_peak_rss_bytes": MAX_RSS_BYTES,
            "max_allowed_growth_bytes": MAX_RSS_GROWTH_BYTES,
        },
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")

    if args.enforce_bounded:
        if max(peak_values) > MAX_RSS_BYTES:
            raise RuntimeError("streaming peak RSS exceeded 32 MiB")
        if rss_growth > MAX_RSS_GROWTH_BYTES:
            raise RuntimeError("streaming peak RSS grew by more than 16 MiB")

    for item in measurements:
        rss_mib = int(item["median_peak_rss_bytes"]) / MIB
        print(
            f"streaming memory: input={item['input_mib']} MiB "
            f"median={item['median_seconds']:.6f}s rss={rss_mib:.2f} MiB"
        )
    print(f"streaming bounded-memory check passed: rss_growth={rss_growth / MIB:.2f} MiB")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as error:
        print(f"streaming memory check failed: {error}", file=sys.stderr)
        raise SystemExit(1)
