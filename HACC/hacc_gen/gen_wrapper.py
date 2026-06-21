from .models import Interface, _port_str


def gen_wrapper_v(iface: Interface, hw_profile: bool = False) -> str:
    static_ports = [
        "  input  ap_clk",
        "  input  ap_rst_n",
        "  output ap_done",
        "  output ap_ready",
        "  input  cache_reset",
        "  input  s_axi_control_AWVALID",
        "  input  [7:0] s_axi_control_AWADDR",
        "  input  s_axi_control_WVALID",
        "  input  [31:0] s_axi_control_WDATA",
        "  input  [3:0] s_axi_control_WSTRB",
        "  input  s_axi_control_BREADY",
        "  input  s_axi_control_ARVALID",
        "  input  [7:0] s_axi_control_ARADDR",
        "  input  s_axi_control_RREADY",
        "  output s_axi_control_AWREADY",
        "  output s_axi_control_WREADY",
        "  output [1:0] s_axi_control_BRESP",
        "  output s_axi_control_BVALID",
        "  output s_axi_control_ARREADY",
        "  output [31:0] s_axi_control_RDATA",
        "  output [1:0] s_axi_control_RRESP",
        "  output s_axi_control_RVALID",
    ]
    axi_port_strs = [_port_str(p.direction, p.width, p.name) for p in iface.axi_ports]
    port_block = ",\n".join(static_ports + axi_port_strs)

    scalar_wire_block = "\n".join(
        f"  wire [31:0] {arg};" for arg in iface.scalar_args
    )
    # Last port has no trailing comma (Verilog requires no comma before ')' )
    translator_args = [f"    .{arg}({arg})" for arg in iface.scalar_args]
    translator_arg_conns = ",\n".join(translator_args)
    core_scalar_block = "\n".join(
        f"    .{arg}({arg})," for arg in iface.scalar_args
    )
    core_axi_list = [f"    .{p.name}({p.name})" for p in iface.axi_ports]
    core_axi_block = ",\n".join(core_axi_list)

    # ── AXI latency performance counter Verilog (N-bundle aggregate) ──────────
    counter_block = ""
    translator_counter_conns = ""
    translator_counter_sep = ""

    if hw_profile:
        bundles = iface.axi_bundles
        N = len(bundles)

        outstanding_decls = "\n".join(
            f"  reg [3:0] rd_outstanding_{i};\n"
            f"  reg [3:0] wr_outstanding_{i};"
            for i in range(N)
        )
        rd_or = " | ".join(f"(rd_outstanding_{i} != 4'd0)" for i in range(N))
        wr_or = " | ".join(f"(wr_outstanding_{i} != 4'd0)" for i in range(N))
        busy_wires = (
            f"  wire rd_any_outstanding = {rd_or};\n"
            f"  wire wr_any_outstanding = {wr_or};"
        )
        per_bundle_blocks = []
        for i, b in enumerate(bundles):
            per_bundle_blocks.append(
                f"  always @(posedge ap_clk) begin\n"
                f"    if (!ap_rst_n || start_port_pulse) rd_outstanding_{i} <= 4'd0;\n"
                f"    else if (({b}_arvalid && {b}_arready) && !({b}_rlast && {b}_rvalid && {b}_rready))\n"
                f"      rd_outstanding_{i} <= (rd_outstanding_{i} < 4'd15) ? rd_outstanding_{i} + 4'd1 : 4'd15;\n"
                f"    else if (!({b}_arvalid && {b}_arready) && ({b}_rlast && {b}_rvalid && {b}_rready))\n"
                f"      rd_outstanding_{i} <= (rd_outstanding_{i} > 4'd0) ? rd_outstanding_{i} - 4'd1 : 4'd0;\n"
                f"  end\n"
                f"  always @(posedge ap_clk) begin\n"
                f"    if (!ap_rst_n || start_port_pulse) wr_outstanding_{i} <= 4'd0;\n"
                f"    else if (({b}_awvalid && {b}_awready) && !({b}_bvalid && {b}_bready))\n"
                f"      wr_outstanding_{i} <= (wr_outstanding_{i} < 4'd15) ? wr_outstanding_{i} + 4'd1 : 4'd15;\n"
                f"    else if (!({b}_awvalid && {b}_awready) && ({b}_bvalid && {b}_bready))\n"
                f"      wr_outstanding_{i} <= (wr_outstanding_{i} > 4'd0) ? wr_outstanding_{i} - 4'd1 : 4'd0;\n"
                f"  end"
            )
        per_bundle_block = "\n".join(per_bundle_blocks)
        done_bits = N.bit_length()
        zero_pad  = 32 - done_bits
        rd_done_sum = "\n    + ".join(
            f"({b}_rlast & {b}_rvalid & {b}_rready)" for b in bundles
        )
        wr_done_sum = "\n    + ".join(
            f"({b}_bvalid & {b}_bready)" for b in bundles
        )
        done_wires = (
            f"  wire [{done_bits - 1}:0] rd_done_this_cycle =\n    {rd_done_sum};\n"
            f"  wire [{done_bits - 1}:0] wr_done_this_cycle =\n    {wr_done_sum};"
        )
        aggregate_block = (
            f"  reg [63:0] rd_busy_cycles;\n"
            f"  reg [63:0] wr_busy_cycles;\n"
            f"  reg [31:0] rd_txn_count;\n"
            f"  reg [31:0] wr_txn_count;\n"
            f"\n"
            f"  always @(posedge ap_clk) begin\n"
            f"    if (!ap_rst_n || start_port_pulse) rd_busy_cycles <= 64'd0;\n"
            f"    else if (rd_any_outstanding)       rd_busy_cycles <= rd_busy_cycles + 64'd1;\n"
            f"  end\n"
            f"  always @(posedge ap_clk) begin\n"
            f"    if (!ap_rst_n || start_port_pulse) wr_busy_cycles <= 64'd0;\n"
            f"    else if (wr_any_outstanding)       wr_busy_cycles <= wr_busy_cycles + 64'd1;\n"
            f"  end\n"
            f"  always @(posedge ap_clk) begin\n"
            f"    if (!ap_rst_n || start_port_pulse) rd_txn_count <= 32'd0;\n"
            f"    else rd_txn_count <= rd_txn_count + {{{zero_pad}'d0, rd_done_this_cycle}};\n"
            f"  end\n"
            f"  always @(posedge ap_clk) begin\n"
            f"    if (!ap_rst_n || start_port_pulse) wr_txn_count <= 32'd0;\n"
            f"    else wr_txn_count <= wr_txn_count + {{{zero_pad}'d0, wr_done_this_cycle}};\n"
            f"  end"
        )
        counter_block = "\n".join([
            "  // ── AXI transaction latency performance counters (N-bundle aggregate) ──",
            outstanding_decls, busy_wires, done_wires, per_bundle_block, aggregate_block,
        ])
        translator_counter_conns = (
            "    .rd_busy_cycles(rd_busy_cycles),\n"
            "    .wr_busy_cycles(wr_busy_cycles),\n"
            "    .rd_txn_count(rd_txn_count),\n"
            "    .wr_txn_count(wr_txn_count)"
        )
        translator_counter_sep = ",\n"
    # ── end counter block ───────────────────────────────────────────────────────

    return f"""\
`timescale 1ns / 1ps
// Vitis-compatible wrapper for Bambu top_level
// Kernel name: panda   (used in script_to_xo.tcl and harness.cpp)
// Generated by generate_hacc_project.py — do not edit manually
module panda (
{port_block}
);

  wire sig_done;
  wire ap_start_lvl;

{scalar_wire_block}

  // Rising-edge detector: Bambu needs a 1-cycle start_port pulse
  reg  ap_start_q;
  always @(posedge ap_clk) ap_start_q <= ap_start_lvl;
  wire start_port_pulse = ap_start_lvl & ~ap_start_q;

  // ap_ready: 1 cycle after start_port (tells XRT job was accepted)
  reg  ap_ready_r;
  always @(posedge ap_clk) ap_ready_r <= start_port_pulse;
  assign ap_ready = ap_ready_r;
  assign ap_done  = sig_done;

{counter_block}

  // AXI-Lite translator
  top_level_translator translator (
    .ap_clk(ap_clk),
    .ap_rst_n(ap_rst_n),
    .ap_done(sig_done),
    .ap_ready(start_port_pulse),
    .ap_start(ap_start_lvl),
    .s_axi_control_AWVALID(s_axi_control_AWVALID),
    .s_axi_control_AWADDR(s_axi_control_AWADDR),
    .s_axi_control_WVALID(s_axi_control_WVALID),
    .s_axi_control_WDATA(s_axi_control_WDATA),
    .s_axi_control_WSTRB(s_axi_control_WSTRB),
    .s_axi_control_BREADY(s_axi_control_BREADY),
    .s_axi_control_ARVALID(s_axi_control_ARVALID),
    .s_axi_control_ARADDR(s_axi_control_ARADDR),
    .s_axi_control_RREADY(s_axi_control_RREADY),
    .s_axi_control_AWREADY(s_axi_control_AWREADY),
    .s_axi_control_WREADY(s_axi_control_WREADY),
    .s_axi_control_BRESP(s_axi_control_BRESP),
    .s_axi_control_BVALID(s_axi_control_BVALID),
    .s_axi_control_ARREADY(s_axi_control_ARREADY),
    .s_axi_control_RDATA(s_axi_control_RDATA),
    .s_axi_control_RRESP(s_axi_control_RRESP),
    .s_axi_control_RVALID(s_axi_control_RVALID),
{translator_arg_conns}{translator_counter_sep}{translator_counter_conns}
  );

  // Bambu core (top_level.v — unmodified)
  top_level core (
    .clock(ap_clk),
    .reset(ap_rst_n),
    .start_port(start_port_pulse),
    .cache_reset(cache_reset),
{core_scalar_block}
    .done_port(sig_done),
{core_axi_block}
  );

endmodule
"""
