#!/usr/bin/env python3

import argparse
import csv
import hashlib
import re
from decimal import Decimal, getcontext
from pathlib import Path


EVENT_TYPES = {
    "KERNEL_READ": "read",
    "KERNEL_WRITE": "write",
}

getcontext().prec = 50
NS_PER_MS = Decimal("1000000")

HBM_RE = re.compile(r"(HBM\[\d+\])")
ARG_RE = re.compile(r"\(([^()]*)\)")


def parse_bundle(bundle_name: str) -> tuple[str, str]:
    hbm_match = HBM_RE.search(bundle_name)
    arg_match = ARG_RE.search(bundle_name)

    hbm = hbm_match.group(1) if hbm_match else ""
    if arg_match:
        arg_name = arg_match.group(1)
    else:
        prefix = bundle_name.split("-", 1)[0]
        arg_name = prefix.removeprefix("m_axi_gmem")

    if "|" in arg_name:
        arg_name = "NA"

    return hbm, arg_name


def normalize_bundle(bundle_name: str) -> str:
    normalized = ARG_RE.sub("", bundle_name).strip()
    if "m_axi_gmem-HBM[" in normalized:
        return "NA"
    return normalized or "NA"


def resolve_input_path(path_str: str | None) -> Path:
    if path_str is None:
        return Path(__file__).resolve().parent / "device_trace_0.csv"

    path = Path(path_str).expanduser().resolve()
    if path.is_dir():
        return path / "device_trace_0.csv"
    return path


def default_output_path(input_path: Path) -> Path:
    return input_path.with_name("device_trace_events.csv")


def decimal_to_string(value: Decimal) -> str:
    rendered = format(value, "f")
    if "." in rendered:
        rendered = rendered.rstrip("0").rstrip(".")
    return rendered or "0"


def hsl_to_rgb(hue: float, saturation: float, lightness: float) -> tuple[int, int, int]:
    chroma = (1 - abs(2 * lightness - 1)) * saturation
    hue_segment = hue / 60
    secondary = chroma * (1 - abs(hue_segment % 2 - 1))
    red = green = blue = 0.0

    if 0 <= hue_segment < 1:
        red, green = chroma, secondary
    elif 1 <= hue_segment < 2:
        red, green = secondary, chroma
    elif 2 <= hue_segment < 3:
        green, blue = chroma, secondary
    elif 3 <= hue_segment < 4:
        green, blue = secondary, chroma
    elif 4 <= hue_segment < 5:
        red, blue = secondary, chroma
    else:
        red, blue = chroma, secondary

    match = lightness - chroma / 2
    return (
        round((red + match) * 255),
        round((green + match) * 255),
        round((blue + match) * 255),
    )


def rgb_to_hex(red: int, green: int, blue: int) -> str:
    return f"#{red:02X}{green:02X}{blue:02X}"


def relative_luminance(red: int, green: int, blue: int) -> float:
    def convert(channel: int) -> float:
        value = channel / 255
        if value <= 0.03928:
            return value / 12.92
        return ((value + 0.055) / 1.055) ** 2.4

    return (
        0.2126 * convert(red)
        + 0.7152 * convert(green)
        + 0.0722 * convert(blue)
    )


def text_color_for_background(red: int, green: int, blue: int) -> str:
    return "#000000" if relative_luminance(red, green, blue) > 0.45 else "#FFFFFF"


def color_for_row(row: dict[str, object]) -> tuple[str, str]:
    key = "|".join(
        str(row[column])
        for column in ("transaction_name", "hbm", "arg", "bundle")
    )
    digest = hashlib.md5(key.encode("utf-8")).digest()
    hue = (int.from_bytes(digest[:2], "big") / 65535) * 360
    saturation = 0.55 + (digest[2] / 255) * 0.15
    lightness = 0.45 + (digest[3] / 255) * 0.10
    red, green, blue = hsl_to_rgb(hue, saturation, lightness)
    return rgb_to_hex(red, green, blue), text_color_for_background(red, green, blue)


def parse_trace(path: Path) -> list[dict[str, object]]:
    row_info: dict[str, dict[str, str]] = {}
    mapping: dict[str, str] = {}
    pending: dict[int, dict[str, object]] = {}
    extracted: list[dict[str, object]] = []
    section = None
    current_bundle = ""

    with path.open(newline="") as handle:
        reader = csv.reader(handle)
        for row in reader:
            if not row:
                continue

            label = row[0].strip()
            if label in {"HEADER", "STRUCTURE", "MAPPING", "EVENTS", "DEPENDENCIES"}:
                section = label
                continue

            if section == "STRUCTURE":
                if label == "Group_Start" and len(row) >= 2 and row[1].startswith("m_axi_"):
                    current_bundle = row[1].strip()
                elif label == "Group_End" and len(row) >= 2 and row[1].startswith("m_axi_"):
                    current_bundle = ""
                elif label == "Static_Row" and len(row) >= 3:
                    row_id = row[1].strip()
                    hbm_name, arg_name = parse_bundle(current_bundle)
                    row_info[row_id] = {
                        "bundle": normalize_bundle(current_bundle),
                        "hbm": hbm_name,
                        "arg": arg_name,
                        "channel": row[2].strip(),
                    }
                continue

            if section == "MAPPING":
                if len(row) >= 2:
                    mapping[row[0].strip()] = row[1].strip()
                continue

            if section != "EVENTS" or len(row) < 6:
                continue

            event_type = row[4].strip()
            operation = EVENT_TYPES.get(event_type)
            if operation is None:
                continue

            try:
                event_id = int(row[0].strip())
                parent_id = int(row[1].strip())
                timestamp_ms = Decimal(row[2].strip())
            except ValueError:
                continue

            row_id = row[3].strip()
            info = row_info.get(row_id, {})

            event_hbm = ""
            for item in row[5:]:
                mapped = mapping.get(item.strip(), item.strip())
                if HBM_RE.fullmatch(mapped):
                    event_hbm = mapped
                    break

            if parent_id == 0:
                pending[event_id] = {
                    "operation": operation,
                    "start_event_id": event_id,
                    "start_ms": timestamp_ms,
                    "row_id": row_id,
                    "bundle": info.get("bundle", ""),
                    "hbm": event_hbm or info.get("hbm", ""),
                    "arg": info.get("arg", ""),
                }
                continue

            start = pending.get(parent_id)
            if not start or start["operation"] != operation:
                continue

            start_ns = start["start_ms"] * NS_PER_MS
            end_ns = timestamp_ms * NS_PER_MS
            extracted.append(
                {
                    "transaction_name": start["operation"],
                    "hbm": start["hbm"],
                    "arg": start["arg"],
                    "bundle": start["bundle"],
                    "start_ns": decimal_to_string(start_ns),
                    "end_ns": decimal_to_string(end_ns),
                    "total_time_ns": decimal_to_string(end_ns - start_ns),
                    "start_event_id": start["start_event_id"],
                    "end_event_id": event_id,
                }
            )

    extracted.sort(
        key=lambda row: (
            Decimal(str(row["start_ns"])),
            Decimal(str(row["end_ns"])),
            row["start_event_id"],
        )
    )
    return extracted


def write_events_csv(path: Path, rows: list[dict[str, object]], with_colors: bool = False) -> None:
    fieldnames = [
        "transaction_name",
        "hbm",
        "arg",
        "bundle",
        "start_ns",
        "end_ns",
        "total_time_ns",
        "start_event_id",
        "end_event_id",
    ]
    if with_colors:
        fieldnames.extend(["color", "text_color"])

    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        if with_colors:
            colored_rows = []
            for row in rows:
                colored_row = dict(row)
                color, text_color = color_for_row(row)
                colored_row["color"] = color
                colored_row["text_color"] = text_color
                colored_rows.append(colored_row)
            writer.writerows(colored_rows)
        else:
            writer.writerows(rows)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Extract paired read/write HBM events from an XRT device_trace_0.csv."
    )
    parser.add_argument(
        "input",
        nargs="?",
        help="Path to device_trace_0.csv or to the directory that contains it.",
    )
    parser.add_argument(
        "-o",
        "--output",
        help="Output CSV path. Default: device_trace_events.csv next to the input trace.",
    )
    parser.add_argument(
        "--with-colors",
        action="store_true",
        help="Add stable color columns (color, text_color) to the output CSV.",
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
        raise SystemExit(f"No paired read/write HBM events found in {input_path}.")

    output_path = Path(args.output).expanduser().resolve() if args.output else default_output_path(input_path)
    write_events_csv(output_path, rows, with_colors=args.with_colors)

    print(f"Input: {input_path}")
    print(f"Output: {output_path}")
    print(f"Paired events: {len(rows)}")


if __name__ == "__main__":
    main()
