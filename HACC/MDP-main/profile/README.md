# Panda Profiling Guide

## Shared `xrt.ini` for `hw` and `hw_emu`

The repository provides a single shared `xrt.ini` in [xrt.ini](/home/pietrobenecchi/MDP/profile/xrt.ini) that can also be used to collect profiling data in real hardware runs (`hw`).

The same file also contains emulation-specific options under the `[Emulation]` section. If you use this `xrt.ini` during `hw_emu`, XRT may print warnings saying that some flags are disabled or ignored. This is expected and does not generate functional problems for the run or for the produced profiling data.

In `hw_emu`, HBM timing data cannot be generated directly. However, you can still recover the timing of the `m_axi` transactions from the waveform by launching `vitis_analyzer xrt.run_summary` in the same directory where you ran the program. You can inspect this information under the `Waveform` section.

## Open the profiling GUI

To inspect the profiling results with the Xilinx GUI, open the run summary from the hardware profile directory:

```bash
cd profile/profile_hw_v1
vitis_analyzer xrt.run_summary
```

This opens the standard Vitis Analyzer view for the run stored in `profile_hw_v1`.

## Python utilities

### `extract_native_events.py`

This script reads `native_trace.csv` and extracts paired host-side XRT API events.

Generated CSV:

- `native_trace_events.csv`

By default, the output file is written in the same directory as the input trace.

### `extract_hbm_events.py`

This script reads `device_trace_0.csv` and extracts paired kernel memory transactions on HBM, split into read/write events.

Generated CSV:

- `device_trace_events.csv`

By default, the output file is written in the same directory as the input trace.

## CSV files to inspect

The generated CSV files are placed next to the source trace files:

- `native_trace_events.csv`
- `device_trace_events.csv`

Examples in this repository:

- `profile/profile_hw_emu_v1/native_trace_events.csv`
- `profile/profile_hw_v1/native_trace_events.csv`
- `profile/profile_hw_v1/device_trace_events.csv`
- `profile/profile_hw_v2/native_trace_events.csv`
- `profile/profile_hw_v2/device_trace_events.csv`
- `profile/profile_hw_v3/native_trace_events.csv`
- `profile/profile_hw_v3/device_trace_events.csv`

They can be opened with any CSV viewer, spreadsheet tool, or a text editor.

## CSV format

### Native host events

`native_trace_events.csv` contains one row for each matched host API event pair, with these fields:

- `event_name`: XRT API name
- `start_ns`: start timestamp in nanoseconds
- `end_ns`: end timestamp in nanoseconds
- `total_time_ns`: event duration in nanoseconds
- `start_event_id`: event ID of the opening record
- `end_event_id`: event ID of the closing record

### HBM device events

`device_trace_events.csv` contains one row for each matched HBM transaction, with these fields:

- `transaction_name`: `read` or `write`
- `hbm`: HBM bank name, for example `HBM[0]`
- `arg`: kernel argument associated with the transfer, if available
- `bundle`: memory bundle label extracted from the trace
- `start_ns`: start timestamp in nanoseconds
- `end_ns`: end timestamp in nanoseconds
- `total_time_ns`: transaction duration in nanoseconds
- `start_event_id`: event ID of the opening record
- `end_event_id`: event ID of the closing record

Optional extra fields when using `--with-colors`:

- `color`: hex background color
- `text_color`: recommended text color for readability

