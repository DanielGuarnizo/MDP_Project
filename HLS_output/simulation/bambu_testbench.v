// verilator lint_off BLKANDNBLK
// verilator lint_off BLKSEQ

`timescale 1ns / 1ps
// CONSTANTS DECLARATION
`define MAX_COMMENT_LENGTH 1000
`define INIT_TIME 100


`ifdef __M64
typedef longint unsigned ptr_t;
`else
typedef int unsigned ptr_t;
`endif

// 
// Politecnico di Milano
// Code created using PandA - Version: PandA 2024.10 - Revision c2ba6936ca2ed63137095fea0b630a1c66e20e63-main - Date 2026-03-18T17:07:20
// Bambu executed with: bambu --top-fname=top_level --generate-interface=INFER --compiler=I386_GCC8 --clock-period=5 -O3 -v4 --generate-tb=testbench.c --tb-param-size=dram_in_b0:288 --tb-param-size=dram_in_b1:288 --tb-param-size=dram_w_b0:288 --tb-param-size=dram_w_b1:288 --tb-param-size=dram_out_b0:32 --tb-param-size=dram_out_b1:32 --tb-param-size=dram_out_b2:32 --tb-param-size=dram_out_b3:32 --tb-param-size=dram_out_b4:32 --tb-param-size=dram_out_b5:32 --tb-param-size=dram_out_b6:32 --tb-param-size=dram_out_b7:32 --simulate top_level.c 
// 
// Send any bug to: panda-info@polimi.it
// ************************************************************************
// The following text holds for all the components tagged with PANDA_LGPLv3.
// They are all part of the BAMBU/PANDA IP LIBRARY.
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 3 of the License, or (at your option) any later version.
// 
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public
// License along with the PandA framework; see the files COPYING.LIB
// If not, see <http://www.gnu.org/licenses/>.
// ************************************************************************


`ifdef __ICARUS__
  `define _SIM_HAVE_CLOG2
`endif
`ifdef VERILATOR
  `define _SIM_HAVE_CLOG2
`endif
`ifdef MODEL_TECH
  `define _SIM_HAVE_CLOG2
`endif
`ifdef VCS
  `define _SIM_HAVE_CLOG2
`endif
`ifdef NCVERILOG
  `define _SIM_HAVE_CLOG2
`endif
`ifdef XILINX_SIMULATOR
  `define _SIM_HAVE_CLOG2
`endif
`ifdef XILINX_ISIM
  `define _SIM_HAVE_CLOG2
`endif

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module join_signal(in1,
  out1);
  parameter BITSIZE_in1=1, PORTSIZE_in1=2,
    BITSIZE_out1=1;
  // IN
  input [(PORTSIZE_in1*BITSIZE_in1)+(-1):0] in1;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  
  generate
  genvar i1;
  for (i1=0; i1<PORTSIZE_in1; i1=i1+1)
    begin : L1
      assign out1[(i1+1)*(BITSIZE_out1/PORTSIZE_in1)-1:i1*(BITSIZE_out1/PORTSIZE_in1)] = in1[(i1+1)*BITSIZE_in1-1:i1*BITSIZE_in1];
    end
  endgenerate
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module split_signal(in1,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_out1=1, PORTSIZE_out1=2;
  // IN
  input [BITSIZE_in1-1:0] in1;
  // OUT
  output [(PORTSIZE_out1*BITSIZE_out1)+(-1):0] out1;
  assign out1 = in1;
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module TestbenchDUT(clock,
  reset,
  start_port,
  dram_in_b0,
  dram_in_b1,
  dram_w_b0,
  dram_w_b1,
  dram_out_b0,
  dram_out_b1,
  dram_out_b2,
  dram_out_b3,
  dram_out_b4,
  dram_out_b5,
  dram_out_b6,
  dram_out_b7,
  cache_reset,
  m_axi_gmem_in0_awready,
  m_axi_gmem_in0_wready,
  m_axi_gmem_in0_bid,
  m_axi_gmem_in0_bresp,
  m_axi_gmem_in0_buser,
  m_axi_gmem_in0_bvalid,
  m_axi_gmem_in0_arready,
  m_axi_gmem_in0_rid,
  m_axi_gmem_in0_rdata,
  m_axi_gmem_in0_rresp,
  m_axi_gmem_in0_rlast,
  m_axi_gmem_in0_ruser,
  m_axi_gmem_in0_rvalid,
  m_axi_gmem_in1_awready,
  m_axi_gmem_in1_wready,
  m_axi_gmem_in1_bid,
  m_axi_gmem_in1_bresp,
  m_axi_gmem_in1_buser,
  m_axi_gmem_in1_bvalid,
  m_axi_gmem_in1_arready,
  m_axi_gmem_in1_rid,
  m_axi_gmem_in1_rdata,
  m_axi_gmem_in1_rresp,
  m_axi_gmem_in1_rlast,
  m_axi_gmem_in1_ruser,
  m_axi_gmem_in1_rvalid,
  m_axi_gmem_out0_awready,
  m_axi_gmem_out0_wready,
  m_axi_gmem_out0_bid,
  m_axi_gmem_out0_bresp,
  m_axi_gmem_out0_buser,
  m_axi_gmem_out0_bvalid,
  m_axi_gmem_out0_arready,
  m_axi_gmem_out0_rid,
  m_axi_gmem_out0_rdata,
  m_axi_gmem_out0_rresp,
  m_axi_gmem_out0_rlast,
  m_axi_gmem_out0_ruser,
  m_axi_gmem_out0_rvalid,
  m_axi_gmem_out1_awready,
  m_axi_gmem_out1_wready,
  m_axi_gmem_out1_bid,
  m_axi_gmem_out1_bresp,
  m_axi_gmem_out1_buser,
  m_axi_gmem_out1_bvalid,
  m_axi_gmem_out1_arready,
  m_axi_gmem_out1_rid,
  m_axi_gmem_out1_rdata,
  m_axi_gmem_out1_rresp,
  m_axi_gmem_out1_rlast,
  m_axi_gmem_out1_ruser,
  m_axi_gmem_out1_rvalid,
  m_axi_gmem_out2_awready,
  m_axi_gmem_out2_wready,
  m_axi_gmem_out2_bid,
  m_axi_gmem_out2_bresp,
  m_axi_gmem_out2_buser,
  m_axi_gmem_out2_bvalid,
  m_axi_gmem_out2_arready,
  m_axi_gmem_out2_rid,
  m_axi_gmem_out2_rdata,
  m_axi_gmem_out2_rresp,
  m_axi_gmem_out2_rlast,
  m_axi_gmem_out2_ruser,
  m_axi_gmem_out2_rvalid,
  m_axi_gmem_out3_awready,
  m_axi_gmem_out3_wready,
  m_axi_gmem_out3_bid,
  m_axi_gmem_out3_bresp,
  m_axi_gmem_out3_buser,
  m_axi_gmem_out3_bvalid,
  m_axi_gmem_out3_arready,
  m_axi_gmem_out3_rid,
  m_axi_gmem_out3_rdata,
  m_axi_gmem_out3_rresp,
  m_axi_gmem_out3_rlast,
  m_axi_gmem_out3_ruser,
  m_axi_gmem_out3_rvalid,
  m_axi_gmem_out4_awready,
  m_axi_gmem_out4_wready,
  m_axi_gmem_out4_bid,
  m_axi_gmem_out4_bresp,
  m_axi_gmem_out4_buser,
  m_axi_gmem_out4_bvalid,
  m_axi_gmem_out4_arready,
  m_axi_gmem_out4_rid,
  m_axi_gmem_out4_rdata,
  m_axi_gmem_out4_rresp,
  m_axi_gmem_out4_rlast,
  m_axi_gmem_out4_ruser,
  m_axi_gmem_out4_rvalid,
  m_axi_gmem_out5_awready,
  m_axi_gmem_out5_wready,
  m_axi_gmem_out5_bid,
  m_axi_gmem_out5_bresp,
  m_axi_gmem_out5_buser,
  m_axi_gmem_out5_bvalid,
  m_axi_gmem_out5_arready,
  m_axi_gmem_out5_rid,
  m_axi_gmem_out5_rdata,
  m_axi_gmem_out5_rresp,
  m_axi_gmem_out5_rlast,
  m_axi_gmem_out5_ruser,
  m_axi_gmem_out5_rvalid,
  m_axi_gmem_out6_awready,
  m_axi_gmem_out6_wready,
  m_axi_gmem_out6_bid,
  m_axi_gmem_out6_bresp,
  m_axi_gmem_out6_buser,
  m_axi_gmem_out6_bvalid,
  m_axi_gmem_out6_arready,
  m_axi_gmem_out6_rid,
  m_axi_gmem_out6_rdata,
  m_axi_gmem_out6_rresp,
  m_axi_gmem_out6_rlast,
  m_axi_gmem_out6_ruser,
  m_axi_gmem_out6_rvalid,
  m_axi_gmem_out7_awready,
  m_axi_gmem_out7_wready,
  m_axi_gmem_out7_bid,
  m_axi_gmem_out7_bresp,
  m_axi_gmem_out7_buser,
  m_axi_gmem_out7_bvalid,
  m_axi_gmem_out7_arready,
  m_axi_gmem_out7_rid,
  m_axi_gmem_out7_rdata,
  m_axi_gmem_out7_rresp,
  m_axi_gmem_out7_rlast,
  m_axi_gmem_out7_ruser,
  m_axi_gmem_out7_rvalid,
  m_axi_gmem_w0_awready,
  m_axi_gmem_w0_wready,
  m_axi_gmem_w0_bid,
  m_axi_gmem_w0_bresp,
  m_axi_gmem_w0_buser,
  m_axi_gmem_w0_bvalid,
  m_axi_gmem_w0_arready,
  m_axi_gmem_w0_rid,
  m_axi_gmem_w0_rdata,
  m_axi_gmem_w0_rresp,
  m_axi_gmem_w0_rlast,
  m_axi_gmem_w0_ruser,
  m_axi_gmem_w0_rvalid,
  m_axi_gmem_w1_awready,
  m_axi_gmem_w1_wready,
  m_axi_gmem_w1_bid,
  m_axi_gmem_w1_bresp,
  m_axi_gmem_w1_buser,
  m_axi_gmem_w1_bvalid,
  m_axi_gmem_w1_arready,
  m_axi_gmem_w1_rid,
  m_axi_gmem_w1_rdata,
  m_axi_gmem_w1_rresp,
  m_axi_gmem_w1_rlast,
  m_axi_gmem_w1_ruser,
  m_axi_gmem_w1_rvalid,
  done_port,
  m_axi_gmem_in0_awid,
  m_axi_gmem_in0_awaddr,
  m_axi_gmem_in0_awlen,
  m_axi_gmem_in0_awsize,
  m_axi_gmem_in0_awburst,
  m_axi_gmem_in0_awlock,
  m_axi_gmem_in0_awcache,
  m_axi_gmem_in0_awprot,
  m_axi_gmem_in0_awqos,
  m_axi_gmem_in0_awregion,
  m_axi_gmem_in0_awuser,
  m_axi_gmem_in0_awvalid,
  m_axi_gmem_in0_wdata,
  m_axi_gmem_in0_wstrb,
  m_axi_gmem_in0_wlast,
  m_axi_gmem_in0_wuser,
  m_axi_gmem_in0_wvalid,
  m_axi_gmem_in0_bready,
  m_axi_gmem_in0_arid,
  m_axi_gmem_in0_araddr,
  m_axi_gmem_in0_arlen,
  m_axi_gmem_in0_arsize,
  m_axi_gmem_in0_arburst,
  m_axi_gmem_in0_arlock,
  m_axi_gmem_in0_arcache,
  m_axi_gmem_in0_arprot,
  m_axi_gmem_in0_arqos,
  m_axi_gmem_in0_arregion,
  m_axi_gmem_in0_aruser,
  m_axi_gmem_in0_arvalid,
  m_axi_gmem_in0_rready,
  m_axi_gmem_in1_awid,
  m_axi_gmem_in1_awaddr,
  m_axi_gmem_in1_awlen,
  m_axi_gmem_in1_awsize,
  m_axi_gmem_in1_awburst,
  m_axi_gmem_in1_awlock,
  m_axi_gmem_in1_awcache,
  m_axi_gmem_in1_awprot,
  m_axi_gmem_in1_awqos,
  m_axi_gmem_in1_awregion,
  m_axi_gmem_in1_awuser,
  m_axi_gmem_in1_awvalid,
  m_axi_gmem_in1_wdata,
  m_axi_gmem_in1_wstrb,
  m_axi_gmem_in1_wlast,
  m_axi_gmem_in1_wuser,
  m_axi_gmem_in1_wvalid,
  m_axi_gmem_in1_bready,
  m_axi_gmem_in1_arid,
  m_axi_gmem_in1_araddr,
  m_axi_gmem_in1_arlen,
  m_axi_gmem_in1_arsize,
  m_axi_gmem_in1_arburst,
  m_axi_gmem_in1_arlock,
  m_axi_gmem_in1_arcache,
  m_axi_gmem_in1_arprot,
  m_axi_gmem_in1_arqos,
  m_axi_gmem_in1_arregion,
  m_axi_gmem_in1_aruser,
  m_axi_gmem_in1_arvalid,
  m_axi_gmem_in1_rready,
  m_axi_gmem_out0_awid,
  m_axi_gmem_out0_awaddr,
  m_axi_gmem_out0_awlen,
  m_axi_gmem_out0_awsize,
  m_axi_gmem_out0_awburst,
  m_axi_gmem_out0_awlock,
  m_axi_gmem_out0_awcache,
  m_axi_gmem_out0_awprot,
  m_axi_gmem_out0_awqos,
  m_axi_gmem_out0_awregion,
  m_axi_gmem_out0_awuser,
  m_axi_gmem_out0_awvalid,
  m_axi_gmem_out0_wdata,
  m_axi_gmem_out0_wstrb,
  m_axi_gmem_out0_wlast,
  m_axi_gmem_out0_wuser,
  m_axi_gmem_out0_wvalid,
  m_axi_gmem_out0_bready,
  m_axi_gmem_out0_arid,
  m_axi_gmem_out0_araddr,
  m_axi_gmem_out0_arlen,
  m_axi_gmem_out0_arsize,
  m_axi_gmem_out0_arburst,
  m_axi_gmem_out0_arlock,
  m_axi_gmem_out0_arcache,
  m_axi_gmem_out0_arprot,
  m_axi_gmem_out0_arqos,
  m_axi_gmem_out0_arregion,
  m_axi_gmem_out0_aruser,
  m_axi_gmem_out0_arvalid,
  m_axi_gmem_out0_rready,
  m_axi_gmem_out1_awid,
  m_axi_gmem_out1_awaddr,
  m_axi_gmem_out1_awlen,
  m_axi_gmem_out1_awsize,
  m_axi_gmem_out1_awburst,
  m_axi_gmem_out1_awlock,
  m_axi_gmem_out1_awcache,
  m_axi_gmem_out1_awprot,
  m_axi_gmem_out1_awqos,
  m_axi_gmem_out1_awregion,
  m_axi_gmem_out1_awuser,
  m_axi_gmem_out1_awvalid,
  m_axi_gmem_out1_wdata,
  m_axi_gmem_out1_wstrb,
  m_axi_gmem_out1_wlast,
  m_axi_gmem_out1_wuser,
  m_axi_gmem_out1_wvalid,
  m_axi_gmem_out1_bready,
  m_axi_gmem_out1_arid,
  m_axi_gmem_out1_araddr,
  m_axi_gmem_out1_arlen,
  m_axi_gmem_out1_arsize,
  m_axi_gmem_out1_arburst,
  m_axi_gmem_out1_arlock,
  m_axi_gmem_out1_arcache,
  m_axi_gmem_out1_arprot,
  m_axi_gmem_out1_arqos,
  m_axi_gmem_out1_arregion,
  m_axi_gmem_out1_aruser,
  m_axi_gmem_out1_arvalid,
  m_axi_gmem_out1_rready,
  m_axi_gmem_out2_awid,
  m_axi_gmem_out2_awaddr,
  m_axi_gmem_out2_awlen,
  m_axi_gmem_out2_awsize,
  m_axi_gmem_out2_awburst,
  m_axi_gmem_out2_awlock,
  m_axi_gmem_out2_awcache,
  m_axi_gmem_out2_awprot,
  m_axi_gmem_out2_awqos,
  m_axi_gmem_out2_awregion,
  m_axi_gmem_out2_awuser,
  m_axi_gmem_out2_awvalid,
  m_axi_gmem_out2_wdata,
  m_axi_gmem_out2_wstrb,
  m_axi_gmem_out2_wlast,
  m_axi_gmem_out2_wuser,
  m_axi_gmem_out2_wvalid,
  m_axi_gmem_out2_bready,
  m_axi_gmem_out2_arid,
  m_axi_gmem_out2_araddr,
  m_axi_gmem_out2_arlen,
  m_axi_gmem_out2_arsize,
  m_axi_gmem_out2_arburst,
  m_axi_gmem_out2_arlock,
  m_axi_gmem_out2_arcache,
  m_axi_gmem_out2_arprot,
  m_axi_gmem_out2_arqos,
  m_axi_gmem_out2_arregion,
  m_axi_gmem_out2_aruser,
  m_axi_gmem_out2_arvalid,
  m_axi_gmem_out2_rready,
  m_axi_gmem_out3_awid,
  m_axi_gmem_out3_awaddr,
  m_axi_gmem_out3_awlen,
  m_axi_gmem_out3_awsize,
  m_axi_gmem_out3_awburst,
  m_axi_gmem_out3_awlock,
  m_axi_gmem_out3_awcache,
  m_axi_gmem_out3_awprot,
  m_axi_gmem_out3_awqos,
  m_axi_gmem_out3_awregion,
  m_axi_gmem_out3_awuser,
  m_axi_gmem_out3_awvalid,
  m_axi_gmem_out3_wdata,
  m_axi_gmem_out3_wstrb,
  m_axi_gmem_out3_wlast,
  m_axi_gmem_out3_wuser,
  m_axi_gmem_out3_wvalid,
  m_axi_gmem_out3_bready,
  m_axi_gmem_out3_arid,
  m_axi_gmem_out3_araddr,
  m_axi_gmem_out3_arlen,
  m_axi_gmem_out3_arsize,
  m_axi_gmem_out3_arburst,
  m_axi_gmem_out3_arlock,
  m_axi_gmem_out3_arcache,
  m_axi_gmem_out3_arprot,
  m_axi_gmem_out3_arqos,
  m_axi_gmem_out3_arregion,
  m_axi_gmem_out3_aruser,
  m_axi_gmem_out3_arvalid,
  m_axi_gmem_out3_rready,
  m_axi_gmem_out4_awid,
  m_axi_gmem_out4_awaddr,
  m_axi_gmem_out4_awlen,
  m_axi_gmem_out4_awsize,
  m_axi_gmem_out4_awburst,
  m_axi_gmem_out4_awlock,
  m_axi_gmem_out4_awcache,
  m_axi_gmem_out4_awprot,
  m_axi_gmem_out4_awqos,
  m_axi_gmem_out4_awregion,
  m_axi_gmem_out4_awuser,
  m_axi_gmem_out4_awvalid,
  m_axi_gmem_out4_wdata,
  m_axi_gmem_out4_wstrb,
  m_axi_gmem_out4_wlast,
  m_axi_gmem_out4_wuser,
  m_axi_gmem_out4_wvalid,
  m_axi_gmem_out4_bready,
  m_axi_gmem_out4_arid,
  m_axi_gmem_out4_araddr,
  m_axi_gmem_out4_arlen,
  m_axi_gmem_out4_arsize,
  m_axi_gmem_out4_arburst,
  m_axi_gmem_out4_arlock,
  m_axi_gmem_out4_arcache,
  m_axi_gmem_out4_arprot,
  m_axi_gmem_out4_arqos,
  m_axi_gmem_out4_arregion,
  m_axi_gmem_out4_aruser,
  m_axi_gmem_out4_arvalid,
  m_axi_gmem_out4_rready,
  m_axi_gmem_out5_awid,
  m_axi_gmem_out5_awaddr,
  m_axi_gmem_out5_awlen,
  m_axi_gmem_out5_awsize,
  m_axi_gmem_out5_awburst,
  m_axi_gmem_out5_awlock,
  m_axi_gmem_out5_awcache,
  m_axi_gmem_out5_awprot,
  m_axi_gmem_out5_awqos,
  m_axi_gmem_out5_awregion,
  m_axi_gmem_out5_awuser,
  m_axi_gmem_out5_awvalid,
  m_axi_gmem_out5_wdata,
  m_axi_gmem_out5_wstrb,
  m_axi_gmem_out5_wlast,
  m_axi_gmem_out5_wuser,
  m_axi_gmem_out5_wvalid,
  m_axi_gmem_out5_bready,
  m_axi_gmem_out5_arid,
  m_axi_gmem_out5_araddr,
  m_axi_gmem_out5_arlen,
  m_axi_gmem_out5_arsize,
  m_axi_gmem_out5_arburst,
  m_axi_gmem_out5_arlock,
  m_axi_gmem_out5_arcache,
  m_axi_gmem_out5_arprot,
  m_axi_gmem_out5_arqos,
  m_axi_gmem_out5_arregion,
  m_axi_gmem_out5_aruser,
  m_axi_gmem_out5_arvalid,
  m_axi_gmem_out5_rready,
  m_axi_gmem_out6_awid,
  m_axi_gmem_out6_awaddr,
  m_axi_gmem_out6_awlen,
  m_axi_gmem_out6_awsize,
  m_axi_gmem_out6_awburst,
  m_axi_gmem_out6_awlock,
  m_axi_gmem_out6_awcache,
  m_axi_gmem_out6_awprot,
  m_axi_gmem_out6_awqos,
  m_axi_gmem_out6_awregion,
  m_axi_gmem_out6_awuser,
  m_axi_gmem_out6_awvalid,
  m_axi_gmem_out6_wdata,
  m_axi_gmem_out6_wstrb,
  m_axi_gmem_out6_wlast,
  m_axi_gmem_out6_wuser,
  m_axi_gmem_out6_wvalid,
  m_axi_gmem_out6_bready,
  m_axi_gmem_out6_arid,
  m_axi_gmem_out6_araddr,
  m_axi_gmem_out6_arlen,
  m_axi_gmem_out6_arsize,
  m_axi_gmem_out6_arburst,
  m_axi_gmem_out6_arlock,
  m_axi_gmem_out6_arcache,
  m_axi_gmem_out6_arprot,
  m_axi_gmem_out6_arqos,
  m_axi_gmem_out6_arregion,
  m_axi_gmem_out6_aruser,
  m_axi_gmem_out6_arvalid,
  m_axi_gmem_out6_rready,
  m_axi_gmem_out7_awid,
  m_axi_gmem_out7_awaddr,
  m_axi_gmem_out7_awlen,
  m_axi_gmem_out7_awsize,
  m_axi_gmem_out7_awburst,
  m_axi_gmem_out7_awlock,
  m_axi_gmem_out7_awcache,
  m_axi_gmem_out7_awprot,
  m_axi_gmem_out7_awqos,
  m_axi_gmem_out7_awregion,
  m_axi_gmem_out7_awuser,
  m_axi_gmem_out7_awvalid,
  m_axi_gmem_out7_wdata,
  m_axi_gmem_out7_wstrb,
  m_axi_gmem_out7_wlast,
  m_axi_gmem_out7_wuser,
  m_axi_gmem_out7_wvalid,
  m_axi_gmem_out7_bready,
  m_axi_gmem_out7_arid,
  m_axi_gmem_out7_araddr,
  m_axi_gmem_out7_arlen,
  m_axi_gmem_out7_arsize,
  m_axi_gmem_out7_arburst,
  m_axi_gmem_out7_arlock,
  m_axi_gmem_out7_arcache,
  m_axi_gmem_out7_arprot,
  m_axi_gmem_out7_arqos,
  m_axi_gmem_out7_arregion,
  m_axi_gmem_out7_aruser,
  m_axi_gmem_out7_arvalid,
  m_axi_gmem_out7_rready,
  m_axi_gmem_w0_awid,
  m_axi_gmem_w0_awaddr,
  m_axi_gmem_w0_awlen,
  m_axi_gmem_w0_awsize,
  m_axi_gmem_w0_awburst,
  m_axi_gmem_w0_awlock,
  m_axi_gmem_w0_awcache,
  m_axi_gmem_w0_awprot,
  m_axi_gmem_w0_awqos,
  m_axi_gmem_w0_awregion,
  m_axi_gmem_w0_awuser,
  m_axi_gmem_w0_awvalid,
  m_axi_gmem_w0_wdata,
  m_axi_gmem_w0_wstrb,
  m_axi_gmem_w0_wlast,
  m_axi_gmem_w0_wuser,
  m_axi_gmem_w0_wvalid,
  m_axi_gmem_w0_bready,
  m_axi_gmem_w0_arid,
  m_axi_gmem_w0_araddr,
  m_axi_gmem_w0_arlen,
  m_axi_gmem_w0_arsize,
  m_axi_gmem_w0_arburst,
  m_axi_gmem_w0_arlock,
  m_axi_gmem_w0_arcache,
  m_axi_gmem_w0_arprot,
  m_axi_gmem_w0_arqos,
  m_axi_gmem_w0_arregion,
  m_axi_gmem_w0_aruser,
  m_axi_gmem_w0_arvalid,
  m_axi_gmem_w0_rready,
  m_axi_gmem_w1_awid,
  m_axi_gmem_w1_awaddr,
  m_axi_gmem_w1_awlen,
  m_axi_gmem_w1_awsize,
  m_axi_gmem_w1_awburst,
  m_axi_gmem_w1_awlock,
  m_axi_gmem_w1_awcache,
  m_axi_gmem_w1_awprot,
  m_axi_gmem_w1_awqos,
  m_axi_gmem_w1_awregion,
  m_axi_gmem_w1_awuser,
  m_axi_gmem_w1_awvalid,
  m_axi_gmem_w1_wdata,
  m_axi_gmem_w1_wstrb,
  m_axi_gmem_w1_wlast,
  m_axi_gmem_w1_wuser,
  m_axi_gmem_w1_wvalid,
  m_axi_gmem_w1_bready,
  m_axi_gmem_w1_arid,
  m_axi_gmem_w1_araddr,
  m_axi_gmem_w1_arlen,
  m_axi_gmem_w1_arsize,
  m_axi_gmem_w1_arburst,
  m_axi_gmem_w1_arlock,
  m_axi_gmem_w1_arcache,
  m_axi_gmem_w1_arprot,
  m_axi_gmem_w1_arqos,
  m_axi_gmem_w1_arregion,
  m_axi_gmem_w1_aruser,
  m_axi_gmem_w1_arvalid,
  m_axi_gmem_w1_rready);
  // IN
  input clock;
  input reset;
  input start_port;
  input [31:0] dram_in_b0;
  input [31:0] dram_in_b1;
  input [31:0] dram_w_b0;
  input [31:0] dram_w_b1;
  input [31:0] dram_out_b0;
  input [31:0] dram_out_b1;
  input [31:0] dram_out_b2;
  input [31:0] dram_out_b3;
  input [31:0] dram_out_b4;
  input [31:0] dram_out_b5;
  input [31:0] dram_out_b6;
  input [31:0] dram_out_b7;
  input cache_reset;
  input m_axi_gmem_in0_awready;
  input m_axi_gmem_in0_wready;
  input [5:0] m_axi_gmem_in0_bid;
  input [1:0] m_axi_gmem_in0_bresp;
  input m_axi_gmem_in0_buser;
  input m_axi_gmem_in0_bvalid;
  input m_axi_gmem_in0_arready;
  input [5:0] m_axi_gmem_in0_rid;
  input [31:0] m_axi_gmem_in0_rdata;
  input [1:0] m_axi_gmem_in0_rresp;
  input m_axi_gmem_in0_rlast;
  input m_axi_gmem_in0_ruser;
  input m_axi_gmem_in0_rvalid;
  input m_axi_gmem_in1_awready;
  input m_axi_gmem_in1_wready;
  input [5:0] m_axi_gmem_in1_bid;
  input [1:0] m_axi_gmem_in1_bresp;
  input m_axi_gmem_in1_buser;
  input m_axi_gmem_in1_bvalid;
  input m_axi_gmem_in1_arready;
  input [5:0] m_axi_gmem_in1_rid;
  input [31:0] m_axi_gmem_in1_rdata;
  input [1:0] m_axi_gmem_in1_rresp;
  input m_axi_gmem_in1_rlast;
  input m_axi_gmem_in1_ruser;
  input m_axi_gmem_in1_rvalid;
  input m_axi_gmem_out0_awready;
  input m_axi_gmem_out0_wready;
  input [5:0] m_axi_gmem_out0_bid;
  input [1:0] m_axi_gmem_out0_bresp;
  input m_axi_gmem_out0_buser;
  input m_axi_gmem_out0_bvalid;
  input m_axi_gmem_out0_arready;
  input [5:0] m_axi_gmem_out0_rid;
  input [31:0] m_axi_gmem_out0_rdata;
  input [1:0] m_axi_gmem_out0_rresp;
  input m_axi_gmem_out0_rlast;
  input m_axi_gmem_out0_ruser;
  input m_axi_gmem_out0_rvalid;
  input m_axi_gmem_out1_awready;
  input m_axi_gmem_out1_wready;
  input [5:0] m_axi_gmem_out1_bid;
  input [1:0] m_axi_gmem_out1_bresp;
  input m_axi_gmem_out1_buser;
  input m_axi_gmem_out1_bvalid;
  input m_axi_gmem_out1_arready;
  input [5:0] m_axi_gmem_out1_rid;
  input [31:0] m_axi_gmem_out1_rdata;
  input [1:0] m_axi_gmem_out1_rresp;
  input m_axi_gmem_out1_rlast;
  input m_axi_gmem_out1_ruser;
  input m_axi_gmem_out1_rvalid;
  input m_axi_gmem_out2_awready;
  input m_axi_gmem_out2_wready;
  input [5:0] m_axi_gmem_out2_bid;
  input [1:0] m_axi_gmem_out2_bresp;
  input m_axi_gmem_out2_buser;
  input m_axi_gmem_out2_bvalid;
  input m_axi_gmem_out2_arready;
  input [5:0] m_axi_gmem_out2_rid;
  input [31:0] m_axi_gmem_out2_rdata;
  input [1:0] m_axi_gmem_out2_rresp;
  input m_axi_gmem_out2_rlast;
  input m_axi_gmem_out2_ruser;
  input m_axi_gmem_out2_rvalid;
  input m_axi_gmem_out3_awready;
  input m_axi_gmem_out3_wready;
  input [5:0] m_axi_gmem_out3_bid;
  input [1:0] m_axi_gmem_out3_bresp;
  input m_axi_gmem_out3_buser;
  input m_axi_gmem_out3_bvalid;
  input m_axi_gmem_out3_arready;
  input [5:0] m_axi_gmem_out3_rid;
  input [31:0] m_axi_gmem_out3_rdata;
  input [1:0] m_axi_gmem_out3_rresp;
  input m_axi_gmem_out3_rlast;
  input m_axi_gmem_out3_ruser;
  input m_axi_gmem_out3_rvalid;
  input m_axi_gmem_out4_awready;
  input m_axi_gmem_out4_wready;
  input [5:0] m_axi_gmem_out4_bid;
  input [1:0] m_axi_gmem_out4_bresp;
  input m_axi_gmem_out4_buser;
  input m_axi_gmem_out4_bvalid;
  input m_axi_gmem_out4_arready;
  input [5:0] m_axi_gmem_out4_rid;
  input [31:0] m_axi_gmem_out4_rdata;
  input [1:0] m_axi_gmem_out4_rresp;
  input m_axi_gmem_out4_rlast;
  input m_axi_gmem_out4_ruser;
  input m_axi_gmem_out4_rvalid;
  input m_axi_gmem_out5_awready;
  input m_axi_gmem_out5_wready;
  input [5:0] m_axi_gmem_out5_bid;
  input [1:0] m_axi_gmem_out5_bresp;
  input m_axi_gmem_out5_buser;
  input m_axi_gmem_out5_bvalid;
  input m_axi_gmem_out5_arready;
  input [5:0] m_axi_gmem_out5_rid;
  input [31:0] m_axi_gmem_out5_rdata;
  input [1:0] m_axi_gmem_out5_rresp;
  input m_axi_gmem_out5_rlast;
  input m_axi_gmem_out5_ruser;
  input m_axi_gmem_out5_rvalid;
  input m_axi_gmem_out6_awready;
  input m_axi_gmem_out6_wready;
  input [5:0] m_axi_gmem_out6_bid;
  input [1:0] m_axi_gmem_out6_bresp;
  input m_axi_gmem_out6_buser;
  input m_axi_gmem_out6_bvalid;
  input m_axi_gmem_out6_arready;
  input [5:0] m_axi_gmem_out6_rid;
  input [31:0] m_axi_gmem_out6_rdata;
  input [1:0] m_axi_gmem_out6_rresp;
  input m_axi_gmem_out6_rlast;
  input m_axi_gmem_out6_ruser;
  input m_axi_gmem_out6_rvalid;
  input m_axi_gmem_out7_awready;
  input m_axi_gmem_out7_wready;
  input [5:0] m_axi_gmem_out7_bid;
  input [1:0] m_axi_gmem_out7_bresp;
  input m_axi_gmem_out7_buser;
  input m_axi_gmem_out7_bvalid;
  input m_axi_gmem_out7_arready;
  input [5:0] m_axi_gmem_out7_rid;
  input [31:0] m_axi_gmem_out7_rdata;
  input [1:0] m_axi_gmem_out7_rresp;
  input m_axi_gmem_out7_rlast;
  input m_axi_gmem_out7_ruser;
  input m_axi_gmem_out7_rvalid;
  input m_axi_gmem_w0_awready;
  input m_axi_gmem_w0_wready;
  input [5:0] m_axi_gmem_w0_bid;
  input [1:0] m_axi_gmem_w0_bresp;
  input m_axi_gmem_w0_buser;
  input m_axi_gmem_w0_bvalid;
  input m_axi_gmem_w0_arready;
  input [5:0] m_axi_gmem_w0_rid;
  input [31:0] m_axi_gmem_w0_rdata;
  input [1:0] m_axi_gmem_w0_rresp;
  input m_axi_gmem_w0_rlast;
  input m_axi_gmem_w0_ruser;
  input m_axi_gmem_w0_rvalid;
  input m_axi_gmem_w1_awready;
  input m_axi_gmem_w1_wready;
  input [5:0] m_axi_gmem_w1_bid;
  input [1:0] m_axi_gmem_w1_bresp;
  input m_axi_gmem_w1_buser;
  input m_axi_gmem_w1_bvalid;
  input m_axi_gmem_w1_arready;
  input [5:0] m_axi_gmem_w1_rid;
  input [31:0] m_axi_gmem_w1_rdata;
  input [1:0] m_axi_gmem_w1_rresp;
  input m_axi_gmem_w1_rlast;
  input m_axi_gmem_w1_ruser;
  input m_axi_gmem_w1_rvalid;
  // OUT
  output done_port;
  output [5:0] m_axi_gmem_in0_awid;
  output [31:0] m_axi_gmem_in0_awaddr;
  output [7:0] m_axi_gmem_in0_awlen;
  output [2:0] m_axi_gmem_in0_awsize;
  output [1:0] m_axi_gmem_in0_awburst;
  output m_axi_gmem_in0_awlock;
  output [3:0] m_axi_gmem_in0_awcache;
  output [2:0] m_axi_gmem_in0_awprot;
  output [3:0] m_axi_gmem_in0_awqos;
  output [3:0] m_axi_gmem_in0_awregion;
  output m_axi_gmem_in0_awuser;
  output m_axi_gmem_in0_awvalid;
  output [31:0] m_axi_gmem_in0_wdata;
  output [3:0] m_axi_gmem_in0_wstrb;
  output m_axi_gmem_in0_wlast;
  output m_axi_gmem_in0_wuser;
  output m_axi_gmem_in0_wvalid;
  output m_axi_gmem_in0_bready;
  output [5:0] m_axi_gmem_in0_arid;
  output [31:0] m_axi_gmem_in0_araddr;
  output [7:0] m_axi_gmem_in0_arlen;
  output [2:0] m_axi_gmem_in0_arsize;
  output [1:0] m_axi_gmem_in0_arburst;
  output m_axi_gmem_in0_arlock;
  output [3:0] m_axi_gmem_in0_arcache;
  output [2:0] m_axi_gmem_in0_arprot;
  output [3:0] m_axi_gmem_in0_arqos;
  output [3:0] m_axi_gmem_in0_arregion;
  output m_axi_gmem_in0_aruser;
  output m_axi_gmem_in0_arvalid;
  output m_axi_gmem_in0_rready;
  output [5:0] m_axi_gmem_in1_awid;
  output [31:0] m_axi_gmem_in1_awaddr;
  output [7:0] m_axi_gmem_in1_awlen;
  output [2:0] m_axi_gmem_in1_awsize;
  output [1:0] m_axi_gmem_in1_awburst;
  output m_axi_gmem_in1_awlock;
  output [3:0] m_axi_gmem_in1_awcache;
  output [2:0] m_axi_gmem_in1_awprot;
  output [3:0] m_axi_gmem_in1_awqos;
  output [3:0] m_axi_gmem_in1_awregion;
  output m_axi_gmem_in1_awuser;
  output m_axi_gmem_in1_awvalid;
  output [31:0] m_axi_gmem_in1_wdata;
  output [3:0] m_axi_gmem_in1_wstrb;
  output m_axi_gmem_in1_wlast;
  output m_axi_gmem_in1_wuser;
  output m_axi_gmem_in1_wvalid;
  output m_axi_gmem_in1_bready;
  output [5:0] m_axi_gmem_in1_arid;
  output [31:0] m_axi_gmem_in1_araddr;
  output [7:0] m_axi_gmem_in1_arlen;
  output [2:0] m_axi_gmem_in1_arsize;
  output [1:0] m_axi_gmem_in1_arburst;
  output m_axi_gmem_in1_arlock;
  output [3:0] m_axi_gmem_in1_arcache;
  output [2:0] m_axi_gmem_in1_arprot;
  output [3:0] m_axi_gmem_in1_arqos;
  output [3:0] m_axi_gmem_in1_arregion;
  output m_axi_gmem_in1_aruser;
  output m_axi_gmem_in1_arvalid;
  output m_axi_gmem_in1_rready;
  output [5:0] m_axi_gmem_out0_awid;
  output [31:0] m_axi_gmem_out0_awaddr;
  output [7:0] m_axi_gmem_out0_awlen;
  output [2:0] m_axi_gmem_out0_awsize;
  output [1:0] m_axi_gmem_out0_awburst;
  output m_axi_gmem_out0_awlock;
  output [3:0] m_axi_gmem_out0_awcache;
  output [2:0] m_axi_gmem_out0_awprot;
  output [3:0] m_axi_gmem_out0_awqos;
  output [3:0] m_axi_gmem_out0_awregion;
  output m_axi_gmem_out0_awuser;
  output m_axi_gmem_out0_awvalid;
  output [31:0] m_axi_gmem_out0_wdata;
  output [3:0] m_axi_gmem_out0_wstrb;
  output m_axi_gmem_out0_wlast;
  output m_axi_gmem_out0_wuser;
  output m_axi_gmem_out0_wvalid;
  output m_axi_gmem_out0_bready;
  output [5:0] m_axi_gmem_out0_arid;
  output [31:0] m_axi_gmem_out0_araddr;
  output [7:0] m_axi_gmem_out0_arlen;
  output [2:0] m_axi_gmem_out0_arsize;
  output [1:0] m_axi_gmem_out0_arburst;
  output m_axi_gmem_out0_arlock;
  output [3:0] m_axi_gmem_out0_arcache;
  output [2:0] m_axi_gmem_out0_arprot;
  output [3:0] m_axi_gmem_out0_arqos;
  output [3:0] m_axi_gmem_out0_arregion;
  output m_axi_gmem_out0_aruser;
  output m_axi_gmem_out0_arvalid;
  output m_axi_gmem_out0_rready;
  output [5:0] m_axi_gmem_out1_awid;
  output [31:0] m_axi_gmem_out1_awaddr;
  output [7:0] m_axi_gmem_out1_awlen;
  output [2:0] m_axi_gmem_out1_awsize;
  output [1:0] m_axi_gmem_out1_awburst;
  output m_axi_gmem_out1_awlock;
  output [3:0] m_axi_gmem_out1_awcache;
  output [2:0] m_axi_gmem_out1_awprot;
  output [3:0] m_axi_gmem_out1_awqos;
  output [3:0] m_axi_gmem_out1_awregion;
  output m_axi_gmem_out1_awuser;
  output m_axi_gmem_out1_awvalid;
  output [31:0] m_axi_gmem_out1_wdata;
  output [3:0] m_axi_gmem_out1_wstrb;
  output m_axi_gmem_out1_wlast;
  output m_axi_gmem_out1_wuser;
  output m_axi_gmem_out1_wvalid;
  output m_axi_gmem_out1_bready;
  output [5:0] m_axi_gmem_out1_arid;
  output [31:0] m_axi_gmem_out1_araddr;
  output [7:0] m_axi_gmem_out1_arlen;
  output [2:0] m_axi_gmem_out1_arsize;
  output [1:0] m_axi_gmem_out1_arburst;
  output m_axi_gmem_out1_arlock;
  output [3:0] m_axi_gmem_out1_arcache;
  output [2:0] m_axi_gmem_out1_arprot;
  output [3:0] m_axi_gmem_out1_arqos;
  output [3:0] m_axi_gmem_out1_arregion;
  output m_axi_gmem_out1_aruser;
  output m_axi_gmem_out1_arvalid;
  output m_axi_gmem_out1_rready;
  output [5:0] m_axi_gmem_out2_awid;
  output [31:0] m_axi_gmem_out2_awaddr;
  output [7:0] m_axi_gmem_out2_awlen;
  output [2:0] m_axi_gmem_out2_awsize;
  output [1:0] m_axi_gmem_out2_awburst;
  output m_axi_gmem_out2_awlock;
  output [3:0] m_axi_gmem_out2_awcache;
  output [2:0] m_axi_gmem_out2_awprot;
  output [3:0] m_axi_gmem_out2_awqos;
  output [3:0] m_axi_gmem_out2_awregion;
  output m_axi_gmem_out2_awuser;
  output m_axi_gmem_out2_awvalid;
  output [31:0] m_axi_gmem_out2_wdata;
  output [3:0] m_axi_gmem_out2_wstrb;
  output m_axi_gmem_out2_wlast;
  output m_axi_gmem_out2_wuser;
  output m_axi_gmem_out2_wvalid;
  output m_axi_gmem_out2_bready;
  output [5:0] m_axi_gmem_out2_arid;
  output [31:0] m_axi_gmem_out2_araddr;
  output [7:0] m_axi_gmem_out2_arlen;
  output [2:0] m_axi_gmem_out2_arsize;
  output [1:0] m_axi_gmem_out2_arburst;
  output m_axi_gmem_out2_arlock;
  output [3:0] m_axi_gmem_out2_arcache;
  output [2:0] m_axi_gmem_out2_arprot;
  output [3:0] m_axi_gmem_out2_arqos;
  output [3:0] m_axi_gmem_out2_arregion;
  output m_axi_gmem_out2_aruser;
  output m_axi_gmem_out2_arvalid;
  output m_axi_gmem_out2_rready;
  output [5:0] m_axi_gmem_out3_awid;
  output [31:0] m_axi_gmem_out3_awaddr;
  output [7:0] m_axi_gmem_out3_awlen;
  output [2:0] m_axi_gmem_out3_awsize;
  output [1:0] m_axi_gmem_out3_awburst;
  output m_axi_gmem_out3_awlock;
  output [3:0] m_axi_gmem_out3_awcache;
  output [2:0] m_axi_gmem_out3_awprot;
  output [3:0] m_axi_gmem_out3_awqos;
  output [3:0] m_axi_gmem_out3_awregion;
  output m_axi_gmem_out3_awuser;
  output m_axi_gmem_out3_awvalid;
  output [31:0] m_axi_gmem_out3_wdata;
  output [3:0] m_axi_gmem_out3_wstrb;
  output m_axi_gmem_out3_wlast;
  output m_axi_gmem_out3_wuser;
  output m_axi_gmem_out3_wvalid;
  output m_axi_gmem_out3_bready;
  output [5:0] m_axi_gmem_out3_arid;
  output [31:0] m_axi_gmem_out3_araddr;
  output [7:0] m_axi_gmem_out3_arlen;
  output [2:0] m_axi_gmem_out3_arsize;
  output [1:0] m_axi_gmem_out3_arburst;
  output m_axi_gmem_out3_arlock;
  output [3:0] m_axi_gmem_out3_arcache;
  output [2:0] m_axi_gmem_out3_arprot;
  output [3:0] m_axi_gmem_out3_arqos;
  output [3:0] m_axi_gmem_out3_arregion;
  output m_axi_gmem_out3_aruser;
  output m_axi_gmem_out3_arvalid;
  output m_axi_gmem_out3_rready;
  output [5:0] m_axi_gmem_out4_awid;
  output [31:0] m_axi_gmem_out4_awaddr;
  output [7:0] m_axi_gmem_out4_awlen;
  output [2:0] m_axi_gmem_out4_awsize;
  output [1:0] m_axi_gmem_out4_awburst;
  output m_axi_gmem_out4_awlock;
  output [3:0] m_axi_gmem_out4_awcache;
  output [2:0] m_axi_gmem_out4_awprot;
  output [3:0] m_axi_gmem_out4_awqos;
  output [3:0] m_axi_gmem_out4_awregion;
  output m_axi_gmem_out4_awuser;
  output m_axi_gmem_out4_awvalid;
  output [31:0] m_axi_gmem_out4_wdata;
  output [3:0] m_axi_gmem_out4_wstrb;
  output m_axi_gmem_out4_wlast;
  output m_axi_gmem_out4_wuser;
  output m_axi_gmem_out4_wvalid;
  output m_axi_gmem_out4_bready;
  output [5:0] m_axi_gmem_out4_arid;
  output [31:0] m_axi_gmem_out4_araddr;
  output [7:0] m_axi_gmem_out4_arlen;
  output [2:0] m_axi_gmem_out4_arsize;
  output [1:0] m_axi_gmem_out4_arburst;
  output m_axi_gmem_out4_arlock;
  output [3:0] m_axi_gmem_out4_arcache;
  output [2:0] m_axi_gmem_out4_arprot;
  output [3:0] m_axi_gmem_out4_arqos;
  output [3:0] m_axi_gmem_out4_arregion;
  output m_axi_gmem_out4_aruser;
  output m_axi_gmem_out4_arvalid;
  output m_axi_gmem_out4_rready;
  output [5:0] m_axi_gmem_out5_awid;
  output [31:0] m_axi_gmem_out5_awaddr;
  output [7:0] m_axi_gmem_out5_awlen;
  output [2:0] m_axi_gmem_out5_awsize;
  output [1:0] m_axi_gmem_out5_awburst;
  output m_axi_gmem_out5_awlock;
  output [3:0] m_axi_gmem_out5_awcache;
  output [2:0] m_axi_gmem_out5_awprot;
  output [3:0] m_axi_gmem_out5_awqos;
  output [3:0] m_axi_gmem_out5_awregion;
  output m_axi_gmem_out5_awuser;
  output m_axi_gmem_out5_awvalid;
  output [31:0] m_axi_gmem_out5_wdata;
  output [3:0] m_axi_gmem_out5_wstrb;
  output m_axi_gmem_out5_wlast;
  output m_axi_gmem_out5_wuser;
  output m_axi_gmem_out5_wvalid;
  output m_axi_gmem_out5_bready;
  output [5:0] m_axi_gmem_out5_arid;
  output [31:0] m_axi_gmem_out5_araddr;
  output [7:0] m_axi_gmem_out5_arlen;
  output [2:0] m_axi_gmem_out5_arsize;
  output [1:0] m_axi_gmem_out5_arburst;
  output m_axi_gmem_out5_arlock;
  output [3:0] m_axi_gmem_out5_arcache;
  output [2:0] m_axi_gmem_out5_arprot;
  output [3:0] m_axi_gmem_out5_arqos;
  output [3:0] m_axi_gmem_out5_arregion;
  output m_axi_gmem_out5_aruser;
  output m_axi_gmem_out5_arvalid;
  output m_axi_gmem_out5_rready;
  output [5:0] m_axi_gmem_out6_awid;
  output [31:0] m_axi_gmem_out6_awaddr;
  output [7:0] m_axi_gmem_out6_awlen;
  output [2:0] m_axi_gmem_out6_awsize;
  output [1:0] m_axi_gmem_out6_awburst;
  output m_axi_gmem_out6_awlock;
  output [3:0] m_axi_gmem_out6_awcache;
  output [2:0] m_axi_gmem_out6_awprot;
  output [3:0] m_axi_gmem_out6_awqos;
  output [3:0] m_axi_gmem_out6_awregion;
  output m_axi_gmem_out6_awuser;
  output m_axi_gmem_out6_awvalid;
  output [31:0] m_axi_gmem_out6_wdata;
  output [3:0] m_axi_gmem_out6_wstrb;
  output m_axi_gmem_out6_wlast;
  output m_axi_gmem_out6_wuser;
  output m_axi_gmem_out6_wvalid;
  output m_axi_gmem_out6_bready;
  output [5:0] m_axi_gmem_out6_arid;
  output [31:0] m_axi_gmem_out6_araddr;
  output [7:0] m_axi_gmem_out6_arlen;
  output [2:0] m_axi_gmem_out6_arsize;
  output [1:0] m_axi_gmem_out6_arburst;
  output m_axi_gmem_out6_arlock;
  output [3:0] m_axi_gmem_out6_arcache;
  output [2:0] m_axi_gmem_out6_arprot;
  output [3:0] m_axi_gmem_out6_arqos;
  output [3:0] m_axi_gmem_out6_arregion;
  output m_axi_gmem_out6_aruser;
  output m_axi_gmem_out6_arvalid;
  output m_axi_gmem_out6_rready;
  output [5:0] m_axi_gmem_out7_awid;
  output [31:0] m_axi_gmem_out7_awaddr;
  output [7:0] m_axi_gmem_out7_awlen;
  output [2:0] m_axi_gmem_out7_awsize;
  output [1:0] m_axi_gmem_out7_awburst;
  output m_axi_gmem_out7_awlock;
  output [3:0] m_axi_gmem_out7_awcache;
  output [2:0] m_axi_gmem_out7_awprot;
  output [3:0] m_axi_gmem_out7_awqos;
  output [3:0] m_axi_gmem_out7_awregion;
  output m_axi_gmem_out7_awuser;
  output m_axi_gmem_out7_awvalid;
  output [31:0] m_axi_gmem_out7_wdata;
  output [3:0] m_axi_gmem_out7_wstrb;
  output m_axi_gmem_out7_wlast;
  output m_axi_gmem_out7_wuser;
  output m_axi_gmem_out7_wvalid;
  output m_axi_gmem_out7_bready;
  output [5:0] m_axi_gmem_out7_arid;
  output [31:0] m_axi_gmem_out7_araddr;
  output [7:0] m_axi_gmem_out7_arlen;
  output [2:0] m_axi_gmem_out7_arsize;
  output [1:0] m_axi_gmem_out7_arburst;
  output m_axi_gmem_out7_arlock;
  output [3:0] m_axi_gmem_out7_arcache;
  output [2:0] m_axi_gmem_out7_arprot;
  output [3:0] m_axi_gmem_out7_arqos;
  output [3:0] m_axi_gmem_out7_arregion;
  output m_axi_gmem_out7_aruser;
  output m_axi_gmem_out7_arvalid;
  output m_axi_gmem_out7_rready;
  output [5:0] m_axi_gmem_w0_awid;
  output [31:0] m_axi_gmem_w0_awaddr;
  output [7:0] m_axi_gmem_w0_awlen;
  output [2:0] m_axi_gmem_w0_awsize;
  output [1:0] m_axi_gmem_w0_awburst;
  output m_axi_gmem_w0_awlock;
  output [3:0] m_axi_gmem_w0_awcache;
  output [2:0] m_axi_gmem_w0_awprot;
  output [3:0] m_axi_gmem_w0_awqos;
  output [3:0] m_axi_gmem_w0_awregion;
  output m_axi_gmem_w0_awuser;
  output m_axi_gmem_w0_awvalid;
  output [31:0] m_axi_gmem_w0_wdata;
  output [3:0] m_axi_gmem_w0_wstrb;
  output m_axi_gmem_w0_wlast;
  output m_axi_gmem_w0_wuser;
  output m_axi_gmem_w0_wvalid;
  output m_axi_gmem_w0_bready;
  output [5:0] m_axi_gmem_w0_arid;
  output [31:0] m_axi_gmem_w0_araddr;
  output [7:0] m_axi_gmem_w0_arlen;
  output [2:0] m_axi_gmem_w0_arsize;
  output [1:0] m_axi_gmem_w0_arburst;
  output m_axi_gmem_w0_arlock;
  output [3:0] m_axi_gmem_w0_arcache;
  output [2:0] m_axi_gmem_w0_arprot;
  output [3:0] m_axi_gmem_w0_arqos;
  output [3:0] m_axi_gmem_w0_arregion;
  output m_axi_gmem_w0_aruser;
  output m_axi_gmem_w0_arvalid;
  output m_axi_gmem_w0_rready;
  output [5:0] m_axi_gmem_w1_awid;
  output [31:0] m_axi_gmem_w1_awaddr;
  output [7:0] m_axi_gmem_w1_awlen;
  output [2:0] m_axi_gmem_w1_awsize;
  output [1:0] m_axi_gmem_w1_awburst;
  output m_axi_gmem_w1_awlock;
  output [3:0] m_axi_gmem_w1_awcache;
  output [2:0] m_axi_gmem_w1_awprot;
  output [3:0] m_axi_gmem_w1_awqos;
  output [3:0] m_axi_gmem_w1_awregion;
  output m_axi_gmem_w1_awuser;
  output m_axi_gmem_w1_awvalid;
  output [31:0] m_axi_gmem_w1_wdata;
  output [3:0] m_axi_gmem_w1_wstrb;
  output m_axi_gmem_w1_wlast;
  output m_axi_gmem_w1_wuser;
  output m_axi_gmem_w1_wvalid;
  output m_axi_gmem_w1_bready;
  output [5:0] m_axi_gmem_w1_arid;
  output [31:0] m_axi_gmem_w1_araddr;
  output [7:0] m_axi_gmem_w1_arlen;
  output [2:0] m_axi_gmem_w1_arsize;
  output [1:0] m_axi_gmem_w1_arburst;
  output m_axi_gmem_w1_arlock;
  output [3:0] m_axi_gmem_w1_arcache;
  output [2:0] m_axi_gmem_w1_arprot;
  output [3:0] m_axi_gmem_w1_arqos;
  output [3:0] m_axi_gmem_w1_arregion;
  output m_axi_gmem_w1_aruser;
  output m_axi_gmem_w1_arvalid;
  output m_axi_gmem_w1_rready;
  
  
  top_level top(
    .clock(clock),
    .reset(reset),
    .start_port(start_port),
    .dram_in_b0(dram_in_b0),
    .dram_in_b1(dram_in_b1),
    .dram_w_b0(dram_w_b0),
    .dram_w_b1(dram_w_b1),
    .dram_out_b0(dram_out_b0),
    .dram_out_b1(dram_out_b1),
    .dram_out_b2(dram_out_b2),
    .dram_out_b3(dram_out_b3),
    .dram_out_b4(dram_out_b4),
    .dram_out_b5(dram_out_b5),
    .dram_out_b6(dram_out_b6),
    .dram_out_b7(dram_out_b7),
    .cache_reset(cache_reset),
    .m_axi_gmem_in0_awready(m_axi_gmem_in0_awready),
    .m_axi_gmem_in0_wready(m_axi_gmem_in0_wready),
    .m_axi_gmem_in0_bid(m_axi_gmem_in0_bid),
    .m_axi_gmem_in0_bresp(m_axi_gmem_in0_bresp),
    .m_axi_gmem_in0_buser(m_axi_gmem_in0_buser),
    .m_axi_gmem_in0_bvalid(m_axi_gmem_in0_bvalid),
    .m_axi_gmem_in0_arready(m_axi_gmem_in0_arready),
    .m_axi_gmem_in0_rid(m_axi_gmem_in0_rid),
    .m_axi_gmem_in0_rdata(m_axi_gmem_in0_rdata),
    .m_axi_gmem_in0_rresp(m_axi_gmem_in0_rresp),
    .m_axi_gmem_in0_rlast(m_axi_gmem_in0_rlast),
    .m_axi_gmem_in0_ruser(m_axi_gmem_in0_ruser),
    .m_axi_gmem_in0_rvalid(m_axi_gmem_in0_rvalid),
    .m_axi_gmem_in1_awready(m_axi_gmem_in1_awready),
    .m_axi_gmem_in1_wready(m_axi_gmem_in1_wready),
    .m_axi_gmem_in1_bid(m_axi_gmem_in1_bid),
    .m_axi_gmem_in1_bresp(m_axi_gmem_in1_bresp),
    .m_axi_gmem_in1_buser(m_axi_gmem_in1_buser),
    .m_axi_gmem_in1_bvalid(m_axi_gmem_in1_bvalid),
    .m_axi_gmem_in1_arready(m_axi_gmem_in1_arready),
    .m_axi_gmem_in1_rid(m_axi_gmem_in1_rid),
    .m_axi_gmem_in1_rdata(m_axi_gmem_in1_rdata),
    .m_axi_gmem_in1_rresp(m_axi_gmem_in1_rresp),
    .m_axi_gmem_in1_rlast(m_axi_gmem_in1_rlast),
    .m_axi_gmem_in1_ruser(m_axi_gmem_in1_ruser),
    .m_axi_gmem_in1_rvalid(m_axi_gmem_in1_rvalid),
    .m_axi_gmem_out0_awready(m_axi_gmem_out0_awready),
    .m_axi_gmem_out0_wready(m_axi_gmem_out0_wready),
    .m_axi_gmem_out0_bid(m_axi_gmem_out0_bid),
    .m_axi_gmem_out0_bresp(m_axi_gmem_out0_bresp),
    .m_axi_gmem_out0_buser(m_axi_gmem_out0_buser),
    .m_axi_gmem_out0_bvalid(m_axi_gmem_out0_bvalid),
    .m_axi_gmem_out0_arready(m_axi_gmem_out0_arready),
    .m_axi_gmem_out0_rid(m_axi_gmem_out0_rid),
    .m_axi_gmem_out0_rdata(m_axi_gmem_out0_rdata),
    .m_axi_gmem_out0_rresp(m_axi_gmem_out0_rresp),
    .m_axi_gmem_out0_rlast(m_axi_gmem_out0_rlast),
    .m_axi_gmem_out0_ruser(m_axi_gmem_out0_ruser),
    .m_axi_gmem_out0_rvalid(m_axi_gmem_out0_rvalid),
    .m_axi_gmem_out1_awready(m_axi_gmem_out1_awready),
    .m_axi_gmem_out1_wready(m_axi_gmem_out1_wready),
    .m_axi_gmem_out1_bid(m_axi_gmem_out1_bid),
    .m_axi_gmem_out1_bresp(m_axi_gmem_out1_bresp),
    .m_axi_gmem_out1_buser(m_axi_gmem_out1_buser),
    .m_axi_gmem_out1_bvalid(m_axi_gmem_out1_bvalid),
    .m_axi_gmem_out1_arready(m_axi_gmem_out1_arready),
    .m_axi_gmem_out1_rid(m_axi_gmem_out1_rid),
    .m_axi_gmem_out1_rdata(m_axi_gmem_out1_rdata),
    .m_axi_gmem_out1_rresp(m_axi_gmem_out1_rresp),
    .m_axi_gmem_out1_rlast(m_axi_gmem_out1_rlast),
    .m_axi_gmem_out1_ruser(m_axi_gmem_out1_ruser),
    .m_axi_gmem_out1_rvalid(m_axi_gmem_out1_rvalid),
    .m_axi_gmem_out2_awready(m_axi_gmem_out2_awready),
    .m_axi_gmem_out2_wready(m_axi_gmem_out2_wready),
    .m_axi_gmem_out2_bid(m_axi_gmem_out2_bid),
    .m_axi_gmem_out2_bresp(m_axi_gmem_out2_bresp),
    .m_axi_gmem_out2_buser(m_axi_gmem_out2_buser),
    .m_axi_gmem_out2_bvalid(m_axi_gmem_out2_bvalid),
    .m_axi_gmem_out2_arready(m_axi_gmem_out2_arready),
    .m_axi_gmem_out2_rid(m_axi_gmem_out2_rid),
    .m_axi_gmem_out2_rdata(m_axi_gmem_out2_rdata),
    .m_axi_gmem_out2_rresp(m_axi_gmem_out2_rresp),
    .m_axi_gmem_out2_rlast(m_axi_gmem_out2_rlast),
    .m_axi_gmem_out2_ruser(m_axi_gmem_out2_ruser),
    .m_axi_gmem_out2_rvalid(m_axi_gmem_out2_rvalid),
    .m_axi_gmem_out3_awready(m_axi_gmem_out3_awready),
    .m_axi_gmem_out3_wready(m_axi_gmem_out3_wready),
    .m_axi_gmem_out3_bid(m_axi_gmem_out3_bid),
    .m_axi_gmem_out3_bresp(m_axi_gmem_out3_bresp),
    .m_axi_gmem_out3_buser(m_axi_gmem_out3_buser),
    .m_axi_gmem_out3_bvalid(m_axi_gmem_out3_bvalid),
    .m_axi_gmem_out3_arready(m_axi_gmem_out3_arready),
    .m_axi_gmem_out3_rid(m_axi_gmem_out3_rid),
    .m_axi_gmem_out3_rdata(m_axi_gmem_out3_rdata),
    .m_axi_gmem_out3_rresp(m_axi_gmem_out3_rresp),
    .m_axi_gmem_out3_rlast(m_axi_gmem_out3_rlast),
    .m_axi_gmem_out3_ruser(m_axi_gmem_out3_ruser),
    .m_axi_gmem_out3_rvalid(m_axi_gmem_out3_rvalid),
    .m_axi_gmem_out4_awready(m_axi_gmem_out4_awready),
    .m_axi_gmem_out4_wready(m_axi_gmem_out4_wready),
    .m_axi_gmem_out4_bid(m_axi_gmem_out4_bid),
    .m_axi_gmem_out4_bresp(m_axi_gmem_out4_bresp),
    .m_axi_gmem_out4_buser(m_axi_gmem_out4_buser),
    .m_axi_gmem_out4_bvalid(m_axi_gmem_out4_bvalid),
    .m_axi_gmem_out4_arready(m_axi_gmem_out4_arready),
    .m_axi_gmem_out4_rid(m_axi_gmem_out4_rid),
    .m_axi_gmem_out4_rdata(m_axi_gmem_out4_rdata),
    .m_axi_gmem_out4_rresp(m_axi_gmem_out4_rresp),
    .m_axi_gmem_out4_rlast(m_axi_gmem_out4_rlast),
    .m_axi_gmem_out4_ruser(m_axi_gmem_out4_ruser),
    .m_axi_gmem_out4_rvalid(m_axi_gmem_out4_rvalid),
    .m_axi_gmem_out5_awready(m_axi_gmem_out5_awready),
    .m_axi_gmem_out5_wready(m_axi_gmem_out5_wready),
    .m_axi_gmem_out5_bid(m_axi_gmem_out5_bid),
    .m_axi_gmem_out5_bresp(m_axi_gmem_out5_bresp),
    .m_axi_gmem_out5_buser(m_axi_gmem_out5_buser),
    .m_axi_gmem_out5_bvalid(m_axi_gmem_out5_bvalid),
    .m_axi_gmem_out5_arready(m_axi_gmem_out5_arready),
    .m_axi_gmem_out5_rid(m_axi_gmem_out5_rid),
    .m_axi_gmem_out5_rdata(m_axi_gmem_out5_rdata),
    .m_axi_gmem_out5_rresp(m_axi_gmem_out5_rresp),
    .m_axi_gmem_out5_rlast(m_axi_gmem_out5_rlast),
    .m_axi_gmem_out5_ruser(m_axi_gmem_out5_ruser),
    .m_axi_gmem_out5_rvalid(m_axi_gmem_out5_rvalid),
    .m_axi_gmem_out6_awready(m_axi_gmem_out6_awready),
    .m_axi_gmem_out6_wready(m_axi_gmem_out6_wready),
    .m_axi_gmem_out6_bid(m_axi_gmem_out6_bid),
    .m_axi_gmem_out6_bresp(m_axi_gmem_out6_bresp),
    .m_axi_gmem_out6_buser(m_axi_gmem_out6_buser),
    .m_axi_gmem_out6_bvalid(m_axi_gmem_out6_bvalid),
    .m_axi_gmem_out6_arready(m_axi_gmem_out6_arready),
    .m_axi_gmem_out6_rid(m_axi_gmem_out6_rid),
    .m_axi_gmem_out6_rdata(m_axi_gmem_out6_rdata),
    .m_axi_gmem_out6_rresp(m_axi_gmem_out6_rresp),
    .m_axi_gmem_out6_rlast(m_axi_gmem_out6_rlast),
    .m_axi_gmem_out6_ruser(m_axi_gmem_out6_ruser),
    .m_axi_gmem_out6_rvalid(m_axi_gmem_out6_rvalid),
    .m_axi_gmem_out7_awready(m_axi_gmem_out7_awready),
    .m_axi_gmem_out7_wready(m_axi_gmem_out7_wready),
    .m_axi_gmem_out7_bid(m_axi_gmem_out7_bid),
    .m_axi_gmem_out7_bresp(m_axi_gmem_out7_bresp),
    .m_axi_gmem_out7_buser(m_axi_gmem_out7_buser),
    .m_axi_gmem_out7_bvalid(m_axi_gmem_out7_bvalid),
    .m_axi_gmem_out7_arready(m_axi_gmem_out7_arready),
    .m_axi_gmem_out7_rid(m_axi_gmem_out7_rid),
    .m_axi_gmem_out7_rdata(m_axi_gmem_out7_rdata),
    .m_axi_gmem_out7_rresp(m_axi_gmem_out7_rresp),
    .m_axi_gmem_out7_rlast(m_axi_gmem_out7_rlast),
    .m_axi_gmem_out7_ruser(m_axi_gmem_out7_ruser),
    .m_axi_gmem_out7_rvalid(m_axi_gmem_out7_rvalid),
    .m_axi_gmem_w0_awready(m_axi_gmem_w0_awready),
    .m_axi_gmem_w0_wready(m_axi_gmem_w0_wready),
    .m_axi_gmem_w0_bid(m_axi_gmem_w0_bid),
    .m_axi_gmem_w0_bresp(m_axi_gmem_w0_bresp),
    .m_axi_gmem_w0_buser(m_axi_gmem_w0_buser),
    .m_axi_gmem_w0_bvalid(m_axi_gmem_w0_bvalid),
    .m_axi_gmem_w0_arready(m_axi_gmem_w0_arready),
    .m_axi_gmem_w0_rid(m_axi_gmem_w0_rid),
    .m_axi_gmem_w0_rdata(m_axi_gmem_w0_rdata),
    .m_axi_gmem_w0_rresp(m_axi_gmem_w0_rresp),
    .m_axi_gmem_w0_rlast(m_axi_gmem_w0_rlast),
    .m_axi_gmem_w0_ruser(m_axi_gmem_w0_ruser),
    .m_axi_gmem_w0_rvalid(m_axi_gmem_w0_rvalid),
    .m_axi_gmem_w1_awready(m_axi_gmem_w1_awready),
    .m_axi_gmem_w1_wready(m_axi_gmem_w1_wready),
    .m_axi_gmem_w1_bid(m_axi_gmem_w1_bid),
    .m_axi_gmem_w1_bresp(m_axi_gmem_w1_bresp),
    .m_axi_gmem_w1_buser(m_axi_gmem_w1_buser),
    .m_axi_gmem_w1_bvalid(m_axi_gmem_w1_bvalid),
    .m_axi_gmem_w1_arready(m_axi_gmem_w1_arready),
    .m_axi_gmem_w1_rid(m_axi_gmem_w1_rid),
    .m_axi_gmem_w1_rdata(m_axi_gmem_w1_rdata),
    .m_axi_gmem_w1_rresp(m_axi_gmem_w1_rresp),
    .m_axi_gmem_w1_rlast(m_axi_gmem_w1_rlast),
    .m_axi_gmem_w1_ruser(m_axi_gmem_w1_ruser),
    .m_axi_gmem_w1_rvalid(m_axi_gmem_w1_rvalid),
    .done_port(done_port),
    .m_axi_gmem_in0_awid(m_axi_gmem_in0_awid),
    .m_axi_gmem_in0_awaddr(m_axi_gmem_in0_awaddr),
    .m_axi_gmem_in0_awlen(m_axi_gmem_in0_awlen),
    .m_axi_gmem_in0_awsize(m_axi_gmem_in0_awsize),
    .m_axi_gmem_in0_awburst(m_axi_gmem_in0_awburst),
    .m_axi_gmem_in0_awlock(m_axi_gmem_in0_awlock),
    .m_axi_gmem_in0_awcache(m_axi_gmem_in0_awcache),
    .m_axi_gmem_in0_awprot(m_axi_gmem_in0_awprot),
    .m_axi_gmem_in0_awqos(m_axi_gmem_in0_awqos),
    .m_axi_gmem_in0_awregion(m_axi_gmem_in0_awregion),
    .m_axi_gmem_in0_awuser(m_axi_gmem_in0_awuser),
    .m_axi_gmem_in0_awvalid(m_axi_gmem_in0_awvalid),
    .m_axi_gmem_in0_wdata(m_axi_gmem_in0_wdata),
    .m_axi_gmem_in0_wstrb(m_axi_gmem_in0_wstrb),
    .m_axi_gmem_in0_wlast(m_axi_gmem_in0_wlast),
    .m_axi_gmem_in0_wuser(m_axi_gmem_in0_wuser),
    .m_axi_gmem_in0_wvalid(m_axi_gmem_in0_wvalid),
    .m_axi_gmem_in0_bready(m_axi_gmem_in0_bready),
    .m_axi_gmem_in0_arid(m_axi_gmem_in0_arid),
    .m_axi_gmem_in0_araddr(m_axi_gmem_in0_araddr),
    .m_axi_gmem_in0_arlen(m_axi_gmem_in0_arlen),
    .m_axi_gmem_in0_arsize(m_axi_gmem_in0_arsize),
    .m_axi_gmem_in0_arburst(m_axi_gmem_in0_arburst),
    .m_axi_gmem_in0_arlock(m_axi_gmem_in0_arlock),
    .m_axi_gmem_in0_arcache(m_axi_gmem_in0_arcache),
    .m_axi_gmem_in0_arprot(m_axi_gmem_in0_arprot),
    .m_axi_gmem_in0_arqos(m_axi_gmem_in0_arqos),
    .m_axi_gmem_in0_arregion(m_axi_gmem_in0_arregion),
    .m_axi_gmem_in0_aruser(m_axi_gmem_in0_aruser),
    .m_axi_gmem_in0_arvalid(m_axi_gmem_in0_arvalid),
    .m_axi_gmem_in0_rready(m_axi_gmem_in0_rready),
    .m_axi_gmem_in1_awid(m_axi_gmem_in1_awid),
    .m_axi_gmem_in1_awaddr(m_axi_gmem_in1_awaddr),
    .m_axi_gmem_in1_awlen(m_axi_gmem_in1_awlen),
    .m_axi_gmem_in1_awsize(m_axi_gmem_in1_awsize),
    .m_axi_gmem_in1_awburst(m_axi_gmem_in1_awburst),
    .m_axi_gmem_in1_awlock(m_axi_gmem_in1_awlock),
    .m_axi_gmem_in1_awcache(m_axi_gmem_in1_awcache),
    .m_axi_gmem_in1_awprot(m_axi_gmem_in1_awprot),
    .m_axi_gmem_in1_awqos(m_axi_gmem_in1_awqos),
    .m_axi_gmem_in1_awregion(m_axi_gmem_in1_awregion),
    .m_axi_gmem_in1_awuser(m_axi_gmem_in1_awuser),
    .m_axi_gmem_in1_awvalid(m_axi_gmem_in1_awvalid),
    .m_axi_gmem_in1_wdata(m_axi_gmem_in1_wdata),
    .m_axi_gmem_in1_wstrb(m_axi_gmem_in1_wstrb),
    .m_axi_gmem_in1_wlast(m_axi_gmem_in1_wlast),
    .m_axi_gmem_in1_wuser(m_axi_gmem_in1_wuser),
    .m_axi_gmem_in1_wvalid(m_axi_gmem_in1_wvalid),
    .m_axi_gmem_in1_bready(m_axi_gmem_in1_bready),
    .m_axi_gmem_in1_arid(m_axi_gmem_in1_arid),
    .m_axi_gmem_in1_araddr(m_axi_gmem_in1_araddr),
    .m_axi_gmem_in1_arlen(m_axi_gmem_in1_arlen),
    .m_axi_gmem_in1_arsize(m_axi_gmem_in1_arsize),
    .m_axi_gmem_in1_arburst(m_axi_gmem_in1_arburst),
    .m_axi_gmem_in1_arlock(m_axi_gmem_in1_arlock),
    .m_axi_gmem_in1_arcache(m_axi_gmem_in1_arcache),
    .m_axi_gmem_in1_arprot(m_axi_gmem_in1_arprot),
    .m_axi_gmem_in1_arqos(m_axi_gmem_in1_arqos),
    .m_axi_gmem_in1_arregion(m_axi_gmem_in1_arregion),
    .m_axi_gmem_in1_aruser(m_axi_gmem_in1_aruser),
    .m_axi_gmem_in1_arvalid(m_axi_gmem_in1_arvalid),
    .m_axi_gmem_in1_rready(m_axi_gmem_in1_rready),
    .m_axi_gmem_out0_awid(m_axi_gmem_out0_awid),
    .m_axi_gmem_out0_awaddr(m_axi_gmem_out0_awaddr),
    .m_axi_gmem_out0_awlen(m_axi_gmem_out0_awlen),
    .m_axi_gmem_out0_awsize(m_axi_gmem_out0_awsize),
    .m_axi_gmem_out0_awburst(m_axi_gmem_out0_awburst),
    .m_axi_gmem_out0_awlock(m_axi_gmem_out0_awlock),
    .m_axi_gmem_out0_awcache(m_axi_gmem_out0_awcache),
    .m_axi_gmem_out0_awprot(m_axi_gmem_out0_awprot),
    .m_axi_gmem_out0_awqos(m_axi_gmem_out0_awqos),
    .m_axi_gmem_out0_awregion(m_axi_gmem_out0_awregion),
    .m_axi_gmem_out0_awuser(m_axi_gmem_out0_awuser),
    .m_axi_gmem_out0_awvalid(m_axi_gmem_out0_awvalid),
    .m_axi_gmem_out0_wdata(m_axi_gmem_out0_wdata),
    .m_axi_gmem_out0_wstrb(m_axi_gmem_out0_wstrb),
    .m_axi_gmem_out0_wlast(m_axi_gmem_out0_wlast),
    .m_axi_gmem_out0_wuser(m_axi_gmem_out0_wuser),
    .m_axi_gmem_out0_wvalid(m_axi_gmem_out0_wvalid),
    .m_axi_gmem_out0_bready(m_axi_gmem_out0_bready),
    .m_axi_gmem_out0_arid(m_axi_gmem_out0_arid),
    .m_axi_gmem_out0_araddr(m_axi_gmem_out0_araddr),
    .m_axi_gmem_out0_arlen(m_axi_gmem_out0_arlen),
    .m_axi_gmem_out0_arsize(m_axi_gmem_out0_arsize),
    .m_axi_gmem_out0_arburst(m_axi_gmem_out0_arburst),
    .m_axi_gmem_out0_arlock(m_axi_gmem_out0_arlock),
    .m_axi_gmem_out0_arcache(m_axi_gmem_out0_arcache),
    .m_axi_gmem_out0_arprot(m_axi_gmem_out0_arprot),
    .m_axi_gmem_out0_arqos(m_axi_gmem_out0_arqos),
    .m_axi_gmem_out0_arregion(m_axi_gmem_out0_arregion),
    .m_axi_gmem_out0_aruser(m_axi_gmem_out0_aruser),
    .m_axi_gmem_out0_arvalid(m_axi_gmem_out0_arvalid),
    .m_axi_gmem_out0_rready(m_axi_gmem_out0_rready),
    .m_axi_gmem_out1_awid(m_axi_gmem_out1_awid),
    .m_axi_gmem_out1_awaddr(m_axi_gmem_out1_awaddr),
    .m_axi_gmem_out1_awlen(m_axi_gmem_out1_awlen),
    .m_axi_gmem_out1_awsize(m_axi_gmem_out1_awsize),
    .m_axi_gmem_out1_awburst(m_axi_gmem_out1_awburst),
    .m_axi_gmem_out1_awlock(m_axi_gmem_out1_awlock),
    .m_axi_gmem_out1_awcache(m_axi_gmem_out1_awcache),
    .m_axi_gmem_out1_awprot(m_axi_gmem_out1_awprot),
    .m_axi_gmem_out1_awqos(m_axi_gmem_out1_awqos),
    .m_axi_gmem_out1_awregion(m_axi_gmem_out1_awregion),
    .m_axi_gmem_out1_awuser(m_axi_gmem_out1_awuser),
    .m_axi_gmem_out1_awvalid(m_axi_gmem_out1_awvalid),
    .m_axi_gmem_out1_wdata(m_axi_gmem_out1_wdata),
    .m_axi_gmem_out1_wstrb(m_axi_gmem_out1_wstrb),
    .m_axi_gmem_out1_wlast(m_axi_gmem_out1_wlast),
    .m_axi_gmem_out1_wuser(m_axi_gmem_out1_wuser),
    .m_axi_gmem_out1_wvalid(m_axi_gmem_out1_wvalid),
    .m_axi_gmem_out1_bready(m_axi_gmem_out1_bready),
    .m_axi_gmem_out1_arid(m_axi_gmem_out1_arid),
    .m_axi_gmem_out1_araddr(m_axi_gmem_out1_araddr),
    .m_axi_gmem_out1_arlen(m_axi_gmem_out1_arlen),
    .m_axi_gmem_out1_arsize(m_axi_gmem_out1_arsize),
    .m_axi_gmem_out1_arburst(m_axi_gmem_out1_arburst),
    .m_axi_gmem_out1_arlock(m_axi_gmem_out1_arlock),
    .m_axi_gmem_out1_arcache(m_axi_gmem_out1_arcache),
    .m_axi_gmem_out1_arprot(m_axi_gmem_out1_arprot),
    .m_axi_gmem_out1_arqos(m_axi_gmem_out1_arqos),
    .m_axi_gmem_out1_arregion(m_axi_gmem_out1_arregion),
    .m_axi_gmem_out1_aruser(m_axi_gmem_out1_aruser),
    .m_axi_gmem_out1_arvalid(m_axi_gmem_out1_arvalid),
    .m_axi_gmem_out1_rready(m_axi_gmem_out1_rready),
    .m_axi_gmem_out2_awid(m_axi_gmem_out2_awid),
    .m_axi_gmem_out2_awaddr(m_axi_gmem_out2_awaddr),
    .m_axi_gmem_out2_awlen(m_axi_gmem_out2_awlen),
    .m_axi_gmem_out2_awsize(m_axi_gmem_out2_awsize),
    .m_axi_gmem_out2_awburst(m_axi_gmem_out2_awburst),
    .m_axi_gmem_out2_awlock(m_axi_gmem_out2_awlock),
    .m_axi_gmem_out2_awcache(m_axi_gmem_out2_awcache),
    .m_axi_gmem_out2_awprot(m_axi_gmem_out2_awprot),
    .m_axi_gmem_out2_awqos(m_axi_gmem_out2_awqos),
    .m_axi_gmem_out2_awregion(m_axi_gmem_out2_awregion),
    .m_axi_gmem_out2_awuser(m_axi_gmem_out2_awuser),
    .m_axi_gmem_out2_awvalid(m_axi_gmem_out2_awvalid),
    .m_axi_gmem_out2_wdata(m_axi_gmem_out2_wdata),
    .m_axi_gmem_out2_wstrb(m_axi_gmem_out2_wstrb),
    .m_axi_gmem_out2_wlast(m_axi_gmem_out2_wlast),
    .m_axi_gmem_out2_wuser(m_axi_gmem_out2_wuser),
    .m_axi_gmem_out2_wvalid(m_axi_gmem_out2_wvalid),
    .m_axi_gmem_out2_bready(m_axi_gmem_out2_bready),
    .m_axi_gmem_out2_arid(m_axi_gmem_out2_arid),
    .m_axi_gmem_out2_araddr(m_axi_gmem_out2_araddr),
    .m_axi_gmem_out2_arlen(m_axi_gmem_out2_arlen),
    .m_axi_gmem_out2_arsize(m_axi_gmem_out2_arsize),
    .m_axi_gmem_out2_arburst(m_axi_gmem_out2_arburst),
    .m_axi_gmem_out2_arlock(m_axi_gmem_out2_arlock),
    .m_axi_gmem_out2_arcache(m_axi_gmem_out2_arcache),
    .m_axi_gmem_out2_arprot(m_axi_gmem_out2_arprot),
    .m_axi_gmem_out2_arqos(m_axi_gmem_out2_arqos),
    .m_axi_gmem_out2_arregion(m_axi_gmem_out2_arregion),
    .m_axi_gmem_out2_aruser(m_axi_gmem_out2_aruser),
    .m_axi_gmem_out2_arvalid(m_axi_gmem_out2_arvalid),
    .m_axi_gmem_out2_rready(m_axi_gmem_out2_rready),
    .m_axi_gmem_out3_awid(m_axi_gmem_out3_awid),
    .m_axi_gmem_out3_awaddr(m_axi_gmem_out3_awaddr),
    .m_axi_gmem_out3_awlen(m_axi_gmem_out3_awlen),
    .m_axi_gmem_out3_awsize(m_axi_gmem_out3_awsize),
    .m_axi_gmem_out3_awburst(m_axi_gmem_out3_awburst),
    .m_axi_gmem_out3_awlock(m_axi_gmem_out3_awlock),
    .m_axi_gmem_out3_awcache(m_axi_gmem_out3_awcache),
    .m_axi_gmem_out3_awprot(m_axi_gmem_out3_awprot),
    .m_axi_gmem_out3_awqos(m_axi_gmem_out3_awqos),
    .m_axi_gmem_out3_awregion(m_axi_gmem_out3_awregion),
    .m_axi_gmem_out3_awuser(m_axi_gmem_out3_awuser),
    .m_axi_gmem_out3_awvalid(m_axi_gmem_out3_awvalid),
    .m_axi_gmem_out3_wdata(m_axi_gmem_out3_wdata),
    .m_axi_gmem_out3_wstrb(m_axi_gmem_out3_wstrb),
    .m_axi_gmem_out3_wlast(m_axi_gmem_out3_wlast),
    .m_axi_gmem_out3_wuser(m_axi_gmem_out3_wuser),
    .m_axi_gmem_out3_wvalid(m_axi_gmem_out3_wvalid),
    .m_axi_gmem_out3_bready(m_axi_gmem_out3_bready),
    .m_axi_gmem_out3_arid(m_axi_gmem_out3_arid),
    .m_axi_gmem_out3_araddr(m_axi_gmem_out3_araddr),
    .m_axi_gmem_out3_arlen(m_axi_gmem_out3_arlen),
    .m_axi_gmem_out3_arsize(m_axi_gmem_out3_arsize),
    .m_axi_gmem_out3_arburst(m_axi_gmem_out3_arburst),
    .m_axi_gmem_out3_arlock(m_axi_gmem_out3_arlock),
    .m_axi_gmem_out3_arcache(m_axi_gmem_out3_arcache),
    .m_axi_gmem_out3_arprot(m_axi_gmem_out3_arprot),
    .m_axi_gmem_out3_arqos(m_axi_gmem_out3_arqos),
    .m_axi_gmem_out3_arregion(m_axi_gmem_out3_arregion),
    .m_axi_gmem_out3_aruser(m_axi_gmem_out3_aruser),
    .m_axi_gmem_out3_arvalid(m_axi_gmem_out3_arvalid),
    .m_axi_gmem_out3_rready(m_axi_gmem_out3_rready),
    .m_axi_gmem_out4_awid(m_axi_gmem_out4_awid),
    .m_axi_gmem_out4_awaddr(m_axi_gmem_out4_awaddr),
    .m_axi_gmem_out4_awlen(m_axi_gmem_out4_awlen),
    .m_axi_gmem_out4_awsize(m_axi_gmem_out4_awsize),
    .m_axi_gmem_out4_awburst(m_axi_gmem_out4_awburst),
    .m_axi_gmem_out4_awlock(m_axi_gmem_out4_awlock),
    .m_axi_gmem_out4_awcache(m_axi_gmem_out4_awcache),
    .m_axi_gmem_out4_awprot(m_axi_gmem_out4_awprot),
    .m_axi_gmem_out4_awqos(m_axi_gmem_out4_awqos),
    .m_axi_gmem_out4_awregion(m_axi_gmem_out4_awregion),
    .m_axi_gmem_out4_awuser(m_axi_gmem_out4_awuser),
    .m_axi_gmem_out4_awvalid(m_axi_gmem_out4_awvalid),
    .m_axi_gmem_out4_wdata(m_axi_gmem_out4_wdata),
    .m_axi_gmem_out4_wstrb(m_axi_gmem_out4_wstrb),
    .m_axi_gmem_out4_wlast(m_axi_gmem_out4_wlast),
    .m_axi_gmem_out4_wuser(m_axi_gmem_out4_wuser),
    .m_axi_gmem_out4_wvalid(m_axi_gmem_out4_wvalid),
    .m_axi_gmem_out4_bready(m_axi_gmem_out4_bready),
    .m_axi_gmem_out4_arid(m_axi_gmem_out4_arid),
    .m_axi_gmem_out4_araddr(m_axi_gmem_out4_araddr),
    .m_axi_gmem_out4_arlen(m_axi_gmem_out4_arlen),
    .m_axi_gmem_out4_arsize(m_axi_gmem_out4_arsize),
    .m_axi_gmem_out4_arburst(m_axi_gmem_out4_arburst),
    .m_axi_gmem_out4_arlock(m_axi_gmem_out4_arlock),
    .m_axi_gmem_out4_arcache(m_axi_gmem_out4_arcache),
    .m_axi_gmem_out4_arprot(m_axi_gmem_out4_arprot),
    .m_axi_gmem_out4_arqos(m_axi_gmem_out4_arqos),
    .m_axi_gmem_out4_arregion(m_axi_gmem_out4_arregion),
    .m_axi_gmem_out4_aruser(m_axi_gmem_out4_aruser),
    .m_axi_gmem_out4_arvalid(m_axi_gmem_out4_arvalid),
    .m_axi_gmem_out4_rready(m_axi_gmem_out4_rready),
    .m_axi_gmem_out5_awid(m_axi_gmem_out5_awid),
    .m_axi_gmem_out5_awaddr(m_axi_gmem_out5_awaddr),
    .m_axi_gmem_out5_awlen(m_axi_gmem_out5_awlen),
    .m_axi_gmem_out5_awsize(m_axi_gmem_out5_awsize),
    .m_axi_gmem_out5_awburst(m_axi_gmem_out5_awburst),
    .m_axi_gmem_out5_awlock(m_axi_gmem_out5_awlock),
    .m_axi_gmem_out5_awcache(m_axi_gmem_out5_awcache),
    .m_axi_gmem_out5_awprot(m_axi_gmem_out5_awprot),
    .m_axi_gmem_out5_awqos(m_axi_gmem_out5_awqos),
    .m_axi_gmem_out5_awregion(m_axi_gmem_out5_awregion),
    .m_axi_gmem_out5_awuser(m_axi_gmem_out5_awuser),
    .m_axi_gmem_out5_awvalid(m_axi_gmem_out5_awvalid),
    .m_axi_gmem_out5_wdata(m_axi_gmem_out5_wdata),
    .m_axi_gmem_out5_wstrb(m_axi_gmem_out5_wstrb),
    .m_axi_gmem_out5_wlast(m_axi_gmem_out5_wlast),
    .m_axi_gmem_out5_wuser(m_axi_gmem_out5_wuser),
    .m_axi_gmem_out5_wvalid(m_axi_gmem_out5_wvalid),
    .m_axi_gmem_out5_bready(m_axi_gmem_out5_bready),
    .m_axi_gmem_out5_arid(m_axi_gmem_out5_arid),
    .m_axi_gmem_out5_araddr(m_axi_gmem_out5_araddr),
    .m_axi_gmem_out5_arlen(m_axi_gmem_out5_arlen),
    .m_axi_gmem_out5_arsize(m_axi_gmem_out5_arsize),
    .m_axi_gmem_out5_arburst(m_axi_gmem_out5_arburst),
    .m_axi_gmem_out5_arlock(m_axi_gmem_out5_arlock),
    .m_axi_gmem_out5_arcache(m_axi_gmem_out5_arcache),
    .m_axi_gmem_out5_arprot(m_axi_gmem_out5_arprot),
    .m_axi_gmem_out5_arqos(m_axi_gmem_out5_arqos),
    .m_axi_gmem_out5_arregion(m_axi_gmem_out5_arregion),
    .m_axi_gmem_out5_aruser(m_axi_gmem_out5_aruser),
    .m_axi_gmem_out5_arvalid(m_axi_gmem_out5_arvalid),
    .m_axi_gmem_out5_rready(m_axi_gmem_out5_rready),
    .m_axi_gmem_out6_awid(m_axi_gmem_out6_awid),
    .m_axi_gmem_out6_awaddr(m_axi_gmem_out6_awaddr),
    .m_axi_gmem_out6_awlen(m_axi_gmem_out6_awlen),
    .m_axi_gmem_out6_awsize(m_axi_gmem_out6_awsize),
    .m_axi_gmem_out6_awburst(m_axi_gmem_out6_awburst),
    .m_axi_gmem_out6_awlock(m_axi_gmem_out6_awlock),
    .m_axi_gmem_out6_awcache(m_axi_gmem_out6_awcache),
    .m_axi_gmem_out6_awprot(m_axi_gmem_out6_awprot),
    .m_axi_gmem_out6_awqos(m_axi_gmem_out6_awqos),
    .m_axi_gmem_out6_awregion(m_axi_gmem_out6_awregion),
    .m_axi_gmem_out6_awuser(m_axi_gmem_out6_awuser),
    .m_axi_gmem_out6_awvalid(m_axi_gmem_out6_awvalid),
    .m_axi_gmem_out6_wdata(m_axi_gmem_out6_wdata),
    .m_axi_gmem_out6_wstrb(m_axi_gmem_out6_wstrb),
    .m_axi_gmem_out6_wlast(m_axi_gmem_out6_wlast),
    .m_axi_gmem_out6_wuser(m_axi_gmem_out6_wuser),
    .m_axi_gmem_out6_wvalid(m_axi_gmem_out6_wvalid),
    .m_axi_gmem_out6_bready(m_axi_gmem_out6_bready),
    .m_axi_gmem_out6_arid(m_axi_gmem_out6_arid),
    .m_axi_gmem_out6_araddr(m_axi_gmem_out6_araddr),
    .m_axi_gmem_out6_arlen(m_axi_gmem_out6_arlen),
    .m_axi_gmem_out6_arsize(m_axi_gmem_out6_arsize),
    .m_axi_gmem_out6_arburst(m_axi_gmem_out6_arburst),
    .m_axi_gmem_out6_arlock(m_axi_gmem_out6_arlock),
    .m_axi_gmem_out6_arcache(m_axi_gmem_out6_arcache),
    .m_axi_gmem_out6_arprot(m_axi_gmem_out6_arprot),
    .m_axi_gmem_out6_arqos(m_axi_gmem_out6_arqos),
    .m_axi_gmem_out6_arregion(m_axi_gmem_out6_arregion),
    .m_axi_gmem_out6_aruser(m_axi_gmem_out6_aruser),
    .m_axi_gmem_out6_arvalid(m_axi_gmem_out6_arvalid),
    .m_axi_gmem_out6_rready(m_axi_gmem_out6_rready),
    .m_axi_gmem_out7_awid(m_axi_gmem_out7_awid),
    .m_axi_gmem_out7_awaddr(m_axi_gmem_out7_awaddr),
    .m_axi_gmem_out7_awlen(m_axi_gmem_out7_awlen),
    .m_axi_gmem_out7_awsize(m_axi_gmem_out7_awsize),
    .m_axi_gmem_out7_awburst(m_axi_gmem_out7_awburst),
    .m_axi_gmem_out7_awlock(m_axi_gmem_out7_awlock),
    .m_axi_gmem_out7_awcache(m_axi_gmem_out7_awcache),
    .m_axi_gmem_out7_awprot(m_axi_gmem_out7_awprot),
    .m_axi_gmem_out7_awqos(m_axi_gmem_out7_awqos),
    .m_axi_gmem_out7_awregion(m_axi_gmem_out7_awregion),
    .m_axi_gmem_out7_awuser(m_axi_gmem_out7_awuser),
    .m_axi_gmem_out7_awvalid(m_axi_gmem_out7_awvalid),
    .m_axi_gmem_out7_wdata(m_axi_gmem_out7_wdata),
    .m_axi_gmem_out7_wstrb(m_axi_gmem_out7_wstrb),
    .m_axi_gmem_out7_wlast(m_axi_gmem_out7_wlast),
    .m_axi_gmem_out7_wuser(m_axi_gmem_out7_wuser),
    .m_axi_gmem_out7_wvalid(m_axi_gmem_out7_wvalid),
    .m_axi_gmem_out7_bready(m_axi_gmem_out7_bready),
    .m_axi_gmem_out7_arid(m_axi_gmem_out7_arid),
    .m_axi_gmem_out7_araddr(m_axi_gmem_out7_araddr),
    .m_axi_gmem_out7_arlen(m_axi_gmem_out7_arlen),
    .m_axi_gmem_out7_arsize(m_axi_gmem_out7_arsize),
    .m_axi_gmem_out7_arburst(m_axi_gmem_out7_arburst),
    .m_axi_gmem_out7_arlock(m_axi_gmem_out7_arlock),
    .m_axi_gmem_out7_arcache(m_axi_gmem_out7_arcache),
    .m_axi_gmem_out7_arprot(m_axi_gmem_out7_arprot),
    .m_axi_gmem_out7_arqos(m_axi_gmem_out7_arqos),
    .m_axi_gmem_out7_arregion(m_axi_gmem_out7_arregion),
    .m_axi_gmem_out7_aruser(m_axi_gmem_out7_aruser),
    .m_axi_gmem_out7_arvalid(m_axi_gmem_out7_arvalid),
    .m_axi_gmem_out7_rready(m_axi_gmem_out7_rready),
    .m_axi_gmem_w0_awid(m_axi_gmem_w0_awid),
    .m_axi_gmem_w0_awaddr(m_axi_gmem_w0_awaddr),
    .m_axi_gmem_w0_awlen(m_axi_gmem_w0_awlen),
    .m_axi_gmem_w0_awsize(m_axi_gmem_w0_awsize),
    .m_axi_gmem_w0_awburst(m_axi_gmem_w0_awburst),
    .m_axi_gmem_w0_awlock(m_axi_gmem_w0_awlock),
    .m_axi_gmem_w0_awcache(m_axi_gmem_w0_awcache),
    .m_axi_gmem_w0_awprot(m_axi_gmem_w0_awprot),
    .m_axi_gmem_w0_awqos(m_axi_gmem_w0_awqos),
    .m_axi_gmem_w0_awregion(m_axi_gmem_w0_awregion),
    .m_axi_gmem_w0_awuser(m_axi_gmem_w0_awuser),
    .m_axi_gmem_w0_awvalid(m_axi_gmem_w0_awvalid),
    .m_axi_gmem_w0_wdata(m_axi_gmem_w0_wdata),
    .m_axi_gmem_w0_wstrb(m_axi_gmem_w0_wstrb),
    .m_axi_gmem_w0_wlast(m_axi_gmem_w0_wlast),
    .m_axi_gmem_w0_wuser(m_axi_gmem_w0_wuser),
    .m_axi_gmem_w0_wvalid(m_axi_gmem_w0_wvalid),
    .m_axi_gmem_w0_bready(m_axi_gmem_w0_bready),
    .m_axi_gmem_w0_arid(m_axi_gmem_w0_arid),
    .m_axi_gmem_w0_araddr(m_axi_gmem_w0_araddr),
    .m_axi_gmem_w0_arlen(m_axi_gmem_w0_arlen),
    .m_axi_gmem_w0_arsize(m_axi_gmem_w0_arsize),
    .m_axi_gmem_w0_arburst(m_axi_gmem_w0_arburst),
    .m_axi_gmem_w0_arlock(m_axi_gmem_w0_arlock),
    .m_axi_gmem_w0_arcache(m_axi_gmem_w0_arcache),
    .m_axi_gmem_w0_arprot(m_axi_gmem_w0_arprot),
    .m_axi_gmem_w0_arqos(m_axi_gmem_w0_arqos),
    .m_axi_gmem_w0_arregion(m_axi_gmem_w0_arregion),
    .m_axi_gmem_w0_aruser(m_axi_gmem_w0_aruser),
    .m_axi_gmem_w0_arvalid(m_axi_gmem_w0_arvalid),
    .m_axi_gmem_w0_rready(m_axi_gmem_w0_rready),
    .m_axi_gmem_w1_awid(m_axi_gmem_w1_awid),
    .m_axi_gmem_w1_awaddr(m_axi_gmem_w1_awaddr),
    .m_axi_gmem_w1_awlen(m_axi_gmem_w1_awlen),
    .m_axi_gmem_w1_awsize(m_axi_gmem_w1_awsize),
    .m_axi_gmem_w1_awburst(m_axi_gmem_w1_awburst),
    .m_axi_gmem_w1_awlock(m_axi_gmem_w1_awlock),
    .m_axi_gmem_w1_awcache(m_axi_gmem_w1_awcache),
    .m_axi_gmem_w1_awprot(m_axi_gmem_w1_awprot),
    .m_axi_gmem_w1_awqos(m_axi_gmem_w1_awqos),
    .m_axi_gmem_w1_awregion(m_axi_gmem_w1_awregion),
    .m_axi_gmem_w1_awuser(m_axi_gmem_w1_awuser),
    .m_axi_gmem_w1_awvalid(m_axi_gmem_w1_awvalid),
    .m_axi_gmem_w1_wdata(m_axi_gmem_w1_wdata),
    .m_axi_gmem_w1_wstrb(m_axi_gmem_w1_wstrb),
    .m_axi_gmem_w1_wlast(m_axi_gmem_w1_wlast),
    .m_axi_gmem_w1_wuser(m_axi_gmem_w1_wuser),
    .m_axi_gmem_w1_wvalid(m_axi_gmem_w1_wvalid),
    .m_axi_gmem_w1_bready(m_axi_gmem_w1_bready),
    .m_axi_gmem_w1_arid(m_axi_gmem_w1_arid),
    .m_axi_gmem_w1_araddr(m_axi_gmem_w1_araddr),
    .m_axi_gmem_w1_arlen(m_axi_gmem_w1_arlen),
    .m_axi_gmem_w1_arsize(m_axi_gmem_w1_arsize),
    .m_axi_gmem_w1_arburst(m_axi_gmem_w1_arburst),
    .m_axi_gmem_w1_arlock(m_axi_gmem_w1_arlock),
    .m_axi_gmem_w1_arcache(m_axi_gmem_w1_arcache),
    .m_axi_gmem_w1_arprot(m_axi_gmem_w1_arprot),
    .m_axi_gmem_w1_arqos(m_axi_gmem_w1_arqos),
    .m_axi_gmem_w1_arregion(m_axi_gmem_w1_arregion),
    .m_axi_gmem_w1_aruser(m_axi_gmem_w1_aruser),
    .m_axi_gmem_w1_arvalid(m_axi_gmem_w1_arvalid),
    .m_axi_gmem_w1_rready(m_axi_gmem_w1_rready));

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module TestbenchFSM(clock,
  done_port,
  reset,
  setup_port,
  start_port);
  parameter RESFILE="results.txt",
    RESET_ACTIVE=0,
    RESET_CYCLES=1,
    RESET_ALWAYS=0,
    CLOCK_PERIOD=2.0,
    MAX_SIM_CYCLES=200000000;
  // IN
  input clock;
  input done_port;
  // OUT
  output reset;
  output setup_port;
  output start_port;
  `ifdef VERILATOR
  timeunit 1ps;
  timeprecision 1ps;
  `endif
  
  import "DPI-C" function int unsigned m_next(input int unsigned state);
  import "DPI-C" function int m_fini();
  
  localparam [6:0] 
    STATE_READY   =7'b0000001,
    STATE_SETUP   =7'b0000010,
    STATE_RUNNING =7'b0000100,
    STATE_END     =7'b0001000,
    STATE_ERROR   =7'b0010000,
    STATE_ABORT   =7'b0100000,
    SIM_DONE      =7'b1000000;
  reg [$bits(STATE_READY)-1:0] state, state_next, state_succ, state_succ_next;
  
  reg rst, rst_next, setup, setup_next, start, start_next;
  integer rst_count, rst_count_next;
  time over_time;
  
  initial
  begin
    // Open file results will be written
    automatic integer res_file;
    res_file = $fopen(RESFILE, "w");
    if (res_file == 0)
    begin
      $display("ERROR - Error opening the res_file");
      $finish;// Terminate
    end
    $fwrite(res_file, "");
    $fclose(res_file);
    
    state = STATE_READY;
    state_next = STATE_READY;
    state_succ = STATE_READY;
    state_succ_next = STATE_READY;
    rst = RESET_ACTIVE;
    rst_next = RESET_ACTIVE;
    rst_count = RESET_CYCLES;
    rst_count_next = RESET_CYCLES;
    setup = 0;
    setup_next = 0;
    start = 0;
    start_next = 0;
    over_time = 0;
    
    $display("Results file: %s", RESFILE);
    $display("Reset active: %0s", RESET_ACTIVE ? "HIGH" : "LOW");
  end
  
  assign reset = rst;
  assign setup_port = setup;
  assign start_port = start;
  
  always @(posedge clock)
  begin
    state <= state_next;
    state_succ <= state_succ_next;
    rst <= rst_next;
    rst_count <= rst_count_next;
    setup <= setup_next;
    start <= start_next;
    case(state_next)
    STATE_READY:
      begin
        automatic integer unsigned next_state = m_next(STATE_READY);
        `ifndef NDEBUG
        $display("Sim: next state: %0d (retval: %0d)", next_state[$bits(state_succ)-1:0], next_state[15:8]);
        `endif
        state_succ <= next_state[$bits(state_succ)-1:0];
      end
    STATE_SETUP:
      begin
        automatic time start_time = $time + CLOCK_PERIOD;
        automatic time start_cycle = $rtoi($itor(start_time)/CLOCK_PERIOD);
        automatic integer res_file;
        if(setup_next)
        begin
          res_file = $fopen(RESFILE, "a");
          $fwrite(res_file, "%0d|", start_time);
          $fclose(res_file);
          `ifndef NDEBUG
          $display("Sim: Argument setup\nSim: Simulation started at cycle %0d", start_cycle);
          `endif
        end
        over_time <= start_cycle + MAX_SIM_CYCLES;
      end
    STATE_RUNNING:
      begin
        automatic time curr_cycle = $rtoi($itor($time)/CLOCK_PERIOD);
        if(curr_cycle >= over_time)
        begin
          automatic integer res_file;
          res_file = $fopen(RESFILE, "a");
          $fwrite(res_file, "X");
          $fclose(res_file);
          $display("Sim: Simulation exceeds %0d cycles", MAX_SIM_CYCLES);
          $finish;
        end
      end
    SIM_DONE:
      begin
        automatic time curr_time = $time;
        automatic time curr_cycle = $rtoi($itor(curr_time)/CLOCK_PERIOD);
        automatic integer res_file;
        res_file = $fopen(RESFILE, "a");
        $fwrite(res_file, "%0d,", curr_time);
        $fclose(res_file);
        `ifndef NDEBUG
        $display("Sim: DUT port writeback\nSim: Simulation ended at cycle %0d", curr_cycle);
        `endif
      end
    STATE_END:
      begin
        automatic integer r = m_fini();
        automatic integer res_file;
        res_file = $fopen(RESFILE, "a");
        $fwrite(res_file, "\n%0d\n", r[15:8]);
        $display("Sim: Testbench returned: %0d", r[15:8]);
        $fclose(res_file);
        $finish;
      end
    STATE_ABORT:
      begin
        automatic integer r = m_fini();
        automatic integer res_file;
        res_file = $fopen(RESFILE, "a");
        $fwrite(res_file, "\nA\n");
        $display("Sim: Testbench aborted");
        $fclose(res_file);
        $finish;
      end
    default:
      begin
      end
    endcase
  end
  
  always @(*)
  begin
    rst_next = rst;
    rst_count_next = rst_count;
    setup_next = setup;
    start_next = start;
    state_next = state;
    state_succ_next = state_succ;
    case(state)
    STATE_READY:
      begin
        state_next = state_succ;
        if(state_succ == STATE_SETUP)
        begin
          if(RESET_ALWAYS || rst_count > 0)
          begin
            rst_next = RESET_ACTIVE;
            rst_count_next = RESET_CYCLES;
          end
          else
          begin
            rst_count_next = 1;
          end
        end
      end
    STATE_SETUP:
      begin
        if(rst_count > 1)
        begin
          setup_next = rst_count == 0;
          rst_next = RESET_ACTIVE;
          rst_count_next = rst_count - 1;
        end
        else if(rst_count == 1)
        begin
          setup_next = 1;
          rst_next = ~RESET_ACTIVE;
          rst_count_next = 0;
        end
        else
        begin
          state_next = STATE_RUNNING;
          setup_next = 0;
          start_next = 1;
        end
      end
    STATE_RUNNING:
      begin
        start_next = 0;
        if(done_port)
        begin
          state_next = SIM_DONE;
        end
      end
    SIM_DONE:
      begin
        // A clock cycle must pass to allow interface modules 
        // finalization operations
        state_next = STATE_READY;
      end
    STATE_END:
      begin
      end
    STATE_ABORT:
      begin
      end
    default:
      begin
        state_next = STATE_READY;
      end
    endcase
  end
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_utils();
  parameter ID=0,
    BITSIZE_data=32;
  
  import "DPI-C" function int m_read (input byte unsigned id, output logic [4095:0] data, input shortint unsigned bitsize, input ptr_t addr, input byte unsigned shift);
  import "DPI-C" function int m_write (input byte unsigned id, input logic [4095:0] data, input shortint unsigned bitsize, input ptr_t addr, input byte unsigned shift);
  import "DPI-C" function int m_state (input byte unsigned id, input int data);
  
  function automatic integer log2;
    input integer value;
    `ifdef _SIM_HAVE_CLOG2
      log2 = $clog2(value);
    `else
      automatic integer temp_value = value-1;
      for (log2=0; temp_value > 0; log2=log2+1)
        temp_value = temp_value >> 1;
    `endif
  endfunction
  
  localparam BITSIZE_strobe=log2(BITSIZE_data) > 3 ? (1<<(log2(BITSIZE_data)-3)) : 1;
  
  function automatic [BITSIZE_data-1:0] read();
    automatic reg [4095:0] _data = 0;
    void'(m_read(ID, _data, BITSIZE_data, 0, 0));
    return _data[BITSIZE_data-1:0];
  endfunction
  
  function automatic [BITSIZE_data-1:0] read_a(input ptr_t addr);
    automatic reg [4095:0] _data = 0;
    void'(m_read(ID, _data, BITSIZE_data, addr, 0));
    return _data[BITSIZE_data-1:0];
  endfunction
  
  function automatic [BITSIZE_data-1:0] read_i(output int info);
    automatic reg [4095:0] _data = 0;
    info = m_read(ID, _data, BITSIZE_data, 0, 0);
    return _data[BITSIZE_data-1:0];
  endfunction
  
  function automatic [BITSIZE_data-1:0] read_ai(input ptr_t addr, output int info);
    automatic reg [4095:0] _data = 0;
    info = m_read(ID, _data, BITSIZE_data, addr, 0);
    return _data[BITSIZE_data-1:0];
  endfunction
  
  function automatic [BITSIZE_data-1:0] pop(output int info);
    automatic reg [4095:0] _data = 0;
    info = m_read(ID, _data, BITSIZE_data, 0, 1);
    return _data[BITSIZE_data-1:0];
  endfunction
  
  function automatic int write(input logic [BITSIZE_data-1:0] data);
    automatic reg [4095:0] _data = 0;
    _data[BITSIZE_data-1:0] = data;
    return m_write(ID, _data, BITSIZE_data, 0, 0);
  endfunction
  
  function automatic int write_a(input logic [BITSIZE_data-1:0] data, input ptr_t addr);
    automatic reg [4095:0] _data = 0;
    _data[BITSIZE_data-1:0] = data;
    return m_write(ID, _data, BITSIZE_data, addr, 0);
  endfunction
  
  function automatic int write_sa(input logic [BITSIZE_data-1:0] data, input shortint unsigned bitsize, input ptr_t addr);
    automatic reg [4095:0] _data = 0;
    _data[BITSIZE_data-1:0] = data;
    return m_write(ID, _data, bitsize, addr, 0);
  endfunction
  
  function automatic int write_strobe(input logic [BITSIZE_data-1:0] data, input logic [BITSIZE_strobe-1:0] strobe, input ptr_t addr);
    automatic shortint unsigned size = 0;
    
    while(strobe != 0 && !strobe[0])
    begin
      addr = addr + 1;
      strobe = strobe >> 1;
    end
    while(strobe[0])
    begin
      size = size + 8;
      strobe = strobe >> 1;
    end
    if(strobe != 0)
    begin
      $display("Scattered strobe write operations not supported");
      $finish;
    end
  
    return write_sa(data, size, addr);
  endfunction
  
  function automatic int push(input logic [BITSIZE_data-1:0] data);
    automatic reg [4095:0] _data = 0;
    _data[BITSIZE_data-1:0] = data;
    return m_write(ID, _data, BITSIZE_data, 0, 1);
  endfunction
  
  function automatic int state(input int data);
    return m_state(ID, data);
  endfunction
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module TestbenchMEMMinimal(clock,
  reset,
  done_port,
  M_DataRdy,
  M_Rdata_ram,
  Mout_oe_ram,
  Mout_we_ram,
  Mout_addr_ram,
  Mout_data_ram_size,
  Mout_Wdata_ram,
  Mout_back_pressure,
  Sout_DataRdy,
  Sout_Rdata_ram,
  S_oe_ram,
  S_we_ram,
  S_addr_ram,
  S_data_ram_size,
  S_Wdata_ram);
  parameter index=0,
    MEM_DELAY_READ=2,
    MEM_DELAY_WRITE=1,
    base_addr=1073741824,
    MEM_DUMP=0,
    MEM_DUMP_FILE="memdump.csv",
    QUEUE_SIZE=4,
    BITSIZE_M_DataRdy=1,
    BITSIZE_M_Rdata_ram=8,
    BITSIZE_Mout_oe_ram=1,
    BITSIZE_Mout_we_ram=1,
    BITSIZE_Mout_addr_ram=1,
    BITSIZE_Mout_data_ram_size=4,
    BITSIZE_Mout_Wdata_ram=8,
    BITSIZE_Mout_back_pressure=1,
    BITSIZE_Sout_DataRdy=1,
    BITSIZE_Sout_Rdata_ram=8,
    BITSIZE_S_oe_ram=1,
    BITSIZE_S_we_ram=1,
    BITSIZE_S_addr_ram=1,
    BITSIZE_S_data_ram_size=4,
    BITSIZE_S_Wdata_ram=8;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_Mout_oe_ram-1:0] Mout_oe_ram;
  input [BITSIZE_Mout_we_ram-1:0] Mout_we_ram;
  input [BITSIZE_Mout_addr_ram-1:0] Mout_addr_ram;
  input [BITSIZE_Mout_data_ram_size-1:0] Mout_data_ram_size;
  input [BITSIZE_Mout_Wdata_ram-1:0] Mout_Wdata_ram;
  input [BITSIZE_Sout_DataRdy-1:0] Sout_DataRdy;
  input [BITSIZE_Sout_Rdata_ram-1:0] Sout_Rdata_ram;
  // OUT
  output [BITSIZE_M_DataRdy-1:0] M_DataRdy;
  output [BITSIZE_M_Rdata_ram-1:0] M_Rdata_ram;
  output [BITSIZE_Mout_back_pressure-1:0] Mout_back_pressure;
  output [BITSIZE_S_oe_ram-1:0] S_oe_ram;
  output [BITSIZE_S_we_ram-1:0] S_we_ram;
  output [BITSIZE_S_addr_ram-1:0] S_addr_ram;
  output [BITSIZE_S_data_ram_size-1:0] S_data_ram_size;
  output [BITSIZE_S_Wdata_ram-1:0] S_Wdata_ram;
  
  function automatic integer log2;
    input integer value;
    `ifdef _SIM_HAVE_CLOG2
      log2 = $clog2(value);
    `else
      automatic integer temp_value = value-1;
      for (log2=0; temp_value > 0; log2=log2+1)
        temp_value = temp_value >> 1;
    `endif
  endfunction
  
  localparam MEM_DELAY_MAX= MEM_DELAY_READ > MEM_DELAY_WRITE ? MEM_DELAY_READ : MEM_DELAY_WRITE,
    ACTIVE_READ= MEM_DELAY_READ > 1 ? (MEM_DELAY_READ-2) : 0,
    ACTIVE_WRITE= MEM_DELAY_WRITE > 1 ? (MEM_DELAY_WRITE-2) : 0,
    CHANNELS_NUMBER=BITSIZE_Mout_oe_ram,
    BITSIZE_oe=1,
    BITSIZE_we=1,
    BITSIZE_addr=BITSIZE_Mout_addr_ram/CHANNELS_NUMBER,
    BITSIZE_Wsize=BITSIZE_Mout_data_ram_size/CHANNELS_NUMBER,
    BITSIZE_Wdata=BITSIZE_Mout_Wdata_ram/CHANNELS_NUMBER,
    BITSIZE_ready=1,
    BITSIZE_Rdata=BITSIZE_M_Rdata_ram/CHANNELS_NUMBER,
    BITSIZE_item=BITSIZE_Wdata+BITSIZE_Wsize+BITSIZE_addr+BITSIZE_we+BITSIZE_oe,
    OFFSET_oe=0,
    OFFSET_we=OFFSET_oe+BITSIZE_oe,
    OFFSET_addr=OFFSET_we+BITSIZE_we,
    OFFSET_Wsize=OFFSET_addr+BITSIZE_addr,
    OFFSET_Wdata=OFFSET_Wsize+BITSIZE_Wsize,
    BITSIZE_S_Rdata=BITSIZE_Sout_Rdata_ram/BITSIZE_S_oe_ram,
    BITSIZE_S_ready=1,
    SLAVE_VALID=BITSIZE_Mout_oe_ram == BITSIZE_S_oe_ram,
    QUEUE_BITSIZE=QUEUE_SIZE > 1 ? log2(QUEUE_SIZE) : 1;
  
  genvar i;
  integer dump_file;
  wire [BITSIZE_M_DataRdy-1:0] _M_DataRdy, _M_DataRdy_reg;
  wire [BITSIZE_M_Rdata_ram-1:0] _M_Rdata_ram;
  
  assign S_oe_ram = Mout_oe_ram;
  assign S_we_ram = Mout_we_ram;
  assign S_addr_ram = Mout_addr_ram;
  assign S_data_ram_size = Mout_data_ram_size;
  assign S_Wdata_ram = Mout_Wdata_ram;
  assign M_DataRdy = _M_DataRdy;
  assign M_Rdata_ram = _M_Rdata_ram;
  
  generate
    if(MEM_DUMP)
    begin
      initial
      begin
        dump_file = $fopen(MEM_DUMP_FILE, "w");
        $fwrite(dump_file, "Channel,Operation,Address,Bitwidth,Data\n");
      end
  
      always@(posedge clock)
      begin
        if(done_port)
        begin
          $fflush(dump_file);
        end
      end
    end
  endgenerate
  
  if_utils #(index, BITSIZE_Rdata) m_utils();
  
  generate
    for(i = 0; i < CHANNELS_NUMBER; i = i + 1)
    begin : channel
      wire [MEM_DELAY_MAX*BITSIZE_item-1:0] queue_next;
      wire [BITSIZE_oe-1:0] oe;
      wire [BITSIZE_we-1:0] we;
      ptr_t Waddr, Raddr;
      shortint unsigned Wsize;
      wire [BITSIZE_Wdata-1:0] Wdata;
      reg [BITSIZE_ready-1:0] Wready, Rready, Wready_reg;
      reg [BITSIZE_Rdata-1:0] Rdata;
  
      reg [QUEUE_BITSIZE-1:0] queue_counter;
      wire [QUEUE_BITSIZE-1:0] queue_counter_next;
  
      if(MEM_DELAY_WRITE == 1)
      begin
        always@(posedge clock)
        begin
          Wready_reg <= Wready;
        end
      end
      else
      begin
        assign Wready_reg = Wready;
      end
      if(QUEUE_SIZE > 1)
      begin
        assign Mout_back_pressure[i] = queue_counter == 0 ? 0 : (queue_counter - _M_DataRdy_reg[BITSIZE_ready*i+:BITSIZE_ready]) == (QUEUE_SIZE - 1);
      end
      else
      begin
        assign Mout_back_pressure[i] = queue_counter && !_M_DataRdy_reg[BITSIZE_ready*i+:BITSIZE_ready];
      end
  
      always @(posedge clock)
      begin
        if(reset == 1'b0)
        begin
          queue_counter <= 0;
        end
        else
        begin
          queue_counter <= queue_counter_next;
        end
      end
  
      if(QUEUE_SIZE > 1)
      begin
        assign queue_counter_next = queue_counter + (((Mout_we_ram[i] || Mout_oe_ram[i]) && !Mout_back_pressure[i] && base_addr <= Mout_addr_ram[i*BITSIZE_addr +: BITSIZE_addr]) && (queue_counter == 0 ? 1 : ((queue_counter  - _M_DataRdy_reg[BITSIZE_ready*i+:BITSIZE_ready]) < (QUEUE_SIZE - 1)))) - _M_DataRdy_reg[BITSIZE_ready*i+:BITSIZE_ready];
      end
      else
      begin
        assign queue_counter_next = ((Mout_we_ram[i] || Mout_oe_ram[i]) && !Mout_back_pressure[i] && base_addr <= Mout_addr_ram[i*BITSIZE_addr +: BITSIZE_addr]) || (queue_counter && !_M_DataRdy_reg[BITSIZE_ready*i+:BITSIZE_ready]);
      end
  
      
      if(MEM_DELAY_MAX > 1)
      begin : requests_queue
        reg [MEM_DELAY_MAX*BITSIZE_item-1:0] queue;
        wire [BITSIZE_item-1:0] new_elem;
  
              assign new_elem = Mout_back_pressure[i] ? {BITSIZE_item{1'b0}} : 
                          {Mout_Wdata_ram[BITSIZE_Wdata*i+:BITSIZE_Wdata],
                          Mout_data_ram_size[BITSIZE_Wsize*i+:BITSIZE_Wsize],
                          Mout_addr_ram[BITSIZE_addr*i+:BITSIZE_addr],
                          Mout_we_ram[BITSIZE_we*i+:BITSIZE_we],
                          Mout_oe_ram[BITSIZE_oe*i+:BITSIZE_oe]};
  
              assign queue_next = {queue[(MEM_DELAY_MAX-1)*BITSIZE_item-1:0],new_elem};
  
        always@(posedge clock)
        begin
          if(reset == 1'b0)
          begin
            queue <= 0;
          end
          else
          begin
            queue <= queue_next;
          end
        end
      end
      else
      begin
        assign queue_next = {Mout_Wdata_ram[BITSIZE_Wdata*i+:BITSIZE_Wdata], 
          Mout_data_ram_size[BITSIZE_Wsize*i+:BITSIZE_Wsize],
          Mout_addr_ram[BITSIZE_addr*i+:BITSIZE_addr],
          Mout_we_ram[BITSIZE_we*i+:BITSIZE_we],
          Mout_oe_ram[BITSIZE_oe*i+:BITSIZE_oe]};
      end
  
      assign oe = queue_next[ACTIVE_READ*BITSIZE_item+OFFSET_oe+:BITSIZE_oe];
      assign Raddr = queue_next[ACTIVE_READ*BITSIZE_item+OFFSET_addr+:BITSIZE_addr];
      assign _M_DataRdy[BITSIZE_ready*i+:BITSIZE_ready] = Wready | Rready | (Sout_DataRdy[BITSIZE_S_ready*i*SLAVE_VALID+:BITSIZE_S_ready] === 1'b1);
      assign _M_DataRdy_reg[BITSIZE_ready*i+:BITSIZE_ready] = Wready_reg | Rready; // Used to update at posedge clock of the queue_counter;
      assign _M_Rdata_ram[BITSIZE_Rdata*i+:BITSIZE_Rdata] = Rdata | (Sout_Rdata_ram[BITSIZE_S_Rdata*i*SLAVE_VALID+:BITSIZE_S_Rdata] & {BITSIZE_S_Rdata{Sout_DataRdy[BITSIZE_S_ready*i*SLAVE_VALID+:BITSIZE_S_ready] === 1'b1}});
  
      if(MEM_DELAY_READ > 1)
      begin : read_channel
        always@(posedge clock)
        begin : read_channel
          automatic reg [BITSIZE_Rdata-1:0] data;
          Rready <= 0;
          Rdata <= 0;
          if(oe && base_addr <= Raddr)
          begin
            data = m_utils.read_a(Raddr);
            Rdata <= data;
            Rready <= 1;
            if(MEM_DUMP)
            begin
              $fwrite(dump_file, "%0d,r,%0X,%0d,%0X\n", i, Raddr, BITSIZE_Rdata, data);
            end
          end
        end
      end
      else
      begin
        always@(negedge clock)
        begin : read_channel
          automatic reg [BITSIZE_Rdata-1:0] data;
          Rready <= 0;
          Rdata <= 0;
          if(oe && base_addr <= Raddr)
          begin
            data = m_utils.read_a(Raddr);
            Rdata <= data;
            Rready <= 1;
            if(MEM_DUMP)
            begin
              $fwrite(dump_file, "%0d,r,%0X,%0d,%0X\n", i, Raddr, BITSIZE_Rdata, data);
            end
          end
        end
      end
  
      assign we = queue_next[ACTIVE_WRITE*BITSIZE_item+OFFSET_we+:BITSIZE_we];
      assign Waddr = queue_next[ACTIVE_WRITE*BITSIZE_item+OFFSET_addr+:BITSIZE_addr];
      assign Wsize = {{16-BITSIZE_Wsize{1'b0}}, queue_next[ACTIVE_WRITE*BITSIZE_item+OFFSET_Wsize+:BITSIZE_Wsize]};
      assign Wdata = queue_next[ACTIVE_WRITE*BITSIZE_item+OFFSET_Wdata+:BITSIZE_Wdata];
  
      if(MEM_DELAY_WRITE > 1)
      begin : write_channel
        always@(posedge clock)
        begin : write_channel
          Wready <= 0;
          if(we && base_addr <= Waddr)
          begin
            void'(m_utils.write_sa(Wdata, Wsize, Waddr));
            Wready <= 1;
            if(MEM_DUMP)
            begin
              $fwrite(dump_file, "%0d,w,%0X,%0d,%0X\n", i, Waddr, Wsize, Wdata);
            end
          end
        end
      end
      else
      begin
        always@(negedge clock)
        begin : write_channel
          Wready <= 0;
          if(we && base_addr <= Waddr)
          begin
            void'(m_utils.write_sa(Wdata, Wsize, Waddr));
            Wready <= 1;
            if(MEM_DUMP)
            begin
              $fwrite(dump_file, "%0d,w,%0X,%0d,%0X\n", i, Waddr, Wsize, Wdata);
            end
          end
        end
      end
  
      always @(posedge clock)
      begin
        if (we & oe)
        begin
          $display("ERROR - Mout_we_ram and Mout_oe_ram both enabled on channel %0d!", i);
          $finish;
        end
      end
    end
  endgenerate
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_m_axi_gmem_in0(clock,
  reset,
  done_port,
  m_axi_gmem_in0_awready,
  m_axi_gmem_in0_wready,
  m_axi_gmem_in0_bid,
  m_axi_gmem_in0_bresp,
  m_axi_gmem_in0_buser,
  m_axi_gmem_in0_bvalid,
  m_axi_gmem_in0_arready,
  m_axi_gmem_in0_rid,
  m_axi_gmem_in0_rdata,
  m_axi_gmem_in0_rresp,
  m_axi_gmem_in0_rlast,
  m_axi_gmem_in0_ruser,
  m_axi_gmem_in0_rvalid,
  m_axi_gmem_in0_awid,
  m_axi_gmem_in0_awaddr,
  m_axi_gmem_in0_awlen,
  m_axi_gmem_in0_awsize,
  m_axi_gmem_in0_awburst,
  m_axi_gmem_in0_awlock,
  m_axi_gmem_in0_awcache,
  m_axi_gmem_in0_awprot,
  m_axi_gmem_in0_awqos,
  m_axi_gmem_in0_awregion,
  m_axi_gmem_in0_awuser,
  m_axi_gmem_in0_awvalid,
  m_axi_gmem_in0_wdata,
  m_axi_gmem_in0_wstrb,
  m_axi_gmem_in0_wlast,
  m_axi_gmem_in0_wuser,
  m_axi_gmem_in0_wvalid,
  m_axi_gmem_in0_bready,
  m_axi_gmem_in0_arid,
  m_axi_gmem_in0_araddr,
  m_axi_gmem_in0_arlen,
  m_axi_gmem_in0_arsize,
  m_axi_gmem_in0_arburst,
  m_axi_gmem_in0_arlock,
  m_axi_gmem_in0_arcache,
  m_axi_gmem_in0_arprot,
  m_axi_gmem_in0_arqos,
  m_axi_gmem_in0_arregion,
  m_axi_gmem_in0_aruser,
  m_axi_gmem_in0_arvalid,
  m_axi_gmem_in0_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem_in0_bid=1,
    BITSIZE_m_axi_gmem_in0_bresp=2,
    BITSIZE_m_axi_gmem_in0_buser=1,
    BITSIZE_m_axi_gmem_in0_rid=1,
    BITSIZE_m_axi_gmem_in0_rdata=1,
    BITSIZE_m_axi_gmem_in0_rresp=2,
    BITSIZE_m_axi_gmem_in0_ruser=1,
    BITSIZE_m_axi_gmem_in0_awid=1,
    BITSIZE_m_axi_gmem_in0_awaddr=1,
    BITSIZE_m_axi_gmem_in0_awlen=1,
    BITSIZE_m_axi_gmem_in0_awsize=1,
    BITSIZE_m_axi_gmem_in0_awburst=2,
    BITSIZE_m_axi_gmem_in0_awlock=1,
    BITSIZE_m_axi_gmem_in0_awcache=1,
    BITSIZE_m_axi_gmem_in0_awprot=1,
    BITSIZE_m_axi_gmem_in0_awqos=1,
    BITSIZE_m_axi_gmem_in0_awregion=1,
    BITSIZE_m_axi_gmem_in0_awuser=1,
    BITSIZE_m_axi_gmem_in0_wdata=1,
    BITSIZE_m_axi_gmem_in0_wstrb=1,
    BITSIZE_m_axi_gmem_in0_wuser=1,
    BITSIZE_m_axi_gmem_in0_arid=1,
    BITSIZE_m_axi_gmem_in0_araddr=1,
    BITSIZE_m_axi_gmem_in0_arlen=1,
    BITSIZE_m_axi_gmem_in0_arsize=1,
    BITSIZE_m_axi_gmem_in0_arburst=2,
    BITSIZE_m_axi_gmem_in0_arlock=1,
    BITSIZE_m_axi_gmem_in0_arcache=1,
    BITSIZE_m_axi_gmem_in0_arprot=1,
    BITSIZE_m_axi_gmem_in0_arqos=1,
    BITSIZE_m_axi_gmem_in0_arregion=1,
    BITSIZE_m_axi_gmem_in0_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem_in0_awid-1:0] m_axi_gmem_in0_awid;
  input [BITSIZE_m_axi_gmem_in0_awaddr-1:0] m_axi_gmem_in0_awaddr;
  input [BITSIZE_m_axi_gmem_in0_awlen-1:0] m_axi_gmem_in0_awlen;
  input [BITSIZE_m_axi_gmem_in0_awsize-1:0] m_axi_gmem_in0_awsize;
  input [BITSIZE_m_axi_gmem_in0_awburst-1:0] m_axi_gmem_in0_awburst;
  input [BITSIZE_m_axi_gmem_in0_awlock-1:0] m_axi_gmem_in0_awlock;
  input [BITSIZE_m_axi_gmem_in0_awcache-1:0] m_axi_gmem_in0_awcache;
  input [BITSIZE_m_axi_gmem_in0_awprot-1:0] m_axi_gmem_in0_awprot;
  input [BITSIZE_m_axi_gmem_in0_awqos-1:0] m_axi_gmem_in0_awqos;
  input [BITSIZE_m_axi_gmem_in0_awregion-1:0] m_axi_gmem_in0_awregion;
  input [BITSIZE_m_axi_gmem_in0_awuser-1:0] m_axi_gmem_in0_awuser;
  input m_axi_gmem_in0_awvalid;
  input [BITSIZE_m_axi_gmem_in0_wdata-1:0] m_axi_gmem_in0_wdata;
  input [BITSIZE_m_axi_gmem_in0_wstrb-1:0] m_axi_gmem_in0_wstrb;
  input m_axi_gmem_in0_wlast;
  input [BITSIZE_m_axi_gmem_in0_wuser-1:0] m_axi_gmem_in0_wuser;
  input m_axi_gmem_in0_wvalid;
  input m_axi_gmem_in0_bready;
  input [BITSIZE_m_axi_gmem_in0_arid-1:0] m_axi_gmem_in0_arid;
  input [BITSIZE_m_axi_gmem_in0_araddr-1:0] m_axi_gmem_in0_araddr;
  input [BITSIZE_m_axi_gmem_in0_arlen-1:0] m_axi_gmem_in0_arlen;
  input [BITSIZE_m_axi_gmem_in0_arsize-1:0] m_axi_gmem_in0_arsize;
  input [BITSIZE_m_axi_gmem_in0_arburst-1:0] m_axi_gmem_in0_arburst;
  input [BITSIZE_m_axi_gmem_in0_arlock-1:0] m_axi_gmem_in0_arlock;
  input [BITSIZE_m_axi_gmem_in0_arcache-1:0] m_axi_gmem_in0_arcache;
  input [BITSIZE_m_axi_gmem_in0_arprot-1:0] m_axi_gmem_in0_arprot;
  input [BITSIZE_m_axi_gmem_in0_arqos-1:0] m_axi_gmem_in0_arqos;
  input [BITSIZE_m_axi_gmem_in0_arregion-1:0] m_axi_gmem_in0_arregion;
  input [BITSIZE_m_axi_gmem_in0_aruser-1:0] m_axi_gmem_in0_aruser;
  input m_axi_gmem_in0_arvalid;
  input m_axi_gmem_in0_rready;
  // OUT
  output m_axi_gmem_in0_awready;
  output m_axi_gmem_in0_wready;
  output [BITSIZE_m_axi_gmem_in0_bid-1:0] m_axi_gmem_in0_bid;
  output [BITSIZE_m_axi_gmem_in0_bresp-1:0] m_axi_gmem_in0_bresp;
  output [BITSIZE_m_axi_gmem_in0_buser-1:0] m_axi_gmem_in0_buser;
  output m_axi_gmem_in0_bvalid;
  output m_axi_gmem_in0_arready;
  output [BITSIZE_m_axi_gmem_in0_rid-1:0] m_axi_gmem_in0_rid;
  output [BITSIZE_m_axi_gmem_in0_rdata-1:0] m_axi_gmem_in0_rdata;
  output [BITSIZE_m_axi_gmem_in0_rresp-1:0] m_axi_gmem_in0_rresp;
  output m_axi_gmem_in0_rlast;
  output [BITSIZE_m_axi_gmem_in0_ruser-1:0] m_axi_gmem_in0_ruser;
  output m_axi_gmem_in0_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem_in0_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem_in0_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem_in0_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem_in0_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem_in0_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem_in0_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem_in0_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem_in0_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem_in0_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem_in0_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem_in0_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem_in0_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem_in0_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem_in0_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem_in0_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem_in0_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem_in0_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem_in0_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem_in0_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem_in0_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem_in0_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem_in0_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem_in0_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem_in0_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem_in0_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem_in0_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem_in0_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem_in0_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem_in0_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem_in0_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem_in0_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem_in0_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem_in0_awready=awready;
  assign m_axi_gmem_in0_wready=wready;
  assign m_axi_gmem_in0_bid=bid;
  assign m_axi_gmem_in0_bresp=bresp;
  assign m_axi_gmem_in0_buser=buser;
  assign m_axi_gmem_in0_bvalid=bvalid;
  assign m_axi_gmem_in0_arready=arready;
  assign m_axi_gmem_in0_rid=rid;
  assign m_axi_gmem_in0_rdata=rdata;
  assign m_axi_gmem_in0_rresp=rresp;
  assign m_axi_gmem_in0_rlast=rlast;
  assign m_axi_gmem_in0_ruser=ruser;
  assign m_axi_gmem_in0_rvalid=rvalid;
  assign awid=m_axi_gmem_in0_awid;
  assign awaddr=m_axi_gmem_in0_awaddr;
  assign awlen=m_axi_gmem_in0_awlen;
  assign awsize=m_axi_gmem_in0_awsize;
  assign awburst=m_axi_gmem_in0_awburst;
  assign awlock=m_axi_gmem_in0_awlock;
  assign awcache=m_axi_gmem_in0_awcache;
  assign awprot=m_axi_gmem_in0_awprot;
  assign awqos=m_axi_gmem_in0_awqos;
  assign awregion=m_axi_gmem_in0_awregion;
  assign awuser=m_axi_gmem_in0_awuser;
  assign awvalid=m_axi_gmem_in0_awvalid;
  assign wdata=m_axi_gmem_in0_wdata;
  assign wstrb=m_axi_gmem_in0_wstrb;
  assign wlast=m_axi_gmem_in0_wlast;
  assign wuser=m_axi_gmem_in0_wuser;
  assign wvalid=m_axi_gmem_in0_wvalid;
  assign bready=m_axi_gmem_in0_bready;
  assign arid=m_axi_gmem_in0_arid;
  assign araddr=m_axi_gmem_in0_araddr;
  assign arlen=m_axi_gmem_in0_arlen;
  assign arsize=m_axi_gmem_in0_arsize;
  assign arburst=m_axi_gmem_in0_arburst;
  assign arlock=m_axi_gmem_in0_arlock;
  assign arcache=m_axi_gmem_in0_arcache;
  assign arprot=m_axi_gmem_in0_arprot;
  assign arqos=m_axi_gmem_in0_arqos;
  assign arregion=m_axi_gmem_in0_arregion;
  assign aruser=m_axi_gmem_in0_aruser;
  assign arvalid=m_axi_gmem_in0_arvalid;
  assign rready=m_axi_gmem_in0_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem_in0_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem_in0_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem_in0_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem_in0_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem_in0_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem_in0_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem_in0_arid,
    OFFSET_delay=0,
    OFFSET_counter=OFFSET_delay+BITSIZE_delay,
    OFFSET_burst=OFFSET_counter+BITSIZE_counter,
    OFFSET_len=OFFSET_burst+BITSIZE_burst,
    OFFSET_size=OFFSET_len+BITSIZE_len,
    OFFSET_addr=OFFSET_size+BITSIZE_size,
    OFFSET_id=OFFSET_addr+BITSIZE_addr,
    OFFSET_data=OFFSET_id+BITSIZE_id,
    OFFSET_wstrb=OFFSET_data+BITSIZE_data,
    BITSIZE_aritem=BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay,
    BITSIZE_awitem=BITSIZE_wstrb+BITSIZE_data+BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay;
  
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] arqueue;
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] next_arqueue;
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] awqueue; 
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] next_awqueue;
  reg [31:0] test_addr;
  reg [31:0] test_wstrb;
  reg [31:0] test_data;
  reg [31:0] test_addr_read;
  integer arqueue_size, next_arqueue_size;
  integer awqueue_size, next_awqueue_size;
  
  reg [BITSIZE_id-1:0] awid_reg;
  reg [BITSIZE_addr-1:0] awaddr_reg;
  reg [BITSIZE_size-1:0] awsize_reg;
  reg [BITSIZE_len-1:0] awlen_reg; 
  reg [BITSIZE_burst-1:0] awburst_reg;
  reg [BITSIZE_counter-1:0] counter_reg, counter_next;
  reg write_done;
  reg wlast_reg, wlast_next;
  
  if_utils #(index, BITSIZE_data) m_utils();
  
  initial
  begin
    arqueue = 0;
    arqueue_size = 0;
    next_arqueue = 0;
    next_arqueue_size = 0;
    awqueue = 0;
    awqueue_size = 0;
    next_awqueue = 0;
    next_awqueue_size = 0;
    awready = 0;
    wready = 0;
    bid = 0;
    bresp = 0;
    buser = 0;
    bvalid = 0;
    arready = 0;
    rid = 0;
    rdata = 0;
    rresp = 0;
    rlast = 0;
    ruser = 0;
    rvalid = 0;
    awid_reg = 0;
    awaddr_reg = 0;
    awsize_reg = 0;
    awlen_reg = 0;
    awburst_reg = 0;
  end
  
  // Combinatorial logic for read transactions
  always@(*)
  begin: read_comb
    automatic integer unsigned i;
    next_arqueue = arqueue;
    next_arqueue_size = arqueue_size;
    if(arvalid && arready)  // Valid and ready -> accept new transaction
    begin
      next_arqueue[arqueue_size*BITSIZE_aritem +:BITSIZE_aritem] = {arid, araddr, arsize, arlen, arburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + READ_DELAY)}; // size of parameter is implementation dependent
      next_arqueue_size = arqueue_size + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] = arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1) && rready && rvalid)
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_arqueue[(i-1)*BITSIZE_aritem+:BITSIZE_aritem] = next_arqueue[i*BITSIZE_aritem+:BITSIZE_aritem];
      end
      next_arqueue_size = next_arqueue_size - 1;
    end
    if(next_arqueue_size > 0 && (next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1) && (next_arqueue[OFFSET_counter+:BITSIZE_counter] < (next_arqueue[OFFSET_len+:BITSIZE_len] + 1)))
    begin
      next_arqueue[OFFSET_counter+:BITSIZE_counter] = next_arqueue[OFFSET_counter+:BITSIZE_counter] + 1;
    end
  end
  
  // Combinatorial logic for write transactions
  always@(*) 
  begin: write_comb
    automatic integer i;
    automatic reg [BITSIZE_counter-1:0] counter;
    next_awqueue = awqueue;
    next_awqueue_size = awqueue_size;
    wlast_next = wlast_reg;
    if(awvalid && awready && wready && wvalid) // Valid and ready -> accept new transaction and save data
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid, awaddr, awsize, awlen, awburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
    end
    else if(awvalid && awready && wlast_reg)
    begin
      awid_reg = awid;
      awaddr_reg = awaddr;
      awsize_reg = awsize;
      awlen_reg = awlen; 
      awburst_reg = awburst;
      counter_next = 0;
      wlast_next = 0;
    end
    else if(wready && wvalid)
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid_reg, awaddr_reg, awsize_reg, awlen_reg, awburst_reg, counter_reg, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
      counter_next = counter_reg + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] = awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(write_done && next_awqueue_size > 0 && ((next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len] && bready) || next_awqueue[OFFSET_counter+:BITSIZE_counter] < next_awqueue[OFFSET_len+:BITSIZE_len]))
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_awqueue[(i-1)*BITSIZE_awitem+:BITSIZE_awitem] = next_awqueue[i*BITSIZE_awitem+:BITSIZE_awitem];
      end
      next_awqueue_size = next_awqueue_size - 1;
    end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arready <= 0;
      awready <= 0;
      wready <= 0;
      wlast_reg <= 1;
      counter_reg <= 0;
     end
     else
     begin
      arready <= (next_arqueue_size - (next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= next_arqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE);  //Ready if next_queue_size - rlast < QUEUE_SIZE
      awready <= (wlast_next || wlast) && (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); // ready if next_queue_size - bvalid < QUEUE_SIZE
      wready <= (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); 
      wlast_reg <= wlast_next || wlast;
      counter_reg <= counter_next;
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      rvalid <= 0;
      bvalid <= 0;
     end
     else
     begin
      rvalid <= (next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1); // if at posedge_clock delay is 1 I have to perfrom the operation in this cycle
      bvalid <= (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == (next_awqueue[OFFSET_len+:BITSIZE_len])); // if at posedge_clock delay is 1 I have to perfrom the last operation in this cycle
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arqueue <= 0;
      arqueue_size <= 0;
      awqueue <= 0;
      awqueue_size <= 0;
     end
     else
     begin
      arqueue <= next_arqueue;
      arqueue_size <= next_arqueue_size;
      awqueue <= next_awqueue;
      awqueue_size <= next_awqueue_size;
     end
  end
  
  // Sequential logic for read transactions
  always@(posedge clock)
  begin : read_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    rlast <= 0;
    test_addr_read <= 0;
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1)
    begin
      if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr] + (next_arqueue[OFFSET_counter+:BITSIZE_counter] - 1) * (1 << next_arqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_addr_read <= currAddr;
      rid <= next_arqueue[OFFSET_id+:BITSIZE_id];
      rdata <= m_utils.read_a(currAddr);
      if(next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1))
      begin
        rlast <= 1;
      end
    end
  end
  
  // Sequential logic for write transactions
  always@(posedge clock)
  begin: write_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    test_wstrb <=0;
    test_addr <= 0;
    test_data <= 0;
    write_done <= 0;
    if(next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1) // Performs the first write of the queue
    begin
      if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr] + next_awqueue[OFFSET_counter+:BITSIZE_counter] * (1 << next_awqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_wstrb <= next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb];
      test_addr <= currAddr;
      test_data <= next_awqueue[OFFSET_data+:BITSIZE_data];
      bid <= next_awqueue[OFFSET_id+:BITSIZE_id];
      write_done <= 1;
      void'(m_utils.write_strobe(next_awqueue[OFFSET_data+:BITSIZE_data], next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb], currAddr));
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module IF_PORT_IN(clock,
  setup_port,
  val_port);
  parameter index=0,
    BITSIZE_val_port=1;
  // IN
  input clock;
  input setup_port;
  // OUT
  output [BITSIZE_val_port-1:0] val_port;
  if_utils #(index, BITSIZE_val_port) m_utils();
  reg [BITSIZE_val_port-1:0] val;
  wire [BITSIZE_val_port-1:0] val_next;
  
  initial val = 0;
  
  assign val_port = val;
  assign val_next = val;
  
  always @(posedge clock) 
  begin
    val <= val_next;
    if(setup_port)
    begin
      val <= m_utils.read();
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_m_axi_gmem_in1(clock,
  reset,
  done_port,
  m_axi_gmem_in1_awready,
  m_axi_gmem_in1_wready,
  m_axi_gmem_in1_bid,
  m_axi_gmem_in1_bresp,
  m_axi_gmem_in1_buser,
  m_axi_gmem_in1_bvalid,
  m_axi_gmem_in1_arready,
  m_axi_gmem_in1_rid,
  m_axi_gmem_in1_rdata,
  m_axi_gmem_in1_rresp,
  m_axi_gmem_in1_rlast,
  m_axi_gmem_in1_ruser,
  m_axi_gmem_in1_rvalid,
  m_axi_gmem_in1_awid,
  m_axi_gmem_in1_awaddr,
  m_axi_gmem_in1_awlen,
  m_axi_gmem_in1_awsize,
  m_axi_gmem_in1_awburst,
  m_axi_gmem_in1_awlock,
  m_axi_gmem_in1_awcache,
  m_axi_gmem_in1_awprot,
  m_axi_gmem_in1_awqos,
  m_axi_gmem_in1_awregion,
  m_axi_gmem_in1_awuser,
  m_axi_gmem_in1_awvalid,
  m_axi_gmem_in1_wdata,
  m_axi_gmem_in1_wstrb,
  m_axi_gmem_in1_wlast,
  m_axi_gmem_in1_wuser,
  m_axi_gmem_in1_wvalid,
  m_axi_gmem_in1_bready,
  m_axi_gmem_in1_arid,
  m_axi_gmem_in1_araddr,
  m_axi_gmem_in1_arlen,
  m_axi_gmem_in1_arsize,
  m_axi_gmem_in1_arburst,
  m_axi_gmem_in1_arlock,
  m_axi_gmem_in1_arcache,
  m_axi_gmem_in1_arprot,
  m_axi_gmem_in1_arqos,
  m_axi_gmem_in1_arregion,
  m_axi_gmem_in1_aruser,
  m_axi_gmem_in1_arvalid,
  m_axi_gmem_in1_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem_in1_bid=1,
    BITSIZE_m_axi_gmem_in1_bresp=2,
    BITSIZE_m_axi_gmem_in1_buser=1,
    BITSIZE_m_axi_gmem_in1_rid=1,
    BITSIZE_m_axi_gmem_in1_rdata=1,
    BITSIZE_m_axi_gmem_in1_rresp=2,
    BITSIZE_m_axi_gmem_in1_ruser=1,
    BITSIZE_m_axi_gmem_in1_awid=1,
    BITSIZE_m_axi_gmem_in1_awaddr=1,
    BITSIZE_m_axi_gmem_in1_awlen=1,
    BITSIZE_m_axi_gmem_in1_awsize=1,
    BITSIZE_m_axi_gmem_in1_awburst=2,
    BITSIZE_m_axi_gmem_in1_awlock=1,
    BITSIZE_m_axi_gmem_in1_awcache=1,
    BITSIZE_m_axi_gmem_in1_awprot=1,
    BITSIZE_m_axi_gmem_in1_awqos=1,
    BITSIZE_m_axi_gmem_in1_awregion=1,
    BITSIZE_m_axi_gmem_in1_awuser=1,
    BITSIZE_m_axi_gmem_in1_wdata=1,
    BITSIZE_m_axi_gmem_in1_wstrb=1,
    BITSIZE_m_axi_gmem_in1_wuser=1,
    BITSIZE_m_axi_gmem_in1_arid=1,
    BITSIZE_m_axi_gmem_in1_araddr=1,
    BITSIZE_m_axi_gmem_in1_arlen=1,
    BITSIZE_m_axi_gmem_in1_arsize=1,
    BITSIZE_m_axi_gmem_in1_arburst=2,
    BITSIZE_m_axi_gmem_in1_arlock=1,
    BITSIZE_m_axi_gmem_in1_arcache=1,
    BITSIZE_m_axi_gmem_in1_arprot=1,
    BITSIZE_m_axi_gmem_in1_arqos=1,
    BITSIZE_m_axi_gmem_in1_arregion=1,
    BITSIZE_m_axi_gmem_in1_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem_in1_awid-1:0] m_axi_gmem_in1_awid;
  input [BITSIZE_m_axi_gmem_in1_awaddr-1:0] m_axi_gmem_in1_awaddr;
  input [BITSIZE_m_axi_gmem_in1_awlen-1:0] m_axi_gmem_in1_awlen;
  input [BITSIZE_m_axi_gmem_in1_awsize-1:0] m_axi_gmem_in1_awsize;
  input [BITSIZE_m_axi_gmem_in1_awburst-1:0] m_axi_gmem_in1_awburst;
  input [BITSIZE_m_axi_gmem_in1_awlock-1:0] m_axi_gmem_in1_awlock;
  input [BITSIZE_m_axi_gmem_in1_awcache-1:0] m_axi_gmem_in1_awcache;
  input [BITSIZE_m_axi_gmem_in1_awprot-1:0] m_axi_gmem_in1_awprot;
  input [BITSIZE_m_axi_gmem_in1_awqos-1:0] m_axi_gmem_in1_awqos;
  input [BITSIZE_m_axi_gmem_in1_awregion-1:0] m_axi_gmem_in1_awregion;
  input [BITSIZE_m_axi_gmem_in1_awuser-1:0] m_axi_gmem_in1_awuser;
  input m_axi_gmem_in1_awvalid;
  input [BITSIZE_m_axi_gmem_in1_wdata-1:0] m_axi_gmem_in1_wdata;
  input [BITSIZE_m_axi_gmem_in1_wstrb-1:0] m_axi_gmem_in1_wstrb;
  input m_axi_gmem_in1_wlast;
  input [BITSIZE_m_axi_gmem_in1_wuser-1:0] m_axi_gmem_in1_wuser;
  input m_axi_gmem_in1_wvalid;
  input m_axi_gmem_in1_bready;
  input [BITSIZE_m_axi_gmem_in1_arid-1:0] m_axi_gmem_in1_arid;
  input [BITSIZE_m_axi_gmem_in1_araddr-1:0] m_axi_gmem_in1_araddr;
  input [BITSIZE_m_axi_gmem_in1_arlen-1:0] m_axi_gmem_in1_arlen;
  input [BITSIZE_m_axi_gmem_in1_arsize-1:0] m_axi_gmem_in1_arsize;
  input [BITSIZE_m_axi_gmem_in1_arburst-1:0] m_axi_gmem_in1_arburst;
  input [BITSIZE_m_axi_gmem_in1_arlock-1:0] m_axi_gmem_in1_arlock;
  input [BITSIZE_m_axi_gmem_in1_arcache-1:0] m_axi_gmem_in1_arcache;
  input [BITSIZE_m_axi_gmem_in1_arprot-1:0] m_axi_gmem_in1_arprot;
  input [BITSIZE_m_axi_gmem_in1_arqos-1:0] m_axi_gmem_in1_arqos;
  input [BITSIZE_m_axi_gmem_in1_arregion-1:0] m_axi_gmem_in1_arregion;
  input [BITSIZE_m_axi_gmem_in1_aruser-1:0] m_axi_gmem_in1_aruser;
  input m_axi_gmem_in1_arvalid;
  input m_axi_gmem_in1_rready;
  // OUT
  output m_axi_gmem_in1_awready;
  output m_axi_gmem_in1_wready;
  output [BITSIZE_m_axi_gmem_in1_bid-1:0] m_axi_gmem_in1_bid;
  output [BITSIZE_m_axi_gmem_in1_bresp-1:0] m_axi_gmem_in1_bresp;
  output [BITSIZE_m_axi_gmem_in1_buser-1:0] m_axi_gmem_in1_buser;
  output m_axi_gmem_in1_bvalid;
  output m_axi_gmem_in1_arready;
  output [BITSIZE_m_axi_gmem_in1_rid-1:0] m_axi_gmem_in1_rid;
  output [BITSIZE_m_axi_gmem_in1_rdata-1:0] m_axi_gmem_in1_rdata;
  output [BITSIZE_m_axi_gmem_in1_rresp-1:0] m_axi_gmem_in1_rresp;
  output m_axi_gmem_in1_rlast;
  output [BITSIZE_m_axi_gmem_in1_ruser-1:0] m_axi_gmem_in1_ruser;
  output m_axi_gmem_in1_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem_in1_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem_in1_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem_in1_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem_in1_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem_in1_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem_in1_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem_in1_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem_in1_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem_in1_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem_in1_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem_in1_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem_in1_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem_in1_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem_in1_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem_in1_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem_in1_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem_in1_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem_in1_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem_in1_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem_in1_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem_in1_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem_in1_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem_in1_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem_in1_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem_in1_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem_in1_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem_in1_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem_in1_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem_in1_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem_in1_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem_in1_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem_in1_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem_in1_awready=awready;
  assign m_axi_gmem_in1_wready=wready;
  assign m_axi_gmem_in1_bid=bid;
  assign m_axi_gmem_in1_bresp=bresp;
  assign m_axi_gmem_in1_buser=buser;
  assign m_axi_gmem_in1_bvalid=bvalid;
  assign m_axi_gmem_in1_arready=arready;
  assign m_axi_gmem_in1_rid=rid;
  assign m_axi_gmem_in1_rdata=rdata;
  assign m_axi_gmem_in1_rresp=rresp;
  assign m_axi_gmem_in1_rlast=rlast;
  assign m_axi_gmem_in1_ruser=ruser;
  assign m_axi_gmem_in1_rvalid=rvalid;
  assign awid=m_axi_gmem_in1_awid;
  assign awaddr=m_axi_gmem_in1_awaddr;
  assign awlen=m_axi_gmem_in1_awlen;
  assign awsize=m_axi_gmem_in1_awsize;
  assign awburst=m_axi_gmem_in1_awburst;
  assign awlock=m_axi_gmem_in1_awlock;
  assign awcache=m_axi_gmem_in1_awcache;
  assign awprot=m_axi_gmem_in1_awprot;
  assign awqos=m_axi_gmem_in1_awqos;
  assign awregion=m_axi_gmem_in1_awregion;
  assign awuser=m_axi_gmem_in1_awuser;
  assign awvalid=m_axi_gmem_in1_awvalid;
  assign wdata=m_axi_gmem_in1_wdata;
  assign wstrb=m_axi_gmem_in1_wstrb;
  assign wlast=m_axi_gmem_in1_wlast;
  assign wuser=m_axi_gmem_in1_wuser;
  assign wvalid=m_axi_gmem_in1_wvalid;
  assign bready=m_axi_gmem_in1_bready;
  assign arid=m_axi_gmem_in1_arid;
  assign araddr=m_axi_gmem_in1_araddr;
  assign arlen=m_axi_gmem_in1_arlen;
  assign arsize=m_axi_gmem_in1_arsize;
  assign arburst=m_axi_gmem_in1_arburst;
  assign arlock=m_axi_gmem_in1_arlock;
  assign arcache=m_axi_gmem_in1_arcache;
  assign arprot=m_axi_gmem_in1_arprot;
  assign arqos=m_axi_gmem_in1_arqos;
  assign arregion=m_axi_gmem_in1_arregion;
  assign aruser=m_axi_gmem_in1_aruser;
  assign arvalid=m_axi_gmem_in1_arvalid;
  assign rready=m_axi_gmem_in1_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem_in1_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem_in1_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem_in1_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem_in1_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem_in1_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem_in1_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem_in1_arid,
    OFFSET_delay=0,
    OFFSET_counter=OFFSET_delay+BITSIZE_delay,
    OFFSET_burst=OFFSET_counter+BITSIZE_counter,
    OFFSET_len=OFFSET_burst+BITSIZE_burst,
    OFFSET_size=OFFSET_len+BITSIZE_len,
    OFFSET_addr=OFFSET_size+BITSIZE_size,
    OFFSET_id=OFFSET_addr+BITSIZE_addr,
    OFFSET_data=OFFSET_id+BITSIZE_id,
    OFFSET_wstrb=OFFSET_data+BITSIZE_data,
    BITSIZE_aritem=BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay,
    BITSIZE_awitem=BITSIZE_wstrb+BITSIZE_data+BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay;
  
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] arqueue;
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] next_arqueue;
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] awqueue; 
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] next_awqueue;
  reg [31:0] test_addr;
  reg [31:0] test_wstrb;
  reg [31:0] test_data;
  reg [31:0] test_addr_read;
  integer arqueue_size, next_arqueue_size;
  integer awqueue_size, next_awqueue_size;
  
  reg [BITSIZE_id-1:0] awid_reg;
  reg [BITSIZE_addr-1:0] awaddr_reg;
  reg [BITSIZE_size-1:0] awsize_reg;
  reg [BITSIZE_len-1:0] awlen_reg; 
  reg [BITSIZE_burst-1:0] awburst_reg;
  reg [BITSIZE_counter-1:0] counter_reg, counter_next;
  reg write_done;
  reg wlast_reg, wlast_next;
  
  if_utils #(index, BITSIZE_data) m_utils();
  
  initial
  begin
    arqueue = 0;
    arqueue_size = 0;
    next_arqueue = 0;
    next_arqueue_size = 0;
    awqueue = 0;
    awqueue_size = 0;
    next_awqueue = 0;
    next_awqueue_size = 0;
    awready = 0;
    wready = 0;
    bid = 0;
    bresp = 0;
    buser = 0;
    bvalid = 0;
    arready = 0;
    rid = 0;
    rdata = 0;
    rresp = 0;
    rlast = 0;
    ruser = 0;
    rvalid = 0;
    awid_reg = 0;
    awaddr_reg = 0;
    awsize_reg = 0;
    awlen_reg = 0;
    awburst_reg = 0;
  end
  
  // Combinatorial logic for read transactions
  always@(*)
  begin: read_comb
    automatic integer unsigned i;
    next_arqueue = arqueue;
    next_arqueue_size = arqueue_size;
    if(arvalid && arready)  // Valid and ready -> accept new transaction
    begin
      next_arqueue[arqueue_size*BITSIZE_aritem +:BITSIZE_aritem] = {arid, araddr, arsize, arlen, arburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + READ_DELAY)}; // size of parameter is implementation dependent
      next_arqueue_size = arqueue_size + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] = arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1) && rready && rvalid)
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_arqueue[(i-1)*BITSIZE_aritem+:BITSIZE_aritem] = next_arqueue[i*BITSIZE_aritem+:BITSIZE_aritem];
      end
      next_arqueue_size = next_arqueue_size - 1;
    end
    if(next_arqueue_size > 0 && (next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1) && (next_arqueue[OFFSET_counter+:BITSIZE_counter] < (next_arqueue[OFFSET_len+:BITSIZE_len] + 1)))
    begin
      next_arqueue[OFFSET_counter+:BITSIZE_counter] = next_arqueue[OFFSET_counter+:BITSIZE_counter] + 1;
    end
  end
  
  // Combinatorial logic for write transactions
  always@(*) 
  begin: write_comb
    automatic integer i;
    automatic reg [BITSIZE_counter-1:0] counter;
    next_awqueue = awqueue;
    next_awqueue_size = awqueue_size;
    wlast_next = wlast_reg;
    if(awvalid && awready && wready && wvalid) // Valid and ready -> accept new transaction and save data
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid, awaddr, awsize, awlen, awburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
    end
    else if(awvalid && awready && wlast_reg)
    begin
      awid_reg = awid;
      awaddr_reg = awaddr;
      awsize_reg = awsize;
      awlen_reg = awlen; 
      awburst_reg = awburst;
      counter_next = 0;
      wlast_next = 0;
    end
    else if(wready && wvalid)
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid_reg, awaddr_reg, awsize_reg, awlen_reg, awburst_reg, counter_reg, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
      counter_next = counter_reg + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] = awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(write_done && next_awqueue_size > 0 && ((next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len] && bready) || next_awqueue[OFFSET_counter+:BITSIZE_counter] < next_awqueue[OFFSET_len+:BITSIZE_len]))
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_awqueue[(i-1)*BITSIZE_awitem+:BITSIZE_awitem] = next_awqueue[i*BITSIZE_awitem+:BITSIZE_awitem];
      end
      next_awqueue_size = next_awqueue_size - 1;
    end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arready <= 0;
      awready <= 0;
      wready <= 0;
      wlast_reg <= 1;
      counter_reg <= 0;
     end
     else
     begin
      arready <= (next_arqueue_size - (next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= next_arqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE);  //Ready if next_queue_size - rlast < QUEUE_SIZE
      awready <= (wlast_next || wlast) && (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); // ready if next_queue_size - bvalid < QUEUE_SIZE
      wready <= (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); 
      wlast_reg <= wlast_next || wlast;
      counter_reg <= counter_next;
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      rvalid <= 0;
      bvalid <= 0;
     end
     else
     begin
      rvalid <= (next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1); // if at posedge_clock delay is 1 I have to perfrom the operation in this cycle
      bvalid <= (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == (next_awqueue[OFFSET_len+:BITSIZE_len])); // if at posedge_clock delay is 1 I have to perfrom the last operation in this cycle
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arqueue <= 0;
      arqueue_size <= 0;
      awqueue <= 0;
      awqueue_size <= 0;
     end
     else
     begin
      arqueue <= next_arqueue;
      arqueue_size <= next_arqueue_size;
      awqueue <= next_awqueue;
      awqueue_size <= next_awqueue_size;
     end
  end
  
  // Sequential logic for read transactions
  always@(posedge clock)
  begin : read_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    rlast <= 0;
    test_addr_read <= 0;
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1)
    begin
      if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr] + (next_arqueue[OFFSET_counter+:BITSIZE_counter] - 1) * (1 << next_arqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_addr_read <= currAddr;
      rid <= next_arqueue[OFFSET_id+:BITSIZE_id];
      rdata <= m_utils.read_a(currAddr);
      if(next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1))
      begin
        rlast <= 1;
      end
    end
  end
  
  // Sequential logic for write transactions
  always@(posedge clock)
  begin: write_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    test_wstrb <=0;
    test_addr <= 0;
    test_data <= 0;
    write_done <= 0;
    if(next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1) // Performs the first write of the queue
    begin
      if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr] + next_awqueue[OFFSET_counter+:BITSIZE_counter] * (1 << next_awqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_wstrb <= next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb];
      test_addr <= currAddr;
      test_data <= next_awqueue[OFFSET_data+:BITSIZE_data];
      bid <= next_awqueue[OFFSET_id+:BITSIZE_id];
      write_done <= 1;
      void'(m_utils.write_strobe(next_awqueue[OFFSET_data+:BITSIZE_data], next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb], currAddr));
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_m_axi_gmem_w0(clock,
  reset,
  done_port,
  m_axi_gmem_w0_awready,
  m_axi_gmem_w0_wready,
  m_axi_gmem_w0_bid,
  m_axi_gmem_w0_bresp,
  m_axi_gmem_w0_buser,
  m_axi_gmem_w0_bvalid,
  m_axi_gmem_w0_arready,
  m_axi_gmem_w0_rid,
  m_axi_gmem_w0_rdata,
  m_axi_gmem_w0_rresp,
  m_axi_gmem_w0_rlast,
  m_axi_gmem_w0_ruser,
  m_axi_gmem_w0_rvalid,
  m_axi_gmem_w0_awid,
  m_axi_gmem_w0_awaddr,
  m_axi_gmem_w0_awlen,
  m_axi_gmem_w0_awsize,
  m_axi_gmem_w0_awburst,
  m_axi_gmem_w0_awlock,
  m_axi_gmem_w0_awcache,
  m_axi_gmem_w0_awprot,
  m_axi_gmem_w0_awqos,
  m_axi_gmem_w0_awregion,
  m_axi_gmem_w0_awuser,
  m_axi_gmem_w0_awvalid,
  m_axi_gmem_w0_wdata,
  m_axi_gmem_w0_wstrb,
  m_axi_gmem_w0_wlast,
  m_axi_gmem_w0_wuser,
  m_axi_gmem_w0_wvalid,
  m_axi_gmem_w0_bready,
  m_axi_gmem_w0_arid,
  m_axi_gmem_w0_araddr,
  m_axi_gmem_w0_arlen,
  m_axi_gmem_w0_arsize,
  m_axi_gmem_w0_arburst,
  m_axi_gmem_w0_arlock,
  m_axi_gmem_w0_arcache,
  m_axi_gmem_w0_arprot,
  m_axi_gmem_w0_arqos,
  m_axi_gmem_w0_arregion,
  m_axi_gmem_w0_aruser,
  m_axi_gmem_w0_arvalid,
  m_axi_gmem_w0_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem_w0_bid=1,
    BITSIZE_m_axi_gmem_w0_bresp=2,
    BITSIZE_m_axi_gmem_w0_buser=1,
    BITSIZE_m_axi_gmem_w0_rid=1,
    BITSIZE_m_axi_gmem_w0_rdata=1,
    BITSIZE_m_axi_gmem_w0_rresp=2,
    BITSIZE_m_axi_gmem_w0_ruser=1,
    BITSIZE_m_axi_gmem_w0_awid=1,
    BITSIZE_m_axi_gmem_w0_awaddr=1,
    BITSIZE_m_axi_gmem_w0_awlen=1,
    BITSIZE_m_axi_gmem_w0_awsize=1,
    BITSIZE_m_axi_gmem_w0_awburst=2,
    BITSIZE_m_axi_gmem_w0_awlock=1,
    BITSIZE_m_axi_gmem_w0_awcache=1,
    BITSIZE_m_axi_gmem_w0_awprot=1,
    BITSIZE_m_axi_gmem_w0_awqos=1,
    BITSIZE_m_axi_gmem_w0_awregion=1,
    BITSIZE_m_axi_gmem_w0_awuser=1,
    BITSIZE_m_axi_gmem_w0_wdata=1,
    BITSIZE_m_axi_gmem_w0_wstrb=1,
    BITSIZE_m_axi_gmem_w0_wuser=1,
    BITSIZE_m_axi_gmem_w0_arid=1,
    BITSIZE_m_axi_gmem_w0_araddr=1,
    BITSIZE_m_axi_gmem_w0_arlen=1,
    BITSIZE_m_axi_gmem_w0_arsize=1,
    BITSIZE_m_axi_gmem_w0_arburst=2,
    BITSIZE_m_axi_gmem_w0_arlock=1,
    BITSIZE_m_axi_gmem_w0_arcache=1,
    BITSIZE_m_axi_gmem_w0_arprot=1,
    BITSIZE_m_axi_gmem_w0_arqos=1,
    BITSIZE_m_axi_gmem_w0_arregion=1,
    BITSIZE_m_axi_gmem_w0_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem_w0_awid-1:0] m_axi_gmem_w0_awid;
  input [BITSIZE_m_axi_gmem_w0_awaddr-1:0] m_axi_gmem_w0_awaddr;
  input [BITSIZE_m_axi_gmem_w0_awlen-1:0] m_axi_gmem_w0_awlen;
  input [BITSIZE_m_axi_gmem_w0_awsize-1:0] m_axi_gmem_w0_awsize;
  input [BITSIZE_m_axi_gmem_w0_awburst-1:0] m_axi_gmem_w0_awburst;
  input [BITSIZE_m_axi_gmem_w0_awlock-1:0] m_axi_gmem_w0_awlock;
  input [BITSIZE_m_axi_gmem_w0_awcache-1:0] m_axi_gmem_w0_awcache;
  input [BITSIZE_m_axi_gmem_w0_awprot-1:0] m_axi_gmem_w0_awprot;
  input [BITSIZE_m_axi_gmem_w0_awqos-1:0] m_axi_gmem_w0_awqos;
  input [BITSIZE_m_axi_gmem_w0_awregion-1:0] m_axi_gmem_w0_awregion;
  input [BITSIZE_m_axi_gmem_w0_awuser-1:0] m_axi_gmem_w0_awuser;
  input m_axi_gmem_w0_awvalid;
  input [BITSIZE_m_axi_gmem_w0_wdata-1:0] m_axi_gmem_w0_wdata;
  input [BITSIZE_m_axi_gmem_w0_wstrb-1:0] m_axi_gmem_w0_wstrb;
  input m_axi_gmem_w0_wlast;
  input [BITSIZE_m_axi_gmem_w0_wuser-1:0] m_axi_gmem_w0_wuser;
  input m_axi_gmem_w0_wvalid;
  input m_axi_gmem_w0_bready;
  input [BITSIZE_m_axi_gmem_w0_arid-1:0] m_axi_gmem_w0_arid;
  input [BITSIZE_m_axi_gmem_w0_araddr-1:0] m_axi_gmem_w0_araddr;
  input [BITSIZE_m_axi_gmem_w0_arlen-1:0] m_axi_gmem_w0_arlen;
  input [BITSIZE_m_axi_gmem_w0_arsize-1:0] m_axi_gmem_w0_arsize;
  input [BITSIZE_m_axi_gmem_w0_arburst-1:0] m_axi_gmem_w0_arburst;
  input [BITSIZE_m_axi_gmem_w0_arlock-1:0] m_axi_gmem_w0_arlock;
  input [BITSIZE_m_axi_gmem_w0_arcache-1:0] m_axi_gmem_w0_arcache;
  input [BITSIZE_m_axi_gmem_w0_arprot-1:0] m_axi_gmem_w0_arprot;
  input [BITSIZE_m_axi_gmem_w0_arqos-1:0] m_axi_gmem_w0_arqos;
  input [BITSIZE_m_axi_gmem_w0_arregion-1:0] m_axi_gmem_w0_arregion;
  input [BITSIZE_m_axi_gmem_w0_aruser-1:0] m_axi_gmem_w0_aruser;
  input m_axi_gmem_w0_arvalid;
  input m_axi_gmem_w0_rready;
  // OUT
  output m_axi_gmem_w0_awready;
  output m_axi_gmem_w0_wready;
  output [BITSIZE_m_axi_gmem_w0_bid-1:0] m_axi_gmem_w0_bid;
  output [BITSIZE_m_axi_gmem_w0_bresp-1:0] m_axi_gmem_w0_bresp;
  output [BITSIZE_m_axi_gmem_w0_buser-1:0] m_axi_gmem_w0_buser;
  output m_axi_gmem_w0_bvalid;
  output m_axi_gmem_w0_arready;
  output [BITSIZE_m_axi_gmem_w0_rid-1:0] m_axi_gmem_w0_rid;
  output [BITSIZE_m_axi_gmem_w0_rdata-1:0] m_axi_gmem_w0_rdata;
  output [BITSIZE_m_axi_gmem_w0_rresp-1:0] m_axi_gmem_w0_rresp;
  output m_axi_gmem_w0_rlast;
  output [BITSIZE_m_axi_gmem_w0_ruser-1:0] m_axi_gmem_w0_ruser;
  output m_axi_gmem_w0_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem_w0_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem_w0_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem_w0_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem_w0_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem_w0_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem_w0_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem_w0_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem_w0_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem_w0_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem_w0_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem_w0_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem_w0_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem_w0_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem_w0_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem_w0_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem_w0_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem_w0_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem_w0_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem_w0_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem_w0_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem_w0_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem_w0_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem_w0_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem_w0_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem_w0_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem_w0_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem_w0_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem_w0_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem_w0_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem_w0_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem_w0_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem_w0_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem_w0_awready=awready;
  assign m_axi_gmem_w0_wready=wready;
  assign m_axi_gmem_w0_bid=bid;
  assign m_axi_gmem_w0_bresp=bresp;
  assign m_axi_gmem_w0_buser=buser;
  assign m_axi_gmem_w0_bvalid=bvalid;
  assign m_axi_gmem_w0_arready=arready;
  assign m_axi_gmem_w0_rid=rid;
  assign m_axi_gmem_w0_rdata=rdata;
  assign m_axi_gmem_w0_rresp=rresp;
  assign m_axi_gmem_w0_rlast=rlast;
  assign m_axi_gmem_w0_ruser=ruser;
  assign m_axi_gmem_w0_rvalid=rvalid;
  assign awid=m_axi_gmem_w0_awid;
  assign awaddr=m_axi_gmem_w0_awaddr;
  assign awlen=m_axi_gmem_w0_awlen;
  assign awsize=m_axi_gmem_w0_awsize;
  assign awburst=m_axi_gmem_w0_awburst;
  assign awlock=m_axi_gmem_w0_awlock;
  assign awcache=m_axi_gmem_w0_awcache;
  assign awprot=m_axi_gmem_w0_awprot;
  assign awqos=m_axi_gmem_w0_awqos;
  assign awregion=m_axi_gmem_w0_awregion;
  assign awuser=m_axi_gmem_w0_awuser;
  assign awvalid=m_axi_gmem_w0_awvalid;
  assign wdata=m_axi_gmem_w0_wdata;
  assign wstrb=m_axi_gmem_w0_wstrb;
  assign wlast=m_axi_gmem_w0_wlast;
  assign wuser=m_axi_gmem_w0_wuser;
  assign wvalid=m_axi_gmem_w0_wvalid;
  assign bready=m_axi_gmem_w0_bready;
  assign arid=m_axi_gmem_w0_arid;
  assign araddr=m_axi_gmem_w0_araddr;
  assign arlen=m_axi_gmem_w0_arlen;
  assign arsize=m_axi_gmem_w0_arsize;
  assign arburst=m_axi_gmem_w0_arburst;
  assign arlock=m_axi_gmem_w0_arlock;
  assign arcache=m_axi_gmem_w0_arcache;
  assign arprot=m_axi_gmem_w0_arprot;
  assign arqos=m_axi_gmem_w0_arqos;
  assign arregion=m_axi_gmem_w0_arregion;
  assign aruser=m_axi_gmem_w0_aruser;
  assign arvalid=m_axi_gmem_w0_arvalid;
  assign rready=m_axi_gmem_w0_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem_w0_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem_w0_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem_w0_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem_w0_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem_w0_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem_w0_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem_w0_arid,
    OFFSET_delay=0,
    OFFSET_counter=OFFSET_delay+BITSIZE_delay,
    OFFSET_burst=OFFSET_counter+BITSIZE_counter,
    OFFSET_len=OFFSET_burst+BITSIZE_burst,
    OFFSET_size=OFFSET_len+BITSIZE_len,
    OFFSET_addr=OFFSET_size+BITSIZE_size,
    OFFSET_id=OFFSET_addr+BITSIZE_addr,
    OFFSET_data=OFFSET_id+BITSIZE_id,
    OFFSET_wstrb=OFFSET_data+BITSIZE_data,
    BITSIZE_aritem=BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay,
    BITSIZE_awitem=BITSIZE_wstrb+BITSIZE_data+BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay;
  
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] arqueue;
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] next_arqueue;
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] awqueue; 
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] next_awqueue;
  reg [31:0] test_addr;
  reg [31:0] test_wstrb;
  reg [31:0] test_data;
  reg [31:0] test_addr_read;
  integer arqueue_size, next_arqueue_size;
  integer awqueue_size, next_awqueue_size;
  
  reg [BITSIZE_id-1:0] awid_reg;
  reg [BITSIZE_addr-1:0] awaddr_reg;
  reg [BITSIZE_size-1:0] awsize_reg;
  reg [BITSIZE_len-1:0] awlen_reg; 
  reg [BITSIZE_burst-1:0] awburst_reg;
  reg [BITSIZE_counter-1:0] counter_reg, counter_next;
  reg write_done;
  reg wlast_reg, wlast_next;
  
  if_utils #(index, BITSIZE_data) m_utils();
  
  initial
  begin
    arqueue = 0;
    arqueue_size = 0;
    next_arqueue = 0;
    next_arqueue_size = 0;
    awqueue = 0;
    awqueue_size = 0;
    next_awqueue = 0;
    next_awqueue_size = 0;
    awready = 0;
    wready = 0;
    bid = 0;
    bresp = 0;
    buser = 0;
    bvalid = 0;
    arready = 0;
    rid = 0;
    rdata = 0;
    rresp = 0;
    rlast = 0;
    ruser = 0;
    rvalid = 0;
    awid_reg = 0;
    awaddr_reg = 0;
    awsize_reg = 0;
    awlen_reg = 0;
    awburst_reg = 0;
  end
  
  // Combinatorial logic for read transactions
  always@(*)
  begin: read_comb
    automatic integer unsigned i;
    next_arqueue = arqueue;
    next_arqueue_size = arqueue_size;
    if(arvalid && arready)  // Valid and ready -> accept new transaction
    begin
      next_arqueue[arqueue_size*BITSIZE_aritem +:BITSIZE_aritem] = {arid, araddr, arsize, arlen, arburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + READ_DELAY)}; // size of parameter is implementation dependent
      next_arqueue_size = arqueue_size + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] = arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1) && rready && rvalid)
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_arqueue[(i-1)*BITSIZE_aritem+:BITSIZE_aritem] = next_arqueue[i*BITSIZE_aritem+:BITSIZE_aritem];
      end
      next_arqueue_size = next_arqueue_size - 1;
    end
    if(next_arqueue_size > 0 && (next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1) && (next_arqueue[OFFSET_counter+:BITSIZE_counter] < (next_arqueue[OFFSET_len+:BITSIZE_len] + 1)))
    begin
      next_arqueue[OFFSET_counter+:BITSIZE_counter] = next_arqueue[OFFSET_counter+:BITSIZE_counter] + 1;
    end
  end
  
  // Combinatorial logic for write transactions
  always@(*) 
  begin: write_comb
    automatic integer i;
    automatic reg [BITSIZE_counter-1:0] counter;
    next_awqueue = awqueue;
    next_awqueue_size = awqueue_size;
    wlast_next = wlast_reg;
    if(awvalid && awready && wready && wvalid) // Valid and ready -> accept new transaction and save data
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid, awaddr, awsize, awlen, awburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
    end
    else if(awvalid && awready && wlast_reg)
    begin
      awid_reg = awid;
      awaddr_reg = awaddr;
      awsize_reg = awsize;
      awlen_reg = awlen; 
      awburst_reg = awburst;
      counter_next = 0;
      wlast_next = 0;
    end
    else if(wready && wvalid)
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid_reg, awaddr_reg, awsize_reg, awlen_reg, awburst_reg, counter_reg, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
      counter_next = counter_reg + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] = awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(write_done && next_awqueue_size > 0 && ((next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len] && bready) || next_awqueue[OFFSET_counter+:BITSIZE_counter] < next_awqueue[OFFSET_len+:BITSIZE_len]))
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_awqueue[(i-1)*BITSIZE_awitem+:BITSIZE_awitem] = next_awqueue[i*BITSIZE_awitem+:BITSIZE_awitem];
      end
      next_awqueue_size = next_awqueue_size - 1;
    end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arready <= 0;
      awready <= 0;
      wready <= 0;
      wlast_reg <= 1;
      counter_reg <= 0;
     end
     else
     begin
      arready <= (next_arqueue_size - (next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= next_arqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE);  //Ready if next_queue_size - rlast < QUEUE_SIZE
      awready <= (wlast_next || wlast) && (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); // ready if next_queue_size - bvalid < QUEUE_SIZE
      wready <= (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); 
      wlast_reg <= wlast_next || wlast;
      counter_reg <= counter_next;
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      rvalid <= 0;
      bvalid <= 0;
     end
     else
     begin
      rvalid <= (next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1); // if at posedge_clock delay is 1 I have to perfrom the operation in this cycle
      bvalid <= (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == (next_awqueue[OFFSET_len+:BITSIZE_len])); // if at posedge_clock delay is 1 I have to perfrom the last operation in this cycle
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arqueue <= 0;
      arqueue_size <= 0;
      awqueue <= 0;
      awqueue_size <= 0;
     end
     else
     begin
      arqueue <= next_arqueue;
      arqueue_size <= next_arqueue_size;
      awqueue <= next_awqueue;
      awqueue_size <= next_awqueue_size;
     end
  end
  
  // Sequential logic for read transactions
  always@(posedge clock)
  begin : read_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    rlast <= 0;
    test_addr_read <= 0;
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1)
    begin
      if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr] + (next_arqueue[OFFSET_counter+:BITSIZE_counter] - 1) * (1 << next_arqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_addr_read <= currAddr;
      rid <= next_arqueue[OFFSET_id+:BITSIZE_id];
      rdata <= m_utils.read_a(currAddr);
      if(next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1))
      begin
        rlast <= 1;
      end
    end
  end
  
  // Sequential logic for write transactions
  always@(posedge clock)
  begin: write_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    test_wstrb <=0;
    test_addr <= 0;
    test_data <= 0;
    write_done <= 0;
    if(next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1) // Performs the first write of the queue
    begin
      if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr] + next_awqueue[OFFSET_counter+:BITSIZE_counter] * (1 << next_awqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_wstrb <= next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb];
      test_addr <= currAddr;
      test_data <= next_awqueue[OFFSET_data+:BITSIZE_data];
      bid <= next_awqueue[OFFSET_id+:BITSIZE_id];
      write_done <= 1;
      void'(m_utils.write_strobe(next_awqueue[OFFSET_data+:BITSIZE_data], next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb], currAddr));
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_m_axi_gmem_w1(clock,
  reset,
  done_port,
  m_axi_gmem_w1_awready,
  m_axi_gmem_w1_wready,
  m_axi_gmem_w1_bid,
  m_axi_gmem_w1_bresp,
  m_axi_gmem_w1_buser,
  m_axi_gmem_w1_bvalid,
  m_axi_gmem_w1_arready,
  m_axi_gmem_w1_rid,
  m_axi_gmem_w1_rdata,
  m_axi_gmem_w1_rresp,
  m_axi_gmem_w1_rlast,
  m_axi_gmem_w1_ruser,
  m_axi_gmem_w1_rvalid,
  m_axi_gmem_w1_awid,
  m_axi_gmem_w1_awaddr,
  m_axi_gmem_w1_awlen,
  m_axi_gmem_w1_awsize,
  m_axi_gmem_w1_awburst,
  m_axi_gmem_w1_awlock,
  m_axi_gmem_w1_awcache,
  m_axi_gmem_w1_awprot,
  m_axi_gmem_w1_awqos,
  m_axi_gmem_w1_awregion,
  m_axi_gmem_w1_awuser,
  m_axi_gmem_w1_awvalid,
  m_axi_gmem_w1_wdata,
  m_axi_gmem_w1_wstrb,
  m_axi_gmem_w1_wlast,
  m_axi_gmem_w1_wuser,
  m_axi_gmem_w1_wvalid,
  m_axi_gmem_w1_bready,
  m_axi_gmem_w1_arid,
  m_axi_gmem_w1_araddr,
  m_axi_gmem_w1_arlen,
  m_axi_gmem_w1_arsize,
  m_axi_gmem_w1_arburst,
  m_axi_gmem_w1_arlock,
  m_axi_gmem_w1_arcache,
  m_axi_gmem_w1_arprot,
  m_axi_gmem_w1_arqos,
  m_axi_gmem_w1_arregion,
  m_axi_gmem_w1_aruser,
  m_axi_gmem_w1_arvalid,
  m_axi_gmem_w1_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem_w1_bid=1,
    BITSIZE_m_axi_gmem_w1_bresp=2,
    BITSIZE_m_axi_gmem_w1_buser=1,
    BITSIZE_m_axi_gmem_w1_rid=1,
    BITSIZE_m_axi_gmem_w1_rdata=1,
    BITSIZE_m_axi_gmem_w1_rresp=2,
    BITSIZE_m_axi_gmem_w1_ruser=1,
    BITSIZE_m_axi_gmem_w1_awid=1,
    BITSIZE_m_axi_gmem_w1_awaddr=1,
    BITSIZE_m_axi_gmem_w1_awlen=1,
    BITSIZE_m_axi_gmem_w1_awsize=1,
    BITSIZE_m_axi_gmem_w1_awburst=2,
    BITSIZE_m_axi_gmem_w1_awlock=1,
    BITSIZE_m_axi_gmem_w1_awcache=1,
    BITSIZE_m_axi_gmem_w1_awprot=1,
    BITSIZE_m_axi_gmem_w1_awqos=1,
    BITSIZE_m_axi_gmem_w1_awregion=1,
    BITSIZE_m_axi_gmem_w1_awuser=1,
    BITSIZE_m_axi_gmem_w1_wdata=1,
    BITSIZE_m_axi_gmem_w1_wstrb=1,
    BITSIZE_m_axi_gmem_w1_wuser=1,
    BITSIZE_m_axi_gmem_w1_arid=1,
    BITSIZE_m_axi_gmem_w1_araddr=1,
    BITSIZE_m_axi_gmem_w1_arlen=1,
    BITSIZE_m_axi_gmem_w1_arsize=1,
    BITSIZE_m_axi_gmem_w1_arburst=2,
    BITSIZE_m_axi_gmem_w1_arlock=1,
    BITSIZE_m_axi_gmem_w1_arcache=1,
    BITSIZE_m_axi_gmem_w1_arprot=1,
    BITSIZE_m_axi_gmem_w1_arqos=1,
    BITSIZE_m_axi_gmem_w1_arregion=1,
    BITSIZE_m_axi_gmem_w1_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem_w1_awid-1:0] m_axi_gmem_w1_awid;
  input [BITSIZE_m_axi_gmem_w1_awaddr-1:0] m_axi_gmem_w1_awaddr;
  input [BITSIZE_m_axi_gmem_w1_awlen-1:0] m_axi_gmem_w1_awlen;
  input [BITSIZE_m_axi_gmem_w1_awsize-1:0] m_axi_gmem_w1_awsize;
  input [BITSIZE_m_axi_gmem_w1_awburst-1:0] m_axi_gmem_w1_awburst;
  input [BITSIZE_m_axi_gmem_w1_awlock-1:0] m_axi_gmem_w1_awlock;
  input [BITSIZE_m_axi_gmem_w1_awcache-1:0] m_axi_gmem_w1_awcache;
  input [BITSIZE_m_axi_gmem_w1_awprot-1:0] m_axi_gmem_w1_awprot;
  input [BITSIZE_m_axi_gmem_w1_awqos-1:0] m_axi_gmem_w1_awqos;
  input [BITSIZE_m_axi_gmem_w1_awregion-1:0] m_axi_gmem_w1_awregion;
  input [BITSIZE_m_axi_gmem_w1_awuser-1:0] m_axi_gmem_w1_awuser;
  input m_axi_gmem_w1_awvalid;
  input [BITSIZE_m_axi_gmem_w1_wdata-1:0] m_axi_gmem_w1_wdata;
  input [BITSIZE_m_axi_gmem_w1_wstrb-1:0] m_axi_gmem_w1_wstrb;
  input m_axi_gmem_w1_wlast;
  input [BITSIZE_m_axi_gmem_w1_wuser-1:0] m_axi_gmem_w1_wuser;
  input m_axi_gmem_w1_wvalid;
  input m_axi_gmem_w1_bready;
  input [BITSIZE_m_axi_gmem_w1_arid-1:0] m_axi_gmem_w1_arid;
  input [BITSIZE_m_axi_gmem_w1_araddr-1:0] m_axi_gmem_w1_araddr;
  input [BITSIZE_m_axi_gmem_w1_arlen-1:0] m_axi_gmem_w1_arlen;
  input [BITSIZE_m_axi_gmem_w1_arsize-1:0] m_axi_gmem_w1_arsize;
  input [BITSIZE_m_axi_gmem_w1_arburst-1:0] m_axi_gmem_w1_arburst;
  input [BITSIZE_m_axi_gmem_w1_arlock-1:0] m_axi_gmem_w1_arlock;
  input [BITSIZE_m_axi_gmem_w1_arcache-1:0] m_axi_gmem_w1_arcache;
  input [BITSIZE_m_axi_gmem_w1_arprot-1:0] m_axi_gmem_w1_arprot;
  input [BITSIZE_m_axi_gmem_w1_arqos-1:0] m_axi_gmem_w1_arqos;
  input [BITSIZE_m_axi_gmem_w1_arregion-1:0] m_axi_gmem_w1_arregion;
  input [BITSIZE_m_axi_gmem_w1_aruser-1:0] m_axi_gmem_w1_aruser;
  input m_axi_gmem_w1_arvalid;
  input m_axi_gmem_w1_rready;
  // OUT
  output m_axi_gmem_w1_awready;
  output m_axi_gmem_w1_wready;
  output [BITSIZE_m_axi_gmem_w1_bid-1:0] m_axi_gmem_w1_bid;
  output [BITSIZE_m_axi_gmem_w1_bresp-1:0] m_axi_gmem_w1_bresp;
  output [BITSIZE_m_axi_gmem_w1_buser-1:0] m_axi_gmem_w1_buser;
  output m_axi_gmem_w1_bvalid;
  output m_axi_gmem_w1_arready;
  output [BITSIZE_m_axi_gmem_w1_rid-1:0] m_axi_gmem_w1_rid;
  output [BITSIZE_m_axi_gmem_w1_rdata-1:0] m_axi_gmem_w1_rdata;
  output [BITSIZE_m_axi_gmem_w1_rresp-1:0] m_axi_gmem_w1_rresp;
  output m_axi_gmem_w1_rlast;
  output [BITSIZE_m_axi_gmem_w1_ruser-1:0] m_axi_gmem_w1_ruser;
  output m_axi_gmem_w1_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem_w1_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem_w1_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem_w1_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem_w1_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem_w1_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem_w1_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem_w1_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem_w1_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem_w1_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem_w1_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem_w1_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem_w1_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem_w1_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem_w1_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem_w1_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem_w1_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem_w1_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem_w1_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem_w1_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem_w1_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem_w1_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem_w1_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem_w1_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem_w1_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem_w1_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem_w1_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem_w1_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem_w1_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem_w1_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem_w1_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem_w1_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem_w1_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem_w1_awready=awready;
  assign m_axi_gmem_w1_wready=wready;
  assign m_axi_gmem_w1_bid=bid;
  assign m_axi_gmem_w1_bresp=bresp;
  assign m_axi_gmem_w1_buser=buser;
  assign m_axi_gmem_w1_bvalid=bvalid;
  assign m_axi_gmem_w1_arready=arready;
  assign m_axi_gmem_w1_rid=rid;
  assign m_axi_gmem_w1_rdata=rdata;
  assign m_axi_gmem_w1_rresp=rresp;
  assign m_axi_gmem_w1_rlast=rlast;
  assign m_axi_gmem_w1_ruser=ruser;
  assign m_axi_gmem_w1_rvalid=rvalid;
  assign awid=m_axi_gmem_w1_awid;
  assign awaddr=m_axi_gmem_w1_awaddr;
  assign awlen=m_axi_gmem_w1_awlen;
  assign awsize=m_axi_gmem_w1_awsize;
  assign awburst=m_axi_gmem_w1_awburst;
  assign awlock=m_axi_gmem_w1_awlock;
  assign awcache=m_axi_gmem_w1_awcache;
  assign awprot=m_axi_gmem_w1_awprot;
  assign awqos=m_axi_gmem_w1_awqos;
  assign awregion=m_axi_gmem_w1_awregion;
  assign awuser=m_axi_gmem_w1_awuser;
  assign awvalid=m_axi_gmem_w1_awvalid;
  assign wdata=m_axi_gmem_w1_wdata;
  assign wstrb=m_axi_gmem_w1_wstrb;
  assign wlast=m_axi_gmem_w1_wlast;
  assign wuser=m_axi_gmem_w1_wuser;
  assign wvalid=m_axi_gmem_w1_wvalid;
  assign bready=m_axi_gmem_w1_bready;
  assign arid=m_axi_gmem_w1_arid;
  assign araddr=m_axi_gmem_w1_araddr;
  assign arlen=m_axi_gmem_w1_arlen;
  assign arsize=m_axi_gmem_w1_arsize;
  assign arburst=m_axi_gmem_w1_arburst;
  assign arlock=m_axi_gmem_w1_arlock;
  assign arcache=m_axi_gmem_w1_arcache;
  assign arprot=m_axi_gmem_w1_arprot;
  assign arqos=m_axi_gmem_w1_arqos;
  assign arregion=m_axi_gmem_w1_arregion;
  assign aruser=m_axi_gmem_w1_aruser;
  assign arvalid=m_axi_gmem_w1_arvalid;
  assign rready=m_axi_gmem_w1_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem_w1_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem_w1_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem_w1_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem_w1_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem_w1_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem_w1_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem_w1_arid,
    OFFSET_delay=0,
    OFFSET_counter=OFFSET_delay+BITSIZE_delay,
    OFFSET_burst=OFFSET_counter+BITSIZE_counter,
    OFFSET_len=OFFSET_burst+BITSIZE_burst,
    OFFSET_size=OFFSET_len+BITSIZE_len,
    OFFSET_addr=OFFSET_size+BITSIZE_size,
    OFFSET_id=OFFSET_addr+BITSIZE_addr,
    OFFSET_data=OFFSET_id+BITSIZE_id,
    OFFSET_wstrb=OFFSET_data+BITSIZE_data,
    BITSIZE_aritem=BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay,
    BITSIZE_awitem=BITSIZE_wstrb+BITSIZE_data+BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay;
  
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] arqueue;
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] next_arqueue;
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] awqueue; 
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] next_awqueue;
  reg [31:0] test_addr;
  reg [31:0] test_wstrb;
  reg [31:0] test_data;
  reg [31:0] test_addr_read;
  integer arqueue_size, next_arqueue_size;
  integer awqueue_size, next_awqueue_size;
  
  reg [BITSIZE_id-1:0] awid_reg;
  reg [BITSIZE_addr-1:0] awaddr_reg;
  reg [BITSIZE_size-1:0] awsize_reg;
  reg [BITSIZE_len-1:0] awlen_reg; 
  reg [BITSIZE_burst-1:0] awburst_reg;
  reg [BITSIZE_counter-1:0] counter_reg, counter_next;
  reg write_done;
  reg wlast_reg, wlast_next;
  
  if_utils #(index, BITSIZE_data) m_utils();
  
  initial
  begin
    arqueue = 0;
    arqueue_size = 0;
    next_arqueue = 0;
    next_arqueue_size = 0;
    awqueue = 0;
    awqueue_size = 0;
    next_awqueue = 0;
    next_awqueue_size = 0;
    awready = 0;
    wready = 0;
    bid = 0;
    bresp = 0;
    buser = 0;
    bvalid = 0;
    arready = 0;
    rid = 0;
    rdata = 0;
    rresp = 0;
    rlast = 0;
    ruser = 0;
    rvalid = 0;
    awid_reg = 0;
    awaddr_reg = 0;
    awsize_reg = 0;
    awlen_reg = 0;
    awburst_reg = 0;
  end
  
  // Combinatorial logic for read transactions
  always@(*)
  begin: read_comb
    automatic integer unsigned i;
    next_arqueue = arqueue;
    next_arqueue_size = arqueue_size;
    if(arvalid && arready)  // Valid and ready -> accept new transaction
    begin
      next_arqueue[arqueue_size*BITSIZE_aritem +:BITSIZE_aritem] = {arid, araddr, arsize, arlen, arburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + READ_DELAY)}; // size of parameter is implementation dependent
      next_arqueue_size = arqueue_size + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] = arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1) && rready && rvalid)
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_arqueue[(i-1)*BITSIZE_aritem+:BITSIZE_aritem] = next_arqueue[i*BITSIZE_aritem+:BITSIZE_aritem];
      end
      next_arqueue_size = next_arqueue_size - 1;
    end
    if(next_arqueue_size > 0 && (next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1) && (next_arqueue[OFFSET_counter+:BITSIZE_counter] < (next_arqueue[OFFSET_len+:BITSIZE_len] + 1)))
    begin
      next_arqueue[OFFSET_counter+:BITSIZE_counter] = next_arqueue[OFFSET_counter+:BITSIZE_counter] + 1;
    end
  end
  
  // Combinatorial logic for write transactions
  always@(*) 
  begin: write_comb
    automatic integer i;
    automatic reg [BITSIZE_counter-1:0] counter;
    next_awqueue = awqueue;
    next_awqueue_size = awqueue_size;
    wlast_next = wlast_reg;
    if(awvalid && awready && wready && wvalid) // Valid and ready -> accept new transaction and save data
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid, awaddr, awsize, awlen, awburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
    end
    else if(awvalid && awready && wlast_reg)
    begin
      awid_reg = awid;
      awaddr_reg = awaddr;
      awsize_reg = awsize;
      awlen_reg = awlen; 
      awburst_reg = awburst;
      counter_next = 0;
      wlast_next = 0;
    end
    else if(wready && wvalid)
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid_reg, awaddr_reg, awsize_reg, awlen_reg, awburst_reg, counter_reg, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
      counter_next = counter_reg + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] = awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(write_done && next_awqueue_size > 0 && ((next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len] && bready) || next_awqueue[OFFSET_counter+:BITSIZE_counter] < next_awqueue[OFFSET_len+:BITSIZE_len]))
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_awqueue[(i-1)*BITSIZE_awitem+:BITSIZE_awitem] = next_awqueue[i*BITSIZE_awitem+:BITSIZE_awitem];
      end
      next_awqueue_size = next_awqueue_size - 1;
    end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arready <= 0;
      awready <= 0;
      wready <= 0;
      wlast_reg <= 1;
      counter_reg <= 0;
     end
     else
     begin
      arready <= (next_arqueue_size - (next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= next_arqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE);  //Ready if next_queue_size - rlast < QUEUE_SIZE
      awready <= (wlast_next || wlast) && (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); // ready if next_queue_size - bvalid < QUEUE_SIZE
      wready <= (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); 
      wlast_reg <= wlast_next || wlast;
      counter_reg <= counter_next;
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      rvalid <= 0;
      bvalid <= 0;
     end
     else
     begin
      rvalid <= (next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1); // if at posedge_clock delay is 1 I have to perfrom the operation in this cycle
      bvalid <= (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == (next_awqueue[OFFSET_len+:BITSIZE_len])); // if at posedge_clock delay is 1 I have to perfrom the last operation in this cycle
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arqueue <= 0;
      arqueue_size <= 0;
      awqueue <= 0;
      awqueue_size <= 0;
     end
     else
     begin
      arqueue <= next_arqueue;
      arqueue_size <= next_arqueue_size;
      awqueue <= next_awqueue;
      awqueue_size <= next_awqueue_size;
     end
  end
  
  // Sequential logic for read transactions
  always@(posedge clock)
  begin : read_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    rlast <= 0;
    test_addr_read <= 0;
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1)
    begin
      if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr] + (next_arqueue[OFFSET_counter+:BITSIZE_counter] - 1) * (1 << next_arqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_addr_read <= currAddr;
      rid <= next_arqueue[OFFSET_id+:BITSIZE_id];
      rdata <= m_utils.read_a(currAddr);
      if(next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1))
      begin
        rlast <= 1;
      end
    end
  end
  
  // Sequential logic for write transactions
  always@(posedge clock)
  begin: write_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    test_wstrb <=0;
    test_addr <= 0;
    test_data <= 0;
    write_done <= 0;
    if(next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1) // Performs the first write of the queue
    begin
      if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr] + next_awqueue[OFFSET_counter+:BITSIZE_counter] * (1 << next_awqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_wstrb <= next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb];
      test_addr <= currAddr;
      test_data <= next_awqueue[OFFSET_data+:BITSIZE_data];
      bid <= next_awqueue[OFFSET_id+:BITSIZE_id];
      write_done <= 1;
      void'(m_utils.write_strobe(next_awqueue[OFFSET_data+:BITSIZE_data], next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb], currAddr));
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_m_axi_gmem_out0(clock,
  reset,
  done_port,
  m_axi_gmem_out0_awready,
  m_axi_gmem_out0_wready,
  m_axi_gmem_out0_bid,
  m_axi_gmem_out0_bresp,
  m_axi_gmem_out0_buser,
  m_axi_gmem_out0_bvalid,
  m_axi_gmem_out0_arready,
  m_axi_gmem_out0_rid,
  m_axi_gmem_out0_rdata,
  m_axi_gmem_out0_rresp,
  m_axi_gmem_out0_rlast,
  m_axi_gmem_out0_ruser,
  m_axi_gmem_out0_rvalid,
  m_axi_gmem_out0_awid,
  m_axi_gmem_out0_awaddr,
  m_axi_gmem_out0_awlen,
  m_axi_gmem_out0_awsize,
  m_axi_gmem_out0_awburst,
  m_axi_gmem_out0_awlock,
  m_axi_gmem_out0_awcache,
  m_axi_gmem_out0_awprot,
  m_axi_gmem_out0_awqos,
  m_axi_gmem_out0_awregion,
  m_axi_gmem_out0_awuser,
  m_axi_gmem_out0_awvalid,
  m_axi_gmem_out0_wdata,
  m_axi_gmem_out0_wstrb,
  m_axi_gmem_out0_wlast,
  m_axi_gmem_out0_wuser,
  m_axi_gmem_out0_wvalid,
  m_axi_gmem_out0_bready,
  m_axi_gmem_out0_arid,
  m_axi_gmem_out0_araddr,
  m_axi_gmem_out0_arlen,
  m_axi_gmem_out0_arsize,
  m_axi_gmem_out0_arburst,
  m_axi_gmem_out0_arlock,
  m_axi_gmem_out0_arcache,
  m_axi_gmem_out0_arprot,
  m_axi_gmem_out0_arqos,
  m_axi_gmem_out0_arregion,
  m_axi_gmem_out0_aruser,
  m_axi_gmem_out0_arvalid,
  m_axi_gmem_out0_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem_out0_bid=1,
    BITSIZE_m_axi_gmem_out0_bresp=2,
    BITSIZE_m_axi_gmem_out0_buser=1,
    BITSIZE_m_axi_gmem_out0_rid=1,
    BITSIZE_m_axi_gmem_out0_rdata=1,
    BITSIZE_m_axi_gmem_out0_rresp=2,
    BITSIZE_m_axi_gmem_out0_ruser=1,
    BITSIZE_m_axi_gmem_out0_awid=1,
    BITSIZE_m_axi_gmem_out0_awaddr=1,
    BITSIZE_m_axi_gmem_out0_awlen=1,
    BITSIZE_m_axi_gmem_out0_awsize=1,
    BITSIZE_m_axi_gmem_out0_awburst=2,
    BITSIZE_m_axi_gmem_out0_awlock=1,
    BITSIZE_m_axi_gmem_out0_awcache=1,
    BITSIZE_m_axi_gmem_out0_awprot=1,
    BITSIZE_m_axi_gmem_out0_awqos=1,
    BITSIZE_m_axi_gmem_out0_awregion=1,
    BITSIZE_m_axi_gmem_out0_awuser=1,
    BITSIZE_m_axi_gmem_out0_wdata=1,
    BITSIZE_m_axi_gmem_out0_wstrb=1,
    BITSIZE_m_axi_gmem_out0_wuser=1,
    BITSIZE_m_axi_gmem_out0_arid=1,
    BITSIZE_m_axi_gmem_out0_araddr=1,
    BITSIZE_m_axi_gmem_out0_arlen=1,
    BITSIZE_m_axi_gmem_out0_arsize=1,
    BITSIZE_m_axi_gmem_out0_arburst=2,
    BITSIZE_m_axi_gmem_out0_arlock=1,
    BITSIZE_m_axi_gmem_out0_arcache=1,
    BITSIZE_m_axi_gmem_out0_arprot=1,
    BITSIZE_m_axi_gmem_out0_arqos=1,
    BITSIZE_m_axi_gmem_out0_arregion=1,
    BITSIZE_m_axi_gmem_out0_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem_out0_awid-1:0] m_axi_gmem_out0_awid;
  input [BITSIZE_m_axi_gmem_out0_awaddr-1:0] m_axi_gmem_out0_awaddr;
  input [BITSIZE_m_axi_gmem_out0_awlen-1:0] m_axi_gmem_out0_awlen;
  input [BITSIZE_m_axi_gmem_out0_awsize-1:0] m_axi_gmem_out0_awsize;
  input [BITSIZE_m_axi_gmem_out0_awburst-1:0] m_axi_gmem_out0_awburst;
  input [BITSIZE_m_axi_gmem_out0_awlock-1:0] m_axi_gmem_out0_awlock;
  input [BITSIZE_m_axi_gmem_out0_awcache-1:0] m_axi_gmem_out0_awcache;
  input [BITSIZE_m_axi_gmem_out0_awprot-1:0] m_axi_gmem_out0_awprot;
  input [BITSIZE_m_axi_gmem_out0_awqos-1:0] m_axi_gmem_out0_awqos;
  input [BITSIZE_m_axi_gmem_out0_awregion-1:0] m_axi_gmem_out0_awregion;
  input [BITSIZE_m_axi_gmem_out0_awuser-1:0] m_axi_gmem_out0_awuser;
  input m_axi_gmem_out0_awvalid;
  input [BITSIZE_m_axi_gmem_out0_wdata-1:0] m_axi_gmem_out0_wdata;
  input [BITSIZE_m_axi_gmem_out0_wstrb-1:0] m_axi_gmem_out0_wstrb;
  input m_axi_gmem_out0_wlast;
  input [BITSIZE_m_axi_gmem_out0_wuser-1:0] m_axi_gmem_out0_wuser;
  input m_axi_gmem_out0_wvalid;
  input m_axi_gmem_out0_bready;
  input [BITSIZE_m_axi_gmem_out0_arid-1:0] m_axi_gmem_out0_arid;
  input [BITSIZE_m_axi_gmem_out0_araddr-1:0] m_axi_gmem_out0_araddr;
  input [BITSIZE_m_axi_gmem_out0_arlen-1:0] m_axi_gmem_out0_arlen;
  input [BITSIZE_m_axi_gmem_out0_arsize-1:0] m_axi_gmem_out0_arsize;
  input [BITSIZE_m_axi_gmem_out0_arburst-1:0] m_axi_gmem_out0_arburst;
  input [BITSIZE_m_axi_gmem_out0_arlock-1:0] m_axi_gmem_out0_arlock;
  input [BITSIZE_m_axi_gmem_out0_arcache-1:0] m_axi_gmem_out0_arcache;
  input [BITSIZE_m_axi_gmem_out0_arprot-1:0] m_axi_gmem_out0_arprot;
  input [BITSIZE_m_axi_gmem_out0_arqos-1:0] m_axi_gmem_out0_arqos;
  input [BITSIZE_m_axi_gmem_out0_arregion-1:0] m_axi_gmem_out0_arregion;
  input [BITSIZE_m_axi_gmem_out0_aruser-1:0] m_axi_gmem_out0_aruser;
  input m_axi_gmem_out0_arvalid;
  input m_axi_gmem_out0_rready;
  // OUT
  output m_axi_gmem_out0_awready;
  output m_axi_gmem_out0_wready;
  output [BITSIZE_m_axi_gmem_out0_bid-1:0] m_axi_gmem_out0_bid;
  output [BITSIZE_m_axi_gmem_out0_bresp-1:0] m_axi_gmem_out0_bresp;
  output [BITSIZE_m_axi_gmem_out0_buser-1:0] m_axi_gmem_out0_buser;
  output m_axi_gmem_out0_bvalid;
  output m_axi_gmem_out0_arready;
  output [BITSIZE_m_axi_gmem_out0_rid-1:0] m_axi_gmem_out0_rid;
  output [BITSIZE_m_axi_gmem_out0_rdata-1:0] m_axi_gmem_out0_rdata;
  output [BITSIZE_m_axi_gmem_out0_rresp-1:0] m_axi_gmem_out0_rresp;
  output m_axi_gmem_out0_rlast;
  output [BITSIZE_m_axi_gmem_out0_ruser-1:0] m_axi_gmem_out0_ruser;
  output m_axi_gmem_out0_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem_out0_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem_out0_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem_out0_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem_out0_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem_out0_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem_out0_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem_out0_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem_out0_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem_out0_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem_out0_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem_out0_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem_out0_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem_out0_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem_out0_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem_out0_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem_out0_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem_out0_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem_out0_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem_out0_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem_out0_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem_out0_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem_out0_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem_out0_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem_out0_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem_out0_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem_out0_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem_out0_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem_out0_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem_out0_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem_out0_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem_out0_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem_out0_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem_out0_awready=awready;
  assign m_axi_gmem_out0_wready=wready;
  assign m_axi_gmem_out0_bid=bid;
  assign m_axi_gmem_out0_bresp=bresp;
  assign m_axi_gmem_out0_buser=buser;
  assign m_axi_gmem_out0_bvalid=bvalid;
  assign m_axi_gmem_out0_arready=arready;
  assign m_axi_gmem_out0_rid=rid;
  assign m_axi_gmem_out0_rdata=rdata;
  assign m_axi_gmem_out0_rresp=rresp;
  assign m_axi_gmem_out0_rlast=rlast;
  assign m_axi_gmem_out0_ruser=ruser;
  assign m_axi_gmem_out0_rvalid=rvalid;
  assign awid=m_axi_gmem_out0_awid;
  assign awaddr=m_axi_gmem_out0_awaddr;
  assign awlen=m_axi_gmem_out0_awlen;
  assign awsize=m_axi_gmem_out0_awsize;
  assign awburst=m_axi_gmem_out0_awburst;
  assign awlock=m_axi_gmem_out0_awlock;
  assign awcache=m_axi_gmem_out0_awcache;
  assign awprot=m_axi_gmem_out0_awprot;
  assign awqos=m_axi_gmem_out0_awqos;
  assign awregion=m_axi_gmem_out0_awregion;
  assign awuser=m_axi_gmem_out0_awuser;
  assign awvalid=m_axi_gmem_out0_awvalid;
  assign wdata=m_axi_gmem_out0_wdata;
  assign wstrb=m_axi_gmem_out0_wstrb;
  assign wlast=m_axi_gmem_out0_wlast;
  assign wuser=m_axi_gmem_out0_wuser;
  assign wvalid=m_axi_gmem_out0_wvalid;
  assign bready=m_axi_gmem_out0_bready;
  assign arid=m_axi_gmem_out0_arid;
  assign araddr=m_axi_gmem_out0_araddr;
  assign arlen=m_axi_gmem_out0_arlen;
  assign arsize=m_axi_gmem_out0_arsize;
  assign arburst=m_axi_gmem_out0_arburst;
  assign arlock=m_axi_gmem_out0_arlock;
  assign arcache=m_axi_gmem_out0_arcache;
  assign arprot=m_axi_gmem_out0_arprot;
  assign arqos=m_axi_gmem_out0_arqos;
  assign arregion=m_axi_gmem_out0_arregion;
  assign aruser=m_axi_gmem_out0_aruser;
  assign arvalid=m_axi_gmem_out0_arvalid;
  assign rready=m_axi_gmem_out0_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem_out0_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem_out0_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem_out0_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem_out0_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem_out0_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem_out0_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem_out0_arid,
    OFFSET_delay=0,
    OFFSET_counter=OFFSET_delay+BITSIZE_delay,
    OFFSET_burst=OFFSET_counter+BITSIZE_counter,
    OFFSET_len=OFFSET_burst+BITSIZE_burst,
    OFFSET_size=OFFSET_len+BITSIZE_len,
    OFFSET_addr=OFFSET_size+BITSIZE_size,
    OFFSET_id=OFFSET_addr+BITSIZE_addr,
    OFFSET_data=OFFSET_id+BITSIZE_id,
    OFFSET_wstrb=OFFSET_data+BITSIZE_data,
    BITSIZE_aritem=BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay,
    BITSIZE_awitem=BITSIZE_wstrb+BITSIZE_data+BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay;
  
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] arqueue;
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] next_arqueue;
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] awqueue; 
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] next_awqueue;
  reg [31:0] test_addr;
  reg [31:0] test_wstrb;
  reg [31:0] test_data;
  reg [31:0] test_addr_read;
  integer arqueue_size, next_arqueue_size;
  integer awqueue_size, next_awqueue_size;
  
  reg [BITSIZE_id-1:0] awid_reg;
  reg [BITSIZE_addr-1:0] awaddr_reg;
  reg [BITSIZE_size-1:0] awsize_reg;
  reg [BITSIZE_len-1:0] awlen_reg; 
  reg [BITSIZE_burst-1:0] awburst_reg;
  reg [BITSIZE_counter-1:0] counter_reg, counter_next;
  reg write_done;
  reg wlast_reg, wlast_next;
  
  if_utils #(index, BITSIZE_data) m_utils();
  
  initial
  begin
    arqueue = 0;
    arqueue_size = 0;
    next_arqueue = 0;
    next_arqueue_size = 0;
    awqueue = 0;
    awqueue_size = 0;
    next_awqueue = 0;
    next_awqueue_size = 0;
    awready = 0;
    wready = 0;
    bid = 0;
    bresp = 0;
    buser = 0;
    bvalid = 0;
    arready = 0;
    rid = 0;
    rdata = 0;
    rresp = 0;
    rlast = 0;
    ruser = 0;
    rvalid = 0;
    awid_reg = 0;
    awaddr_reg = 0;
    awsize_reg = 0;
    awlen_reg = 0;
    awburst_reg = 0;
  end
  
  // Combinatorial logic for read transactions
  always@(*)
  begin: read_comb
    automatic integer unsigned i;
    next_arqueue = arqueue;
    next_arqueue_size = arqueue_size;
    if(arvalid && arready)  // Valid and ready -> accept new transaction
    begin
      next_arqueue[arqueue_size*BITSIZE_aritem +:BITSIZE_aritem] = {arid, araddr, arsize, arlen, arburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + READ_DELAY)}; // size of parameter is implementation dependent
      next_arqueue_size = arqueue_size + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] = arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1) && rready && rvalid)
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_arqueue[(i-1)*BITSIZE_aritem+:BITSIZE_aritem] = next_arqueue[i*BITSIZE_aritem+:BITSIZE_aritem];
      end
      next_arqueue_size = next_arqueue_size - 1;
    end
    if(next_arqueue_size > 0 && (next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1) && (next_arqueue[OFFSET_counter+:BITSIZE_counter] < (next_arqueue[OFFSET_len+:BITSIZE_len] + 1)))
    begin
      next_arqueue[OFFSET_counter+:BITSIZE_counter] = next_arqueue[OFFSET_counter+:BITSIZE_counter] + 1;
    end
  end
  
  // Combinatorial logic for write transactions
  always@(*) 
  begin: write_comb
    automatic integer i;
    automatic reg [BITSIZE_counter-1:0] counter;
    next_awqueue = awqueue;
    next_awqueue_size = awqueue_size;
    wlast_next = wlast_reg;
    if(awvalid && awready && wready && wvalid) // Valid and ready -> accept new transaction and save data
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid, awaddr, awsize, awlen, awburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
    end
    else if(awvalid && awready && wlast_reg)
    begin
      awid_reg = awid;
      awaddr_reg = awaddr;
      awsize_reg = awsize;
      awlen_reg = awlen; 
      awburst_reg = awburst;
      counter_next = 0;
      wlast_next = 0;
    end
    else if(wready && wvalid)
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid_reg, awaddr_reg, awsize_reg, awlen_reg, awburst_reg, counter_reg, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
      counter_next = counter_reg + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] = awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(write_done && next_awqueue_size > 0 && ((next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len] && bready) || next_awqueue[OFFSET_counter+:BITSIZE_counter] < next_awqueue[OFFSET_len+:BITSIZE_len]))
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_awqueue[(i-1)*BITSIZE_awitem+:BITSIZE_awitem] = next_awqueue[i*BITSIZE_awitem+:BITSIZE_awitem];
      end
      next_awqueue_size = next_awqueue_size - 1;
    end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arready <= 0;
      awready <= 0;
      wready <= 0;
      wlast_reg <= 1;
      counter_reg <= 0;
     end
     else
     begin
      arready <= (next_arqueue_size - (next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= next_arqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE);  //Ready if next_queue_size - rlast < QUEUE_SIZE
      awready <= (wlast_next || wlast) && (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); // ready if next_queue_size - bvalid < QUEUE_SIZE
      wready <= (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); 
      wlast_reg <= wlast_next || wlast;
      counter_reg <= counter_next;
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      rvalid <= 0;
      bvalid <= 0;
     end
     else
     begin
      rvalid <= (next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1); // if at posedge_clock delay is 1 I have to perfrom the operation in this cycle
      bvalid <= (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == (next_awqueue[OFFSET_len+:BITSIZE_len])); // if at posedge_clock delay is 1 I have to perfrom the last operation in this cycle
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arqueue <= 0;
      arqueue_size <= 0;
      awqueue <= 0;
      awqueue_size <= 0;
     end
     else
     begin
      arqueue <= next_arqueue;
      arqueue_size <= next_arqueue_size;
      awqueue <= next_awqueue;
      awqueue_size <= next_awqueue_size;
     end
  end
  
  // Sequential logic for read transactions
  always@(posedge clock)
  begin : read_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    rlast <= 0;
    test_addr_read <= 0;
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1)
    begin
      if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr] + (next_arqueue[OFFSET_counter+:BITSIZE_counter] - 1) * (1 << next_arqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_addr_read <= currAddr;
      rid <= next_arqueue[OFFSET_id+:BITSIZE_id];
      rdata <= m_utils.read_a(currAddr);
      if(next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1))
      begin
        rlast <= 1;
      end
    end
  end
  
  // Sequential logic for write transactions
  always@(posedge clock)
  begin: write_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    test_wstrb <=0;
    test_addr <= 0;
    test_data <= 0;
    write_done <= 0;
    if(next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1) // Performs the first write of the queue
    begin
      if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr] + next_awqueue[OFFSET_counter+:BITSIZE_counter] * (1 << next_awqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_wstrb <= next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb];
      test_addr <= currAddr;
      test_data <= next_awqueue[OFFSET_data+:BITSIZE_data];
      bid <= next_awqueue[OFFSET_id+:BITSIZE_id];
      write_done <= 1;
      void'(m_utils.write_strobe(next_awqueue[OFFSET_data+:BITSIZE_data], next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb], currAddr));
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_m_axi_gmem_out1(clock,
  reset,
  done_port,
  m_axi_gmem_out1_awready,
  m_axi_gmem_out1_wready,
  m_axi_gmem_out1_bid,
  m_axi_gmem_out1_bresp,
  m_axi_gmem_out1_buser,
  m_axi_gmem_out1_bvalid,
  m_axi_gmem_out1_arready,
  m_axi_gmem_out1_rid,
  m_axi_gmem_out1_rdata,
  m_axi_gmem_out1_rresp,
  m_axi_gmem_out1_rlast,
  m_axi_gmem_out1_ruser,
  m_axi_gmem_out1_rvalid,
  m_axi_gmem_out1_awid,
  m_axi_gmem_out1_awaddr,
  m_axi_gmem_out1_awlen,
  m_axi_gmem_out1_awsize,
  m_axi_gmem_out1_awburst,
  m_axi_gmem_out1_awlock,
  m_axi_gmem_out1_awcache,
  m_axi_gmem_out1_awprot,
  m_axi_gmem_out1_awqos,
  m_axi_gmem_out1_awregion,
  m_axi_gmem_out1_awuser,
  m_axi_gmem_out1_awvalid,
  m_axi_gmem_out1_wdata,
  m_axi_gmem_out1_wstrb,
  m_axi_gmem_out1_wlast,
  m_axi_gmem_out1_wuser,
  m_axi_gmem_out1_wvalid,
  m_axi_gmem_out1_bready,
  m_axi_gmem_out1_arid,
  m_axi_gmem_out1_araddr,
  m_axi_gmem_out1_arlen,
  m_axi_gmem_out1_arsize,
  m_axi_gmem_out1_arburst,
  m_axi_gmem_out1_arlock,
  m_axi_gmem_out1_arcache,
  m_axi_gmem_out1_arprot,
  m_axi_gmem_out1_arqos,
  m_axi_gmem_out1_arregion,
  m_axi_gmem_out1_aruser,
  m_axi_gmem_out1_arvalid,
  m_axi_gmem_out1_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem_out1_bid=1,
    BITSIZE_m_axi_gmem_out1_bresp=2,
    BITSIZE_m_axi_gmem_out1_buser=1,
    BITSIZE_m_axi_gmem_out1_rid=1,
    BITSIZE_m_axi_gmem_out1_rdata=1,
    BITSIZE_m_axi_gmem_out1_rresp=2,
    BITSIZE_m_axi_gmem_out1_ruser=1,
    BITSIZE_m_axi_gmem_out1_awid=1,
    BITSIZE_m_axi_gmem_out1_awaddr=1,
    BITSIZE_m_axi_gmem_out1_awlen=1,
    BITSIZE_m_axi_gmem_out1_awsize=1,
    BITSIZE_m_axi_gmem_out1_awburst=2,
    BITSIZE_m_axi_gmem_out1_awlock=1,
    BITSIZE_m_axi_gmem_out1_awcache=1,
    BITSIZE_m_axi_gmem_out1_awprot=1,
    BITSIZE_m_axi_gmem_out1_awqos=1,
    BITSIZE_m_axi_gmem_out1_awregion=1,
    BITSIZE_m_axi_gmem_out1_awuser=1,
    BITSIZE_m_axi_gmem_out1_wdata=1,
    BITSIZE_m_axi_gmem_out1_wstrb=1,
    BITSIZE_m_axi_gmem_out1_wuser=1,
    BITSIZE_m_axi_gmem_out1_arid=1,
    BITSIZE_m_axi_gmem_out1_araddr=1,
    BITSIZE_m_axi_gmem_out1_arlen=1,
    BITSIZE_m_axi_gmem_out1_arsize=1,
    BITSIZE_m_axi_gmem_out1_arburst=2,
    BITSIZE_m_axi_gmem_out1_arlock=1,
    BITSIZE_m_axi_gmem_out1_arcache=1,
    BITSIZE_m_axi_gmem_out1_arprot=1,
    BITSIZE_m_axi_gmem_out1_arqos=1,
    BITSIZE_m_axi_gmem_out1_arregion=1,
    BITSIZE_m_axi_gmem_out1_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem_out1_awid-1:0] m_axi_gmem_out1_awid;
  input [BITSIZE_m_axi_gmem_out1_awaddr-1:0] m_axi_gmem_out1_awaddr;
  input [BITSIZE_m_axi_gmem_out1_awlen-1:0] m_axi_gmem_out1_awlen;
  input [BITSIZE_m_axi_gmem_out1_awsize-1:0] m_axi_gmem_out1_awsize;
  input [BITSIZE_m_axi_gmem_out1_awburst-1:0] m_axi_gmem_out1_awburst;
  input [BITSIZE_m_axi_gmem_out1_awlock-1:0] m_axi_gmem_out1_awlock;
  input [BITSIZE_m_axi_gmem_out1_awcache-1:0] m_axi_gmem_out1_awcache;
  input [BITSIZE_m_axi_gmem_out1_awprot-1:0] m_axi_gmem_out1_awprot;
  input [BITSIZE_m_axi_gmem_out1_awqos-1:0] m_axi_gmem_out1_awqos;
  input [BITSIZE_m_axi_gmem_out1_awregion-1:0] m_axi_gmem_out1_awregion;
  input [BITSIZE_m_axi_gmem_out1_awuser-1:0] m_axi_gmem_out1_awuser;
  input m_axi_gmem_out1_awvalid;
  input [BITSIZE_m_axi_gmem_out1_wdata-1:0] m_axi_gmem_out1_wdata;
  input [BITSIZE_m_axi_gmem_out1_wstrb-1:0] m_axi_gmem_out1_wstrb;
  input m_axi_gmem_out1_wlast;
  input [BITSIZE_m_axi_gmem_out1_wuser-1:0] m_axi_gmem_out1_wuser;
  input m_axi_gmem_out1_wvalid;
  input m_axi_gmem_out1_bready;
  input [BITSIZE_m_axi_gmem_out1_arid-1:0] m_axi_gmem_out1_arid;
  input [BITSIZE_m_axi_gmem_out1_araddr-1:0] m_axi_gmem_out1_araddr;
  input [BITSIZE_m_axi_gmem_out1_arlen-1:0] m_axi_gmem_out1_arlen;
  input [BITSIZE_m_axi_gmem_out1_arsize-1:0] m_axi_gmem_out1_arsize;
  input [BITSIZE_m_axi_gmem_out1_arburst-1:0] m_axi_gmem_out1_arburst;
  input [BITSIZE_m_axi_gmem_out1_arlock-1:0] m_axi_gmem_out1_arlock;
  input [BITSIZE_m_axi_gmem_out1_arcache-1:0] m_axi_gmem_out1_arcache;
  input [BITSIZE_m_axi_gmem_out1_arprot-1:0] m_axi_gmem_out1_arprot;
  input [BITSIZE_m_axi_gmem_out1_arqos-1:0] m_axi_gmem_out1_arqos;
  input [BITSIZE_m_axi_gmem_out1_arregion-1:0] m_axi_gmem_out1_arregion;
  input [BITSIZE_m_axi_gmem_out1_aruser-1:0] m_axi_gmem_out1_aruser;
  input m_axi_gmem_out1_arvalid;
  input m_axi_gmem_out1_rready;
  // OUT
  output m_axi_gmem_out1_awready;
  output m_axi_gmem_out1_wready;
  output [BITSIZE_m_axi_gmem_out1_bid-1:0] m_axi_gmem_out1_bid;
  output [BITSIZE_m_axi_gmem_out1_bresp-1:0] m_axi_gmem_out1_bresp;
  output [BITSIZE_m_axi_gmem_out1_buser-1:0] m_axi_gmem_out1_buser;
  output m_axi_gmem_out1_bvalid;
  output m_axi_gmem_out1_arready;
  output [BITSIZE_m_axi_gmem_out1_rid-1:0] m_axi_gmem_out1_rid;
  output [BITSIZE_m_axi_gmem_out1_rdata-1:0] m_axi_gmem_out1_rdata;
  output [BITSIZE_m_axi_gmem_out1_rresp-1:0] m_axi_gmem_out1_rresp;
  output m_axi_gmem_out1_rlast;
  output [BITSIZE_m_axi_gmem_out1_ruser-1:0] m_axi_gmem_out1_ruser;
  output m_axi_gmem_out1_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem_out1_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem_out1_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem_out1_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem_out1_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem_out1_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem_out1_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem_out1_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem_out1_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem_out1_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem_out1_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem_out1_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem_out1_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem_out1_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem_out1_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem_out1_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem_out1_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem_out1_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem_out1_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem_out1_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem_out1_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem_out1_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem_out1_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem_out1_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem_out1_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem_out1_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem_out1_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem_out1_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem_out1_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem_out1_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem_out1_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem_out1_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem_out1_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem_out1_awready=awready;
  assign m_axi_gmem_out1_wready=wready;
  assign m_axi_gmem_out1_bid=bid;
  assign m_axi_gmem_out1_bresp=bresp;
  assign m_axi_gmem_out1_buser=buser;
  assign m_axi_gmem_out1_bvalid=bvalid;
  assign m_axi_gmem_out1_arready=arready;
  assign m_axi_gmem_out1_rid=rid;
  assign m_axi_gmem_out1_rdata=rdata;
  assign m_axi_gmem_out1_rresp=rresp;
  assign m_axi_gmem_out1_rlast=rlast;
  assign m_axi_gmem_out1_ruser=ruser;
  assign m_axi_gmem_out1_rvalid=rvalid;
  assign awid=m_axi_gmem_out1_awid;
  assign awaddr=m_axi_gmem_out1_awaddr;
  assign awlen=m_axi_gmem_out1_awlen;
  assign awsize=m_axi_gmem_out1_awsize;
  assign awburst=m_axi_gmem_out1_awburst;
  assign awlock=m_axi_gmem_out1_awlock;
  assign awcache=m_axi_gmem_out1_awcache;
  assign awprot=m_axi_gmem_out1_awprot;
  assign awqos=m_axi_gmem_out1_awqos;
  assign awregion=m_axi_gmem_out1_awregion;
  assign awuser=m_axi_gmem_out1_awuser;
  assign awvalid=m_axi_gmem_out1_awvalid;
  assign wdata=m_axi_gmem_out1_wdata;
  assign wstrb=m_axi_gmem_out1_wstrb;
  assign wlast=m_axi_gmem_out1_wlast;
  assign wuser=m_axi_gmem_out1_wuser;
  assign wvalid=m_axi_gmem_out1_wvalid;
  assign bready=m_axi_gmem_out1_bready;
  assign arid=m_axi_gmem_out1_arid;
  assign araddr=m_axi_gmem_out1_araddr;
  assign arlen=m_axi_gmem_out1_arlen;
  assign arsize=m_axi_gmem_out1_arsize;
  assign arburst=m_axi_gmem_out1_arburst;
  assign arlock=m_axi_gmem_out1_arlock;
  assign arcache=m_axi_gmem_out1_arcache;
  assign arprot=m_axi_gmem_out1_arprot;
  assign arqos=m_axi_gmem_out1_arqos;
  assign arregion=m_axi_gmem_out1_arregion;
  assign aruser=m_axi_gmem_out1_aruser;
  assign arvalid=m_axi_gmem_out1_arvalid;
  assign rready=m_axi_gmem_out1_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem_out1_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem_out1_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem_out1_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem_out1_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem_out1_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem_out1_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem_out1_arid,
    OFFSET_delay=0,
    OFFSET_counter=OFFSET_delay+BITSIZE_delay,
    OFFSET_burst=OFFSET_counter+BITSIZE_counter,
    OFFSET_len=OFFSET_burst+BITSIZE_burst,
    OFFSET_size=OFFSET_len+BITSIZE_len,
    OFFSET_addr=OFFSET_size+BITSIZE_size,
    OFFSET_id=OFFSET_addr+BITSIZE_addr,
    OFFSET_data=OFFSET_id+BITSIZE_id,
    OFFSET_wstrb=OFFSET_data+BITSIZE_data,
    BITSIZE_aritem=BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay,
    BITSIZE_awitem=BITSIZE_wstrb+BITSIZE_data+BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay;
  
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] arqueue;
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] next_arqueue;
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] awqueue; 
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] next_awqueue;
  reg [31:0] test_addr;
  reg [31:0] test_wstrb;
  reg [31:0] test_data;
  reg [31:0] test_addr_read;
  integer arqueue_size, next_arqueue_size;
  integer awqueue_size, next_awqueue_size;
  
  reg [BITSIZE_id-1:0] awid_reg;
  reg [BITSIZE_addr-1:0] awaddr_reg;
  reg [BITSIZE_size-1:0] awsize_reg;
  reg [BITSIZE_len-1:0] awlen_reg; 
  reg [BITSIZE_burst-1:0] awburst_reg;
  reg [BITSIZE_counter-1:0] counter_reg, counter_next;
  reg write_done;
  reg wlast_reg, wlast_next;
  
  if_utils #(index, BITSIZE_data) m_utils();
  
  initial
  begin
    arqueue = 0;
    arqueue_size = 0;
    next_arqueue = 0;
    next_arqueue_size = 0;
    awqueue = 0;
    awqueue_size = 0;
    next_awqueue = 0;
    next_awqueue_size = 0;
    awready = 0;
    wready = 0;
    bid = 0;
    bresp = 0;
    buser = 0;
    bvalid = 0;
    arready = 0;
    rid = 0;
    rdata = 0;
    rresp = 0;
    rlast = 0;
    ruser = 0;
    rvalid = 0;
    awid_reg = 0;
    awaddr_reg = 0;
    awsize_reg = 0;
    awlen_reg = 0;
    awburst_reg = 0;
  end
  
  // Combinatorial logic for read transactions
  always@(*)
  begin: read_comb
    automatic integer unsigned i;
    next_arqueue = arqueue;
    next_arqueue_size = arqueue_size;
    if(arvalid && arready)  // Valid and ready -> accept new transaction
    begin
      next_arqueue[arqueue_size*BITSIZE_aritem +:BITSIZE_aritem] = {arid, araddr, arsize, arlen, arburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + READ_DELAY)}; // size of parameter is implementation dependent
      next_arqueue_size = arqueue_size + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] = arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1) && rready && rvalid)
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_arqueue[(i-1)*BITSIZE_aritem+:BITSIZE_aritem] = next_arqueue[i*BITSIZE_aritem+:BITSIZE_aritem];
      end
      next_arqueue_size = next_arqueue_size - 1;
    end
    if(next_arqueue_size > 0 && (next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1) && (next_arqueue[OFFSET_counter+:BITSIZE_counter] < (next_arqueue[OFFSET_len+:BITSIZE_len] + 1)))
    begin
      next_arqueue[OFFSET_counter+:BITSIZE_counter] = next_arqueue[OFFSET_counter+:BITSIZE_counter] + 1;
    end
  end
  
  // Combinatorial logic for write transactions
  always@(*) 
  begin: write_comb
    automatic integer i;
    automatic reg [BITSIZE_counter-1:0] counter;
    next_awqueue = awqueue;
    next_awqueue_size = awqueue_size;
    wlast_next = wlast_reg;
    if(awvalid && awready && wready && wvalid) // Valid and ready -> accept new transaction and save data
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid, awaddr, awsize, awlen, awburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
    end
    else if(awvalid && awready && wlast_reg)
    begin
      awid_reg = awid;
      awaddr_reg = awaddr;
      awsize_reg = awsize;
      awlen_reg = awlen; 
      awburst_reg = awburst;
      counter_next = 0;
      wlast_next = 0;
    end
    else if(wready && wvalid)
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid_reg, awaddr_reg, awsize_reg, awlen_reg, awburst_reg, counter_reg, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
      counter_next = counter_reg + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] = awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(write_done && next_awqueue_size > 0 && ((next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len] && bready) || next_awqueue[OFFSET_counter+:BITSIZE_counter] < next_awqueue[OFFSET_len+:BITSIZE_len]))
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_awqueue[(i-1)*BITSIZE_awitem+:BITSIZE_awitem] = next_awqueue[i*BITSIZE_awitem+:BITSIZE_awitem];
      end
      next_awqueue_size = next_awqueue_size - 1;
    end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arready <= 0;
      awready <= 0;
      wready <= 0;
      wlast_reg <= 1;
      counter_reg <= 0;
     end
     else
     begin
      arready <= (next_arqueue_size - (next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= next_arqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE);  //Ready if next_queue_size - rlast < QUEUE_SIZE
      awready <= (wlast_next || wlast) && (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); // ready if next_queue_size - bvalid < QUEUE_SIZE
      wready <= (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); 
      wlast_reg <= wlast_next || wlast;
      counter_reg <= counter_next;
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      rvalid <= 0;
      bvalid <= 0;
     end
     else
     begin
      rvalid <= (next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1); // if at posedge_clock delay is 1 I have to perfrom the operation in this cycle
      bvalid <= (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == (next_awqueue[OFFSET_len+:BITSIZE_len])); // if at posedge_clock delay is 1 I have to perfrom the last operation in this cycle
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arqueue <= 0;
      arqueue_size <= 0;
      awqueue <= 0;
      awqueue_size <= 0;
     end
     else
     begin
      arqueue <= next_arqueue;
      arqueue_size <= next_arqueue_size;
      awqueue <= next_awqueue;
      awqueue_size <= next_awqueue_size;
     end
  end
  
  // Sequential logic for read transactions
  always@(posedge clock)
  begin : read_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    rlast <= 0;
    test_addr_read <= 0;
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1)
    begin
      if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr] + (next_arqueue[OFFSET_counter+:BITSIZE_counter] - 1) * (1 << next_arqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_addr_read <= currAddr;
      rid <= next_arqueue[OFFSET_id+:BITSIZE_id];
      rdata <= m_utils.read_a(currAddr);
      if(next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1))
      begin
        rlast <= 1;
      end
    end
  end
  
  // Sequential logic for write transactions
  always@(posedge clock)
  begin: write_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    test_wstrb <=0;
    test_addr <= 0;
    test_data <= 0;
    write_done <= 0;
    if(next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1) // Performs the first write of the queue
    begin
      if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr] + next_awqueue[OFFSET_counter+:BITSIZE_counter] * (1 << next_awqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_wstrb <= next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb];
      test_addr <= currAddr;
      test_data <= next_awqueue[OFFSET_data+:BITSIZE_data];
      bid <= next_awqueue[OFFSET_id+:BITSIZE_id];
      write_done <= 1;
      void'(m_utils.write_strobe(next_awqueue[OFFSET_data+:BITSIZE_data], next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb], currAddr));
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_m_axi_gmem_out2(clock,
  reset,
  done_port,
  m_axi_gmem_out2_awready,
  m_axi_gmem_out2_wready,
  m_axi_gmem_out2_bid,
  m_axi_gmem_out2_bresp,
  m_axi_gmem_out2_buser,
  m_axi_gmem_out2_bvalid,
  m_axi_gmem_out2_arready,
  m_axi_gmem_out2_rid,
  m_axi_gmem_out2_rdata,
  m_axi_gmem_out2_rresp,
  m_axi_gmem_out2_rlast,
  m_axi_gmem_out2_ruser,
  m_axi_gmem_out2_rvalid,
  m_axi_gmem_out2_awid,
  m_axi_gmem_out2_awaddr,
  m_axi_gmem_out2_awlen,
  m_axi_gmem_out2_awsize,
  m_axi_gmem_out2_awburst,
  m_axi_gmem_out2_awlock,
  m_axi_gmem_out2_awcache,
  m_axi_gmem_out2_awprot,
  m_axi_gmem_out2_awqos,
  m_axi_gmem_out2_awregion,
  m_axi_gmem_out2_awuser,
  m_axi_gmem_out2_awvalid,
  m_axi_gmem_out2_wdata,
  m_axi_gmem_out2_wstrb,
  m_axi_gmem_out2_wlast,
  m_axi_gmem_out2_wuser,
  m_axi_gmem_out2_wvalid,
  m_axi_gmem_out2_bready,
  m_axi_gmem_out2_arid,
  m_axi_gmem_out2_araddr,
  m_axi_gmem_out2_arlen,
  m_axi_gmem_out2_arsize,
  m_axi_gmem_out2_arburst,
  m_axi_gmem_out2_arlock,
  m_axi_gmem_out2_arcache,
  m_axi_gmem_out2_arprot,
  m_axi_gmem_out2_arqos,
  m_axi_gmem_out2_arregion,
  m_axi_gmem_out2_aruser,
  m_axi_gmem_out2_arvalid,
  m_axi_gmem_out2_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem_out2_bid=1,
    BITSIZE_m_axi_gmem_out2_bresp=2,
    BITSIZE_m_axi_gmem_out2_buser=1,
    BITSIZE_m_axi_gmem_out2_rid=1,
    BITSIZE_m_axi_gmem_out2_rdata=1,
    BITSIZE_m_axi_gmem_out2_rresp=2,
    BITSIZE_m_axi_gmem_out2_ruser=1,
    BITSIZE_m_axi_gmem_out2_awid=1,
    BITSIZE_m_axi_gmem_out2_awaddr=1,
    BITSIZE_m_axi_gmem_out2_awlen=1,
    BITSIZE_m_axi_gmem_out2_awsize=1,
    BITSIZE_m_axi_gmem_out2_awburst=2,
    BITSIZE_m_axi_gmem_out2_awlock=1,
    BITSIZE_m_axi_gmem_out2_awcache=1,
    BITSIZE_m_axi_gmem_out2_awprot=1,
    BITSIZE_m_axi_gmem_out2_awqos=1,
    BITSIZE_m_axi_gmem_out2_awregion=1,
    BITSIZE_m_axi_gmem_out2_awuser=1,
    BITSIZE_m_axi_gmem_out2_wdata=1,
    BITSIZE_m_axi_gmem_out2_wstrb=1,
    BITSIZE_m_axi_gmem_out2_wuser=1,
    BITSIZE_m_axi_gmem_out2_arid=1,
    BITSIZE_m_axi_gmem_out2_araddr=1,
    BITSIZE_m_axi_gmem_out2_arlen=1,
    BITSIZE_m_axi_gmem_out2_arsize=1,
    BITSIZE_m_axi_gmem_out2_arburst=2,
    BITSIZE_m_axi_gmem_out2_arlock=1,
    BITSIZE_m_axi_gmem_out2_arcache=1,
    BITSIZE_m_axi_gmem_out2_arprot=1,
    BITSIZE_m_axi_gmem_out2_arqos=1,
    BITSIZE_m_axi_gmem_out2_arregion=1,
    BITSIZE_m_axi_gmem_out2_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem_out2_awid-1:0] m_axi_gmem_out2_awid;
  input [BITSIZE_m_axi_gmem_out2_awaddr-1:0] m_axi_gmem_out2_awaddr;
  input [BITSIZE_m_axi_gmem_out2_awlen-1:0] m_axi_gmem_out2_awlen;
  input [BITSIZE_m_axi_gmem_out2_awsize-1:0] m_axi_gmem_out2_awsize;
  input [BITSIZE_m_axi_gmem_out2_awburst-1:0] m_axi_gmem_out2_awburst;
  input [BITSIZE_m_axi_gmem_out2_awlock-1:0] m_axi_gmem_out2_awlock;
  input [BITSIZE_m_axi_gmem_out2_awcache-1:0] m_axi_gmem_out2_awcache;
  input [BITSIZE_m_axi_gmem_out2_awprot-1:0] m_axi_gmem_out2_awprot;
  input [BITSIZE_m_axi_gmem_out2_awqos-1:0] m_axi_gmem_out2_awqos;
  input [BITSIZE_m_axi_gmem_out2_awregion-1:0] m_axi_gmem_out2_awregion;
  input [BITSIZE_m_axi_gmem_out2_awuser-1:0] m_axi_gmem_out2_awuser;
  input m_axi_gmem_out2_awvalid;
  input [BITSIZE_m_axi_gmem_out2_wdata-1:0] m_axi_gmem_out2_wdata;
  input [BITSIZE_m_axi_gmem_out2_wstrb-1:0] m_axi_gmem_out2_wstrb;
  input m_axi_gmem_out2_wlast;
  input [BITSIZE_m_axi_gmem_out2_wuser-1:0] m_axi_gmem_out2_wuser;
  input m_axi_gmem_out2_wvalid;
  input m_axi_gmem_out2_bready;
  input [BITSIZE_m_axi_gmem_out2_arid-1:0] m_axi_gmem_out2_arid;
  input [BITSIZE_m_axi_gmem_out2_araddr-1:0] m_axi_gmem_out2_araddr;
  input [BITSIZE_m_axi_gmem_out2_arlen-1:0] m_axi_gmem_out2_arlen;
  input [BITSIZE_m_axi_gmem_out2_arsize-1:0] m_axi_gmem_out2_arsize;
  input [BITSIZE_m_axi_gmem_out2_arburst-1:0] m_axi_gmem_out2_arburst;
  input [BITSIZE_m_axi_gmem_out2_arlock-1:0] m_axi_gmem_out2_arlock;
  input [BITSIZE_m_axi_gmem_out2_arcache-1:0] m_axi_gmem_out2_arcache;
  input [BITSIZE_m_axi_gmem_out2_arprot-1:0] m_axi_gmem_out2_arprot;
  input [BITSIZE_m_axi_gmem_out2_arqos-1:0] m_axi_gmem_out2_arqos;
  input [BITSIZE_m_axi_gmem_out2_arregion-1:0] m_axi_gmem_out2_arregion;
  input [BITSIZE_m_axi_gmem_out2_aruser-1:0] m_axi_gmem_out2_aruser;
  input m_axi_gmem_out2_arvalid;
  input m_axi_gmem_out2_rready;
  // OUT
  output m_axi_gmem_out2_awready;
  output m_axi_gmem_out2_wready;
  output [BITSIZE_m_axi_gmem_out2_bid-1:0] m_axi_gmem_out2_bid;
  output [BITSIZE_m_axi_gmem_out2_bresp-1:0] m_axi_gmem_out2_bresp;
  output [BITSIZE_m_axi_gmem_out2_buser-1:0] m_axi_gmem_out2_buser;
  output m_axi_gmem_out2_bvalid;
  output m_axi_gmem_out2_arready;
  output [BITSIZE_m_axi_gmem_out2_rid-1:0] m_axi_gmem_out2_rid;
  output [BITSIZE_m_axi_gmem_out2_rdata-1:0] m_axi_gmem_out2_rdata;
  output [BITSIZE_m_axi_gmem_out2_rresp-1:0] m_axi_gmem_out2_rresp;
  output m_axi_gmem_out2_rlast;
  output [BITSIZE_m_axi_gmem_out2_ruser-1:0] m_axi_gmem_out2_ruser;
  output m_axi_gmem_out2_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem_out2_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem_out2_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem_out2_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem_out2_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem_out2_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem_out2_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem_out2_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem_out2_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem_out2_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem_out2_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem_out2_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem_out2_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem_out2_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem_out2_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem_out2_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem_out2_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem_out2_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem_out2_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem_out2_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem_out2_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem_out2_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem_out2_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem_out2_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem_out2_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem_out2_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem_out2_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem_out2_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem_out2_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem_out2_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem_out2_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem_out2_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem_out2_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem_out2_awready=awready;
  assign m_axi_gmem_out2_wready=wready;
  assign m_axi_gmem_out2_bid=bid;
  assign m_axi_gmem_out2_bresp=bresp;
  assign m_axi_gmem_out2_buser=buser;
  assign m_axi_gmem_out2_bvalid=bvalid;
  assign m_axi_gmem_out2_arready=arready;
  assign m_axi_gmem_out2_rid=rid;
  assign m_axi_gmem_out2_rdata=rdata;
  assign m_axi_gmem_out2_rresp=rresp;
  assign m_axi_gmem_out2_rlast=rlast;
  assign m_axi_gmem_out2_ruser=ruser;
  assign m_axi_gmem_out2_rvalid=rvalid;
  assign awid=m_axi_gmem_out2_awid;
  assign awaddr=m_axi_gmem_out2_awaddr;
  assign awlen=m_axi_gmem_out2_awlen;
  assign awsize=m_axi_gmem_out2_awsize;
  assign awburst=m_axi_gmem_out2_awburst;
  assign awlock=m_axi_gmem_out2_awlock;
  assign awcache=m_axi_gmem_out2_awcache;
  assign awprot=m_axi_gmem_out2_awprot;
  assign awqos=m_axi_gmem_out2_awqos;
  assign awregion=m_axi_gmem_out2_awregion;
  assign awuser=m_axi_gmem_out2_awuser;
  assign awvalid=m_axi_gmem_out2_awvalid;
  assign wdata=m_axi_gmem_out2_wdata;
  assign wstrb=m_axi_gmem_out2_wstrb;
  assign wlast=m_axi_gmem_out2_wlast;
  assign wuser=m_axi_gmem_out2_wuser;
  assign wvalid=m_axi_gmem_out2_wvalid;
  assign bready=m_axi_gmem_out2_bready;
  assign arid=m_axi_gmem_out2_arid;
  assign araddr=m_axi_gmem_out2_araddr;
  assign arlen=m_axi_gmem_out2_arlen;
  assign arsize=m_axi_gmem_out2_arsize;
  assign arburst=m_axi_gmem_out2_arburst;
  assign arlock=m_axi_gmem_out2_arlock;
  assign arcache=m_axi_gmem_out2_arcache;
  assign arprot=m_axi_gmem_out2_arprot;
  assign arqos=m_axi_gmem_out2_arqos;
  assign arregion=m_axi_gmem_out2_arregion;
  assign aruser=m_axi_gmem_out2_aruser;
  assign arvalid=m_axi_gmem_out2_arvalid;
  assign rready=m_axi_gmem_out2_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem_out2_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem_out2_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem_out2_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem_out2_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem_out2_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem_out2_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem_out2_arid,
    OFFSET_delay=0,
    OFFSET_counter=OFFSET_delay+BITSIZE_delay,
    OFFSET_burst=OFFSET_counter+BITSIZE_counter,
    OFFSET_len=OFFSET_burst+BITSIZE_burst,
    OFFSET_size=OFFSET_len+BITSIZE_len,
    OFFSET_addr=OFFSET_size+BITSIZE_size,
    OFFSET_id=OFFSET_addr+BITSIZE_addr,
    OFFSET_data=OFFSET_id+BITSIZE_id,
    OFFSET_wstrb=OFFSET_data+BITSIZE_data,
    BITSIZE_aritem=BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay,
    BITSIZE_awitem=BITSIZE_wstrb+BITSIZE_data+BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay;
  
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] arqueue;
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] next_arqueue;
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] awqueue; 
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] next_awqueue;
  reg [31:0] test_addr;
  reg [31:0] test_wstrb;
  reg [31:0] test_data;
  reg [31:0] test_addr_read;
  integer arqueue_size, next_arqueue_size;
  integer awqueue_size, next_awqueue_size;
  
  reg [BITSIZE_id-1:0] awid_reg;
  reg [BITSIZE_addr-1:0] awaddr_reg;
  reg [BITSIZE_size-1:0] awsize_reg;
  reg [BITSIZE_len-1:0] awlen_reg; 
  reg [BITSIZE_burst-1:0] awburst_reg;
  reg [BITSIZE_counter-1:0] counter_reg, counter_next;
  reg write_done;
  reg wlast_reg, wlast_next;
  
  if_utils #(index, BITSIZE_data) m_utils();
  
  initial
  begin
    arqueue = 0;
    arqueue_size = 0;
    next_arqueue = 0;
    next_arqueue_size = 0;
    awqueue = 0;
    awqueue_size = 0;
    next_awqueue = 0;
    next_awqueue_size = 0;
    awready = 0;
    wready = 0;
    bid = 0;
    bresp = 0;
    buser = 0;
    bvalid = 0;
    arready = 0;
    rid = 0;
    rdata = 0;
    rresp = 0;
    rlast = 0;
    ruser = 0;
    rvalid = 0;
    awid_reg = 0;
    awaddr_reg = 0;
    awsize_reg = 0;
    awlen_reg = 0;
    awburst_reg = 0;
  end
  
  // Combinatorial logic for read transactions
  always@(*)
  begin: read_comb
    automatic integer unsigned i;
    next_arqueue = arqueue;
    next_arqueue_size = arqueue_size;
    if(arvalid && arready)  // Valid and ready -> accept new transaction
    begin
      next_arqueue[arqueue_size*BITSIZE_aritem +:BITSIZE_aritem] = {arid, araddr, arsize, arlen, arburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + READ_DELAY)}; // size of parameter is implementation dependent
      next_arqueue_size = arqueue_size + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] = arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1) && rready && rvalid)
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_arqueue[(i-1)*BITSIZE_aritem+:BITSIZE_aritem] = next_arqueue[i*BITSIZE_aritem+:BITSIZE_aritem];
      end
      next_arqueue_size = next_arqueue_size - 1;
    end
    if(next_arqueue_size > 0 && (next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1) && (next_arqueue[OFFSET_counter+:BITSIZE_counter] < (next_arqueue[OFFSET_len+:BITSIZE_len] + 1)))
    begin
      next_arqueue[OFFSET_counter+:BITSIZE_counter] = next_arqueue[OFFSET_counter+:BITSIZE_counter] + 1;
    end
  end
  
  // Combinatorial logic for write transactions
  always@(*) 
  begin: write_comb
    automatic integer i;
    automatic reg [BITSIZE_counter-1:0] counter;
    next_awqueue = awqueue;
    next_awqueue_size = awqueue_size;
    wlast_next = wlast_reg;
    if(awvalid && awready && wready && wvalid) // Valid and ready -> accept new transaction and save data
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid, awaddr, awsize, awlen, awburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
    end
    else if(awvalid && awready && wlast_reg)
    begin
      awid_reg = awid;
      awaddr_reg = awaddr;
      awsize_reg = awsize;
      awlen_reg = awlen; 
      awburst_reg = awburst;
      counter_next = 0;
      wlast_next = 0;
    end
    else if(wready && wvalid)
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid_reg, awaddr_reg, awsize_reg, awlen_reg, awburst_reg, counter_reg, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
      counter_next = counter_reg + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] = awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(write_done && next_awqueue_size > 0 && ((next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len] && bready) || next_awqueue[OFFSET_counter+:BITSIZE_counter] < next_awqueue[OFFSET_len+:BITSIZE_len]))
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_awqueue[(i-1)*BITSIZE_awitem+:BITSIZE_awitem] = next_awqueue[i*BITSIZE_awitem+:BITSIZE_awitem];
      end
      next_awqueue_size = next_awqueue_size - 1;
    end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arready <= 0;
      awready <= 0;
      wready <= 0;
      wlast_reg <= 1;
      counter_reg <= 0;
     end
     else
     begin
      arready <= (next_arqueue_size - (next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= next_arqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE);  //Ready if next_queue_size - rlast < QUEUE_SIZE
      awready <= (wlast_next || wlast) && (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); // ready if next_queue_size - bvalid < QUEUE_SIZE
      wready <= (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); 
      wlast_reg <= wlast_next || wlast;
      counter_reg <= counter_next;
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      rvalid <= 0;
      bvalid <= 0;
     end
     else
     begin
      rvalid <= (next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1); // if at posedge_clock delay is 1 I have to perfrom the operation in this cycle
      bvalid <= (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == (next_awqueue[OFFSET_len+:BITSIZE_len])); // if at posedge_clock delay is 1 I have to perfrom the last operation in this cycle
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arqueue <= 0;
      arqueue_size <= 0;
      awqueue <= 0;
      awqueue_size <= 0;
     end
     else
     begin
      arqueue <= next_arqueue;
      arqueue_size <= next_arqueue_size;
      awqueue <= next_awqueue;
      awqueue_size <= next_awqueue_size;
     end
  end
  
  // Sequential logic for read transactions
  always@(posedge clock)
  begin : read_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    rlast <= 0;
    test_addr_read <= 0;
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1)
    begin
      if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr] + (next_arqueue[OFFSET_counter+:BITSIZE_counter] - 1) * (1 << next_arqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_addr_read <= currAddr;
      rid <= next_arqueue[OFFSET_id+:BITSIZE_id];
      rdata <= m_utils.read_a(currAddr);
      if(next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1))
      begin
        rlast <= 1;
      end
    end
  end
  
  // Sequential logic for write transactions
  always@(posedge clock)
  begin: write_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    test_wstrb <=0;
    test_addr <= 0;
    test_data <= 0;
    write_done <= 0;
    if(next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1) // Performs the first write of the queue
    begin
      if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr] + next_awqueue[OFFSET_counter+:BITSIZE_counter] * (1 << next_awqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_wstrb <= next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb];
      test_addr <= currAddr;
      test_data <= next_awqueue[OFFSET_data+:BITSIZE_data];
      bid <= next_awqueue[OFFSET_id+:BITSIZE_id];
      write_done <= 1;
      void'(m_utils.write_strobe(next_awqueue[OFFSET_data+:BITSIZE_data], next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb], currAddr));
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_m_axi_gmem_out3(clock,
  reset,
  done_port,
  m_axi_gmem_out3_awready,
  m_axi_gmem_out3_wready,
  m_axi_gmem_out3_bid,
  m_axi_gmem_out3_bresp,
  m_axi_gmem_out3_buser,
  m_axi_gmem_out3_bvalid,
  m_axi_gmem_out3_arready,
  m_axi_gmem_out3_rid,
  m_axi_gmem_out3_rdata,
  m_axi_gmem_out3_rresp,
  m_axi_gmem_out3_rlast,
  m_axi_gmem_out3_ruser,
  m_axi_gmem_out3_rvalid,
  m_axi_gmem_out3_awid,
  m_axi_gmem_out3_awaddr,
  m_axi_gmem_out3_awlen,
  m_axi_gmem_out3_awsize,
  m_axi_gmem_out3_awburst,
  m_axi_gmem_out3_awlock,
  m_axi_gmem_out3_awcache,
  m_axi_gmem_out3_awprot,
  m_axi_gmem_out3_awqos,
  m_axi_gmem_out3_awregion,
  m_axi_gmem_out3_awuser,
  m_axi_gmem_out3_awvalid,
  m_axi_gmem_out3_wdata,
  m_axi_gmem_out3_wstrb,
  m_axi_gmem_out3_wlast,
  m_axi_gmem_out3_wuser,
  m_axi_gmem_out3_wvalid,
  m_axi_gmem_out3_bready,
  m_axi_gmem_out3_arid,
  m_axi_gmem_out3_araddr,
  m_axi_gmem_out3_arlen,
  m_axi_gmem_out3_arsize,
  m_axi_gmem_out3_arburst,
  m_axi_gmem_out3_arlock,
  m_axi_gmem_out3_arcache,
  m_axi_gmem_out3_arprot,
  m_axi_gmem_out3_arqos,
  m_axi_gmem_out3_arregion,
  m_axi_gmem_out3_aruser,
  m_axi_gmem_out3_arvalid,
  m_axi_gmem_out3_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem_out3_bid=1,
    BITSIZE_m_axi_gmem_out3_bresp=2,
    BITSIZE_m_axi_gmem_out3_buser=1,
    BITSIZE_m_axi_gmem_out3_rid=1,
    BITSIZE_m_axi_gmem_out3_rdata=1,
    BITSIZE_m_axi_gmem_out3_rresp=2,
    BITSIZE_m_axi_gmem_out3_ruser=1,
    BITSIZE_m_axi_gmem_out3_awid=1,
    BITSIZE_m_axi_gmem_out3_awaddr=1,
    BITSIZE_m_axi_gmem_out3_awlen=1,
    BITSIZE_m_axi_gmem_out3_awsize=1,
    BITSIZE_m_axi_gmem_out3_awburst=2,
    BITSIZE_m_axi_gmem_out3_awlock=1,
    BITSIZE_m_axi_gmem_out3_awcache=1,
    BITSIZE_m_axi_gmem_out3_awprot=1,
    BITSIZE_m_axi_gmem_out3_awqos=1,
    BITSIZE_m_axi_gmem_out3_awregion=1,
    BITSIZE_m_axi_gmem_out3_awuser=1,
    BITSIZE_m_axi_gmem_out3_wdata=1,
    BITSIZE_m_axi_gmem_out3_wstrb=1,
    BITSIZE_m_axi_gmem_out3_wuser=1,
    BITSIZE_m_axi_gmem_out3_arid=1,
    BITSIZE_m_axi_gmem_out3_araddr=1,
    BITSIZE_m_axi_gmem_out3_arlen=1,
    BITSIZE_m_axi_gmem_out3_arsize=1,
    BITSIZE_m_axi_gmem_out3_arburst=2,
    BITSIZE_m_axi_gmem_out3_arlock=1,
    BITSIZE_m_axi_gmem_out3_arcache=1,
    BITSIZE_m_axi_gmem_out3_arprot=1,
    BITSIZE_m_axi_gmem_out3_arqos=1,
    BITSIZE_m_axi_gmem_out3_arregion=1,
    BITSIZE_m_axi_gmem_out3_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem_out3_awid-1:0] m_axi_gmem_out3_awid;
  input [BITSIZE_m_axi_gmem_out3_awaddr-1:0] m_axi_gmem_out3_awaddr;
  input [BITSIZE_m_axi_gmem_out3_awlen-1:0] m_axi_gmem_out3_awlen;
  input [BITSIZE_m_axi_gmem_out3_awsize-1:0] m_axi_gmem_out3_awsize;
  input [BITSIZE_m_axi_gmem_out3_awburst-1:0] m_axi_gmem_out3_awburst;
  input [BITSIZE_m_axi_gmem_out3_awlock-1:0] m_axi_gmem_out3_awlock;
  input [BITSIZE_m_axi_gmem_out3_awcache-1:0] m_axi_gmem_out3_awcache;
  input [BITSIZE_m_axi_gmem_out3_awprot-1:0] m_axi_gmem_out3_awprot;
  input [BITSIZE_m_axi_gmem_out3_awqos-1:0] m_axi_gmem_out3_awqos;
  input [BITSIZE_m_axi_gmem_out3_awregion-1:0] m_axi_gmem_out3_awregion;
  input [BITSIZE_m_axi_gmem_out3_awuser-1:0] m_axi_gmem_out3_awuser;
  input m_axi_gmem_out3_awvalid;
  input [BITSIZE_m_axi_gmem_out3_wdata-1:0] m_axi_gmem_out3_wdata;
  input [BITSIZE_m_axi_gmem_out3_wstrb-1:0] m_axi_gmem_out3_wstrb;
  input m_axi_gmem_out3_wlast;
  input [BITSIZE_m_axi_gmem_out3_wuser-1:0] m_axi_gmem_out3_wuser;
  input m_axi_gmem_out3_wvalid;
  input m_axi_gmem_out3_bready;
  input [BITSIZE_m_axi_gmem_out3_arid-1:0] m_axi_gmem_out3_arid;
  input [BITSIZE_m_axi_gmem_out3_araddr-1:0] m_axi_gmem_out3_araddr;
  input [BITSIZE_m_axi_gmem_out3_arlen-1:0] m_axi_gmem_out3_arlen;
  input [BITSIZE_m_axi_gmem_out3_arsize-1:0] m_axi_gmem_out3_arsize;
  input [BITSIZE_m_axi_gmem_out3_arburst-1:0] m_axi_gmem_out3_arburst;
  input [BITSIZE_m_axi_gmem_out3_arlock-1:0] m_axi_gmem_out3_arlock;
  input [BITSIZE_m_axi_gmem_out3_arcache-1:0] m_axi_gmem_out3_arcache;
  input [BITSIZE_m_axi_gmem_out3_arprot-1:0] m_axi_gmem_out3_arprot;
  input [BITSIZE_m_axi_gmem_out3_arqos-1:0] m_axi_gmem_out3_arqos;
  input [BITSIZE_m_axi_gmem_out3_arregion-1:0] m_axi_gmem_out3_arregion;
  input [BITSIZE_m_axi_gmem_out3_aruser-1:0] m_axi_gmem_out3_aruser;
  input m_axi_gmem_out3_arvalid;
  input m_axi_gmem_out3_rready;
  // OUT
  output m_axi_gmem_out3_awready;
  output m_axi_gmem_out3_wready;
  output [BITSIZE_m_axi_gmem_out3_bid-1:0] m_axi_gmem_out3_bid;
  output [BITSIZE_m_axi_gmem_out3_bresp-1:0] m_axi_gmem_out3_bresp;
  output [BITSIZE_m_axi_gmem_out3_buser-1:0] m_axi_gmem_out3_buser;
  output m_axi_gmem_out3_bvalid;
  output m_axi_gmem_out3_arready;
  output [BITSIZE_m_axi_gmem_out3_rid-1:0] m_axi_gmem_out3_rid;
  output [BITSIZE_m_axi_gmem_out3_rdata-1:0] m_axi_gmem_out3_rdata;
  output [BITSIZE_m_axi_gmem_out3_rresp-1:0] m_axi_gmem_out3_rresp;
  output m_axi_gmem_out3_rlast;
  output [BITSIZE_m_axi_gmem_out3_ruser-1:0] m_axi_gmem_out3_ruser;
  output m_axi_gmem_out3_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem_out3_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem_out3_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem_out3_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem_out3_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem_out3_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem_out3_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem_out3_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem_out3_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem_out3_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem_out3_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem_out3_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem_out3_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem_out3_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem_out3_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem_out3_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem_out3_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem_out3_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem_out3_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem_out3_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem_out3_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem_out3_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem_out3_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem_out3_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem_out3_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem_out3_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem_out3_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem_out3_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem_out3_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem_out3_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem_out3_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem_out3_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem_out3_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem_out3_awready=awready;
  assign m_axi_gmem_out3_wready=wready;
  assign m_axi_gmem_out3_bid=bid;
  assign m_axi_gmem_out3_bresp=bresp;
  assign m_axi_gmem_out3_buser=buser;
  assign m_axi_gmem_out3_bvalid=bvalid;
  assign m_axi_gmem_out3_arready=arready;
  assign m_axi_gmem_out3_rid=rid;
  assign m_axi_gmem_out3_rdata=rdata;
  assign m_axi_gmem_out3_rresp=rresp;
  assign m_axi_gmem_out3_rlast=rlast;
  assign m_axi_gmem_out3_ruser=ruser;
  assign m_axi_gmem_out3_rvalid=rvalid;
  assign awid=m_axi_gmem_out3_awid;
  assign awaddr=m_axi_gmem_out3_awaddr;
  assign awlen=m_axi_gmem_out3_awlen;
  assign awsize=m_axi_gmem_out3_awsize;
  assign awburst=m_axi_gmem_out3_awburst;
  assign awlock=m_axi_gmem_out3_awlock;
  assign awcache=m_axi_gmem_out3_awcache;
  assign awprot=m_axi_gmem_out3_awprot;
  assign awqos=m_axi_gmem_out3_awqos;
  assign awregion=m_axi_gmem_out3_awregion;
  assign awuser=m_axi_gmem_out3_awuser;
  assign awvalid=m_axi_gmem_out3_awvalid;
  assign wdata=m_axi_gmem_out3_wdata;
  assign wstrb=m_axi_gmem_out3_wstrb;
  assign wlast=m_axi_gmem_out3_wlast;
  assign wuser=m_axi_gmem_out3_wuser;
  assign wvalid=m_axi_gmem_out3_wvalid;
  assign bready=m_axi_gmem_out3_bready;
  assign arid=m_axi_gmem_out3_arid;
  assign araddr=m_axi_gmem_out3_araddr;
  assign arlen=m_axi_gmem_out3_arlen;
  assign arsize=m_axi_gmem_out3_arsize;
  assign arburst=m_axi_gmem_out3_arburst;
  assign arlock=m_axi_gmem_out3_arlock;
  assign arcache=m_axi_gmem_out3_arcache;
  assign arprot=m_axi_gmem_out3_arprot;
  assign arqos=m_axi_gmem_out3_arqos;
  assign arregion=m_axi_gmem_out3_arregion;
  assign aruser=m_axi_gmem_out3_aruser;
  assign arvalid=m_axi_gmem_out3_arvalid;
  assign rready=m_axi_gmem_out3_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem_out3_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem_out3_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem_out3_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem_out3_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem_out3_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem_out3_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem_out3_arid,
    OFFSET_delay=0,
    OFFSET_counter=OFFSET_delay+BITSIZE_delay,
    OFFSET_burst=OFFSET_counter+BITSIZE_counter,
    OFFSET_len=OFFSET_burst+BITSIZE_burst,
    OFFSET_size=OFFSET_len+BITSIZE_len,
    OFFSET_addr=OFFSET_size+BITSIZE_size,
    OFFSET_id=OFFSET_addr+BITSIZE_addr,
    OFFSET_data=OFFSET_id+BITSIZE_id,
    OFFSET_wstrb=OFFSET_data+BITSIZE_data,
    BITSIZE_aritem=BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay,
    BITSIZE_awitem=BITSIZE_wstrb+BITSIZE_data+BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay;
  
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] arqueue;
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] next_arqueue;
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] awqueue; 
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] next_awqueue;
  reg [31:0] test_addr;
  reg [31:0] test_wstrb;
  reg [31:0] test_data;
  reg [31:0] test_addr_read;
  integer arqueue_size, next_arqueue_size;
  integer awqueue_size, next_awqueue_size;
  
  reg [BITSIZE_id-1:0] awid_reg;
  reg [BITSIZE_addr-1:0] awaddr_reg;
  reg [BITSIZE_size-1:0] awsize_reg;
  reg [BITSIZE_len-1:0] awlen_reg; 
  reg [BITSIZE_burst-1:0] awburst_reg;
  reg [BITSIZE_counter-1:0] counter_reg, counter_next;
  reg write_done;
  reg wlast_reg, wlast_next;
  
  if_utils #(index, BITSIZE_data) m_utils();
  
  initial
  begin
    arqueue = 0;
    arqueue_size = 0;
    next_arqueue = 0;
    next_arqueue_size = 0;
    awqueue = 0;
    awqueue_size = 0;
    next_awqueue = 0;
    next_awqueue_size = 0;
    awready = 0;
    wready = 0;
    bid = 0;
    bresp = 0;
    buser = 0;
    bvalid = 0;
    arready = 0;
    rid = 0;
    rdata = 0;
    rresp = 0;
    rlast = 0;
    ruser = 0;
    rvalid = 0;
    awid_reg = 0;
    awaddr_reg = 0;
    awsize_reg = 0;
    awlen_reg = 0;
    awburst_reg = 0;
  end
  
  // Combinatorial logic for read transactions
  always@(*)
  begin: read_comb
    automatic integer unsigned i;
    next_arqueue = arqueue;
    next_arqueue_size = arqueue_size;
    if(arvalid && arready)  // Valid and ready -> accept new transaction
    begin
      next_arqueue[arqueue_size*BITSIZE_aritem +:BITSIZE_aritem] = {arid, araddr, arsize, arlen, arburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + READ_DELAY)}; // size of parameter is implementation dependent
      next_arqueue_size = arqueue_size + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] = arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1) && rready && rvalid)
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_arqueue[(i-1)*BITSIZE_aritem+:BITSIZE_aritem] = next_arqueue[i*BITSIZE_aritem+:BITSIZE_aritem];
      end
      next_arqueue_size = next_arqueue_size - 1;
    end
    if(next_arqueue_size > 0 && (next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1) && (next_arqueue[OFFSET_counter+:BITSIZE_counter] < (next_arqueue[OFFSET_len+:BITSIZE_len] + 1)))
    begin
      next_arqueue[OFFSET_counter+:BITSIZE_counter] = next_arqueue[OFFSET_counter+:BITSIZE_counter] + 1;
    end
  end
  
  // Combinatorial logic for write transactions
  always@(*) 
  begin: write_comb
    automatic integer i;
    automatic reg [BITSIZE_counter-1:0] counter;
    next_awqueue = awqueue;
    next_awqueue_size = awqueue_size;
    wlast_next = wlast_reg;
    if(awvalid && awready && wready && wvalid) // Valid and ready -> accept new transaction and save data
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid, awaddr, awsize, awlen, awburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
    end
    else if(awvalid && awready && wlast_reg)
    begin
      awid_reg = awid;
      awaddr_reg = awaddr;
      awsize_reg = awsize;
      awlen_reg = awlen; 
      awburst_reg = awburst;
      counter_next = 0;
      wlast_next = 0;
    end
    else if(wready && wvalid)
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid_reg, awaddr_reg, awsize_reg, awlen_reg, awburst_reg, counter_reg, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
      counter_next = counter_reg + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] = awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(write_done && next_awqueue_size > 0 && ((next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len] && bready) || next_awqueue[OFFSET_counter+:BITSIZE_counter] < next_awqueue[OFFSET_len+:BITSIZE_len]))
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_awqueue[(i-1)*BITSIZE_awitem+:BITSIZE_awitem] = next_awqueue[i*BITSIZE_awitem+:BITSIZE_awitem];
      end
      next_awqueue_size = next_awqueue_size - 1;
    end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arready <= 0;
      awready <= 0;
      wready <= 0;
      wlast_reg <= 1;
      counter_reg <= 0;
     end
     else
     begin
      arready <= (next_arqueue_size - (next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= next_arqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE);  //Ready if next_queue_size - rlast < QUEUE_SIZE
      awready <= (wlast_next || wlast) && (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); // ready if next_queue_size - bvalid < QUEUE_SIZE
      wready <= (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); 
      wlast_reg <= wlast_next || wlast;
      counter_reg <= counter_next;
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      rvalid <= 0;
      bvalid <= 0;
     end
     else
     begin
      rvalid <= (next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1); // if at posedge_clock delay is 1 I have to perfrom the operation in this cycle
      bvalid <= (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == (next_awqueue[OFFSET_len+:BITSIZE_len])); // if at posedge_clock delay is 1 I have to perfrom the last operation in this cycle
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arqueue <= 0;
      arqueue_size <= 0;
      awqueue <= 0;
      awqueue_size <= 0;
     end
     else
     begin
      arqueue <= next_arqueue;
      arqueue_size <= next_arqueue_size;
      awqueue <= next_awqueue;
      awqueue_size <= next_awqueue_size;
     end
  end
  
  // Sequential logic for read transactions
  always@(posedge clock)
  begin : read_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    rlast <= 0;
    test_addr_read <= 0;
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1)
    begin
      if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr] + (next_arqueue[OFFSET_counter+:BITSIZE_counter] - 1) * (1 << next_arqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_addr_read <= currAddr;
      rid <= next_arqueue[OFFSET_id+:BITSIZE_id];
      rdata <= m_utils.read_a(currAddr);
      if(next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1))
      begin
        rlast <= 1;
      end
    end
  end
  
  // Sequential logic for write transactions
  always@(posedge clock)
  begin: write_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    test_wstrb <=0;
    test_addr <= 0;
    test_data <= 0;
    write_done <= 0;
    if(next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1) // Performs the first write of the queue
    begin
      if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr] + next_awqueue[OFFSET_counter+:BITSIZE_counter] * (1 << next_awqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_wstrb <= next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb];
      test_addr <= currAddr;
      test_data <= next_awqueue[OFFSET_data+:BITSIZE_data];
      bid <= next_awqueue[OFFSET_id+:BITSIZE_id];
      write_done <= 1;
      void'(m_utils.write_strobe(next_awqueue[OFFSET_data+:BITSIZE_data], next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb], currAddr));
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_m_axi_gmem_out4(clock,
  reset,
  done_port,
  m_axi_gmem_out4_awready,
  m_axi_gmem_out4_wready,
  m_axi_gmem_out4_bid,
  m_axi_gmem_out4_bresp,
  m_axi_gmem_out4_buser,
  m_axi_gmem_out4_bvalid,
  m_axi_gmem_out4_arready,
  m_axi_gmem_out4_rid,
  m_axi_gmem_out4_rdata,
  m_axi_gmem_out4_rresp,
  m_axi_gmem_out4_rlast,
  m_axi_gmem_out4_ruser,
  m_axi_gmem_out4_rvalid,
  m_axi_gmem_out4_awid,
  m_axi_gmem_out4_awaddr,
  m_axi_gmem_out4_awlen,
  m_axi_gmem_out4_awsize,
  m_axi_gmem_out4_awburst,
  m_axi_gmem_out4_awlock,
  m_axi_gmem_out4_awcache,
  m_axi_gmem_out4_awprot,
  m_axi_gmem_out4_awqos,
  m_axi_gmem_out4_awregion,
  m_axi_gmem_out4_awuser,
  m_axi_gmem_out4_awvalid,
  m_axi_gmem_out4_wdata,
  m_axi_gmem_out4_wstrb,
  m_axi_gmem_out4_wlast,
  m_axi_gmem_out4_wuser,
  m_axi_gmem_out4_wvalid,
  m_axi_gmem_out4_bready,
  m_axi_gmem_out4_arid,
  m_axi_gmem_out4_araddr,
  m_axi_gmem_out4_arlen,
  m_axi_gmem_out4_arsize,
  m_axi_gmem_out4_arburst,
  m_axi_gmem_out4_arlock,
  m_axi_gmem_out4_arcache,
  m_axi_gmem_out4_arprot,
  m_axi_gmem_out4_arqos,
  m_axi_gmem_out4_arregion,
  m_axi_gmem_out4_aruser,
  m_axi_gmem_out4_arvalid,
  m_axi_gmem_out4_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem_out4_bid=1,
    BITSIZE_m_axi_gmem_out4_bresp=2,
    BITSIZE_m_axi_gmem_out4_buser=1,
    BITSIZE_m_axi_gmem_out4_rid=1,
    BITSIZE_m_axi_gmem_out4_rdata=1,
    BITSIZE_m_axi_gmem_out4_rresp=2,
    BITSIZE_m_axi_gmem_out4_ruser=1,
    BITSIZE_m_axi_gmem_out4_awid=1,
    BITSIZE_m_axi_gmem_out4_awaddr=1,
    BITSIZE_m_axi_gmem_out4_awlen=1,
    BITSIZE_m_axi_gmem_out4_awsize=1,
    BITSIZE_m_axi_gmem_out4_awburst=2,
    BITSIZE_m_axi_gmem_out4_awlock=1,
    BITSIZE_m_axi_gmem_out4_awcache=1,
    BITSIZE_m_axi_gmem_out4_awprot=1,
    BITSIZE_m_axi_gmem_out4_awqos=1,
    BITSIZE_m_axi_gmem_out4_awregion=1,
    BITSIZE_m_axi_gmem_out4_awuser=1,
    BITSIZE_m_axi_gmem_out4_wdata=1,
    BITSIZE_m_axi_gmem_out4_wstrb=1,
    BITSIZE_m_axi_gmem_out4_wuser=1,
    BITSIZE_m_axi_gmem_out4_arid=1,
    BITSIZE_m_axi_gmem_out4_araddr=1,
    BITSIZE_m_axi_gmem_out4_arlen=1,
    BITSIZE_m_axi_gmem_out4_arsize=1,
    BITSIZE_m_axi_gmem_out4_arburst=2,
    BITSIZE_m_axi_gmem_out4_arlock=1,
    BITSIZE_m_axi_gmem_out4_arcache=1,
    BITSIZE_m_axi_gmem_out4_arprot=1,
    BITSIZE_m_axi_gmem_out4_arqos=1,
    BITSIZE_m_axi_gmem_out4_arregion=1,
    BITSIZE_m_axi_gmem_out4_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem_out4_awid-1:0] m_axi_gmem_out4_awid;
  input [BITSIZE_m_axi_gmem_out4_awaddr-1:0] m_axi_gmem_out4_awaddr;
  input [BITSIZE_m_axi_gmem_out4_awlen-1:0] m_axi_gmem_out4_awlen;
  input [BITSIZE_m_axi_gmem_out4_awsize-1:0] m_axi_gmem_out4_awsize;
  input [BITSIZE_m_axi_gmem_out4_awburst-1:0] m_axi_gmem_out4_awburst;
  input [BITSIZE_m_axi_gmem_out4_awlock-1:0] m_axi_gmem_out4_awlock;
  input [BITSIZE_m_axi_gmem_out4_awcache-1:0] m_axi_gmem_out4_awcache;
  input [BITSIZE_m_axi_gmem_out4_awprot-1:0] m_axi_gmem_out4_awprot;
  input [BITSIZE_m_axi_gmem_out4_awqos-1:0] m_axi_gmem_out4_awqos;
  input [BITSIZE_m_axi_gmem_out4_awregion-1:0] m_axi_gmem_out4_awregion;
  input [BITSIZE_m_axi_gmem_out4_awuser-1:0] m_axi_gmem_out4_awuser;
  input m_axi_gmem_out4_awvalid;
  input [BITSIZE_m_axi_gmem_out4_wdata-1:0] m_axi_gmem_out4_wdata;
  input [BITSIZE_m_axi_gmem_out4_wstrb-1:0] m_axi_gmem_out4_wstrb;
  input m_axi_gmem_out4_wlast;
  input [BITSIZE_m_axi_gmem_out4_wuser-1:0] m_axi_gmem_out4_wuser;
  input m_axi_gmem_out4_wvalid;
  input m_axi_gmem_out4_bready;
  input [BITSIZE_m_axi_gmem_out4_arid-1:0] m_axi_gmem_out4_arid;
  input [BITSIZE_m_axi_gmem_out4_araddr-1:0] m_axi_gmem_out4_araddr;
  input [BITSIZE_m_axi_gmem_out4_arlen-1:0] m_axi_gmem_out4_arlen;
  input [BITSIZE_m_axi_gmem_out4_arsize-1:0] m_axi_gmem_out4_arsize;
  input [BITSIZE_m_axi_gmem_out4_arburst-1:0] m_axi_gmem_out4_arburst;
  input [BITSIZE_m_axi_gmem_out4_arlock-1:0] m_axi_gmem_out4_arlock;
  input [BITSIZE_m_axi_gmem_out4_arcache-1:0] m_axi_gmem_out4_arcache;
  input [BITSIZE_m_axi_gmem_out4_arprot-1:0] m_axi_gmem_out4_arprot;
  input [BITSIZE_m_axi_gmem_out4_arqos-1:0] m_axi_gmem_out4_arqos;
  input [BITSIZE_m_axi_gmem_out4_arregion-1:0] m_axi_gmem_out4_arregion;
  input [BITSIZE_m_axi_gmem_out4_aruser-1:0] m_axi_gmem_out4_aruser;
  input m_axi_gmem_out4_arvalid;
  input m_axi_gmem_out4_rready;
  // OUT
  output m_axi_gmem_out4_awready;
  output m_axi_gmem_out4_wready;
  output [BITSIZE_m_axi_gmem_out4_bid-1:0] m_axi_gmem_out4_bid;
  output [BITSIZE_m_axi_gmem_out4_bresp-1:0] m_axi_gmem_out4_bresp;
  output [BITSIZE_m_axi_gmem_out4_buser-1:0] m_axi_gmem_out4_buser;
  output m_axi_gmem_out4_bvalid;
  output m_axi_gmem_out4_arready;
  output [BITSIZE_m_axi_gmem_out4_rid-1:0] m_axi_gmem_out4_rid;
  output [BITSIZE_m_axi_gmem_out4_rdata-1:0] m_axi_gmem_out4_rdata;
  output [BITSIZE_m_axi_gmem_out4_rresp-1:0] m_axi_gmem_out4_rresp;
  output m_axi_gmem_out4_rlast;
  output [BITSIZE_m_axi_gmem_out4_ruser-1:0] m_axi_gmem_out4_ruser;
  output m_axi_gmem_out4_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem_out4_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem_out4_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem_out4_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem_out4_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem_out4_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem_out4_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem_out4_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem_out4_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem_out4_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem_out4_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem_out4_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem_out4_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem_out4_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem_out4_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem_out4_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem_out4_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem_out4_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem_out4_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem_out4_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem_out4_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem_out4_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem_out4_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem_out4_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem_out4_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem_out4_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem_out4_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem_out4_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem_out4_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem_out4_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem_out4_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem_out4_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem_out4_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem_out4_awready=awready;
  assign m_axi_gmem_out4_wready=wready;
  assign m_axi_gmem_out4_bid=bid;
  assign m_axi_gmem_out4_bresp=bresp;
  assign m_axi_gmem_out4_buser=buser;
  assign m_axi_gmem_out4_bvalid=bvalid;
  assign m_axi_gmem_out4_arready=arready;
  assign m_axi_gmem_out4_rid=rid;
  assign m_axi_gmem_out4_rdata=rdata;
  assign m_axi_gmem_out4_rresp=rresp;
  assign m_axi_gmem_out4_rlast=rlast;
  assign m_axi_gmem_out4_ruser=ruser;
  assign m_axi_gmem_out4_rvalid=rvalid;
  assign awid=m_axi_gmem_out4_awid;
  assign awaddr=m_axi_gmem_out4_awaddr;
  assign awlen=m_axi_gmem_out4_awlen;
  assign awsize=m_axi_gmem_out4_awsize;
  assign awburst=m_axi_gmem_out4_awburst;
  assign awlock=m_axi_gmem_out4_awlock;
  assign awcache=m_axi_gmem_out4_awcache;
  assign awprot=m_axi_gmem_out4_awprot;
  assign awqos=m_axi_gmem_out4_awqos;
  assign awregion=m_axi_gmem_out4_awregion;
  assign awuser=m_axi_gmem_out4_awuser;
  assign awvalid=m_axi_gmem_out4_awvalid;
  assign wdata=m_axi_gmem_out4_wdata;
  assign wstrb=m_axi_gmem_out4_wstrb;
  assign wlast=m_axi_gmem_out4_wlast;
  assign wuser=m_axi_gmem_out4_wuser;
  assign wvalid=m_axi_gmem_out4_wvalid;
  assign bready=m_axi_gmem_out4_bready;
  assign arid=m_axi_gmem_out4_arid;
  assign araddr=m_axi_gmem_out4_araddr;
  assign arlen=m_axi_gmem_out4_arlen;
  assign arsize=m_axi_gmem_out4_arsize;
  assign arburst=m_axi_gmem_out4_arburst;
  assign arlock=m_axi_gmem_out4_arlock;
  assign arcache=m_axi_gmem_out4_arcache;
  assign arprot=m_axi_gmem_out4_arprot;
  assign arqos=m_axi_gmem_out4_arqos;
  assign arregion=m_axi_gmem_out4_arregion;
  assign aruser=m_axi_gmem_out4_aruser;
  assign arvalid=m_axi_gmem_out4_arvalid;
  assign rready=m_axi_gmem_out4_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem_out4_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem_out4_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem_out4_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem_out4_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem_out4_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem_out4_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem_out4_arid,
    OFFSET_delay=0,
    OFFSET_counter=OFFSET_delay+BITSIZE_delay,
    OFFSET_burst=OFFSET_counter+BITSIZE_counter,
    OFFSET_len=OFFSET_burst+BITSIZE_burst,
    OFFSET_size=OFFSET_len+BITSIZE_len,
    OFFSET_addr=OFFSET_size+BITSIZE_size,
    OFFSET_id=OFFSET_addr+BITSIZE_addr,
    OFFSET_data=OFFSET_id+BITSIZE_id,
    OFFSET_wstrb=OFFSET_data+BITSIZE_data,
    BITSIZE_aritem=BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay,
    BITSIZE_awitem=BITSIZE_wstrb+BITSIZE_data+BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay;
  
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] arqueue;
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] next_arqueue;
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] awqueue; 
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] next_awqueue;
  reg [31:0] test_addr;
  reg [31:0] test_wstrb;
  reg [31:0] test_data;
  reg [31:0] test_addr_read;
  integer arqueue_size, next_arqueue_size;
  integer awqueue_size, next_awqueue_size;
  
  reg [BITSIZE_id-1:0] awid_reg;
  reg [BITSIZE_addr-1:0] awaddr_reg;
  reg [BITSIZE_size-1:0] awsize_reg;
  reg [BITSIZE_len-1:0] awlen_reg; 
  reg [BITSIZE_burst-1:0] awburst_reg;
  reg [BITSIZE_counter-1:0] counter_reg, counter_next;
  reg write_done;
  reg wlast_reg, wlast_next;
  
  if_utils #(index, BITSIZE_data) m_utils();
  
  initial
  begin
    arqueue = 0;
    arqueue_size = 0;
    next_arqueue = 0;
    next_arqueue_size = 0;
    awqueue = 0;
    awqueue_size = 0;
    next_awqueue = 0;
    next_awqueue_size = 0;
    awready = 0;
    wready = 0;
    bid = 0;
    bresp = 0;
    buser = 0;
    bvalid = 0;
    arready = 0;
    rid = 0;
    rdata = 0;
    rresp = 0;
    rlast = 0;
    ruser = 0;
    rvalid = 0;
    awid_reg = 0;
    awaddr_reg = 0;
    awsize_reg = 0;
    awlen_reg = 0;
    awburst_reg = 0;
  end
  
  // Combinatorial logic for read transactions
  always@(*)
  begin: read_comb
    automatic integer unsigned i;
    next_arqueue = arqueue;
    next_arqueue_size = arqueue_size;
    if(arvalid && arready)  // Valid and ready -> accept new transaction
    begin
      next_arqueue[arqueue_size*BITSIZE_aritem +:BITSIZE_aritem] = {arid, araddr, arsize, arlen, arburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + READ_DELAY)}; // size of parameter is implementation dependent
      next_arqueue_size = arqueue_size + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] = arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1) && rready && rvalid)
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_arqueue[(i-1)*BITSIZE_aritem+:BITSIZE_aritem] = next_arqueue[i*BITSIZE_aritem+:BITSIZE_aritem];
      end
      next_arqueue_size = next_arqueue_size - 1;
    end
    if(next_arqueue_size > 0 && (next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1) && (next_arqueue[OFFSET_counter+:BITSIZE_counter] < (next_arqueue[OFFSET_len+:BITSIZE_len] + 1)))
    begin
      next_arqueue[OFFSET_counter+:BITSIZE_counter] = next_arqueue[OFFSET_counter+:BITSIZE_counter] + 1;
    end
  end
  
  // Combinatorial logic for write transactions
  always@(*) 
  begin: write_comb
    automatic integer i;
    automatic reg [BITSIZE_counter-1:0] counter;
    next_awqueue = awqueue;
    next_awqueue_size = awqueue_size;
    wlast_next = wlast_reg;
    if(awvalid && awready && wready && wvalid) // Valid and ready -> accept new transaction and save data
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid, awaddr, awsize, awlen, awburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
    end
    else if(awvalid && awready && wlast_reg)
    begin
      awid_reg = awid;
      awaddr_reg = awaddr;
      awsize_reg = awsize;
      awlen_reg = awlen; 
      awburst_reg = awburst;
      counter_next = 0;
      wlast_next = 0;
    end
    else if(wready && wvalid)
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid_reg, awaddr_reg, awsize_reg, awlen_reg, awburst_reg, counter_reg, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
      counter_next = counter_reg + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] = awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(write_done && next_awqueue_size > 0 && ((next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len] && bready) || next_awqueue[OFFSET_counter+:BITSIZE_counter] < next_awqueue[OFFSET_len+:BITSIZE_len]))
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_awqueue[(i-1)*BITSIZE_awitem+:BITSIZE_awitem] = next_awqueue[i*BITSIZE_awitem+:BITSIZE_awitem];
      end
      next_awqueue_size = next_awqueue_size - 1;
    end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arready <= 0;
      awready <= 0;
      wready <= 0;
      wlast_reg <= 1;
      counter_reg <= 0;
     end
     else
     begin
      arready <= (next_arqueue_size - (next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= next_arqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE);  //Ready if next_queue_size - rlast < QUEUE_SIZE
      awready <= (wlast_next || wlast) && (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); // ready if next_queue_size - bvalid < QUEUE_SIZE
      wready <= (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); 
      wlast_reg <= wlast_next || wlast;
      counter_reg <= counter_next;
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      rvalid <= 0;
      bvalid <= 0;
     end
     else
     begin
      rvalid <= (next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1); // if at posedge_clock delay is 1 I have to perfrom the operation in this cycle
      bvalid <= (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == (next_awqueue[OFFSET_len+:BITSIZE_len])); // if at posedge_clock delay is 1 I have to perfrom the last operation in this cycle
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arqueue <= 0;
      arqueue_size <= 0;
      awqueue <= 0;
      awqueue_size <= 0;
     end
     else
     begin
      arqueue <= next_arqueue;
      arqueue_size <= next_arqueue_size;
      awqueue <= next_awqueue;
      awqueue_size <= next_awqueue_size;
     end
  end
  
  // Sequential logic for read transactions
  always@(posedge clock)
  begin : read_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    rlast <= 0;
    test_addr_read <= 0;
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1)
    begin
      if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr] + (next_arqueue[OFFSET_counter+:BITSIZE_counter] - 1) * (1 << next_arqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_addr_read <= currAddr;
      rid <= next_arqueue[OFFSET_id+:BITSIZE_id];
      rdata <= m_utils.read_a(currAddr);
      if(next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1))
      begin
        rlast <= 1;
      end
    end
  end
  
  // Sequential logic for write transactions
  always@(posedge clock)
  begin: write_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    test_wstrb <=0;
    test_addr <= 0;
    test_data <= 0;
    write_done <= 0;
    if(next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1) // Performs the first write of the queue
    begin
      if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr] + next_awqueue[OFFSET_counter+:BITSIZE_counter] * (1 << next_awqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_wstrb <= next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb];
      test_addr <= currAddr;
      test_data <= next_awqueue[OFFSET_data+:BITSIZE_data];
      bid <= next_awqueue[OFFSET_id+:BITSIZE_id];
      write_done <= 1;
      void'(m_utils.write_strobe(next_awqueue[OFFSET_data+:BITSIZE_data], next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb], currAddr));
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_m_axi_gmem_out5(clock,
  reset,
  done_port,
  m_axi_gmem_out5_awready,
  m_axi_gmem_out5_wready,
  m_axi_gmem_out5_bid,
  m_axi_gmem_out5_bresp,
  m_axi_gmem_out5_buser,
  m_axi_gmem_out5_bvalid,
  m_axi_gmem_out5_arready,
  m_axi_gmem_out5_rid,
  m_axi_gmem_out5_rdata,
  m_axi_gmem_out5_rresp,
  m_axi_gmem_out5_rlast,
  m_axi_gmem_out5_ruser,
  m_axi_gmem_out5_rvalid,
  m_axi_gmem_out5_awid,
  m_axi_gmem_out5_awaddr,
  m_axi_gmem_out5_awlen,
  m_axi_gmem_out5_awsize,
  m_axi_gmem_out5_awburst,
  m_axi_gmem_out5_awlock,
  m_axi_gmem_out5_awcache,
  m_axi_gmem_out5_awprot,
  m_axi_gmem_out5_awqos,
  m_axi_gmem_out5_awregion,
  m_axi_gmem_out5_awuser,
  m_axi_gmem_out5_awvalid,
  m_axi_gmem_out5_wdata,
  m_axi_gmem_out5_wstrb,
  m_axi_gmem_out5_wlast,
  m_axi_gmem_out5_wuser,
  m_axi_gmem_out5_wvalid,
  m_axi_gmem_out5_bready,
  m_axi_gmem_out5_arid,
  m_axi_gmem_out5_araddr,
  m_axi_gmem_out5_arlen,
  m_axi_gmem_out5_arsize,
  m_axi_gmem_out5_arburst,
  m_axi_gmem_out5_arlock,
  m_axi_gmem_out5_arcache,
  m_axi_gmem_out5_arprot,
  m_axi_gmem_out5_arqos,
  m_axi_gmem_out5_arregion,
  m_axi_gmem_out5_aruser,
  m_axi_gmem_out5_arvalid,
  m_axi_gmem_out5_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem_out5_bid=1,
    BITSIZE_m_axi_gmem_out5_bresp=2,
    BITSIZE_m_axi_gmem_out5_buser=1,
    BITSIZE_m_axi_gmem_out5_rid=1,
    BITSIZE_m_axi_gmem_out5_rdata=1,
    BITSIZE_m_axi_gmem_out5_rresp=2,
    BITSIZE_m_axi_gmem_out5_ruser=1,
    BITSIZE_m_axi_gmem_out5_awid=1,
    BITSIZE_m_axi_gmem_out5_awaddr=1,
    BITSIZE_m_axi_gmem_out5_awlen=1,
    BITSIZE_m_axi_gmem_out5_awsize=1,
    BITSIZE_m_axi_gmem_out5_awburst=2,
    BITSIZE_m_axi_gmem_out5_awlock=1,
    BITSIZE_m_axi_gmem_out5_awcache=1,
    BITSIZE_m_axi_gmem_out5_awprot=1,
    BITSIZE_m_axi_gmem_out5_awqos=1,
    BITSIZE_m_axi_gmem_out5_awregion=1,
    BITSIZE_m_axi_gmem_out5_awuser=1,
    BITSIZE_m_axi_gmem_out5_wdata=1,
    BITSIZE_m_axi_gmem_out5_wstrb=1,
    BITSIZE_m_axi_gmem_out5_wuser=1,
    BITSIZE_m_axi_gmem_out5_arid=1,
    BITSIZE_m_axi_gmem_out5_araddr=1,
    BITSIZE_m_axi_gmem_out5_arlen=1,
    BITSIZE_m_axi_gmem_out5_arsize=1,
    BITSIZE_m_axi_gmem_out5_arburst=2,
    BITSIZE_m_axi_gmem_out5_arlock=1,
    BITSIZE_m_axi_gmem_out5_arcache=1,
    BITSIZE_m_axi_gmem_out5_arprot=1,
    BITSIZE_m_axi_gmem_out5_arqos=1,
    BITSIZE_m_axi_gmem_out5_arregion=1,
    BITSIZE_m_axi_gmem_out5_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem_out5_awid-1:0] m_axi_gmem_out5_awid;
  input [BITSIZE_m_axi_gmem_out5_awaddr-1:0] m_axi_gmem_out5_awaddr;
  input [BITSIZE_m_axi_gmem_out5_awlen-1:0] m_axi_gmem_out5_awlen;
  input [BITSIZE_m_axi_gmem_out5_awsize-1:0] m_axi_gmem_out5_awsize;
  input [BITSIZE_m_axi_gmem_out5_awburst-1:0] m_axi_gmem_out5_awburst;
  input [BITSIZE_m_axi_gmem_out5_awlock-1:0] m_axi_gmem_out5_awlock;
  input [BITSIZE_m_axi_gmem_out5_awcache-1:0] m_axi_gmem_out5_awcache;
  input [BITSIZE_m_axi_gmem_out5_awprot-1:0] m_axi_gmem_out5_awprot;
  input [BITSIZE_m_axi_gmem_out5_awqos-1:0] m_axi_gmem_out5_awqos;
  input [BITSIZE_m_axi_gmem_out5_awregion-1:0] m_axi_gmem_out5_awregion;
  input [BITSIZE_m_axi_gmem_out5_awuser-1:0] m_axi_gmem_out5_awuser;
  input m_axi_gmem_out5_awvalid;
  input [BITSIZE_m_axi_gmem_out5_wdata-1:0] m_axi_gmem_out5_wdata;
  input [BITSIZE_m_axi_gmem_out5_wstrb-1:0] m_axi_gmem_out5_wstrb;
  input m_axi_gmem_out5_wlast;
  input [BITSIZE_m_axi_gmem_out5_wuser-1:0] m_axi_gmem_out5_wuser;
  input m_axi_gmem_out5_wvalid;
  input m_axi_gmem_out5_bready;
  input [BITSIZE_m_axi_gmem_out5_arid-1:0] m_axi_gmem_out5_arid;
  input [BITSIZE_m_axi_gmem_out5_araddr-1:0] m_axi_gmem_out5_araddr;
  input [BITSIZE_m_axi_gmem_out5_arlen-1:0] m_axi_gmem_out5_arlen;
  input [BITSIZE_m_axi_gmem_out5_arsize-1:0] m_axi_gmem_out5_arsize;
  input [BITSIZE_m_axi_gmem_out5_arburst-1:0] m_axi_gmem_out5_arburst;
  input [BITSIZE_m_axi_gmem_out5_arlock-1:0] m_axi_gmem_out5_arlock;
  input [BITSIZE_m_axi_gmem_out5_arcache-1:0] m_axi_gmem_out5_arcache;
  input [BITSIZE_m_axi_gmem_out5_arprot-1:0] m_axi_gmem_out5_arprot;
  input [BITSIZE_m_axi_gmem_out5_arqos-1:0] m_axi_gmem_out5_arqos;
  input [BITSIZE_m_axi_gmem_out5_arregion-1:0] m_axi_gmem_out5_arregion;
  input [BITSIZE_m_axi_gmem_out5_aruser-1:0] m_axi_gmem_out5_aruser;
  input m_axi_gmem_out5_arvalid;
  input m_axi_gmem_out5_rready;
  // OUT
  output m_axi_gmem_out5_awready;
  output m_axi_gmem_out5_wready;
  output [BITSIZE_m_axi_gmem_out5_bid-1:0] m_axi_gmem_out5_bid;
  output [BITSIZE_m_axi_gmem_out5_bresp-1:0] m_axi_gmem_out5_bresp;
  output [BITSIZE_m_axi_gmem_out5_buser-1:0] m_axi_gmem_out5_buser;
  output m_axi_gmem_out5_bvalid;
  output m_axi_gmem_out5_arready;
  output [BITSIZE_m_axi_gmem_out5_rid-1:0] m_axi_gmem_out5_rid;
  output [BITSIZE_m_axi_gmem_out5_rdata-1:0] m_axi_gmem_out5_rdata;
  output [BITSIZE_m_axi_gmem_out5_rresp-1:0] m_axi_gmem_out5_rresp;
  output m_axi_gmem_out5_rlast;
  output [BITSIZE_m_axi_gmem_out5_ruser-1:0] m_axi_gmem_out5_ruser;
  output m_axi_gmem_out5_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem_out5_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem_out5_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem_out5_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem_out5_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem_out5_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem_out5_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem_out5_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem_out5_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem_out5_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem_out5_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem_out5_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem_out5_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem_out5_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem_out5_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem_out5_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem_out5_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem_out5_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem_out5_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem_out5_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem_out5_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem_out5_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem_out5_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem_out5_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem_out5_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem_out5_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem_out5_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem_out5_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem_out5_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem_out5_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem_out5_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem_out5_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem_out5_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem_out5_awready=awready;
  assign m_axi_gmem_out5_wready=wready;
  assign m_axi_gmem_out5_bid=bid;
  assign m_axi_gmem_out5_bresp=bresp;
  assign m_axi_gmem_out5_buser=buser;
  assign m_axi_gmem_out5_bvalid=bvalid;
  assign m_axi_gmem_out5_arready=arready;
  assign m_axi_gmem_out5_rid=rid;
  assign m_axi_gmem_out5_rdata=rdata;
  assign m_axi_gmem_out5_rresp=rresp;
  assign m_axi_gmem_out5_rlast=rlast;
  assign m_axi_gmem_out5_ruser=ruser;
  assign m_axi_gmem_out5_rvalid=rvalid;
  assign awid=m_axi_gmem_out5_awid;
  assign awaddr=m_axi_gmem_out5_awaddr;
  assign awlen=m_axi_gmem_out5_awlen;
  assign awsize=m_axi_gmem_out5_awsize;
  assign awburst=m_axi_gmem_out5_awburst;
  assign awlock=m_axi_gmem_out5_awlock;
  assign awcache=m_axi_gmem_out5_awcache;
  assign awprot=m_axi_gmem_out5_awprot;
  assign awqos=m_axi_gmem_out5_awqos;
  assign awregion=m_axi_gmem_out5_awregion;
  assign awuser=m_axi_gmem_out5_awuser;
  assign awvalid=m_axi_gmem_out5_awvalid;
  assign wdata=m_axi_gmem_out5_wdata;
  assign wstrb=m_axi_gmem_out5_wstrb;
  assign wlast=m_axi_gmem_out5_wlast;
  assign wuser=m_axi_gmem_out5_wuser;
  assign wvalid=m_axi_gmem_out5_wvalid;
  assign bready=m_axi_gmem_out5_bready;
  assign arid=m_axi_gmem_out5_arid;
  assign araddr=m_axi_gmem_out5_araddr;
  assign arlen=m_axi_gmem_out5_arlen;
  assign arsize=m_axi_gmem_out5_arsize;
  assign arburst=m_axi_gmem_out5_arburst;
  assign arlock=m_axi_gmem_out5_arlock;
  assign arcache=m_axi_gmem_out5_arcache;
  assign arprot=m_axi_gmem_out5_arprot;
  assign arqos=m_axi_gmem_out5_arqos;
  assign arregion=m_axi_gmem_out5_arregion;
  assign aruser=m_axi_gmem_out5_aruser;
  assign arvalid=m_axi_gmem_out5_arvalid;
  assign rready=m_axi_gmem_out5_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem_out5_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem_out5_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem_out5_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem_out5_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem_out5_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem_out5_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem_out5_arid,
    OFFSET_delay=0,
    OFFSET_counter=OFFSET_delay+BITSIZE_delay,
    OFFSET_burst=OFFSET_counter+BITSIZE_counter,
    OFFSET_len=OFFSET_burst+BITSIZE_burst,
    OFFSET_size=OFFSET_len+BITSIZE_len,
    OFFSET_addr=OFFSET_size+BITSIZE_size,
    OFFSET_id=OFFSET_addr+BITSIZE_addr,
    OFFSET_data=OFFSET_id+BITSIZE_id,
    OFFSET_wstrb=OFFSET_data+BITSIZE_data,
    BITSIZE_aritem=BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay,
    BITSIZE_awitem=BITSIZE_wstrb+BITSIZE_data+BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay;
  
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] arqueue;
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] next_arqueue;
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] awqueue; 
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] next_awqueue;
  reg [31:0] test_addr;
  reg [31:0] test_wstrb;
  reg [31:0] test_data;
  reg [31:0] test_addr_read;
  integer arqueue_size, next_arqueue_size;
  integer awqueue_size, next_awqueue_size;
  
  reg [BITSIZE_id-1:0] awid_reg;
  reg [BITSIZE_addr-1:0] awaddr_reg;
  reg [BITSIZE_size-1:0] awsize_reg;
  reg [BITSIZE_len-1:0] awlen_reg; 
  reg [BITSIZE_burst-1:0] awburst_reg;
  reg [BITSIZE_counter-1:0] counter_reg, counter_next;
  reg write_done;
  reg wlast_reg, wlast_next;
  
  if_utils #(index, BITSIZE_data) m_utils();
  
  initial
  begin
    arqueue = 0;
    arqueue_size = 0;
    next_arqueue = 0;
    next_arqueue_size = 0;
    awqueue = 0;
    awqueue_size = 0;
    next_awqueue = 0;
    next_awqueue_size = 0;
    awready = 0;
    wready = 0;
    bid = 0;
    bresp = 0;
    buser = 0;
    bvalid = 0;
    arready = 0;
    rid = 0;
    rdata = 0;
    rresp = 0;
    rlast = 0;
    ruser = 0;
    rvalid = 0;
    awid_reg = 0;
    awaddr_reg = 0;
    awsize_reg = 0;
    awlen_reg = 0;
    awburst_reg = 0;
  end
  
  // Combinatorial logic for read transactions
  always@(*)
  begin: read_comb
    automatic integer unsigned i;
    next_arqueue = arqueue;
    next_arqueue_size = arqueue_size;
    if(arvalid && arready)  // Valid and ready -> accept new transaction
    begin
      next_arqueue[arqueue_size*BITSIZE_aritem +:BITSIZE_aritem] = {arid, araddr, arsize, arlen, arburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + READ_DELAY)}; // size of parameter is implementation dependent
      next_arqueue_size = arqueue_size + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] = arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1) && rready && rvalid)
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_arqueue[(i-1)*BITSIZE_aritem+:BITSIZE_aritem] = next_arqueue[i*BITSIZE_aritem+:BITSIZE_aritem];
      end
      next_arqueue_size = next_arqueue_size - 1;
    end
    if(next_arqueue_size > 0 && (next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1) && (next_arqueue[OFFSET_counter+:BITSIZE_counter] < (next_arqueue[OFFSET_len+:BITSIZE_len] + 1)))
    begin
      next_arqueue[OFFSET_counter+:BITSIZE_counter] = next_arqueue[OFFSET_counter+:BITSIZE_counter] + 1;
    end
  end
  
  // Combinatorial logic for write transactions
  always@(*) 
  begin: write_comb
    automatic integer i;
    automatic reg [BITSIZE_counter-1:0] counter;
    next_awqueue = awqueue;
    next_awqueue_size = awqueue_size;
    wlast_next = wlast_reg;
    if(awvalid && awready && wready && wvalid) // Valid and ready -> accept new transaction and save data
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid, awaddr, awsize, awlen, awburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
    end
    else if(awvalid && awready && wlast_reg)
    begin
      awid_reg = awid;
      awaddr_reg = awaddr;
      awsize_reg = awsize;
      awlen_reg = awlen; 
      awburst_reg = awburst;
      counter_next = 0;
      wlast_next = 0;
    end
    else if(wready && wvalid)
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid_reg, awaddr_reg, awsize_reg, awlen_reg, awburst_reg, counter_reg, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
      counter_next = counter_reg + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] = awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(write_done && next_awqueue_size > 0 && ((next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len] && bready) || next_awqueue[OFFSET_counter+:BITSIZE_counter] < next_awqueue[OFFSET_len+:BITSIZE_len]))
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_awqueue[(i-1)*BITSIZE_awitem+:BITSIZE_awitem] = next_awqueue[i*BITSIZE_awitem+:BITSIZE_awitem];
      end
      next_awqueue_size = next_awqueue_size - 1;
    end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arready <= 0;
      awready <= 0;
      wready <= 0;
      wlast_reg <= 1;
      counter_reg <= 0;
     end
     else
     begin
      arready <= (next_arqueue_size - (next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= next_arqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE);  //Ready if next_queue_size - rlast < QUEUE_SIZE
      awready <= (wlast_next || wlast) && (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); // ready if next_queue_size - bvalid < QUEUE_SIZE
      wready <= (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); 
      wlast_reg <= wlast_next || wlast;
      counter_reg <= counter_next;
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      rvalid <= 0;
      bvalid <= 0;
     end
     else
     begin
      rvalid <= (next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1); // if at posedge_clock delay is 1 I have to perfrom the operation in this cycle
      bvalid <= (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == (next_awqueue[OFFSET_len+:BITSIZE_len])); // if at posedge_clock delay is 1 I have to perfrom the last operation in this cycle
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arqueue <= 0;
      arqueue_size <= 0;
      awqueue <= 0;
      awqueue_size <= 0;
     end
     else
     begin
      arqueue <= next_arqueue;
      arqueue_size <= next_arqueue_size;
      awqueue <= next_awqueue;
      awqueue_size <= next_awqueue_size;
     end
  end
  
  // Sequential logic for read transactions
  always@(posedge clock)
  begin : read_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    rlast <= 0;
    test_addr_read <= 0;
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1)
    begin
      if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr] + (next_arqueue[OFFSET_counter+:BITSIZE_counter] - 1) * (1 << next_arqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_addr_read <= currAddr;
      rid <= next_arqueue[OFFSET_id+:BITSIZE_id];
      rdata <= m_utils.read_a(currAddr);
      if(next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1))
      begin
        rlast <= 1;
      end
    end
  end
  
  // Sequential logic for write transactions
  always@(posedge clock)
  begin: write_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    test_wstrb <=0;
    test_addr <= 0;
    test_data <= 0;
    write_done <= 0;
    if(next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1) // Performs the first write of the queue
    begin
      if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr] + next_awqueue[OFFSET_counter+:BITSIZE_counter] * (1 << next_awqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_wstrb <= next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb];
      test_addr <= currAddr;
      test_data <= next_awqueue[OFFSET_data+:BITSIZE_data];
      bid <= next_awqueue[OFFSET_id+:BITSIZE_id];
      write_done <= 1;
      void'(m_utils.write_strobe(next_awqueue[OFFSET_data+:BITSIZE_data], next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb], currAddr));
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_m_axi_gmem_out6(clock,
  reset,
  done_port,
  m_axi_gmem_out6_awready,
  m_axi_gmem_out6_wready,
  m_axi_gmem_out6_bid,
  m_axi_gmem_out6_bresp,
  m_axi_gmem_out6_buser,
  m_axi_gmem_out6_bvalid,
  m_axi_gmem_out6_arready,
  m_axi_gmem_out6_rid,
  m_axi_gmem_out6_rdata,
  m_axi_gmem_out6_rresp,
  m_axi_gmem_out6_rlast,
  m_axi_gmem_out6_ruser,
  m_axi_gmem_out6_rvalid,
  m_axi_gmem_out6_awid,
  m_axi_gmem_out6_awaddr,
  m_axi_gmem_out6_awlen,
  m_axi_gmem_out6_awsize,
  m_axi_gmem_out6_awburst,
  m_axi_gmem_out6_awlock,
  m_axi_gmem_out6_awcache,
  m_axi_gmem_out6_awprot,
  m_axi_gmem_out6_awqos,
  m_axi_gmem_out6_awregion,
  m_axi_gmem_out6_awuser,
  m_axi_gmem_out6_awvalid,
  m_axi_gmem_out6_wdata,
  m_axi_gmem_out6_wstrb,
  m_axi_gmem_out6_wlast,
  m_axi_gmem_out6_wuser,
  m_axi_gmem_out6_wvalid,
  m_axi_gmem_out6_bready,
  m_axi_gmem_out6_arid,
  m_axi_gmem_out6_araddr,
  m_axi_gmem_out6_arlen,
  m_axi_gmem_out6_arsize,
  m_axi_gmem_out6_arburst,
  m_axi_gmem_out6_arlock,
  m_axi_gmem_out6_arcache,
  m_axi_gmem_out6_arprot,
  m_axi_gmem_out6_arqos,
  m_axi_gmem_out6_arregion,
  m_axi_gmem_out6_aruser,
  m_axi_gmem_out6_arvalid,
  m_axi_gmem_out6_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem_out6_bid=1,
    BITSIZE_m_axi_gmem_out6_bresp=2,
    BITSIZE_m_axi_gmem_out6_buser=1,
    BITSIZE_m_axi_gmem_out6_rid=1,
    BITSIZE_m_axi_gmem_out6_rdata=1,
    BITSIZE_m_axi_gmem_out6_rresp=2,
    BITSIZE_m_axi_gmem_out6_ruser=1,
    BITSIZE_m_axi_gmem_out6_awid=1,
    BITSIZE_m_axi_gmem_out6_awaddr=1,
    BITSIZE_m_axi_gmem_out6_awlen=1,
    BITSIZE_m_axi_gmem_out6_awsize=1,
    BITSIZE_m_axi_gmem_out6_awburst=2,
    BITSIZE_m_axi_gmem_out6_awlock=1,
    BITSIZE_m_axi_gmem_out6_awcache=1,
    BITSIZE_m_axi_gmem_out6_awprot=1,
    BITSIZE_m_axi_gmem_out6_awqos=1,
    BITSIZE_m_axi_gmem_out6_awregion=1,
    BITSIZE_m_axi_gmem_out6_awuser=1,
    BITSIZE_m_axi_gmem_out6_wdata=1,
    BITSIZE_m_axi_gmem_out6_wstrb=1,
    BITSIZE_m_axi_gmem_out6_wuser=1,
    BITSIZE_m_axi_gmem_out6_arid=1,
    BITSIZE_m_axi_gmem_out6_araddr=1,
    BITSIZE_m_axi_gmem_out6_arlen=1,
    BITSIZE_m_axi_gmem_out6_arsize=1,
    BITSIZE_m_axi_gmem_out6_arburst=2,
    BITSIZE_m_axi_gmem_out6_arlock=1,
    BITSIZE_m_axi_gmem_out6_arcache=1,
    BITSIZE_m_axi_gmem_out6_arprot=1,
    BITSIZE_m_axi_gmem_out6_arqos=1,
    BITSIZE_m_axi_gmem_out6_arregion=1,
    BITSIZE_m_axi_gmem_out6_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem_out6_awid-1:0] m_axi_gmem_out6_awid;
  input [BITSIZE_m_axi_gmem_out6_awaddr-1:0] m_axi_gmem_out6_awaddr;
  input [BITSIZE_m_axi_gmem_out6_awlen-1:0] m_axi_gmem_out6_awlen;
  input [BITSIZE_m_axi_gmem_out6_awsize-1:0] m_axi_gmem_out6_awsize;
  input [BITSIZE_m_axi_gmem_out6_awburst-1:0] m_axi_gmem_out6_awburst;
  input [BITSIZE_m_axi_gmem_out6_awlock-1:0] m_axi_gmem_out6_awlock;
  input [BITSIZE_m_axi_gmem_out6_awcache-1:0] m_axi_gmem_out6_awcache;
  input [BITSIZE_m_axi_gmem_out6_awprot-1:0] m_axi_gmem_out6_awprot;
  input [BITSIZE_m_axi_gmem_out6_awqos-1:0] m_axi_gmem_out6_awqos;
  input [BITSIZE_m_axi_gmem_out6_awregion-1:0] m_axi_gmem_out6_awregion;
  input [BITSIZE_m_axi_gmem_out6_awuser-1:0] m_axi_gmem_out6_awuser;
  input m_axi_gmem_out6_awvalid;
  input [BITSIZE_m_axi_gmem_out6_wdata-1:0] m_axi_gmem_out6_wdata;
  input [BITSIZE_m_axi_gmem_out6_wstrb-1:0] m_axi_gmem_out6_wstrb;
  input m_axi_gmem_out6_wlast;
  input [BITSIZE_m_axi_gmem_out6_wuser-1:0] m_axi_gmem_out6_wuser;
  input m_axi_gmem_out6_wvalid;
  input m_axi_gmem_out6_bready;
  input [BITSIZE_m_axi_gmem_out6_arid-1:0] m_axi_gmem_out6_arid;
  input [BITSIZE_m_axi_gmem_out6_araddr-1:0] m_axi_gmem_out6_araddr;
  input [BITSIZE_m_axi_gmem_out6_arlen-1:0] m_axi_gmem_out6_arlen;
  input [BITSIZE_m_axi_gmem_out6_arsize-1:0] m_axi_gmem_out6_arsize;
  input [BITSIZE_m_axi_gmem_out6_arburst-1:0] m_axi_gmem_out6_arburst;
  input [BITSIZE_m_axi_gmem_out6_arlock-1:0] m_axi_gmem_out6_arlock;
  input [BITSIZE_m_axi_gmem_out6_arcache-1:0] m_axi_gmem_out6_arcache;
  input [BITSIZE_m_axi_gmem_out6_arprot-1:0] m_axi_gmem_out6_arprot;
  input [BITSIZE_m_axi_gmem_out6_arqos-1:0] m_axi_gmem_out6_arqos;
  input [BITSIZE_m_axi_gmem_out6_arregion-1:0] m_axi_gmem_out6_arregion;
  input [BITSIZE_m_axi_gmem_out6_aruser-1:0] m_axi_gmem_out6_aruser;
  input m_axi_gmem_out6_arvalid;
  input m_axi_gmem_out6_rready;
  // OUT
  output m_axi_gmem_out6_awready;
  output m_axi_gmem_out6_wready;
  output [BITSIZE_m_axi_gmem_out6_bid-1:0] m_axi_gmem_out6_bid;
  output [BITSIZE_m_axi_gmem_out6_bresp-1:0] m_axi_gmem_out6_bresp;
  output [BITSIZE_m_axi_gmem_out6_buser-1:0] m_axi_gmem_out6_buser;
  output m_axi_gmem_out6_bvalid;
  output m_axi_gmem_out6_arready;
  output [BITSIZE_m_axi_gmem_out6_rid-1:0] m_axi_gmem_out6_rid;
  output [BITSIZE_m_axi_gmem_out6_rdata-1:0] m_axi_gmem_out6_rdata;
  output [BITSIZE_m_axi_gmem_out6_rresp-1:0] m_axi_gmem_out6_rresp;
  output m_axi_gmem_out6_rlast;
  output [BITSIZE_m_axi_gmem_out6_ruser-1:0] m_axi_gmem_out6_ruser;
  output m_axi_gmem_out6_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem_out6_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem_out6_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem_out6_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem_out6_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem_out6_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem_out6_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem_out6_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem_out6_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem_out6_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem_out6_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem_out6_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem_out6_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem_out6_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem_out6_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem_out6_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem_out6_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem_out6_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem_out6_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem_out6_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem_out6_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem_out6_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem_out6_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem_out6_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem_out6_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem_out6_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem_out6_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem_out6_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem_out6_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem_out6_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem_out6_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem_out6_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem_out6_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem_out6_awready=awready;
  assign m_axi_gmem_out6_wready=wready;
  assign m_axi_gmem_out6_bid=bid;
  assign m_axi_gmem_out6_bresp=bresp;
  assign m_axi_gmem_out6_buser=buser;
  assign m_axi_gmem_out6_bvalid=bvalid;
  assign m_axi_gmem_out6_arready=arready;
  assign m_axi_gmem_out6_rid=rid;
  assign m_axi_gmem_out6_rdata=rdata;
  assign m_axi_gmem_out6_rresp=rresp;
  assign m_axi_gmem_out6_rlast=rlast;
  assign m_axi_gmem_out6_ruser=ruser;
  assign m_axi_gmem_out6_rvalid=rvalid;
  assign awid=m_axi_gmem_out6_awid;
  assign awaddr=m_axi_gmem_out6_awaddr;
  assign awlen=m_axi_gmem_out6_awlen;
  assign awsize=m_axi_gmem_out6_awsize;
  assign awburst=m_axi_gmem_out6_awburst;
  assign awlock=m_axi_gmem_out6_awlock;
  assign awcache=m_axi_gmem_out6_awcache;
  assign awprot=m_axi_gmem_out6_awprot;
  assign awqos=m_axi_gmem_out6_awqos;
  assign awregion=m_axi_gmem_out6_awregion;
  assign awuser=m_axi_gmem_out6_awuser;
  assign awvalid=m_axi_gmem_out6_awvalid;
  assign wdata=m_axi_gmem_out6_wdata;
  assign wstrb=m_axi_gmem_out6_wstrb;
  assign wlast=m_axi_gmem_out6_wlast;
  assign wuser=m_axi_gmem_out6_wuser;
  assign wvalid=m_axi_gmem_out6_wvalid;
  assign bready=m_axi_gmem_out6_bready;
  assign arid=m_axi_gmem_out6_arid;
  assign araddr=m_axi_gmem_out6_araddr;
  assign arlen=m_axi_gmem_out6_arlen;
  assign arsize=m_axi_gmem_out6_arsize;
  assign arburst=m_axi_gmem_out6_arburst;
  assign arlock=m_axi_gmem_out6_arlock;
  assign arcache=m_axi_gmem_out6_arcache;
  assign arprot=m_axi_gmem_out6_arprot;
  assign arqos=m_axi_gmem_out6_arqos;
  assign arregion=m_axi_gmem_out6_arregion;
  assign aruser=m_axi_gmem_out6_aruser;
  assign arvalid=m_axi_gmem_out6_arvalid;
  assign rready=m_axi_gmem_out6_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem_out6_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem_out6_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem_out6_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem_out6_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem_out6_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem_out6_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem_out6_arid,
    OFFSET_delay=0,
    OFFSET_counter=OFFSET_delay+BITSIZE_delay,
    OFFSET_burst=OFFSET_counter+BITSIZE_counter,
    OFFSET_len=OFFSET_burst+BITSIZE_burst,
    OFFSET_size=OFFSET_len+BITSIZE_len,
    OFFSET_addr=OFFSET_size+BITSIZE_size,
    OFFSET_id=OFFSET_addr+BITSIZE_addr,
    OFFSET_data=OFFSET_id+BITSIZE_id,
    OFFSET_wstrb=OFFSET_data+BITSIZE_data,
    BITSIZE_aritem=BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay,
    BITSIZE_awitem=BITSIZE_wstrb+BITSIZE_data+BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay;
  
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] arqueue;
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] next_arqueue;
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] awqueue; 
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] next_awqueue;
  reg [31:0] test_addr;
  reg [31:0] test_wstrb;
  reg [31:0] test_data;
  reg [31:0] test_addr_read;
  integer arqueue_size, next_arqueue_size;
  integer awqueue_size, next_awqueue_size;
  
  reg [BITSIZE_id-1:0] awid_reg;
  reg [BITSIZE_addr-1:0] awaddr_reg;
  reg [BITSIZE_size-1:0] awsize_reg;
  reg [BITSIZE_len-1:0] awlen_reg; 
  reg [BITSIZE_burst-1:0] awburst_reg;
  reg [BITSIZE_counter-1:0] counter_reg, counter_next;
  reg write_done;
  reg wlast_reg, wlast_next;
  
  if_utils #(index, BITSIZE_data) m_utils();
  
  initial
  begin
    arqueue = 0;
    arqueue_size = 0;
    next_arqueue = 0;
    next_arqueue_size = 0;
    awqueue = 0;
    awqueue_size = 0;
    next_awqueue = 0;
    next_awqueue_size = 0;
    awready = 0;
    wready = 0;
    bid = 0;
    bresp = 0;
    buser = 0;
    bvalid = 0;
    arready = 0;
    rid = 0;
    rdata = 0;
    rresp = 0;
    rlast = 0;
    ruser = 0;
    rvalid = 0;
    awid_reg = 0;
    awaddr_reg = 0;
    awsize_reg = 0;
    awlen_reg = 0;
    awburst_reg = 0;
  end
  
  // Combinatorial logic for read transactions
  always@(*)
  begin: read_comb
    automatic integer unsigned i;
    next_arqueue = arqueue;
    next_arqueue_size = arqueue_size;
    if(arvalid && arready)  // Valid and ready -> accept new transaction
    begin
      next_arqueue[arqueue_size*BITSIZE_aritem +:BITSIZE_aritem] = {arid, araddr, arsize, arlen, arburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + READ_DELAY)}; // size of parameter is implementation dependent
      next_arqueue_size = arqueue_size + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] = arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1) && rready && rvalid)
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_arqueue[(i-1)*BITSIZE_aritem+:BITSIZE_aritem] = next_arqueue[i*BITSIZE_aritem+:BITSIZE_aritem];
      end
      next_arqueue_size = next_arqueue_size - 1;
    end
    if(next_arqueue_size > 0 && (next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1) && (next_arqueue[OFFSET_counter+:BITSIZE_counter] < (next_arqueue[OFFSET_len+:BITSIZE_len] + 1)))
    begin
      next_arqueue[OFFSET_counter+:BITSIZE_counter] = next_arqueue[OFFSET_counter+:BITSIZE_counter] + 1;
    end
  end
  
  // Combinatorial logic for write transactions
  always@(*) 
  begin: write_comb
    automatic integer i;
    automatic reg [BITSIZE_counter-1:0] counter;
    next_awqueue = awqueue;
    next_awqueue_size = awqueue_size;
    wlast_next = wlast_reg;
    if(awvalid && awready && wready && wvalid) // Valid and ready -> accept new transaction and save data
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid, awaddr, awsize, awlen, awburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
    end
    else if(awvalid && awready && wlast_reg)
    begin
      awid_reg = awid;
      awaddr_reg = awaddr;
      awsize_reg = awsize;
      awlen_reg = awlen; 
      awburst_reg = awburst;
      counter_next = 0;
      wlast_next = 0;
    end
    else if(wready && wvalid)
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid_reg, awaddr_reg, awsize_reg, awlen_reg, awburst_reg, counter_reg, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
      counter_next = counter_reg + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] = awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(write_done && next_awqueue_size > 0 && ((next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len] && bready) || next_awqueue[OFFSET_counter+:BITSIZE_counter] < next_awqueue[OFFSET_len+:BITSIZE_len]))
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_awqueue[(i-1)*BITSIZE_awitem+:BITSIZE_awitem] = next_awqueue[i*BITSIZE_awitem+:BITSIZE_awitem];
      end
      next_awqueue_size = next_awqueue_size - 1;
    end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arready <= 0;
      awready <= 0;
      wready <= 0;
      wlast_reg <= 1;
      counter_reg <= 0;
     end
     else
     begin
      arready <= (next_arqueue_size - (next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= next_arqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE);  //Ready if next_queue_size - rlast < QUEUE_SIZE
      awready <= (wlast_next || wlast) && (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); // ready if next_queue_size - bvalid < QUEUE_SIZE
      wready <= (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); 
      wlast_reg <= wlast_next || wlast;
      counter_reg <= counter_next;
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      rvalid <= 0;
      bvalid <= 0;
     end
     else
     begin
      rvalid <= (next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1); // if at posedge_clock delay is 1 I have to perfrom the operation in this cycle
      bvalid <= (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == (next_awqueue[OFFSET_len+:BITSIZE_len])); // if at posedge_clock delay is 1 I have to perfrom the last operation in this cycle
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arqueue <= 0;
      arqueue_size <= 0;
      awqueue <= 0;
      awqueue_size <= 0;
     end
     else
     begin
      arqueue <= next_arqueue;
      arqueue_size <= next_arqueue_size;
      awqueue <= next_awqueue;
      awqueue_size <= next_awqueue_size;
     end
  end
  
  // Sequential logic for read transactions
  always@(posedge clock)
  begin : read_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    rlast <= 0;
    test_addr_read <= 0;
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1)
    begin
      if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr] + (next_arqueue[OFFSET_counter+:BITSIZE_counter] - 1) * (1 << next_arqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_addr_read <= currAddr;
      rid <= next_arqueue[OFFSET_id+:BITSIZE_id];
      rdata <= m_utils.read_a(currAddr);
      if(next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1))
      begin
        rlast <= 1;
      end
    end
  end
  
  // Sequential logic for write transactions
  always@(posedge clock)
  begin: write_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    test_wstrb <=0;
    test_addr <= 0;
    test_data <= 0;
    write_done <= 0;
    if(next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1) // Performs the first write of the queue
    begin
      if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr] + next_awqueue[OFFSET_counter+:BITSIZE_counter] * (1 << next_awqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_wstrb <= next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb];
      test_addr <= currAddr;
      test_data <= next_awqueue[OFFSET_data+:BITSIZE_data];
      bid <= next_awqueue[OFFSET_id+:BITSIZE_id];
      write_done <= 1;
      void'(m_utils.write_strobe(next_awqueue[OFFSET_data+:BITSIZE_data], next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb], currAddr));
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Michele Fiorito <michele.fiorito@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module if_m_axi_gmem_out7(clock,
  reset,
  done_port,
  m_axi_gmem_out7_awready,
  m_axi_gmem_out7_wready,
  m_axi_gmem_out7_bid,
  m_axi_gmem_out7_bresp,
  m_axi_gmem_out7_buser,
  m_axi_gmem_out7_bvalid,
  m_axi_gmem_out7_arready,
  m_axi_gmem_out7_rid,
  m_axi_gmem_out7_rdata,
  m_axi_gmem_out7_rresp,
  m_axi_gmem_out7_rlast,
  m_axi_gmem_out7_ruser,
  m_axi_gmem_out7_rvalid,
  m_axi_gmem_out7_awid,
  m_axi_gmem_out7_awaddr,
  m_axi_gmem_out7_awlen,
  m_axi_gmem_out7_awsize,
  m_axi_gmem_out7_awburst,
  m_axi_gmem_out7_awlock,
  m_axi_gmem_out7_awcache,
  m_axi_gmem_out7_awprot,
  m_axi_gmem_out7_awqos,
  m_axi_gmem_out7_awregion,
  m_axi_gmem_out7_awuser,
  m_axi_gmem_out7_awvalid,
  m_axi_gmem_out7_wdata,
  m_axi_gmem_out7_wstrb,
  m_axi_gmem_out7_wlast,
  m_axi_gmem_out7_wuser,
  m_axi_gmem_out7_wvalid,
  m_axi_gmem_out7_bready,
  m_axi_gmem_out7_arid,
  m_axi_gmem_out7_araddr,
  m_axi_gmem_out7_arlen,
  m_axi_gmem_out7_arsize,
  m_axi_gmem_out7_arburst,
  m_axi_gmem_out7_arlock,
  m_axi_gmem_out7_arcache,
  m_axi_gmem_out7_arprot,
  m_axi_gmem_out7_arqos,
  m_axi_gmem_out7_arregion,
  m_axi_gmem_out7_aruser,
  m_axi_gmem_out7_arvalid,
  m_axi_gmem_out7_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem_out7_bid=1,
    BITSIZE_m_axi_gmem_out7_bresp=2,
    BITSIZE_m_axi_gmem_out7_buser=1,
    BITSIZE_m_axi_gmem_out7_rid=1,
    BITSIZE_m_axi_gmem_out7_rdata=1,
    BITSIZE_m_axi_gmem_out7_rresp=2,
    BITSIZE_m_axi_gmem_out7_ruser=1,
    BITSIZE_m_axi_gmem_out7_awid=1,
    BITSIZE_m_axi_gmem_out7_awaddr=1,
    BITSIZE_m_axi_gmem_out7_awlen=1,
    BITSIZE_m_axi_gmem_out7_awsize=1,
    BITSIZE_m_axi_gmem_out7_awburst=2,
    BITSIZE_m_axi_gmem_out7_awlock=1,
    BITSIZE_m_axi_gmem_out7_awcache=1,
    BITSIZE_m_axi_gmem_out7_awprot=1,
    BITSIZE_m_axi_gmem_out7_awqos=1,
    BITSIZE_m_axi_gmem_out7_awregion=1,
    BITSIZE_m_axi_gmem_out7_awuser=1,
    BITSIZE_m_axi_gmem_out7_wdata=1,
    BITSIZE_m_axi_gmem_out7_wstrb=1,
    BITSIZE_m_axi_gmem_out7_wuser=1,
    BITSIZE_m_axi_gmem_out7_arid=1,
    BITSIZE_m_axi_gmem_out7_araddr=1,
    BITSIZE_m_axi_gmem_out7_arlen=1,
    BITSIZE_m_axi_gmem_out7_arsize=1,
    BITSIZE_m_axi_gmem_out7_arburst=2,
    BITSIZE_m_axi_gmem_out7_arlock=1,
    BITSIZE_m_axi_gmem_out7_arcache=1,
    BITSIZE_m_axi_gmem_out7_arprot=1,
    BITSIZE_m_axi_gmem_out7_arqos=1,
    BITSIZE_m_axi_gmem_out7_arregion=1,
    BITSIZE_m_axi_gmem_out7_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem_out7_awid-1:0] m_axi_gmem_out7_awid;
  input [BITSIZE_m_axi_gmem_out7_awaddr-1:0] m_axi_gmem_out7_awaddr;
  input [BITSIZE_m_axi_gmem_out7_awlen-1:0] m_axi_gmem_out7_awlen;
  input [BITSIZE_m_axi_gmem_out7_awsize-1:0] m_axi_gmem_out7_awsize;
  input [BITSIZE_m_axi_gmem_out7_awburst-1:0] m_axi_gmem_out7_awburst;
  input [BITSIZE_m_axi_gmem_out7_awlock-1:0] m_axi_gmem_out7_awlock;
  input [BITSIZE_m_axi_gmem_out7_awcache-1:0] m_axi_gmem_out7_awcache;
  input [BITSIZE_m_axi_gmem_out7_awprot-1:0] m_axi_gmem_out7_awprot;
  input [BITSIZE_m_axi_gmem_out7_awqos-1:0] m_axi_gmem_out7_awqos;
  input [BITSIZE_m_axi_gmem_out7_awregion-1:0] m_axi_gmem_out7_awregion;
  input [BITSIZE_m_axi_gmem_out7_awuser-1:0] m_axi_gmem_out7_awuser;
  input m_axi_gmem_out7_awvalid;
  input [BITSIZE_m_axi_gmem_out7_wdata-1:0] m_axi_gmem_out7_wdata;
  input [BITSIZE_m_axi_gmem_out7_wstrb-1:0] m_axi_gmem_out7_wstrb;
  input m_axi_gmem_out7_wlast;
  input [BITSIZE_m_axi_gmem_out7_wuser-1:0] m_axi_gmem_out7_wuser;
  input m_axi_gmem_out7_wvalid;
  input m_axi_gmem_out7_bready;
  input [BITSIZE_m_axi_gmem_out7_arid-1:0] m_axi_gmem_out7_arid;
  input [BITSIZE_m_axi_gmem_out7_araddr-1:0] m_axi_gmem_out7_araddr;
  input [BITSIZE_m_axi_gmem_out7_arlen-1:0] m_axi_gmem_out7_arlen;
  input [BITSIZE_m_axi_gmem_out7_arsize-1:0] m_axi_gmem_out7_arsize;
  input [BITSIZE_m_axi_gmem_out7_arburst-1:0] m_axi_gmem_out7_arburst;
  input [BITSIZE_m_axi_gmem_out7_arlock-1:0] m_axi_gmem_out7_arlock;
  input [BITSIZE_m_axi_gmem_out7_arcache-1:0] m_axi_gmem_out7_arcache;
  input [BITSIZE_m_axi_gmem_out7_arprot-1:0] m_axi_gmem_out7_arprot;
  input [BITSIZE_m_axi_gmem_out7_arqos-1:0] m_axi_gmem_out7_arqos;
  input [BITSIZE_m_axi_gmem_out7_arregion-1:0] m_axi_gmem_out7_arregion;
  input [BITSIZE_m_axi_gmem_out7_aruser-1:0] m_axi_gmem_out7_aruser;
  input m_axi_gmem_out7_arvalid;
  input m_axi_gmem_out7_rready;
  // OUT
  output m_axi_gmem_out7_awready;
  output m_axi_gmem_out7_wready;
  output [BITSIZE_m_axi_gmem_out7_bid-1:0] m_axi_gmem_out7_bid;
  output [BITSIZE_m_axi_gmem_out7_bresp-1:0] m_axi_gmem_out7_bresp;
  output [BITSIZE_m_axi_gmem_out7_buser-1:0] m_axi_gmem_out7_buser;
  output m_axi_gmem_out7_bvalid;
  output m_axi_gmem_out7_arready;
  output [BITSIZE_m_axi_gmem_out7_rid-1:0] m_axi_gmem_out7_rid;
  output [BITSIZE_m_axi_gmem_out7_rdata-1:0] m_axi_gmem_out7_rdata;
  output [BITSIZE_m_axi_gmem_out7_rresp-1:0] m_axi_gmem_out7_rresp;
  output m_axi_gmem_out7_rlast;
  output [BITSIZE_m_axi_gmem_out7_ruser-1:0] m_axi_gmem_out7_ruser;
  output m_axi_gmem_out7_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem_out7_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem_out7_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem_out7_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem_out7_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem_out7_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem_out7_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem_out7_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem_out7_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem_out7_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem_out7_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem_out7_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem_out7_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem_out7_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem_out7_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem_out7_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem_out7_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem_out7_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem_out7_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem_out7_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem_out7_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem_out7_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem_out7_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem_out7_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem_out7_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem_out7_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem_out7_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem_out7_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem_out7_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem_out7_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem_out7_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem_out7_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem_out7_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem_out7_awready=awready;
  assign m_axi_gmem_out7_wready=wready;
  assign m_axi_gmem_out7_bid=bid;
  assign m_axi_gmem_out7_bresp=bresp;
  assign m_axi_gmem_out7_buser=buser;
  assign m_axi_gmem_out7_bvalid=bvalid;
  assign m_axi_gmem_out7_arready=arready;
  assign m_axi_gmem_out7_rid=rid;
  assign m_axi_gmem_out7_rdata=rdata;
  assign m_axi_gmem_out7_rresp=rresp;
  assign m_axi_gmem_out7_rlast=rlast;
  assign m_axi_gmem_out7_ruser=ruser;
  assign m_axi_gmem_out7_rvalid=rvalid;
  assign awid=m_axi_gmem_out7_awid;
  assign awaddr=m_axi_gmem_out7_awaddr;
  assign awlen=m_axi_gmem_out7_awlen;
  assign awsize=m_axi_gmem_out7_awsize;
  assign awburst=m_axi_gmem_out7_awburst;
  assign awlock=m_axi_gmem_out7_awlock;
  assign awcache=m_axi_gmem_out7_awcache;
  assign awprot=m_axi_gmem_out7_awprot;
  assign awqos=m_axi_gmem_out7_awqos;
  assign awregion=m_axi_gmem_out7_awregion;
  assign awuser=m_axi_gmem_out7_awuser;
  assign awvalid=m_axi_gmem_out7_awvalid;
  assign wdata=m_axi_gmem_out7_wdata;
  assign wstrb=m_axi_gmem_out7_wstrb;
  assign wlast=m_axi_gmem_out7_wlast;
  assign wuser=m_axi_gmem_out7_wuser;
  assign wvalid=m_axi_gmem_out7_wvalid;
  assign bready=m_axi_gmem_out7_bready;
  assign arid=m_axi_gmem_out7_arid;
  assign araddr=m_axi_gmem_out7_araddr;
  assign arlen=m_axi_gmem_out7_arlen;
  assign arsize=m_axi_gmem_out7_arsize;
  assign arburst=m_axi_gmem_out7_arburst;
  assign arlock=m_axi_gmem_out7_arlock;
  assign arcache=m_axi_gmem_out7_arcache;
  assign arprot=m_axi_gmem_out7_arprot;
  assign arqos=m_axi_gmem_out7_arqos;
  assign arregion=m_axi_gmem_out7_arregion;
  assign aruser=m_axi_gmem_out7_aruser;
  assign arvalid=m_axi_gmem_out7_arvalid;
  assign rready=m_axi_gmem_out7_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem_out7_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem_out7_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem_out7_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem_out7_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem_out7_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem_out7_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem_out7_arid,
    OFFSET_delay=0,
    OFFSET_counter=OFFSET_delay+BITSIZE_delay,
    OFFSET_burst=OFFSET_counter+BITSIZE_counter,
    OFFSET_len=OFFSET_burst+BITSIZE_burst,
    OFFSET_size=OFFSET_len+BITSIZE_len,
    OFFSET_addr=OFFSET_size+BITSIZE_size,
    OFFSET_id=OFFSET_addr+BITSIZE_addr,
    OFFSET_data=OFFSET_id+BITSIZE_id,
    OFFSET_wstrb=OFFSET_data+BITSIZE_data,
    BITSIZE_aritem=BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay,
    BITSIZE_awitem=BITSIZE_wstrb+BITSIZE_data+BITSIZE_id+BITSIZE_addr+BITSIZE_size+BITSIZE_len+BITSIZE_burst+BITSIZE_counter+BITSIZE_delay;
  
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] arqueue;
  reg [QUEUE_SIZE*BITSIZE_aritem-1:0] next_arqueue;
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] awqueue; 
  reg [QUEUE_SIZE*BITSIZE_awitem-1:0] next_awqueue;
  reg [31:0] test_addr;
  reg [31:0] test_wstrb;
  reg [31:0] test_data;
  reg [31:0] test_addr_read;
  integer arqueue_size, next_arqueue_size;
  integer awqueue_size, next_awqueue_size;
  
  reg [BITSIZE_id-1:0] awid_reg;
  reg [BITSIZE_addr-1:0] awaddr_reg;
  reg [BITSIZE_size-1:0] awsize_reg;
  reg [BITSIZE_len-1:0] awlen_reg; 
  reg [BITSIZE_burst-1:0] awburst_reg;
  reg [BITSIZE_counter-1:0] counter_reg, counter_next;
  reg write_done;
  reg wlast_reg, wlast_next;
  
  if_utils #(index, BITSIZE_data) m_utils();
  
  initial
  begin
    arqueue = 0;
    arqueue_size = 0;
    next_arqueue = 0;
    next_arqueue_size = 0;
    awqueue = 0;
    awqueue_size = 0;
    next_awqueue = 0;
    next_awqueue_size = 0;
    awready = 0;
    wready = 0;
    bid = 0;
    bresp = 0;
    buser = 0;
    bvalid = 0;
    arready = 0;
    rid = 0;
    rdata = 0;
    rresp = 0;
    rlast = 0;
    ruser = 0;
    rvalid = 0;
    awid_reg = 0;
    awaddr_reg = 0;
    awsize_reg = 0;
    awlen_reg = 0;
    awburst_reg = 0;
  end
  
  // Combinatorial logic for read transactions
  always@(*)
  begin: read_comb
    automatic integer unsigned i;
    next_arqueue = arqueue;
    next_arqueue_size = arqueue_size;
    if(arvalid && arready)  // Valid and ready -> accept new transaction
    begin
      next_arqueue[arqueue_size*BITSIZE_aritem +:BITSIZE_aritem] = {arid, araddr, arsize, arlen, arburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + READ_DELAY)}; // size of parameter is implementation dependent
      next_arqueue_size = arqueue_size + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] = arqueue[i*BITSIZE_aritem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1) && rready && rvalid)
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_arqueue[(i-1)*BITSIZE_aritem+:BITSIZE_aritem] = next_arqueue[i*BITSIZE_aritem+:BITSIZE_aritem];
      end
      next_arqueue_size = next_arqueue_size - 1;
    end
    if(next_arqueue_size > 0 && (next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1) && (next_arqueue[OFFSET_counter+:BITSIZE_counter] < (next_arqueue[OFFSET_len+:BITSIZE_len] + 1)))
    begin
      next_arqueue[OFFSET_counter+:BITSIZE_counter] = next_arqueue[OFFSET_counter+:BITSIZE_counter] + 1;
    end
  end
  
  // Combinatorial logic for write transactions
  always@(*) 
  begin: write_comb
    automatic integer i;
    automatic reg [BITSIZE_counter-1:0] counter;
    next_awqueue = awqueue;
    next_awqueue_size = awqueue_size;
    wlast_next = wlast_reg;
    if(awvalid && awready && wready && wvalid) // Valid and ready -> accept new transaction and save data
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid, awaddr, awsize, awlen, awburst, {BITSIZE_counter{1'b0}}, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
    end
    else if(awvalid && awready && wlast_reg)
    begin
      awid_reg = awid;
      awaddr_reg = awaddr;
      awsize_reg = awsize;
      awlen_reg = awlen; 
      awburst_reg = awburst;
      counter_next = 0;
      wlast_next = 0;
    end
    else if(wready && wvalid)
    begin
      next_awqueue[awqueue_size*BITSIZE_awitem+:BITSIZE_awitem] = {wstrb, wdata, awid_reg, awaddr_reg, awsize_reg, awlen_reg, awburst_reg, counter_reg, ({BITSIZE_delay{1'b0}} + WRITE_DELAY)};
      next_awqueue_size = awqueue_size + 1;
      counter_next = counter_reg + 1;
    end
    for(i = 0; i < QUEUE_SIZE; i = i + 1)
    begin
      if(awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] > 1)
      begin
        next_awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] = awqueue[i*BITSIZE_awitem+OFFSET_delay+:BITSIZE_delay] - 1;
      end
    end
    if(write_done && next_awqueue_size > 0 && ((next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len] && bready) || next_awqueue[OFFSET_counter+:BITSIZE_counter] < next_awqueue[OFFSET_len+:BITSIZE_len]))
    begin
      for(i = 1; i < QUEUE_SIZE; i = i + 1)
      begin
        next_awqueue[(i-1)*BITSIZE_awitem+:BITSIZE_awitem] = next_awqueue[i*BITSIZE_awitem+:BITSIZE_awitem];
      end
      next_awqueue_size = next_awqueue_size - 1;
    end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arready <= 0;
      awready <= 0;
      wready <= 0;
      wlast_reg <= 1;
      counter_reg <= 0;
     end
     else
     begin
      arready <= (next_arqueue_size - (next_arqueue_size > 0 && next_arqueue[OFFSET_counter+:BITSIZE_counter] >= next_arqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE);  //Ready if next_queue_size - rlast < QUEUE_SIZE
      awready <= (wlast_next || wlast) && (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); // ready if next_queue_size - bvalid < QUEUE_SIZE
      wready <= (next_awqueue_size - (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == next_awqueue[OFFSET_len+:BITSIZE_len]) < QUEUE_SIZE); 
      wlast_reg <= wlast_next || wlast;
      counter_reg <= counter_next;
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      rvalid <= 0;
      bvalid <= 0;
     end
     else
     begin
      rvalid <= (next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1); // if at posedge_clock delay is 1 I have to perfrom the operation in this cycle
      bvalid <= (next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1 && next_awqueue[OFFSET_counter+:BITSIZE_counter] == (next_awqueue[OFFSET_len+:BITSIZE_len])); // if at posedge_clock delay is 1 I have to perfrom the last operation in this cycle
     end
  end
  
  always@(posedge clock)
  begin
     if(reset == 1'b0)
     begin
      arqueue <= 0;
      arqueue_size <= 0;
      awqueue <= 0;
      awqueue_size <= 0;
     end
     else
     begin
      arqueue <= next_arqueue;
      arqueue_size <= next_arqueue_size;
      awqueue <= next_awqueue;
      awqueue_size <= next_awqueue_size;
     end
  end
  
  // Sequential logic for read transactions
  always@(posedge clock)
  begin : read_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    rlast <= 0;
    test_addr_read <= 0;
    if(next_arqueue_size > 0 && next_arqueue[OFFSET_delay+:BITSIZE_delay] == 1)
    begin
      if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_arqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_arqueue[OFFSET_addr+:BITSIZE_addr] + (next_arqueue[OFFSET_counter+:BITSIZE_counter] - 1) * (1 << next_arqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_addr_read <= currAddr;
      rid <= next_arqueue[OFFSET_id+:BITSIZE_id];
      rdata <= m_utils.read_a(currAddr);
      if(next_arqueue[OFFSET_counter+:BITSIZE_counter] >= (next_arqueue[OFFSET_len+:BITSIZE_len] + 1))
      begin
        rlast <= 1;
      end
    end
  end
  
  // Sequential logic for write transactions
  always@(posedge clock)
  begin: write_seq
    automatic ptr_t currAddr;
    automatic ptr_t endAddr;
    test_wstrb <=0;
    test_addr <= 0;
    test_data <= 0;
    write_done <= 0;
    if(next_awqueue_size > 0 && next_awqueue[OFFSET_delay+:BITSIZE_delay] == 1) // Performs the first write of the queue
    begin
      if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b00)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr];
      end
      else if(next_awqueue[OFFSET_burst+:BITSIZE_burst] == 2'b01)
      begin
        currAddr = next_awqueue[OFFSET_addr+:BITSIZE_addr] + next_awqueue[OFFSET_counter+:BITSIZE_counter] * (1 << next_awqueue[OFFSET_size+:BITSIZE_size]);
      end
      else
      begin
        $display("Unsupported burst type: %0d", next_arqueue[OFFSET_burst+:BITSIZE_burst]);
        $finish;
      end
      test_wstrb <= next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb];
      test_addr <= currAddr;
      test_data <= next_awqueue[OFFSET_data+:BITSIZE_data];
      bid <= next_awqueue[OFFSET_id+:BITSIZE_id];
      write_done <= 1;
      void'(m_utils.write_strobe(next_awqueue[OFFSET_data+:BITSIZE_data], next_awqueue[OFFSET_wstrb+:BITSIZE_wstrb], currAddr));
    end
  end

endmodule

// Testbench top component
// This component has been derived from the input source code and so it does not fall under the copyright of PandA framework, but it follows the input source code copyright, and may be aggregated with components of the BAMBU/PANDA IP LIBRARY.
// Author(s): Component automatically generated by bambu
// License: THIS COMPONENT IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
`timescale 1ns / 1ps
module bambu_testbench_impl(clock);
  // IN
  input clock;
  // Component and signal declarations
  wire sig_done_port;
  wire [31:0] sig_dram_in_b0;
  wire [31:0] sig_dram_in_b1;
  wire [31:0] sig_dram_out_b0;
  wire [31:0] sig_dram_out_b1;
  wire [31:0] sig_dram_out_b2;
  wire [31:0] sig_dram_out_b3;
  wire [31:0] sig_dram_out_b4;
  wire [31:0] sig_dram_out_b5;
  wire [31:0] sig_dram_out_b6;
  wire [31:0] sig_dram_out_b7;
  wire [31:0] sig_dram_w_b0;
  wire [31:0] sig_dram_w_b1;
  wire [31:0] sig_m_axi_gmem_in0_araddr;
  wire [1:0] sig_m_axi_gmem_in0_arburst;
  wire [3:0] sig_m_axi_gmem_in0_arcache;
  wire [5:0] sig_m_axi_gmem_in0_arid;
  wire [7:0] sig_m_axi_gmem_in0_arlen;
  wire sig_m_axi_gmem_in0_arlock;
  wire [2:0] sig_m_axi_gmem_in0_arprot;
  wire [3:0] sig_m_axi_gmem_in0_arqos;
  wire sig_m_axi_gmem_in0_arready;
  wire [3:0] sig_m_axi_gmem_in0_arregion;
  wire [2:0] sig_m_axi_gmem_in0_arsize;
  wire sig_m_axi_gmem_in0_aruser;
  wire sig_m_axi_gmem_in0_arvalid;
  wire [31:0] sig_m_axi_gmem_in0_awaddr;
  wire [1:0] sig_m_axi_gmem_in0_awburst;
  wire [3:0] sig_m_axi_gmem_in0_awcache;
  wire [5:0] sig_m_axi_gmem_in0_awid;
  wire [7:0] sig_m_axi_gmem_in0_awlen;
  wire sig_m_axi_gmem_in0_awlock;
  wire [2:0] sig_m_axi_gmem_in0_awprot;
  wire [3:0] sig_m_axi_gmem_in0_awqos;
  wire sig_m_axi_gmem_in0_awready;
  wire [3:0] sig_m_axi_gmem_in0_awregion;
  wire [2:0] sig_m_axi_gmem_in0_awsize;
  wire sig_m_axi_gmem_in0_awuser;
  wire sig_m_axi_gmem_in0_awvalid;
  wire [5:0] sig_m_axi_gmem_in0_bid;
  wire sig_m_axi_gmem_in0_bready;
  wire [1:0] sig_m_axi_gmem_in0_bresp;
  wire sig_m_axi_gmem_in0_buser;
  wire sig_m_axi_gmem_in0_bvalid;
  wire [31:0] sig_m_axi_gmem_in0_rdata;
  wire [5:0] sig_m_axi_gmem_in0_rid;
  wire sig_m_axi_gmem_in0_rlast;
  wire sig_m_axi_gmem_in0_rready;
  wire [1:0] sig_m_axi_gmem_in0_rresp;
  wire sig_m_axi_gmem_in0_ruser;
  wire sig_m_axi_gmem_in0_rvalid;
  wire [31:0] sig_m_axi_gmem_in0_wdata;
  wire sig_m_axi_gmem_in0_wlast;
  wire sig_m_axi_gmem_in0_wready;
  wire [3:0] sig_m_axi_gmem_in0_wstrb;
  wire sig_m_axi_gmem_in0_wuser;
  wire sig_m_axi_gmem_in0_wvalid;
  wire [31:0] sig_m_axi_gmem_in1_araddr;
  wire [1:0] sig_m_axi_gmem_in1_arburst;
  wire [3:0] sig_m_axi_gmem_in1_arcache;
  wire [5:0] sig_m_axi_gmem_in1_arid;
  wire [7:0] sig_m_axi_gmem_in1_arlen;
  wire sig_m_axi_gmem_in1_arlock;
  wire [2:0] sig_m_axi_gmem_in1_arprot;
  wire [3:0] sig_m_axi_gmem_in1_arqos;
  wire sig_m_axi_gmem_in1_arready;
  wire [3:0] sig_m_axi_gmem_in1_arregion;
  wire [2:0] sig_m_axi_gmem_in1_arsize;
  wire sig_m_axi_gmem_in1_aruser;
  wire sig_m_axi_gmem_in1_arvalid;
  wire [31:0] sig_m_axi_gmem_in1_awaddr;
  wire [1:0] sig_m_axi_gmem_in1_awburst;
  wire [3:0] sig_m_axi_gmem_in1_awcache;
  wire [5:0] sig_m_axi_gmem_in1_awid;
  wire [7:0] sig_m_axi_gmem_in1_awlen;
  wire sig_m_axi_gmem_in1_awlock;
  wire [2:0] sig_m_axi_gmem_in1_awprot;
  wire [3:0] sig_m_axi_gmem_in1_awqos;
  wire sig_m_axi_gmem_in1_awready;
  wire [3:0] sig_m_axi_gmem_in1_awregion;
  wire [2:0] sig_m_axi_gmem_in1_awsize;
  wire sig_m_axi_gmem_in1_awuser;
  wire sig_m_axi_gmem_in1_awvalid;
  wire [5:0] sig_m_axi_gmem_in1_bid;
  wire sig_m_axi_gmem_in1_bready;
  wire [1:0] sig_m_axi_gmem_in1_bresp;
  wire sig_m_axi_gmem_in1_buser;
  wire sig_m_axi_gmem_in1_bvalid;
  wire [31:0] sig_m_axi_gmem_in1_rdata;
  wire [5:0] sig_m_axi_gmem_in1_rid;
  wire sig_m_axi_gmem_in1_rlast;
  wire sig_m_axi_gmem_in1_rready;
  wire [1:0] sig_m_axi_gmem_in1_rresp;
  wire sig_m_axi_gmem_in1_ruser;
  wire sig_m_axi_gmem_in1_rvalid;
  wire [31:0] sig_m_axi_gmem_in1_wdata;
  wire sig_m_axi_gmem_in1_wlast;
  wire sig_m_axi_gmem_in1_wready;
  wire [3:0] sig_m_axi_gmem_in1_wstrb;
  wire sig_m_axi_gmem_in1_wuser;
  wire sig_m_axi_gmem_in1_wvalid;
  wire [31:0] sig_m_axi_gmem_out0_araddr;
  wire [1:0] sig_m_axi_gmem_out0_arburst;
  wire [3:0] sig_m_axi_gmem_out0_arcache;
  wire [5:0] sig_m_axi_gmem_out0_arid;
  wire [7:0] sig_m_axi_gmem_out0_arlen;
  wire sig_m_axi_gmem_out0_arlock;
  wire [2:0] sig_m_axi_gmem_out0_arprot;
  wire [3:0] sig_m_axi_gmem_out0_arqos;
  wire sig_m_axi_gmem_out0_arready;
  wire [3:0] sig_m_axi_gmem_out0_arregion;
  wire [2:0] sig_m_axi_gmem_out0_arsize;
  wire sig_m_axi_gmem_out0_aruser;
  wire sig_m_axi_gmem_out0_arvalid;
  wire [31:0] sig_m_axi_gmem_out0_awaddr;
  wire [1:0] sig_m_axi_gmem_out0_awburst;
  wire [3:0] sig_m_axi_gmem_out0_awcache;
  wire [5:0] sig_m_axi_gmem_out0_awid;
  wire [7:0] sig_m_axi_gmem_out0_awlen;
  wire sig_m_axi_gmem_out0_awlock;
  wire [2:0] sig_m_axi_gmem_out0_awprot;
  wire [3:0] sig_m_axi_gmem_out0_awqos;
  wire sig_m_axi_gmem_out0_awready;
  wire [3:0] sig_m_axi_gmem_out0_awregion;
  wire [2:0] sig_m_axi_gmem_out0_awsize;
  wire sig_m_axi_gmem_out0_awuser;
  wire sig_m_axi_gmem_out0_awvalid;
  wire [5:0] sig_m_axi_gmem_out0_bid;
  wire sig_m_axi_gmem_out0_bready;
  wire [1:0] sig_m_axi_gmem_out0_bresp;
  wire sig_m_axi_gmem_out0_buser;
  wire sig_m_axi_gmem_out0_bvalid;
  wire [31:0] sig_m_axi_gmem_out0_rdata;
  wire [5:0] sig_m_axi_gmem_out0_rid;
  wire sig_m_axi_gmem_out0_rlast;
  wire sig_m_axi_gmem_out0_rready;
  wire [1:0] sig_m_axi_gmem_out0_rresp;
  wire sig_m_axi_gmem_out0_ruser;
  wire sig_m_axi_gmem_out0_rvalid;
  wire [31:0] sig_m_axi_gmem_out0_wdata;
  wire sig_m_axi_gmem_out0_wlast;
  wire sig_m_axi_gmem_out0_wready;
  wire [3:0] sig_m_axi_gmem_out0_wstrb;
  wire sig_m_axi_gmem_out0_wuser;
  wire sig_m_axi_gmem_out0_wvalid;
  wire [31:0] sig_m_axi_gmem_out1_araddr;
  wire [1:0] sig_m_axi_gmem_out1_arburst;
  wire [3:0] sig_m_axi_gmem_out1_arcache;
  wire [5:0] sig_m_axi_gmem_out1_arid;
  wire [7:0] sig_m_axi_gmem_out1_arlen;
  wire sig_m_axi_gmem_out1_arlock;
  wire [2:0] sig_m_axi_gmem_out1_arprot;
  wire [3:0] sig_m_axi_gmem_out1_arqos;
  wire sig_m_axi_gmem_out1_arready;
  wire [3:0] sig_m_axi_gmem_out1_arregion;
  wire [2:0] sig_m_axi_gmem_out1_arsize;
  wire sig_m_axi_gmem_out1_aruser;
  wire sig_m_axi_gmem_out1_arvalid;
  wire [31:0] sig_m_axi_gmem_out1_awaddr;
  wire [1:0] sig_m_axi_gmem_out1_awburst;
  wire [3:0] sig_m_axi_gmem_out1_awcache;
  wire [5:0] sig_m_axi_gmem_out1_awid;
  wire [7:0] sig_m_axi_gmem_out1_awlen;
  wire sig_m_axi_gmem_out1_awlock;
  wire [2:0] sig_m_axi_gmem_out1_awprot;
  wire [3:0] sig_m_axi_gmem_out1_awqos;
  wire sig_m_axi_gmem_out1_awready;
  wire [3:0] sig_m_axi_gmem_out1_awregion;
  wire [2:0] sig_m_axi_gmem_out1_awsize;
  wire sig_m_axi_gmem_out1_awuser;
  wire sig_m_axi_gmem_out1_awvalid;
  wire [5:0] sig_m_axi_gmem_out1_bid;
  wire sig_m_axi_gmem_out1_bready;
  wire [1:0] sig_m_axi_gmem_out1_bresp;
  wire sig_m_axi_gmem_out1_buser;
  wire sig_m_axi_gmem_out1_bvalid;
  wire [31:0] sig_m_axi_gmem_out1_rdata;
  wire [5:0] sig_m_axi_gmem_out1_rid;
  wire sig_m_axi_gmem_out1_rlast;
  wire sig_m_axi_gmem_out1_rready;
  wire [1:0] sig_m_axi_gmem_out1_rresp;
  wire sig_m_axi_gmem_out1_ruser;
  wire sig_m_axi_gmem_out1_rvalid;
  wire [31:0] sig_m_axi_gmem_out1_wdata;
  wire sig_m_axi_gmem_out1_wlast;
  wire sig_m_axi_gmem_out1_wready;
  wire [3:0] sig_m_axi_gmem_out1_wstrb;
  wire sig_m_axi_gmem_out1_wuser;
  wire sig_m_axi_gmem_out1_wvalid;
  wire [31:0] sig_m_axi_gmem_out2_araddr;
  wire [1:0] sig_m_axi_gmem_out2_arburst;
  wire [3:0] sig_m_axi_gmem_out2_arcache;
  wire [5:0] sig_m_axi_gmem_out2_arid;
  wire [7:0] sig_m_axi_gmem_out2_arlen;
  wire sig_m_axi_gmem_out2_arlock;
  wire [2:0] sig_m_axi_gmem_out2_arprot;
  wire [3:0] sig_m_axi_gmem_out2_arqos;
  wire sig_m_axi_gmem_out2_arready;
  wire [3:0] sig_m_axi_gmem_out2_arregion;
  wire [2:0] sig_m_axi_gmem_out2_arsize;
  wire sig_m_axi_gmem_out2_aruser;
  wire sig_m_axi_gmem_out2_arvalid;
  wire [31:0] sig_m_axi_gmem_out2_awaddr;
  wire [1:0] sig_m_axi_gmem_out2_awburst;
  wire [3:0] sig_m_axi_gmem_out2_awcache;
  wire [5:0] sig_m_axi_gmem_out2_awid;
  wire [7:0] sig_m_axi_gmem_out2_awlen;
  wire sig_m_axi_gmem_out2_awlock;
  wire [2:0] sig_m_axi_gmem_out2_awprot;
  wire [3:0] sig_m_axi_gmem_out2_awqos;
  wire sig_m_axi_gmem_out2_awready;
  wire [3:0] sig_m_axi_gmem_out2_awregion;
  wire [2:0] sig_m_axi_gmem_out2_awsize;
  wire sig_m_axi_gmem_out2_awuser;
  wire sig_m_axi_gmem_out2_awvalid;
  wire [5:0] sig_m_axi_gmem_out2_bid;
  wire sig_m_axi_gmem_out2_bready;
  wire [1:0] sig_m_axi_gmem_out2_bresp;
  wire sig_m_axi_gmem_out2_buser;
  wire sig_m_axi_gmem_out2_bvalid;
  wire [31:0] sig_m_axi_gmem_out2_rdata;
  wire [5:0] sig_m_axi_gmem_out2_rid;
  wire sig_m_axi_gmem_out2_rlast;
  wire sig_m_axi_gmem_out2_rready;
  wire [1:0] sig_m_axi_gmem_out2_rresp;
  wire sig_m_axi_gmem_out2_ruser;
  wire sig_m_axi_gmem_out2_rvalid;
  wire [31:0] sig_m_axi_gmem_out2_wdata;
  wire sig_m_axi_gmem_out2_wlast;
  wire sig_m_axi_gmem_out2_wready;
  wire [3:0] sig_m_axi_gmem_out2_wstrb;
  wire sig_m_axi_gmem_out2_wuser;
  wire sig_m_axi_gmem_out2_wvalid;
  wire [31:0] sig_m_axi_gmem_out3_araddr;
  wire [1:0] sig_m_axi_gmem_out3_arburst;
  wire [3:0] sig_m_axi_gmem_out3_arcache;
  wire [5:0] sig_m_axi_gmem_out3_arid;
  wire [7:0] sig_m_axi_gmem_out3_arlen;
  wire sig_m_axi_gmem_out3_arlock;
  wire [2:0] sig_m_axi_gmem_out3_arprot;
  wire [3:0] sig_m_axi_gmem_out3_arqos;
  wire sig_m_axi_gmem_out3_arready;
  wire [3:0] sig_m_axi_gmem_out3_arregion;
  wire [2:0] sig_m_axi_gmem_out3_arsize;
  wire sig_m_axi_gmem_out3_aruser;
  wire sig_m_axi_gmem_out3_arvalid;
  wire [31:0] sig_m_axi_gmem_out3_awaddr;
  wire [1:0] sig_m_axi_gmem_out3_awburst;
  wire [3:0] sig_m_axi_gmem_out3_awcache;
  wire [5:0] sig_m_axi_gmem_out3_awid;
  wire [7:0] sig_m_axi_gmem_out3_awlen;
  wire sig_m_axi_gmem_out3_awlock;
  wire [2:0] sig_m_axi_gmem_out3_awprot;
  wire [3:0] sig_m_axi_gmem_out3_awqos;
  wire sig_m_axi_gmem_out3_awready;
  wire [3:0] sig_m_axi_gmem_out3_awregion;
  wire [2:0] sig_m_axi_gmem_out3_awsize;
  wire sig_m_axi_gmem_out3_awuser;
  wire sig_m_axi_gmem_out3_awvalid;
  wire [5:0] sig_m_axi_gmem_out3_bid;
  wire sig_m_axi_gmem_out3_bready;
  wire [1:0] sig_m_axi_gmem_out3_bresp;
  wire sig_m_axi_gmem_out3_buser;
  wire sig_m_axi_gmem_out3_bvalid;
  wire [31:0] sig_m_axi_gmem_out3_rdata;
  wire [5:0] sig_m_axi_gmem_out3_rid;
  wire sig_m_axi_gmem_out3_rlast;
  wire sig_m_axi_gmem_out3_rready;
  wire [1:0] sig_m_axi_gmem_out3_rresp;
  wire sig_m_axi_gmem_out3_ruser;
  wire sig_m_axi_gmem_out3_rvalid;
  wire [31:0] sig_m_axi_gmem_out3_wdata;
  wire sig_m_axi_gmem_out3_wlast;
  wire sig_m_axi_gmem_out3_wready;
  wire [3:0] sig_m_axi_gmem_out3_wstrb;
  wire sig_m_axi_gmem_out3_wuser;
  wire sig_m_axi_gmem_out3_wvalid;
  wire [31:0] sig_m_axi_gmem_out4_araddr;
  wire [1:0] sig_m_axi_gmem_out4_arburst;
  wire [3:0] sig_m_axi_gmem_out4_arcache;
  wire [5:0] sig_m_axi_gmem_out4_arid;
  wire [7:0] sig_m_axi_gmem_out4_arlen;
  wire sig_m_axi_gmem_out4_arlock;
  wire [2:0] sig_m_axi_gmem_out4_arprot;
  wire [3:0] sig_m_axi_gmem_out4_arqos;
  wire sig_m_axi_gmem_out4_arready;
  wire [3:0] sig_m_axi_gmem_out4_arregion;
  wire [2:0] sig_m_axi_gmem_out4_arsize;
  wire sig_m_axi_gmem_out4_aruser;
  wire sig_m_axi_gmem_out4_arvalid;
  wire [31:0] sig_m_axi_gmem_out4_awaddr;
  wire [1:0] sig_m_axi_gmem_out4_awburst;
  wire [3:0] sig_m_axi_gmem_out4_awcache;
  wire [5:0] sig_m_axi_gmem_out4_awid;
  wire [7:0] sig_m_axi_gmem_out4_awlen;
  wire sig_m_axi_gmem_out4_awlock;
  wire [2:0] sig_m_axi_gmem_out4_awprot;
  wire [3:0] sig_m_axi_gmem_out4_awqos;
  wire sig_m_axi_gmem_out4_awready;
  wire [3:0] sig_m_axi_gmem_out4_awregion;
  wire [2:0] sig_m_axi_gmem_out4_awsize;
  wire sig_m_axi_gmem_out4_awuser;
  wire sig_m_axi_gmem_out4_awvalid;
  wire [5:0] sig_m_axi_gmem_out4_bid;
  wire sig_m_axi_gmem_out4_bready;
  wire [1:0] sig_m_axi_gmem_out4_bresp;
  wire sig_m_axi_gmem_out4_buser;
  wire sig_m_axi_gmem_out4_bvalid;
  wire [31:0] sig_m_axi_gmem_out4_rdata;
  wire [5:0] sig_m_axi_gmem_out4_rid;
  wire sig_m_axi_gmem_out4_rlast;
  wire sig_m_axi_gmem_out4_rready;
  wire [1:0] sig_m_axi_gmem_out4_rresp;
  wire sig_m_axi_gmem_out4_ruser;
  wire sig_m_axi_gmem_out4_rvalid;
  wire [31:0] sig_m_axi_gmem_out4_wdata;
  wire sig_m_axi_gmem_out4_wlast;
  wire sig_m_axi_gmem_out4_wready;
  wire [3:0] sig_m_axi_gmem_out4_wstrb;
  wire sig_m_axi_gmem_out4_wuser;
  wire sig_m_axi_gmem_out4_wvalid;
  wire [31:0] sig_m_axi_gmem_out5_araddr;
  wire [1:0] sig_m_axi_gmem_out5_arburst;
  wire [3:0] sig_m_axi_gmem_out5_arcache;
  wire [5:0] sig_m_axi_gmem_out5_arid;
  wire [7:0] sig_m_axi_gmem_out5_arlen;
  wire sig_m_axi_gmem_out5_arlock;
  wire [2:0] sig_m_axi_gmem_out5_arprot;
  wire [3:0] sig_m_axi_gmem_out5_arqos;
  wire sig_m_axi_gmem_out5_arready;
  wire [3:0] sig_m_axi_gmem_out5_arregion;
  wire [2:0] sig_m_axi_gmem_out5_arsize;
  wire sig_m_axi_gmem_out5_aruser;
  wire sig_m_axi_gmem_out5_arvalid;
  wire [31:0] sig_m_axi_gmem_out5_awaddr;
  wire [1:0] sig_m_axi_gmem_out5_awburst;
  wire [3:0] sig_m_axi_gmem_out5_awcache;
  wire [5:0] sig_m_axi_gmem_out5_awid;
  wire [7:0] sig_m_axi_gmem_out5_awlen;
  wire sig_m_axi_gmem_out5_awlock;
  wire [2:0] sig_m_axi_gmem_out5_awprot;
  wire [3:0] sig_m_axi_gmem_out5_awqos;
  wire sig_m_axi_gmem_out5_awready;
  wire [3:0] sig_m_axi_gmem_out5_awregion;
  wire [2:0] sig_m_axi_gmem_out5_awsize;
  wire sig_m_axi_gmem_out5_awuser;
  wire sig_m_axi_gmem_out5_awvalid;
  wire [5:0] sig_m_axi_gmem_out5_bid;
  wire sig_m_axi_gmem_out5_bready;
  wire [1:0] sig_m_axi_gmem_out5_bresp;
  wire sig_m_axi_gmem_out5_buser;
  wire sig_m_axi_gmem_out5_bvalid;
  wire [31:0] sig_m_axi_gmem_out5_rdata;
  wire [5:0] sig_m_axi_gmem_out5_rid;
  wire sig_m_axi_gmem_out5_rlast;
  wire sig_m_axi_gmem_out5_rready;
  wire [1:0] sig_m_axi_gmem_out5_rresp;
  wire sig_m_axi_gmem_out5_ruser;
  wire sig_m_axi_gmem_out5_rvalid;
  wire [31:0] sig_m_axi_gmem_out5_wdata;
  wire sig_m_axi_gmem_out5_wlast;
  wire sig_m_axi_gmem_out5_wready;
  wire [3:0] sig_m_axi_gmem_out5_wstrb;
  wire sig_m_axi_gmem_out5_wuser;
  wire sig_m_axi_gmem_out5_wvalid;
  wire [31:0] sig_m_axi_gmem_out6_araddr;
  wire [1:0] sig_m_axi_gmem_out6_arburst;
  wire [3:0] sig_m_axi_gmem_out6_arcache;
  wire [5:0] sig_m_axi_gmem_out6_arid;
  wire [7:0] sig_m_axi_gmem_out6_arlen;
  wire sig_m_axi_gmem_out6_arlock;
  wire [2:0] sig_m_axi_gmem_out6_arprot;
  wire [3:0] sig_m_axi_gmem_out6_arqos;
  wire sig_m_axi_gmem_out6_arready;
  wire [3:0] sig_m_axi_gmem_out6_arregion;
  wire [2:0] sig_m_axi_gmem_out6_arsize;
  wire sig_m_axi_gmem_out6_aruser;
  wire sig_m_axi_gmem_out6_arvalid;
  wire [31:0] sig_m_axi_gmem_out6_awaddr;
  wire [1:0] sig_m_axi_gmem_out6_awburst;
  wire [3:0] sig_m_axi_gmem_out6_awcache;
  wire [5:0] sig_m_axi_gmem_out6_awid;
  wire [7:0] sig_m_axi_gmem_out6_awlen;
  wire sig_m_axi_gmem_out6_awlock;
  wire [2:0] sig_m_axi_gmem_out6_awprot;
  wire [3:0] sig_m_axi_gmem_out6_awqos;
  wire sig_m_axi_gmem_out6_awready;
  wire [3:0] sig_m_axi_gmem_out6_awregion;
  wire [2:0] sig_m_axi_gmem_out6_awsize;
  wire sig_m_axi_gmem_out6_awuser;
  wire sig_m_axi_gmem_out6_awvalid;
  wire [5:0] sig_m_axi_gmem_out6_bid;
  wire sig_m_axi_gmem_out6_bready;
  wire [1:0] sig_m_axi_gmem_out6_bresp;
  wire sig_m_axi_gmem_out6_buser;
  wire sig_m_axi_gmem_out6_bvalid;
  wire [31:0] sig_m_axi_gmem_out6_rdata;
  wire [5:0] sig_m_axi_gmem_out6_rid;
  wire sig_m_axi_gmem_out6_rlast;
  wire sig_m_axi_gmem_out6_rready;
  wire [1:0] sig_m_axi_gmem_out6_rresp;
  wire sig_m_axi_gmem_out6_ruser;
  wire sig_m_axi_gmem_out6_rvalid;
  wire [31:0] sig_m_axi_gmem_out6_wdata;
  wire sig_m_axi_gmem_out6_wlast;
  wire sig_m_axi_gmem_out6_wready;
  wire [3:0] sig_m_axi_gmem_out6_wstrb;
  wire sig_m_axi_gmem_out6_wuser;
  wire sig_m_axi_gmem_out6_wvalid;
  wire [31:0] sig_m_axi_gmem_out7_araddr;
  wire [1:0] sig_m_axi_gmem_out7_arburst;
  wire [3:0] sig_m_axi_gmem_out7_arcache;
  wire [5:0] sig_m_axi_gmem_out7_arid;
  wire [7:0] sig_m_axi_gmem_out7_arlen;
  wire sig_m_axi_gmem_out7_arlock;
  wire [2:0] sig_m_axi_gmem_out7_arprot;
  wire [3:0] sig_m_axi_gmem_out7_arqos;
  wire sig_m_axi_gmem_out7_arready;
  wire [3:0] sig_m_axi_gmem_out7_arregion;
  wire [2:0] sig_m_axi_gmem_out7_arsize;
  wire sig_m_axi_gmem_out7_aruser;
  wire sig_m_axi_gmem_out7_arvalid;
  wire [31:0] sig_m_axi_gmem_out7_awaddr;
  wire [1:0] sig_m_axi_gmem_out7_awburst;
  wire [3:0] sig_m_axi_gmem_out7_awcache;
  wire [5:0] sig_m_axi_gmem_out7_awid;
  wire [7:0] sig_m_axi_gmem_out7_awlen;
  wire sig_m_axi_gmem_out7_awlock;
  wire [2:0] sig_m_axi_gmem_out7_awprot;
  wire [3:0] sig_m_axi_gmem_out7_awqos;
  wire sig_m_axi_gmem_out7_awready;
  wire [3:0] sig_m_axi_gmem_out7_awregion;
  wire [2:0] sig_m_axi_gmem_out7_awsize;
  wire sig_m_axi_gmem_out7_awuser;
  wire sig_m_axi_gmem_out7_awvalid;
  wire [5:0] sig_m_axi_gmem_out7_bid;
  wire sig_m_axi_gmem_out7_bready;
  wire [1:0] sig_m_axi_gmem_out7_bresp;
  wire sig_m_axi_gmem_out7_buser;
  wire sig_m_axi_gmem_out7_bvalid;
  wire [31:0] sig_m_axi_gmem_out7_rdata;
  wire [5:0] sig_m_axi_gmem_out7_rid;
  wire sig_m_axi_gmem_out7_rlast;
  wire sig_m_axi_gmem_out7_rready;
  wire [1:0] sig_m_axi_gmem_out7_rresp;
  wire sig_m_axi_gmem_out7_ruser;
  wire sig_m_axi_gmem_out7_rvalid;
  wire [31:0] sig_m_axi_gmem_out7_wdata;
  wire sig_m_axi_gmem_out7_wlast;
  wire sig_m_axi_gmem_out7_wready;
  wire [3:0] sig_m_axi_gmem_out7_wstrb;
  wire sig_m_axi_gmem_out7_wuser;
  wire sig_m_axi_gmem_out7_wvalid;
  wire [31:0] sig_m_axi_gmem_w0_araddr;
  wire [1:0] sig_m_axi_gmem_w0_arburst;
  wire [3:0] sig_m_axi_gmem_w0_arcache;
  wire [5:0] sig_m_axi_gmem_w0_arid;
  wire [7:0] sig_m_axi_gmem_w0_arlen;
  wire sig_m_axi_gmem_w0_arlock;
  wire [2:0] sig_m_axi_gmem_w0_arprot;
  wire [3:0] sig_m_axi_gmem_w0_arqos;
  wire sig_m_axi_gmem_w0_arready;
  wire [3:0] sig_m_axi_gmem_w0_arregion;
  wire [2:0] sig_m_axi_gmem_w0_arsize;
  wire sig_m_axi_gmem_w0_aruser;
  wire sig_m_axi_gmem_w0_arvalid;
  wire [31:0] sig_m_axi_gmem_w0_awaddr;
  wire [1:0] sig_m_axi_gmem_w0_awburst;
  wire [3:0] sig_m_axi_gmem_w0_awcache;
  wire [5:0] sig_m_axi_gmem_w0_awid;
  wire [7:0] sig_m_axi_gmem_w0_awlen;
  wire sig_m_axi_gmem_w0_awlock;
  wire [2:0] sig_m_axi_gmem_w0_awprot;
  wire [3:0] sig_m_axi_gmem_w0_awqos;
  wire sig_m_axi_gmem_w0_awready;
  wire [3:0] sig_m_axi_gmem_w0_awregion;
  wire [2:0] sig_m_axi_gmem_w0_awsize;
  wire sig_m_axi_gmem_w0_awuser;
  wire sig_m_axi_gmem_w0_awvalid;
  wire [5:0] sig_m_axi_gmem_w0_bid;
  wire sig_m_axi_gmem_w0_bready;
  wire [1:0] sig_m_axi_gmem_w0_bresp;
  wire sig_m_axi_gmem_w0_buser;
  wire sig_m_axi_gmem_w0_bvalid;
  wire [31:0] sig_m_axi_gmem_w0_rdata;
  wire [5:0] sig_m_axi_gmem_w0_rid;
  wire sig_m_axi_gmem_w0_rlast;
  wire sig_m_axi_gmem_w0_rready;
  wire [1:0] sig_m_axi_gmem_w0_rresp;
  wire sig_m_axi_gmem_w0_ruser;
  wire sig_m_axi_gmem_w0_rvalid;
  wire [31:0] sig_m_axi_gmem_w0_wdata;
  wire sig_m_axi_gmem_w0_wlast;
  wire sig_m_axi_gmem_w0_wready;
  wire [3:0] sig_m_axi_gmem_w0_wstrb;
  wire sig_m_axi_gmem_w0_wuser;
  wire sig_m_axi_gmem_w0_wvalid;
  wire [31:0] sig_m_axi_gmem_w1_araddr;
  wire [1:0] sig_m_axi_gmem_w1_arburst;
  wire [3:0] sig_m_axi_gmem_w1_arcache;
  wire [5:0] sig_m_axi_gmem_w1_arid;
  wire [7:0] sig_m_axi_gmem_w1_arlen;
  wire sig_m_axi_gmem_w1_arlock;
  wire [2:0] sig_m_axi_gmem_w1_arprot;
  wire [3:0] sig_m_axi_gmem_w1_arqos;
  wire sig_m_axi_gmem_w1_arready;
  wire [3:0] sig_m_axi_gmem_w1_arregion;
  wire [2:0] sig_m_axi_gmem_w1_arsize;
  wire sig_m_axi_gmem_w1_aruser;
  wire sig_m_axi_gmem_w1_arvalid;
  wire [31:0] sig_m_axi_gmem_w1_awaddr;
  wire [1:0] sig_m_axi_gmem_w1_awburst;
  wire [3:0] sig_m_axi_gmem_w1_awcache;
  wire [5:0] sig_m_axi_gmem_w1_awid;
  wire [7:0] sig_m_axi_gmem_w1_awlen;
  wire sig_m_axi_gmem_w1_awlock;
  wire [2:0] sig_m_axi_gmem_w1_awprot;
  wire [3:0] sig_m_axi_gmem_w1_awqos;
  wire sig_m_axi_gmem_w1_awready;
  wire [3:0] sig_m_axi_gmem_w1_awregion;
  wire [2:0] sig_m_axi_gmem_w1_awsize;
  wire sig_m_axi_gmem_w1_awuser;
  wire sig_m_axi_gmem_w1_awvalid;
  wire [5:0] sig_m_axi_gmem_w1_bid;
  wire sig_m_axi_gmem_w1_bready;
  wire [1:0] sig_m_axi_gmem_w1_bresp;
  wire sig_m_axi_gmem_w1_buser;
  wire sig_m_axi_gmem_w1_bvalid;
  wire [31:0] sig_m_axi_gmem_w1_rdata;
  wire [5:0] sig_m_axi_gmem_w1_rid;
  wire sig_m_axi_gmem_w1_rlast;
  wire sig_m_axi_gmem_w1_rready;
  wire [1:0] sig_m_axi_gmem_w1_rresp;
  wire sig_m_axi_gmem_w1_ruser;
  wire sig_m_axi_gmem_w1_rvalid;
  wire [31:0] sig_m_axi_gmem_w1_wdata;
  wire sig_m_axi_gmem_w1_wlast;
  wire sig_m_axi_gmem_w1_wready;
  wire [3:0] sig_m_axi_gmem_w1_wstrb;
  wire sig_m_axi_gmem_w1_wuser;
  wire sig_m_axi_gmem_w1_wvalid;
  wire sig_reset;
  wire sig_setup_port;
  wire sig_start_port;
  
  TestbenchDUT DUT (.done_port(sig_done_port),
    .m_axi_gmem_in0_awid(sig_m_axi_gmem_in0_awid),
    .m_axi_gmem_in0_awaddr(sig_m_axi_gmem_in0_awaddr),
    .m_axi_gmem_in0_awlen(sig_m_axi_gmem_in0_awlen),
    .m_axi_gmem_in0_awsize(sig_m_axi_gmem_in0_awsize),
    .m_axi_gmem_in0_awburst(sig_m_axi_gmem_in0_awburst),
    .m_axi_gmem_in0_awlock(sig_m_axi_gmem_in0_awlock),
    .m_axi_gmem_in0_awcache(sig_m_axi_gmem_in0_awcache),
    .m_axi_gmem_in0_awprot(sig_m_axi_gmem_in0_awprot),
    .m_axi_gmem_in0_awqos(sig_m_axi_gmem_in0_awqos),
    .m_axi_gmem_in0_awregion(sig_m_axi_gmem_in0_awregion),
    .m_axi_gmem_in0_awuser(sig_m_axi_gmem_in0_awuser),
    .m_axi_gmem_in0_awvalid(sig_m_axi_gmem_in0_awvalid),
    .m_axi_gmem_in0_wdata(sig_m_axi_gmem_in0_wdata),
    .m_axi_gmem_in0_wstrb(sig_m_axi_gmem_in0_wstrb),
    .m_axi_gmem_in0_wlast(sig_m_axi_gmem_in0_wlast),
    .m_axi_gmem_in0_wuser(sig_m_axi_gmem_in0_wuser),
    .m_axi_gmem_in0_wvalid(sig_m_axi_gmem_in0_wvalid),
    .m_axi_gmem_in0_bready(sig_m_axi_gmem_in0_bready),
    .m_axi_gmem_in0_arid(sig_m_axi_gmem_in0_arid),
    .m_axi_gmem_in0_araddr(sig_m_axi_gmem_in0_araddr),
    .m_axi_gmem_in0_arlen(sig_m_axi_gmem_in0_arlen),
    .m_axi_gmem_in0_arsize(sig_m_axi_gmem_in0_arsize),
    .m_axi_gmem_in0_arburst(sig_m_axi_gmem_in0_arburst),
    .m_axi_gmem_in0_arlock(sig_m_axi_gmem_in0_arlock),
    .m_axi_gmem_in0_arcache(sig_m_axi_gmem_in0_arcache),
    .m_axi_gmem_in0_arprot(sig_m_axi_gmem_in0_arprot),
    .m_axi_gmem_in0_arqos(sig_m_axi_gmem_in0_arqos),
    .m_axi_gmem_in0_arregion(sig_m_axi_gmem_in0_arregion),
    .m_axi_gmem_in0_aruser(sig_m_axi_gmem_in0_aruser),
    .m_axi_gmem_in0_arvalid(sig_m_axi_gmem_in0_arvalid),
    .m_axi_gmem_in0_rready(sig_m_axi_gmem_in0_rready),
    .m_axi_gmem_in1_awid(sig_m_axi_gmem_in1_awid),
    .m_axi_gmem_in1_awaddr(sig_m_axi_gmem_in1_awaddr),
    .m_axi_gmem_in1_awlen(sig_m_axi_gmem_in1_awlen),
    .m_axi_gmem_in1_awsize(sig_m_axi_gmem_in1_awsize),
    .m_axi_gmem_in1_awburst(sig_m_axi_gmem_in1_awburst),
    .m_axi_gmem_in1_awlock(sig_m_axi_gmem_in1_awlock),
    .m_axi_gmem_in1_awcache(sig_m_axi_gmem_in1_awcache),
    .m_axi_gmem_in1_awprot(sig_m_axi_gmem_in1_awprot),
    .m_axi_gmem_in1_awqos(sig_m_axi_gmem_in1_awqos),
    .m_axi_gmem_in1_awregion(sig_m_axi_gmem_in1_awregion),
    .m_axi_gmem_in1_awuser(sig_m_axi_gmem_in1_awuser),
    .m_axi_gmem_in1_awvalid(sig_m_axi_gmem_in1_awvalid),
    .m_axi_gmem_in1_wdata(sig_m_axi_gmem_in1_wdata),
    .m_axi_gmem_in1_wstrb(sig_m_axi_gmem_in1_wstrb),
    .m_axi_gmem_in1_wlast(sig_m_axi_gmem_in1_wlast),
    .m_axi_gmem_in1_wuser(sig_m_axi_gmem_in1_wuser),
    .m_axi_gmem_in1_wvalid(sig_m_axi_gmem_in1_wvalid),
    .m_axi_gmem_in1_bready(sig_m_axi_gmem_in1_bready),
    .m_axi_gmem_in1_arid(sig_m_axi_gmem_in1_arid),
    .m_axi_gmem_in1_araddr(sig_m_axi_gmem_in1_araddr),
    .m_axi_gmem_in1_arlen(sig_m_axi_gmem_in1_arlen),
    .m_axi_gmem_in1_arsize(sig_m_axi_gmem_in1_arsize),
    .m_axi_gmem_in1_arburst(sig_m_axi_gmem_in1_arburst),
    .m_axi_gmem_in1_arlock(sig_m_axi_gmem_in1_arlock),
    .m_axi_gmem_in1_arcache(sig_m_axi_gmem_in1_arcache),
    .m_axi_gmem_in1_arprot(sig_m_axi_gmem_in1_arprot),
    .m_axi_gmem_in1_arqos(sig_m_axi_gmem_in1_arqos),
    .m_axi_gmem_in1_arregion(sig_m_axi_gmem_in1_arregion),
    .m_axi_gmem_in1_aruser(sig_m_axi_gmem_in1_aruser),
    .m_axi_gmem_in1_arvalid(sig_m_axi_gmem_in1_arvalid),
    .m_axi_gmem_in1_rready(sig_m_axi_gmem_in1_rready),
    .m_axi_gmem_out0_awid(sig_m_axi_gmem_out0_awid),
    .m_axi_gmem_out0_awaddr(sig_m_axi_gmem_out0_awaddr),
    .m_axi_gmem_out0_awlen(sig_m_axi_gmem_out0_awlen),
    .m_axi_gmem_out0_awsize(sig_m_axi_gmem_out0_awsize),
    .m_axi_gmem_out0_awburst(sig_m_axi_gmem_out0_awburst),
    .m_axi_gmem_out0_awlock(sig_m_axi_gmem_out0_awlock),
    .m_axi_gmem_out0_awcache(sig_m_axi_gmem_out0_awcache),
    .m_axi_gmem_out0_awprot(sig_m_axi_gmem_out0_awprot),
    .m_axi_gmem_out0_awqos(sig_m_axi_gmem_out0_awqos),
    .m_axi_gmem_out0_awregion(sig_m_axi_gmem_out0_awregion),
    .m_axi_gmem_out0_awuser(sig_m_axi_gmem_out0_awuser),
    .m_axi_gmem_out0_awvalid(sig_m_axi_gmem_out0_awvalid),
    .m_axi_gmem_out0_wdata(sig_m_axi_gmem_out0_wdata),
    .m_axi_gmem_out0_wstrb(sig_m_axi_gmem_out0_wstrb),
    .m_axi_gmem_out0_wlast(sig_m_axi_gmem_out0_wlast),
    .m_axi_gmem_out0_wuser(sig_m_axi_gmem_out0_wuser),
    .m_axi_gmem_out0_wvalid(sig_m_axi_gmem_out0_wvalid),
    .m_axi_gmem_out0_bready(sig_m_axi_gmem_out0_bready),
    .m_axi_gmem_out0_arid(sig_m_axi_gmem_out0_arid),
    .m_axi_gmem_out0_araddr(sig_m_axi_gmem_out0_araddr),
    .m_axi_gmem_out0_arlen(sig_m_axi_gmem_out0_arlen),
    .m_axi_gmem_out0_arsize(sig_m_axi_gmem_out0_arsize),
    .m_axi_gmem_out0_arburst(sig_m_axi_gmem_out0_arburst),
    .m_axi_gmem_out0_arlock(sig_m_axi_gmem_out0_arlock),
    .m_axi_gmem_out0_arcache(sig_m_axi_gmem_out0_arcache),
    .m_axi_gmem_out0_arprot(sig_m_axi_gmem_out0_arprot),
    .m_axi_gmem_out0_arqos(sig_m_axi_gmem_out0_arqos),
    .m_axi_gmem_out0_arregion(sig_m_axi_gmem_out0_arregion),
    .m_axi_gmem_out0_aruser(sig_m_axi_gmem_out0_aruser),
    .m_axi_gmem_out0_arvalid(sig_m_axi_gmem_out0_arvalid),
    .m_axi_gmem_out0_rready(sig_m_axi_gmem_out0_rready),
    .m_axi_gmem_out1_awid(sig_m_axi_gmem_out1_awid),
    .m_axi_gmem_out1_awaddr(sig_m_axi_gmem_out1_awaddr),
    .m_axi_gmem_out1_awlen(sig_m_axi_gmem_out1_awlen),
    .m_axi_gmem_out1_awsize(sig_m_axi_gmem_out1_awsize),
    .m_axi_gmem_out1_awburst(sig_m_axi_gmem_out1_awburst),
    .m_axi_gmem_out1_awlock(sig_m_axi_gmem_out1_awlock),
    .m_axi_gmem_out1_awcache(sig_m_axi_gmem_out1_awcache),
    .m_axi_gmem_out1_awprot(sig_m_axi_gmem_out1_awprot),
    .m_axi_gmem_out1_awqos(sig_m_axi_gmem_out1_awqos),
    .m_axi_gmem_out1_awregion(sig_m_axi_gmem_out1_awregion),
    .m_axi_gmem_out1_awuser(sig_m_axi_gmem_out1_awuser),
    .m_axi_gmem_out1_awvalid(sig_m_axi_gmem_out1_awvalid),
    .m_axi_gmem_out1_wdata(sig_m_axi_gmem_out1_wdata),
    .m_axi_gmem_out1_wstrb(sig_m_axi_gmem_out1_wstrb),
    .m_axi_gmem_out1_wlast(sig_m_axi_gmem_out1_wlast),
    .m_axi_gmem_out1_wuser(sig_m_axi_gmem_out1_wuser),
    .m_axi_gmem_out1_wvalid(sig_m_axi_gmem_out1_wvalid),
    .m_axi_gmem_out1_bready(sig_m_axi_gmem_out1_bready),
    .m_axi_gmem_out1_arid(sig_m_axi_gmem_out1_arid),
    .m_axi_gmem_out1_araddr(sig_m_axi_gmem_out1_araddr),
    .m_axi_gmem_out1_arlen(sig_m_axi_gmem_out1_arlen),
    .m_axi_gmem_out1_arsize(sig_m_axi_gmem_out1_arsize),
    .m_axi_gmem_out1_arburst(sig_m_axi_gmem_out1_arburst),
    .m_axi_gmem_out1_arlock(sig_m_axi_gmem_out1_arlock),
    .m_axi_gmem_out1_arcache(sig_m_axi_gmem_out1_arcache),
    .m_axi_gmem_out1_arprot(sig_m_axi_gmem_out1_arprot),
    .m_axi_gmem_out1_arqos(sig_m_axi_gmem_out1_arqos),
    .m_axi_gmem_out1_arregion(sig_m_axi_gmem_out1_arregion),
    .m_axi_gmem_out1_aruser(sig_m_axi_gmem_out1_aruser),
    .m_axi_gmem_out1_arvalid(sig_m_axi_gmem_out1_arvalid),
    .m_axi_gmem_out1_rready(sig_m_axi_gmem_out1_rready),
    .m_axi_gmem_out2_awid(sig_m_axi_gmem_out2_awid),
    .m_axi_gmem_out2_awaddr(sig_m_axi_gmem_out2_awaddr),
    .m_axi_gmem_out2_awlen(sig_m_axi_gmem_out2_awlen),
    .m_axi_gmem_out2_awsize(sig_m_axi_gmem_out2_awsize),
    .m_axi_gmem_out2_awburst(sig_m_axi_gmem_out2_awburst),
    .m_axi_gmem_out2_awlock(sig_m_axi_gmem_out2_awlock),
    .m_axi_gmem_out2_awcache(sig_m_axi_gmem_out2_awcache),
    .m_axi_gmem_out2_awprot(sig_m_axi_gmem_out2_awprot),
    .m_axi_gmem_out2_awqos(sig_m_axi_gmem_out2_awqos),
    .m_axi_gmem_out2_awregion(sig_m_axi_gmem_out2_awregion),
    .m_axi_gmem_out2_awuser(sig_m_axi_gmem_out2_awuser),
    .m_axi_gmem_out2_awvalid(sig_m_axi_gmem_out2_awvalid),
    .m_axi_gmem_out2_wdata(sig_m_axi_gmem_out2_wdata),
    .m_axi_gmem_out2_wstrb(sig_m_axi_gmem_out2_wstrb),
    .m_axi_gmem_out2_wlast(sig_m_axi_gmem_out2_wlast),
    .m_axi_gmem_out2_wuser(sig_m_axi_gmem_out2_wuser),
    .m_axi_gmem_out2_wvalid(sig_m_axi_gmem_out2_wvalid),
    .m_axi_gmem_out2_bready(sig_m_axi_gmem_out2_bready),
    .m_axi_gmem_out2_arid(sig_m_axi_gmem_out2_arid),
    .m_axi_gmem_out2_araddr(sig_m_axi_gmem_out2_araddr),
    .m_axi_gmem_out2_arlen(sig_m_axi_gmem_out2_arlen),
    .m_axi_gmem_out2_arsize(sig_m_axi_gmem_out2_arsize),
    .m_axi_gmem_out2_arburst(sig_m_axi_gmem_out2_arburst),
    .m_axi_gmem_out2_arlock(sig_m_axi_gmem_out2_arlock),
    .m_axi_gmem_out2_arcache(sig_m_axi_gmem_out2_arcache),
    .m_axi_gmem_out2_arprot(sig_m_axi_gmem_out2_arprot),
    .m_axi_gmem_out2_arqos(sig_m_axi_gmem_out2_arqos),
    .m_axi_gmem_out2_arregion(sig_m_axi_gmem_out2_arregion),
    .m_axi_gmem_out2_aruser(sig_m_axi_gmem_out2_aruser),
    .m_axi_gmem_out2_arvalid(sig_m_axi_gmem_out2_arvalid),
    .m_axi_gmem_out2_rready(sig_m_axi_gmem_out2_rready),
    .m_axi_gmem_out3_awid(sig_m_axi_gmem_out3_awid),
    .m_axi_gmem_out3_awaddr(sig_m_axi_gmem_out3_awaddr),
    .m_axi_gmem_out3_awlen(sig_m_axi_gmem_out3_awlen),
    .m_axi_gmem_out3_awsize(sig_m_axi_gmem_out3_awsize),
    .m_axi_gmem_out3_awburst(sig_m_axi_gmem_out3_awburst),
    .m_axi_gmem_out3_awlock(sig_m_axi_gmem_out3_awlock),
    .m_axi_gmem_out3_awcache(sig_m_axi_gmem_out3_awcache),
    .m_axi_gmem_out3_awprot(sig_m_axi_gmem_out3_awprot),
    .m_axi_gmem_out3_awqos(sig_m_axi_gmem_out3_awqos),
    .m_axi_gmem_out3_awregion(sig_m_axi_gmem_out3_awregion),
    .m_axi_gmem_out3_awuser(sig_m_axi_gmem_out3_awuser),
    .m_axi_gmem_out3_awvalid(sig_m_axi_gmem_out3_awvalid),
    .m_axi_gmem_out3_wdata(sig_m_axi_gmem_out3_wdata),
    .m_axi_gmem_out3_wstrb(sig_m_axi_gmem_out3_wstrb),
    .m_axi_gmem_out3_wlast(sig_m_axi_gmem_out3_wlast),
    .m_axi_gmem_out3_wuser(sig_m_axi_gmem_out3_wuser),
    .m_axi_gmem_out3_wvalid(sig_m_axi_gmem_out3_wvalid),
    .m_axi_gmem_out3_bready(sig_m_axi_gmem_out3_bready),
    .m_axi_gmem_out3_arid(sig_m_axi_gmem_out3_arid),
    .m_axi_gmem_out3_araddr(sig_m_axi_gmem_out3_araddr),
    .m_axi_gmem_out3_arlen(sig_m_axi_gmem_out3_arlen),
    .m_axi_gmem_out3_arsize(sig_m_axi_gmem_out3_arsize),
    .m_axi_gmem_out3_arburst(sig_m_axi_gmem_out3_arburst),
    .m_axi_gmem_out3_arlock(sig_m_axi_gmem_out3_arlock),
    .m_axi_gmem_out3_arcache(sig_m_axi_gmem_out3_arcache),
    .m_axi_gmem_out3_arprot(sig_m_axi_gmem_out3_arprot),
    .m_axi_gmem_out3_arqos(sig_m_axi_gmem_out3_arqos),
    .m_axi_gmem_out3_arregion(sig_m_axi_gmem_out3_arregion),
    .m_axi_gmem_out3_aruser(sig_m_axi_gmem_out3_aruser),
    .m_axi_gmem_out3_arvalid(sig_m_axi_gmem_out3_arvalid),
    .m_axi_gmem_out3_rready(sig_m_axi_gmem_out3_rready),
    .m_axi_gmem_out4_awid(sig_m_axi_gmem_out4_awid),
    .m_axi_gmem_out4_awaddr(sig_m_axi_gmem_out4_awaddr),
    .m_axi_gmem_out4_awlen(sig_m_axi_gmem_out4_awlen),
    .m_axi_gmem_out4_awsize(sig_m_axi_gmem_out4_awsize),
    .m_axi_gmem_out4_awburst(sig_m_axi_gmem_out4_awburst),
    .m_axi_gmem_out4_awlock(sig_m_axi_gmem_out4_awlock),
    .m_axi_gmem_out4_awcache(sig_m_axi_gmem_out4_awcache),
    .m_axi_gmem_out4_awprot(sig_m_axi_gmem_out4_awprot),
    .m_axi_gmem_out4_awqos(sig_m_axi_gmem_out4_awqos),
    .m_axi_gmem_out4_awregion(sig_m_axi_gmem_out4_awregion),
    .m_axi_gmem_out4_awuser(sig_m_axi_gmem_out4_awuser),
    .m_axi_gmem_out4_awvalid(sig_m_axi_gmem_out4_awvalid),
    .m_axi_gmem_out4_wdata(sig_m_axi_gmem_out4_wdata),
    .m_axi_gmem_out4_wstrb(sig_m_axi_gmem_out4_wstrb),
    .m_axi_gmem_out4_wlast(sig_m_axi_gmem_out4_wlast),
    .m_axi_gmem_out4_wuser(sig_m_axi_gmem_out4_wuser),
    .m_axi_gmem_out4_wvalid(sig_m_axi_gmem_out4_wvalid),
    .m_axi_gmem_out4_bready(sig_m_axi_gmem_out4_bready),
    .m_axi_gmem_out4_arid(sig_m_axi_gmem_out4_arid),
    .m_axi_gmem_out4_araddr(sig_m_axi_gmem_out4_araddr),
    .m_axi_gmem_out4_arlen(sig_m_axi_gmem_out4_arlen),
    .m_axi_gmem_out4_arsize(sig_m_axi_gmem_out4_arsize),
    .m_axi_gmem_out4_arburst(sig_m_axi_gmem_out4_arburst),
    .m_axi_gmem_out4_arlock(sig_m_axi_gmem_out4_arlock),
    .m_axi_gmem_out4_arcache(sig_m_axi_gmem_out4_arcache),
    .m_axi_gmem_out4_arprot(sig_m_axi_gmem_out4_arprot),
    .m_axi_gmem_out4_arqos(sig_m_axi_gmem_out4_arqos),
    .m_axi_gmem_out4_arregion(sig_m_axi_gmem_out4_arregion),
    .m_axi_gmem_out4_aruser(sig_m_axi_gmem_out4_aruser),
    .m_axi_gmem_out4_arvalid(sig_m_axi_gmem_out4_arvalid),
    .m_axi_gmem_out4_rready(sig_m_axi_gmem_out4_rready),
    .m_axi_gmem_out5_awid(sig_m_axi_gmem_out5_awid),
    .m_axi_gmem_out5_awaddr(sig_m_axi_gmem_out5_awaddr),
    .m_axi_gmem_out5_awlen(sig_m_axi_gmem_out5_awlen),
    .m_axi_gmem_out5_awsize(sig_m_axi_gmem_out5_awsize),
    .m_axi_gmem_out5_awburst(sig_m_axi_gmem_out5_awburst),
    .m_axi_gmem_out5_awlock(sig_m_axi_gmem_out5_awlock),
    .m_axi_gmem_out5_awcache(sig_m_axi_gmem_out5_awcache),
    .m_axi_gmem_out5_awprot(sig_m_axi_gmem_out5_awprot),
    .m_axi_gmem_out5_awqos(sig_m_axi_gmem_out5_awqos),
    .m_axi_gmem_out5_awregion(sig_m_axi_gmem_out5_awregion),
    .m_axi_gmem_out5_awuser(sig_m_axi_gmem_out5_awuser),
    .m_axi_gmem_out5_awvalid(sig_m_axi_gmem_out5_awvalid),
    .m_axi_gmem_out5_wdata(sig_m_axi_gmem_out5_wdata),
    .m_axi_gmem_out5_wstrb(sig_m_axi_gmem_out5_wstrb),
    .m_axi_gmem_out5_wlast(sig_m_axi_gmem_out5_wlast),
    .m_axi_gmem_out5_wuser(sig_m_axi_gmem_out5_wuser),
    .m_axi_gmem_out5_wvalid(sig_m_axi_gmem_out5_wvalid),
    .m_axi_gmem_out5_bready(sig_m_axi_gmem_out5_bready),
    .m_axi_gmem_out5_arid(sig_m_axi_gmem_out5_arid),
    .m_axi_gmem_out5_araddr(sig_m_axi_gmem_out5_araddr),
    .m_axi_gmem_out5_arlen(sig_m_axi_gmem_out5_arlen),
    .m_axi_gmem_out5_arsize(sig_m_axi_gmem_out5_arsize),
    .m_axi_gmem_out5_arburst(sig_m_axi_gmem_out5_arburst),
    .m_axi_gmem_out5_arlock(sig_m_axi_gmem_out5_arlock),
    .m_axi_gmem_out5_arcache(sig_m_axi_gmem_out5_arcache),
    .m_axi_gmem_out5_arprot(sig_m_axi_gmem_out5_arprot),
    .m_axi_gmem_out5_arqos(sig_m_axi_gmem_out5_arqos),
    .m_axi_gmem_out5_arregion(sig_m_axi_gmem_out5_arregion),
    .m_axi_gmem_out5_aruser(sig_m_axi_gmem_out5_aruser),
    .m_axi_gmem_out5_arvalid(sig_m_axi_gmem_out5_arvalid),
    .m_axi_gmem_out5_rready(sig_m_axi_gmem_out5_rready),
    .m_axi_gmem_out6_awid(sig_m_axi_gmem_out6_awid),
    .m_axi_gmem_out6_awaddr(sig_m_axi_gmem_out6_awaddr),
    .m_axi_gmem_out6_awlen(sig_m_axi_gmem_out6_awlen),
    .m_axi_gmem_out6_awsize(sig_m_axi_gmem_out6_awsize),
    .m_axi_gmem_out6_awburst(sig_m_axi_gmem_out6_awburst),
    .m_axi_gmem_out6_awlock(sig_m_axi_gmem_out6_awlock),
    .m_axi_gmem_out6_awcache(sig_m_axi_gmem_out6_awcache),
    .m_axi_gmem_out6_awprot(sig_m_axi_gmem_out6_awprot),
    .m_axi_gmem_out6_awqos(sig_m_axi_gmem_out6_awqos),
    .m_axi_gmem_out6_awregion(sig_m_axi_gmem_out6_awregion),
    .m_axi_gmem_out6_awuser(sig_m_axi_gmem_out6_awuser),
    .m_axi_gmem_out6_awvalid(sig_m_axi_gmem_out6_awvalid),
    .m_axi_gmem_out6_wdata(sig_m_axi_gmem_out6_wdata),
    .m_axi_gmem_out6_wstrb(sig_m_axi_gmem_out6_wstrb),
    .m_axi_gmem_out6_wlast(sig_m_axi_gmem_out6_wlast),
    .m_axi_gmem_out6_wuser(sig_m_axi_gmem_out6_wuser),
    .m_axi_gmem_out6_wvalid(sig_m_axi_gmem_out6_wvalid),
    .m_axi_gmem_out6_bready(sig_m_axi_gmem_out6_bready),
    .m_axi_gmem_out6_arid(sig_m_axi_gmem_out6_arid),
    .m_axi_gmem_out6_araddr(sig_m_axi_gmem_out6_araddr),
    .m_axi_gmem_out6_arlen(sig_m_axi_gmem_out6_arlen),
    .m_axi_gmem_out6_arsize(sig_m_axi_gmem_out6_arsize),
    .m_axi_gmem_out6_arburst(sig_m_axi_gmem_out6_arburst),
    .m_axi_gmem_out6_arlock(sig_m_axi_gmem_out6_arlock),
    .m_axi_gmem_out6_arcache(sig_m_axi_gmem_out6_arcache),
    .m_axi_gmem_out6_arprot(sig_m_axi_gmem_out6_arprot),
    .m_axi_gmem_out6_arqos(sig_m_axi_gmem_out6_arqos),
    .m_axi_gmem_out6_arregion(sig_m_axi_gmem_out6_arregion),
    .m_axi_gmem_out6_aruser(sig_m_axi_gmem_out6_aruser),
    .m_axi_gmem_out6_arvalid(sig_m_axi_gmem_out6_arvalid),
    .m_axi_gmem_out6_rready(sig_m_axi_gmem_out6_rready),
    .m_axi_gmem_out7_awid(sig_m_axi_gmem_out7_awid),
    .m_axi_gmem_out7_awaddr(sig_m_axi_gmem_out7_awaddr),
    .m_axi_gmem_out7_awlen(sig_m_axi_gmem_out7_awlen),
    .m_axi_gmem_out7_awsize(sig_m_axi_gmem_out7_awsize),
    .m_axi_gmem_out7_awburst(sig_m_axi_gmem_out7_awburst),
    .m_axi_gmem_out7_awlock(sig_m_axi_gmem_out7_awlock),
    .m_axi_gmem_out7_awcache(sig_m_axi_gmem_out7_awcache),
    .m_axi_gmem_out7_awprot(sig_m_axi_gmem_out7_awprot),
    .m_axi_gmem_out7_awqos(sig_m_axi_gmem_out7_awqos),
    .m_axi_gmem_out7_awregion(sig_m_axi_gmem_out7_awregion),
    .m_axi_gmem_out7_awuser(sig_m_axi_gmem_out7_awuser),
    .m_axi_gmem_out7_awvalid(sig_m_axi_gmem_out7_awvalid),
    .m_axi_gmem_out7_wdata(sig_m_axi_gmem_out7_wdata),
    .m_axi_gmem_out7_wstrb(sig_m_axi_gmem_out7_wstrb),
    .m_axi_gmem_out7_wlast(sig_m_axi_gmem_out7_wlast),
    .m_axi_gmem_out7_wuser(sig_m_axi_gmem_out7_wuser),
    .m_axi_gmem_out7_wvalid(sig_m_axi_gmem_out7_wvalid),
    .m_axi_gmem_out7_bready(sig_m_axi_gmem_out7_bready),
    .m_axi_gmem_out7_arid(sig_m_axi_gmem_out7_arid),
    .m_axi_gmem_out7_araddr(sig_m_axi_gmem_out7_araddr),
    .m_axi_gmem_out7_arlen(sig_m_axi_gmem_out7_arlen),
    .m_axi_gmem_out7_arsize(sig_m_axi_gmem_out7_arsize),
    .m_axi_gmem_out7_arburst(sig_m_axi_gmem_out7_arburst),
    .m_axi_gmem_out7_arlock(sig_m_axi_gmem_out7_arlock),
    .m_axi_gmem_out7_arcache(sig_m_axi_gmem_out7_arcache),
    .m_axi_gmem_out7_arprot(sig_m_axi_gmem_out7_arprot),
    .m_axi_gmem_out7_arqos(sig_m_axi_gmem_out7_arqos),
    .m_axi_gmem_out7_arregion(sig_m_axi_gmem_out7_arregion),
    .m_axi_gmem_out7_aruser(sig_m_axi_gmem_out7_aruser),
    .m_axi_gmem_out7_arvalid(sig_m_axi_gmem_out7_arvalid),
    .m_axi_gmem_out7_rready(sig_m_axi_gmem_out7_rready),
    .m_axi_gmem_w0_awid(sig_m_axi_gmem_w0_awid),
    .m_axi_gmem_w0_awaddr(sig_m_axi_gmem_w0_awaddr),
    .m_axi_gmem_w0_awlen(sig_m_axi_gmem_w0_awlen),
    .m_axi_gmem_w0_awsize(sig_m_axi_gmem_w0_awsize),
    .m_axi_gmem_w0_awburst(sig_m_axi_gmem_w0_awburst),
    .m_axi_gmem_w0_awlock(sig_m_axi_gmem_w0_awlock),
    .m_axi_gmem_w0_awcache(sig_m_axi_gmem_w0_awcache),
    .m_axi_gmem_w0_awprot(sig_m_axi_gmem_w0_awprot),
    .m_axi_gmem_w0_awqos(sig_m_axi_gmem_w0_awqos),
    .m_axi_gmem_w0_awregion(sig_m_axi_gmem_w0_awregion),
    .m_axi_gmem_w0_awuser(sig_m_axi_gmem_w0_awuser),
    .m_axi_gmem_w0_awvalid(sig_m_axi_gmem_w0_awvalid),
    .m_axi_gmem_w0_wdata(sig_m_axi_gmem_w0_wdata),
    .m_axi_gmem_w0_wstrb(sig_m_axi_gmem_w0_wstrb),
    .m_axi_gmem_w0_wlast(sig_m_axi_gmem_w0_wlast),
    .m_axi_gmem_w0_wuser(sig_m_axi_gmem_w0_wuser),
    .m_axi_gmem_w0_wvalid(sig_m_axi_gmem_w0_wvalid),
    .m_axi_gmem_w0_bready(sig_m_axi_gmem_w0_bready),
    .m_axi_gmem_w0_arid(sig_m_axi_gmem_w0_arid),
    .m_axi_gmem_w0_araddr(sig_m_axi_gmem_w0_araddr),
    .m_axi_gmem_w0_arlen(sig_m_axi_gmem_w0_arlen),
    .m_axi_gmem_w0_arsize(sig_m_axi_gmem_w0_arsize),
    .m_axi_gmem_w0_arburst(sig_m_axi_gmem_w0_arburst),
    .m_axi_gmem_w0_arlock(sig_m_axi_gmem_w0_arlock),
    .m_axi_gmem_w0_arcache(sig_m_axi_gmem_w0_arcache),
    .m_axi_gmem_w0_arprot(sig_m_axi_gmem_w0_arprot),
    .m_axi_gmem_w0_arqos(sig_m_axi_gmem_w0_arqos),
    .m_axi_gmem_w0_arregion(sig_m_axi_gmem_w0_arregion),
    .m_axi_gmem_w0_aruser(sig_m_axi_gmem_w0_aruser),
    .m_axi_gmem_w0_arvalid(sig_m_axi_gmem_w0_arvalid),
    .m_axi_gmem_w0_rready(sig_m_axi_gmem_w0_rready),
    .m_axi_gmem_w1_awid(sig_m_axi_gmem_w1_awid),
    .m_axi_gmem_w1_awaddr(sig_m_axi_gmem_w1_awaddr),
    .m_axi_gmem_w1_awlen(sig_m_axi_gmem_w1_awlen),
    .m_axi_gmem_w1_awsize(sig_m_axi_gmem_w1_awsize),
    .m_axi_gmem_w1_awburst(sig_m_axi_gmem_w1_awburst),
    .m_axi_gmem_w1_awlock(sig_m_axi_gmem_w1_awlock),
    .m_axi_gmem_w1_awcache(sig_m_axi_gmem_w1_awcache),
    .m_axi_gmem_w1_awprot(sig_m_axi_gmem_w1_awprot),
    .m_axi_gmem_w1_awqos(sig_m_axi_gmem_w1_awqos),
    .m_axi_gmem_w1_awregion(sig_m_axi_gmem_w1_awregion),
    .m_axi_gmem_w1_awuser(sig_m_axi_gmem_w1_awuser),
    .m_axi_gmem_w1_awvalid(sig_m_axi_gmem_w1_awvalid),
    .m_axi_gmem_w1_wdata(sig_m_axi_gmem_w1_wdata),
    .m_axi_gmem_w1_wstrb(sig_m_axi_gmem_w1_wstrb),
    .m_axi_gmem_w1_wlast(sig_m_axi_gmem_w1_wlast),
    .m_axi_gmem_w1_wuser(sig_m_axi_gmem_w1_wuser),
    .m_axi_gmem_w1_wvalid(sig_m_axi_gmem_w1_wvalid),
    .m_axi_gmem_w1_bready(sig_m_axi_gmem_w1_bready),
    .m_axi_gmem_w1_arid(sig_m_axi_gmem_w1_arid),
    .m_axi_gmem_w1_araddr(sig_m_axi_gmem_w1_araddr),
    .m_axi_gmem_w1_arlen(sig_m_axi_gmem_w1_arlen),
    .m_axi_gmem_w1_arsize(sig_m_axi_gmem_w1_arsize),
    .m_axi_gmem_w1_arburst(sig_m_axi_gmem_w1_arburst),
    .m_axi_gmem_w1_arlock(sig_m_axi_gmem_w1_arlock),
    .m_axi_gmem_w1_arcache(sig_m_axi_gmem_w1_arcache),
    .m_axi_gmem_w1_arprot(sig_m_axi_gmem_w1_arprot),
    .m_axi_gmem_w1_arqos(sig_m_axi_gmem_w1_arqos),
    .m_axi_gmem_w1_arregion(sig_m_axi_gmem_w1_arregion),
    .m_axi_gmem_w1_aruser(sig_m_axi_gmem_w1_aruser),
    .m_axi_gmem_w1_arvalid(sig_m_axi_gmem_w1_arvalid),
    .m_axi_gmem_w1_rready(sig_m_axi_gmem_w1_rready),
    .clock(clock),
    .reset(sig_reset),
    .start_port(sig_start_port),
    .dram_in_b0(sig_dram_in_b0),
    .dram_in_b1(sig_dram_in_b1),
    .dram_w_b0(sig_dram_w_b0),
    .dram_w_b1(sig_dram_w_b1),
    .dram_out_b0(sig_dram_out_b0),
    .dram_out_b1(sig_dram_out_b1),
    .dram_out_b2(sig_dram_out_b2),
    .dram_out_b3(sig_dram_out_b3),
    .dram_out_b4(sig_dram_out_b4),
    .dram_out_b5(sig_dram_out_b5),
    .dram_out_b6(sig_dram_out_b6),
    .dram_out_b7(sig_dram_out_b7),
    .cache_reset(sig_setup_port),
    .m_axi_gmem_in0_awready(sig_m_axi_gmem_in0_awready),
    .m_axi_gmem_in0_wready(sig_m_axi_gmem_in0_wready),
    .m_axi_gmem_in0_bid(sig_m_axi_gmem_in0_bid),
    .m_axi_gmem_in0_bresp(sig_m_axi_gmem_in0_bresp),
    .m_axi_gmem_in0_buser(sig_m_axi_gmem_in0_buser),
    .m_axi_gmem_in0_bvalid(sig_m_axi_gmem_in0_bvalid),
    .m_axi_gmem_in0_arready(sig_m_axi_gmem_in0_arready),
    .m_axi_gmem_in0_rid(sig_m_axi_gmem_in0_rid),
    .m_axi_gmem_in0_rdata(sig_m_axi_gmem_in0_rdata),
    .m_axi_gmem_in0_rresp(sig_m_axi_gmem_in0_rresp),
    .m_axi_gmem_in0_rlast(sig_m_axi_gmem_in0_rlast),
    .m_axi_gmem_in0_ruser(sig_m_axi_gmem_in0_ruser),
    .m_axi_gmem_in0_rvalid(sig_m_axi_gmem_in0_rvalid),
    .m_axi_gmem_in1_awready(sig_m_axi_gmem_in1_awready),
    .m_axi_gmem_in1_wready(sig_m_axi_gmem_in1_wready),
    .m_axi_gmem_in1_bid(sig_m_axi_gmem_in1_bid),
    .m_axi_gmem_in1_bresp(sig_m_axi_gmem_in1_bresp),
    .m_axi_gmem_in1_buser(sig_m_axi_gmem_in1_buser),
    .m_axi_gmem_in1_bvalid(sig_m_axi_gmem_in1_bvalid),
    .m_axi_gmem_in1_arready(sig_m_axi_gmem_in1_arready),
    .m_axi_gmem_in1_rid(sig_m_axi_gmem_in1_rid),
    .m_axi_gmem_in1_rdata(sig_m_axi_gmem_in1_rdata),
    .m_axi_gmem_in1_rresp(sig_m_axi_gmem_in1_rresp),
    .m_axi_gmem_in1_rlast(sig_m_axi_gmem_in1_rlast),
    .m_axi_gmem_in1_ruser(sig_m_axi_gmem_in1_ruser),
    .m_axi_gmem_in1_rvalid(sig_m_axi_gmem_in1_rvalid),
    .m_axi_gmem_out0_awready(sig_m_axi_gmem_out0_awready),
    .m_axi_gmem_out0_wready(sig_m_axi_gmem_out0_wready),
    .m_axi_gmem_out0_bid(sig_m_axi_gmem_out0_bid),
    .m_axi_gmem_out0_bresp(sig_m_axi_gmem_out0_bresp),
    .m_axi_gmem_out0_buser(sig_m_axi_gmem_out0_buser),
    .m_axi_gmem_out0_bvalid(sig_m_axi_gmem_out0_bvalid),
    .m_axi_gmem_out0_arready(sig_m_axi_gmem_out0_arready),
    .m_axi_gmem_out0_rid(sig_m_axi_gmem_out0_rid),
    .m_axi_gmem_out0_rdata(sig_m_axi_gmem_out0_rdata),
    .m_axi_gmem_out0_rresp(sig_m_axi_gmem_out0_rresp),
    .m_axi_gmem_out0_rlast(sig_m_axi_gmem_out0_rlast),
    .m_axi_gmem_out0_ruser(sig_m_axi_gmem_out0_ruser),
    .m_axi_gmem_out0_rvalid(sig_m_axi_gmem_out0_rvalid),
    .m_axi_gmem_out1_awready(sig_m_axi_gmem_out1_awready),
    .m_axi_gmem_out1_wready(sig_m_axi_gmem_out1_wready),
    .m_axi_gmem_out1_bid(sig_m_axi_gmem_out1_bid),
    .m_axi_gmem_out1_bresp(sig_m_axi_gmem_out1_bresp),
    .m_axi_gmem_out1_buser(sig_m_axi_gmem_out1_buser),
    .m_axi_gmem_out1_bvalid(sig_m_axi_gmem_out1_bvalid),
    .m_axi_gmem_out1_arready(sig_m_axi_gmem_out1_arready),
    .m_axi_gmem_out1_rid(sig_m_axi_gmem_out1_rid),
    .m_axi_gmem_out1_rdata(sig_m_axi_gmem_out1_rdata),
    .m_axi_gmem_out1_rresp(sig_m_axi_gmem_out1_rresp),
    .m_axi_gmem_out1_rlast(sig_m_axi_gmem_out1_rlast),
    .m_axi_gmem_out1_ruser(sig_m_axi_gmem_out1_ruser),
    .m_axi_gmem_out1_rvalid(sig_m_axi_gmem_out1_rvalid),
    .m_axi_gmem_out2_awready(sig_m_axi_gmem_out2_awready),
    .m_axi_gmem_out2_wready(sig_m_axi_gmem_out2_wready),
    .m_axi_gmem_out2_bid(sig_m_axi_gmem_out2_bid),
    .m_axi_gmem_out2_bresp(sig_m_axi_gmem_out2_bresp),
    .m_axi_gmem_out2_buser(sig_m_axi_gmem_out2_buser),
    .m_axi_gmem_out2_bvalid(sig_m_axi_gmem_out2_bvalid),
    .m_axi_gmem_out2_arready(sig_m_axi_gmem_out2_arready),
    .m_axi_gmem_out2_rid(sig_m_axi_gmem_out2_rid),
    .m_axi_gmem_out2_rdata(sig_m_axi_gmem_out2_rdata),
    .m_axi_gmem_out2_rresp(sig_m_axi_gmem_out2_rresp),
    .m_axi_gmem_out2_rlast(sig_m_axi_gmem_out2_rlast),
    .m_axi_gmem_out2_ruser(sig_m_axi_gmem_out2_ruser),
    .m_axi_gmem_out2_rvalid(sig_m_axi_gmem_out2_rvalid),
    .m_axi_gmem_out3_awready(sig_m_axi_gmem_out3_awready),
    .m_axi_gmem_out3_wready(sig_m_axi_gmem_out3_wready),
    .m_axi_gmem_out3_bid(sig_m_axi_gmem_out3_bid),
    .m_axi_gmem_out3_bresp(sig_m_axi_gmem_out3_bresp),
    .m_axi_gmem_out3_buser(sig_m_axi_gmem_out3_buser),
    .m_axi_gmem_out3_bvalid(sig_m_axi_gmem_out3_bvalid),
    .m_axi_gmem_out3_arready(sig_m_axi_gmem_out3_arready),
    .m_axi_gmem_out3_rid(sig_m_axi_gmem_out3_rid),
    .m_axi_gmem_out3_rdata(sig_m_axi_gmem_out3_rdata),
    .m_axi_gmem_out3_rresp(sig_m_axi_gmem_out3_rresp),
    .m_axi_gmem_out3_rlast(sig_m_axi_gmem_out3_rlast),
    .m_axi_gmem_out3_ruser(sig_m_axi_gmem_out3_ruser),
    .m_axi_gmem_out3_rvalid(sig_m_axi_gmem_out3_rvalid),
    .m_axi_gmem_out4_awready(sig_m_axi_gmem_out4_awready),
    .m_axi_gmem_out4_wready(sig_m_axi_gmem_out4_wready),
    .m_axi_gmem_out4_bid(sig_m_axi_gmem_out4_bid),
    .m_axi_gmem_out4_bresp(sig_m_axi_gmem_out4_bresp),
    .m_axi_gmem_out4_buser(sig_m_axi_gmem_out4_buser),
    .m_axi_gmem_out4_bvalid(sig_m_axi_gmem_out4_bvalid),
    .m_axi_gmem_out4_arready(sig_m_axi_gmem_out4_arready),
    .m_axi_gmem_out4_rid(sig_m_axi_gmem_out4_rid),
    .m_axi_gmem_out4_rdata(sig_m_axi_gmem_out4_rdata),
    .m_axi_gmem_out4_rresp(sig_m_axi_gmem_out4_rresp),
    .m_axi_gmem_out4_rlast(sig_m_axi_gmem_out4_rlast),
    .m_axi_gmem_out4_ruser(sig_m_axi_gmem_out4_ruser),
    .m_axi_gmem_out4_rvalid(sig_m_axi_gmem_out4_rvalid),
    .m_axi_gmem_out5_awready(sig_m_axi_gmem_out5_awready),
    .m_axi_gmem_out5_wready(sig_m_axi_gmem_out5_wready),
    .m_axi_gmem_out5_bid(sig_m_axi_gmem_out5_bid),
    .m_axi_gmem_out5_bresp(sig_m_axi_gmem_out5_bresp),
    .m_axi_gmem_out5_buser(sig_m_axi_gmem_out5_buser),
    .m_axi_gmem_out5_bvalid(sig_m_axi_gmem_out5_bvalid),
    .m_axi_gmem_out5_arready(sig_m_axi_gmem_out5_arready),
    .m_axi_gmem_out5_rid(sig_m_axi_gmem_out5_rid),
    .m_axi_gmem_out5_rdata(sig_m_axi_gmem_out5_rdata),
    .m_axi_gmem_out5_rresp(sig_m_axi_gmem_out5_rresp),
    .m_axi_gmem_out5_rlast(sig_m_axi_gmem_out5_rlast),
    .m_axi_gmem_out5_ruser(sig_m_axi_gmem_out5_ruser),
    .m_axi_gmem_out5_rvalid(sig_m_axi_gmem_out5_rvalid),
    .m_axi_gmem_out6_awready(sig_m_axi_gmem_out6_awready),
    .m_axi_gmem_out6_wready(sig_m_axi_gmem_out6_wready),
    .m_axi_gmem_out6_bid(sig_m_axi_gmem_out6_bid),
    .m_axi_gmem_out6_bresp(sig_m_axi_gmem_out6_bresp),
    .m_axi_gmem_out6_buser(sig_m_axi_gmem_out6_buser),
    .m_axi_gmem_out6_bvalid(sig_m_axi_gmem_out6_bvalid),
    .m_axi_gmem_out6_arready(sig_m_axi_gmem_out6_arready),
    .m_axi_gmem_out6_rid(sig_m_axi_gmem_out6_rid),
    .m_axi_gmem_out6_rdata(sig_m_axi_gmem_out6_rdata),
    .m_axi_gmem_out6_rresp(sig_m_axi_gmem_out6_rresp),
    .m_axi_gmem_out6_rlast(sig_m_axi_gmem_out6_rlast),
    .m_axi_gmem_out6_ruser(sig_m_axi_gmem_out6_ruser),
    .m_axi_gmem_out6_rvalid(sig_m_axi_gmem_out6_rvalid),
    .m_axi_gmem_out7_awready(sig_m_axi_gmem_out7_awready),
    .m_axi_gmem_out7_wready(sig_m_axi_gmem_out7_wready),
    .m_axi_gmem_out7_bid(sig_m_axi_gmem_out7_bid),
    .m_axi_gmem_out7_bresp(sig_m_axi_gmem_out7_bresp),
    .m_axi_gmem_out7_buser(sig_m_axi_gmem_out7_buser),
    .m_axi_gmem_out7_bvalid(sig_m_axi_gmem_out7_bvalid),
    .m_axi_gmem_out7_arready(sig_m_axi_gmem_out7_arready),
    .m_axi_gmem_out7_rid(sig_m_axi_gmem_out7_rid),
    .m_axi_gmem_out7_rdata(sig_m_axi_gmem_out7_rdata),
    .m_axi_gmem_out7_rresp(sig_m_axi_gmem_out7_rresp),
    .m_axi_gmem_out7_rlast(sig_m_axi_gmem_out7_rlast),
    .m_axi_gmem_out7_ruser(sig_m_axi_gmem_out7_ruser),
    .m_axi_gmem_out7_rvalid(sig_m_axi_gmem_out7_rvalid),
    .m_axi_gmem_w0_awready(sig_m_axi_gmem_w0_awready),
    .m_axi_gmem_w0_wready(sig_m_axi_gmem_w0_wready),
    .m_axi_gmem_w0_bid(sig_m_axi_gmem_w0_bid),
    .m_axi_gmem_w0_bresp(sig_m_axi_gmem_w0_bresp),
    .m_axi_gmem_w0_buser(sig_m_axi_gmem_w0_buser),
    .m_axi_gmem_w0_bvalid(sig_m_axi_gmem_w0_bvalid),
    .m_axi_gmem_w0_arready(sig_m_axi_gmem_w0_arready),
    .m_axi_gmem_w0_rid(sig_m_axi_gmem_w0_rid),
    .m_axi_gmem_w0_rdata(sig_m_axi_gmem_w0_rdata),
    .m_axi_gmem_w0_rresp(sig_m_axi_gmem_w0_rresp),
    .m_axi_gmem_w0_rlast(sig_m_axi_gmem_w0_rlast),
    .m_axi_gmem_w0_ruser(sig_m_axi_gmem_w0_ruser),
    .m_axi_gmem_w0_rvalid(sig_m_axi_gmem_w0_rvalid),
    .m_axi_gmem_w1_awready(sig_m_axi_gmem_w1_awready),
    .m_axi_gmem_w1_wready(sig_m_axi_gmem_w1_wready),
    .m_axi_gmem_w1_bid(sig_m_axi_gmem_w1_bid),
    .m_axi_gmem_w1_bresp(sig_m_axi_gmem_w1_bresp),
    .m_axi_gmem_w1_buser(sig_m_axi_gmem_w1_buser),
    .m_axi_gmem_w1_bvalid(sig_m_axi_gmem_w1_bvalid),
    .m_axi_gmem_w1_arready(sig_m_axi_gmem_w1_arready),
    .m_axi_gmem_w1_rid(sig_m_axi_gmem_w1_rid),
    .m_axi_gmem_w1_rdata(sig_m_axi_gmem_w1_rdata),
    .m_axi_gmem_w1_rresp(sig_m_axi_gmem_w1_rresp),
    .m_axi_gmem_w1_rlast(sig_m_axi_gmem_w1_rlast),
    .m_axi_gmem_w1_ruser(sig_m_axi_gmem_w1_ruser),
    .m_axi_gmem_w1_rvalid(sig_m_axi_gmem_w1_rvalid));
  TestbenchFSM #(.RESFILE("results.txt"),
    .RESET_ACTIVE(0),
    .RESET_CYCLES(1),
    .RESET_ALWAYS(0),
    .CLOCK_PERIOD(2.0),
    .MAX_SIM_CYCLES(200000000)) SystemFSM (.reset(sig_reset),
    .setup_port(sig_setup_port),
    .start_port(sig_start_port),
    .clock(clock),
    .done_port(sig_done_port));
  TestbenchMEMMinimal #(.index(12),
    .MEM_DELAY_READ(2),
    .MEM_DELAY_WRITE(1),
    .base_addr(1073741824),
    .MEM_DUMP(0),
    .MEM_DUMP_FILE("memdump.csv"),
    .QUEUE_SIZE(4),
    .BITSIZE_M_DataRdy(1),
    .BITSIZE_M_Rdata_ram(8),
    .BITSIZE_Mout_oe_ram(1),
    .BITSIZE_Mout_we_ram(1),
    .BITSIZE_Mout_addr_ram(1),
    .BITSIZE_Mout_data_ram_size(4),
    .BITSIZE_Mout_Wdata_ram(8),
    .BITSIZE_Mout_back_pressure(1),
    .BITSIZE_Sout_DataRdy(1),
    .BITSIZE_Sout_Rdata_ram(8),
    .BITSIZE_S_oe_ram(1),
    .BITSIZE_S_we_ram(1),
    .BITSIZE_S_addr_ram(1),
    .BITSIZE_S_data_ram_size(4),
    .BITSIZE_S_Wdata_ram(8)) SystemMEM (.clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port));
  IF_PORT_IN #(.index(0),
    .BITSIZE_val_port(32)) if_addr_dram_in_b0 (.val_port(sig_dram_in_b0),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(1),
    .BITSIZE_val_port(32)) if_addr_dram_in_b1 (.val_port(sig_dram_in_b1),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(4),
    .BITSIZE_val_port(32)) if_addr_dram_out_b0 (.val_port(sig_dram_out_b0),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(5),
    .BITSIZE_val_port(32)) if_addr_dram_out_b1 (.val_port(sig_dram_out_b1),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(6),
    .BITSIZE_val_port(32)) if_addr_dram_out_b2 (.val_port(sig_dram_out_b2),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(7),
    .BITSIZE_val_port(32)) if_addr_dram_out_b3 (.val_port(sig_dram_out_b3),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(8),
    .BITSIZE_val_port(32)) if_addr_dram_out_b4 (.val_port(sig_dram_out_b4),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(9),
    .BITSIZE_val_port(32)) if_addr_dram_out_b5 (.val_port(sig_dram_out_b5),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(10),
    .BITSIZE_val_port(32)) if_addr_dram_out_b6 (.val_port(sig_dram_out_b6),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(11),
    .BITSIZE_val_port(32)) if_addr_dram_out_b7 (.val_port(sig_dram_out_b7),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(2),
    .BITSIZE_val_port(32)) if_addr_dram_w_b0 (.val_port(sig_dram_w_b0),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(3),
    .BITSIZE_val_port(32)) if_addr_dram_w_b1 (.val_port(sig_dram_w_b1),
    .clock(clock),
    .setup_port(sig_setup_port));
  if_m_axi_gmem_in0 #(.index(12),
    .BITSIZE_m_axi_gmem_in0_bid(6),
    .BITSIZE_m_axi_gmem_in0_bresp(2),
    .BITSIZE_m_axi_gmem_in0_buser(1),
    .BITSIZE_m_axi_gmem_in0_rid(6),
    .BITSIZE_m_axi_gmem_in0_rdata(32),
    .BITSIZE_m_axi_gmem_in0_rresp(2),
    .BITSIZE_m_axi_gmem_in0_ruser(1),
    .BITSIZE_m_axi_gmem_in0_awid(6),
    .BITSIZE_m_axi_gmem_in0_awaddr(32),
    .BITSIZE_m_axi_gmem_in0_awlen(8),
    .BITSIZE_m_axi_gmem_in0_awsize(3),
    .BITSIZE_m_axi_gmem_in0_awburst(2),
    .BITSIZE_m_axi_gmem_in0_awlock(1),
    .BITSIZE_m_axi_gmem_in0_awcache(4),
    .BITSIZE_m_axi_gmem_in0_awprot(3),
    .BITSIZE_m_axi_gmem_in0_awqos(4),
    .BITSIZE_m_axi_gmem_in0_awregion(4),
    .BITSIZE_m_axi_gmem_in0_awuser(1),
    .BITSIZE_m_axi_gmem_in0_wdata(32),
    .BITSIZE_m_axi_gmem_in0_wstrb(4),
    .BITSIZE_m_axi_gmem_in0_wuser(1),
    .BITSIZE_m_axi_gmem_in0_arid(6),
    .BITSIZE_m_axi_gmem_in0_araddr(32),
    .BITSIZE_m_axi_gmem_in0_arlen(8),
    .BITSIZE_m_axi_gmem_in0_arsize(3),
    .BITSIZE_m_axi_gmem_in0_arburst(2),
    .BITSIZE_m_axi_gmem_in0_arlock(1),
    .BITSIZE_m_axi_gmem_in0_arcache(4),
    .BITSIZE_m_axi_gmem_in0_arprot(3),
    .BITSIZE_m_axi_gmem_in0_arqos(4),
    .BITSIZE_m_axi_gmem_in0_arregion(4),
    .BITSIZE_m_axi_gmem_in0_aruser(1)) if_m_axi_gmem_in0_fu (.m_axi_gmem_in0_awready(sig_m_axi_gmem_in0_awready),
    .m_axi_gmem_in0_wready(sig_m_axi_gmem_in0_wready),
    .m_axi_gmem_in0_bid(sig_m_axi_gmem_in0_bid),
    .m_axi_gmem_in0_bresp(sig_m_axi_gmem_in0_bresp),
    .m_axi_gmem_in0_buser(sig_m_axi_gmem_in0_buser),
    .m_axi_gmem_in0_bvalid(sig_m_axi_gmem_in0_bvalid),
    .m_axi_gmem_in0_arready(sig_m_axi_gmem_in0_arready),
    .m_axi_gmem_in0_rid(sig_m_axi_gmem_in0_rid),
    .m_axi_gmem_in0_rdata(sig_m_axi_gmem_in0_rdata),
    .m_axi_gmem_in0_rresp(sig_m_axi_gmem_in0_rresp),
    .m_axi_gmem_in0_rlast(sig_m_axi_gmem_in0_rlast),
    .m_axi_gmem_in0_ruser(sig_m_axi_gmem_in0_ruser),
    .m_axi_gmem_in0_rvalid(sig_m_axi_gmem_in0_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem_in0_awid(sig_m_axi_gmem_in0_awid),
    .m_axi_gmem_in0_awaddr(sig_m_axi_gmem_in0_awaddr),
    .m_axi_gmem_in0_awlen(sig_m_axi_gmem_in0_awlen),
    .m_axi_gmem_in0_awsize(sig_m_axi_gmem_in0_awsize),
    .m_axi_gmem_in0_awburst(sig_m_axi_gmem_in0_awburst),
    .m_axi_gmem_in0_awlock(sig_m_axi_gmem_in0_awlock),
    .m_axi_gmem_in0_awcache(sig_m_axi_gmem_in0_awcache),
    .m_axi_gmem_in0_awprot(sig_m_axi_gmem_in0_awprot),
    .m_axi_gmem_in0_awqos(sig_m_axi_gmem_in0_awqos),
    .m_axi_gmem_in0_awregion(sig_m_axi_gmem_in0_awregion),
    .m_axi_gmem_in0_awuser(sig_m_axi_gmem_in0_awuser),
    .m_axi_gmem_in0_awvalid(sig_m_axi_gmem_in0_awvalid),
    .m_axi_gmem_in0_wdata(sig_m_axi_gmem_in0_wdata),
    .m_axi_gmem_in0_wstrb(sig_m_axi_gmem_in0_wstrb),
    .m_axi_gmem_in0_wlast(sig_m_axi_gmem_in0_wlast),
    .m_axi_gmem_in0_wuser(sig_m_axi_gmem_in0_wuser),
    .m_axi_gmem_in0_wvalid(sig_m_axi_gmem_in0_wvalid),
    .m_axi_gmem_in0_bready(sig_m_axi_gmem_in0_bready),
    .m_axi_gmem_in0_arid(sig_m_axi_gmem_in0_arid),
    .m_axi_gmem_in0_araddr(sig_m_axi_gmem_in0_araddr),
    .m_axi_gmem_in0_arlen(sig_m_axi_gmem_in0_arlen),
    .m_axi_gmem_in0_arsize(sig_m_axi_gmem_in0_arsize),
    .m_axi_gmem_in0_arburst(sig_m_axi_gmem_in0_arburst),
    .m_axi_gmem_in0_arlock(sig_m_axi_gmem_in0_arlock),
    .m_axi_gmem_in0_arcache(sig_m_axi_gmem_in0_arcache),
    .m_axi_gmem_in0_arprot(sig_m_axi_gmem_in0_arprot),
    .m_axi_gmem_in0_arqos(sig_m_axi_gmem_in0_arqos),
    .m_axi_gmem_in0_arregion(sig_m_axi_gmem_in0_arregion),
    .m_axi_gmem_in0_aruser(sig_m_axi_gmem_in0_aruser),
    .m_axi_gmem_in0_arvalid(sig_m_axi_gmem_in0_arvalid),
    .m_axi_gmem_in0_rready(sig_m_axi_gmem_in0_rready));
  if_m_axi_gmem_in1 #(.index(12),
    .BITSIZE_m_axi_gmem_in1_bid(6),
    .BITSIZE_m_axi_gmem_in1_bresp(2),
    .BITSIZE_m_axi_gmem_in1_buser(1),
    .BITSIZE_m_axi_gmem_in1_rid(6),
    .BITSIZE_m_axi_gmem_in1_rdata(32),
    .BITSIZE_m_axi_gmem_in1_rresp(2),
    .BITSIZE_m_axi_gmem_in1_ruser(1),
    .BITSIZE_m_axi_gmem_in1_awid(6),
    .BITSIZE_m_axi_gmem_in1_awaddr(32),
    .BITSIZE_m_axi_gmem_in1_awlen(8),
    .BITSIZE_m_axi_gmem_in1_awsize(3),
    .BITSIZE_m_axi_gmem_in1_awburst(2),
    .BITSIZE_m_axi_gmem_in1_awlock(1),
    .BITSIZE_m_axi_gmem_in1_awcache(4),
    .BITSIZE_m_axi_gmem_in1_awprot(3),
    .BITSIZE_m_axi_gmem_in1_awqos(4),
    .BITSIZE_m_axi_gmem_in1_awregion(4),
    .BITSIZE_m_axi_gmem_in1_awuser(1),
    .BITSIZE_m_axi_gmem_in1_wdata(32),
    .BITSIZE_m_axi_gmem_in1_wstrb(4),
    .BITSIZE_m_axi_gmem_in1_wuser(1),
    .BITSIZE_m_axi_gmem_in1_arid(6),
    .BITSIZE_m_axi_gmem_in1_araddr(32),
    .BITSIZE_m_axi_gmem_in1_arlen(8),
    .BITSIZE_m_axi_gmem_in1_arsize(3),
    .BITSIZE_m_axi_gmem_in1_arburst(2),
    .BITSIZE_m_axi_gmem_in1_arlock(1),
    .BITSIZE_m_axi_gmem_in1_arcache(4),
    .BITSIZE_m_axi_gmem_in1_arprot(3),
    .BITSIZE_m_axi_gmem_in1_arqos(4),
    .BITSIZE_m_axi_gmem_in1_arregion(4),
    .BITSIZE_m_axi_gmem_in1_aruser(1)) if_m_axi_gmem_in1_fu (.m_axi_gmem_in1_awready(sig_m_axi_gmem_in1_awready),
    .m_axi_gmem_in1_wready(sig_m_axi_gmem_in1_wready),
    .m_axi_gmem_in1_bid(sig_m_axi_gmem_in1_bid),
    .m_axi_gmem_in1_bresp(sig_m_axi_gmem_in1_bresp),
    .m_axi_gmem_in1_buser(sig_m_axi_gmem_in1_buser),
    .m_axi_gmem_in1_bvalid(sig_m_axi_gmem_in1_bvalid),
    .m_axi_gmem_in1_arready(sig_m_axi_gmem_in1_arready),
    .m_axi_gmem_in1_rid(sig_m_axi_gmem_in1_rid),
    .m_axi_gmem_in1_rdata(sig_m_axi_gmem_in1_rdata),
    .m_axi_gmem_in1_rresp(sig_m_axi_gmem_in1_rresp),
    .m_axi_gmem_in1_rlast(sig_m_axi_gmem_in1_rlast),
    .m_axi_gmem_in1_ruser(sig_m_axi_gmem_in1_ruser),
    .m_axi_gmem_in1_rvalid(sig_m_axi_gmem_in1_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem_in1_awid(sig_m_axi_gmem_in1_awid),
    .m_axi_gmem_in1_awaddr(sig_m_axi_gmem_in1_awaddr),
    .m_axi_gmem_in1_awlen(sig_m_axi_gmem_in1_awlen),
    .m_axi_gmem_in1_awsize(sig_m_axi_gmem_in1_awsize),
    .m_axi_gmem_in1_awburst(sig_m_axi_gmem_in1_awburst),
    .m_axi_gmem_in1_awlock(sig_m_axi_gmem_in1_awlock),
    .m_axi_gmem_in1_awcache(sig_m_axi_gmem_in1_awcache),
    .m_axi_gmem_in1_awprot(sig_m_axi_gmem_in1_awprot),
    .m_axi_gmem_in1_awqos(sig_m_axi_gmem_in1_awqos),
    .m_axi_gmem_in1_awregion(sig_m_axi_gmem_in1_awregion),
    .m_axi_gmem_in1_awuser(sig_m_axi_gmem_in1_awuser),
    .m_axi_gmem_in1_awvalid(sig_m_axi_gmem_in1_awvalid),
    .m_axi_gmem_in1_wdata(sig_m_axi_gmem_in1_wdata),
    .m_axi_gmem_in1_wstrb(sig_m_axi_gmem_in1_wstrb),
    .m_axi_gmem_in1_wlast(sig_m_axi_gmem_in1_wlast),
    .m_axi_gmem_in1_wuser(sig_m_axi_gmem_in1_wuser),
    .m_axi_gmem_in1_wvalid(sig_m_axi_gmem_in1_wvalid),
    .m_axi_gmem_in1_bready(sig_m_axi_gmem_in1_bready),
    .m_axi_gmem_in1_arid(sig_m_axi_gmem_in1_arid),
    .m_axi_gmem_in1_araddr(sig_m_axi_gmem_in1_araddr),
    .m_axi_gmem_in1_arlen(sig_m_axi_gmem_in1_arlen),
    .m_axi_gmem_in1_arsize(sig_m_axi_gmem_in1_arsize),
    .m_axi_gmem_in1_arburst(sig_m_axi_gmem_in1_arburst),
    .m_axi_gmem_in1_arlock(sig_m_axi_gmem_in1_arlock),
    .m_axi_gmem_in1_arcache(sig_m_axi_gmem_in1_arcache),
    .m_axi_gmem_in1_arprot(sig_m_axi_gmem_in1_arprot),
    .m_axi_gmem_in1_arqos(sig_m_axi_gmem_in1_arqos),
    .m_axi_gmem_in1_arregion(sig_m_axi_gmem_in1_arregion),
    .m_axi_gmem_in1_aruser(sig_m_axi_gmem_in1_aruser),
    .m_axi_gmem_in1_arvalid(sig_m_axi_gmem_in1_arvalid),
    .m_axi_gmem_in1_rready(sig_m_axi_gmem_in1_rready));
  if_m_axi_gmem_out0 #(.index(12),
    .BITSIZE_m_axi_gmem_out0_bid(6),
    .BITSIZE_m_axi_gmem_out0_bresp(2),
    .BITSIZE_m_axi_gmem_out0_buser(1),
    .BITSIZE_m_axi_gmem_out0_rid(6),
    .BITSIZE_m_axi_gmem_out0_rdata(32),
    .BITSIZE_m_axi_gmem_out0_rresp(2),
    .BITSIZE_m_axi_gmem_out0_ruser(1),
    .BITSIZE_m_axi_gmem_out0_awid(6),
    .BITSIZE_m_axi_gmem_out0_awaddr(32),
    .BITSIZE_m_axi_gmem_out0_awlen(8),
    .BITSIZE_m_axi_gmem_out0_awsize(3),
    .BITSIZE_m_axi_gmem_out0_awburst(2),
    .BITSIZE_m_axi_gmem_out0_awlock(1),
    .BITSIZE_m_axi_gmem_out0_awcache(4),
    .BITSIZE_m_axi_gmem_out0_awprot(3),
    .BITSIZE_m_axi_gmem_out0_awqos(4),
    .BITSIZE_m_axi_gmem_out0_awregion(4),
    .BITSIZE_m_axi_gmem_out0_awuser(1),
    .BITSIZE_m_axi_gmem_out0_wdata(32),
    .BITSIZE_m_axi_gmem_out0_wstrb(4),
    .BITSIZE_m_axi_gmem_out0_wuser(1),
    .BITSIZE_m_axi_gmem_out0_arid(6),
    .BITSIZE_m_axi_gmem_out0_araddr(32),
    .BITSIZE_m_axi_gmem_out0_arlen(8),
    .BITSIZE_m_axi_gmem_out0_arsize(3),
    .BITSIZE_m_axi_gmem_out0_arburst(2),
    .BITSIZE_m_axi_gmem_out0_arlock(1),
    .BITSIZE_m_axi_gmem_out0_arcache(4),
    .BITSIZE_m_axi_gmem_out0_arprot(3),
    .BITSIZE_m_axi_gmem_out0_arqos(4),
    .BITSIZE_m_axi_gmem_out0_arregion(4),
    .BITSIZE_m_axi_gmem_out0_aruser(1)) if_m_axi_gmem_out0_fu (.m_axi_gmem_out0_awready(sig_m_axi_gmem_out0_awready),
    .m_axi_gmem_out0_wready(sig_m_axi_gmem_out0_wready),
    .m_axi_gmem_out0_bid(sig_m_axi_gmem_out0_bid),
    .m_axi_gmem_out0_bresp(sig_m_axi_gmem_out0_bresp),
    .m_axi_gmem_out0_buser(sig_m_axi_gmem_out0_buser),
    .m_axi_gmem_out0_bvalid(sig_m_axi_gmem_out0_bvalid),
    .m_axi_gmem_out0_arready(sig_m_axi_gmem_out0_arready),
    .m_axi_gmem_out0_rid(sig_m_axi_gmem_out0_rid),
    .m_axi_gmem_out0_rdata(sig_m_axi_gmem_out0_rdata),
    .m_axi_gmem_out0_rresp(sig_m_axi_gmem_out0_rresp),
    .m_axi_gmem_out0_rlast(sig_m_axi_gmem_out0_rlast),
    .m_axi_gmem_out0_ruser(sig_m_axi_gmem_out0_ruser),
    .m_axi_gmem_out0_rvalid(sig_m_axi_gmem_out0_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem_out0_awid(sig_m_axi_gmem_out0_awid),
    .m_axi_gmem_out0_awaddr(sig_m_axi_gmem_out0_awaddr),
    .m_axi_gmem_out0_awlen(sig_m_axi_gmem_out0_awlen),
    .m_axi_gmem_out0_awsize(sig_m_axi_gmem_out0_awsize),
    .m_axi_gmem_out0_awburst(sig_m_axi_gmem_out0_awburst),
    .m_axi_gmem_out0_awlock(sig_m_axi_gmem_out0_awlock),
    .m_axi_gmem_out0_awcache(sig_m_axi_gmem_out0_awcache),
    .m_axi_gmem_out0_awprot(sig_m_axi_gmem_out0_awprot),
    .m_axi_gmem_out0_awqos(sig_m_axi_gmem_out0_awqos),
    .m_axi_gmem_out0_awregion(sig_m_axi_gmem_out0_awregion),
    .m_axi_gmem_out0_awuser(sig_m_axi_gmem_out0_awuser),
    .m_axi_gmem_out0_awvalid(sig_m_axi_gmem_out0_awvalid),
    .m_axi_gmem_out0_wdata(sig_m_axi_gmem_out0_wdata),
    .m_axi_gmem_out0_wstrb(sig_m_axi_gmem_out0_wstrb),
    .m_axi_gmem_out0_wlast(sig_m_axi_gmem_out0_wlast),
    .m_axi_gmem_out0_wuser(sig_m_axi_gmem_out0_wuser),
    .m_axi_gmem_out0_wvalid(sig_m_axi_gmem_out0_wvalid),
    .m_axi_gmem_out0_bready(sig_m_axi_gmem_out0_bready),
    .m_axi_gmem_out0_arid(sig_m_axi_gmem_out0_arid),
    .m_axi_gmem_out0_araddr(sig_m_axi_gmem_out0_araddr),
    .m_axi_gmem_out0_arlen(sig_m_axi_gmem_out0_arlen),
    .m_axi_gmem_out0_arsize(sig_m_axi_gmem_out0_arsize),
    .m_axi_gmem_out0_arburst(sig_m_axi_gmem_out0_arburst),
    .m_axi_gmem_out0_arlock(sig_m_axi_gmem_out0_arlock),
    .m_axi_gmem_out0_arcache(sig_m_axi_gmem_out0_arcache),
    .m_axi_gmem_out0_arprot(sig_m_axi_gmem_out0_arprot),
    .m_axi_gmem_out0_arqos(sig_m_axi_gmem_out0_arqos),
    .m_axi_gmem_out0_arregion(sig_m_axi_gmem_out0_arregion),
    .m_axi_gmem_out0_aruser(sig_m_axi_gmem_out0_aruser),
    .m_axi_gmem_out0_arvalid(sig_m_axi_gmem_out0_arvalid),
    .m_axi_gmem_out0_rready(sig_m_axi_gmem_out0_rready));
  if_m_axi_gmem_out1 #(.index(12),
    .BITSIZE_m_axi_gmem_out1_bid(6),
    .BITSIZE_m_axi_gmem_out1_bresp(2),
    .BITSIZE_m_axi_gmem_out1_buser(1),
    .BITSIZE_m_axi_gmem_out1_rid(6),
    .BITSIZE_m_axi_gmem_out1_rdata(32),
    .BITSIZE_m_axi_gmem_out1_rresp(2),
    .BITSIZE_m_axi_gmem_out1_ruser(1),
    .BITSIZE_m_axi_gmem_out1_awid(6),
    .BITSIZE_m_axi_gmem_out1_awaddr(32),
    .BITSIZE_m_axi_gmem_out1_awlen(8),
    .BITSIZE_m_axi_gmem_out1_awsize(3),
    .BITSIZE_m_axi_gmem_out1_awburst(2),
    .BITSIZE_m_axi_gmem_out1_awlock(1),
    .BITSIZE_m_axi_gmem_out1_awcache(4),
    .BITSIZE_m_axi_gmem_out1_awprot(3),
    .BITSIZE_m_axi_gmem_out1_awqos(4),
    .BITSIZE_m_axi_gmem_out1_awregion(4),
    .BITSIZE_m_axi_gmem_out1_awuser(1),
    .BITSIZE_m_axi_gmem_out1_wdata(32),
    .BITSIZE_m_axi_gmem_out1_wstrb(4),
    .BITSIZE_m_axi_gmem_out1_wuser(1),
    .BITSIZE_m_axi_gmem_out1_arid(6),
    .BITSIZE_m_axi_gmem_out1_araddr(32),
    .BITSIZE_m_axi_gmem_out1_arlen(8),
    .BITSIZE_m_axi_gmem_out1_arsize(3),
    .BITSIZE_m_axi_gmem_out1_arburst(2),
    .BITSIZE_m_axi_gmem_out1_arlock(1),
    .BITSIZE_m_axi_gmem_out1_arcache(4),
    .BITSIZE_m_axi_gmem_out1_arprot(3),
    .BITSIZE_m_axi_gmem_out1_arqos(4),
    .BITSIZE_m_axi_gmem_out1_arregion(4),
    .BITSIZE_m_axi_gmem_out1_aruser(1)) if_m_axi_gmem_out1_fu (.m_axi_gmem_out1_awready(sig_m_axi_gmem_out1_awready),
    .m_axi_gmem_out1_wready(sig_m_axi_gmem_out1_wready),
    .m_axi_gmem_out1_bid(sig_m_axi_gmem_out1_bid),
    .m_axi_gmem_out1_bresp(sig_m_axi_gmem_out1_bresp),
    .m_axi_gmem_out1_buser(sig_m_axi_gmem_out1_buser),
    .m_axi_gmem_out1_bvalid(sig_m_axi_gmem_out1_bvalid),
    .m_axi_gmem_out1_arready(sig_m_axi_gmem_out1_arready),
    .m_axi_gmem_out1_rid(sig_m_axi_gmem_out1_rid),
    .m_axi_gmem_out1_rdata(sig_m_axi_gmem_out1_rdata),
    .m_axi_gmem_out1_rresp(sig_m_axi_gmem_out1_rresp),
    .m_axi_gmem_out1_rlast(sig_m_axi_gmem_out1_rlast),
    .m_axi_gmem_out1_ruser(sig_m_axi_gmem_out1_ruser),
    .m_axi_gmem_out1_rvalid(sig_m_axi_gmem_out1_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem_out1_awid(sig_m_axi_gmem_out1_awid),
    .m_axi_gmem_out1_awaddr(sig_m_axi_gmem_out1_awaddr),
    .m_axi_gmem_out1_awlen(sig_m_axi_gmem_out1_awlen),
    .m_axi_gmem_out1_awsize(sig_m_axi_gmem_out1_awsize),
    .m_axi_gmem_out1_awburst(sig_m_axi_gmem_out1_awburst),
    .m_axi_gmem_out1_awlock(sig_m_axi_gmem_out1_awlock),
    .m_axi_gmem_out1_awcache(sig_m_axi_gmem_out1_awcache),
    .m_axi_gmem_out1_awprot(sig_m_axi_gmem_out1_awprot),
    .m_axi_gmem_out1_awqos(sig_m_axi_gmem_out1_awqos),
    .m_axi_gmem_out1_awregion(sig_m_axi_gmem_out1_awregion),
    .m_axi_gmem_out1_awuser(sig_m_axi_gmem_out1_awuser),
    .m_axi_gmem_out1_awvalid(sig_m_axi_gmem_out1_awvalid),
    .m_axi_gmem_out1_wdata(sig_m_axi_gmem_out1_wdata),
    .m_axi_gmem_out1_wstrb(sig_m_axi_gmem_out1_wstrb),
    .m_axi_gmem_out1_wlast(sig_m_axi_gmem_out1_wlast),
    .m_axi_gmem_out1_wuser(sig_m_axi_gmem_out1_wuser),
    .m_axi_gmem_out1_wvalid(sig_m_axi_gmem_out1_wvalid),
    .m_axi_gmem_out1_bready(sig_m_axi_gmem_out1_bready),
    .m_axi_gmem_out1_arid(sig_m_axi_gmem_out1_arid),
    .m_axi_gmem_out1_araddr(sig_m_axi_gmem_out1_araddr),
    .m_axi_gmem_out1_arlen(sig_m_axi_gmem_out1_arlen),
    .m_axi_gmem_out1_arsize(sig_m_axi_gmem_out1_arsize),
    .m_axi_gmem_out1_arburst(sig_m_axi_gmem_out1_arburst),
    .m_axi_gmem_out1_arlock(sig_m_axi_gmem_out1_arlock),
    .m_axi_gmem_out1_arcache(sig_m_axi_gmem_out1_arcache),
    .m_axi_gmem_out1_arprot(sig_m_axi_gmem_out1_arprot),
    .m_axi_gmem_out1_arqos(sig_m_axi_gmem_out1_arqos),
    .m_axi_gmem_out1_arregion(sig_m_axi_gmem_out1_arregion),
    .m_axi_gmem_out1_aruser(sig_m_axi_gmem_out1_aruser),
    .m_axi_gmem_out1_arvalid(sig_m_axi_gmem_out1_arvalid),
    .m_axi_gmem_out1_rready(sig_m_axi_gmem_out1_rready));
  if_m_axi_gmem_out2 #(.index(12),
    .BITSIZE_m_axi_gmem_out2_bid(6),
    .BITSIZE_m_axi_gmem_out2_bresp(2),
    .BITSIZE_m_axi_gmem_out2_buser(1),
    .BITSIZE_m_axi_gmem_out2_rid(6),
    .BITSIZE_m_axi_gmem_out2_rdata(32),
    .BITSIZE_m_axi_gmem_out2_rresp(2),
    .BITSIZE_m_axi_gmem_out2_ruser(1),
    .BITSIZE_m_axi_gmem_out2_awid(6),
    .BITSIZE_m_axi_gmem_out2_awaddr(32),
    .BITSIZE_m_axi_gmem_out2_awlen(8),
    .BITSIZE_m_axi_gmem_out2_awsize(3),
    .BITSIZE_m_axi_gmem_out2_awburst(2),
    .BITSIZE_m_axi_gmem_out2_awlock(1),
    .BITSIZE_m_axi_gmem_out2_awcache(4),
    .BITSIZE_m_axi_gmem_out2_awprot(3),
    .BITSIZE_m_axi_gmem_out2_awqos(4),
    .BITSIZE_m_axi_gmem_out2_awregion(4),
    .BITSIZE_m_axi_gmem_out2_awuser(1),
    .BITSIZE_m_axi_gmem_out2_wdata(32),
    .BITSIZE_m_axi_gmem_out2_wstrb(4),
    .BITSIZE_m_axi_gmem_out2_wuser(1),
    .BITSIZE_m_axi_gmem_out2_arid(6),
    .BITSIZE_m_axi_gmem_out2_araddr(32),
    .BITSIZE_m_axi_gmem_out2_arlen(8),
    .BITSIZE_m_axi_gmem_out2_arsize(3),
    .BITSIZE_m_axi_gmem_out2_arburst(2),
    .BITSIZE_m_axi_gmem_out2_arlock(1),
    .BITSIZE_m_axi_gmem_out2_arcache(4),
    .BITSIZE_m_axi_gmem_out2_arprot(3),
    .BITSIZE_m_axi_gmem_out2_arqos(4),
    .BITSIZE_m_axi_gmem_out2_arregion(4),
    .BITSIZE_m_axi_gmem_out2_aruser(1)) if_m_axi_gmem_out2_fu (.m_axi_gmem_out2_awready(sig_m_axi_gmem_out2_awready),
    .m_axi_gmem_out2_wready(sig_m_axi_gmem_out2_wready),
    .m_axi_gmem_out2_bid(sig_m_axi_gmem_out2_bid),
    .m_axi_gmem_out2_bresp(sig_m_axi_gmem_out2_bresp),
    .m_axi_gmem_out2_buser(sig_m_axi_gmem_out2_buser),
    .m_axi_gmem_out2_bvalid(sig_m_axi_gmem_out2_bvalid),
    .m_axi_gmem_out2_arready(sig_m_axi_gmem_out2_arready),
    .m_axi_gmem_out2_rid(sig_m_axi_gmem_out2_rid),
    .m_axi_gmem_out2_rdata(sig_m_axi_gmem_out2_rdata),
    .m_axi_gmem_out2_rresp(sig_m_axi_gmem_out2_rresp),
    .m_axi_gmem_out2_rlast(sig_m_axi_gmem_out2_rlast),
    .m_axi_gmem_out2_ruser(sig_m_axi_gmem_out2_ruser),
    .m_axi_gmem_out2_rvalid(sig_m_axi_gmem_out2_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem_out2_awid(sig_m_axi_gmem_out2_awid),
    .m_axi_gmem_out2_awaddr(sig_m_axi_gmem_out2_awaddr),
    .m_axi_gmem_out2_awlen(sig_m_axi_gmem_out2_awlen),
    .m_axi_gmem_out2_awsize(sig_m_axi_gmem_out2_awsize),
    .m_axi_gmem_out2_awburst(sig_m_axi_gmem_out2_awburst),
    .m_axi_gmem_out2_awlock(sig_m_axi_gmem_out2_awlock),
    .m_axi_gmem_out2_awcache(sig_m_axi_gmem_out2_awcache),
    .m_axi_gmem_out2_awprot(sig_m_axi_gmem_out2_awprot),
    .m_axi_gmem_out2_awqos(sig_m_axi_gmem_out2_awqos),
    .m_axi_gmem_out2_awregion(sig_m_axi_gmem_out2_awregion),
    .m_axi_gmem_out2_awuser(sig_m_axi_gmem_out2_awuser),
    .m_axi_gmem_out2_awvalid(sig_m_axi_gmem_out2_awvalid),
    .m_axi_gmem_out2_wdata(sig_m_axi_gmem_out2_wdata),
    .m_axi_gmem_out2_wstrb(sig_m_axi_gmem_out2_wstrb),
    .m_axi_gmem_out2_wlast(sig_m_axi_gmem_out2_wlast),
    .m_axi_gmem_out2_wuser(sig_m_axi_gmem_out2_wuser),
    .m_axi_gmem_out2_wvalid(sig_m_axi_gmem_out2_wvalid),
    .m_axi_gmem_out2_bready(sig_m_axi_gmem_out2_bready),
    .m_axi_gmem_out2_arid(sig_m_axi_gmem_out2_arid),
    .m_axi_gmem_out2_araddr(sig_m_axi_gmem_out2_araddr),
    .m_axi_gmem_out2_arlen(sig_m_axi_gmem_out2_arlen),
    .m_axi_gmem_out2_arsize(sig_m_axi_gmem_out2_arsize),
    .m_axi_gmem_out2_arburst(sig_m_axi_gmem_out2_arburst),
    .m_axi_gmem_out2_arlock(sig_m_axi_gmem_out2_arlock),
    .m_axi_gmem_out2_arcache(sig_m_axi_gmem_out2_arcache),
    .m_axi_gmem_out2_arprot(sig_m_axi_gmem_out2_arprot),
    .m_axi_gmem_out2_arqos(sig_m_axi_gmem_out2_arqos),
    .m_axi_gmem_out2_arregion(sig_m_axi_gmem_out2_arregion),
    .m_axi_gmem_out2_aruser(sig_m_axi_gmem_out2_aruser),
    .m_axi_gmem_out2_arvalid(sig_m_axi_gmem_out2_arvalid),
    .m_axi_gmem_out2_rready(sig_m_axi_gmem_out2_rready));
  if_m_axi_gmem_out3 #(.index(12),
    .BITSIZE_m_axi_gmem_out3_bid(6),
    .BITSIZE_m_axi_gmem_out3_bresp(2),
    .BITSIZE_m_axi_gmem_out3_buser(1),
    .BITSIZE_m_axi_gmem_out3_rid(6),
    .BITSIZE_m_axi_gmem_out3_rdata(32),
    .BITSIZE_m_axi_gmem_out3_rresp(2),
    .BITSIZE_m_axi_gmem_out3_ruser(1),
    .BITSIZE_m_axi_gmem_out3_awid(6),
    .BITSIZE_m_axi_gmem_out3_awaddr(32),
    .BITSIZE_m_axi_gmem_out3_awlen(8),
    .BITSIZE_m_axi_gmem_out3_awsize(3),
    .BITSIZE_m_axi_gmem_out3_awburst(2),
    .BITSIZE_m_axi_gmem_out3_awlock(1),
    .BITSIZE_m_axi_gmem_out3_awcache(4),
    .BITSIZE_m_axi_gmem_out3_awprot(3),
    .BITSIZE_m_axi_gmem_out3_awqos(4),
    .BITSIZE_m_axi_gmem_out3_awregion(4),
    .BITSIZE_m_axi_gmem_out3_awuser(1),
    .BITSIZE_m_axi_gmem_out3_wdata(32),
    .BITSIZE_m_axi_gmem_out3_wstrb(4),
    .BITSIZE_m_axi_gmem_out3_wuser(1),
    .BITSIZE_m_axi_gmem_out3_arid(6),
    .BITSIZE_m_axi_gmem_out3_araddr(32),
    .BITSIZE_m_axi_gmem_out3_arlen(8),
    .BITSIZE_m_axi_gmem_out3_arsize(3),
    .BITSIZE_m_axi_gmem_out3_arburst(2),
    .BITSIZE_m_axi_gmem_out3_arlock(1),
    .BITSIZE_m_axi_gmem_out3_arcache(4),
    .BITSIZE_m_axi_gmem_out3_arprot(3),
    .BITSIZE_m_axi_gmem_out3_arqos(4),
    .BITSIZE_m_axi_gmem_out3_arregion(4),
    .BITSIZE_m_axi_gmem_out3_aruser(1)) if_m_axi_gmem_out3_fu (.m_axi_gmem_out3_awready(sig_m_axi_gmem_out3_awready),
    .m_axi_gmem_out3_wready(sig_m_axi_gmem_out3_wready),
    .m_axi_gmem_out3_bid(sig_m_axi_gmem_out3_bid),
    .m_axi_gmem_out3_bresp(sig_m_axi_gmem_out3_bresp),
    .m_axi_gmem_out3_buser(sig_m_axi_gmem_out3_buser),
    .m_axi_gmem_out3_bvalid(sig_m_axi_gmem_out3_bvalid),
    .m_axi_gmem_out3_arready(sig_m_axi_gmem_out3_arready),
    .m_axi_gmem_out3_rid(sig_m_axi_gmem_out3_rid),
    .m_axi_gmem_out3_rdata(sig_m_axi_gmem_out3_rdata),
    .m_axi_gmem_out3_rresp(sig_m_axi_gmem_out3_rresp),
    .m_axi_gmem_out3_rlast(sig_m_axi_gmem_out3_rlast),
    .m_axi_gmem_out3_ruser(sig_m_axi_gmem_out3_ruser),
    .m_axi_gmem_out3_rvalid(sig_m_axi_gmem_out3_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem_out3_awid(sig_m_axi_gmem_out3_awid),
    .m_axi_gmem_out3_awaddr(sig_m_axi_gmem_out3_awaddr),
    .m_axi_gmem_out3_awlen(sig_m_axi_gmem_out3_awlen),
    .m_axi_gmem_out3_awsize(sig_m_axi_gmem_out3_awsize),
    .m_axi_gmem_out3_awburst(sig_m_axi_gmem_out3_awburst),
    .m_axi_gmem_out3_awlock(sig_m_axi_gmem_out3_awlock),
    .m_axi_gmem_out3_awcache(sig_m_axi_gmem_out3_awcache),
    .m_axi_gmem_out3_awprot(sig_m_axi_gmem_out3_awprot),
    .m_axi_gmem_out3_awqos(sig_m_axi_gmem_out3_awqos),
    .m_axi_gmem_out3_awregion(sig_m_axi_gmem_out3_awregion),
    .m_axi_gmem_out3_awuser(sig_m_axi_gmem_out3_awuser),
    .m_axi_gmem_out3_awvalid(sig_m_axi_gmem_out3_awvalid),
    .m_axi_gmem_out3_wdata(sig_m_axi_gmem_out3_wdata),
    .m_axi_gmem_out3_wstrb(sig_m_axi_gmem_out3_wstrb),
    .m_axi_gmem_out3_wlast(sig_m_axi_gmem_out3_wlast),
    .m_axi_gmem_out3_wuser(sig_m_axi_gmem_out3_wuser),
    .m_axi_gmem_out3_wvalid(sig_m_axi_gmem_out3_wvalid),
    .m_axi_gmem_out3_bready(sig_m_axi_gmem_out3_bready),
    .m_axi_gmem_out3_arid(sig_m_axi_gmem_out3_arid),
    .m_axi_gmem_out3_araddr(sig_m_axi_gmem_out3_araddr),
    .m_axi_gmem_out3_arlen(sig_m_axi_gmem_out3_arlen),
    .m_axi_gmem_out3_arsize(sig_m_axi_gmem_out3_arsize),
    .m_axi_gmem_out3_arburst(sig_m_axi_gmem_out3_arburst),
    .m_axi_gmem_out3_arlock(sig_m_axi_gmem_out3_arlock),
    .m_axi_gmem_out3_arcache(sig_m_axi_gmem_out3_arcache),
    .m_axi_gmem_out3_arprot(sig_m_axi_gmem_out3_arprot),
    .m_axi_gmem_out3_arqos(sig_m_axi_gmem_out3_arqos),
    .m_axi_gmem_out3_arregion(sig_m_axi_gmem_out3_arregion),
    .m_axi_gmem_out3_aruser(sig_m_axi_gmem_out3_aruser),
    .m_axi_gmem_out3_arvalid(sig_m_axi_gmem_out3_arvalid),
    .m_axi_gmem_out3_rready(sig_m_axi_gmem_out3_rready));
  if_m_axi_gmem_out4 #(.index(12),
    .BITSIZE_m_axi_gmem_out4_bid(6),
    .BITSIZE_m_axi_gmem_out4_bresp(2),
    .BITSIZE_m_axi_gmem_out4_buser(1),
    .BITSIZE_m_axi_gmem_out4_rid(6),
    .BITSIZE_m_axi_gmem_out4_rdata(32),
    .BITSIZE_m_axi_gmem_out4_rresp(2),
    .BITSIZE_m_axi_gmem_out4_ruser(1),
    .BITSIZE_m_axi_gmem_out4_awid(6),
    .BITSIZE_m_axi_gmem_out4_awaddr(32),
    .BITSIZE_m_axi_gmem_out4_awlen(8),
    .BITSIZE_m_axi_gmem_out4_awsize(3),
    .BITSIZE_m_axi_gmem_out4_awburst(2),
    .BITSIZE_m_axi_gmem_out4_awlock(1),
    .BITSIZE_m_axi_gmem_out4_awcache(4),
    .BITSIZE_m_axi_gmem_out4_awprot(3),
    .BITSIZE_m_axi_gmem_out4_awqos(4),
    .BITSIZE_m_axi_gmem_out4_awregion(4),
    .BITSIZE_m_axi_gmem_out4_awuser(1),
    .BITSIZE_m_axi_gmem_out4_wdata(32),
    .BITSIZE_m_axi_gmem_out4_wstrb(4),
    .BITSIZE_m_axi_gmem_out4_wuser(1),
    .BITSIZE_m_axi_gmem_out4_arid(6),
    .BITSIZE_m_axi_gmem_out4_araddr(32),
    .BITSIZE_m_axi_gmem_out4_arlen(8),
    .BITSIZE_m_axi_gmem_out4_arsize(3),
    .BITSIZE_m_axi_gmem_out4_arburst(2),
    .BITSIZE_m_axi_gmem_out4_arlock(1),
    .BITSIZE_m_axi_gmem_out4_arcache(4),
    .BITSIZE_m_axi_gmem_out4_arprot(3),
    .BITSIZE_m_axi_gmem_out4_arqos(4),
    .BITSIZE_m_axi_gmem_out4_arregion(4),
    .BITSIZE_m_axi_gmem_out4_aruser(1)) if_m_axi_gmem_out4_fu (.m_axi_gmem_out4_awready(sig_m_axi_gmem_out4_awready),
    .m_axi_gmem_out4_wready(sig_m_axi_gmem_out4_wready),
    .m_axi_gmem_out4_bid(sig_m_axi_gmem_out4_bid),
    .m_axi_gmem_out4_bresp(sig_m_axi_gmem_out4_bresp),
    .m_axi_gmem_out4_buser(sig_m_axi_gmem_out4_buser),
    .m_axi_gmem_out4_bvalid(sig_m_axi_gmem_out4_bvalid),
    .m_axi_gmem_out4_arready(sig_m_axi_gmem_out4_arready),
    .m_axi_gmem_out4_rid(sig_m_axi_gmem_out4_rid),
    .m_axi_gmem_out4_rdata(sig_m_axi_gmem_out4_rdata),
    .m_axi_gmem_out4_rresp(sig_m_axi_gmem_out4_rresp),
    .m_axi_gmem_out4_rlast(sig_m_axi_gmem_out4_rlast),
    .m_axi_gmem_out4_ruser(sig_m_axi_gmem_out4_ruser),
    .m_axi_gmem_out4_rvalid(sig_m_axi_gmem_out4_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem_out4_awid(sig_m_axi_gmem_out4_awid),
    .m_axi_gmem_out4_awaddr(sig_m_axi_gmem_out4_awaddr),
    .m_axi_gmem_out4_awlen(sig_m_axi_gmem_out4_awlen),
    .m_axi_gmem_out4_awsize(sig_m_axi_gmem_out4_awsize),
    .m_axi_gmem_out4_awburst(sig_m_axi_gmem_out4_awburst),
    .m_axi_gmem_out4_awlock(sig_m_axi_gmem_out4_awlock),
    .m_axi_gmem_out4_awcache(sig_m_axi_gmem_out4_awcache),
    .m_axi_gmem_out4_awprot(sig_m_axi_gmem_out4_awprot),
    .m_axi_gmem_out4_awqos(sig_m_axi_gmem_out4_awqos),
    .m_axi_gmem_out4_awregion(sig_m_axi_gmem_out4_awregion),
    .m_axi_gmem_out4_awuser(sig_m_axi_gmem_out4_awuser),
    .m_axi_gmem_out4_awvalid(sig_m_axi_gmem_out4_awvalid),
    .m_axi_gmem_out4_wdata(sig_m_axi_gmem_out4_wdata),
    .m_axi_gmem_out4_wstrb(sig_m_axi_gmem_out4_wstrb),
    .m_axi_gmem_out4_wlast(sig_m_axi_gmem_out4_wlast),
    .m_axi_gmem_out4_wuser(sig_m_axi_gmem_out4_wuser),
    .m_axi_gmem_out4_wvalid(sig_m_axi_gmem_out4_wvalid),
    .m_axi_gmem_out4_bready(sig_m_axi_gmem_out4_bready),
    .m_axi_gmem_out4_arid(sig_m_axi_gmem_out4_arid),
    .m_axi_gmem_out4_araddr(sig_m_axi_gmem_out4_araddr),
    .m_axi_gmem_out4_arlen(sig_m_axi_gmem_out4_arlen),
    .m_axi_gmem_out4_arsize(sig_m_axi_gmem_out4_arsize),
    .m_axi_gmem_out4_arburst(sig_m_axi_gmem_out4_arburst),
    .m_axi_gmem_out4_arlock(sig_m_axi_gmem_out4_arlock),
    .m_axi_gmem_out4_arcache(sig_m_axi_gmem_out4_arcache),
    .m_axi_gmem_out4_arprot(sig_m_axi_gmem_out4_arprot),
    .m_axi_gmem_out4_arqos(sig_m_axi_gmem_out4_arqos),
    .m_axi_gmem_out4_arregion(sig_m_axi_gmem_out4_arregion),
    .m_axi_gmem_out4_aruser(sig_m_axi_gmem_out4_aruser),
    .m_axi_gmem_out4_arvalid(sig_m_axi_gmem_out4_arvalid),
    .m_axi_gmem_out4_rready(sig_m_axi_gmem_out4_rready));
  if_m_axi_gmem_out5 #(.index(12),
    .BITSIZE_m_axi_gmem_out5_bid(6),
    .BITSIZE_m_axi_gmem_out5_bresp(2),
    .BITSIZE_m_axi_gmem_out5_buser(1),
    .BITSIZE_m_axi_gmem_out5_rid(6),
    .BITSIZE_m_axi_gmem_out5_rdata(32),
    .BITSIZE_m_axi_gmem_out5_rresp(2),
    .BITSIZE_m_axi_gmem_out5_ruser(1),
    .BITSIZE_m_axi_gmem_out5_awid(6),
    .BITSIZE_m_axi_gmem_out5_awaddr(32),
    .BITSIZE_m_axi_gmem_out5_awlen(8),
    .BITSIZE_m_axi_gmem_out5_awsize(3),
    .BITSIZE_m_axi_gmem_out5_awburst(2),
    .BITSIZE_m_axi_gmem_out5_awlock(1),
    .BITSIZE_m_axi_gmem_out5_awcache(4),
    .BITSIZE_m_axi_gmem_out5_awprot(3),
    .BITSIZE_m_axi_gmem_out5_awqos(4),
    .BITSIZE_m_axi_gmem_out5_awregion(4),
    .BITSIZE_m_axi_gmem_out5_awuser(1),
    .BITSIZE_m_axi_gmem_out5_wdata(32),
    .BITSIZE_m_axi_gmem_out5_wstrb(4),
    .BITSIZE_m_axi_gmem_out5_wuser(1),
    .BITSIZE_m_axi_gmem_out5_arid(6),
    .BITSIZE_m_axi_gmem_out5_araddr(32),
    .BITSIZE_m_axi_gmem_out5_arlen(8),
    .BITSIZE_m_axi_gmem_out5_arsize(3),
    .BITSIZE_m_axi_gmem_out5_arburst(2),
    .BITSIZE_m_axi_gmem_out5_arlock(1),
    .BITSIZE_m_axi_gmem_out5_arcache(4),
    .BITSIZE_m_axi_gmem_out5_arprot(3),
    .BITSIZE_m_axi_gmem_out5_arqos(4),
    .BITSIZE_m_axi_gmem_out5_arregion(4),
    .BITSIZE_m_axi_gmem_out5_aruser(1)) if_m_axi_gmem_out5_fu (.m_axi_gmem_out5_awready(sig_m_axi_gmem_out5_awready),
    .m_axi_gmem_out5_wready(sig_m_axi_gmem_out5_wready),
    .m_axi_gmem_out5_bid(sig_m_axi_gmem_out5_bid),
    .m_axi_gmem_out5_bresp(sig_m_axi_gmem_out5_bresp),
    .m_axi_gmem_out5_buser(sig_m_axi_gmem_out5_buser),
    .m_axi_gmem_out5_bvalid(sig_m_axi_gmem_out5_bvalid),
    .m_axi_gmem_out5_arready(sig_m_axi_gmem_out5_arready),
    .m_axi_gmem_out5_rid(sig_m_axi_gmem_out5_rid),
    .m_axi_gmem_out5_rdata(sig_m_axi_gmem_out5_rdata),
    .m_axi_gmem_out5_rresp(sig_m_axi_gmem_out5_rresp),
    .m_axi_gmem_out5_rlast(sig_m_axi_gmem_out5_rlast),
    .m_axi_gmem_out5_ruser(sig_m_axi_gmem_out5_ruser),
    .m_axi_gmem_out5_rvalid(sig_m_axi_gmem_out5_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem_out5_awid(sig_m_axi_gmem_out5_awid),
    .m_axi_gmem_out5_awaddr(sig_m_axi_gmem_out5_awaddr),
    .m_axi_gmem_out5_awlen(sig_m_axi_gmem_out5_awlen),
    .m_axi_gmem_out5_awsize(sig_m_axi_gmem_out5_awsize),
    .m_axi_gmem_out5_awburst(sig_m_axi_gmem_out5_awburst),
    .m_axi_gmem_out5_awlock(sig_m_axi_gmem_out5_awlock),
    .m_axi_gmem_out5_awcache(sig_m_axi_gmem_out5_awcache),
    .m_axi_gmem_out5_awprot(sig_m_axi_gmem_out5_awprot),
    .m_axi_gmem_out5_awqos(sig_m_axi_gmem_out5_awqos),
    .m_axi_gmem_out5_awregion(sig_m_axi_gmem_out5_awregion),
    .m_axi_gmem_out5_awuser(sig_m_axi_gmem_out5_awuser),
    .m_axi_gmem_out5_awvalid(sig_m_axi_gmem_out5_awvalid),
    .m_axi_gmem_out5_wdata(sig_m_axi_gmem_out5_wdata),
    .m_axi_gmem_out5_wstrb(sig_m_axi_gmem_out5_wstrb),
    .m_axi_gmem_out5_wlast(sig_m_axi_gmem_out5_wlast),
    .m_axi_gmem_out5_wuser(sig_m_axi_gmem_out5_wuser),
    .m_axi_gmem_out5_wvalid(sig_m_axi_gmem_out5_wvalid),
    .m_axi_gmem_out5_bready(sig_m_axi_gmem_out5_bready),
    .m_axi_gmem_out5_arid(sig_m_axi_gmem_out5_arid),
    .m_axi_gmem_out5_araddr(sig_m_axi_gmem_out5_araddr),
    .m_axi_gmem_out5_arlen(sig_m_axi_gmem_out5_arlen),
    .m_axi_gmem_out5_arsize(sig_m_axi_gmem_out5_arsize),
    .m_axi_gmem_out5_arburst(sig_m_axi_gmem_out5_arburst),
    .m_axi_gmem_out5_arlock(sig_m_axi_gmem_out5_arlock),
    .m_axi_gmem_out5_arcache(sig_m_axi_gmem_out5_arcache),
    .m_axi_gmem_out5_arprot(sig_m_axi_gmem_out5_arprot),
    .m_axi_gmem_out5_arqos(sig_m_axi_gmem_out5_arqos),
    .m_axi_gmem_out5_arregion(sig_m_axi_gmem_out5_arregion),
    .m_axi_gmem_out5_aruser(sig_m_axi_gmem_out5_aruser),
    .m_axi_gmem_out5_arvalid(sig_m_axi_gmem_out5_arvalid),
    .m_axi_gmem_out5_rready(sig_m_axi_gmem_out5_rready));
  if_m_axi_gmem_out6 #(.index(12),
    .BITSIZE_m_axi_gmem_out6_bid(6),
    .BITSIZE_m_axi_gmem_out6_bresp(2),
    .BITSIZE_m_axi_gmem_out6_buser(1),
    .BITSIZE_m_axi_gmem_out6_rid(6),
    .BITSIZE_m_axi_gmem_out6_rdata(32),
    .BITSIZE_m_axi_gmem_out6_rresp(2),
    .BITSIZE_m_axi_gmem_out6_ruser(1),
    .BITSIZE_m_axi_gmem_out6_awid(6),
    .BITSIZE_m_axi_gmem_out6_awaddr(32),
    .BITSIZE_m_axi_gmem_out6_awlen(8),
    .BITSIZE_m_axi_gmem_out6_awsize(3),
    .BITSIZE_m_axi_gmem_out6_awburst(2),
    .BITSIZE_m_axi_gmem_out6_awlock(1),
    .BITSIZE_m_axi_gmem_out6_awcache(4),
    .BITSIZE_m_axi_gmem_out6_awprot(3),
    .BITSIZE_m_axi_gmem_out6_awqos(4),
    .BITSIZE_m_axi_gmem_out6_awregion(4),
    .BITSIZE_m_axi_gmem_out6_awuser(1),
    .BITSIZE_m_axi_gmem_out6_wdata(32),
    .BITSIZE_m_axi_gmem_out6_wstrb(4),
    .BITSIZE_m_axi_gmem_out6_wuser(1),
    .BITSIZE_m_axi_gmem_out6_arid(6),
    .BITSIZE_m_axi_gmem_out6_araddr(32),
    .BITSIZE_m_axi_gmem_out6_arlen(8),
    .BITSIZE_m_axi_gmem_out6_arsize(3),
    .BITSIZE_m_axi_gmem_out6_arburst(2),
    .BITSIZE_m_axi_gmem_out6_arlock(1),
    .BITSIZE_m_axi_gmem_out6_arcache(4),
    .BITSIZE_m_axi_gmem_out6_arprot(3),
    .BITSIZE_m_axi_gmem_out6_arqos(4),
    .BITSIZE_m_axi_gmem_out6_arregion(4),
    .BITSIZE_m_axi_gmem_out6_aruser(1)) if_m_axi_gmem_out6_fu (.m_axi_gmem_out6_awready(sig_m_axi_gmem_out6_awready),
    .m_axi_gmem_out6_wready(sig_m_axi_gmem_out6_wready),
    .m_axi_gmem_out6_bid(sig_m_axi_gmem_out6_bid),
    .m_axi_gmem_out6_bresp(sig_m_axi_gmem_out6_bresp),
    .m_axi_gmem_out6_buser(sig_m_axi_gmem_out6_buser),
    .m_axi_gmem_out6_bvalid(sig_m_axi_gmem_out6_bvalid),
    .m_axi_gmem_out6_arready(sig_m_axi_gmem_out6_arready),
    .m_axi_gmem_out6_rid(sig_m_axi_gmem_out6_rid),
    .m_axi_gmem_out6_rdata(sig_m_axi_gmem_out6_rdata),
    .m_axi_gmem_out6_rresp(sig_m_axi_gmem_out6_rresp),
    .m_axi_gmem_out6_rlast(sig_m_axi_gmem_out6_rlast),
    .m_axi_gmem_out6_ruser(sig_m_axi_gmem_out6_ruser),
    .m_axi_gmem_out6_rvalid(sig_m_axi_gmem_out6_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem_out6_awid(sig_m_axi_gmem_out6_awid),
    .m_axi_gmem_out6_awaddr(sig_m_axi_gmem_out6_awaddr),
    .m_axi_gmem_out6_awlen(sig_m_axi_gmem_out6_awlen),
    .m_axi_gmem_out6_awsize(sig_m_axi_gmem_out6_awsize),
    .m_axi_gmem_out6_awburst(sig_m_axi_gmem_out6_awburst),
    .m_axi_gmem_out6_awlock(sig_m_axi_gmem_out6_awlock),
    .m_axi_gmem_out6_awcache(sig_m_axi_gmem_out6_awcache),
    .m_axi_gmem_out6_awprot(sig_m_axi_gmem_out6_awprot),
    .m_axi_gmem_out6_awqos(sig_m_axi_gmem_out6_awqos),
    .m_axi_gmem_out6_awregion(sig_m_axi_gmem_out6_awregion),
    .m_axi_gmem_out6_awuser(sig_m_axi_gmem_out6_awuser),
    .m_axi_gmem_out6_awvalid(sig_m_axi_gmem_out6_awvalid),
    .m_axi_gmem_out6_wdata(sig_m_axi_gmem_out6_wdata),
    .m_axi_gmem_out6_wstrb(sig_m_axi_gmem_out6_wstrb),
    .m_axi_gmem_out6_wlast(sig_m_axi_gmem_out6_wlast),
    .m_axi_gmem_out6_wuser(sig_m_axi_gmem_out6_wuser),
    .m_axi_gmem_out6_wvalid(sig_m_axi_gmem_out6_wvalid),
    .m_axi_gmem_out6_bready(sig_m_axi_gmem_out6_bready),
    .m_axi_gmem_out6_arid(sig_m_axi_gmem_out6_arid),
    .m_axi_gmem_out6_araddr(sig_m_axi_gmem_out6_araddr),
    .m_axi_gmem_out6_arlen(sig_m_axi_gmem_out6_arlen),
    .m_axi_gmem_out6_arsize(sig_m_axi_gmem_out6_arsize),
    .m_axi_gmem_out6_arburst(sig_m_axi_gmem_out6_arburst),
    .m_axi_gmem_out6_arlock(sig_m_axi_gmem_out6_arlock),
    .m_axi_gmem_out6_arcache(sig_m_axi_gmem_out6_arcache),
    .m_axi_gmem_out6_arprot(sig_m_axi_gmem_out6_arprot),
    .m_axi_gmem_out6_arqos(sig_m_axi_gmem_out6_arqos),
    .m_axi_gmem_out6_arregion(sig_m_axi_gmem_out6_arregion),
    .m_axi_gmem_out6_aruser(sig_m_axi_gmem_out6_aruser),
    .m_axi_gmem_out6_arvalid(sig_m_axi_gmem_out6_arvalid),
    .m_axi_gmem_out6_rready(sig_m_axi_gmem_out6_rready));
  if_m_axi_gmem_out7 #(.index(12),
    .BITSIZE_m_axi_gmem_out7_bid(6),
    .BITSIZE_m_axi_gmem_out7_bresp(2),
    .BITSIZE_m_axi_gmem_out7_buser(1),
    .BITSIZE_m_axi_gmem_out7_rid(6),
    .BITSIZE_m_axi_gmem_out7_rdata(32),
    .BITSIZE_m_axi_gmem_out7_rresp(2),
    .BITSIZE_m_axi_gmem_out7_ruser(1),
    .BITSIZE_m_axi_gmem_out7_awid(6),
    .BITSIZE_m_axi_gmem_out7_awaddr(32),
    .BITSIZE_m_axi_gmem_out7_awlen(8),
    .BITSIZE_m_axi_gmem_out7_awsize(3),
    .BITSIZE_m_axi_gmem_out7_awburst(2),
    .BITSIZE_m_axi_gmem_out7_awlock(1),
    .BITSIZE_m_axi_gmem_out7_awcache(4),
    .BITSIZE_m_axi_gmem_out7_awprot(3),
    .BITSIZE_m_axi_gmem_out7_awqos(4),
    .BITSIZE_m_axi_gmem_out7_awregion(4),
    .BITSIZE_m_axi_gmem_out7_awuser(1),
    .BITSIZE_m_axi_gmem_out7_wdata(32),
    .BITSIZE_m_axi_gmem_out7_wstrb(4),
    .BITSIZE_m_axi_gmem_out7_wuser(1),
    .BITSIZE_m_axi_gmem_out7_arid(6),
    .BITSIZE_m_axi_gmem_out7_araddr(32),
    .BITSIZE_m_axi_gmem_out7_arlen(8),
    .BITSIZE_m_axi_gmem_out7_arsize(3),
    .BITSIZE_m_axi_gmem_out7_arburst(2),
    .BITSIZE_m_axi_gmem_out7_arlock(1),
    .BITSIZE_m_axi_gmem_out7_arcache(4),
    .BITSIZE_m_axi_gmem_out7_arprot(3),
    .BITSIZE_m_axi_gmem_out7_arqos(4),
    .BITSIZE_m_axi_gmem_out7_arregion(4),
    .BITSIZE_m_axi_gmem_out7_aruser(1)) if_m_axi_gmem_out7_fu (.m_axi_gmem_out7_awready(sig_m_axi_gmem_out7_awready),
    .m_axi_gmem_out7_wready(sig_m_axi_gmem_out7_wready),
    .m_axi_gmem_out7_bid(sig_m_axi_gmem_out7_bid),
    .m_axi_gmem_out7_bresp(sig_m_axi_gmem_out7_bresp),
    .m_axi_gmem_out7_buser(sig_m_axi_gmem_out7_buser),
    .m_axi_gmem_out7_bvalid(sig_m_axi_gmem_out7_bvalid),
    .m_axi_gmem_out7_arready(sig_m_axi_gmem_out7_arready),
    .m_axi_gmem_out7_rid(sig_m_axi_gmem_out7_rid),
    .m_axi_gmem_out7_rdata(sig_m_axi_gmem_out7_rdata),
    .m_axi_gmem_out7_rresp(sig_m_axi_gmem_out7_rresp),
    .m_axi_gmem_out7_rlast(sig_m_axi_gmem_out7_rlast),
    .m_axi_gmem_out7_ruser(sig_m_axi_gmem_out7_ruser),
    .m_axi_gmem_out7_rvalid(sig_m_axi_gmem_out7_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem_out7_awid(sig_m_axi_gmem_out7_awid),
    .m_axi_gmem_out7_awaddr(sig_m_axi_gmem_out7_awaddr),
    .m_axi_gmem_out7_awlen(sig_m_axi_gmem_out7_awlen),
    .m_axi_gmem_out7_awsize(sig_m_axi_gmem_out7_awsize),
    .m_axi_gmem_out7_awburst(sig_m_axi_gmem_out7_awburst),
    .m_axi_gmem_out7_awlock(sig_m_axi_gmem_out7_awlock),
    .m_axi_gmem_out7_awcache(sig_m_axi_gmem_out7_awcache),
    .m_axi_gmem_out7_awprot(sig_m_axi_gmem_out7_awprot),
    .m_axi_gmem_out7_awqos(sig_m_axi_gmem_out7_awqos),
    .m_axi_gmem_out7_awregion(sig_m_axi_gmem_out7_awregion),
    .m_axi_gmem_out7_awuser(sig_m_axi_gmem_out7_awuser),
    .m_axi_gmem_out7_awvalid(sig_m_axi_gmem_out7_awvalid),
    .m_axi_gmem_out7_wdata(sig_m_axi_gmem_out7_wdata),
    .m_axi_gmem_out7_wstrb(sig_m_axi_gmem_out7_wstrb),
    .m_axi_gmem_out7_wlast(sig_m_axi_gmem_out7_wlast),
    .m_axi_gmem_out7_wuser(sig_m_axi_gmem_out7_wuser),
    .m_axi_gmem_out7_wvalid(sig_m_axi_gmem_out7_wvalid),
    .m_axi_gmem_out7_bready(sig_m_axi_gmem_out7_bready),
    .m_axi_gmem_out7_arid(sig_m_axi_gmem_out7_arid),
    .m_axi_gmem_out7_araddr(sig_m_axi_gmem_out7_araddr),
    .m_axi_gmem_out7_arlen(sig_m_axi_gmem_out7_arlen),
    .m_axi_gmem_out7_arsize(sig_m_axi_gmem_out7_arsize),
    .m_axi_gmem_out7_arburst(sig_m_axi_gmem_out7_arburst),
    .m_axi_gmem_out7_arlock(sig_m_axi_gmem_out7_arlock),
    .m_axi_gmem_out7_arcache(sig_m_axi_gmem_out7_arcache),
    .m_axi_gmem_out7_arprot(sig_m_axi_gmem_out7_arprot),
    .m_axi_gmem_out7_arqos(sig_m_axi_gmem_out7_arqos),
    .m_axi_gmem_out7_arregion(sig_m_axi_gmem_out7_arregion),
    .m_axi_gmem_out7_aruser(sig_m_axi_gmem_out7_aruser),
    .m_axi_gmem_out7_arvalid(sig_m_axi_gmem_out7_arvalid),
    .m_axi_gmem_out7_rready(sig_m_axi_gmem_out7_rready));
  if_m_axi_gmem_w0 #(.index(12),
    .BITSIZE_m_axi_gmem_w0_bid(6),
    .BITSIZE_m_axi_gmem_w0_bresp(2),
    .BITSIZE_m_axi_gmem_w0_buser(1),
    .BITSIZE_m_axi_gmem_w0_rid(6),
    .BITSIZE_m_axi_gmem_w0_rdata(32),
    .BITSIZE_m_axi_gmem_w0_rresp(2),
    .BITSIZE_m_axi_gmem_w0_ruser(1),
    .BITSIZE_m_axi_gmem_w0_awid(6),
    .BITSIZE_m_axi_gmem_w0_awaddr(32),
    .BITSIZE_m_axi_gmem_w0_awlen(8),
    .BITSIZE_m_axi_gmem_w0_awsize(3),
    .BITSIZE_m_axi_gmem_w0_awburst(2),
    .BITSIZE_m_axi_gmem_w0_awlock(1),
    .BITSIZE_m_axi_gmem_w0_awcache(4),
    .BITSIZE_m_axi_gmem_w0_awprot(3),
    .BITSIZE_m_axi_gmem_w0_awqos(4),
    .BITSIZE_m_axi_gmem_w0_awregion(4),
    .BITSIZE_m_axi_gmem_w0_awuser(1),
    .BITSIZE_m_axi_gmem_w0_wdata(32),
    .BITSIZE_m_axi_gmem_w0_wstrb(4),
    .BITSIZE_m_axi_gmem_w0_wuser(1),
    .BITSIZE_m_axi_gmem_w0_arid(6),
    .BITSIZE_m_axi_gmem_w0_araddr(32),
    .BITSIZE_m_axi_gmem_w0_arlen(8),
    .BITSIZE_m_axi_gmem_w0_arsize(3),
    .BITSIZE_m_axi_gmem_w0_arburst(2),
    .BITSIZE_m_axi_gmem_w0_arlock(1),
    .BITSIZE_m_axi_gmem_w0_arcache(4),
    .BITSIZE_m_axi_gmem_w0_arprot(3),
    .BITSIZE_m_axi_gmem_w0_arqos(4),
    .BITSIZE_m_axi_gmem_w0_arregion(4),
    .BITSIZE_m_axi_gmem_w0_aruser(1)) if_m_axi_gmem_w0_fu (.m_axi_gmem_w0_awready(sig_m_axi_gmem_w0_awready),
    .m_axi_gmem_w0_wready(sig_m_axi_gmem_w0_wready),
    .m_axi_gmem_w0_bid(sig_m_axi_gmem_w0_bid),
    .m_axi_gmem_w0_bresp(sig_m_axi_gmem_w0_bresp),
    .m_axi_gmem_w0_buser(sig_m_axi_gmem_w0_buser),
    .m_axi_gmem_w0_bvalid(sig_m_axi_gmem_w0_bvalid),
    .m_axi_gmem_w0_arready(sig_m_axi_gmem_w0_arready),
    .m_axi_gmem_w0_rid(sig_m_axi_gmem_w0_rid),
    .m_axi_gmem_w0_rdata(sig_m_axi_gmem_w0_rdata),
    .m_axi_gmem_w0_rresp(sig_m_axi_gmem_w0_rresp),
    .m_axi_gmem_w0_rlast(sig_m_axi_gmem_w0_rlast),
    .m_axi_gmem_w0_ruser(sig_m_axi_gmem_w0_ruser),
    .m_axi_gmem_w0_rvalid(sig_m_axi_gmem_w0_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem_w0_awid(sig_m_axi_gmem_w0_awid),
    .m_axi_gmem_w0_awaddr(sig_m_axi_gmem_w0_awaddr),
    .m_axi_gmem_w0_awlen(sig_m_axi_gmem_w0_awlen),
    .m_axi_gmem_w0_awsize(sig_m_axi_gmem_w0_awsize),
    .m_axi_gmem_w0_awburst(sig_m_axi_gmem_w0_awburst),
    .m_axi_gmem_w0_awlock(sig_m_axi_gmem_w0_awlock),
    .m_axi_gmem_w0_awcache(sig_m_axi_gmem_w0_awcache),
    .m_axi_gmem_w0_awprot(sig_m_axi_gmem_w0_awprot),
    .m_axi_gmem_w0_awqos(sig_m_axi_gmem_w0_awqos),
    .m_axi_gmem_w0_awregion(sig_m_axi_gmem_w0_awregion),
    .m_axi_gmem_w0_awuser(sig_m_axi_gmem_w0_awuser),
    .m_axi_gmem_w0_awvalid(sig_m_axi_gmem_w0_awvalid),
    .m_axi_gmem_w0_wdata(sig_m_axi_gmem_w0_wdata),
    .m_axi_gmem_w0_wstrb(sig_m_axi_gmem_w0_wstrb),
    .m_axi_gmem_w0_wlast(sig_m_axi_gmem_w0_wlast),
    .m_axi_gmem_w0_wuser(sig_m_axi_gmem_w0_wuser),
    .m_axi_gmem_w0_wvalid(sig_m_axi_gmem_w0_wvalid),
    .m_axi_gmem_w0_bready(sig_m_axi_gmem_w0_bready),
    .m_axi_gmem_w0_arid(sig_m_axi_gmem_w0_arid),
    .m_axi_gmem_w0_araddr(sig_m_axi_gmem_w0_araddr),
    .m_axi_gmem_w0_arlen(sig_m_axi_gmem_w0_arlen),
    .m_axi_gmem_w0_arsize(sig_m_axi_gmem_w0_arsize),
    .m_axi_gmem_w0_arburst(sig_m_axi_gmem_w0_arburst),
    .m_axi_gmem_w0_arlock(sig_m_axi_gmem_w0_arlock),
    .m_axi_gmem_w0_arcache(sig_m_axi_gmem_w0_arcache),
    .m_axi_gmem_w0_arprot(sig_m_axi_gmem_w0_arprot),
    .m_axi_gmem_w0_arqos(sig_m_axi_gmem_w0_arqos),
    .m_axi_gmem_w0_arregion(sig_m_axi_gmem_w0_arregion),
    .m_axi_gmem_w0_aruser(sig_m_axi_gmem_w0_aruser),
    .m_axi_gmem_w0_arvalid(sig_m_axi_gmem_w0_arvalid),
    .m_axi_gmem_w0_rready(sig_m_axi_gmem_w0_rready));
  if_m_axi_gmem_w1 #(.index(12),
    .BITSIZE_m_axi_gmem_w1_bid(6),
    .BITSIZE_m_axi_gmem_w1_bresp(2),
    .BITSIZE_m_axi_gmem_w1_buser(1),
    .BITSIZE_m_axi_gmem_w1_rid(6),
    .BITSIZE_m_axi_gmem_w1_rdata(32),
    .BITSIZE_m_axi_gmem_w1_rresp(2),
    .BITSIZE_m_axi_gmem_w1_ruser(1),
    .BITSIZE_m_axi_gmem_w1_awid(6),
    .BITSIZE_m_axi_gmem_w1_awaddr(32),
    .BITSIZE_m_axi_gmem_w1_awlen(8),
    .BITSIZE_m_axi_gmem_w1_awsize(3),
    .BITSIZE_m_axi_gmem_w1_awburst(2),
    .BITSIZE_m_axi_gmem_w1_awlock(1),
    .BITSIZE_m_axi_gmem_w1_awcache(4),
    .BITSIZE_m_axi_gmem_w1_awprot(3),
    .BITSIZE_m_axi_gmem_w1_awqos(4),
    .BITSIZE_m_axi_gmem_w1_awregion(4),
    .BITSIZE_m_axi_gmem_w1_awuser(1),
    .BITSIZE_m_axi_gmem_w1_wdata(32),
    .BITSIZE_m_axi_gmem_w1_wstrb(4),
    .BITSIZE_m_axi_gmem_w1_wuser(1),
    .BITSIZE_m_axi_gmem_w1_arid(6),
    .BITSIZE_m_axi_gmem_w1_araddr(32),
    .BITSIZE_m_axi_gmem_w1_arlen(8),
    .BITSIZE_m_axi_gmem_w1_arsize(3),
    .BITSIZE_m_axi_gmem_w1_arburst(2),
    .BITSIZE_m_axi_gmem_w1_arlock(1),
    .BITSIZE_m_axi_gmem_w1_arcache(4),
    .BITSIZE_m_axi_gmem_w1_arprot(3),
    .BITSIZE_m_axi_gmem_w1_arqos(4),
    .BITSIZE_m_axi_gmem_w1_arregion(4),
    .BITSIZE_m_axi_gmem_w1_aruser(1)) if_m_axi_gmem_w1_fu (.m_axi_gmem_w1_awready(sig_m_axi_gmem_w1_awready),
    .m_axi_gmem_w1_wready(sig_m_axi_gmem_w1_wready),
    .m_axi_gmem_w1_bid(sig_m_axi_gmem_w1_bid),
    .m_axi_gmem_w1_bresp(sig_m_axi_gmem_w1_bresp),
    .m_axi_gmem_w1_buser(sig_m_axi_gmem_w1_buser),
    .m_axi_gmem_w1_bvalid(sig_m_axi_gmem_w1_bvalid),
    .m_axi_gmem_w1_arready(sig_m_axi_gmem_w1_arready),
    .m_axi_gmem_w1_rid(sig_m_axi_gmem_w1_rid),
    .m_axi_gmem_w1_rdata(sig_m_axi_gmem_w1_rdata),
    .m_axi_gmem_w1_rresp(sig_m_axi_gmem_w1_rresp),
    .m_axi_gmem_w1_rlast(sig_m_axi_gmem_w1_rlast),
    .m_axi_gmem_w1_ruser(sig_m_axi_gmem_w1_ruser),
    .m_axi_gmem_w1_rvalid(sig_m_axi_gmem_w1_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem_w1_awid(sig_m_axi_gmem_w1_awid),
    .m_axi_gmem_w1_awaddr(sig_m_axi_gmem_w1_awaddr),
    .m_axi_gmem_w1_awlen(sig_m_axi_gmem_w1_awlen),
    .m_axi_gmem_w1_awsize(sig_m_axi_gmem_w1_awsize),
    .m_axi_gmem_w1_awburst(sig_m_axi_gmem_w1_awburst),
    .m_axi_gmem_w1_awlock(sig_m_axi_gmem_w1_awlock),
    .m_axi_gmem_w1_awcache(sig_m_axi_gmem_w1_awcache),
    .m_axi_gmem_w1_awprot(sig_m_axi_gmem_w1_awprot),
    .m_axi_gmem_w1_awqos(sig_m_axi_gmem_w1_awqos),
    .m_axi_gmem_w1_awregion(sig_m_axi_gmem_w1_awregion),
    .m_axi_gmem_w1_awuser(sig_m_axi_gmem_w1_awuser),
    .m_axi_gmem_w1_awvalid(sig_m_axi_gmem_w1_awvalid),
    .m_axi_gmem_w1_wdata(sig_m_axi_gmem_w1_wdata),
    .m_axi_gmem_w1_wstrb(sig_m_axi_gmem_w1_wstrb),
    .m_axi_gmem_w1_wlast(sig_m_axi_gmem_w1_wlast),
    .m_axi_gmem_w1_wuser(sig_m_axi_gmem_w1_wuser),
    .m_axi_gmem_w1_wvalid(sig_m_axi_gmem_w1_wvalid),
    .m_axi_gmem_w1_bready(sig_m_axi_gmem_w1_bready),
    .m_axi_gmem_w1_arid(sig_m_axi_gmem_w1_arid),
    .m_axi_gmem_w1_araddr(sig_m_axi_gmem_w1_araddr),
    .m_axi_gmem_w1_arlen(sig_m_axi_gmem_w1_arlen),
    .m_axi_gmem_w1_arsize(sig_m_axi_gmem_w1_arsize),
    .m_axi_gmem_w1_arburst(sig_m_axi_gmem_w1_arburst),
    .m_axi_gmem_w1_arlock(sig_m_axi_gmem_w1_arlock),
    .m_axi_gmem_w1_arcache(sig_m_axi_gmem_w1_arcache),
    .m_axi_gmem_w1_arprot(sig_m_axi_gmem_w1_arprot),
    .m_axi_gmem_w1_arqos(sig_m_axi_gmem_w1_arqos),
    .m_axi_gmem_w1_arregion(sig_m_axi_gmem_w1_arregion),
    .m_axi_gmem_w1_aruser(sig_m_axi_gmem_w1_aruser),
    .m_axi_gmem_w1_arvalid(sig_m_axi_gmem_w1_arvalid),
    .m_axi_gmem_w1_rready(sig_m_axi_gmem_w1_rready));

endmodule


// MODULE DECLARATION
module bambu_testbench(clock);

  input clock;
  
  initial
  begin
    `ifndef VERILATOR
    // VCD file generation
    $dumpfile("HLS_output/simulation/test.vcd");
    `ifdef GENERATE_VCD
    $dumpvars;
    `endif
    `endif
  end
  
  bambu_testbench_impl system(.clock(clock));
  
endmodule

`ifndef VERILATOR
module clocked_bambu_testbench;
parameter HALF_CLOCK_PERIOD=1.0;
  
  reg clock;
  initial clock = 1;
  always # HALF_CLOCK_PERIOD clock = !clock;
  
  bambu_testbench bambu_testbench(.clock(clock));
  
endmodule
`endif

// verilator lint_on BLKANDNBLK
// verilator lint_on BLKSEQ
