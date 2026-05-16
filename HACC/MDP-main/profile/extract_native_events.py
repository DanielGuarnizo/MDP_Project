#!/usr/bin/env python3

import argparse
import csv
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation, getcontext
from pathlib import Path


getcontext().prec = 50
NS_PER_MS = Decimal("1000000")
TRACE_SECTIONS = {"HEADER", "STRUCTURE", "MAPPING", "EVENTS", "DEPENDENCIES"}


@dataclass(frozen=True)
class NativeEvent:
    event_id: int
    parent_id: int
    timestamp_ms: Decimal
    row_id: str
    trace_type: str
    name_id: str
    event_name: str


def resolve_input_path(path_str: str | None) -> Path:
    if path_str is None:
        return Path(__file__).resolve().parent / "native_trace.csv"

    path = Path(path_str).expanduser().resolve()
    if path.is_dir():
        return path / "native_trace.csv"
    return path


def default_output_path(input_path: Path) -> Path:
    return input_path.with_name("native_trace_events.csv")


def decimal_to_string(value: Decimal) -> str:
    rendered = format(value, "f")
    if "." in rendered:
        rendered = rendered.rstrip("0").rstrip(".")
    return rendered or "0"


def parse_event_row(row: list[str], mapping: dict[str, str]) -> NativeEvent | None:
    if len(row) < 6:
        return None

    try:
        event_id = int(row[0].strip())
        parent_id = int(row[1].strip())
        timestamp_ms = Decimal(row[2].strip())
    except (ValueError, InvalidOperation):
        return None

    row_id = row[3].strip()
    trace_type = row[4].strip()
    name_id = row[5].strip()
    event_name = mapping.get(name_id, name_id)

    return NativeEvent(
        event_id=event_id,
        parent_id=parent_id,
        timestamp_ms=timestamp_ms,
        row_id=row_id,
        trace_type=trace_type,
        name_id=name_id,
        event_name=event_name,
    )


def parse_trace(path: Path) -> list[dict[str, object]]:
    mapping: dict[str, str] = {}
    pending: dict[int, NativeEvent] = {}
    rows: list[dict[str, object]] = []
    section: str | None = None

    with path.open(newline="") as handle:
        reader = csv.reader(handle)
        for row in reader:
            if not row:
                continue

            label = row[0].strip()
            if label in TRACE_SECTIONS:
                section = label
                continue

            if section == "MAPPING":
                if len(row) >= 2:
                    mapping[row[0].strip()] = row[1].strip()
                continue

            if section != "EVENTS":
                continue

            event = parse_event_row(row, mapping)
            if event is None:
                continue

            if event.parent_id == 0:
                pending[event.event_id] = event
                continue

            start = pending.get(event.parent_id)
            if start is None:
                continue

            if (
                start.name_id != event.name_id
                or start.trace_type != event.trace_type
                or start.row_id != event.row_id
            ):
                continue

            start_ns = start.timestamp_ms * NS_PER_MS
            end_ns = event.timestamp_ms * NS_PER_MS
            rows.append(
                {
                    "event_name": start.event_name,
                    "start_event_id": start.event_id,
                    "end_event_id": event.event_id,
                    "start_ns": decimal_to_string(start_ns),
                    "end_ns": decimal_to_string(end_ns),
                    "total_time_ns": decimal_to_string(end_ns - start_ns),
                }
            )
            pending.pop(event.parent_id, None)

    rows.sort(
        key=lambda row: (
            Decimal(str(row["start_ns"])),
            Decimal(str(row["end_ns"])),
            row["start_event_id"],
        )
    )
    return rows


def write_events_csv(path: Path, rows: list[dict[str, object]]) -> None:
    fieldnames = [
        "event_name",
        "start_ns",
        "end_ns",
        "total_time_ns",
        "start_event_id",
        "end_event_id",
    ]
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Extract paired host-side API events from an XRT native_trace.csv."
    )
    parser.add_argument(
        "input",
        nargs="?",
        help="Path to native_trace.csv or to the directory that contains it.",
    )
    parser.add_argument(
        "-o",
        "--output",
        help="Output CSV path. Default: native_trace_events.csv next to the input trace.",
    )
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    input_path = resolve_input_path(args.input)
    if not input_path.is_file():
        raise SystemExit(f"Input trace not found: {input_path}")

    rows = parse_trace(input_path)
    if not rows:
        raise SystemExit(f"No paired native events found in {input_path}.")

    output_path = Path(args.output).expanduser().resolve() if args.output else default_output_path(input_path)
    write_events_csv(output_path, rows)

    print(f"Input: {input_path}")
    print(f"Output: {output_path}")
    print(f"Paired events: {len(rows)}")


if __name__ == "__main__":
    main()
