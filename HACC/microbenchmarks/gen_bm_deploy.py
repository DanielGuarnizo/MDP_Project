#!/usr/bin/env python3
"""
gen_bm_deploy.py — generate HACC deploy folders for read_bm and write_bm.
Run from repo root: python3 HACC/microbenchmarks/gen_bm_deploy.py

Creates:
  HACC/read_bm_deploy/   — read-only AXI benchmark kernel
  HACC/write_bm_deploy/  — write-only AXI benchmark kernel

Each has: wrapper.v, translator.v, Bambu DUT.v, script_to_xo.tcl,
          xo_to_xclbin.sh, host/bm_host.cpp, host/CMakeLists.txt,
          accel_config.json, build_all.sh, xrt.ini, input_data/
"""

import json, os, shutil
from pathlib import Path

REPO     = Path(__file__).resolve().parents[2]
BM_DIR   = Path(__file__).resolve().parent
BAMBU_OUT = BM_DIR / "Bambu_outputs"
HACC_DIR  = BM_DIR.parent
LIB_DIR   = HACC_DIR / "lib"

# ─── AXI M port declarations (single gmem_0 bundle, 32-bit data/addr) ──────

AXI_SLAVE_DECLS = """\
  input  m_axi_gmem_0_awready,
  input  m_axi_gmem_0_wready,
  input  [5:0] m_axi_gmem_0_bid,
  input  [1:0] m_axi_gmem_0_bresp,
  input  [0:0] m_axi_gmem_0_buser,
  input  m_axi_gmem_0_bvalid,
  input  m_axi_gmem_0_arready,
  input  [5:0] m_axi_gmem_0_rid,
  input  [31:0] m_axi_gmem_0_rdata,
  input  [1:0] m_axi_gmem_0_rresp,
  input  m_axi_gmem_0_rlast,
  input  [0:0] m_axi_gmem_0_ruser,
  input  m_axi_gmem_0_rvalid"""

AXI_MASTER_DECLS = """\
  output [5:0] m_axi_gmem_0_awid,
  output [31:0] m_axi_gmem_0_awaddr,
  output [7:0] m_axi_gmem_0_awlen,
  output [2:0] m_axi_gmem_0_awsize,
  output [1:0] m_axi_gmem_0_awburst,
  output [1:0] m_axi_gmem_0_awlock,
  output [3:0] m_axi_gmem_0_awcache,
  output [2:0] m_axi_gmem_0_awprot,
  output [3:0] m_axi_gmem_0_awqos,
  output [3:0] m_axi_gmem_0_awregion,
  output [0:0] m_axi_gmem_0_awuser,
  output m_axi_gmem_0_awvalid,
  output [31:0] m_axi_gmem_0_wdata,
  output [3:0] m_axi_gmem_0_wstrb,
  output m_axi_gmem_0_wlast,
  output [0:0] m_axi_gmem_0_wuser,
  output m_axi_gmem_0_wvalid,
  output m_axi_gmem_0_bready,
  output [5:0] m_axi_gmem_0_arid,
  output [31:0] m_axi_gmem_0_araddr,
  output [7:0] m_axi_gmem_0_arlen,
  output [2:0] m_axi_gmem_0_arsize,
  output [1:0] m_axi_gmem_0_arburst,
  output [1:0] m_axi_gmem_0_arlock,
  output [3:0] m_axi_gmem_0_arcache,
  output [2:0] m_axi_gmem_0_arprot,
  output [3:0] m_axi_gmem_0_arqos,
  output [3:0] m_axi_gmem_0_arregion,
  output [0:0] m_axi_gmem_0_aruser,
  output m_axi_gmem_0_arvalid,
  output m_axi_gmem_0_rready"""

AXI_PORT_CONNECTIONS = """\
    .m_axi_gmem_0_awready(m_axi_gmem_0_awready),
    .m_axi_gmem_0_wready(m_axi_gmem_0_wready),
    .m_axi_gmem_0_bid(m_axi_gmem_0_bid),
    .m_axi_gmem_0_bresp(m_axi_gmem_0_bresp),
    .m_axi_gmem_0_buser(m_axi_gmem_0_buser),
    .m_axi_gmem_0_bvalid(m_axi_gmem_0_bvalid),
    .m_axi_gmem_0_arready(m_axi_gmem_0_arready),
    .m_axi_gmem_0_rid(m_axi_gmem_0_rid),
    .m_axi_gmem_0_rdata(m_axi_gmem_0_rdata),
    .m_axi_gmem_0_rresp(m_axi_gmem_0_rresp),
    .m_axi_gmem_0_rlast(m_axi_gmem_0_rlast),
    .m_axi_gmem_0_ruser(m_axi_gmem_0_ruser),
    .m_axi_gmem_0_rvalid(m_axi_gmem_0_rvalid),
    .m_axi_gmem_0_awid(m_axi_gmem_0_awid),
    .m_axi_gmem_0_awaddr(m_axi_gmem_0_awaddr),
    .m_axi_gmem_0_awlen(m_axi_gmem_0_awlen),
    .m_axi_gmem_0_awsize(m_axi_gmem_0_awsize),
    .m_axi_gmem_0_awburst(m_axi_gmem_0_awburst),
    .m_axi_gmem_0_awlock(m_axi_gmem_0_awlock),
    .m_axi_gmem_0_awcache(m_axi_gmem_0_awcache),
    .m_axi_gmem_0_awprot(m_axi_gmem_0_awprot),
    .m_axi_gmem_0_awqos(m_axi_gmem_0_awqos),
    .m_axi_gmem_0_awregion(m_axi_gmem_0_awregion),
    .m_axi_gmem_0_awuser(m_axi_gmem_0_awuser),
    .m_axi_gmem_0_awvalid(m_axi_gmem_0_awvalid),
    .m_axi_gmem_0_wdata(m_axi_gmem_0_wdata),
    .m_axi_gmem_0_wstrb(m_axi_gmem_0_wstrb),
    .m_axi_gmem_0_wlast(m_axi_gmem_0_wlast),
    .m_axi_gmem_0_wuser(m_axi_gmem_0_wuser),
    .m_axi_gmem_0_wvalid(m_axi_gmem_0_wvalid),
    .m_axi_gmem_0_bready(m_axi_gmem_0_bready),
    .m_axi_gmem_0_arid(m_axi_gmem_0_arid),
    .m_axi_gmem_0_araddr(m_axi_gmem_0_araddr),
    .m_axi_gmem_0_arlen(m_axi_gmem_0_arlen),
    .m_axi_gmem_0_arsize(m_axi_gmem_0_arsize),
    .m_axi_gmem_0_arburst(m_axi_gmem_0_arburst),
    .m_axi_gmem_0_arlock(m_axi_gmem_0_arlock),
    .m_axi_gmem_0_arcache(m_axi_gmem_0_arcache),
    .m_axi_gmem_0_arprot(m_axi_gmem_0_arprot),
    .m_axi_gmem_0_arqos(m_axi_gmem_0_arqos),
    .m_axi_gmem_0_arregion(m_axi_gmem_0_arregion),
    .m_axi_gmem_0_aruser(m_axi_gmem_0_aruser),
    .m_axi_gmem_0_arvalid(m_axi_gmem_0_arvalid),
    .m_axi_gmem_0_rready(m_axi_gmem_0_rready)"""


# ─── Verilog generation ───────────────────────────────────────────────────────

def gen_translator_v(kname: str, scalar_args: list[str]) -> str:
    """AXI-Lite slave — register map with hw-profile counter reads."""
    BASE, STEP = 0x10, 0x04
    addr_map   = {a: BASE + i * STEP for i, a in enumerate(scalar_args)}

    lp = ["    ADDR_AP_CTRL = 8'h00"]
    for a in scalar_args:
        lp.append(f"    ADDR_{a.upper()} = 8'h{addr_map[a]:02X}")
    lp += [
        "    ADDR_RD_BUSY_LO = 8'h90",
        "    ADDR_RD_BUSY_HI = 8'h94",
        "    ADDR_WR_BUSY_LO = 8'h98",
        "    ADDR_WR_BUSY_HI = 8'h9C",
        "    ADDR_RD_TXN_CNT = 8'hA0",
        "    ADDR_WR_TXN_CNT = 8'hA4",
        "    WRIDLE  = 2'd0", "    WRDATA  = 2'd1",
        "    WRRESP  = 2'd2", "    WRRESET = 2'd3",
        "    RDIDLE  = 2'd0", "    RDDATA  = 2'd1",
        "    RDRESET = 2'd2",
        "    ADDR_BITS = C_S_AXI_CONTROL_ADDR_WIDTH",
    ]
    lp_block = "localparam\n" + ",\n".join(lp) + ";"

    reg_decls    = "\n".join(f"    reg [31:0] reg_{a};" for a in scalar_args)
    out_assigns  = "\n".join(f"    assign {a} = reg_{a};" for a in scalar_args)
    scalar_ports = "\n".join(f"    output wire [31:0] {a}," for a in scalar_args)
    rdata_cases  = "\n".join(
        f"                ADDR_{a.upper()}: rdata <= reg_{a};" for a in scalar_args)
    reg_logic = "\n\n".join(
        f"    always @(posedge ap_clk) begin\n"
        f"        if (!ap_rst_n)\n"
        f"            reg_{a} <= 0;\n"
        f"        else if (w_hs && waddr == ADDR_{a.upper()})\n"
        f"            reg_{a} <= (s_axi_control_WDATA & wmask) | (reg_{a} & ~wmask);\n"
        f"    end"
        for a in scalar_args)

    wmask_line = (
        "    assign wmask = "
        "{ {8{s_axi_control_WSTRB[3]}}, {8{s_axi_control_WSTRB[2]}}, "
        "{8{s_axi_control_WSTRB[1]}}, {8{s_axi_control_WSTRB[0]}} };")
    waddr_latch = (
        "        if (aw_hs) "
        "waddr <= {s_axi_control_AWADDR[ADDR_BITS-1:2], {2{1'b0}}};")

    return f"""\
`timescale 1ns / 1ps
// AXI-Lite slave translator for {kname} — auto-generated by gen_bm_deploy.py
module {kname}_translator #(
    parameter C_S_AXI_CONTROL_DATA_WIDTH = 32,
    parameter C_S_AXI_CONTROL_ADDR_WIDTH = 8,
    parameter C_WSTRB_WIDTH = 4
)(
    input  wire ap_clk,
    input  wire ap_rst_n,
    input       ap_ready,
    input       ap_done,
    input  wire s_axi_control_AWVALID,
    input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_AWADDR,
    input  wire s_axi_control_WVALID,
    input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_WDATA,
    input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_WSTRB,
    input  wire s_axi_control_BREADY,
    input  wire s_axi_control_ARVALID,
    input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_ARADDR,
    input  wire s_axi_control_RREADY,
    output reg  s_axi_control_AWREADY,
    output reg  s_axi_control_WREADY,
    output wire [1:0] s_axi_control_BRESP,
    output reg  s_axi_control_BVALID,
    output reg  s_axi_control_ARREADY,
    output reg  [C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_RDATA,
    output wire [1:0] s_axi_control_RRESP,
    output reg  s_axi_control_RVALID,
    output wire ap_start,
    // performance counter inputs (read-only, driven by wrapper)
    input  wire [63:0] rd_busy_cycles,
    input  wire [63:0] wr_busy_cycles,
    input  wire [31:0] rd_txn_count,
    input  wire [31:0] wr_txn_count,
{scalar_ports}
    output reg  [31:0] ap_return
);

    {lp_block}

    reg  [1:0] wstate;
    reg  [1:0] rstate;
    reg  [ADDR_BITS-1:0] waddr;
    wire [31:0] wmask;
    wire aw_hs = s_axi_control_AWVALID & s_axi_control_AWREADY;
    wire w_hs  = s_axi_control_WVALID  & s_axi_control_WREADY;

    {wmask_line}
    assign s_axi_control_BRESP = 2'b00;
    assign s_axi_control_RRESP = 2'b00;

    // ap_start register (self-clearing)
    reg  ap_start_r;
    always @(posedge ap_clk) begin
        if (!ap_rst_n)
            ap_start_r <= 0;
        else if (w_hs && waddr == ADDR_AP_CTRL && s_axi_control_WDATA[0])
            ap_start_r <= 1;
        else if (ap_ready)
            ap_start_r <= 0;
    end
    assign ap_start = ap_start_r;

    // ap_done / ap_idle status (read-only in CTRL register)
    reg  ap_done_r;
    always @(posedge ap_clk) begin
        if (!ap_rst_n) ap_done_r <= 0;
        else if (ap_done) ap_done_r <= 1;
        else if (w_hs && waddr == ADDR_AP_CTRL) ap_done_r <= 0;
    end

    // Write state machine
    always @(posedge ap_clk) begin
        if (!ap_rst_n) wstate <= WRRESET;
        else case (wstate)
            WRIDLE: if (s_axi_control_AWVALID) wstate <= WRDATA;
            WRDATA: if (s_axi_control_WVALID)  wstate <= WRRESP;
            WRRESP: if (s_axi_control_BREADY)  wstate <= WRIDLE;
            default: wstate <= WRIDLE;
        endcase
    end
    always @(posedge ap_clk) begin
        if (!ap_rst_n) s_axi_control_AWREADY <= 0;
        else           s_axi_control_AWREADY <= (wstate == WRIDLE);
    end
    always @(posedge ap_clk) begin
        if (!ap_rst_n) s_axi_control_WREADY <= 0;
        else           s_axi_control_WREADY <= (wstate == WRDATA);
    end
    always @(posedge ap_clk) begin
        if (!ap_rst_n) s_axi_control_BVALID <= 0;
        else if (wstate == WRDATA && s_axi_control_WVALID) s_axi_control_BVALID <= 1;
        else if (s_axi_control_BREADY) s_axi_control_BVALID <= 0;
    end
    always @(posedge ap_clk) begin
        {waddr_latch}
    end

    // Read state machine
    always @(posedge ap_clk) begin
        if (!ap_rst_n) rstate <= RDRESET;
        else case (rstate)
            RDIDLE: if (s_axi_control_ARVALID) rstate <= RDDATA;
            RDDATA: if (s_axi_control_RREADY && s_axi_control_RVALID) rstate <= RDIDLE;
            default: rstate <= RDIDLE;
        endcase
    end
    always @(posedge ap_clk) begin
        if (!ap_rst_n) s_axi_control_ARREADY <= 0;
        else           s_axi_control_ARREADY <= (rstate == RDIDLE);
    end
    always @(posedge ap_clk) begin
        if (!ap_rst_n) s_axi_control_RVALID <= 0;
        else if (rstate == RDIDLE && s_axi_control_ARVALID) s_axi_control_RVALID <= 1;
        else if (s_axi_control_RREADY) s_axi_control_RVALID <= 0;
    end

    // Read data mux
    reg [31:0] rdata;
    always @(*) begin
        rdata = 32'd0;
        case (s_axi_control_ARADDR)
            ADDR_AP_CTRL:    rdata = {{28'd0, 1'b1, ap_done_r, 1'b0, ap_start_r}};
            {rdata_cases}
            ADDR_RD_BUSY_LO: rdata = rd_busy_cycles[31:0];
            ADDR_RD_BUSY_HI: rdata = rd_busy_cycles[63:32];
            ADDR_WR_BUSY_LO: rdata = wr_busy_cycles[31:0];
            ADDR_WR_BUSY_HI: rdata = wr_busy_cycles[63:32];
            ADDR_RD_TXN_CNT: rdata = rd_txn_count;
            ADDR_WR_TXN_CNT: rdata = wr_txn_count;
            default: rdata = 32'd0;
        endcase
    end
    always @(posedge ap_clk) begin
        if (!ap_rst_n) s_axi_control_RDATA <= 0;
        else           s_axi_control_RDATA <= rdata;
    end

    // Scalar arg registers
    {reg_decls}
    {out_assigns}

    {reg_logic}

endmodule
"""


def gen_wrapper_v(kname: str, dut_name: str, scalar_args: list[str]) -> str:
    """Vitis-compatible wrapper with AXI-Lite + hw-profile counters."""
    scalar_wires = "\n".join(f"  wire [31:0] {a};" for a in scalar_args)
    translator_scalar_conns = ",\n".join(f"    .{a}({a})" for a in scalar_args)
    dut_scalar_conns = "\n".join(f"    .{a}({a})," for a in scalar_args)
    return f"""\
`timescale 1ns / 1ps
// Vitis-compatible wrapper for Bambu {dut_name} — auto-generated by gen_bm_deploy.py
module {kname} (
  input  ap_clk,
  input  ap_rst_n,
  output ap_done,
  output ap_ready,
  input  cache_reset,
  input  s_axi_control_AWVALID,
  input  [7:0] s_axi_control_AWADDR,
  input  s_axi_control_WVALID,
  input  [31:0] s_axi_control_WDATA,
  input  [3:0] s_axi_control_WSTRB,
  input  s_axi_control_BREADY,
  input  s_axi_control_ARVALID,
  input  [7:0] s_axi_control_ARADDR,
  input  s_axi_control_RREADY,
  output s_axi_control_AWREADY,
  output s_axi_control_WREADY,
  output [1:0] s_axi_control_BRESP,
  output s_axi_control_BVALID,
  output s_axi_control_ARREADY,
  output [31:0] s_axi_control_RDATA,
  output [1:0] s_axi_control_RRESP,
  output s_axi_control_RVALID,
{AXI_SLAVE_DECLS},
{AXI_MASTER_DECLS}
);

  wire sig_done;
  wire ap_start_lvl;
{scalar_wires}

  // Rising-edge detector: Bambu needs a 1-cycle start_port pulse
  reg  ap_start_q;
  always @(posedge ap_clk) ap_start_q <= ap_start_lvl;
  wire start_port_pulse = ap_start_lvl & ~ap_start_q;

  reg  ap_ready_r;
  always @(posedge ap_clk) ap_ready_r <= start_port_pulse;
  assign ap_ready = ap_ready_r;
  assign ap_done  = sig_done;

  // ── hw-profile counters (single gmem_0 bundle) ──────────────────────────
  reg [3:0] rd_outstanding_0;
  reg [3:0] wr_outstanding_0;
  wire rd_any_outstanding = (rd_outstanding_0 != 4'd0);
  wire wr_any_outstanding = (wr_outstanding_0 != 4'd0);

  always @(posedge ap_clk) begin
    if (!ap_rst_n || start_port_pulse) rd_outstanding_0 <= 4'd0;
    else if ((m_axi_gmem_0_arvalid && m_axi_gmem_0_arready) && !(m_axi_gmem_0_rlast && m_axi_gmem_0_rvalid && m_axi_gmem_0_rready))
      rd_outstanding_0 <= (rd_outstanding_0 < 4'd15) ? rd_outstanding_0 + 4'd1 : 4'd15;
    else if (!(m_axi_gmem_0_arvalid && m_axi_gmem_0_arready) && (m_axi_gmem_0_rlast && m_axi_gmem_0_rvalid && m_axi_gmem_0_rready))
      rd_outstanding_0 <= (rd_outstanding_0 > 4'd0) ? rd_outstanding_0 - 4'd1 : 4'd0;
  end
  always @(posedge ap_clk) begin
    if (!ap_rst_n || start_port_pulse) wr_outstanding_0 <= 4'd0;
    else if ((m_axi_gmem_0_awvalid && m_axi_gmem_0_awready) && !(m_axi_gmem_0_bvalid && m_axi_gmem_0_bready))
      wr_outstanding_0 <= (wr_outstanding_0 < 4'd15) ? wr_outstanding_0 + 4'd1 : 4'd15;
    else if (!(m_axi_gmem_0_awvalid && m_axi_gmem_0_awready) && (m_axi_gmem_0_bvalid && m_axi_gmem_0_bready))
      wr_outstanding_0 <= (wr_outstanding_0 > 4'd0) ? wr_outstanding_0 - 4'd1 : 4'd0;
  end

  wire rd_done_this_cycle = (m_axi_gmem_0_rlast & m_axi_gmem_0_rvalid & m_axi_gmem_0_rready);
  wire wr_done_this_cycle = (m_axi_gmem_0_bvalid & m_axi_gmem_0_bready);

  reg [63:0] rd_busy_cycles;
  reg [63:0] wr_busy_cycles;
  reg [31:0] rd_txn_count;
  reg [31:0] wr_txn_count;

  always @(posedge ap_clk) begin
    if (!ap_rst_n || start_port_pulse) rd_busy_cycles <= 64'd0;
    else if (rd_any_outstanding)       rd_busy_cycles <= rd_busy_cycles + 64'd1;
  end
  always @(posedge ap_clk) begin
    if (!ap_rst_n || start_port_pulse) wr_busy_cycles <= 64'd0;
    else if (wr_any_outstanding)       wr_busy_cycles <= wr_busy_cycles + 64'd1;
  end
  always @(posedge ap_clk) begin
    if (!ap_rst_n || start_port_pulse) rd_txn_count <= 32'd0;
    else rd_txn_count <= rd_txn_count + {{31'd0, rd_done_this_cycle}};
  end
  always @(posedge ap_clk) begin
    if (!ap_rst_n || start_port_pulse) wr_txn_count <= 32'd0;
    else wr_txn_count <= wr_txn_count + {{31'd0, wr_done_this_cycle}};
  end
  // ── end hw-profile counters ───────────────────────────────────────────────

  {kname}_translator translator (
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
    .rd_busy_cycles(rd_busy_cycles),
    .wr_busy_cycles(wr_busy_cycles),
    .rd_txn_count(rd_txn_count),
    .wr_txn_count(wr_txn_count),
{translator_scalar_conns}
  );

  {dut_name} core (
    .clock(ap_clk),
    .reset(ap_rst_n),
    .start_port(start_port_pulse),
    .cache_reset(cache_reset),
{dut_scalar_conns}
    .done_port(sig_done),
{AXI_PORT_CONNECTIONS}
  );

endmodule
"""


def gen_script_to_xo(kname: str, scalar_args: list[str]) -> str:
    """Vivado TCL to package the kernel as a Vitis XO."""
    BASE, STEP = 0x10, 0x04
    addr_map = {a: BASE + i * STEP for i, a in enumerate(scalar_args)}
    buf_args = [a for a in scalar_args if a.startswith("dram_")]

    reg_entries = []
    for a in scalar_args:
        reg_entries.append(
            f"ipx::add_register {a} $ab\n"
            f"set_property address_offset 0x{addr_map[a]:03X} "
            f"[ipx::get_registers {a} -of_objects $ab]\n"
            f"set_property size 32 [ipx::get_registers {a} -of_objects $ab]"
        )
    reg_block = "\n\n".join(reg_entries)

    # All buffer args point to the single gmem_0 bundle
    assoc_busif = "\n".join(
        f"set regobj [ipx::get_registers {a} -of_objects $ab]\n"
        f"ipx::add_register_parameter ASSOCIATED_BUSIF $regobj\n"
        f"set_property value m_axi_gmem_0 "
        f"[ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]"
        for a in buf_args
    )

    return f"""\
# script_to_xo.tcl — packages {kname} wrapper as a Vitis XO kernel
# Run: vivado -mode batch -source script_to_xo.tcl

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJ_DIR   [file normalize [file join $SCRIPT_DIR "build" "vivado"]]
set SRC_DIR    [file normalize [file join $SCRIPT_DIR "src"]]
set IP_ROOT    [file normalize [file join $SCRIPT_DIR "build" "ip"]]
set XO_DIR     [file normalize [file join $SCRIPT_DIR "xo"]]

file mkdir $PROJ_DIR $IP_ROOT $XO_DIR

create_project -force project $PROJ_DIR -part xcu55c-fsvh2892-2L-e

add_files -norecurse [list \\
  [file join $SRC_DIR {kname}.v] \\
  [file join $SRC_DIR {kname}_translator.v] \\
  [file join $SRC_DIR {kname}_dut.v] \\
]
update_compile_order -fileset sources_1
set_property top {kname} [current_fileset]
update_compile_order -fileset sources_1

ipx::package_project \\
  -root_dir $IP_ROOT \\
  -vendor user.org -library user -taxonomy /UserIP \\
  -import_files -force

set_property name         {kname} [ipx::current_core]
set_property display_name {kname} [ipx::current_core]
set_property description  "Bambu AXI latency benchmark — {kname}" [ipx::current_core]
set_property ipi_drc {{ignore_freq_hz true}} [ipx::current_core]
set_property sdx_kernel               true  [ipx::current_core]
set_property sdx_kernel_type          rtl   [ipx::current_core]
set_property vitis_drc {{ctrl_protocol ap_ctrl_hs}} [ipx::current_core]

set core [ipx::current_core]

ipx::associate_bus_interfaces -busif s_axi_control -clock ap_clk $core
ipx::associate_bus_interfaces -busif m_axi_gmem_0  -clock ap_clk $core

catch {{ ipx::remove_bus_interface cache_reset $core }}

# Clock frequency tolerance
ipx::add_bus_parameter FREQ_TOLERANCE_HZ [ipx::get_bus_interfaces ap_clk -of_objects $core]
set_property value -1 [ipx::get_bus_parameters FREQ_TOLERANCE_HZ \\
  -of_objects [ipx::get_bus_interfaces ap_clk -of_objects $core]]

set mm [ipx::get_memory_maps s_axi_control -of_objects $core]
set ab [ipx::get_address_blocks reg0 -of_objects $mm]

# AP_CTRL
ipx::add_register CTRL $ab
set_property address_offset 0x000 [ipx::get_registers CTRL -of_objects $ab]
set_property size 32              [ipx::get_registers CTRL -of_objects $ab]

# Scalar args
{reg_block}

# hw-profile read-only registers
foreach {{name off}} {{
    rd_busy_cycles_lo 0x90  rd_busy_cycles_hi 0x94
    wr_busy_cycles_lo 0x98  wr_busy_cycles_hi 0x9C
    rd_txn_count      0xA0  wr_txn_count      0xA4
}} {{
    ipx::add_register $name $ab
    set_property address_offset $off [ipx::get_registers $name -of_objects $ab]
    set_property size 32             [ipx::get_registers $name -of_objects $ab]
}}

# Link buffer args to the AXI master bundle
{assoc_busif}

set_property core_revision 1 $core
ipx::create_xgui_files $core
ipx::update_checksums  $core
ipx::check_integrity -kernel -xrt $core
ipx::save_core         $core

package_xo -force \\
  -xo_path     ${{XO_DIR}}/{kname}.xo \\
  -kernel_name  {kname} \\
  -ip_directory $IP_ROOT \\
  -ctrl_protocol ap_ctrl_hs

puts "XO created: ${{XO_DIR}}/{kname}.xo"
"""


def gen_xo_to_xclbin(kname: str) -> str:
    return f"""\
#!/usr/bin/env bash
# xo_to_xclbin.sh — link {kname}.xo into a hw xclbin for Alveo U55C
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
XO="${{SCRIPT_DIR}}/xo/{kname}.xo"

[ -f "$XO" ] || {{ echo "ERROR: $XO not found — run script_to_xo.tcl first"; exit 1; }}

mkdir -p "${{SCRIPT_DIR}}/build/vpp/logs" \\
         "${{SCRIPT_DIR}}/build/vpp/tmp"  \\
         "${{SCRIPT_DIR}}/build/vpp/reports"

source /tools/Xilinx/Vitis/2024.2/settings64.sh

echo "=== v++ link start $(date) ==="
v++ -t hw \\
  --platform xilinx_u55c_gen3x16_xdma_3_202210_1 \\
  --link "$XO" \\
  --log_dir    "${{SCRIPT_DIR}}/build/vpp/logs"   \\
  --temp_dir   "${{SCRIPT_DIR}}/build/vpp/tmp"    \\
  --report_dir "${{SCRIPT_DIR}}/build/vpp/reports" \\
  --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE=Explore \\
  --vivado.prop run.impl_1.STEPS.PHYS_OPT_DESIGN.IS_ENABLED=true \\
  --vivado.prop run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED=true \\
  --vivado.prop run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE=Explore \\
  "--vivado.prop=run.impl_1.STEPS.PLACE_DESIGN.TCL.PRE=${{SCRIPT_DIR}}/pre_place_pblock.tcl" \\
  --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.TCL.POST="${{SCRIPT_DIR}}/post_route.tcl" \\
  --connectivity.sp {kname}_1.m_axi_gmem_0:HBM[0] \\
  -o "${{SCRIPT_DIR}}/xo/{kname}.xclbin"

echo "=== v++ link done $(date) ==="
touch "${{SCRIPT_DIR}}/.build_done"
"""


def gen_host_cpp(kname: str, scalar_args: list[str], n_values: list[int]) -> str:
    """Host C++ app: sweep N, print hw-profile counters per run."""
    BASE, STEP = 0x10, 0x04
    addr_map = {a: BASE + i * STEP for i, a in enumerate(scalar_args)}

    n_values_str = ", ".join(str(v) for v in n_values)
    return f"""\
// bm_host.cpp — AXI latency benchmark host for {kname}
// Sweeps N values and prints hw-profile counter results.
// Build: see CMakeLists.txt
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <experimental/xrt_bo.h>
#include <experimental/xrt_device.h>
#include <experimental/xrt_kernel.h>
#include <vector>

// hw-profile register offsets
static constexpr uint32_t ADDR_RD_BUSY_LO = 0x90;
static constexpr uint32_t ADDR_RD_BUSY_HI = 0x94;
static constexpr uint32_t ADDR_WR_BUSY_LO = 0x98;
static constexpr uint32_t ADDR_WR_BUSY_HI = 0x9C;
static constexpr uint32_t ADDR_RD_TXN_CNT = 0xA0;
static constexpr uint32_t ADDR_WR_TXN_CNT = 0xA4;

int main(int argc, char* argv[]) {{
    const char* xclbin_path = (argc > 1) ? argv[1] : "{kname}.xclbin";

    auto device = xrt::device(0);
    auto uuid   = device.load_xclbin(xclbin_path);
    auto krnl   = xrt::kernel(device, uuid, "{kname}", xrt::kernel::cu_access_mode::exclusive);

    std::vector<int> n_list = {{{n_values_str}}};

    printf("%-12s  %-12s  %-12s  %-12s  %-12s  %-12s  %-12s\\n",
           "N", "kern_ms", "rd_busy", "wr_busy", "rd_txn", "wr_txn",
           "rd_lat/txn");

    for (int n : n_list) {{
        size_t n_floats = (size_t)n;

        // Allocate buffers in HBM[0]
        auto buf_input_p0  = xrt::bo(device, n_floats * sizeof(float), 0);
        auto buf_output_p0 = xrt::bo(device, n_floats * sizeof(float), 0);

        // Fill input with 1.0f
        float* inp = buf_input_p0.map<float*>();
        for (size_t i = 0; i < n_floats; i++) inp[i] = 1.0f;
        buf_input_p0.sync(XCL_BO_SYNC_BO_TO_DEVICE);

        // Set registers
        krnl.write_register(0x{addr_map.get("dram_input_p0", 0x10):03X},
            (uint32_t)(buf_input_p0.address()  & 0xFFFFFFFF));
        krnl.write_register(0x{addr_map.get("dram_output_p0", 0x14):03X},
            (uint32_t)(buf_output_p0.address() & 0xFFFFFFFF));
        krnl.write_register(0x{addr_map.get("n", 0x18):03X}, (uint32_t)n);

        // Run
        auto t0 = std::chrono::high_resolution_clock::now();
        krnl.write_register(0x00, 0x1);   // ap_start
        while (!(krnl.read_register(0x00) & 0x4)) {{}}  // wait ap_done (bit2 in translator)
        auto t1 = std::chrono::high_resolution_clock::now();
        double kern_ms = std::chrono::duration<double, std::milli>(t1 - t0).count();

        // Read hw-profile counters
        uint64_t rd_busy = ((uint64_t)krnl.read_register(ADDR_RD_BUSY_HI) << 32)
                         |  (uint64_t)krnl.read_register(ADDR_RD_BUSY_LO);
        uint64_t wr_busy = ((uint64_t)krnl.read_register(ADDR_WR_BUSY_HI) << 32)
                         |  (uint64_t)krnl.read_register(ADDR_WR_BUSY_LO);
        uint32_t rd_txn  = krnl.read_register(ADDR_RD_TXN_CNT);
        uint32_t wr_txn  = krnl.read_register(ADDR_WR_TXN_CNT);

        double rd_lat = (rd_txn > 0) ? (double)rd_busy / rd_txn : 0.0;

        printf("%-12d  %-12.3f  %-12lu  %-12lu  %-12u  %-12u  %-12.2f\\n",
               n, kern_ms, rd_busy, wr_busy, rd_txn, wr_txn, rd_lat);
    }}
    return 0;
}}
"""


def gen_cmake(kname: str) -> str:
    return f"""\
cmake_minimum_required(VERSION 3.10)
project({kname}_host CXX)
set(CMAKE_CXX_STANDARD 17)

if(NOT DEFINED ENV{{XILINX_XRT}})
  message(FATAL_ERROR "Set XILINX_XRT before cmake, e.g. export XILINX_XRT=/opt/xilinx/xrt_2024.2")
endif()
set(XRT_ROOT $ENV{{XILINX_XRT}})

add_executable(bm_host bm_host.cpp)
target_include_directories(bm_host PRIVATE ${{XRT_ROOT}}/include)
target_link_directories(bm_host PRIVATE ${{XRT_ROOT}}/lib)
target_link_libraries(bm_host PRIVATE xrt_coreutil pthread)
install(TARGETS bm_host DESTINATION ${{CMAKE_INSTALL_PREFIX}})
"""


def gen_build_all(kname: str) -> str:
    return f"""\
#!/usr/bin/env bash
# build_all.sh — full build: XO → xclbin + host binary
# Run on hacc-build-01 from the deploy folder.
set -eo pipefail
SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
LOG="$SCRIPT_DIR/build_all.log"
exec > >(tee -a "$LOG") 2>&1

echo "=== BUILD START $(date) ==="

# 1. Package Verilog → XO using Vivado
source /tools/Xilinx/Vivado/2024.2/settings64.sh
echo "[1/3] Packaging XO with Vivado..."
vivado -mode batch -source "$SCRIPT_DIR/script_to_xo.tcl" 2>&1
[ -f "$SCRIPT_DIR/xo/{kname}.xo" ] || {{ echo "ERROR: XO not created"; exit 1; }}

# 2. Link XO → xclbin using v++
echo "[2/3] Linking xclbin with v++..."
bash "$SCRIPT_DIR/xo_to_xclbin.sh" 2>&1

# 3. Build host binary
source /tools/Xilinx/Vitis/2024.2/settings64.sh
echo "[3/3] Building host binary..."
cmake -S "$SCRIPT_DIR/host" -B "$SCRIPT_DIR/build/host" -DCMAKE_INSTALL_PREFIX="$SCRIPT_DIR" -DCMAKE_BUILD_TYPE=Release
cmake --build "$SCRIPT_DIR/build/host" --parallel 4
cmake --install "$SCRIPT_DIR/build/host"

echo "=== BUILD DONE $(date) ==="
"""


def gen_accel_config(kname: str) -> dict:
    return {
        "kernel": kname,
        "note": "AXI latency microbenchmark — no output verification, just hw-profile counters",
        "platform": "I386_GCC8|3.0|xcu55c-2Lfsvh2892-VVD",
    }


# ─── Deploy folder creation ───────────────────────────────────────────────────

BENCHMARKS = {
    "read_bm_krnl": {
        "dut": "read_bm",
        "scalar_args": ["dram_input_p0", "dram_output_p0", "n"],
        "n_values": [1024, 4096, 16384, 65536, 262144, 1048576],
        "src_v": BAMBU_OUT / "read_bm" / "read_bm.v",
        "out_dir": HACC_DIR / "read_bm_deploy",
    },
    "write_bm_krnl": {
        "dut": "write_bm",
        "scalar_args": ["dram_output_p0", "n"],
        "n_values": [1024, 4096, 16384, 65536, 262144, 1048576],
        "src_v": BAMBU_OUT / "write_bm" / "write_bm.v",
        "out_dir": HACC_DIR / "write_bm_deploy",
    },
}


def create_deploy(kname: str, cfg: dict) -> None:
    out = cfg["out_dir"]
    src_v = cfg["src_v"]
    dut   = cfg["dut"]
    scalar_args = cfg["scalar_args"]
    n_values    = cfg["n_values"]

    if not src_v.exists():
        print(f"  ERROR: {src_v} not found — run compile_bm.sh first")
        return

    (out / "src").mkdir(parents=True, exist_ok=True)
    (out / "xo").mkdir(parents=True, exist_ok=True)
    (out / "host").mkdir(parents=True, exist_ok=True)
    (out / "input_data").mkdir(parents=True, exist_ok=True)

    # Verilog sources
    shutil.copy(src_v, out / "src" / f"{kname}_dut.v")
    (out / "src" / f"{kname}_translator.v").write_text(
        gen_translator_v(kname, scalar_args))
    (out / "src" / f"{kname}.v").write_text(
        gen_wrapper_v(kname, dut, scalar_args))

    # Build scripts
    (out / "script_to_xo.tcl").write_text(gen_script_to_xo(kname, scalar_args))
    (out / "xo_to_xclbin.sh").write_text(gen_xo_to_xclbin(kname))
    os.chmod(out / "xo_to_xclbin.sh", 0o755)
    (out / "build_all.sh").write_text(gen_build_all(kname))
    os.chmod(out / "build_all.sh", 0o755)

    # Host
    (out / "host" / "bm_host.cpp").write_text(
        gen_host_cpp(kname, scalar_args, n_values))
    (out / "host" / "CMakeLists.txt").write_text(gen_cmake(kname))

    # Config + runtime
    (out / "accel_config.json").write_text(
        json.dumps(gen_accel_config(kname), indent=2))
    shutil.copy(LIB_DIR / "xrt.ini",            out / "xrt.ini")
    shutil.copy(LIB_DIR / "pre_place_pblock.tcl", out / "pre_place_pblock.tcl")
    shutil.copy(LIB_DIR / "post_route.tcl",      out / "post_route.tcl")

    # input_data: 1M floats of 1.0f (enough for all N values)
    max_n = max(n_values)
    import array
    arr = array.array('f', [1.0] * max_n)
    with open(out / "input_data" / "input.bin", "wb") as f:
        arr.tofile(f)

    print(f"  Created {out}")
    print(f"    src/: {kname}.v, {kname}_translator.v, {kname}_dut.v")
    print(f"    script_to_xo.tcl, xo_to_xclbin.sh, build_all.sh")
    print(f"    host/bm_host.cpp, host/CMakeLists.txt")


if __name__ == "__main__":
    print("Generating microbenchmark deploy folders...")
    for kname, cfg in BENCHMARKS.items():
        print(f"\n[{kname}]")
        create_deploy(kname, cfg)
    print("\nDone. Next: push to hacc-build-01 and run build_all.sh")
    print("  scp -r HACC/read_bm_deploy  hacc-build-01:~/workspace/deploy/")
    print("  scp -r HACC/write_bm_deploy hacc-build-01:~/workspace/deploy/")
    print("  ssh hacc-build-01 'cd ~/workspace/deploy/read_bm_deploy && bash build_all.sh 2>&1 | tee build.log &'")
