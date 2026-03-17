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
// Code created using PandA - Version: PandA 2024.10 - Revision c2ba6936ca2ed63137095fea0b630a1c66e20e63-main - Date 2026-03-17T17:03:39
// Bambu executed with: bambu --top-fname=top_level --generate-interface=INFER --clock-period=5 -O3 -v4 --generate-tb=testbench.c --simulate top_level.c 
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
  dram_in,
  dram_w,
  dram_out_b0,
  dram_out_b1,
  dram_out_b2,
  dram_out_b3,
  dram_out_b4,
  dram_out_b5,
  dram_out_b6,
  dram_out_b7,
  cache_reset,
  m_axi_gmem0_awready,
  m_axi_gmem0_wready,
  m_axi_gmem0_bid,
  m_axi_gmem0_bresp,
  m_axi_gmem0_buser,
  m_axi_gmem0_bvalid,
  m_axi_gmem0_arready,
  m_axi_gmem0_rid,
  m_axi_gmem0_rdata,
  m_axi_gmem0_rresp,
  m_axi_gmem0_rlast,
  m_axi_gmem0_ruser,
  m_axi_gmem0_rvalid,
  m_axi_gmem1_awready,
  m_axi_gmem1_wready,
  m_axi_gmem1_bid,
  m_axi_gmem1_bresp,
  m_axi_gmem1_buser,
  m_axi_gmem1_bvalid,
  m_axi_gmem1_arready,
  m_axi_gmem1_rid,
  m_axi_gmem1_rdata,
  m_axi_gmem1_rresp,
  m_axi_gmem1_rlast,
  m_axi_gmem1_ruser,
  m_axi_gmem1_rvalid,
  m_axi_gmem2_b0_awready,
  m_axi_gmem2_b0_wready,
  m_axi_gmem2_b0_bid,
  m_axi_gmem2_b0_bresp,
  m_axi_gmem2_b0_buser,
  m_axi_gmem2_b0_bvalid,
  m_axi_gmem2_b0_arready,
  m_axi_gmem2_b0_rid,
  m_axi_gmem2_b0_rdata,
  m_axi_gmem2_b0_rresp,
  m_axi_gmem2_b0_rlast,
  m_axi_gmem2_b0_ruser,
  m_axi_gmem2_b0_rvalid,
  m_axi_gmem2_b1_awready,
  m_axi_gmem2_b1_wready,
  m_axi_gmem2_b1_bid,
  m_axi_gmem2_b1_bresp,
  m_axi_gmem2_b1_buser,
  m_axi_gmem2_b1_bvalid,
  m_axi_gmem2_b1_arready,
  m_axi_gmem2_b1_rid,
  m_axi_gmem2_b1_rdata,
  m_axi_gmem2_b1_rresp,
  m_axi_gmem2_b1_rlast,
  m_axi_gmem2_b1_ruser,
  m_axi_gmem2_b1_rvalid,
  m_axi_gmem2_b2_awready,
  m_axi_gmem2_b2_wready,
  m_axi_gmem2_b2_bid,
  m_axi_gmem2_b2_bresp,
  m_axi_gmem2_b2_buser,
  m_axi_gmem2_b2_bvalid,
  m_axi_gmem2_b2_arready,
  m_axi_gmem2_b2_rid,
  m_axi_gmem2_b2_rdata,
  m_axi_gmem2_b2_rresp,
  m_axi_gmem2_b2_rlast,
  m_axi_gmem2_b2_ruser,
  m_axi_gmem2_b2_rvalid,
  m_axi_gmem2_b3_awready,
  m_axi_gmem2_b3_wready,
  m_axi_gmem2_b3_bid,
  m_axi_gmem2_b3_bresp,
  m_axi_gmem2_b3_buser,
  m_axi_gmem2_b3_bvalid,
  m_axi_gmem2_b3_arready,
  m_axi_gmem2_b3_rid,
  m_axi_gmem2_b3_rdata,
  m_axi_gmem2_b3_rresp,
  m_axi_gmem2_b3_rlast,
  m_axi_gmem2_b3_ruser,
  m_axi_gmem2_b3_rvalid,
  m_axi_gmem2_b4_awready,
  m_axi_gmem2_b4_wready,
  m_axi_gmem2_b4_bid,
  m_axi_gmem2_b4_bresp,
  m_axi_gmem2_b4_buser,
  m_axi_gmem2_b4_bvalid,
  m_axi_gmem2_b4_arready,
  m_axi_gmem2_b4_rid,
  m_axi_gmem2_b4_rdata,
  m_axi_gmem2_b4_rresp,
  m_axi_gmem2_b4_rlast,
  m_axi_gmem2_b4_ruser,
  m_axi_gmem2_b4_rvalid,
  m_axi_gmem2_b5_awready,
  m_axi_gmem2_b5_wready,
  m_axi_gmem2_b5_bid,
  m_axi_gmem2_b5_bresp,
  m_axi_gmem2_b5_buser,
  m_axi_gmem2_b5_bvalid,
  m_axi_gmem2_b5_arready,
  m_axi_gmem2_b5_rid,
  m_axi_gmem2_b5_rdata,
  m_axi_gmem2_b5_rresp,
  m_axi_gmem2_b5_rlast,
  m_axi_gmem2_b5_ruser,
  m_axi_gmem2_b5_rvalid,
  m_axi_gmem2_b6_awready,
  m_axi_gmem2_b6_wready,
  m_axi_gmem2_b6_bid,
  m_axi_gmem2_b6_bresp,
  m_axi_gmem2_b6_buser,
  m_axi_gmem2_b6_bvalid,
  m_axi_gmem2_b6_arready,
  m_axi_gmem2_b6_rid,
  m_axi_gmem2_b6_rdata,
  m_axi_gmem2_b6_rresp,
  m_axi_gmem2_b6_rlast,
  m_axi_gmem2_b6_ruser,
  m_axi_gmem2_b6_rvalid,
  m_axi_gmem2_b7_awready,
  m_axi_gmem2_b7_wready,
  m_axi_gmem2_b7_bid,
  m_axi_gmem2_b7_bresp,
  m_axi_gmem2_b7_buser,
  m_axi_gmem2_b7_bvalid,
  m_axi_gmem2_b7_arready,
  m_axi_gmem2_b7_rid,
  m_axi_gmem2_b7_rdata,
  m_axi_gmem2_b7_rresp,
  m_axi_gmem2_b7_rlast,
  m_axi_gmem2_b7_ruser,
  m_axi_gmem2_b7_rvalid,
  done_port,
  m_axi_gmem0_awid,
  m_axi_gmem0_awaddr,
  m_axi_gmem0_awlen,
  m_axi_gmem0_awsize,
  m_axi_gmem0_awburst,
  m_axi_gmem0_awlock,
  m_axi_gmem0_awcache,
  m_axi_gmem0_awprot,
  m_axi_gmem0_awqos,
  m_axi_gmem0_awregion,
  m_axi_gmem0_awuser,
  m_axi_gmem0_awvalid,
  m_axi_gmem0_wdata,
  m_axi_gmem0_wstrb,
  m_axi_gmem0_wlast,
  m_axi_gmem0_wuser,
  m_axi_gmem0_wvalid,
  m_axi_gmem0_bready,
  m_axi_gmem0_arid,
  m_axi_gmem0_araddr,
  m_axi_gmem0_arlen,
  m_axi_gmem0_arsize,
  m_axi_gmem0_arburst,
  m_axi_gmem0_arlock,
  m_axi_gmem0_arcache,
  m_axi_gmem0_arprot,
  m_axi_gmem0_arqos,
  m_axi_gmem0_arregion,
  m_axi_gmem0_aruser,
  m_axi_gmem0_arvalid,
  m_axi_gmem0_rready,
  m_axi_gmem1_awid,
  m_axi_gmem1_awaddr,
  m_axi_gmem1_awlen,
  m_axi_gmem1_awsize,
  m_axi_gmem1_awburst,
  m_axi_gmem1_awlock,
  m_axi_gmem1_awcache,
  m_axi_gmem1_awprot,
  m_axi_gmem1_awqos,
  m_axi_gmem1_awregion,
  m_axi_gmem1_awuser,
  m_axi_gmem1_awvalid,
  m_axi_gmem1_wdata,
  m_axi_gmem1_wstrb,
  m_axi_gmem1_wlast,
  m_axi_gmem1_wuser,
  m_axi_gmem1_wvalid,
  m_axi_gmem1_bready,
  m_axi_gmem1_arid,
  m_axi_gmem1_araddr,
  m_axi_gmem1_arlen,
  m_axi_gmem1_arsize,
  m_axi_gmem1_arburst,
  m_axi_gmem1_arlock,
  m_axi_gmem1_arcache,
  m_axi_gmem1_arprot,
  m_axi_gmem1_arqos,
  m_axi_gmem1_arregion,
  m_axi_gmem1_aruser,
  m_axi_gmem1_arvalid,
  m_axi_gmem1_rready,
  m_axi_gmem2_b0_awid,
  m_axi_gmem2_b0_awaddr,
  m_axi_gmem2_b0_awlen,
  m_axi_gmem2_b0_awsize,
  m_axi_gmem2_b0_awburst,
  m_axi_gmem2_b0_awlock,
  m_axi_gmem2_b0_awcache,
  m_axi_gmem2_b0_awprot,
  m_axi_gmem2_b0_awqos,
  m_axi_gmem2_b0_awregion,
  m_axi_gmem2_b0_awuser,
  m_axi_gmem2_b0_awvalid,
  m_axi_gmem2_b0_wdata,
  m_axi_gmem2_b0_wstrb,
  m_axi_gmem2_b0_wlast,
  m_axi_gmem2_b0_wuser,
  m_axi_gmem2_b0_wvalid,
  m_axi_gmem2_b0_bready,
  m_axi_gmem2_b0_arid,
  m_axi_gmem2_b0_araddr,
  m_axi_gmem2_b0_arlen,
  m_axi_gmem2_b0_arsize,
  m_axi_gmem2_b0_arburst,
  m_axi_gmem2_b0_arlock,
  m_axi_gmem2_b0_arcache,
  m_axi_gmem2_b0_arprot,
  m_axi_gmem2_b0_arqos,
  m_axi_gmem2_b0_arregion,
  m_axi_gmem2_b0_aruser,
  m_axi_gmem2_b0_arvalid,
  m_axi_gmem2_b0_rready,
  m_axi_gmem2_b1_awid,
  m_axi_gmem2_b1_awaddr,
  m_axi_gmem2_b1_awlen,
  m_axi_gmem2_b1_awsize,
  m_axi_gmem2_b1_awburst,
  m_axi_gmem2_b1_awlock,
  m_axi_gmem2_b1_awcache,
  m_axi_gmem2_b1_awprot,
  m_axi_gmem2_b1_awqos,
  m_axi_gmem2_b1_awregion,
  m_axi_gmem2_b1_awuser,
  m_axi_gmem2_b1_awvalid,
  m_axi_gmem2_b1_wdata,
  m_axi_gmem2_b1_wstrb,
  m_axi_gmem2_b1_wlast,
  m_axi_gmem2_b1_wuser,
  m_axi_gmem2_b1_wvalid,
  m_axi_gmem2_b1_bready,
  m_axi_gmem2_b1_arid,
  m_axi_gmem2_b1_araddr,
  m_axi_gmem2_b1_arlen,
  m_axi_gmem2_b1_arsize,
  m_axi_gmem2_b1_arburst,
  m_axi_gmem2_b1_arlock,
  m_axi_gmem2_b1_arcache,
  m_axi_gmem2_b1_arprot,
  m_axi_gmem2_b1_arqos,
  m_axi_gmem2_b1_arregion,
  m_axi_gmem2_b1_aruser,
  m_axi_gmem2_b1_arvalid,
  m_axi_gmem2_b1_rready,
  m_axi_gmem2_b2_awid,
  m_axi_gmem2_b2_awaddr,
  m_axi_gmem2_b2_awlen,
  m_axi_gmem2_b2_awsize,
  m_axi_gmem2_b2_awburst,
  m_axi_gmem2_b2_awlock,
  m_axi_gmem2_b2_awcache,
  m_axi_gmem2_b2_awprot,
  m_axi_gmem2_b2_awqos,
  m_axi_gmem2_b2_awregion,
  m_axi_gmem2_b2_awuser,
  m_axi_gmem2_b2_awvalid,
  m_axi_gmem2_b2_wdata,
  m_axi_gmem2_b2_wstrb,
  m_axi_gmem2_b2_wlast,
  m_axi_gmem2_b2_wuser,
  m_axi_gmem2_b2_wvalid,
  m_axi_gmem2_b2_bready,
  m_axi_gmem2_b2_arid,
  m_axi_gmem2_b2_araddr,
  m_axi_gmem2_b2_arlen,
  m_axi_gmem2_b2_arsize,
  m_axi_gmem2_b2_arburst,
  m_axi_gmem2_b2_arlock,
  m_axi_gmem2_b2_arcache,
  m_axi_gmem2_b2_arprot,
  m_axi_gmem2_b2_arqos,
  m_axi_gmem2_b2_arregion,
  m_axi_gmem2_b2_aruser,
  m_axi_gmem2_b2_arvalid,
  m_axi_gmem2_b2_rready,
  m_axi_gmem2_b3_awid,
  m_axi_gmem2_b3_awaddr,
  m_axi_gmem2_b3_awlen,
  m_axi_gmem2_b3_awsize,
  m_axi_gmem2_b3_awburst,
  m_axi_gmem2_b3_awlock,
  m_axi_gmem2_b3_awcache,
  m_axi_gmem2_b3_awprot,
  m_axi_gmem2_b3_awqos,
  m_axi_gmem2_b3_awregion,
  m_axi_gmem2_b3_awuser,
  m_axi_gmem2_b3_awvalid,
  m_axi_gmem2_b3_wdata,
  m_axi_gmem2_b3_wstrb,
  m_axi_gmem2_b3_wlast,
  m_axi_gmem2_b3_wuser,
  m_axi_gmem2_b3_wvalid,
  m_axi_gmem2_b3_bready,
  m_axi_gmem2_b3_arid,
  m_axi_gmem2_b3_araddr,
  m_axi_gmem2_b3_arlen,
  m_axi_gmem2_b3_arsize,
  m_axi_gmem2_b3_arburst,
  m_axi_gmem2_b3_arlock,
  m_axi_gmem2_b3_arcache,
  m_axi_gmem2_b3_arprot,
  m_axi_gmem2_b3_arqos,
  m_axi_gmem2_b3_arregion,
  m_axi_gmem2_b3_aruser,
  m_axi_gmem2_b3_arvalid,
  m_axi_gmem2_b3_rready,
  m_axi_gmem2_b4_awid,
  m_axi_gmem2_b4_awaddr,
  m_axi_gmem2_b4_awlen,
  m_axi_gmem2_b4_awsize,
  m_axi_gmem2_b4_awburst,
  m_axi_gmem2_b4_awlock,
  m_axi_gmem2_b4_awcache,
  m_axi_gmem2_b4_awprot,
  m_axi_gmem2_b4_awqos,
  m_axi_gmem2_b4_awregion,
  m_axi_gmem2_b4_awuser,
  m_axi_gmem2_b4_awvalid,
  m_axi_gmem2_b4_wdata,
  m_axi_gmem2_b4_wstrb,
  m_axi_gmem2_b4_wlast,
  m_axi_gmem2_b4_wuser,
  m_axi_gmem2_b4_wvalid,
  m_axi_gmem2_b4_bready,
  m_axi_gmem2_b4_arid,
  m_axi_gmem2_b4_araddr,
  m_axi_gmem2_b4_arlen,
  m_axi_gmem2_b4_arsize,
  m_axi_gmem2_b4_arburst,
  m_axi_gmem2_b4_arlock,
  m_axi_gmem2_b4_arcache,
  m_axi_gmem2_b4_arprot,
  m_axi_gmem2_b4_arqos,
  m_axi_gmem2_b4_arregion,
  m_axi_gmem2_b4_aruser,
  m_axi_gmem2_b4_arvalid,
  m_axi_gmem2_b4_rready,
  m_axi_gmem2_b5_awid,
  m_axi_gmem2_b5_awaddr,
  m_axi_gmem2_b5_awlen,
  m_axi_gmem2_b5_awsize,
  m_axi_gmem2_b5_awburst,
  m_axi_gmem2_b5_awlock,
  m_axi_gmem2_b5_awcache,
  m_axi_gmem2_b5_awprot,
  m_axi_gmem2_b5_awqos,
  m_axi_gmem2_b5_awregion,
  m_axi_gmem2_b5_awuser,
  m_axi_gmem2_b5_awvalid,
  m_axi_gmem2_b5_wdata,
  m_axi_gmem2_b5_wstrb,
  m_axi_gmem2_b5_wlast,
  m_axi_gmem2_b5_wuser,
  m_axi_gmem2_b5_wvalid,
  m_axi_gmem2_b5_bready,
  m_axi_gmem2_b5_arid,
  m_axi_gmem2_b5_araddr,
  m_axi_gmem2_b5_arlen,
  m_axi_gmem2_b5_arsize,
  m_axi_gmem2_b5_arburst,
  m_axi_gmem2_b5_arlock,
  m_axi_gmem2_b5_arcache,
  m_axi_gmem2_b5_arprot,
  m_axi_gmem2_b5_arqos,
  m_axi_gmem2_b5_arregion,
  m_axi_gmem2_b5_aruser,
  m_axi_gmem2_b5_arvalid,
  m_axi_gmem2_b5_rready,
  m_axi_gmem2_b6_awid,
  m_axi_gmem2_b6_awaddr,
  m_axi_gmem2_b6_awlen,
  m_axi_gmem2_b6_awsize,
  m_axi_gmem2_b6_awburst,
  m_axi_gmem2_b6_awlock,
  m_axi_gmem2_b6_awcache,
  m_axi_gmem2_b6_awprot,
  m_axi_gmem2_b6_awqos,
  m_axi_gmem2_b6_awregion,
  m_axi_gmem2_b6_awuser,
  m_axi_gmem2_b6_awvalid,
  m_axi_gmem2_b6_wdata,
  m_axi_gmem2_b6_wstrb,
  m_axi_gmem2_b6_wlast,
  m_axi_gmem2_b6_wuser,
  m_axi_gmem2_b6_wvalid,
  m_axi_gmem2_b6_bready,
  m_axi_gmem2_b6_arid,
  m_axi_gmem2_b6_araddr,
  m_axi_gmem2_b6_arlen,
  m_axi_gmem2_b6_arsize,
  m_axi_gmem2_b6_arburst,
  m_axi_gmem2_b6_arlock,
  m_axi_gmem2_b6_arcache,
  m_axi_gmem2_b6_arprot,
  m_axi_gmem2_b6_arqos,
  m_axi_gmem2_b6_arregion,
  m_axi_gmem2_b6_aruser,
  m_axi_gmem2_b6_arvalid,
  m_axi_gmem2_b6_rready,
  m_axi_gmem2_b7_awid,
  m_axi_gmem2_b7_awaddr,
  m_axi_gmem2_b7_awlen,
  m_axi_gmem2_b7_awsize,
  m_axi_gmem2_b7_awburst,
  m_axi_gmem2_b7_awlock,
  m_axi_gmem2_b7_awcache,
  m_axi_gmem2_b7_awprot,
  m_axi_gmem2_b7_awqos,
  m_axi_gmem2_b7_awregion,
  m_axi_gmem2_b7_awuser,
  m_axi_gmem2_b7_awvalid,
  m_axi_gmem2_b7_wdata,
  m_axi_gmem2_b7_wstrb,
  m_axi_gmem2_b7_wlast,
  m_axi_gmem2_b7_wuser,
  m_axi_gmem2_b7_wvalid,
  m_axi_gmem2_b7_bready,
  m_axi_gmem2_b7_arid,
  m_axi_gmem2_b7_araddr,
  m_axi_gmem2_b7_arlen,
  m_axi_gmem2_b7_arsize,
  m_axi_gmem2_b7_arburst,
  m_axi_gmem2_b7_arlock,
  m_axi_gmem2_b7_arcache,
  m_axi_gmem2_b7_arprot,
  m_axi_gmem2_b7_arqos,
  m_axi_gmem2_b7_arregion,
  m_axi_gmem2_b7_aruser,
  m_axi_gmem2_b7_arvalid,
  m_axi_gmem2_b7_rready);
  // IN
  input clock;
  input reset;
  input start_port;
  input [31:0] dram_in;
  input [31:0] dram_w;
  input [31:0] dram_out_b0;
  input [31:0] dram_out_b1;
  input [31:0] dram_out_b2;
  input [31:0] dram_out_b3;
  input [31:0] dram_out_b4;
  input [31:0] dram_out_b5;
  input [31:0] dram_out_b6;
  input [31:0] dram_out_b7;
  input cache_reset;
  input m_axi_gmem0_awready;
  input m_axi_gmem0_wready;
  input [5:0] m_axi_gmem0_bid;
  input [1:0] m_axi_gmem0_bresp;
  input m_axi_gmem0_buser;
  input m_axi_gmem0_bvalid;
  input m_axi_gmem0_arready;
  input [5:0] m_axi_gmem0_rid;
  input [31:0] m_axi_gmem0_rdata;
  input [1:0] m_axi_gmem0_rresp;
  input m_axi_gmem0_rlast;
  input m_axi_gmem0_ruser;
  input m_axi_gmem0_rvalid;
  input m_axi_gmem1_awready;
  input m_axi_gmem1_wready;
  input [5:0] m_axi_gmem1_bid;
  input [1:0] m_axi_gmem1_bresp;
  input m_axi_gmem1_buser;
  input m_axi_gmem1_bvalid;
  input m_axi_gmem1_arready;
  input [5:0] m_axi_gmem1_rid;
  input [31:0] m_axi_gmem1_rdata;
  input [1:0] m_axi_gmem1_rresp;
  input m_axi_gmem1_rlast;
  input m_axi_gmem1_ruser;
  input m_axi_gmem1_rvalid;
  input m_axi_gmem2_b0_awready;
  input m_axi_gmem2_b0_wready;
  input [5:0] m_axi_gmem2_b0_bid;
  input [1:0] m_axi_gmem2_b0_bresp;
  input m_axi_gmem2_b0_buser;
  input m_axi_gmem2_b0_bvalid;
  input m_axi_gmem2_b0_arready;
  input [5:0] m_axi_gmem2_b0_rid;
  input [31:0] m_axi_gmem2_b0_rdata;
  input [1:0] m_axi_gmem2_b0_rresp;
  input m_axi_gmem2_b0_rlast;
  input m_axi_gmem2_b0_ruser;
  input m_axi_gmem2_b0_rvalid;
  input m_axi_gmem2_b1_awready;
  input m_axi_gmem2_b1_wready;
  input [5:0] m_axi_gmem2_b1_bid;
  input [1:0] m_axi_gmem2_b1_bresp;
  input m_axi_gmem2_b1_buser;
  input m_axi_gmem2_b1_bvalid;
  input m_axi_gmem2_b1_arready;
  input [5:0] m_axi_gmem2_b1_rid;
  input [31:0] m_axi_gmem2_b1_rdata;
  input [1:0] m_axi_gmem2_b1_rresp;
  input m_axi_gmem2_b1_rlast;
  input m_axi_gmem2_b1_ruser;
  input m_axi_gmem2_b1_rvalid;
  input m_axi_gmem2_b2_awready;
  input m_axi_gmem2_b2_wready;
  input [5:0] m_axi_gmem2_b2_bid;
  input [1:0] m_axi_gmem2_b2_bresp;
  input m_axi_gmem2_b2_buser;
  input m_axi_gmem2_b2_bvalid;
  input m_axi_gmem2_b2_arready;
  input [5:0] m_axi_gmem2_b2_rid;
  input [31:0] m_axi_gmem2_b2_rdata;
  input [1:0] m_axi_gmem2_b2_rresp;
  input m_axi_gmem2_b2_rlast;
  input m_axi_gmem2_b2_ruser;
  input m_axi_gmem2_b2_rvalid;
  input m_axi_gmem2_b3_awready;
  input m_axi_gmem2_b3_wready;
  input [5:0] m_axi_gmem2_b3_bid;
  input [1:0] m_axi_gmem2_b3_bresp;
  input m_axi_gmem2_b3_buser;
  input m_axi_gmem2_b3_bvalid;
  input m_axi_gmem2_b3_arready;
  input [5:0] m_axi_gmem2_b3_rid;
  input [31:0] m_axi_gmem2_b3_rdata;
  input [1:0] m_axi_gmem2_b3_rresp;
  input m_axi_gmem2_b3_rlast;
  input m_axi_gmem2_b3_ruser;
  input m_axi_gmem2_b3_rvalid;
  input m_axi_gmem2_b4_awready;
  input m_axi_gmem2_b4_wready;
  input [5:0] m_axi_gmem2_b4_bid;
  input [1:0] m_axi_gmem2_b4_bresp;
  input m_axi_gmem2_b4_buser;
  input m_axi_gmem2_b4_bvalid;
  input m_axi_gmem2_b4_arready;
  input [5:0] m_axi_gmem2_b4_rid;
  input [31:0] m_axi_gmem2_b4_rdata;
  input [1:0] m_axi_gmem2_b4_rresp;
  input m_axi_gmem2_b4_rlast;
  input m_axi_gmem2_b4_ruser;
  input m_axi_gmem2_b4_rvalid;
  input m_axi_gmem2_b5_awready;
  input m_axi_gmem2_b5_wready;
  input [5:0] m_axi_gmem2_b5_bid;
  input [1:0] m_axi_gmem2_b5_bresp;
  input m_axi_gmem2_b5_buser;
  input m_axi_gmem2_b5_bvalid;
  input m_axi_gmem2_b5_arready;
  input [5:0] m_axi_gmem2_b5_rid;
  input [31:0] m_axi_gmem2_b5_rdata;
  input [1:0] m_axi_gmem2_b5_rresp;
  input m_axi_gmem2_b5_rlast;
  input m_axi_gmem2_b5_ruser;
  input m_axi_gmem2_b5_rvalid;
  input m_axi_gmem2_b6_awready;
  input m_axi_gmem2_b6_wready;
  input [5:0] m_axi_gmem2_b6_bid;
  input [1:0] m_axi_gmem2_b6_bresp;
  input m_axi_gmem2_b6_buser;
  input m_axi_gmem2_b6_bvalid;
  input m_axi_gmem2_b6_arready;
  input [5:0] m_axi_gmem2_b6_rid;
  input [31:0] m_axi_gmem2_b6_rdata;
  input [1:0] m_axi_gmem2_b6_rresp;
  input m_axi_gmem2_b6_rlast;
  input m_axi_gmem2_b6_ruser;
  input m_axi_gmem2_b6_rvalid;
  input m_axi_gmem2_b7_awready;
  input m_axi_gmem2_b7_wready;
  input [5:0] m_axi_gmem2_b7_bid;
  input [1:0] m_axi_gmem2_b7_bresp;
  input m_axi_gmem2_b7_buser;
  input m_axi_gmem2_b7_bvalid;
  input m_axi_gmem2_b7_arready;
  input [5:0] m_axi_gmem2_b7_rid;
  input [31:0] m_axi_gmem2_b7_rdata;
  input [1:0] m_axi_gmem2_b7_rresp;
  input m_axi_gmem2_b7_rlast;
  input m_axi_gmem2_b7_ruser;
  input m_axi_gmem2_b7_rvalid;
  // OUT
  output done_port;
  output [5:0] m_axi_gmem0_awid;
  output [31:0] m_axi_gmem0_awaddr;
  output [7:0] m_axi_gmem0_awlen;
  output [2:0] m_axi_gmem0_awsize;
  output [1:0] m_axi_gmem0_awburst;
  output m_axi_gmem0_awlock;
  output [3:0] m_axi_gmem0_awcache;
  output [2:0] m_axi_gmem0_awprot;
  output [3:0] m_axi_gmem0_awqos;
  output [3:0] m_axi_gmem0_awregion;
  output m_axi_gmem0_awuser;
  output m_axi_gmem0_awvalid;
  output [31:0] m_axi_gmem0_wdata;
  output [3:0] m_axi_gmem0_wstrb;
  output m_axi_gmem0_wlast;
  output m_axi_gmem0_wuser;
  output m_axi_gmem0_wvalid;
  output m_axi_gmem0_bready;
  output [5:0] m_axi_gmem0_arid;
  output [31:0] m_axi_gmem0_araddr;
  output [7:0] m_axi_gmem0_arlen;
  output [2:0] m_axi_gmem0_arsize;
  output [1:0] m_axi_gmem0_arburst;
  output m_axi_gmem0_arlock;
  output [3:0] m_axi_gmem0_arcache;
  output [2:0] m_axi_gmem0_arprot;
  output [3:0] m_axi_gmem0_arqos;
  output [3:0] m_axi_gmem0_arregion;
  output m_axi_gmem0_aruser;
  output m_axi_gmem0_arvalid;
  output m_axi_gmem0_rready;
  output [5:0] m_axi_gmem1_awid;
  output [31:0] m_axi_gmem1_awaddr;
  output [7:0] m_axi_gmem1_awlen;
  output [2:0] m_axi_gmem1_awsize;
  output [1:0] m_axi_gmem1_awburst;
  output m_axi_gmem1_awlock;
  output [3:0] m_axi_gmem1_awcache;
  output [2:0] m_axi_gmem1_awprot;
  output [3:0] m_axi_gmem1_awqos;
  output [3:0] m_axi_gmem1_awregion;
  output m_axi_gmem1_awuser;
  output m_axi_gmem1_awvalid;
  output [31:0] m_axi_gmem1_wdata;
  output [3:0] m_axi_gmem1_wstrb;
  output m_axi_gmem1_wlast;
  output m_axi_gmem1_wuser;
  output m_axi_gmem1_wvalid;
  output m_axi_gmem1_bready;
  output [5:0] m_axi_gmem1_arid;
  output [31:0] m_axi_gmem1_araddr;
  output [7:0] m_axi_gmem1_arlen;
  output [2:0] m_axi_gmem1_arsize;
  output [1:0] m_axi_gmem1_arburst;
  output m_axi_gmem1_arlock;
  output [3:0] m_axi_gmem1_arcache;
  output [2:0] m_axi_gmem1_arprot;
  output [3:0] m_axi_gmem1_arqos;
  output [3:0] m_axi_gmem1_arregion;
  output m_axi_gmem1_aruser;
  output m_axi_gmem1_arvalid;
  output m_axi_gmem1_rready;
  output [5:0] m_axi_gmem2_b0_awid;
  output [31:0] m_axi_gmem2_b0_awaddr;
  output [7:0] m_axi_gmem2_b0_awlen;
  output [2:0] m_axi_gmem2_b0_awsize;
  output [1:0] m_axi_gmem2_b0_awburst;
  output m_axi_gmem2_b0_awlock;
  output [3:0] m_axi_gmem2_b0_awcache;
  output [2:0] m_axi_gmem2_b0_awprot;
  output [3:0] m_axi_gmem2_b0_awqos;
  output [3:0] m_axi_gmem2_b0_awregion;
  output m_axi_gmem2_b0_awuser;
  output m_axi_gmem2_b0_awvalid;
  output [31:0] m_axi_gmem2_b0_wdata;
  output [3:0] m_axi_gmem2_b0_wstrb;
  output m_axi_gmem2_b0_wlast;
  output m_axi_gmem2_b0_wuser;
  output m_axi_gmem2_b0_wvalid;
  output m_axi_gmem2_b0_bready;
  output [5:0] m_axi_gmem2_b0_arid;
  output [31:0] m_axi_gmem2_b0_araddr;
  output [7:0] m_axi_gmem2_b0_arlen;
  output [2:0] m_axi_gmem2_b0_arsize;
  output [1:0] m_axi_gmem2_b0_arburst;
  output m_axi_gmem2_b0_arlock;
  output [3:0] m_axi_gmem2_b0_arcache;
  output [2:0] m_axi_gmem2_b0_arprot;
  output [3:0] m_axi_gmem2_b0_arqos;
  output [3:0] m_axi_gmem2_b0_arregion;
  output m_axi_gmem2_b0_aruser;
  output m_axi_gmem2_b0_arvalid;
  output m_axi_gmem2_b0_rready;
  output [5:0] m_axi_gmem2_b1_awid;
  output [31:0] m_axi_gmem2_b1_awaddr;
  output [7:0] m_axi_gmem2_b1_awlen;
  output [2:0] m_axi_gmem2_b1_awsize;
  output [1:0] m_axi_gmem2_b1_awburst;
  output m_axi_gmem2_b1_awlock;
  output [3:0] m_axi_gmem2_b1_awcache;
  output [2:0] m_axi_gmem2_b1_awprot;
  output [3:0] m_axi_gmem2_b1_awqos;
  output [3:0] m_axi_gmem2_b1_awregion;
  output m_axi_gmem2_b1_awuser;
  output m_axi_gmem2_b1_awvalid;
  output [31:0] m_axi_gmem2_b1_wdata;
  output [3:0] m_axi_gmem2_b1_wstrb;
  output m_axi_gmem2_b1_wlast;
  output m_axi_gmem2_b1_wuser;
  output m_axi_gmem2_b1_wvalid;
  output m_axi_gmem2_b1_bready;
  output [5:0] m_axi_gmem2_b1_arid;
  output [31:0] m_axi_gmem2_b1_araddr;
  output [7:0] m_axi_gmem2_b1_arlen;
  output [2:0] m_axi_gmem2_b1_arsize;
  output [1:0] m_axi_gmem2_b1_arburst;
  output m_axi_gmem2_b1_arlock;
  output [3:0] m_axi_gmem2_b1_arcache;
  output [2:0] m_axi_gmem2_b1_arprot;
  output [3:0] m_axi_gmem2_b1_arqos;
  output [3:0] m_axi_gmem2_b1_arregion;
  output m_axi_gmem2_b1_aruser;
  output m_axi_gmem2_b1_arvalid;
  output m_axi_gmem2_b1_rready;
  output [5:0] m_axi_gmem2_b2_awid;
  output [31:0] m_axi_gmem2_b2_awaddr;
  output [7:0] m_axi_gmem2_b2_awlen;
  output [2:0] m_axi_gmem2_b2_awsize;
  output [1:0] m_axi_gmem2_b2_awburst;
  output m_axi_gmem2_b2_awlock;
  output [3:0] m_axi_gmem2_b2_awcache;
  output [2:0] m_axi_gmem2_b2_awprot;
  output [3:0] m_axi_gmem2_b2_awqos;
  output [3:0] m_axi_gmem2_b2_awregion;
  output m_axi_gmem2_b2_awuser;
  output m_axi_gmem2_b2_awvalid;
  output [31:0] m_axi_gmem2_b2_wdata;
  output [3:0] m_axi_gmem2_b2_wstrb;
  output m_axi_gmem2_b2_wlast;
  output m_axi_gmem2_b2_wuser;
  output m_axi_gmem2_b2_wvalid;
  output m_axi_gmem2_b2_bready;
  output [5:0] m_axi_gmem2_b2_arid;
  output [31:0] m_axi_gmem2_b2_araddr;
  output [7:0] m_axi_gmem2_b2_arlen;
  output [2:0] m_axi_gmem2_b2_arsize;
  output [1:0] m_axi_gmem2_b2_arburst;
  output m_axi_gmem2_b2_arlock;
  output [3:0] m_axi_gmem2_b2_arcache;
  output [2:0] m_axi_gmem2_b2_arprot;
  output [3:0] m_axi_gmem2_b2_arqos;
  output [3:0] m_axi_gmem2_b2_arregion;
  output m_axi_gmem2_b2_aruser;
  output m_axi_gmem2_b2_arvalid;
  output m_axi_gmem2_b2_rready;
  output [5:0] m_axi_gmem2_b3_awid;
  output [31:0] m_axi_gmem2_b3_awaddr;
  output [7:0] m_axi_gmem2_b3_awlen;
  output [2:0] m_axi_gmem2_b3_awsize;
  output [1:0] m_axi_gmem2_b3_awburst;
  output m_axi_gmem2_b3_awlock;
  output [3:0] m_axi_gmem2_b3_awcache;
  output [2:0] m_axi_gmem2_b3_awprot;
  output [3:0] m_axi_gmem2_b3_awqos;
  output [3:0] m_axi_gmem2_b3_awregion;
  output m_axi_gmem2_b3_awuser;
  output m_axi_gmem2_b3_awvalid;
  output [31:0] m_axi_gmem2_b3_wdata;
  output [3:0] m_axi_gmem2_b3_wstrb;
  output m_axi_gmem2_b3_wlast;
  output m_axi_gmem2_b3_wuser;
  output m_axi_gmem2_b3_wvalid;
  output m_axi_gmem2_b3_bready;
  output [5:0] m_axi_gmem2_b3_arid;
  output [31:0] m_axi_gmem2_b3_araddr;
  output [7:0] m_axi_gmem2_b3_arlen;
  output [2:0] m_axi_gmem2_b3_arsize;
  output [1:0] m_axi_gmem2_b3_arburst;
  output m_axi_gmem2_b3_arlock;
  output [3:0] m_axi_gmem2_b3_arcache;
  output [2:0] m_axi_gmem2_b3_arprot;
  output [3:0] m_axi_gmem2_b3_arqos;
  output [3:0] m_axi_gmem2_b3_arregion;
  output m_axi_gmem2_b3_aruser;
  output m_axi_gmem2_b3_arvalid;
  output m_axi_gmem2_b3_rready;
  output [5:0] m_axi_gmem2_b4_awid;
  output [31:0] m_axi_gmem2_b4_awaddr;
  output [7:0] m_axi_gmem2_b4_awlen;
  output [2:0] m_axi_gmem2_b4_awsize;
  output [1:0] m_axi_gmem2_b4_awburst;
  output m_axi_gmem2_b4_awlock;
  output [3:0] m_axi_gmem2_b4_awcache;
  output [2:0] m_axi_gmem2_b4_awprot;
  output [3:0] m_axi_gmem2_b4_awqos;
  output [3:0] m_axi_gmem2_b4_awregion;
  output m_axi_gmem2_b4_awuser;
  output m_axi_gmem2_b4_awvalid;
  output [31:0] m_axi_gmem2_b4_wdata;
  output [3:0] m_axi_gmem2_b4_wstrb;
  output m_axi_gmem2_b4_wlast;
  output m_axi_gmem2_b4_wuser;
  output m_axi_gmem2_b4_wvalid;
  output m_axi_gmem2_b4_bready;
  output [5:0] m_axi_gmem2_b4_arid;
  output [31:0] m_axi_gmem2_b4_araddr;
  output [7:0] m_axi_gmem2_b4_arlen;
  output [2:0] m_axi_gmem2_b4_arsize;
  output [1:0] m_axi_gmem2_b4_arburst;
  output m_axi_gmem2_b4_arlock;
  output [3:0] m_axi_gmem2_b4_arcache;
  output [2:0] m_axi_gmem2_b4_arprot;
  output [3:0] m_axi_gmem2_b4_arqos;
  output [3:0] m_axi_gmem2_b4_arregion;
  output m_axi_gmem2_b4_aruser;
  output m_axi_gmem2_b4_arvalid;
  output m_axi_gmem2_b4_rready;
  output [5:0] m_axi_gmem2_b5_awid;
  output [31:0] m_axi_gmem2_b5_awaddr;
  output [7:0] m_axi_gmem2_b5_awlen;
  output [2:0] m_axi_gmem2_b5_awsize;
  output [1:0] m_axi_gmem2_b5_awburst;
  output m_axi_gmem2_b5_awlock;
  output [3:0] m_axi_gmem2_b5_awcache;
  output [2:0] m_axi_gmem2_b5_awprot;
  output [3:0] m_axi_gmem2_b5_awqos;
  output [3:0] m_axi_gmem2_b5_awregion;
  output m_axi_gmem2_b5_awuser;
  output m_axi_gmem2_b5_awvalid;
  output [31:0] m_axi_gmem2_b5_wdata;
  output [3:0] m_axi_gmem2_b5_wstrb;
  output m_axi_gmem2_b5_wlast;
  output m_axi_gmem2_b5_wuser;
  output m_axi_gmem2_b5_wvalid;
  output m_axi_gmem2_b5_bready;
  output [5:0] m_axi_gmem2_b5_arid;
  output [31:0] m_axi_gmem2_b5_araddr;
  output [7:0] m_axi_gmem2_b5_arlen;
  output [2:0] m_axi_gmem2_b5_arsize;
  output [1:0] m_axi_gmem2_b5_arburst;
  output m_axi_gmem2_b5_arlock;
  output [3:0] m_axi_gmem2_b5_arcache;
  output [2:0] m_axi_gmem2_b5_arprot;
  output [3:0] m_axi_gmem2_b5_arqos;
  output [3:0] m_axi_gmem2_b5_arregion;
  output m_axi_gmem2_b5_aruser;
  output m_axi_gmem2_b5_arvalid;
  output m_axi_gmem2_b5_rready;
  output [5:0] m_axi_gmem2_b6_awid;
  output [31:0] m_axi_gmem2_b6_awaddr;
  output [7:0] m_axi_gmem2_b6_awlen;
  output [2:0] m_axi_gmem2_b6_awsize;
  output [1:0] m_axi_gmem2_b6_awburst;
  output m_axi_gmem2_b6_awlock;
  output [3:0] m_axi_gmem2_b6_awcache;
  output [2:0] m_axi_gmem2_b6_awprot;
  output [3:0] m_axi_gmem2_b6_awqos;
  output [3:0] m_axi_gmem2_b6_awregion;
  output m_axi_gmem2_b6_awuser;
  output m_axi_gmem2_b6_awvalid;
  output [31:0] m_axi_gmem2_b6_wdata;
  output [3:0] m_axi_gmem2_b6_wstrb;
  output m_axi_gmem2_b6_wlast;
  output m_axi_gmem2_b6_wuser;
  output m_axi_gmem2_b6_wvalid;
  output m_axi_gmem2_b6_bready;
  output [5:0] m_axi_gmem2_b6_arid;
  output [31:0] m_axi_gmem2_b6_araddr;
  output [7:0] m_axi_gmem2_b6_arlen;
  output [2:0] m_axi_gmem2_b6_arsize;
  output [1:0] m_axi_gmem2_b6_arburst;
  output m_axi_gmem2_b6_arlock;
  output [3:0] m_axi_gmem2_b6_arcache;
  output [2:0] m_axi_gmem2_b6_arprot;
  output [3:0] m_axi_gmem2_b6_arqos;
  output [3:0] m_axi_gmem2_b6_arregion;
  output m_axi_gmem2_b6_aruser;
  output m_axi_gmem2_b6_arvalid;
  output m_axi_gmem2_b6_rready;
  output [5:0] m_axi_gmem2_b7_awid;
  output [31:0] m_axi_gmem2_b7_awaddr;
  output [7:0] m_axi_gmem2_b7_awlen;
  output [2:0] m_axi_gmem2_b7_awsize;
  output [1:0] m_axi_gmem2_b7_awburst;
  output m_axi_gmem2_b7_awlock;
  output [3:0] m_axi_gmem2_b7_awcache;
  output [2:0] m_axi_gmem2_b7_awprot;
  output [3:0] m_axi_gmem2_b7_awqos;
  output [3:0] m_axi_gmem2_b7_awregion;
  output m_axi_gmem2_b7_awuser;
  output m_axi_gmem2_b7_awvalid;
  output [31:0] m_axi_gmem2_b7_wdata;
  output [3:0] m_axi_gmem2_b7_wstrb;
  output m_axi_gmem2_b7_wlast;
  output m_axi_gmem2_b7_wuser;
  output m_axi_gmem2_b7_wvalid;
  output m_axi_gmem2_b7_bready;
  output [5:0] m_axi_gmem2_b7_arid;
  output [31:0] m_axi_gmem2_b7_araddr;
  output [7:0] m_axi_gmem2_b7_arlen;
  output [2:0] m_axi_gmem2_b7_arsize;
  output [1:0] m_axi_gmem2_b7_arburst;
  output m_axi_gmem2_b7_arlock;
  output [3:0] m_axi_gmem2_b7_arcache;
  output [2:0] m_axi_gmem2_b7_arprot;
  output [3:0] m_axi_gmem2_b7_arqos;
  output [3:0] m_axi_gmem2_b7_arregion;
  output m_axi_gmem2_b7_aruser;
  output m_axi_gmem2_b7_arvalid;
  output m_axi_gmem2_b7_rready;
  
  
  top_level top(
    .clock(clock),
    .reset(reset),
    .start_port(start_port),
    .dram_in(dram_in),
    .dram_w(dram_w),
    .dram_out_b0(dram_out_b0),
    .dram_out_b1(dram_out_b1),
    .dram_out_b2(dram_out_b2),
    .dram_out_b3(dram_out_b3),
    .dram_out_b4(dram_out_b4),
    .dram_out_b5(dram_out_b5),
    .dram_out_b6(dram_out_b6),
    .dram_out_b7(dram_out_b7),
    .cache_reset(cache_reset),
    .m_axi_gmem0_awready(m_axi_gmem0_awready),
    .m_axi_gmem0_wready(m_axi_gmem0_wready),
    .m_axi_gmem0_bid(m_axi_gmem0_bid),
    .m_axi_gmem0_bresp(m_axi_gmem0_bresp),
    .m_axi_gmem0_buser(m_axi_gmem0_buser),
    .m_axi_gmem0_bvalid(m_axi_gmem0_bvalid),
    .m_axi_gmem0_arready(m_axi_gmem0_arready),
    .m_axi_gmem0_rid(m_axi_gmem0_rid),
    .m_axi_gmem0_rdata(m_axi_gmem0_rdata),
    .m_axi_gmem0_rresp(m_axi_gmem0_rresp),
    .m_axi_gmem0_rlast(m_axi_gmem0_rlast),
    .m_axi_gmem0_ruser(m_axi_gmem0_ruser),
    .m_axi_gmem0_rvalid(m_axi_gmem0_rvalid),
    .m_axi_gmem1_awready(m_axi_gmem1_awready),
    .m_axi_gmem1_wready(m_axi_gmem1_wready),
    .m_axi_gmem1_bid(m_axi_gmem1_bid),
    .m_axi_gmem1_bresp(m_axi_gmem1_bresp),
    .m_axi_gmem1_buser(m_axi_gmem1_buser),
    .m_axi_gmem1_bvalid(m_axi_gmem1_bvalid),
    .m_axi_gmem1_arready(m_axi_gmem1_arready),
    .m_axi_gmem1_rid(m_axi_gmem1_rid),
    .m_axi_gmem1_rdata(m_axi_gmem1_rdata),
    .m_axi_gmem1_rresp(m_axi_gmem1_rresp),
    .m_axi_gmem1_rlast(m_axi_gmem1_rlast),
    .m_axi_gmem1_ruser(m_axi_gmem1_ruser),
    .m_axi_gmem1_rvalid(m_axi_gmem1_rvalid),
    .m_axi_gmem2_b0_awready(m_axi_gmem2_b0_awready),
    .m_axi_gmem2_b0_wready(m_axi_gmem2_b0_wready),
    .m_axi_gmem2_b0_bid(m_axi_gmem2_b0_bid),
    .m_axi_gmem2_b0_bresp(m_axi_gmem2_b0_bresp),
    .m_axi_gmem2_b0_buser(m_axi_gmem2_b0_buser),
    .m_axi_gmem2_b0_bvalid(m_axi_gmem2_b0_bvalid),
    .m_axi_gmem2_b0_arready(m_axi_gmem2_b0_arready),
    .m_axi_gmem2_b0_rid(m_axi_gmem2_b0_rid),
    .m_axi_gmem2_b0_rdata(m_axi_gmem2_b0_rdata),
    .m_axi_gmem2_b0_rresp(m_axi_gmem2_b0_rresp),
    .m_axi_gmem2_b0_rlast(m_axi_gmem2_b0_rlast),
    .m_axi_gmem2_b0_ruser(m_axi_gmem2_b0_ruser),
    .m_axi_gmem2_b0_rvalid(m_axi_gmem2_b0_rvalid),
    .m_axi_gmem2_b1_awready(m_axi_gmem2_b1_awready),
    .m_axi_gmem2_b1_wready(m_axi_gmem2_b1_wready),
    .m_axi_gmem2_b1_bid(m_axi_gmem2_b1_bid),
    .m_axi_gmem2_b1_bresp(m_axi_gmem2_b1_bresp),
    .m_axi_gmem2_b1_buser(m_axi_gmem2_b1_buser),
    .m_axi_gmem2_b1_bvalid(m_axi_gmem2_b1_bvalid),
    .m_axi_gmem2_b1_arready(m_axi_gmem2_b1_arready),
    .m_axi_gmem2_b1_rid(m_axi_gmem2_b1_rid),
    .m_axi_gmem2_b1_rdata(m_axi_gmem2_b1_rdata),
    .m_axi_gmem2_b1_rresp(m_axi_gmem2_b1_rresp),
    .m_axi_gmem2_b1_rlast(m_axi_gmem2_b1_rlast),
    .m_axi_gmem2_b1_ruser(m_axi_gmem2_b1_ruser),
    .m_axi_gmem2_b1_rvalid(m_axi_gmem2_b1_rvalid),
    .m_axi_gmem2_b2_awready(m_axi_gmem2_b2_awready),
    .m_axi_gmem2_b2_wready(m_axi_gmem2_b2_wready),
    .m_axi_gmem2_b2_bid(m_axi_gmem2_b2_bid),
    .m_axi_gmem2_b2_bresp(m_axi_gmem2_b2_bresp),
    .m_axi_gmem2_b2_buser(m_axi_gmem2_b2_buser),
    .m_axi_gmem2_b2_bvalid(m_axi_gmem2_b2_bvalid),
    .m_axi_gmem2_b2_arready(m_axi_gmem2_b2_arready),
    .m_axi_gmem2_b2_rid(m_axi_gmem2_b2_rid),
    .m_axi_gmem2_b2_rdata(m_axi_gmem2_b2_rdata),
    .m_axi_gmem2_b2_rresp(m_axi_gmem2_b2_rresp),
    .m_axi_gmem2_b2_rlast(m_axi_gmem2_b2_rlast),
    .m_axi_gmem2_b2_ruser(m_axi_gmem2_b2_ruser),
    .m_axi_gmem2_b2_rvalid(m_axi_gmem2_b2_rvalid),
    .m_axi_gmem2_b3_awready(m_axi_gmem2_b3_awready),
    .m_axi_gmem2_b3_wready(m_axi_gmem2_b3_wready),
    .m_axi_gmem2_b3_bid(m_axi_gmem2_b3_bid),
    .m_axi_gmem2_b3_bresp(m_axi_gmem2_b3_bresp),
    .m_axi_gmem2_b3_buser(m_axi_gmem2_b3_buser),
    .m_axi_gmem2_b3_bvalid(m_axi_gmem2_b3_bvalid),
    .m_axi_gmem2_b3_arready(m_axi_gmem2_b3_arready),
    .m_axi_gmem2_b3_rid(m_axi_gmem2_b3_rid),
    .m_axi_gmem2_b3_rdata(m_axi_gmem2_b3_rdata),
    .m_axi_gmem2_b3_rresp(m_axi_gmem2_b3_rresp),
    .m_axi_gmem2_b3_rlast(m_axi_gmem2_b3_rlast),
    .m_axi_gmem2_b3_ruser(m_axi_gmem2_b3_ruser),
    .m_axi_gmem2_b3_rvalid(m_axi_gmem2_b3_rvalid),
    .m_axi_gmem2_b4_awready(m_axi_gmem2_b4_awready),
    .m_axi_gmem2_b4_wready(m_axi_gmem2_b4_wready),
    .m_axi_gmem2_b4_bid(m_axi_gmem2_b4_bid),
    .m_axi_gmem2_b4_bresp(m_axi_gmem2_b4_bresp),
    .m_axi_gmem2_b4_buser(m_axi_gmem2_b4_buser),
    .m_axi_gmem2_b4_bvalid(m_axi_gmem2_b4_bvalid),
    .m_axi_gmem2_b4_arready(m_axi_gmem2_b4_arready),
    .m_axi_gmem2_b4_rid(m_axi_gmem2_b4_rid),
    .m_axi_gmem2_b4_rdata(m_axi_gmem2_b4_rdata),
    .m_axi_gmem2_b4_rresp(m_axi_gmem2_b4_rresp),
    .m_axi_gmem2_b4_rlast(m_axi_gmem2_b4_rlast),
    .m_axi_gmem2_b4_ruser(m_axi_gmem2_b4_ruser),
    .m_axi_gmem2_b4_rvalid(m_axi_gmem2_b4_rvalid),
    .m_axi_gmem2_b5_awready(m_axi_gmem2_b5_awready),
    .m_axi_gmem2_b5_wready(m_axi_gmem2_b5_wready),
    .m_axi_gmem2_b5_bid(m_axi_gmem2_b5_bid),
    .m_axi_gmem2_b5_bresp(m_axi_gmem2_b5_bresp),
    .m_axi_gmem2_b5_buser(m_axi_gmem2_b5_buser),
    .m_axi_gmem2_b5_bvalid(m_axi_gmem2_b5_bvalid),
    .m_axi_gmem2_b5_arready(m_axi_gmem2_b5_arready),
    .m_axi_gmem2_b5_rid(m_axi_gmem2_b5_rid),
    .m_axi_gmem2_b5_rdata(m_axi_gmem2_b5_rdata),
    .m_axi_gmem2_b5_rresp(m_axi_gmem2_b5_rresp),
    .m_axi_gmem2_b5_rlast(m_axi_gmem2_b5_rlast),
    .m_axi_gmem2_b5_ruser(m_axi_gmem2_b5_ruser),
    .m_axi_gmem2_b5_rvalid(m_axi_gmem2_b5_rvalid),
    .m_axi_gmem2_b6_awready(m_axi_gmem2_b6_awready),
    .m_axi_gmem2_b6_wready(m_axi_gmem2_b6_wready),
    .m_axi_gmem2_b6_bid(m_axi_gmem2_b6_bid),
    .m_axi_gmem2_b6_bresp(m_axi_gmem2_b6_bresp),
    .m_axi_gmem2_b6_buser(m_axi_gmem2_b6_buser),
    .m_axi_gmem2_b6_bvalid(m_axi_gmem2_b6_bvalid),
    .m_axi_gmem2_b6_arready(m_axi_gmem2_b6_arready),
    .m_axi_gmem2_b6_rid(m_axi_gmem2_b6_rid),
    .m_axi_gmem2_b6_rdata(m_axi_gmem2_b6_rdata),
    .m_axi_gmem2_b6_rresp(m_axi_gmem2_b6_rresp),
    .m_axi_gmem2_b6_rlast(m_axi_gmem2_b6_rlast),
    .m_axi_gmem2_b6_ruser(m_axi_gmem2_b6_ruser),
    .m_axi_gmem2_b6_rvalid(m_axi_gmem2_b6_rvalid),
    .m_axi_gmem2_b7_awready(m_axi_gmem2_b7_awready),
    .m_axi_gmem2_b7_wready(m_axi_gmem2_b7_wready),
    .m_axi_gmem2_b7_bid(m_axi_gmem2_b7_bid),
    .m_axi_gmem2_b7_bresp(m_axi_gmem2_b7_bresp),
    .m_axi_gmem2_b7_buser(m_axi_gmem2_b7_buser),
    .m_axi_gmem2_b7_bvalid(m_axi_gmem2_b7_bvalid),
    .m_axi_gmem2_b7_arready(m_axi_gmem2_b7_arready),
    .m_axi_gmem2_b7_rid(m_axi_gmem2_b7_rid),
    .m_axi_gmem2_b7_rdata(m_axi_gmem2_b7_rdata),
    .m_axi_gmem2_b7_rresp(m_axi_gmem2_b7_rresp),
    .m_axi_gmem2_b7_rlast(m_axi_gmem2_b7_rlast),
    .m_axi_gmem2_b7_ruser(m_axi_gmem2_b7_ruser),
    .m_axi_gmem2_b7_rvalid(m_axi_gmem2_b7_rvalid),
    .done_port(done_port),
    .m_axi_gmem0_awid(m_axi_gmem0_awid),
    .m_axi_gmem0_awaddr(m_axi_gmem0_awaddr),
    .m_axi_gmem0_awlen(m_axi_gmem0_awlen),
    .m_axi_gmem0_awsize(m_axi_gmem0_awsize),
    .m_axi_gmem0_awburst(m_axi_gmem0_awburst),
    .m_axi_gmem0_awlock(m_axi_gmem0_awlock),
    .m_axi_gmem0_awcache(m_axi_gmem0_awcache),
    .m_axi_gmem0_awprot(m_axi_gmem0_awprot),
    .m_axi_gmem0_awqos(m_axi_gmem0_awqos),
    .m_axi_gmem0_awregion(m_axi_gmem0_awregion),
    .m_axi_gmem0_awuser(m_axi_gmem0_awuser),
    .m_axi_gmem0_awvalid(m_axi_gmem0_awvalid),
    .m_axi_gmem0_wdata(m_axi_gmem0_wdata),
    .m_axi_gmem0_wstrb(m_axi_gmem0_wstrb),
    .m_axi_gmem0_wlast(m_axi_gmem0_wlast),
    .m_axi_gmem0_wuser(m_axi_gmem0_wuser),
    .m_axi_gmem0_wvalid(m_axi_gmem0_wvalid),
    .m_axi_gmem0_bready(m_axi_gmem0_bready),
    .m_axi_gmem0_arid(m_axi_gmem0_arid),
    .m_axi_gmem0_araddr(m_axi_gmem0_araddr),
    .m_axi_gmem0_arlen(m_axi_gmem0_arlen),
    .m_axi_gmem0_arsize(m_axi_gmem0_arsize),
    .m_axi_gmem0_arburst(m_axi_gmem0_arburst),
    .m_axi_gmem0_arlock(m_axi_gmem0_arlock),
    .m_axi_gmem0_arcache(m_axi_gmem0_arcache),
    .m_axi_gmem0_arprot(m_axi_gmem0_arprot),
    .m_axi_gmem0_arqos(m_axi_gmem0_arqos),
    .m_axi_gmem0_arregion(m_axi_gmem0_arregion),
    .m_axi_gmem0_aruser(m_axi_gmem0_aruser),
    .m_axi_gmem0_arvalid(m_axi_gmem0_arvalid),
    .m_axi_gmem0_rready(m_axi_gmem0_rready),
    .m_axi_gmem1_awid(m_axi_gmem1_awid),
    .m_axi_gmem1_awaddr(m_axi_gmem1_awaddr),
    .m_axi_gmem1_awlen(m_axi_gmem1_awlen),
    .m_axi_gmem1_awsize(m_axi_gmem1_awsize),
    .m_axi_gmem1_awburst(m_axi_gmem1_awburst),
    .m_axi_gmem1_awlock(m_axi_gmem1_awlock),
    .m_axi_gmem1_awcache(m_axi_gmem1_awcache),
    .m_axi_gmem1_awprot(m_axi_gmem1_awprot),
    .m_axi_gmem1_awqos(m_axi_gmem1_awqos),
    .m_axi_gmem1_awregion(m_axi_gmem1_awregion),
    .m_axi_gmem1_awuser(m_axi_gmem1_awuser),
    .m_axi_gmem1_awvalid(m_axi_gmem1_awvalid),
    .m_axi_gmem1_wdata(m_axi_gmem1_wdata),
    .m_axi_gmem1_wstrb(m_axi_gmem1_wstrb),
    .m_axi_gmem1_wlast(m_axi_gmem1_wlast),
    .m_axi_gmem1_wuser(m_axi_gmem1_wuser),
    .m_axi_gmem1_wvalid(m_axi_gmem1_wvalid),
    .m_axi_gmem1_bready(m_axi_gmem1_bready),
    .m_axi_gmem1_arid(m_axi_gmem1_arid),
    .m_axi_gmem1_araddr(m_axi_gmem1_araddr),
    .m_axi_gmem1_arlen(m_axi_gmem1_arlen),
    .m_axi_gmem1_arsize(m_axi_gmem1_arsize),
    .m_axi_gmem1_arburst(m_axi_gmem1_arburst),
    .m_axi_gmem1_arlock(m_axi_gmem1_arlock),
    .m_axi_gmem1_arcache(m_axi_gmem1_arcache),
    .m_axi_gmem1_arprot(m_axi_gmem1_arprot),
    .m_axi_gmem1_arqos(m_axi_gmem1_arqos),
    .m_axi_gmem1_arregion(m_axi_gmem1_arregion),
    .m_axi_gmem1_aruser(m_axi_gmem1_aruser),
    .m_axi_gmem1_arvalid(m_axi_gmem1_arvalid),
    .m_axi_gmem1_rready(m_axi_gmem1_rready),
    .m_axi_gmem2_b0_awid(m_axi_gmem2_b0_awid),
    .m_axi_gmem2_b0_awaddr(m_axi_gmem2_b0_awaddr),
    .m_axi_gmem2_b0_awlen(m_axi_gmem2_b0_awlen),
    .m_axi_gmem2_b0_awsize(m_axi_gmem2_b0_awsize),
    .m_axi_gmem2_b0_awburst(m_axi_gmem2_b0_awburst),
    .m_axi_gmem2_b0_awlock(m_axi_gmem2_b0_awlock),
    .m_axi_gmem2_b0_awcache(m_axi_gmem2_b0_awcache),
    .m_axi_gmem2_b0_awprot(m_axi_gmem2_b0_awprot),
    .m_axi_gmem2_b0_awqos(m_axi_gmem2_b0_awqos),
    .m_axi_gmem2_b0_awregion(m_axi_gmem2_b0_awregion),
    .m_axi_gmem2_b0_awuser(m_axi_gmem2_b0_awuser),
    .m_axi_gmem2_b0_awvalid(m_axi_gmem2_b0_awvalid),
    .m_axi_gmem2_b0_wdata(m_axi_gmem2_b0_wdata),
    .m_axi_gmem2_b0_wstrb(m_axi_gmem2_b0_wstrb),
    .m_axi_gmem2_b0_wlast(m_axi_gmem2_b0_wlast),
    .m_axi_gmem2_b0_wuser(m_axi_gmem2_b0_wuser),
    .m_axi_gmem2_b0_wvalid(m_axi_gmem2_b0_wvalid),
    .m_axi_gmem2_b0_bready(m_axi_gmem2_b0_bready),
    .m_axi_gmem2_b0_arid(m_axi_gmem2_b0_arid),
    .m_axi_gmem2_b0_araddr(m_axi_gmem2_b0_araddr),
    .m_axi_gmem2_b0_arlen(m_axi_gmem2_b0_arlen),
    .m_axi_gmem2_b0_arsize(m_axi_gmem2_b0_arsize),
    .m_axi_gmem2_b0_arburst(m_axi_gmem2_b0_arburst),
    .m_axi_gmem2_b0_arlock(m_axi_gmem2_b0_arlock),
    .m_axi_gmem2_b0_arcache(m_axi_gmem2_b0_arcache),
    .m_axi_gmem2_b0_arprot(m_axi_gmem2_b0_arprot),
    .m_axi_gmem2_b0_arqos(m_axi_gmem2_b0_arqos),
    .m_axi_gmem2_b0_arregion(m_axi_gmem2_b0_arregion),
    .m_axi_gmem2_b0_aruser(m_axi_gmem2_b0_aruser),
    .m_axi_gmem2_b0_arvalid(m_axi_gmem2_b0_arvalid),
    .m_axi_gmem2_b0_rready(m_axi_gmem2_b0_rready),
    .m_axi_gmem2_b1_awid(m_axi_gmem2_b1_awid),
    .m_axi_gmem2_b1_awaddr(m_axi_gmem2_b1_awaddr),
    .m_axi_gmem2_b1_awlen(m_axi_gmem2_b1_awlen),
    .m_axi_gmem2_b1_awsize(m_axi_gmem2_b1_awsize),
    .m_axi_gmem2_b1_awburst(m_axi_gmem2_b1_awburst),
    .m_axi_gmem2_b1_awlock(m_axi_gmem2_b1_awlock),
    .m_axi_gmem2_b1_awcache(m_axi_gmem2_b1_awcache),
    .m_axi_gmem2_b1_awprot(m_axi_gmem2_b1_awprot),
    .m_axi_gmem2_b1_awqos(m_axi_gmem2_b1_awqos),
    .m_axi_gmem2_b1_awregion(m_axi_gmem2_b1_awregion),
    .m_axi_gmem2_b1_awuser(m_axi_gmem2_b1_awuser),
    .m_axi_gmem2_b1_awvalid(m_axi_gmem2_b1_awvalid),
    .m_axi_gmem2_b1_wdata(m_axi_gmem2_b1_wdata),
    .m_axi_gmem2_b1_wstrb(m_axi_gmem2_b1_wstrb),
    .m_axi_gmem2_b1_wlast(m_axi_gmem2_b1_wlast),
    .m_axi_gmem2_b1_wuser(m_axi_gmem2_b1_wuser),
    .m_axi_gmem2_b1_wvalid(m_axi_gmem2_b1_wvalid),
    .m_axi_gmem2_b1_bready(m_axi_gmem2_b1_bready),
    .m_axi_gmem2_b1_arid(m_axi_gmem2_b1_arid),
    .m_axi_gmem2_b1_araddr(m_axi_gmem2_b1_araddr),
    .m_axi_gmem2_b1_arlen(m_axi_gmem2_b1_arlen),
    .m_axi_gmem2_b1_arsize(m_axi_gmem2_b1_arsize),
    .m_axi_gmem2_b1_arburst(m_axi_gmem2_b1_arburst),
    .m_axi_gmem2_b1_arlock(m_axi_gmem2_b1_arlock),
    .m_axi_gmem2_b1_arcache(m_axi_gmem2_b1_arcache),
    .m_axi_gmem2_b1_arprot(m_axi_gmem2_b1_arprot),
    .m_axi_gmem2_b1_arqos(m_axi_gmem2_b1_arqos),
    .m_axi_gmem2_b1_arregion(m_axi_gmem2_b1_arregion),
    .m_axi_gmem2_b1_aruser(m_axi_gmem2_b1_aruser),
    .m_axi_gmem2_b1_arvalid(m_axi_gmem2_b1_arvalid),
    .m_axi_gmem2_b1_rready(m_axi_gmem2_b1_rready),
    .m_axi_gmem2_b2_awid(m_axi_gmem2_b2_awid),
    .m_axi_gmem2_b2_awaddr(m_axi_gmem2_b2_awaddr),
    .m_axi_gmem2_b2_awlen(m_axi_gmem2_b2_awlen),
    .m_axi_gmem2_b2_awsize(m_axi_gmem2_b2_awsize),
    .m_axi_gmem2_b2_awburst(m_axi_gmem2_b2_awburst),
    .m_axi_gmem2_b2_awlock(m_axi_gmem2_b2_awlock),
    .m_axi_gmem2_b2_awcache(m_axi_gmem2_b2_awcache),
    .m_axi_gmem2_b2_awprot(m_axi_gmem2_b2_awprot),
    .m_axi_gmem2_b2_awqos(m_axi_gmem2_b2_awqos),
    .m_axi_gmem2_b2_awregion(m_axi_gmem2_b2_awregion),
    .m_axi_gmem2_b2_awuser(m_axi_gmem2_b2_awuser),
    .m_axi_gmem2_b2_awvalid(m_axi_gmem2_b2_awvalid),
    .m_axi_gmem2_b2_wdata(m_axi_gmem2_b2_wdata),
    .m_axi_gmem2_b2_wstrb(m_axi_gmem2_b2_wstrb),
    .m_axi_gmem2_b2_wlast(m_axi_gmem2_b2_wlast),
    .m_axi_gmem2_b2_wuser(m_axi_gmem2_b2_wuser),
    .m_axi_gmem2_b2_wvalid(m_axi_gmem2_b2_wvalid),
    .m_axi_gmem2_b2_bready(m_axi_gmem2_b2_bready),
    .m_axi_gmem2_b2_arid(m_axi_gmem2_b2_arid),
    .m_axi_gmem2_b2_araddr(m_axi_gmem2_b2_araddr),
    .m_axi_gmem2_b2_arlen(m_axi_gmem2_b2_arlen),
    .m_axi_gmem2_b2_arsize(m_axi_gmem2_b2_arsize),
    .m_axi_gmem2_b2_arburst(m_axi_gmem2_b2_arburst),
    .m_axi_gmem2_b2_arlock(m_axi_gmem2_b2_arlock),
    .m_axi_gmem2_b2_arcache(m_axi_gmem2_b2_arcache),
    .m_axi_gmem2_b2_arprot(m_axi_gmem2_b2_arprot),
    .m_axi_gmem2_b2_arqos(m_axi_gmem2_b2_arqos),
    .m_axi_gmem2_b2_arregion(m_axi_gmem2_b2_arregion),
    .m_axi_gmem2_b2_aruser(m_axi_gmem2_b2_aruser),
    .m_axi_gmem2_b2_arvalid(m_axi_gmem2_b2_arvalid),
    .m_axi_gmem2_b2_rready(m_axi_gmem2_b2_rready),
    .m_axi_gmem2_b3_awid(m_axi_gmem2_b3_awid),
    .m_axi_gmem2_b3_awaddr(m_axi_gmem2_b3_awaddr),
    .m_axi_gmem2_b3_awlen(m_axi_gmem2_b3_awlen),
    .m_axi_gmem2_b3_awsize(m_axi_gmem2_b3_awsize),
    .m_axi_gmem2_b3_awburst(m_axi_gmem2_b3_awburst),
    .m_axi_gmem2_b3_awlock(m_axi_gmem2_b3_awlock),
    .m_axi_gmem2_b3_awcache(m_axi_gmem2_b3_awcache),
    .m_axi_gmem2_b3_awprot(m_axi_gmem2_b3_awprot),
    .m_axi_gmem2_b3_awqos(m_axi_gmem2_b3_awqos),
    .m_axi_gmem2_b3_awregion(m_axi_gmem2_b3_awregion),
    .m_axi_gmem2_b3_awuser(m_axi_gmem2_b3_awuser),
    .m_axi_gmem2_b3_awvalid(m_axi_gmem2_b3_awvalid),
    .m_axi_gmem2_b3_wdata(m_axi_gmem2_b3_wdata),
    .m_axi_gmem2_b3_wstrb(m_axi_gmem2_b3_wstrb),
    .m_axi_gmem2_b3_wlast(m_axi_gmem2_b3_wlast),
    .m_axi_gmem2_b3_wuser(m_axi_gmem2_b3_wuser),
    .m_axi_gmem2_b3_wvalid(m_axi_gmem2_b3_wvalid),
    .m_axi_gmem2_b3_bready(m_axi_gmem2_b3_bready),
    .m_axi_gmem2_b3_arid(m_axi_gmem2_b3_arid),
    .m_axi_gmem2_b3_araddr(m_axi_gmem2_b3_araddr),
    .m_axi_gmem2_b3_arlen(m_axi_gmem2_b3_arlen),
    .m_axi_gmem2_b3_arsize(m_axi_gmem2_b3_arsize),
    .m_axi_gmem2_b3_arburst(m_axi_gmem2_b3_arburst),
    .m_axi_gmem2_b3_arlock(m_axi_gmem2_b3_arlock),
    .m_axi_gmem2_b3_arcache(m_axi_gmem2_b3_arcache),
    .m_axi_gmem2_b3_arprot(m_axi_gmem2_b3_arprot),
    .m_axi_gmem2_b3_arqos(m_axi_gmem2_b3_arqos),
    .m_axi_gmem2_b3_arregion(m_axi_gmem2_b3_arregion),
    .m_axi_gmem2_b3_aruser(m_axi_gmem2_b3_aruser),
    .m_axi_gmem2_b3_arvalid(m_axi_gmem2_b3_arvalid),
    .m_axi_gmem2_b3_rready(m_axi_gmem2_b3_rready),
    .m_axi_gmem2_b4_awid(m_axi_gmem2_b4_awid),
    .m_axi_gmem2_b4_awaddr(m_axi_gmem2_b4_awaddr),
    .m_axi_gmem2_b4_awlen(m_axi_gmem2_b4_awlen),
    .m_axi_gmem2_b4_awsize(m_axi_gmem2_b4_awsize),
    .m_axi_gmem2_b4_awburst(m_axi_gmem2_b4_awburst),
    .m_axi_gmem2_b4_awlock(m_axi_gmem2_b4_awlock),
    .m_axi_gmem2_b4_awcache(m_axi_gmem2_b4_awcache),
    .m_axi_gmem2_b4_awprot(m_axi_gmem2_b4_awprot),
    .m_axi_gmem2_b4_awqos(m_axi_gmem2_b4_awqos),
    .m_axi_gmem2_b4_awregion(m_axi_gmem2_b4_awregion),
    .m_axi_gmem2_b4_awuser(m_axi_gmem2_b4_awuser),
    .m_axi_gmem2_b4_awvalid(m_axi_gmem2_b4_awvalid),
    .m_axi_gmem2_b4_wdata(m_axi_gmem2_b4_wdata),
    .m_axi_gmem2_b4_wstrb(m_axi_gmem2_b4_wstrb),
    .m_axi_gmem2_b4_wlast(m_axi_gmem2_b4_wlast),
    .m_axi_gmem2_b4_wuser(m_axi_gmem2_b4_wuser),
    .m_axi_gmem2_b4_wvalid(m_axi_gmem2_b4_wvalid),
    .m_axi_gmem2_b4_bready(m_axi_gmem2_b4_bready),
    .m_axi_gmem2_b4_arid(m_axi_gmem2_b4_arid),
    .m_axi_gmem2_b4_araddr(m_axi_gmem2_b4_araddr),
    .m_axi_gmem2_b4_arlen(m_axi_gmem2_b4_arlen),
    .m_axi_gmem2_b4_arsize(m_axi_gmem2_b4_arsize),
    .m_axi_gmem2_b4_arburst(m_axi_gmem2_b4_arburst),
    .m_axi_gmem2_b4_arlock(m_axi_gmem2_b4_arlock),
    .m_axi_gmem2_b4_arcache(m_axi_gmem2_b4_arcache),
    .m_axi_gmem2_b4_arprot(m_axi_gmem2_b4_arprot),
    .m_axi_gmem2_b4_arqos(m_axi_gmem2_b4_arqos),
    .m_axi_gmem2_b4_arregion(m_axi_gmem2_b4_arregion),
    .m_axi_gmem2_b4_aruser(m_axi_gmem2_b4_aruser),
    .m_axi_gmem2_b4_arvalid(m_axi_gmem2_b4_arvalid),
    .m_axi_gmem2_b4_rready(m_axi_gmem2_b4_rready),
    .m_axi_gmem2_b5_awid(m_axi_gmem2_b5_awid),
    .m_axi_gmem2_b5_awaddr(m_axi_gmem2_b5_awaddr),
    .m_axi_gmem2_b5_awlen(m_axi_gmem2_b5_awlen),
    .m_axi_gmem2_b5_awsize(m_axi_gmem2_b5_awsize),
    .m_axi_gmem2_b5_awburst(m_axi_gmem2_b5_awburst),
    .m_axi_gmem2_b5_awlock(m_axi_gmem2_b5_awlock),
    .m_axi_gmem2_b5_awcache(m_axi_gmem2_b5_awcache),
    .m_axi_gmem2_b5_awprot(m_axi_gmem2_b5_awprot),
    .m_axi_gmem2_b5_awqos(m_axi_gmem2_b5_awqos),
    .m_axi_gmem2_b5_awregion(m_axi_gmem2_b5_awregion),
    .m_axi_gmem2_b5_awuser(m_axi_gmem2_b5_awuser),
    .m_axi_gmem2_b5_awvalid(m_axi_gmem2_b5_awvalid),
    .m_axi_gmem2_b5_wdata(m_axi_gmem2_b5_wdata),
    .m_axi_gmem2_b5_wstrb(m_axi_gmem2_b5_wstrb),
    .m_axi_gmem2_b5_wlast(m_axi_gmem2_b5_wlast),
    .m_axi_gmem2_b5_wuser(m_axi_gmem2_b5_wuser),
    .m_axi_gmem2_b5_wvalid(m_axi_gmem2_b5_wvalid),
    .m_axi_gmem2_b5_bready(m_axi_gmem2_b5_bready),
    .m_axi_gmem2_b5_arid(m_axi_gmem2_b5_arid),
    .m_axi_gmem2_b5_araddr(m_axi_gmem2_b5_araddr),
    .m_axi_gmem2_b5_arlen(m_axi_gmem2_b5_arlen),
    .m_axi_gmem2_b5_arsize(m_axi_gmem2_b5_arsize),
    .m_axi_gmem2_b5_arburst(m_axi_gmem2_b5_arburst),
    .m_axi_gmem2_b5_arlock(m_axi_gmem2_b5_arlock),
    .m_axi_gmem2_b5_arcache(m_axi_gmem2_b5_arcache),
    .m_axi_gmem2_b5_arprot(m_axi_gmem2_b5_arprot),
    .m_axi_gmem2_b5_arqos(m_axi_gmem2_b5_arqos),
    .m_axi_gmem2_b5_arregion(m_axi_gmem2_b5_arregion),
    .m_axi_gmem2_b5_aruser(m_axi_gmem2_b5_aruser),
    .m_axi_gmem2_b5_arvalid(m_axi_gmem2_b5_arvalid),
    .m_axi_gmem2_b5_rready(m_axi_gmem2_b5_rready),
    .m_axi_gmem2_b6_awid(m_axi_gmem2_b6_awid),
    .m_axi_gmem2_b6_awaddr(m_axi_gmem2_b6_awaddr),
    .m_axi_gmem2_b6_awlen(m_axi_gmem2_b6_awlen),
    .m_axi_gmem2_b6_awsize(m_axi_gmem2_b6_awsize),
    .m_axi_gmem2_b6_awburst(m_axi_gmem2_b6_awburst),
    .m_axi_gmem2_b6_awlock(m_axi_gmem2_b6_awlock),
    .m_axi_gmem2_b6_awcache(m_axi_gmem2_b6_awcache),
    .m_axi_gmem2_b6_awprot(m_axi_gmem2_b6_awprot),
    .m_axi_gmem2_b6_awqos(m_axi_gmem2_b6_awqos),
    .m_axi_gmem2_b6_awregion(m_axi_gmem2_b6_awregion),
    .m_axi_gmem2_b6_awuser(m_axi_gmem2_b6_awuser),
    .m_axi_gmem2_b6_awvalid(m_axi_gmem2_b6_awvalid),
    .m_axi_gmem2_b6_wdata(m_axi_gmem2_b6_wdata),
    .m_axi_gmem2_b6_wstrb(m_axi_gmem2_b6_wstrb),
    .m_axi_gmem2_b6_wlast(m_axi_gmem2_b6_wlast),
    .m_axi_gmem2_b6_wuser(m_axi_gmem2_b6_wuser),
    .m_axi_gmem2_b6_wvalid(m_axi_gmem2_b6_wvalid),
    .m_axi_gmem2_b6_bready(m_axi_gmem2_b6_bready),
    .m_axi_gmem2_b6_arid(m_axi_gmem2_b6_arid),
    .m_axi_gmem2_b6_araddr(m_axi_gmem2_b6_araddr),
    .m_axi_gmem2_b6_arlen(m_axi_gmem2_b6_arlen),
    .m_axi_gmem2_b6_arsize(m_axi_gmem2_b6_arsize),
    .m_axi_gmem2_b6_arburst(m_axi_gmem2_b6_arburst),
    .m_axi_gmem2_b6_arlock(m_axi_gmem2_b6_arlock),
    .m_axi_gmem2_b6_arcache(m_axi_gmem2_b6_arcache),
    .m_axi_gmem2_b6_arprot(m_axi_gmem2_b6_arprot),
    .m_axi_gmem2_b6_arqos(m_axi_gmem2_b6_arqos),
    .m_axi_gmem2_b6_arregion(m_axi_gmem2_b6_arregion),
    .m_axi_gmem2_b6_aruser(m_axi_gmem2_b6_aruser),
    .m_axi_gmem2_b6_arvalid(m_axi_gmem2_b6_arvalid),
    .m_axi_gmem2_b6_rready(m_axi_gmem2_b6_rready),
    .m_axi_gmem2_b7_awid(m_axi_gmem2_b7_awid),
    .m_axi_gmem2_b7_awaddr(m_axi_gmem2_b7_awaddr),
    .m_axi_gmem2_b7_awlen(m_axi_gmem2_b7_awlen),
    .m_axi_gmem2_b7_awsize(m_axi_gmem2_b7_awsize),
    .m_axi_gmem2_b7_awburst(m_axi_gmem2_b7_awburst),
    .m_axi_gmem2_b7_awlock(m_axi_gmem2_b7_awlock),
    .m_axi_gmem2_b7_awcache(m_axi_gmem2_b7_awcache),
    .m_axi_gmem2_b7_awprot(m_axi_gmem2_b7_awprot),
    .m_axi_gmem2_b7_awqos(m_axi_gmem2_b7_awqos),
    .m_axi_gmem2_b7_awregion(m_axi_gmem2_b7_awregion),
    .m_axi_gmem2_b7_awuser(m_axi_gmem2_b7_awuser),
    .m_axi_gmem2_b7_awvalid(m_axi_gmem2_b7_awvalid),
    .m_axi_gmem2_b7_wdata(m_axi_gmem2_b7_wdata),
    .m_axi_gmem2_b7_wstrb(m_axi_gmem2_b7_wstrb),
    .m_axi_gmem2_b7_wlast(m_axi_gmem2_b7_wlast),
    .m_axi_gmem2_b7_wuser(m_axi_gmem2_b7_wuser),
    .m_axi_gmem2_b7_wvalid(m_axi_gmem2_b7_wvalid),
    .m_axi_gmem2_b7_bready(m_axi_gmem2_b7_bready),
    .m_axi_gmem2_b7_arid(m_axi_gmem2_b7_arid),
    .m_axi_gmem2_b7_araddr(m_axi_gmem2_b7_araddr),
    .m_axi_gmem2_b7_arlen(m_axi_gmem2_b7_arlen),
    .m_axi_gmem2_b7_arsize(m_axi_gmem2_b7_arsize),
    .m_axi_gmem2_b7_arburst(m_axi_gmem2_b7_arburst),
    .m_axi_gmem2_b7_arlock(m_axi_gmem2_b7_arlock),
    .m_axi_gmem2_b7_arcache(m_axi_gmem2_b7_arcache),
    .m_axi_gmem2_b7_arprot(m_axi_gmem2_b7_arprot),
    .m_axi_gmem2_b7_arqos(m_axi_gmem2_b7_arqos),
    .m_axi_gmem2_b7_arregion(m_axi_gmem2_b7_arregion),
    .m_axi_gmem2_b7_aruser(m_axi_gmem2_b7_aruser),
    .m_axi_gmem2_b7_arvalid(m_axi_gmem2_b7_arvalid),
    .m_axi_gmem2_b7_rready(m_axi_gmem2_b7_rready));

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
module if_m_axi_gmem0(clock,
  reset,
  done_port,
  m_axi_gmem0_awready,
  m_axi_gmem0_wready,
  m_axi_gmem0_bid,
  m_axi_gmem0_bresp,
  m_axi_gmem0_buser,
  m_axi_gmem0_bvalid,
  m_axi_gmem0_arready,
  m_axi_gmem0_rid,
  m_axi_gmem0_rdata,
  m_axi_gmem0_rresp,
  m_axi_gmem0_rlast,
  m_axi_gmem0_ruser,
  m_axi_gmem0_rvalid,
  m_axi_gmem0_awid,
  m_axi_gmem0_awaddr,
  m_axi_gmem0_awlen,
  m_axi_gmem0_awsize,
  m_axi_gmem0_awburst,
  m_axi_gmem0_awlock,
  m_axi_gmem0_awcache,
  m_axi_gmem0_awprot,
  m_axi_gmem0_awqos,
  m_axi_gmem0_awregion,
  m_axi_gmem0_awuser,
  m_axi_gmem0_awvalid,
  m_axi_gmem0_wdata,
  m_axi_gmem0_wstrb,
  m_axi_gmem0_wlast,
  m_axi_gmem0_wuser,
  m_axi_gmem0_wvalid,
  m_axi_gmem0_bready,
  m_axi_gmem0_arid,
  m_axi_gmem0_araddr,
  m_axi_gmem0_arlen,
  m_axi_gmem0_arsize,
  m_axi_gmem0_arburst,
  m_axi_gmem0_arlock,
  m_axi_gmem0_arcache,
  m_axi_gmem0_arprot,
  m_axi_gmem0_arqos,
  m_axi_gmem0_arregion,
  m_axi_gmem0_aruser,
  m_axi_gmem0_arvalid,
  m_axi_gmem0_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem0_bid=1,
    BITSIZE_m_axi_gmem0_bresp=2,
    BITSIZE_m_axi_gmem0_buser=1,
    BITSIZE_m_axi_gmem0_rid=1,
    BITSIZE_m_axi_gmem0_rdata=1,
    BITSIZE_m_axi_gmem0_rresp=2,
    BITSIZE_m_axi_gmem0_ruser=1,
    BITSIZE_m_axi_gmem0_awid=1,
    BITSIZE_m_axi_gmem0_awaddr=1,
    BITSIZE_m_axi_gmem0_awlen=1,
    BITSIZE_m_axi_gmem0_awsize=1,
    BITSIZE_m_axi_gmem0_awburst=2,
    BITSIZE_m_axi_gmem0_awlock=1,
    BITSIZE_m_axi_gmem0_awcache=1,
    BITSIZE_m_axi_gmem0_awprot=1,
    BITSIZE_m_axi_gmem0_awqos=1,
    BITSIZE_m_axi_gmem0_awregion=1,
    BITSIZE_m_axi_gmem0_awuser=1,
    BITSIZE_m_axi_gmem0_wdata=1,
    BITSIZE_m_axi_gmem0_wstrb=1,
    BITSIZE_m_axi_gmem0_wuser=1,
    BITSIZE_m_axi_gmem0_arid=1,
    BITSIZE_m_axi_gmem0_araddr=1,
    BITSIZE_m_axi_gmem0_arlen=1,
    BITSIZE_m_axi_gmem0_arsize=1,
    BITSIZE_m_axi_gmem0_arburst=2,
    BITSIZE_m_axi_gmem0_arlock=1,
    BITSIZE_m_axi_gmem0_arcache=1,
    BITSIZE_m_axi_gmem0_arprot=1,
    BITSIZE_m_axi_gmem0_arqos=1,
    BITSIZE_m_axi_gmem0_arregion=1,
    BITSIZE_m_axi_gmem0_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem0_awid-1:0] m_axi_gmem0_awid;
  input [BITSIZE_m_axi_gmem0_awaddr-1:0] m_axi_gmem0_awaddr;
  input [BITSIZE_m_axi_gmem0_awlen-1:0] m_axi_gmem0_awlen;
  input [BITSIZE_m_axi_gmem0_awsize-1:0] m_axi_gmem0_awsize;
  input [BITSIZE_m_axi_gmem0_awburst-1:0] m_axi_gmem0_awburst;
  input [BITSIZE_m_axi_gmem0_awlock-1:0] m_axi_gmem0_awlock;
  input [BITSIZE_m_axi_gmem0_awcache-1:0] m_axi_gmem0_awcache;
  input [BITSIZE_m_axi_gmem0_awprot-1:0] m_axi_gmem0_awprot;
  input [BITSIZE_m_axi_gmem0_awqos-1:0] m_axi_gmem0_awqos;
  input [BITSIZE_m_axi_gmem0_awregion-1:0] m_axi_gmem0_awregion;
  input [BITSIZE_m_axi_gmem0_awuser-1:0] m_axi_gmem0_awuser;
  input m_axi_gmem0_awvalid;
  input [BITSIZE_m_axi_gmem0_wdata-1:0] m_axi_gmem0_wdata;
  input [BITSIZE_m_axi_gmem0_wstrb-1:0] m_axi_gmem0_wstrb;
  input m_axi_gmem0_wlast;
  input [BITSIZE_m_axi_gmem0_wuser-1:0] m_axi_gmem0_wuser;
  input m_axi_gmem0_wvalid;
  input m_axi_gmem0_bready;
  input [BITSIZE_m_axi_gmem0_arid-1:0] m_axi_gmem0_arid;
  input [BITSIZE_m_axi_gmem0_araddr-1:0] m_axi_gmem0_araddr;
  input [BITSIZE_m_axi_gmem0_arlen-1:0] m_axi_gmem0_arlen;
  input [BITSIZE_m_axi_gmem0_arsize-1:0] m_axi_gmem0_arsize;
  input [BITSIZE_m_axi_gmem0_arburst-1:0] m_axi_gmem0_arburst;
  input [BITSIZE_m_axi_gmem0_arlock-1:0] m_axi_gmem0_arlock;
  input [BITSIZE_m_axi_gmem0_arcache-1:0] m_axi_gmem0_arcache;
  input [BITSIZE_m_axi_gmem0_arprot-1:0] m_axi_gmem0_arprot;
  input [BITSIZE_m_axi_gmem0_arqos-1:0] m_axi_gmem0_arqos;
  input [BITSIZE_m_axi_gmem0_arregion-1:0] m_axi_gmem0_arregion;
  input [BITSIZE_m_axi_gmem0_aruser-1:0] m_axi_gmem0_aruser;
  input m_axi_gmem0_arvalid;
  input m_axi_gmem0_rready;
  // OUT
  output m_axi_gmem0_awready;
  output m_axi_gmem0_wready;
  output [BITSIZE_m_axi_gmem0_bid-1:0] m_axi_gmem0_bid;
  output [BITSIZE_m_axi_gmem0_bresp-1:0] m_axi_gmem0_bresp;
  output [BITSIZE_m_axi_gmem0_buser-1:0] m_axi_gmem0_buser;
  output m_axi_gmem0_bvalid;
  output m_axi_gmem0_arready;
  output [BITSIZE_m_axi_gmem0_rid-1:0] m_axi_gmem0_rid;
  output [BITSIZE_m_axi_gmem0_rdata-1:0] m_axi_gmem0_rdata;
  output [BITSIZE_m_axi_gmem0_rresp-1:0] m_axi_gmem0_rresp;
  output m_axi_gmem0_rlast;
  output [BITSIZE_m_axi_gmem0_ruser-1:0] m_axi_gmem0_ruser;
  output m_axi_gmem0_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem0_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem0_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem0_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem0_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem0_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem0_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem0_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem0_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem0_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem0_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem0_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem0_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem0_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem0_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem0_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem0_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem0_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem0_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem0_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem0_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem0_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem0_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem0_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem0_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem0_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem0_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem0_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem0_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem0_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem0_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem0_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem0_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem0_awready=awready;
  assign m_axi_gmem0_wready=wready;
  assign m_axi_gmem0_bid=bid;
  assign m_axi_gmem0_bresp=bresp;
  assign m_axi_gmem0_buser=buser;
  assign m_axi_gmem0_bvalid=bvalid;
  assign m_axi_gmem0_arready=arready;
  assign m_axi_gmem0_rid=rid;
  assign m_axi_gmem0_rdata=rdata;
  assign m_axi_gmem0_rresp=rresp;
  assign m_axi_gmem0_rlast=rlast;
  assign m_axi_gmem0_ruser=ruser;
  assign m_axi_gmem0_rvalid=rvalid;
  assign awid=m_axi_gmem0_awid;
  assign awaddr=m_axi_gmem0_awaddr;
  assign awlen=m_axi_gmem0_awlen;
  assign awsize=m_axi_gmem0_awsize;
  assign awburst=m_axi_gmem0_awburst;
  assign awlock=m_axi_gmem0_awlock;
  assign awcache=m_axi_gmem0_awcache;
  assign awprot=m_axi_gmem0_awprot;
  assign awqos=m_axi_gmem0_awqos;
  assign awregion=m_axi_gmem0_awregion;
  assign awuser=m_axi_gmem0_awuser;
  assign awvalid=m_axi_gmem0_awvalid;
  assign wdata=m_axi_gmem0_wdata;
  assign wstrb=m_axi_gmem0_wstrb;
  assign wlast=m_axi_gmem0_wlast;
  assign wuser=m_axi_gmem0_wuser;
  assign wvalid=m_axi_gmem0_wvalid;
  assign bready=m_axi_gmem0_bready;
  assign arid=m_axi_gmem0_arid;
  assign araddr=m_axi_gmem0_araddr;
  assign arlen=m_axi_gmem0_arlen;
  assign arsize=m_axi_gmem0_arsize;
  assign arburst=m_axi_gmem0_arburst;
  assign arlock=m_axi_gmem0_arlock;
  assign arcache=m_axi_gmem0_arcache;
  assign arprot=m_axi_gmem0_arprot;
  assign arqos=m_axi_gmem0_arqos;
  assign arregion=m_axi_gmem0_arregion;
  assign aruser=m_axi_gmem0_aruser;
  assign arvalid=m_axi_gmem0_arvalid;
  assign rready=m_axi_gmem0_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem0_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem0_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem0_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem0_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem0_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem0_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem0_arid,
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
module if_m_axi_gmem1(clock,
  reset,
  done_port,
  m_axi_gmem1_awready,
  m_axi_gmem1_wready,
  m_axi_gmem1_bid,
  m_axi_gmem1_bresp,
  m_axi_gmem1_buser,
  m_axi_gmem1_bvalid,
  m_axi_gmem1_arready,
  m_axi_gmem1_rid,
  m_axi_gmem1_rdata,
  m_axi_gmem1_rresp,
  m_axi_gmem1_rlast,
  m_axi_gmem1_ruser,
  m_axi_gmem1_rvalid,
  m_axi_gmem1_awid,
  m_axi_gmem1_awaddr,
  m_axi_gmem1_awlen,
  m_axi_gmem1_awsize,
  m_axi_gmem1_awburst,
  m_axi_gmem1_awlock,
  m_axi_gmem1_awcache,
  m_axi_gmem1_awprot,
  m_axi_gmem1_awqos,
  m_axi_gmem1_awregion,
  m_axi_gmem1_awuser,
  m_axi_gmem1_awvalid,
  m_axi_gmem1_wdata,
  m_axi_gmem1_wstrb,
  m_axi_gmem1_wlast,
  m_axi_gmem1_wuser,
  m_axi_gmem1_wvalid,
  m_axi_gmem1_bready,
  m_axi_gmem1_arid,
  m_axi_gmem1_araddr,
  m_axi_gmem1_arlen,
  m_axi_gmem1_arsize,
  m_axi_gmem1_arburst,
  m_axi_gmem1_arlock,
  m_axi_gmem1_arcache,
  m_axi_gmem1_arprot,
  m_axi_gmem1_arqos,
  m_axi_gmem1_arregion,
  m_axi_gmem1_aruser,
  m_axi_gmem1_arvalid,
  m_axi_gmem1_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem1_bid=1,
    BITSIZE_m_axi_gmem1_bresp=2,
    BITSIZE_m_axi_gmem1_buser=1,
    BITSIZE_m_axi_gmem1_rid=1,
    BITSIZE_m_axi_gmem1_rdata=1,
    BITSIZE_m_axi_gmem1_rresp=2,
    BITSIZE_m_axi_gmem1_ruser=1,
    BITSIZE_m_axi_gmem1_awid=1,
    BITSIZE_m_axi_gmem1_awaddr=1,
    BITSIZE_m_axi_gmem1_awlen=1,
    BITSIZE_m_axi_gmem1_awsize=1,
    BITSIZE_m_axi_gmem1_awburst=2,
    BITSIZE_m_axi_gmem1_awlock=1,
    BITSIZE_m_axi_gmem1_awcache=1,
    BITSIZE_m_axi_gmem1_awprot=1,
    BITSIZE_m_axi_gmem1_awqos=1,
    BITSIZE_m_axi_gmem1_awregion=1,
    BITSIZE_m_axi_gmem1_awuser=1,
    BITSIZE_m_axi_gmem1_wdata=1,
    BITSIZE_m_axi_gmem1_wstrb=1,
    BITSIZE_m_axi_gmem1_wuser=1,
    BITSIZE_m_axi_gmem1_arid=1,
    BITSIZE_m_axi_gmem1_araddr=1,
    BITSIZE_m_axi_gmem1_arlen=1,
    BITSIZE_m_axi_gmem1_arsize=1,
    BITSIZE_m_axi_gmem1_arburst=2,
    BITSIZE_m_axi_gmem1_arlock=1,
    BITSIZE_m_axi_gmem1_arcache=1,
    BITSIZE_m_axi_gmem1_arprot=1,
    BITSIZE_m_axi_gmem1_arqos=1,
    BITSIZE_m_axi_gmem1_arregion=1,
    BITSIZE_m_axi_gmem1_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem1_awid-1:0] m_axi_gmem1_awid;
  input [BITSIZE_m_axi_gmem1_awaddr-1:0] m_axi_gmem1_awaddr;
  input [BITSIZE_m_axi_gmem1_awlen-1:0] m_axi_gmem1_awlen;
  input [BITSIZE_m_axi_gmem1_awsize-1:0] m_axi_gmem1_awsize;
  input [BITSIZE_m_axi_gmem1_awburst-1:0] m_axi_gmem1_awburst;
  input [BITSIZE_m_axi_gmem1_awlock-1:0] m_axi_gmem1_awlock;
  input [BITSIZE_m_axi_gmem1_awcache-1:0] m_axi_gmem1_awcache;
  input [BITSIZE_m_axi_gmem1_awprot-1:0] m_axi_gmem1_awprot;
  input [BITSIZE_m_axi_gmem1_awqos-1:0] m_axi_gmem1_awqos;
  input [BITSIZE_m_axi_gmem1_awregion-1:0] m_axi_gmem1_awregion;
  input [BITSIZE_m_axi_gmem1_awuser-1:0] m_axi_gmem1_awuser;
  input m_axi_gmem1_awvalid;
  input [BITSIZE_m_axi_gmem1_wdata-1:0] m_axi_gmem1_wdata;
  input [BITSIZE_m_axi_gmem1_wstrb-1:0] m_axi_gmem1_wstrb;
  input m_axi_gmem1_wlast;
  input [BITSIZE_m_axi_gmem1_wuser-1:0] m_axi_gmem1_wuser;
  input m_axi_gmem1_wvalid;
  input m_axi_gmem1_bready;
  input [BITSIZE_m_axi_gmem1_arid-1:0] m_axi_gmem1_arid;
  input [BITSIZE_m_axi_gmem1_araddr-1:0] m_axi_gmem1_araddr;
  input [BITSIZE_m_axi_gmem1_arlen-1:0] m_axi_gmem1_arlen;
  input [BITSIZE_m_axi_gmem1_arsize-1:0] m_axi_gmem1_arsize;
  input [BITSIZE_m_axi_gmem1_arburst-1:0] m_axi_gmem1_arburst;
  input [BITSIZE_m_axi_gmem1_arlock-1:0] m_axi_gmem1_arlock;
  input [BITSIZE_m_axi_gmem1_arcache-1:0] m_axi_gmem1_arcache;
  input [BITSIZE_m_axi_gmem1_arprot-1:0] m_axi_gmem1_arprot;
  input [BITSIZE_m_axi_gmem1_arqos-1:0] m_axi_gmem1_arqos;
  input [BITSIZE_m_axi_gmem1_arregion-1:0] m_axi_gmem1_arregion;
  input [BITSIZE_m_axi_gmem1_aruser-1:0] m_axi_gmem1_aruser;
  input m_axi_gmem1_arvalid;
  input m_axi_gmem1_rready;
  // OUT
  output m_axi_gmem1_awready;
  output m_axi_gmem1_wready;
  output [BITSIZE_m_axi_gmem1_bid-1:0] m_axi_gmem1_bid;
  output [BITSIZE_m_axi_gmem1_bresp-1:0] m_axi_gmem1_bresp;
  output [BITSIZE_m_axi_gmem1_buser-1:0] m_axi_gmem1_buser;
  output m_axi_gmem1_bvalid;
  output m_axi_gmem1_arready;
  output [BITSIZE_m_axi_gmem1_rid-1:0] m_axi_gmem1_rid;
  output [BITSIZE_m_axi_gmem1_rdata-1:0] m_axi_gmem1_rdata;
  output [BITSIZE_m_axi_gmem1_rresp-1:0] m_axi_gmem1_rresp;
  output m_axi_gmem1_rlast;
  output [BITSIZE_m_axi_gmem1_ruser-1:0] m_axi_gmem1_ruser;
  output m_axi_gmem1_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem1_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem1_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem1_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem1_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem1_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem1_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem1_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem1_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem1_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem1_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem1_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem1_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem1_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem1_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem1_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem1_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem1_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem1_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem1_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem1_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem1_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem1_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem1_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem1_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem1_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem1_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem1_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem1_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem1_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem1_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem1_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem1_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem1_awready=awready;
  assign m_axi_gmem1_wready=wready;
  assign m_axi_gmem1_bid=bid;
  assign m_axi_gmem1_bresp=bresp;
  assign m_axi_gmem1_buser=buser;
  assign m_axi_gmem1_bvalid=bvalid;
  assign m_axi_gmem1_arready=arready;
  assign m_axi_gmem1_rid=rid;
  assign m_axi_gmem1_rdata=rdata;
  assign m_axi_gmem1_rresp=rresp;
  assign m_axi_gmem1_rlast=rlast;
  assign m_axi_gmem1_ruser=ruser;
  assign m_axi_gmem1_rvalid=rvalid;
  assign awid=m_axi_gmem1_awid;
  assign awaddr=m_axi_gmem1_awaddr;
  assign awlen=m_axi_gmem1_awlen;
  assign awsize=m_axi_gmem1_awsize;
  assign awburst=m_axi_gmem1_awburst;
  assign awlock=m_axi_gmem1_awlock;
  assign awcache=m_axi_gmem1_awcache;
  assign awprot=m_axi_gmem1_awprot;
  assign awqos=m_axi_gmem1_awqos;
  assign awregion=m_axi_gmem1_awregion;
  assign awuser=m_axi_gmem1_awuser;
  assign awvalid=m_axi_gmem1_awvalid;
  assign wdata=m_axi_gmem1_wdata;
  assign wstrb=m_axi_gmem1_wstrb;
  assign wlast=m_axi_gmem1_wlast;
  assign wuser=m_axi_gmem1_wuser;
  assign wvalid=m_axi_gmem1_wvalid;
  assign bready=m_axi_gmem1_bready;
  assign arid=m_axi_gmem1_arid;
  assign araddr=m_axi_gmem1_araddr;
  assign arlen=m_axi_gmem1_arlen;
  assign arsize=m_axi_gmem1_arsize;
  assign arburst=m_axi_gmem1_arburst;
  assign arlock=m_axi_gmem1_arlock;
  assign arcache=m_axi_gmem1_arcache;
  assign arprot=m_axi_gmem1_arprot;
  assign arqos=m_axi_gmem1_arqos;
  assign arregion=m_axi_gmem1_arregion;
  assign aruser=m_axi_gmem1_aruser;
  assign arvalid=m_axi_gmem1_arvalid;
  assign rready=m_axi_gmem1_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem1_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem1_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem1_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem1_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem1_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem1_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem1_arid,
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
module if_m_axi_gmem2_b0(clock,
  reset,
  done_port,
  m_axi_gmem2_b0_awready,
  m_axi_gmem2_b0_wready,
  m_axi_gmem2_b0_bid,
  m_axi_gmem2_b0_bresp,
  m_axi_gmem2_b0_buser,
  m_axi_gmem2_b0_bvalid,
  m_axi_gmem2_b0_arready,
  m_axi_gmem2_b0_rid,
  m_axi_gmem2_b0_rdata,
  m_axi_gmem2_b0_rresp,
  m_axi_gmem2_b0_rlast,
  m_axi_gmem2_b0_ruser,
  m_axi_gmem2_b0_rvalid,
  m_axi_gmem2_b0_awid,
  m_axi_gmem2_b0_awaddr,
  m_axi_gmem2_b0_awlen,
  m_axi_gmem2_b0_awsize,
  m_axi_gmem2_b0_awburst,
  m_axi_gmem2_b0_awlock,
  m_axi_gmem2_b0_awcache,
  m_axi_gmem2_b0_awprot,
  m_axi_gmem2_b0_awqos,
  m_axi_gmem2_b0_awregion,
  m_axi_gmem2_b0_awuser,
  m_axi_gmem2_b0_awvalid,
  m_axi_gmem2_b0_wdata,
  m_axi_gmem2_b0_wstrb,
  m_axi_gmem2_b0_wlast,
  m_axi_gmem2_b0_wuser,
  m_axi_gmem2_b0_wvalid,
  m_axi_gmem2_b0_bready,
  m_axi_gmem2_b0_arid,
  m_axi_gmem2_b0_araddr,
  m_axi_gmem2_b0_arlen,
  m_axi_gmem2_b0_arsize,
  m_axi_gmem2_b0_arburst,
  m_axi_gmem2_b0_arlock,
  m_axi_gmem2_b0_arcache,
  m_axi_gmem2_b0_arprot,
  m_axi_gmem2_b0_arqos,
  m_axi_gmem2_b0_arregion,
  m_axi_gmem2_b0_aruser,
  m_axi_gmem2_b0_arvalid,
  m_axi_gmem2_b0_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem2_b0_bid=1,
    BITSIZE_m_axi_gmem2_b0_bresp=2,
    BITSIZE_m_axi_gmem2_b0_buser=1,
    BITSIZE_m_axi_gmem2_b0_rid=1,
    BITSIZE_m_axi_gmem2_b0_rdata=1,
    BITSIZE_m_axi_gmem2_b0_rresp=2,
    BITSIZE_m_axi_gmem2_b0_ruser=1,
    BITSIZE_m_axi_gmem2_b0_awid=1,
    BITSIZE_m_axi_gmem2_b0_awaddr=1,
    BITSIZE_m_axi_gmem2_b0_awlen=1,
    BITSIZE_m_axi_gmem2_b0_awsize=1,
    BITSIZE_m_axi_gmem2_b0_awburst=2,
    BITSIZE_m_axi_gmem2_b0_awlock=1,
    BITSIZE_m_axi_gmem2_b0_awcache=1,
    BITSIZE_m_axi_gmem2_b0_awprot=1,
    BITSIZE_m_axi_gmem2_b0_awqos=1,
    BITSIZE_m_axi_gmem2_b0_awregion=1,
    BITSIZE_m_axi_gmem2_b0_awuser=1,
    BITSIZE_m_axi_gmem2_b0_wdata=1,
    BITSIZE_m_axi_gmem2_b0_wstrb=1,
    BITSIZE_m_axi_gmem2_b0_wuser=1,
    BITSIZE_m_axi_gmem2_b0_arid=1,
    BITSIZE_m_axi_gmem2_b0_araddr=1,
    BITSIZE_m_axi_gmem2_b0_arlen=1,
    BITSIZE_m_axi_gmem2_b0_arsize=1,
    BITSIZE_m_axi_gmem2_b0_arburst=2,
    BITSIZE_m_axi_gmem2_b0_arlock=1,
    BITSIZE_m_axi_gmem2_b0_arcache=1,
    BITSIZE_m_axi_gmem2_b0_arprot=1,
    BITSIZE_m_axi_gmem2_b0_arqos=1,
    BITSIZE_m_axi_gmem2_b0_arregion=1,
    BITSIZE_m_axi_gmem2_b0_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem2_b0_awid-1:0] m_axi_gmem2_b0_awid;
  input [BITSIZE_m_axi_gmem2_b0_awaddr-1:0] m_axi_gmem2_b0_awaddr;
  input [BITSIZE_m_axi_gmem2_b0_awlen-1:0] m_axi_gmem2_b0_awlen;
  input [BITSIZE_m_axi_gmem2_b0_awsize-1:0] m_axi_gmem2_b0_awsize;
  input [BITSIZE_m_axi_gmem2_b0_awburst-1:0] m_axi_gmem2_b0_awburst;
  input [BITSIZE_m_axi_gmem2_b0_awlock-1:0] m_axi_gmem2_b0_awlock;
  input [BITSIZE_m_axi_gmem2_b0_awcache-1:0] m_axi_gmem2_b0_awcache;
  input [BITSIZE_m_axi_gmem2_b0_awprot-1:0] m_axi_gmem2_b0_awprot;
  input [BITSIZE_m_axi_gmem2_b0_awqos-1:0] m_axi_gmem2_b0_awqos;
  input [BITSIZE_m_axi_gmem2_b0_awregion-1:0] m_axi_gmem2_b0_awregion;
  input [BITSIZE_m_axi_gmem2_b0_awuser-1:0] m_axi_gmem2_b0_awuser;
  input m_axi_gmem2_b0_awvalid;
  input [BITSIZE_m_axi_gmem2_b0_wdata-1:0] m_axi_gmem2_b0_wdata;
  input [BITSIZE_m_axi_gmem2_b0_wstrb-1:0] m_axi_gmem2_b0_wstrb;
  input m_axi_gmem2_b0_wlast;
  input [BITSIZE_m_axi_gmem2_b0_wuser-1:0] m_axi_gmem2_b0_wuser;
  input m_axi_gmem2_b0_wvalid;
  input m_axi_gmem2_b0_bready;
  input [BITSIZE_m_axi_gmem2_b0_arid-1:0] m_axi_gmem2_b0_arid;
  input [BITSIZE_m_axi_gmem2_b0_araddr-1:0] m_axi_gmem2_b0_araddr;
  input [BITSIZE_m_axi_gmem2_b0_arlen-1:0] m_axi_gmem2_b0_arlen;
  input [BITSIZE_m_axi_gmem2_b0_arsize-1:0] m_axi_gmem2_b0_arsize;
  input [BITSIZE_m_axi_gmem2_b0_arburst-1:0] m_axi_gmem2_b0_arburst;
  input [BITSIZE_m_axi_gmem2_b0_arlock-1:0] m_axi_gmem2_b0_arlock;
  input [BITSIZE_m_axi_gmem2_b0_arcache-1:0] m_axi_gmem2_b0_arcache;
  input [BITSIZE_m_axi_gmem2_b0_arprot-1:0] m_axi_gmem2_b0_arprot;
  input [BITSIZE_m_axi_gmem2_b0_arqos-1:0] m_axi_gmem2_b0_arqos;
  input [BITSIZE_m_axi_gmem2_b0_arregion-1:0] m_axi_gmem2_b0_arregion;
  input [BITSIZE_m_axi_gmem2_b0_aruser-1:0] m_axi_gmem2_b0_aruser;
  input m_axi_gmem2_b0_arvalid;
  input m_axi_gmem2_b0_rready;
  // OUT
  output m_axi_gmem2_b0_awready;
  output m_axi_gmem2_b0_wready;
  output [BITSIZE_m_axi_gmem2_b0_bid-1:0] m_axi_gmem2_b0_bid;
  output [BITSIZE_m_axi_gmem2_b0_bresp-1:0] m_axi_gmem2_b0_bresp;
  output [BITSIZE_m_axi_gmem2_b0_buser-1:0] m_axi_gmem2_b0_buser;
  output m_axi_gmem2_b0_bvalid;
  output m_axi_gmem2_b0_arready;
  output [BITSIZE_m_axi_gmem2_b0_rid-1:0] m_axi_gmem2_b0_rid;
  output [BITSIZE_m_axi_gmem2_b0_rdata-1:0] m_axi_gmem2_b0_rdata;
  output [BITSIZE_m_axi_gmem2_b0_rresp-1:0] m_axi_gmem2_b0_rresp;
  output m_axi_gmem2_b0_rlast;
  output [BITSIZE_m_axi_gmem2_b0_ruser-1:0] m_axi_gmem2_b0_ruser;
  output m_axi_gmem2_b0_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem2_b0_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem2_b0_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem2_b0_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem2_b0_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem2_b0_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem2_b0_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem2_b0_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem2_b0_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem2_b0_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem2_b0_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem2_b0_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem2_b0_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem2_b0_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem2_b0_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem2_b0_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem2_b0_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem2_b0_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem2_b0_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem2_b0_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem2_b0_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem2_b0_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem2_b0_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem2_b0_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem2_b0_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem2_b0_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem2_b0_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem2_b0_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem2_b0_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem2_b0_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem2_b0_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem2_b0_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem2_b0_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem2_b0_awready=awready;
  assign m_axi_gmem2_b0_wready=wready;
  assign m_axi_gmem2_b0_bid=bid;
  assign m_axi_gmem2_b0_bresp=bresp;
  assign m_axi_gmem2_b0_buser=buser;
  assign m_axi_gmem2_b0_bvalid=bvalid;
  assign m_axi_gmem2_b0_arready=arready;
  assign m_axi_gmem2_b0_rid=rid;
  assign m_axi_gmem2_b0_rdata=rdata;
  assign m_axi_gmem2_b0_rresp=rresp;
  assign m_axi_gmem2_b0_rlast=rlast;
  assign m_axi_gmem2_b0_ruser=ruser;
  assign m_axi_gmem2_b0_rvalid=rvalid;
  assign awid=m_axi_gmem2_b0_awid;
  assign awaddr=m_axi_gmem2_b0_awaddr;
  assign awlen=m_axi_gmem2_b0_awlen;
  assign awsize=m_axi_gmem2_b0_awsize;
  assign awburst=m_axi_gmem2_b0_awburst;
  assign awlock=m_axi_gmem2_b0_awlock;
  assign awcache=m_axi_gmem2_b0_awcache;
  assign awprot=m_axi_gmem2_b0_awprot;
  assign awqos=m_axi_gmem2_b0_awqos;
  assign awregion=m_axi_gmem2_b0_awregion;
  assign awuser=m_axi_gmem2_b0_awuser;
  assign awvalid=m_axi_gmem2_b0_awvalid;
  assign wdata=m_axi_gmem2_b0_wdata;
  assign wstrb=m_axi_gmem2_b0_wstrb;
  assign wlast=m_axi_gmem2_b0_wlast;
  assign wuser=m_axi_gmem2_b0_wuser;
  assign wvalid=m_axi_gmem2_b0_wvalid;
  assign bready=m_axi_gmem2_b0_bready;
  assign arid=m_axi_gmem2_b0_arid;
  assign araddr=m_axi_gmem2_b0_araddr;
  assign arlen=m_axi_gmem2_b0_arlen;
  assign arsize=m_axi_gmem2_b0_arsize;
  assign arburst=m_axi_gmem2_b0_arburst;
  assign arlock=m_axi_gmem2_b0_arlock;
  assign arcache=m_axi_gmem2_b0_arcache;
  assign arprot=m_axi_gmem2_b0_arprot;
  assign arqos=m_axi_gmem2_b0_arqos;
  assign arregion=m_axi_gmem2_b0_arregion;
  assign aruser=m_axi_gmem2_b0_aruser;
  assign arvalid=m_axi_gmem2_b0_arvalid;
  assign rready=m_axi_gmem2_b0_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem2_b0_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem2_b0_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem2_b0_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem2_b0_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem2_b0_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem2_b0_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem2_b0_arid,
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
module if_m_axi_gmem2_b1(clock,
  reset,
  done_port,
  m_axi_gmem2_b1_awready,
  m_axi_gmem2_b1_wready,
  m_axi_gmem2_b1_bid,
  m_axi_gmem2_b1_bresp,
  m_axi_gmem2_b1_buser,
  m_axi_gmem2_b1_bvalid,
  m_axi_gmem2_b1_arready,
  m_axi_gmem2_b1_rid,
  m_axi_gmem2_b1_rdata,
  m_axi_gmem2_b1_rresp,
  m_axi_gmem2_b1_rlast,
  m_axi_gmem2_b1_ruser,
  m_axi_gmem2_b1_rvalid,
  m_axi_gmem2_b1_awid,
  m_axi_gmem2_b1_awaddr,
  m_axi_gmem2_b1_awlen,
  m_axi_gmem2_b1_awsize,
  m_axi_gmem2_b1_awburst,
  m_axi_gmem2_b1_awlock,
  m_axi_gmem2_b1_awcache,
  m_axi_gmem2_b1_awprot,
  m_axi_gmem2_b1_awqos,
  m_axi_gmem2_b1_awregion,
  m_axi_gmem2_b1_awuser,
  m_axi_gmem2_b1_awvalid,
  m_axi_gmem2_b1_wdata,
  m_axi_gmem2_b1_wstrb,
  m_axi_gmem2_b1_wlast,
  m_axi_gmem2_b1_wuser,
  m_axi_gmem2_b1_wvalid,
  m_axi_gmem2_b1_bready,
  m_axi_gmem2_b1_arid,
  m_axi_gmem2_b1_araddr,
  m_axi_gmem2_b1_arlen,
  m_axi_gmem2_b1_arsize,
  m_axi_gmem2_b1_arburst,
  m_axi_gmem2_b1_arlock,
  m_axi_gmem2_b1_arcache,
  m_axi_gmem2_b1_arprot,
  m_axi_gmem2_b1_arqos,
  m_axi_gmem2_b1_arregion,
  m_axi_gmem2_b1_aruser,
  m_axi_gmem2_b1_arvalid,
  m_axi_gmem2_b1_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem2_b1_bid=1,
    BITSIZE_m_axi_gmem2_b1_bresp=2,
    BITSIZE_m_axi_gmem2_b1_buser=1,
    BITSIZE_m_axi_gmem2_b1_rid=1,
    BITSIZE_m_axi_gmem2_b1_rdata=1,
    BITSIZE_m_axi_gmem2_b1_rresp=2,
    BITSIZE_m_axi_gmem2_b1_ruser=1,
    BITSIZE_m_axi_gmem2_b1_awid=1,
    BITSIZE_m_axi_gmem2_b1_awaddr=1,
    BITSIZE_m_axi_gmem2_b1_awlen=1,
    BITSIZE_m_axi_gmem2_b1_awsize=1,
    BITSIZE_m_axi_gmem2_b1_awburst=2,
    BITSIZE_m_axi_gmem2_b1_awlock=1,
    BITSIZE_m_axi_gmem2_b1_awcache=1,
    BITSIZE_m_axi_gmem2_b1_awprot=1,
    BITSIZE_m_axi_gmem2_b1_awqos=1,
    BITSIZE_m_axi_gmem2_b1_awregion=1,
    BITSIZE_m_axi_gmem2_b1_awuser=1,
    BITSIZE_m_axi_gmem2_b1_wdata=1,
    BITSIZE_m_axi_gmem2_b1_wstrb=1,
    BITSIZE_m_axi_gmem2_b1_wuser=1,
    BITSIZE_m_axi_gmem2_b1_arid=1,
    BITSIZE_m_axi_gmem2_b1_araddr=1,
    BITSIZE_m_axi_gmem2_b1_arlen=1,
    BITSIZE_m_axi_gmem2_b1_arsize=1,
    BITSIZE_m_axi_gmem2_b1_arburst=2,
    BITSIZE_m_axi_gmem2_b1_arlock=1,
    BITSIZE_m_axi_gmem2_b1_arcache=1,
    BITSIZE_m_axi_gmem2_b1_arprot=1,
    BITSIZE_m_axi_gmem2_b1_arqos=1,
    BITSIZE_m_axi_gmem2_b1_arregion=1,
    BITSIZE_m_axi_gmem2_b1_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem2_b1_awid-1:0] m_axi_gmem2_b1_awid;
  input [BITSIZE_m_axi_gmem2_b1_awaddr-1:0] m_axi_gmem2_b1_awaddr;
  input [BITSIZE_m_axi_gmem2_b1_awlen-1:0] m_axi_gmem2_b1_awlen;
  input [BITSIZE_m_axi_gmem2_b1_awsize-1:0] m_axi_gmem2_b1_awsize;
  input [BITSIZE_m_axi_gmem2_b1_awburst-1:0] m_axi_gmem2_b1_awburst;
  input [BITSIZE_m_axi_gmem2_b1_awlock-1:0] m_axi_gmem2_b1_awlock;
  input [BITSIZE_m_axi_gmem2_b1_awcache-1:0] m_axi_gmem2_b1_awcache;
  input [BITSIZE_m_axi_gmem2_b1_awprot-1:0] m_axi_gmem2_b1_awprot;
  input [BITSIZE_m_axi_gmem2_b1_awqos-1:0] m_axi_gmem2_b1_awqos;
  input [BITSIZE_m_axi_gmem2_b1_awregion-1:0] m_axi_gmem2_b1_awregion;
  input [BITSIZE_m_axi_gmem2_b1_awuser-1:0] m_axi_gmem2_b1_awuser;
  input m_axi_gmem2_b1_awvalid;
  input [BITSIZE_m_axi_gmem2_b1_wdata-1:0] m_axi_gmem2_b1_wdata;
  input [BITSIZE_m_axi_gmem2_b1_wstrb-1:0] m_axi_gmem2_b1_wstrb;
  input m_axi_gmem2_b1_wlast;
  input [BITSIZE_m_axi_gmem2_b1_wuser-1:0] m_axi_gmem2_b1_wuser;
  input m_axi_gmem2_b1_wvalid;
  input m_axi_gmem2_b1_bready;
  input [BITSIZE_m_axi_gmem2_b1_arid-1:0] m_axi_gmem2_b1_arid;
  input [BITSIZE_m_axi_gmem2_b1_araddr-1:0] m_axi_gmem2_b1_araddr;
  input [BITSIZE_m_axi_gmem2_b1_arlen-1:0] m_axi_gmem2_b1_arlen;
  input [BITSIZE_m_axi_gmem2_b1_arsize-1:0] m_axi_gmem2_b1_arsize;
  input [BITSIZE_m_axi_gmem2_b1_arburst-1:0] m_axi_gmem2_b1_arburst;
  input [BITSIZE_m_axi_gmem2_b1_arlock-1:0] m_axi_gmem2_b1_arlock;
  input [BITSIZE_m_axi_gmem2_b1_arcache-1:0] m_axi_gmem2_b1_arcache;
  input [BITSIZE_m_axi_gmem2_b1_arprot-1:0] m_axi_gmem2_b1_arprot;
  input [BITSIZE_m_axi_gmem2_b1_arqos-1:0] m_axi_gmem2_b1_arqos;
  input [BITSIZE_m_axi_gmem2_b1_arregion-1:0] m_axi_gmem2_b1_arregion;
  input [BITSIZE_m_axi_gmem2_b1_aruser-1:0] m_axi_gmem2_b1_aruser;
  input m_axi_gmem2_b1_arvalid;
  input m_axi_gmem2_b1_rready;
  // OUT
  output m_axi_gmem2_b1_awready;
  output m_axi_gmem2_b1_wready;
  output [BITSIZE_m_axi_gmem2_b1_bid-1:0] m_axi_gmem2_b1_bid;
  output [BITSIZE_m_axi_gmem2_b1_bresp-1:0] m_axi_gmem2_b1_bresp;
  output [BITSIZE_m_axi_gmem2_b1_buser-1:0] m_axi_gmem2_b1_buser;
  output m_axi_gmem2_b1_bvalid;
  output m_axi_gmem2_b1_arready;
  output [BITSIZE_m_axi_gmem2_b1_rid-1:0] m_axi_gmem2_b1_rid;
  output [BITSIZE_m_axi_gmem2_b1_rdata-1:0] m_axi_gmem2_b1_rdata;
  output [BITSIZE_m_axi_gmem2_b1_rresp-1:0] m_axi_gmem2_b1_rresp;
  output m_axi_gmem2_b1_rlast;
  output [BITSIZE_m_axi_gmem2_b1_ruser-1:0] m_axi_gmem2_b1_ruser;
  output m_axi_gmem2_b1_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem2_b1_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem2_b1_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem2_b1_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem2_b1_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem2_b1_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem2_b1_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem2_b1_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem2_b1_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem2_b1_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem2_b1_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem2_b1_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem2_b1_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem2_b1_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem2_b1_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem2_b1_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem2_b1_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem2_b1_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem2_b1_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem2_b1_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem2_b1_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem2_b1_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem2_b1_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem2_b1_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem2_b1_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem2_b1_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem2_b1_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem2_b1_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem2_b1_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem2_b1_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem2_b1_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem2_b1_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem2_b1_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem2_b1_awready=awready;
  assign m_axi_gmem2_b1_wready=wready;
  assign m_axi_gmem2_b1_bid=bid;
  assign m_axi_gmem2_b1_bresp=bresp;
  assign m_axi_gmem2_b1_buser=buser;
  assign m_axi_gmem2_b1_bvalid=bvalid;
  assign m_axi_gmem2_b1_arready=arready;
  assign m_axi_gmem2_b1_rid=rid;
  assign m_axi_gmem2_b1_rdata=rdata;
  assign m_axi_gmem2_b1_rresp=rresp;
  assign m_axi_gmem2_b1_rlast=rlast;
  assign m_axi_gmem2_b1_ruser=ruser;
  assign m_axi_gmem2_b1_rvalid=rvalid;
  assign awid=m_axi_gmem2_b1_awid;
  assign awaddr=m_axi_gmem2_b1_awaddr;
  assign awlen=m_axi_gmem2_b1_awlen;
  assign awsize=m_axi_gmem2_b1_awsize;
  assign awburst=m_axi_gmem2_b1_awburst;
  assign awlock=m_axi_gmem2_b1_awlock;
  assign awcache=m_axi_gmem2_b1_awcache;
  assign awprot=m_axi_gmem2_b1_awprot;
  assign awqos=m_axi_gmem2_b1_awqos;
  assign awregion=m_axi_gmem2_b1_awregion;
  assign awuser=m_axi_gmem2_b1_awuser;
  assign awvalid=m_axi_gmem2_b1_awvalid;
  assign wdata=m_axi_gmem2_b1_wdata;
  assign wstrb=m_axi_gmem2_b1_wstrb;
  assign wlast=m_axi_gmem2_b1_wlast;
  assign wuser=m_axi_gmem2_b1_wuser;
  assign wvalid=m_axi_gmem2_b1_wvalid;
  assign bready=m_axi_gmem2_b1_bready;
  assign arid=m_axi_gmem2_b1_arid;
  assign araddr=m_axi_gmem2_b1_araddr;
  assign arlen=m_axi_gmem2_b1_arlen;
  assign arsize=m_axi_gmem2_b1_arsize;
  assign arburst=m_axi_gmem2_b1_arburst;
  assign arlock=m_axi_gmem2_b1_arlock;
  assign arcache=m_axi_gmem2_b1_arcache;
  assign arprot=m_axi_gmem2_b1_arprot;
  assign arqos=m_axi_gmem2_b1_arqos;
  assign arregion=m_axi_gmem2_b1_arregion;
  assign aruser=m_axi_gmem2_b1_aruser;
  assign arvalid=m_axi_gmem2_b1_arvalid;
  assign rready=m_axi_gmem2_b1_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem2_b1_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem2_b1_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem2_b1_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem2_b1_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem2_b1_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem2_b1_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem2_b1_arid,
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
module if_m_axi_gmem2_b2(clock,
  reset,
  done_port,
  m_axi_gmem2_b2_awready,
  m_axi_gmem2_b2_wready,
  m_axi_gmem2_b2_bid,
  m_axi_gmem2_b2_bresp,
  m_axi_gmem2_b2_buser,
  m_axi_gmem2_b2_bvalid,
  m_axi_gmem2_b2_arready,
  m_axi_gmem2_b2_rid,
  m_axi_gmem2_b2_rdata,
  m_axi_gmem2_b2_rresp,
  m_axi_gmem2_b2_rlast,
  m_axi_gmem2_b2_ruser,
  m_axi_gmem2_b2_rvalid,
  m_axi_gmem2_b2_awid,
  m_axi_gmem2_b2_awaddr,
  m_axi_gmem2_b2_awlen,
  m_axi_gmem2_b2_awsize,
  m_axi_gmem2_b2_awburst,
  m_axi_gmem2_b2_awlock,
  m_axi_gmem2_b2_awcache,
  m_axi_gmem2_b2_awprot,
  m_axi_gmem2_b2_awqos,
  m_axi_gmem2_b2_awregion,
  m_axi_gmem2_b2_awuser,
  m_axi_gmem2_b2_awvalid,
  m_axi_gmem2_b2_wdata,
  m_axi_gmem2_b2_wstrb,
  m_axi_gmem2_b2_wlast,
  m_axi_gmem2_b2_wuser,
  m_axi_gmem2_b2_wvalid,
  m_axi_gmem2_b2_bready,
  m_axi_gmem2_b2_arid,
  m_axi_gmem2_b2_araddr,
  m_axi_gmem2_b2_arlen,
  m_axi_gmem2_b2_arsize,
  m_axi_gmem2_b2_arburst,
  m_axi_gmem2_b2_arlock,
  m_axi_gmem2_b2_arcache,
  m_axi_gmem2_b2_arprot,
  m_axi_gmem2_b2_arqos,
  m_axi_gmem2_b2_arregion,
  m_axi_gmem2_b2_aruser,
  m_axi_gmem2_b2_arvalid,
  m_axi_gmem2_b2_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem2_b2_bid=1,
    BITSIZE_m_axi_gmem2_b2_bresp=2,
    BITSIZE_m_axi_gmem2_b2_buser=1,
    BITSIZE_m_axi_gmem2_b2_rid=1,
    BITSIZE_m_axi_gmem2_b2_rdata=1,
    BITSIZE_m_axi_gmem2_b2_rresp=2,
    BITSIZE_m_axi_gmem2_b2_ruser=1,
    BITSIZE_m_axi_gmem2_b2_awid=1,
    BITSIZE_m_axi_gmem2_b2_awaddr=1,
    BITSIZE_m_axi_gmem2_b2_awlen=1,
    BITSIZE_m_axi_gmem2_b2_awsize=1,
    BITSIZE_m_axi_gmem2_b2_awburst=2,
    BITSIZE_m_axi_gmem2_b2_awlock=1,
    BITSIZE_m_axi_gmem2_b2_awcache=1,
    BITSIZE_m_axi_gmem2_b2_awprot=1,
    BITSIZE_m_axi_gmem2_b2_awqos=1,
    BITSIZE_m_axi_gmem2_b2_awregion=1,
    BITSIZE_m_axi_gmem2_b2_awuser=1,
    BITSIZE_m_axi_gmem2_b2_wdata=1,
    BITSIZE_m_axi_gmem2_b2_wstrb=1,
    BITSIZE_m_axi_gmem2_b2_wuser=1,
    BITSIZE_m_axi_gmem2_b2_arid=1,
    BITSIZE_m_axi_gmem2_b2_araddr=1,
    BITSIZE_m_axi_gmem2_b2_arlen=1,
    BITSIZE_m_axi_gmem2_b2_arsize=1,
    BITSIZE_m_axi_gmem2_b2_arburst=2,
    BITSIZE_m_axi_gmem2_b2_arlock=1,
    BITSIZE_m_axi_gmem2_b2_arcache=1,
    BITSIZE_m_axi_gmem2_b2_arprot=1,
    BITSIZE_m_axi_gmem2_b2_arqos=1,
    BITSIZE_m_axi_gmem2_b2_arregion=1,
    BITSIZE_m_axi_gmem2_b2_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem2_b2_awid-1:0] m_axi_gmem2_b2_awid;
  input [BITSIZE_m_axi_gmem2_b2_awaddr-1:0] m_axi_gmem2_b2_awaddr;
  input [BITSIZE_m_axi_gmem2_b2_awlen-1:0] m_axi_gmem2_b2_awlen;
  input [BITSIZE_m_axi_gmem2_b2_awsize-1:0] m_axi_gmem2_b2_awsize;
  input [BITSIZE_m_axi_gmem2_b2_awburst-1:0] m_axi_gmem2_b2_awburst;
  input [BITSIZE_m_axi_gmem2_b2_awlock-1:0] m_axi_gmem2_b2_awlock;
  input [BITSIZE_m_axi_gmem2_b2_awcache-1:0] m_axi_gmem2_b2_awcache;
  input [BITSIZE_m_axi_gmem2_b2_awprot-1:0] m_axi_gmem2_b2_awprot;
  input [BITSIZE_m_axi_gmem2_b2_awqos-1:0] m_axi_gmem2_b2_awqos;
  input [BITSIZE_m_axi_gmem2_b2_awregion-1:0] m_axi_gmem2_b2_awregion;
  input [BITSIZE_m_axi_gmem2_b2_awuser-1:0] m_axi_gmem2_b2_awuser;
  input m_axi_gmem2_b2_awvalid;
  input [BITSIZE_m_axi_gmem2_b2_wdata-1:0] m_axi_gmem2_b2_wdata;
  input [BITSIZE_m_axi_gmem2_b2_wstrb-1:0] m_axi_gmem2_b2_wstrb;
  input m_axi_gmem2_b2_wlast;
  input [BITSIZE_m_axi_gmem2_b2_wuser-1:0] m_axi_gmem2_b2_wuser;
  input m_axi_gmem2_b2_wvalid;
  input m_axi_gmem2_b2_bready;
  input [BITSIZE_m_axi_gmem2_b2_arid-1:0] m_axi_gmem2_b2_arid;
  input [BITSIZE_m_axi_gmem2_b2_araddr-1:0] m_axi_gmem2_b2_araddr;
  input [BITSIZE_m_axi_gmem2_b2_arlen-1:0] m_axi_gmem2_b2_arlen;
  input [BITSIZE_m_axi_gmem2_b2_arsize-1:0] m_axi_gmem2_b2_arsize;
  input [BITSIZE_m_axi_gmem2_b2_arburst-1:0] m_axi_gmem2_b2_arburst;
  input [BITSIZE_m_axi_gmem2_b2_arlock-1:0] m_axi_gmem2_b2_arlock;
  input [BITSIZE_m_axi_gmem2_b2_arcache-1:0] m_axi_gmem2_b2_arcache;
  input [BITSIZE_m_axi_gmem2_b2_arprot-1:0] m_axi_gmem2_b2_arprot;
  input [BITSIZE_m_axi_gmem2_b2_arqos-1:0] m_axi_gmem2_b2_arqos;
  input [BITSIZE_m_axi_gmem2_b2_arregion-1:0] m_axi_gmem2_b2_arregion;
  input [BITSIZE_m_axi_gmem2_b2_aruser-1:0] m_axi_gmem2_b2_aruser;
  input m_axi_gmem2_b2_arvalid;
  input m_axi_gmem2_b2_rready;
  // OUT
  output m_axi_gmem2_b2_awready;
  output m_axi_gmem2_b2_wready;
  output [BITSIZE_m_axi_gmem2_b2_bid-1:0] m_axi_gmem2_b2_bid;
  output [BITSIZE_m_axi_gmem2_b2_bresp-1:0] m_axi_gmem2_b2_bresp;
  output [BITSIZE_m_axi_gmem2_b2_buser-1:0] m_axi_gmem2_b2_buser;
  output m_axi_gmem2_b2_bvalid;
  output m_axi_gmem2_b2_arready;
  output [BITSIZE_m_axi_gmem2_b2_rid-1:0] m_axi_gmem2_b2_rid;
  output [BITSIZE_m_axi_gmem2_b2_rdata-1:0] m_axi_gmem2_b2_rdata;
  output [BITSIZE_m_axi_gmem2_b2_rresp-1:0] m_axi_gmem2_b2_rresp;
  output m_axi_gmem2_b2_rlast;
  output [BITSIZE_m_axi_gmem2_b2_ruser-1:0] m_axi_gmem2_b2_ruser;
  output m_axi_gmem2_b2_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem2_b2_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem2_b2_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem2_b2_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem2_b2_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem2_b2_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem2_b2_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem2_b2_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem2_b2_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem2_b2_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem2_b2_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem2_b2_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem2_b2_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem2_b2_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem2_b2_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem2_b2_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem2_b2_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem2_b2_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem2_b2_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem2_b2_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem2_b2_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem2_b2_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem2_b2_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem2_b2_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem2_b2_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem2_b2_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem2_b2_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem2_b2_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem2_b2_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem2_b2_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem2_b2_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem2_b2_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem2_b2_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem2_b2_awready=awready;
  assign m_axi_gmem2_b2_wready=wready;
  assign m_axi_gmem2_b2_bid=bid;
  assign m_axi_gmem2_b2_bresp=bresp;
  assign m_axi_gmem2_b2_buser=buser;
  assign m_axi_gmem2_b2_bvalid=bvalid;
  assign m_axi_gmem2_b2_arready=arready;
  assign m_axi_gmem2_b2_rid=rid;
  assign m_axi_gmem2_b2_rdata=rdata;
  assign m_axi_gmem2_b2_rresp=rresp;
  assign m_axi_gmem2_b2_rlast=rlast;
  assign m_axi_gmem2_b2_ruser=ruser;
  assign m_axi_gmem2_b2_rvalid=rvalid;
  assign awid=m_axi_gmem2_b2_awid;
  assign awaddr=m_axi_gmem2_b2_awaddr;
  assign awlen=m_axi_gmem2_b2_awlen;
  assign awsize=m_axi_gmem2_b2_awsize;
  assign awburst=m_axi_gmem2_b2_awburst;
  assign awlock=m_axi_gmem2_b2_awlock;
  assign awcache=m_axi_gmem2_b2_awcache;
  assign awprot=m_axi_gmem2_b2_awprot;
  assign awqos=m_axi_gmem2_b2_awqos;
  assign awregion=m_axi_gmem2_b2_awregion;
  assign awuser=m_axi_gmem2_b2_awuser;
  assign awvalid=m_axi_gmem2_b2_awvalid;
  assign wdata=m_axi_gmem2_b2_wdata;
  assign wstrb=m_axi_gmem2_b2_wstrb;
  assign wlast=m_axi_gmem2_b2_wlast;
  assign wuser=m_axi_gmem2_b2_wuser;
  assign wvalid=m_axi_gmem2_b2_wvalid;
  assign bready=m_axi_gmem2_b2_bready;
  assign arid=m_axi_gmem2_b2_arid;
  assign araddr=m_axi_gmem2_b2_araddr;
  assign arlen=m_axi_gmem2_b2_arlen;
  assign arsize=m_axi_gmem2_b2_arsize;
  assign arburst=m_axi_gmem2_b2_arburst;
  assign arlock=m_axi_gmem2_b2_arlock;
  assign arcache=m_axi_gmem2_b2_arcache;
  assign arprot=m_axi_gmem2_b2_arprot;
  assign arqos=m_axi_gmem2_b2_arqos;
  assign arregion=m_axi_gmem2_b2_arregion;
  assign aruser=m_axi_gmem2_b2_aruser;
  assign arvalid=m_axi_gmem2_b2_arvalid;
  assign rready=m_axi_gmem2_b2_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem2_b2_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem2_b2_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem2_b2_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem2_b2_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem2_b2_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem2_b2_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem2_b2_arid,
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
module if_m_axi_gmem2_b3(clock,
  reset,
  done_port,
  m_axi_gmem2_b3_awready,
  m_axi_gmem2_b3_wready,
  m_axi_gmem2_b3_bid,
  m_axi_gmem2_b3_bresp,
  m_axi_gmem2_b3_buser,
  m_axi_gmem2_b3_bvalid,
  m_axi_gmem2_b3_arready,
  m_axi_gmem2_b3_rid,
  m_axi_gmem2_b3_rdata,
  m_axi_gmem2_b3_rresp,
  m_axi_gmem2_b3_rlast,
  m_axi_gmem2_b3_ruser,
  m_axi_gmem2_b3_rvalid,
  m_axi_gmem2_b3_awid,
  m_axi_gmem2_b3_awaddr,
  m_axi_gmem2_b3_awlen,
  m_axi_gmem2_b3_awsize,
  m_axi_gmem2_b3_awburst,
  m_axi_gmem2_b3_awlock,
  m_axi_gmem2_b3_awcache,
  m_axi_gmem2_b3_awprot,
  m_axi_gmem2_b3_awqos,
  m_axi_gmem2_b3_awregion,
  m_axi_gmem2_b3_awuser,
  m_axi_gmem2_b3_awvalid,
  m_axi_gmem2_b3_wdata,
  m_axi_gmem2_b3_wstrb,
  m_axi_gmem2_b3_wlast,
  m_axi_gmem2_b3_wuser,
  m_axi_gmem2_b3_wvalid,
  m_axi_gmem2_b3_bready,
  m_axi_gmem2_b3_arid,
  m_axi_gmem2_b3_araddr,
  m_axi_gmem2_b3_arlen,
  m_axi_gmem2_b3_arsize,
  m_axi_gmem2_b3_arburst,
  m_axi_gmem2_b3_arlock,
  m_axi_gmem2_b3_arcache,
  m_axi_gmem2_b3_arprot,
  m_axi_gmem2_b3_arqos,
  m_axi_gmem2_b3_arregion,
  m_axi_gmem2_b3_aruser,
  m_axi_gmem2_b3_arvalid,
  m_axi_gmem2_b3_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem2_b3_bid=1,
    BITSIZE_m_axi_gmem2_b3_bresp=2,
    BITSIZE_m_axi_gmem2_b3_buser=1,
    BITSIZE_m_axi_gmem2_b3_rid=1,
    BITSIZE_m_axi_gmem2_b3_rdata=1,
    BITSIZE_m_axi_gmem2_b3_rresp=2,
    BITSIZE_m_axi_gmem2_b3_ruser=1,
    BITSIZE_m_axi_gmem2_b3_awid=1,
    BITSIZE_m_axi_gmem2_b3_awaddr=1,
    BITSIZE_m_axi_gmem2_b3_awlen=1,
    BITSIZE_m_axi_gmem2_b3_awsize=1,
    BITSIZE_m_axi_gmem2_b3_awburst=2,
    BITSIZE_m_axi_gmem2_b3_awlock=1,
    BITSIZE_m_axi_gmem2_b3_awcache=1,
    BITSIZE_m_axi_gmem2_b3_awprot=1,
    BITSIZE_m_axi_gmem2_b3_awqos=1,
    BITSIZE_m_axi_gmem2_b3_awregion=1,
    BITSIZE_m_axi_gmem2_b3_awuser=1,
    BITSIZE_m_axi_gmem2_b3_wdata=1,
    BITSIZE_m_axi_gmem2_b3_wstrb=1,
    BITSIZE_m_axi_gmem2_b3_wuser=1,
    BITSIZE_m_axi_gmem2_b3_arid=1,
    BITSIZE_m_axi_gmem2_b3_araddr=1,
    BITSIZE_m_axi_gmem2_b3_arlen=1,
    BITSIZE_m_axi_gmem2_b3_arsize=1,
    BITSIZE_m_axi_gmem2_b3_arburst=2,
    BITSIZE_m_axi_gmem2_b3_arlock=1,
    BITSIZE_m_axi_gmem2_b3_arcache=1,
    BITSIZE_m_axi_gmem2_b3_arprot=1,
    BITSIZE_m_axi_gmem2_b3_arqos=1,
    BITSIZE_m_axi_gmem2_b3_arregion=1,
    BITSIZE_m_axi_gmem2_b3_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem2_b3_awid-1:0] m_axi_gmem2_b3_awid;
  input [BITSIZE_m_axi_gmem2_b3_awaddr-1:0] m_axi_gmem2_b3_awaddr;
  input [BITSIZE_m_axi_gmem2_b3_awlen-1:0] m_axi_gmem2_b3_awlen;
  input [BITSIZE_m_axi_gmem2_b3_awsize-1:0] m_axi_gmem2_b3_awsize;
  input [BITSIZE_m_axi_gmem2_b3_awburst-1:0] m_axi_gmem2_b3_awburst;
  input [BITSIZE_m_axi_gmem2_b3_awlock-1:0] m_axi_gmem2_b3_awlock;
  input [BITSIZE_m_axi_gmem2_b3_awcache-1:0] m_axi_gmem2_b3_awcache;
  input [BITSIZE_m_axi_gmem2_b3_awprot-1:0] m_axi_gmem2_b3_awprot;
  input [BITSIZE_m_axi_gmem2_b3_awqos-1:0] m_axi_gmem2_b3_awqos;
  input [BITSIZE_m_axi_gmem2_b3_awregion-1:0] m_axi_gmem2_b3_awregion;
  input [BITSIZE_m_axi_gmem2_b3_awuser-1:0] m_axi_gmem2_b3_awuser;
  input m_axi_gmem2_b3_awvalid;
  input [BITSIZE_m_axi_gmem2_b3_wdata-1:0] m_axi_gmem2_b3_wdata;
  input [BITSIZE_m_axi_gmem2_b3_wstrb-1:0] m_axi_gmem2_b3_wstrb;
  input m_axi_gmem2_b3_wlast;
  input [BITSIZE_m_axi_gmem2_b3_wuser-1:0] m_axi_gmem2_b3_wuser;
  input m_axi_gmem2_b3_wvalid;
  input m_axi_gmem2_b3_bready;
  input [BITSIZE_m_axi_gmem2_b3_arid-1:0] m_axi_gmem2_b3_arid;
  input [BITSIZE_m_axi_gmem2_b3_araddr-1:0] m_axi_gmem2_b3_araddr;
  input [BITSIZE_m_axi_gmem2_b3_arlen-1:0] m_axi_gmem2_b3_arlen;
  input [BITSIZE_m_axi_gmem2_b3_arsize-1:0] m_axi_gmem2_b3_arsize;
  input [BITSIZE_m_axi_gmem2_b3_arburst-1:0] m_axi_gmem2_b3_arburst;
  input [BITSIZE_m_axi_gmem2_b3_arlock-1:0] m_axi_gmem2_b3_arlock;
  input [BITSIZE_m_axi_gmem2_b3_arcache-1:0] m_axi_gmem2_b3_arcache;
  input [BITSIZE_m_axi_gmem2_b3_arprot-1:0] m_axi_gmem2_b3_arprot;
  input [BITSIZE_m_axi_gmem2_b3_arqos-1:0] m_axi_gmem2_b3_arqos;
  input [BITSIZE_m_axi_gmem2_b3_arregion-1:0] m_axi_gmem2_b3_arregion;
  input [BITSIZE_m_axi_gmem2_b3_aruser-1:0] m_axi_gmem2_b3_aruser;
  input m_axi_gmem2_b3_arvalid;
  input m_axi_gmem2_b3_rready;
  // OUT
  output m_axi_gmem2_b3_awready;
  output m_axi_gmem2_b3_wready;
  output [BITSIZE_m_axi_gmem2_b3_bid-1:0] m_axi_gmem2_b3_bid;
  output [BITSIZE_m_axi_gmem2_b3_bresp-1:0] m_axi_gmem2_b3_bresp;
  output [BITSIZE_m_axi_gmem2_b3_buser-1:0] m_axi_gmem2_b3_buser;
  output m_axi_gmem2_b3_bvalid;
  output m_axi_gmem2_b3_arready;
  output [BITSIZE_m_axi_gmem2_b3_rid-1:0] m_axi_gmem2_b3_rid;
  output [BITSIZE_m_axi_gmem2_b3_rdata-1:0] m_axi_gmem2_b3_rdata;
  output [BITSIZE_m_axi_gmem2_b3_rresp-1:0] m_axi_gmem2_b3_rresp;
  output m_axi_gmem2_b3_rlast;
  output [BITSIZE_m_axi_gmem2_b3_ruser-1:0] m_axi_gmem2_b3_ruser;
  output m_axi_gmem2_b3_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem2_b3_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem2_b3_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem2_b3_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem2_b3_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem2_b3_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem2_b3_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem2_b3_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem2_b3_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem2_b3_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem2_b3_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem2_b3_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem2_b3_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem2_b3_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem2_b3_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem2_b3_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem2_b3_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem2_b3_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem2_b3_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem2_b3_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem2_b3_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem2_b3_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem2_b3_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem2_b3_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem2_b3_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem2_b3_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem2_b3_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem2_b3_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem2_b3_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem2_b3_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem2_b3_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem2_b3_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem2_b3_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem2_b3_awready=awready;
  assign m_axi_gmem2_b3_wready=wready;
  assign m_axi_gmem2_b3_bid=bid;
  assign m_axi_gmem2_b3_bresp=bresp;
  assign m_axi_gmem2_b3_buser=buser;
  assign m_axi_gmem2_b3_bvalid=bvalid;
  assign m_axi_gmem2_b3_arready=arready;
  assign m_axi_gmem2_b3_rid=rid;
  assign m_axi_gmem2_b3_rdata=rdata;
  assign m_axi_gmem2_b3_rresp=rresp;
  assign m_axi_gmem2_b3_rlast=rlast;
  assign m_axi_gmem2_b3_ruser=ruser;
  assign m_axi_gmem2_b3_rvalid=rvalid;
  assign awid=m_axi_gmem2_b3_awid;
  assign awaddr=m_axi_gmem2_b3_awaddr;
  assign awlen=m_axi_gmem2_b3_awlen;
  assign awsize=m_axi_gmem2_b3_awsize;
  assign awburst=m_axi_gmem2_b3_awburst;
  assign awlock=m_axi_gmem2_b3_awlock;
  assign awcache=m_axi_gmem2_b3_awcache;
  assign awprot=m_axi_gmem2_b3_awprot;
  assign awqos=m_axi_gmem2_b3_awqos;
  assign awregion=m_axi_gmem2_b3_awregion;
  assign awuser=m_axi_gmem2_b3_awuser;
  assign awvalid=m_axi_gmem2_b3_awvalid;
  assign wdata=m_axi_gmem2_b3_wdata;
  assign wstrb=m_axi_gmem2_b3_wstrb;
  assign wlast=m_axi_gmem2_b3_wlast;
  assign wuser=m_axi_gmem2_b3_wuser;
  assign wvalid=m_axi_gmem2_b3_wvalid;
  assign bready=m_axi_gmem2_b3_bready;
  assign arid=m_axi_gmem2_b3_arid;
  assign araddr=m_axi_gmem2_b3_araddr;
  assign arlen=m_axi_gmem2_b3_arlen;
  assign arsize=m_axi_gmem2_b3_arsize;
  assign arburst=m_axi_gmem2_b3_arburst;
  assign arlock=m_axi_gmem2_b3_arlock;
  assign arcache=m_axi_gmem2_b3_arcache;
  assign arprot=m_axi_gmem2_b3_arprot;
  assign arqos=m_axi_gmem2_b3_arqos;
  assign arregion=m_axi_gmem2_b3_arregion;
  assign aruser=m_axi_gmem2_b3_aruser;
  assign arvalid=m_axi_gmem2_b3_arvalid;
  assign rready=m_axi_gmem2_b3_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem2_b3_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem2_b3_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem2_b3_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem2_b3_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem2_b3_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem2_b3_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem2_b3_arid,
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
module if_m_axi_gmem2_b4(clock,
  reset,
  done_port,
  m_axi_gmem2_b4_awready,
  m_axi_gmem2_b4_wready,
  m_axi_gmem2_b4_bid,
  m_axi_gmem2_b4_bresp,
  m_axi_gmem2_b4_buser,
  m_axi_gmem2_b4_bvalid,
  m_axi_gmem2_b4_arready,
  m_axi_gmem2_b4_rid,
  m_axi_gmem2_b4_rdata,
  m_axi_gmem2_b4_rresp,
  m_axi_gmem2_b4_rlast,
  m_axi_gmem2_b4_ruser,
  m_axi_gmem2_b4_rvalid,
  m_axi_gmem2_b4_awid,
  m_axi_gmem2_b4_awaddr,
  m_axi_gmem2_b4_awlen,
  m_axi_gmem2_b4_awsize,
  m_axi_gmem2_b4_awburst,
  m_axi_gmem2_b4_awlock,
  m_axi_gmem2_b4_awcache,
  m_axi_gmem2_b4_awprot,
  m_axi_gmem2_b4_awqos,
  m_axi_gmem2_b4_awregion,
  m_axi_gmem2_b4_awuser,
  m_axi_gmem2_b4_awvalid,
  m_axi_gmem2_b4_wdata,
  m_axi_gmem2_b4_wstrb,
  m_axi_gmem2_b4_wlast,
  m_axi_gmem2_b4_wuser,
  m_axi_gmem2_b4_wvalid,
  m_axi_gmem2_b4_bready,
  m_axi_gmem2_b4_arid,
  m_axi_gmem2_b4_araddr,
  m_axi_gmem2_b4_arlen,
  m_axi_gmem2_b4_arsize,
  m_axi_gmem2_b4_arburst,
  m_axi_gmem2_b4_arlock,
  m_axi_gmem2_b4_arcache,
  m_axi_gmem2_b4_arprot,
  m_axi_gmem2_b4_arqos,
  m_axi_gmem2_b4_arregion,
  m_axi_gmem2_b4_aruser,
  m_axi_gmem2_b4_arvalid,
  m_axi_gmem2_b4_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem2_b4_bid=1,
    BITSIZE_m_axi_gmem2_b4_bresp=2,
    BITSIZE_m_axi_gmem2_b4_buser=1,
    BITSIZE_m_axi_gmem2_b4_rid=1,
    BITSIZE_m_axi_gmem2_b4_rdata=1,
    BITSIZE_m_axi_gmem2_b4_rresp=2,
    BITSIZE_m_axi_gmem2_b4_ruser=1,
    BITSIZE_m_axi_gmem2_b4_awid=1,
    BITSIZE_m_axi_gmem2_b4_awaddr=1,
    BITSIZE_m_axi_gmem2_b4_awlen=1,
    BITSIZE_m_axi_gmem2_b4_awsize=1,
    BITSIZE_m_axi_gmem2_b4_awburst=2,
    BITSIZE_m_axi_gmem2_b4_awlock=1,
    BITSIZE_m_axi_gmem2_b4_awcache=1,
    BITSIZE_m_axi_gmem2_b4_awprot=1,
    BITSIZE_m_axi_gmem2_b4_awqos=1,
    BITSIZE_m_axi_gmem2_b4_awregion=1,
    BITSIZE_m_axi_gmem2_b4_awuser=1,
    BITSIZE_m_axi_gmem2_b4_wdata=1,
    BITSIZE_m_axi_gmem2_b4_wstrb=1,
    BITSIZE_m_axi_gmem2_b4_wuser=1,
    BITSIZE_m_axi_gmem2_b4_arid=1,
    BITSIZE_m_axi_gmem2_b4_araddr=1,
    BITSIZE_m_axi_gmem2_b4_arlen=1,
    BITSIZE_m_axi_gmem2_b4_arsize=1,
    BITSIZE_m_axi_gmem2_b4_arburst=2,
    BITSIZE_m_axi_gmem2_b4_arlock=1,
    BITSIZE_m_axi_gmem2_b4_arcache=1,
    BITSIZE_m_axi_gmem2_b4_arprot=1,
    BITSIZE_m_axi_gmem2_b4_arqos=1,
    BITSIZE_m_axi_gmem2_b4_arregion=1,
    BITSIZE_m_axi_gmem2_b4_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem2_b4_awid-1:0] m_axi_gmem2_b4_awid;
  input [BITSIZE_m_axi_gmem2_b4_awaddr-1:0] m_axi_gmem2_b4_awaddr;
  input [BITSIZE_m_axi_gmem2_b4_awlen-1:0] m_axi_gmem2_b4_awlen;
  input [BITSIZE_m_axi_gmem2_b4_awsize-1:0] m_axi_gmem2_b4_awsize;
  input [BITSIZE_m_axi_gmem2_b4_awburst-1:0] m_axi_gmem2_b4_awburst;
  input [BITSIZE_m_axi_gmem2_b4_awlock-1:0] m_axi_gmem2_b4_awlock;
  input [BITSIZE_m_axi_gmem2_b4_awcache-1:0] m_axi_gmem2_b4_awcache;
  input [BITSIZE_m_axi_gmem2_b4_awprot-1:0] m_axi_gmem2_b4_awprot;
  input [BITSIZE_m_axi_gmem2_b4_awqos-1:0] m_axi_gmem2_b4_awqos;
  input [BITSIZE_m_axi_gmem2_b4_awregion-1:0] m_axi_gmem2_b4_awregion;
  input [BITSIZE_m_axi_gmem2_b4_awuser-1:0] m_axi_gmem2_b4_awuser;
  input m_axi_gmem2_b4_awvalid;
  input [BITSIZE_m_axi_gmem2_b4_wdata-1:0] m_axi_gmem2_b4_wdata;
  input [BITSIZE_m_axi_gmem2_b4_wstrb-1:0] m_axi_gmem2_b4_wstrb;
  input m_axi_gmem2_b4_wlast;
  input [BITSIZE_m_axi_gmem2_b4_wuser-1:0] m_axi_gmem2_b4_wuser;
  input m_axi_gmem2_b4_wvalid;
  input m_axi_gmem2_b4_bready;
  input [BITSIZE_m_axi_gmem2_b4_arid-1:0] m_axi_gmem2_b4_arid;
  input [BITSIZE_m_axi_gmem2_b4_araddr-1:0] m_axi_gmem2_b4_araddr;
  input [BITSIZE_m_axi_gmem2_b4_arlen-1:0] m_axi_gmem2_b4_arlen;
  input [BITSIZE_m_axi_gmem2_b4_arsize-1:0] m_axi_gmem2_b4_arsize;
  input [BITSIZE_m_axi_gmem2_b4_arburst-1:0] m_axi_gmem2_b4_arburst;
  input [BITSIZE_m_axi_gmem2_b4_arlock-1:0] m_axi_gmem2_b4_arlock;
  input [BITSIZE_m_axi_gmem2_b4_arcache-1:0] m_axi_gmem2_b4_arcache;
  input [BITSIZE_m_axi_gmem2_b4_arprot-1:0] m_axi_gmem2_b4_arprot;
  input [BITSIZE_m_axi_gmem2_b4_arqos-1:0] m_axi_gmem2_b4_arqos;
  input [BITSIZE_m_axi_gmem2_b4_arregion-1:0] m_axi_gmem2_b4_arregion;
  input [BITSIZE_m_axi_gmem2_b4_aruser-1:0] m_axi_gmem2_b4_aruser;
  input m_axi_gmem2_b4_arvalid;
  input m_axi_gmem2_b4_rready;
  // OUT
  output m_axi_gmem2_b4_awready;
  output m_axi_gmem2_b4_wready;
  output [BITSIZE_m_axi_gmem2_b4_bid-1:0] m_axi_gmem2_b4_bid;
  output [BITSIZE_m_axi_gmem2_b4_bresp-1:0] m_axi_gmem2_b4_bresp;
  output [BITSIZE_m_axi_gmem2_b4_buser-1:0] m_axi_gmem2_b4_buser;
  output m_axi_gmem2_b4_bvalid;
  output m_axi_gmem2_b4_arready;
  output [BITSIZE_m_axi_gmem2_b4_rid-1:0] m_axi_gmem2_b4_rid;
  output [BITSIZE_m_axi_gmem2_b4_rdata-1:0] m_axi_gmem2_b4_rdata;
  output [BITSIZE_m_axi_gmem2_b4_rresp-1:0] m_axi_gmem2_b4_rresp;
  output m_axi_gmem2_b4_rlast;
  output [BITSIZE_m_axi_gmem2_b4_ruser-1:0] m_axi_gmem2_b4_ruser;
  output m_axi_gmem2_b4_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem2_b4_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem2_b4_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem2_b4_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem2_b4_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem2_b4_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem2_b4_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem2_b4_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem2_b4_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem2_b4_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem2_b4_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem2_b4_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem2_b4_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem2_b4_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem2_b4_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem2_b4_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem2_b4_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem2_b4_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem2_b4_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem2_b4_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem2_b4_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem2_b4_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem2_b4_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem2_b4_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem2_b4_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem2_b4_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem2_b4_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem2_b4_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem2_b4_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem2_b4_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem2_b4_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem2_b4_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem2_b4_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem2_b4_awready=awready;
  assign m_axi_gmem2_b4_wready=wready;
  assign m_axi_gmem2_b4_bid=bid;
  assign m_axi_gmem2_b4_bresp=bresp;
  assign m_axi_gmem2_b4_buser=buser;
  assign m_axi_gmem2_b4_bvalid=bvalid;
  assign m_axi_gmem2_b4_arready=arready;
  assign m_axi_gmem2_b4_rid=rid;
  assign m_axi_gmem2_b4_rdata=rdata;
  assign m_axi_gmem2_b4_rresp=rresp;
  assign m_axi_gmem2_b4_rlast=rlast;
  assign m_axi_gmem2_b4_ruser=ruser;
  assign m_axi_gmem2_b4_rvalid=rvalid;
  assign awid=m_axi_gmem2_b4_awid;
  assign awaddr=m_axi_gmem2_b4_awaddr;
  assign awlen=m_axi_gmem2_b4_awlen;
  assign awsize=m_axi_gmem2_b4_awsize;
  assign awburst=m_axi_gmem2_b4_awburst;
  assign awlock=m_axi_gmem2_b4_awlock;
  assign awcache=m_axi_gmem2_b4_awcache;
  assign awprot=m_axi_gmem2_b4_awprot;
  assign awqos=m_axi_gmem2_b4_awqos;
  assign awregion=m_axi_gmem2_b4_awregion;
  assign awuser=m_axi_gmem2_b4_awuser;
  assign awvalid=m_axi_gmem2_b4_awvalid;
  assign wdata=m_axi_gmem2_b4_wdata;
  assign wstrb=m_axi_gmem2_b4_wstrb;
  assign wlast=m_axi_gmem2_b4_wlast;
  assign wuser=m_axi_gmem2_b4_wuser;
  assign wvalid=m_axi_gmem2_b4_wvalid;
  assign bready=m_axi_gmem2_b4_bready;
  assign arid=m_axi_gmem2_b4_arid;
  assign araddr=m_axi_gmem2_b4_araddr;
  assign arlen=m_axi_gmem2_b4_arlen;
  assign arsize=m_axi_gmem2_b4_arsize;
  assign arburst=m_axi_gmem2_b4_arburst;
  assign arlock=m_axi_gmem2_b4_arlock;
  assign arcache=m_axi_gmem2_b4_arcache;
  assign arprot=m_axi_gmem2_b4_arprot;
  assign arqos=m_axi_gmem2_b4_arqos;
  assign arregion=m_axi_gmem2_b4_arregion;
  assign aruser=m_axi_gmem2_b4_aruser;
  assign arvalid=m_axi_gmem2_b4_arvalid;
  assign rready=m_axi_gmem2_b4_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem2_b4_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem2_b4_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem2_b4_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem2_b4_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem2_b4_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem2_b4_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem2_b4_arid,
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
module if_m_axi_gmem2_b5(clock,
  reset,
  done_port,
  m_axi_gmem2_b5_awready,
  m_axi_gmem2_b5_wready,
  m_axi_gmem2_b5_bid,
  m_axi_gmem2_b5_bresp,
  m_axi_gmem2_b5_buser,
  m_axi_gmem2_b5_bvalid,
  m_axi_gmem2_b5_arready,
  m_axi_gmem2_b5_rid,
  m_axi_gmem2_b5_rdata,
  m_axi_gmem2_b5_rresp,
  m_axi_gmem2_b5_rlast,
  m_axi_gmem2_b5_ruser,
  m_axi_gmem2_b5_rvalid,
  m_axi_gmem2_b5_awid,
  m_axi_gmem2_b5_awaddr,
  m_axi_gmem2_b5_awlen,
  m_axi_gmem2_b5_awsize,
  m_axi_gmem2_b5_awburst,
  m_axi_gmem2_b5_awlock,
  m_axi_gmem2_b5_awcache,
  m_axi_gmem2_b5_awprot,
  m_axi_gmem2_b5_awqos,
  m_axi_gmem2_b5_awregion,
  m_axi_gmem2_b5_awuser,
  m_axi_gmem2_b5_awvalid,
  m_axi_gmem2_b5_wdata,
  m_axi_gmem2_b5_wstrb,
  m_axi_gmem2_b5_wlast,
  m_axi_gmem2_b5_wuser,
  m_axi_gmem2_b5_wvalid,
  m_axi_gmem2_b5_bready,
  m_axi_gmem2_b5_arid,
  m_axi_gmem2_b5_araddr,
  m_axi_gmem2_b5_arlen,
  m_axi_gmem2_b5_arsize,
  m_axi_gmem2_b5_arburst,
  m_axi_gmem2_b5_arlock,
  m_axi_gmem2_b5_arcache,
  m_axi_gmem2_b5_arprot,
  m_axi_gmem2_b5_arqos,
  m_axi_gmem2_b5_arregion,
  m_axi_gmem2_b5_aruser,
  m_axi_gmem2_b5_arvalid,
  m_axi_gmem2_b5_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem2_b5_bid=1,
    BITSIZE_m_axi_gmem2_b5_bresp=2,
    BITSIZE_m_axi_gmem2_b5_buser=1,
    BITSIZE_m_axi_gmem2_b5_rid=1,
    BITSIZE_m_axi_gmem2_b5_rdata=1,
    BITSIZE_m_axi_gmem2_b5_rresp=2,
    BITSIZE_m_axi_gmem2_b5_ruser=1,
    BITSIZE_m_axi_gmem2_b5_awid=1,
    BITSIZE_m_axi_gmem2_b5_awaddr=1,
    BITSIZE_m_axi_gmem2_b5_awlen=1,
    BITSIZE_m_axi_gmem2_b5_awsize=1,
    BITSIZE_m_axi_gmem2_b5_awburst=2,
    BITSIZE_m_axi_gmem2_b5_awlock=1,
    BITSIZE_m_axi_gmem2_b5_awcache=1,
    BITSIZE_m_axi_gmem2_b5_awprot=1,
    BITSIZE_m_axi_gmem2_b5_awqos=1,
    BITSIZE_m_axi_gmem2_b5_awregion=1,
    BITSIZE_m_axi_gmem2_b5_awuser=1,
    BITSIZE_m_axi_gmem2_b5_wdata=1,
    BITSIZE_m_axi_gmem2_b5_wstrb=1,
    BITSIZE_m_axi_gmem2_b5_wuser=1,
    BITSIZE_m_axi_gmem2_b5_arid=1,
    BITSIZE_m_axi_gmem2_b5_araddr=1,
    BITSIZE_m_axi_gmem2_b5_arlen=1,
    BITSIZE_m_axi_gmem2_b5_arsize=1,
    BITSIZE_m_axi_gmem2_b5_arburst=2,
    BITSIZE_m_axi_gmem2_b5_arlock=1,
    BITSIZE_m_axi_gmem2_b5_arcache=1,
    BITSIZE_m_axi_gmem2_b5_arprot=1,
    BITSIZE_m_axi_gmem2_b5_arqos=1,
    BITSIZE_m_axi_gmem2_b5_arregion=1,
    BITSIZE_m_axi_gmem2_b5_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem2_b5_awid-1:0] m_axi_gmem2_b5_awid;
  input [BITSIZE_m_axi_gmem2_b5_awaddr-1:0] m_axi_gmem2_b5_awaddr;
  input [BITSIZE_m_axi_gmem2_b5_awlen-1:0] m_axi_gmem2_b5_awlen;
  input [BITSIZE_m_axi_gmem2_b5_awsize-1:0] m_axi_gmem2_b5_awsize;
  input [BITSIZE_m_axi_gmem2_b5_awburst-1:0] m_axi_gmem2_b5_awburst;
  input [BITSIZE_m_axi_gmem2_b5_awlock-1:0] m_axi_gmem2_b5_awlock;
  input [BITSIZE_m_axi_gmem2_b5_awcache-1:0] m_axi_gmem2_b5_awcache;
  input [BITSIZE_m_axi_gmem2_b5_awprot-1:0] m_axi_gmem2_b5_awprot;
  input [BITSIZE_m_axi_gmem2_b5_awqos-1:0] m_axi_gmem2_b5_awqos;
  input [BITSIZE_m_axi_gmem2_b5_awregion-1:0] m_axi_gmem2_b5_awregion;
  input [BITSIZE_m_axi_gmem2_b5_awuser-1:0] m_axi_gmem2_b5_awuser;
  input m_axi_gmem2_b5_awvalid;
  input [BITSIZE_m_axi_gmem2_b5_wdata-1:0] m_axi_gmem2_b5_wdata;
  input [BITSIZE_m_axi_gmem2_b5_wstrb-1:0] m_axi_gmem2_b5_wstrb;
  input m_axi_gmem2_b5_wlast;
  input [BITSIZE_m_axi_gmem2_b5_wuser-1:0] m_axi_gmem2_b5_wuser;
  input m_axi_gmem2_b5_wvalid;
  input m_axi_gmem2_b5_bready;
  input [BITSIZE_m_axi_gmem2_b5_arid-1:0] m_axi_gmem2_b5_arid;
  input [BITSIZE_m_axi_gmem2_b5_araddr-1:0] m_axi_gmem2_b5_araddr;
  input [BITSIZE_m_axi_gmem2_b5_arlen-1:0] m_axi_gmem2_b5_arlen;
  input [BITSIZE_m_axi_gmem2_b5_arsize-1:0] m_axi_gmem2_b5_arsize;
  input [BITSIZE_m_axi_gmem2_b5_arburst-1:0] m_axi_gmem2_b5_arburst;
  input [BITSIZE_m_axi_gmem2_b5_arlock-1:0] m_axi_gmem2_b5_arlock;
  input [BITSIZE_m_axi_gmem2_b5_arcache-1:0] m_axi_gmem2_b5_arcache;
  input [BITSIZE_m_axi_gmem2_b5_arprot-1:0] m_axi_gmem2_b5_arprot;
  input [BITSIZE_m_axi_gmem2_b5_arqos-1:0] m_axi_gmem2_b5_arqos;
  input [BITSIZE_m_axi_gmem2_b5_arregion-1:0] m_axi_gmem2_b5_arregion;
  input [BITSIZE_m_axi_gmem2_b5_aruser-1:0] m_axi_gmem2_b5_aruser;
  input m_axi_gmem2_b5_arvalid;
  input m_axi_gmem2_b5_rready;
  // OUT
  output m_axi_gmem2_b5_awready;
  output m_axi_gmem2_b5_wready;
  output [BITSIZE_m_axi_gmem2_b5_bid-1:0] m_axi_gmem2_b5_bid;
  output [BITSIZE_m_axi_gmem2_b5_bresp-1:0] m_axi_gmem2_b5_bresp;
  output [BITSIZE_m_axi_gmem2_b5_buser-1:0] m_axi_gmem2_b5_buser;
  output m_axi_gmem2_b5_bvalid;
  output m_axi_gmem2_b5_arready;
  output [BITSIZE_m_axi_gmem2_b5_rid-1:0] m_axi_gmem2_b5_rid;
  output [BITSIZE_m_axi_gmem2_b5_rdata-1:0] m_axi_gmem2_b5_rdata;
  output [BITSIZE_m_axi_gmem2_b5_rresp-1:0] m_axi_gmem2_b5_rresp;
  output m_axi_gmem2_b5_rlast;
  output [BITSIZE_m_axi_gmem2_b5_ruser-1:0] m_axi_gmem2_b5_ruser;
  output m_axi_gmem2_b5_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem2_b5_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem2_b5_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem2_b5_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem2_b5_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem2_b5_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem2_b5_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem2_b5_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem2_b5_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem2_b5_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem2_b5_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem2_b5_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem2_b5_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem2_b5_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem2_b5_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem2_b5_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem2_b5_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem2_b5_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem2_b5_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem2_b5_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem2_b5_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem2_b5_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem2_b5_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem2_b5_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem2_b5_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem2_b5_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem2_b5_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem2_b5_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem2_b5_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem2_b5_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem2_b5_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem2_b5_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem2_b5_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem2_b5_awready=awready;
  assign m_axi_gmem2_b5_wready=wready;
  assign m_axi_gmem2_b5_bid=bid;
  assign m_axi_gmem2_b5_bresp=bresp;
  assign m_axi_gmem2_b5_buser=buser;
  assign m_axi_gmem2_b5_bvalid=bvalid;
  assign m_axi_gmem2_b5_arready=arready;
  assign m_axi_gmem2_b5_rid=rid;
  assign m_axi_gmem2_b5_rdata=rdata;
  assign m_axi_gmem2_b5_rresp=rresp;
  assign m_axi_gmem2_b5_rlast=rlast;
  assign m_axi_gmem2_b5_ruser=ruser;
  assign m_axi_gmem2_b5_rvalid=rvalid;
  assign awid=m_axi_gmem2_b5_awid;
  assign awaddr=m_axi_gmem2_b5_awaddr;
  assign awlen=m_axi_gmem2_b5_awlen;
  assign awsize=m_axi_gmem2_b5_awsize;
  assign awburst=m_axi_gmem2_b5_awburst;
  assign awlock=m_axi_gmem2_b5_awlock;
  assign awcache=m_axi_gmem2_b5_awcache;
  assign awprot=m_axi_gmem2_b5_awprot;
  assign awqos=m_axi_gmem2_b5_awqos;
  assign awregion=m_axi_gmem2_b5_awregion;
  assign awuser=m_axi_gmem2_b5_awuser;
  assign awvalid=m_axi_gmem2_b5_awvalid;
  assign wdata=m_axi_gmem2_b5_wdata;
  assign wstrb=m_axi_gmem2_b5_wstrb;
  assign wlast=m_axi_gmem2_b5_wlast;
  assign wuser=m_axi_gmem2_b5_wuser;
  assign wvalid=m_axi_gmem2_b5_wvalid;
  assign bready=m_axi_gmem2_b5_bready;
  assign arid=m_axi_gmem2_b5_arid;
  assign araddr=m_axi_gmem2_b5_araddr;
  assign arlen=m_axi_gmem2_b5_arlen;
  assign arsize=m_axi_gmem2_b5_arsize;
  assign arburst=m_axi_gmem2_b5_arburst;
  assign arlock=m_axi_gmem2_b5_arlock;
  assign arcache=m_axi_gmem2_b5_arcache;
  assign arprot=m_axi_gmem2_b5_arprot;
  assign arqos=m_axi_gmem2_b5_arqos;
  assign arregion=m_axi_gmem2_b5_arregion;
  assign aruser=m_axi_gmem2_b5_aruser;
  assign arvalid=m_axi_gmem2_b5_arvalid;
  assign rready=m_axi_gmem2_b5_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem2_b5_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem2_b5_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem2_b5_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem2_b5_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem2_b5_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem2_b5_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem2_b5_arid,
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
module if_m_axi_gmem2_b6(clock,
  reset,
  done_port,
  m_axi_gmem2_b6_awready,
  m_axi_gmem2_b6_wready,
  m_axi_gmem2_b6_bid,
  m_axi_gmem2_b6_bresp,
  m_axi_gmem2_b6_buser,
  m_axi_gmem2_b6_bvalid,
  m_axi_gmem2_b6_arready,
  m_axi_gmem2_b6_rid,
  m_axi_gmem2_b6_rdata,
  m_axi_gmem2_b6_rresp,
  m_axi_gmem2_b6_rlast,
  m_axi_gmem2_b6_ruser,
  m_axi_gmem2_b6_rvalid,
  m_axi_gmem2_b6_awid,
  m_axi_gmem2_b6_awaddr,
  m_axi_gmem2_b6_awlen,
  m_axi_gmem2_b6_awsize,
  m_axi_gmem2_b6_awburst,
  m_axi_gmem2_b6_awlock,
  m_axi_gmem2_b6_awcache,
  m_axi_gmem2_b6_awprot,
  m_axi_gmem2_b6_awqos,
  m_axi_gmem2_b6_awregion,
  m_axi_gmem2_b6_awuser,
  m_axi_gmem2_b6_awvalid,
  m_axi_gmem2_b6_wdata,
  m_axi_gmem2_b6_wstrb,
  m_axi_gmem2_b6_wlast,
  m_axi_gmem2_b6_wuser,
  m_axi_gmem2_b6_wvalid,
  m_axi_gmem2_b6_bready,
  m_axi_gmem2_b6_arid,
  m_axi_gmem2_b6_araddr,
  m_axi_gmem2_b6_arlen,
  m_axi_gmem2_b6_arsize,
  m_axi_gmem2_b6_arburst,
  m_axi_gmem2_b6_arlock,
  m_axi_gmem2_b6_arcache,
  m_axi_gmem2_b6_arprot,
  m_axi_gmem2_b6_arqos,
  m_axi_gmem2_b6_arregion,
  m_axi_gmem2_b6_aruser,
  m_axi_gmem2_b6_arvalid,
  m_axi_gmem2_b6_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem2_b6_bid=1,
    BITSIZE_m_axi_gmem2_b6_bresp=2,
    BITSIZE_m_axi_gmem2_b6_buser=1,
    BITSIZE_m_axi_gmem2_b6_rid=1,
    BITSIZE_m_axi_gmem2_b6_rdata=1,
    BITSIZE_m_axi_gmem2_b6_rresp=2,
    BITSIZE_m_axi_gmem2_b6_ruser=1,
    BITSIZE_m_axi_gmem2_b6_awid=1,
    BITSIZE_m_axi_gmem2_b6_awaddr=1,
    BITSIZE_m_axi_gmem2_b6_awlen=1,
    BITSIZE_m_axi_gmem2_b6_awsize=1,
    BITSIZE_m_axi_gmem2_b6_awburst=2,
    BITSIZE_m_axi_gmem2_b6_awlock=1,
    BITSIZE_m_axi_gmem2_b6_awcache=1,
    BITSIZE_m_axi_gmem2_b6_awprot=1,
    BITSIZE_m_axi_gmem2_b6_awqos=1,
    BITSIZE_m_axi_gmem2_b6_awregion=1,
    BITSIZE_m_axi_gmem2_b6_awuser=1,
    BITSIZE_m_axi_gmem2_b6_wdata=1,
    BITSIZE_m_axi_gmem2_b6_wstrb=1,
    BITSIZE_m_axi_gmem2_b6_wuser=1,
    BITSIZE_m_axi_gmem2_b6_arid=1,
    BITSIZE_m_axi_gmem2_b6_araddr=1,
    BITSIZE_m_axi_gmem2_b6_arlen=1,
    BITSIZE_m_axi_gmem2_b6_arsize=1,
    BITSIZE_m_axi_gmem2_b6_arburst=2,
    BITSIZE_m_axi_gmem2_b6_arlock=1,
    BITSIZE_m_axi_gmem2_b6_arcache=1,
    BITSIZE_m_axi_gmem2_b6_arprot=1,
    BITSIZE_m_axi_gmem2_b6_arqos=1,
    BITSIZE_m_axi_gmem2_b6_arregion=1,
    BITSIZE_m_axi_gmem2_b6_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem2_b6_awid-1:0] m_axi_gmem2_b6_awid;
  input [BITSIZE_m_axi_gmem2_b6_awaddr-1:0] m_axi_gmem2_b6_awaddr;
  input [BITSIZE_m_axi_gmem2_b6_awlen-1:0] m_axi_gmem2_b6_awlen;
  input [BITSIZE_m_axi_gmem2_b6_awsize-1:0] m_axi_gmem2_b6_awsize;
  input [BITSIZE_m_axi_gmem2_b6_awburst-1:0] m_axi_gmem2_b6_awburst;
  input [BITSIZE_m_axi_gmem2_b6_awlock-1:0] m_axi_gmem2_b6_awlock;
  input [BITSIZE_m_axi_gmem2_b6_awcache-1:0] m_axi_gmem2_b6_awcache;
  input [BITSIZE_m_axi_gmem2_b6_awprot-1:0] m_axi_gmem2_b6_awprot;
  input [BITSIZE_m_axi_gmem2_b6_awqos-1:0] m_axi_gmem2_b6_awqos;
  input [BITSIZE_m_axi_gmem2_b6_awregion-1:0] m_axi_gmem2_b6_awregion;
  input [BITSIZE_m_axi_gmem2_b6_awuser-1:0] m_axi_gmem2_b6_awuser;
  input m_axi_gmem2_b6_awvalid;
  input [BITSIZE_m_axi_gmem2_b6_wdata-1:0] m_axi_gmem2_b6_wdata;
  input [BITSIZE_m_axi_gmem2_b6_wstrb-1:0] m_axi_gmem2_b6_wstrb;
  input m_axi_gmem2_b6_wlast;
  input [BITSIZE_m_axi_gmem2_b6_wuser-1:0] m_axi_gmem2_b6_wuser;
  input m_axi_gmem2_b6_wvalid;
  input m_axi_gmem2_b6_bready;
  input [BITSIZE_m_axi_gmem2_b6_arid-1:0] m_axi_gmem2_b6_arid;
  input [BITSIZE_m_axi_gmem2_b6_araddr-1:0] m_axi_gmem2_b6_araddr;
  input [BITSIZE_m_axi_gmem2_b6_arlen-1:0] m_axi_gmem2_b6_arlen;
  input [BITSIZE_m_axi_gmem2_b6_arsize-1:0] m_axi_gmem2_b6_arsize;
  input [BITSIZE_m_axi_gmem2_b6_arburst-1:0] m_axi_gmem2_b6_arburst;
  input [BITSIZE_m_axi_gmem2_b6_arlock-1:0] m_axi_gmem2_b6_arlock;
  input [BITSIZE_m_axi_gmem2_b6_arcache-1:0] m_axi_gmem2_b6_arcache;
  input [BITSIZE_m_axi_gmem2_b6_arprot-1:0] m_axi_gmem2_b6_arprot;
  input [BITSIZE_m_axi_gmem2_b6_arqos-1:0] m_axi_gmem2_b6_arqos;
  input [BITSIZE_m_axi_gmem2_b6_arregion-1:0] m_axi_gmem2_b6_arregion;
  input [BITSIZE_m_axi_gmem2_b6_aruser-1:0] m_axi_gmem2_b6_aruser;
  input m_axi_gmem2_b6_arvalid;
  input m_axi_gmem2_b6_rready;
  // OUT
  output m_axi_gmem2_b6_awready;
  output m_axi_gmem2_b6_wready;
  output [BITSIZE_m_axi_gmem2_b6_bid-1:0] m_axi_gmem2_b6_bid;
  output [BITSIZE_m_axi_gmem2_b6_bresp-1:0] m_axi_gmem2_b6_bresp;
  output [BITSIZE_m_axi_gmem2_b6_buser-1:0] m_axi_gmem2_b6_buser;
  output m_axi_gmem2_b6_bvalid;
  output m_axi_gmem2_b6_arready;
  output [BITSIZE_m_axi_gmem2_b6_rid-1:0] m_axi_gmem2_b6_rid;
  output [BITSIZE_m_axi_gmem2_b6_rdata-1:0] m_axi_gmem2_b6_rdata;
  output [BITSIZE_m_axi_gmem2_b6_rresp-1:0] m_axi_gmem2_b6_rresp;
  output m_axi_gmem2_b6_rlast;
  output [BITSIZE_m_axi_gmem2_b6_ruser-1:0] m_axi_gmem2_b6_ruser;
  output m_axi_gmem2_b6_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem2_b6_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem2_b6_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem2_b6_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem2_b6_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem2_b6_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem2_b6_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem2_b6_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem2_b6_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem2_b6_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem2_b6_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem2_b6_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem2_b6_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem2_b6_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem2_b6_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem2_b6_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem2_b6_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem2_b6_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem2_b6_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem2_b6_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem2_b6_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem2_b6_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem2_b6_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem2_b6_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem2_b6_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem2_b6_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem2_b6_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem2_b6_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem2_b6_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem2_b6_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem2_b6_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem2_b6_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem2_b6_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem2_b6_awready=awready;
  assign m_axi_gmem2_b6_wready=wready;
  assign m_axi_gmem2_b6_bid=bid;
  assign m_axi_gmem2_b6_bresp=bresp;
  assign m_axi_gmem2_b6_buser=buser;
  assign m_axi_gmem2_b6_bvalid=bvalid;
  assign m_axi_gmem2_b6_arready=arready;
  assign m_axi_gmem2_b6_rid=rid;
  assign m_axi_gmem2_b6_rdata=rdata;
  assign m_axi_gmem2_b6_rresp=rresp;
  assign m_axi_gmem2_b6_rlast=rlast;
  assign m_axi_gmem2_b6_ruser=ruser;
  assign m_axi_gmem2_b6_rvalid=rvalid;
  assign awid=m_axi_gmem2_b6_awid;
  assign awaddr=m_axi_gmem2_b6_awaddr;
  assign awlen=m_axi_gmem2_b6_awlen;
  assign awsize=m_axi_gmem2_b6_awsize;
  assign awburst=m_axi_gmem2_b6_awburst;
  assign awlock=m_axi_gmem2_b6_awlock;
  assign awcache=m_axi_gmem2_b6_awcache;
  assign awprot=m_axi_gmem2_b6_awprot;
  assign awqos=m_axi_gmem2_b6_awqos;
  assign awregion=m_axi_gmem2_b6_awregion;
  assign awuser=m_axi_gmem2_b6_awuser;
  assign awvalid=m_axi_gmem2_b6_awvalid;
  assign wdata=m_axi_gmem2_b6_wdata;
  assign wstrb=m_axi_gmem2_b6_wstrb;
  assign wlast=m_axi_gmem2_b6_wlast;
  assign wuser=m_axi_gmem2_b6_wuser;
  assign wvalid=m_axi_gmem2_b6_wvalid;
  assign bready=m_axi_gmem2_b6_bready;
  assign arid=m_axi_gmem2_b6_arid;
  assign araddr=m_axi_gmem2_b6_araddr;
  assign arlen=m_axi_gmem2_b6_arlen;
  assign arsize=m_axi_gmem2_b6_arsize;
  assign arburst=m_axi_gmem2_b6_arburst;
  assign arlock=m_axi_gmem2_b6_arlock;
  assign arcache=m_axi_gmem2_b6_arcache;
  assign arprot=m_axi_gmem2_b6_arprot;
  assign arqos=m_axi_gmem2_b6_arqos;
  assign arregion=m_axi_gmem2_b6_arregion;
  assign aruser=m_axi_gmem2_b6_aruser;
  assign arvalid=m_axi_gmem2_b6_arvalid;
  assign rready=m_axi_gmem2_b6_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem2_b6_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem2_b6_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem2_b6_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem2_b6_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem2_b6_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem2_b6_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem2_b6_arid,
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
module if_m_axi_gmem2_b7(clock,
  reset,
  done_port,
  m_axi_gmem2_b7_awready,
  m_axi_gmem2_b7_wready,
  m_axi_gmem2_b7_bid,
  m_axi_gmem2_b7_bresp,
  m_axi_gmem2_b7_buser,
  m_axi_gmem2_b7_bvalid,
  m_axi_gmem2_b7_arready,
  m_axi_gmem2_b7_rid,
  m_axi_gmem2_b7_rdata,
  m_axi_gmem2_b7_rresp,
  m_axi_gmem2_b7_rlast,
  m_axi_gmem2_b7_ruser,
  m_axi_gmem2_b7_rvalid,
  m_axi_gmem2_b7_awid,
  m_axi_gmem2_b7_awaddr,
  m_axi_gmem2_b7_awlen,
  m_axi_gmem2_b7_awsize,
  m_axi_gmem2_b7_awburst,
  m_axi_gmem2_b7_awlock,
  m_axi_gmem2_b7_awcache,
  m_axi_gmem2_b7_awprot,
  m_axi_gmem2_b7_awqos,
  m_axi_gmem2_b7_awregion,
  m_axi_gmem2_b7_awuser,
  m_axi_gmem2_b7_awvalid,
  m_axi_gmem2_b7_wdata,
  m_axi_gmem2_b7_wstrb,
  m_axi_gmem2_b7_wlast,
  m_axi_gmem2_b7_wuser,
  m_axi_gmem2_b7_wvalid,
  m_axi_gmem2_b7_bready,
  m_axi_gmem2_b7_arid,
  m_axi_gmem2_b7_araddr,
  m_axi_gmem2_b7_arlen,
  m_axi_gmem2_b7_arsize,
  m_axi_gmem2_b7_arburst,
  m_axi_gmem2_b7_arlock,
  m_axi_gmem2_b7_arcache,
  m_axi_gmem2_b7_arprot,
  m_axi_gmem2_b7_arqos,
  m_axi_gmem2_b7_arregion,
  m_axi_gmem2_b7_aruser,
  m_axi_gmem2_b7_arvalid,
  m_axi_gmem2_b7_rready);
  parameter index=0,
    BITSIZE_m_axi_gmem2_b7_bid=1,
    BITSIZE_m_axi_gmem2_b7_bresp=2,
    BITSIZE_m_axi_gmem2_b7_buser=1,
    BITSIZE_m_axi_gmem2_b7_rid=1,
    BITSIZE_m_axi_gmem2_b7_rdata=1,
    BITSIZE_m_axi_gmem2_b7_rresp=2,
    BITSIZE_m_axi_gmem2_b7_ruser=1,
    BITSIZE_m_axi_gmem2_b7_awid=1,
    BITSIZE_m_axi_gmem2_b7_awaddr=1,
    BITSIZE_m_axi_gmem2_b7_awlen=1,
    BITSIZE_m_axi_gmem2_b7_awsize=1,
    BITSIZE_m_axi_gmem2_b7_awburst=2,
    BITSIZE_m_axi_gmem2_b7_awlock=1,
    BITSIZE_m_axi_gmem2_b7_awcache=1,
    BITSIZE_m_axi_gmem2_b7_awprot=1,
    BITSIZE_m_axi_gmem2_b7_awqos=1,
    BITSIZE_m_axi_gmem2_b7_awregion=1,
    BITSIZE_m_axi_gmem2_b7_awuser=1,
    BITSIZE_m_axi_gmem2_b7_wdata=1,
    BITSIZE_m_axi_gmem2_b7_wstrb=1,
    BITSIZE_m_axi_gmem2_b7_wuser=1,
    BITSIZE_m_axi_gmem2_b7_arid=1,
    BITSIZE_m_axi_gmem2_b7_araddr=1,
    BITSIZE_m_axi_gmem2_b7_arlen=1,
    BITSIZE_m_axi_gmem2_b7_arsize=1,
    BITSIZE_m_axi_gmem2_b7_arburst=2,
    BITSIZE_m_axi_gmem2_b7_arlock=1,
    BITSIZE_m_axi_gmem2_b7_arcache=1,
    BITSIZE_m_axi_gmem2_b7_arprot=1,
    BITSIZE_m_axi_gmem2_b7_arqos=1,
    BITSIZE_m_axi_gmem2_b7_arregion=1,
    BITSIZE_m_axi_gmem2_b7_aruser=1;
  // IN
  input clock;
  input reset;
  input done_port;
  input [BITSIZE_m_axi_gmem2_b7_awid-1:0] m_axi_gmem2_b7_awid;
  input [BITSIZE_m_axi_gmem2_b7_awaddr-1:0] m_axi_gmem2_b7_awaddr;
  input [BITSIZE_m_axi_gmem2_b7_awlen-1:0] m_axi_gmem2_b7_awlen;
  input [BITSIZE_m_axi_gmem2_b7_awsize-1:0] m_axi_gmem2_b7_awsize;
  input [BITSIZE_m_axi_gmem2_b7_awburst-1:0] m_axi_gmem2_b7_awburst;
  input [BITSIZE_m_axi_gmem2_b7_awlock-1:0] m_axi_gmem2_b7_awlock;
  input [BITSIZE_m_axi_gmem2_b7_awcache-1:0] m_axi_gmem2_b7_awcache;
  input [BITSIZE_m_axi_gmem2_b7_awprot-1:0] m_axi_gmem2_b7_awprot;
  input [BITSIZE_m_axi_gmem2_b7_awqos-1:0] m_axi_gmem2_b7_awqos;
  input [BITSIZE_m_axi_gmem2_b7_awregion-1:0] m_axi_gmem2_b7_awregion;
  input [BITSIZE_m_axi_gmem2_b7_awuser-1:0] m_axi_gmem2_b7_awuser;
  input m_axi_gmem2_b7_awvalid;
  input [BITSIZE_m_axi_gmem2_b7_wdata-1:0] m_axi_gmem2_b7_wdata;
  input [BITSIZE_m_axi_gmem2_b7_wstrb-1:0] m_axi_gmem2_b7_wstrb;
  input m_axi_gmem2_b7_wlast;
  input [BITSIZE_m_axi_gmem2_b7_wuser-1:0] m_axi_gmem2_b7_wuser;
  input m_axi_gmem2_b7_wvalid;
  input m_axi_gmem2_b7_bready;
  input [BITSIZE_m_axi_gmem2_b7_arid-1:0] m_axi_gmem2_b7_arid;
  input [BITSIZE_m_axi_gmem2_b7_araddr-1:0] m_axi_gmem2_b7_araddr;
  input [BITSIZE_m_axi_gmem2_b7_arlen-1:0] m_axi_gmem2_b7_arlen;
  input [BITSIZE_m_axi_gmem2_b7_arsize-1:0] m_axi_gmem2_b7_arsize;
  input [BITSIZE_m_axi_gmem2_b7_arburst-1:0] m_axi_gmem2_b7_arburst;
  input [BITSIZE_m_axi_gmem2_b7_arlock-1:0] m_axi_gmem2_b7_arlock;
  input [BITSIZE_m_axi_gmem2_b7_arcache-1:0] m_axi_gmem2_b7_arcache;
  input [BITSIZE_m_axi_gmem2_b7_arprot-1:0] m_axi_gmem2_b7_arprot;
  input [BITSIZE_m_axi_gmem2_b7_arqos-1:0] m_axi_gmem2_b7_arqos;
  input [BITSIZE_m_axi_gmem2_b7_arregion-1:0] m_axi_gmem2_b7_arregion;
  input [BITSIZE_m_axi_gmem2_b7_aruser-1:0] m_axi_gmem2_b7_aruser;
  input m_axi_gmem2_b7_arvalid;
  input m_axi_gmem2_b7_rready;
  // OUT
  output m_axi_gmem2_b7_awready;
  output m_axi_gmem2_b7_wready;
  output [BITSIZE_m_axi_gmem2_b7_bid-1:0] m_axi_gmem2_b7_bid;
  output [BITSIZE_m_axi_gmem2_b7_bresp-1:0] m_axi_gmem2_b7_bresp;
  output [BITSIZE_m_axi_gmem2_b7_buser-1:0] m_axi_gmem2_b7_buser;
  output m_axi_gmem2_b7_bvalid;
  output m_axi_gmem2_b7_arready;
  output [BITSIZE_m_axi_gmem2_b7_rid-1:0] m_axi_gmem2_b7_rid;
  output [BITSIZE_m_axi_gmem2_b7_rdata-1:0] m_axi_gmem2_b7_rdata;
  output [BITSIZE_m_axi_gmem2_b7_rresp-1:0] m_axi_gmem2_b7_rresp;
  output m_axi_gmem2_b7_rlast;
  output [BITSIZE_m_axi_gmem2_b7_ruser-1:0] m_axi_gmem2_b7_ruser;
  output m_axi_gmem2_b7_rvalid;
  reg awready;
  reg wready;
  reg [BITSIZE_m_axi_gmem2_b7_bid-1:0] bid;
  reg [BITSIZE_m_axi_gmem2_b7_bresp-1:0] bresp;
  reg [BITSIZE_m_axi_gmem2_b7_buser-1:0] buser;
  reg bvalid;
  reg arready;
  reg [BITSIZE_m_axi_gmem2_b7_rid-1:0] rid;
  reg [BITSIZE_m_axi_gmem2_b7_rdata-1:0] rdata;
  reg [BITSIZE_m_axi_gmem2_b7_rresp-1:0] rresp;
  reg rlast;
  reg [BITSIZE_m_axi_gmem2_b7_ruser-1:0] ruser;
  reg rvalid;
  reg [BITSIZE_m_axi_gmem2_b7_awid-1:0] awid;
  reg [BITSIZE_m_axi_gmem2_b7_awaddr-1:0] awaddr;
  reg [BITSIZE_m_axi_gmem2_b7_awlen-1:0] awlen;
  reg [BITSIZE_m_axi_gmem2_b7_awsize-1:0] awsize;
  reg [BITSIZE_m_axi_gmem2_b7_awburst-1:0] awburst;
  reg [BITSIZE_m_axi_gmem2_b7_awlock-1:0] awlock;
  reg [BITSIZE_m_axi_gmem2_b7_awcache-1:0] awcache;
  reg [BITSIZE_m_axi_gmem2_b7_awprot-1:0] awprot;
  reg [BITSIZE_m_axi_gmem2_b7_awqos-1:0] awqos;
  reg [BITSIZE_m_axi_gmem2_b7_awregion-1:0] awregion;
  reg [BITSIZE_m_axi_gmem2_b7_awuser-1:0] awuser;
  reg awvalid;
  reg [BITSIZE_m_axi_gmem2_b7_wdata-1:0] wdata;
  reg [BITSIZE_m_axi_gmem2_b7_wstrb-1:0] wstrb;
  reg wlast;
  reg [BITSIZE_m_axi_gmem2_b7_wuser-1:0] wuser;
  reg wvalid;
  wire bready;
  reg [BITSIZE_m_axi_gmem2_b7_arid-1:0] arid;
  reg [BITSIZE_m_axi_gmem2_b7_araddr-1:0] araddr;
  reg [BITSIZE_m_axi_gmem2_b7_arlen-1:0] arlen;
  reg [BITSIZE_m_axi_gmem2_b7_arsize-1:0] arsize;
  reg [BITSIZE_m_axi_gmem2_b7_arburst-1:0] arburst;
  reg [BITSIZE_m_axi_gmem2_b7_arlock-1:0] arlock;
  reg [BITSIZE_m_axi_gmem2_b7_arcache-1:0] arcache;
  reg [BITSIZE_m_axi_gmem2_b7_arprot-1:0] arprot;
  reg [BITSIZE_m_axi_gmem2_b7_arqos-1:0] arqos;
  reg [BITSIZE_m_axi_gmem2_b7_arregion-1:0] arregion;
  reg [BITSIZE_m_axi_gmem2_b7_aruser-1:0] aruser;
  reg arvalid;
  wire rready;
  assign m_axi_gmem2_b7_awready=awready;
  assign m_axi_gmem2_b7_wready=wready;
  assign m_axi_gmem2_b7_bid=bid;
  assign m_axi_gmem2_b7_bresp=bresp;
  assign m_axi_gmem2_b7_buser=buser;
  assign m_axi_gmem2_b7_bvalid=bvalid;
  assign m_axi_gmem2_b7_arready=arready;
  assign m_axi_gmem2_b7_rid=rid;
  assign m_axi_gmem2_b7_rdata=rdata;
  assign m_axi_gmem2_b7_rresp=rresp;
  assign m_axi_gmem2_b7_rlast=rlast;
  assign m_axi_gmem2_b7_ruser=ruser;
  assign m_axi_gmem2_b7_rvalid=rvalid;
  assign awid=m_axi_gmem2_b7_awid;
  assign awaddr=m_axi_gmem2_b7_awaddr;
  assign awlen=m_axi_gmem2_b7_awlen;
  assign awsize=m_axi_gmem2_b7_awsize;
  assign awburst=m_axi_gmem2_b7_awburst;
  assign awlock=m_axi_gmem2_b7_awlock;
  assign awcache=m_axi_gmem2_b7_awcache;
  assign awprot=m_axi_gmem2_b7_awprot;
  assign awqos=m_axi_gmem2_b7_awqos;
  assign awregion=m_axi_gmem2_b7_awregion;
  assign awuser=m_axi_gmem2_b7_awuser;
  assign awvalid=m_axi_gmem2_b7_awvalid;
  assign wdata=m_axi_gmem2_b7_wdata;
  assign wstrb=m_axi_gmem2_b7_wstrb;
  assign wlast=m_axi_gmem2_b7_wlast;
  assign wuser=m_axi_gmem2_b7_wuser;
  assign wvalid=m_axi_gmem2_b7_wvalid;
  assign bready=m_axi_gmem2_b7_bready;
  assign arid=m_axi_gmem2_b7_arid;
  assign araddr=m_axi_gmem2_b7_araddr;
  assign arlen=m_axi_gmem2_b7_arlen;
  assign arsize=m_axi_gmem2_b7_arsize;
  assign arburst=m_axi_gmem2_b7_arburst;
  assign arlock=m_axi_gmem2_b7_arlock;
  assign arcache=m_axi_gmem2_b7_arcache;
  assign arprot=m_axi_gmem2_b7_arprot;
  assign arqos=m_axi_gmem2_b7_arqos;
  assign arregion=m_axi_gmem2_b7_arregion;
  assign aruser=m_axi_gmem2_b7_aruser;
  assign arvalid=m_axi_gmem2_b7_arvalid;
  assign rready=m_axi_gmem2_b7_rready;
  
  localparam WRITE_DELAY=1,
    READ_DELAY=1,
    QUEUE_SIZE=4,
    BITSIZE_data=BITSIZE_m_axi_gmem2_b7_rdata,
    BITSIZE_counter=32,
    BITSIZE_burst=BITSIZE_m_axi_gmem2_b7_arburst,
    BITSIZE_len=BITSIZE_m_axi_gmem2_b7_arlen,
    BITSIZE_delay=32,
    BITSIZE_size=BITSIZE_m_axi_gmem2_b7_arsize,
    BITSIZE_addr=BITSIZE_m_axi_gmem2_b7_araddr,
    BITSIZE_wstrb=BITSIZE_m_axi_gmem2_b7_wstrb,
    BITSIZE_id=BITSIZE_m_axi_gmem2_b7_arid,
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
  wire [31:0] sig_dram_in;
  wire [31:0] sig_dram_out_b0;
  wire [31:0] sig_dram_out_b1;
  wire [31:0] sig_dram_out_b2;
  wire [31:0] sig_dram_out_b3;
  wire [31:0] sig_dram_out_b4;
  wire [31:0] sig_dram_out_b5;
  wire [31:0] sig_dram_out_b6;
  wire [31:0] sig_dram_out_b7;
  wire [31:0] sig_dram_w;
  wire [31:0] sig_m_axi_gmem0_araddr;
  wire [1:0] sig_m_axi_gmem0_arburst;
  wire [3:0] sig_m_axi_gmem0_arcache;
  wire [5:0] sig_m_axi_gmem0_arid;
  wire [7:0] sig_m_axi_gmem0_arlen;
  wire sig_m_axi_gmem0_arlock;
  wire [2:0] sig_m_axi_gmem0_arprot;
  wire [3:0] sig_m_axi_gmem0_arqos;
  wire sig_m_axi_gmem0_arready;
  wire [3:0] sig_m_axi_gmem0_arregion;
  wire [2:0] sig_m_axi_gmem0_arsize;
  wire sig_m_axi_gmem0_aruser;
  wire sig_m_axi_gmem0_arvalid;
  wire [31:0] sig_m_axi_gmem0_awaddr;
  wire [1:0] sig_m_axi_gmem0_awburst;
  wire [3:0] sig_m_axi_gmem0_awcache;
  wire [5:0] sig_m_axi_gmem0_awid;
  wire [7:0] sig_m_axi_gmem0_awlen;
  wire sig_m_axi_gmem0_awlock;
  wire [2:0] sig_m_axi_gmem0_awprot;
  wire [3:0] sig_m_axi_gmem0_awqos;
  wire sig_m_axi_gmem0_awready;
  wire [3:0] sig_m_axi_gmem0_awregion;
  wire [2:0] sig_m_axi_gmem0_awsize;
  wire sig_m_axi_gmem0_awuser;
  wire sig_m_axi_gmem0_awvalid;
  wire [5:0] sig_m_axi_gmem0_bid;
  wire sig_m_axi_gmem0_bready;
  wire [1:0] sig_m_axi_gmem0_bresp;
  wire sig_m_axi_gmem0_buser;
  wire sig_m_axi_gmem0_bvalid;
  wire [31:0] sig_m_axi_gmem0_rdata;
  wire [5:0] sig_m_axi_gmem0_rid;
  wire sig_m_axi_gmem0_rlast;
  wire sig_m_axi_gmem0_rready;
  wire [1:0] sig_m_axi_gmem0_rresp;
  wire sig_m_axi_gmem0_ruser;
  wire sig_m_axi_gmem0_rvalid;
  wire [31:0] sig_m_axi_gmem0_wdata;
  wire sig_m_axi_gmem0_wlast;
  wire sig_m_axi_gmem0_wready;
  wire [3:0] sig_m_axi_gmem0_wstrb;
  wire sig_m_axi_gmem0_wuser;
  wire sig_m_axi_gmem0_wvalid;
  wire [31:0] sig_m_axi_gmem1_araddr;
  wire [1:0] sig_m_axi_gmem1_arburst;
  wire [3:0] sig_m_axi_gmem1_arcache;
  wire [5:0] sig_m_axi_gmem1_arid;
  wire [7:0] sig_m_axi_gmem1_arlen;
  wire sig_m_axi_gmem1_arlock;
  wire [2:0] sig_m_axi_gmem1_arprot;
  wire [3:0] sig_m_axi_gmem1_arqos;
  wire sig_m_axi_gmem1_arready;
  wire [3:0] sig_m_axi_gmem1_arregion;
  wire [2:0] sig_m_axi_gmem1_arsize;
  wire sig_m_axi_gmem1_aruser;
  wire sig_m_axi_gmem1_arvalid;
  wire [31:0] sig_m_axi_gmem1_awaddr;
  wire [1:0] sig_m_axi_gmem1_awburst;
  wire [3:0] sig_m_axi_gmem1_awcache;
  wire [5:0] sig_m_axi_gmem1_awid;
  wire [7:0] sig_m_axi_gmem1_awlen;
  wire sig_m_axi_gmem1_awlock;
  wire [2:0] sig_m_axi_gmem1_awprot;
  wire [3:0] sig_m_axi_gmem1_awqos;
  wire sig_m_axi_gmem1_awready;
  wire [3:0] sig_m_axi_gmem1_awregion;
  wire [2:0] sig_m_axi_gmem1_awsize;
  wire sig_m_axi_gmem1_awuser;
  wire sig_m_axi_gmem1_awvalid;
  wire [5:0] sig_m_axi_gmem1_bid;
  wire sig_m_axi_gmem1_bready;
  wire [1:0] sig_m_axi_gmem1_bresp;
  wire sig_m_axi_gmem1_buser;
  wire sig_m_axi_gmem1_bvalid;
  wire [31:0] sig_m_axi_gmem1_rdata;
  wire [5:0] sig_m_axi_gmem1_rid;
  wire sig_m_axi_gmem1_rlast;
  wire sig_m_axi_gmem1_rready;
  wire [1:0] sig_m_axi_gmem1_rresp;
  wire sig_m_axi_gmem1_ruser;
  wire sig_m_axi_gmem1_rvalid;
  wire [31:0] sig_m_axi_gmem1_wdata;
  wire sig_m_axi_gmem1_wlast;
  wire sig_m_axi_gmem1_wready;
  wire [3:0] sig_m_axi_gmem1_wstrb;
  wire sig_m_axi_gmem1_wuser;
  wire sig_m_axi_gmem1_wvalid;
  wire [31:0] sig_m_axi_gmem2_b0_araddr;
  wire [1:0] sig_m_axi_gmem2_b0_arburst;
  wire [3:0] sig_m_axi_gmem2_b0_arcache;
  wire [5:0] sig_m_axi_gmem2_b0_arid;
  wire [7:0] sig_m_axi_gmem2_b0_arlen;
  wire sig_m_axi_gmem2_b0_arlock;
  wire [2:0] sig_m_axi_gmem2_b0_arprot;
  wire [3:0] sig_m_axi_gmem2_b0_arqos;
  wire sig_m_axi_gmem2_b0_arready;
  wire [3:0] sig_m_axi_gmem2_b0_arregion;
  wire [2:0] sig_m_axi_gmem2_b0_arsize;
  wire sig_m_axi_gmem2_b0_aruser;
  wire sig_m_axi_gmem2_b0_arvalid;
  wire [31:0] sig_m_axi_gmem2_b0_awaddr;
  wire [1:0] sig_m_axi_gmem2_b0_awburst;
  wire [3:0] sig_m_axi_gmem2_b0_awcache;
  wire [5:0] sig_m_axi_gmem2_b0_awid;
  wire [7:0] sig_m_axi_gmem2_b0_awlen;
  wire sig_m_axi_gmem2_b0_awlock;
  wire [2:0] sig_m_axi_gmem2_b0_awprot;
  wire [3:0] sig_m_axi_gmem2_b0_awqos;
  wire sig_m_axi_gmem2_b0_awready;
  wire [3:0] sig_m_axi_gmem2_b0_awregion;
  wire [2:0] sig_m_axi_gmem2_b0_awsize;
  wire sig_m_axi_gmem2_b0_awuser;
  wire sig_m_axi_gmem2_b0_awvalid;
  wire [5:0] sig_m_axi_gmem2_b0_bid;
  wire sig_m_axi_gmem2_b0_bready;
  wire [1:0] sig_m_axi_gmem2_b0_bresp;
  wire sig_m_axi_gmem2_b0_buser;
  wire sig_m_axi_gmem2_b0_bvalid;
  wire [31:0] sig_m_axi_gmem2_b0_rdata;
  wire [5:0] sig_m_axi_gmem2_b0_rid;
  wire sig_m_axi_gmem2_b0_rlast;
  wire sig_m_axi_gmem2_b0_rready;
  wire [1:0] sig_m_axi_gmem2_b0_rresp;
  wire sig_m_axi_gmem2_b0_ruser;
  wire sig_m_axi_gmem2_b0_rvalid;
  wire [31:0] sig_m_axi_gmem2_b0_wdata;
  wire sig_m_axi_gmem2_b0_wlast;
  wire sig_m_axi_gmem2_b0_wready;
  wire [3:0] sig_m_axi_gmem2_b0_wstrb;
  wire sig_m_axi_gmem2_b0_wuser;
  wire sig_m_axi_gmem2_b0_wvalid;
  wire [31:0] sig_m_axi_gmem2_b1_araddr;
  wire [1:0] sig_m_axi_gmem2_b1_arburst;
  wire [3:0] sig_m_axi_gmem2_b1_arcache;
  wire [5:0] sig_m_axi_gmem2_b1_arid;
  wire [7:0] sig_m_axi_gmem2_b1_arlen;
  wire sig_m_axi_gmem2_b1_arlock;
  wire [2:0] sig_m_axi_gmem2_b1_arprot;
  wire [3:0] sig_m_axi_gmem2_b1_arqos;
  wire sig_m_axi_gmem2_b1_arready;
  wire [3:0] sig_m_axi_gmem2_b1_arregion;
  wire [2:0] sig_m_axi_gmem2_b1_arsize;
  wire sig_m_axi_gmem2_b1_aruser;
  wire sig_m_axi_gmem2_b1_arvalid;
  wire [31:0] sig_m_axi_gmem2_b1_awaddr;
  wire [1:0] sig_m_axi_gmem2_b1_awburst;
  wire [3:0] sig_m_axi_gmem2_b1_awcache;
  wire [5:0] sig_m_axi_gmem2_b1_awid;
  wire [7:0] sig_m_axi_gmem2_b1_awlen;
  wire sig_m_axi_gmem2_b1_awlock;
  wire [2:0] sig_m_axi_gmem2_b1_awprot;
  wire [3:0] sig_m_axi_gmem2_b1_awqos;
  wire sig_m_axi_gmem2_b1_awready;
  wire [3:0] sig_m_axi_gmem2_b1_awregion;
  wire [2:0] sig_m_axi_gmem2_b1_awsize;
  wire sig_m_axi_gmem2_b1_awuser;
  wire sig_m_axi_gmem2_b1_awvalid;
  wire [5:0] sig_m_axi_gmem2_b1_bid;
  wire sig_m_axi_gmem2_b1_bready;
  wire [1:0] sig_m_axi_gmem2_b1_bresp;
  wire sig_m_axi_gmem2_b1_buser;
  wire sig_m_axi_gmem2_b1_bvalid;
  wire [31:0] sig_m_axi_gmem2_b1_rdata;
  wire [5:0] sig_m_axi_gmem2_b1_rid;
  wire sig_m_axi_gmem2_b1_rlast;
  wire sig_m_axi_gmem2_b1_rready;
  wire [1:0] sig_m_axi_gmem2_b1_rresp;
  wire sig_m_axi_gmem2_b1_ruser;
  wire sig_m_axi_gmem2_b1_rvalid;
  wire [31:0] sig_m_axi_gmem2_b1_wdata;
  wire sig_m_axi_gmem2_b1_wlast;
  wire sig_m_axi_gmem2_b1_wready;
  wire [3:0] sig_m_axi_gmem2_b1_wstrb;
  wire sig_m_axi_gmem2_b1_wuser;
  wire sig_m_axi_gmem2_b1_wvalid;
  wire [31:0] sig_m_axi_gmem2_b2_araddr;
  wire [1:0] sig_m_axi_gmem2_b2_arburst;
  wire [3:0] sig_m_axi_gmem2_b2_arcache;
  wire [5:0] sig_m_axi_gmem2_b2_arid;
  wire [7:0] sig_m_axi_gmem2_b2_arlen;
  wire sig_m_axi_gmem2_b2_arlock;
  wire [2:0] sig_m_axi_gmem2_b2_arprot;
  wire [3:0] sig_m_axi_gmem2_b2_arqos;
  wire sig_m_axi_gmem2_b2_arready;
  wire [3:0] sig_m_axi_gmem2_b2_arregion;
  wire [2:0] sig_m_axi_gmem2_b2_arsize;
  wire sig_m_axi_gmem2_b2_aruser;
  wire sig_m_axi_gmem2_b2_arvalid;
  wire [31:0] sig_m_axi_gmem2_b2_awaddr;
  wire [1:0] sig_m_axi_gmem2_b2_awburst;
  wire [3:0] sig_m_axi_gmem2_b2_awcache;
  wire [5:0] sig_m_axi_gmem2_b2_awid;
  wire [7:0] sig_m_axi_gmem2_b2_awlen;
  wire sig_m_axi_gmem2_b2_awlock;
  wire [2:0] sig_m_axi_gmem2_b2_awprot;
  wire [3:0] sig_m_axi_gmem2_b2_awqos;
  wire sig_m_axi_gmem2_b2_awready;
  wire [3:0] sig_m_axi_gmem2_b2_awregion;
  wire [2:0] sig_m_axi_gmem2_b2_awsize;
  wire sig_m_axi_gmem2_b2_awuser;
  wire sig_m_axi_gmem2_b2_awvalid;
  wire [5:0] sig_m_axi_gmem2_b2_bid;
  wire sig_m_axi_gmem2_b2_bready;
  wire [1:0] sig_m_axi_gmem2_b2_bresp;
  wire sig_m_axi_gmem2_b2_buser;
  wire sig_m_axi_gmem2_b2_bvalid;
  wire [31:0] sig_m_axi_gmem2_b2_rdata;
  wire [5:0] sig_m_axi_gmem2_b2_rid;
  wire sig_m_axi_gmem2_b2_rlast;
  wire sig_m_axi_gmem2_b2_rready;
  wire [1:0] sig_m_axi_gmem2_b2_rresp;
  wire sig_m_axi_gmem2_b2_ruser;
  wire sig_m_axi_gmem2_b2_rvalid;
  wire [31:0] sig_m_axi_gmem2_b2_wdata;
  wire sig_m_axi_gmem2_b2_wlast;
  wire sig_m_axi_gmem2_b2_wready;
  wire [3:0] sig_m_axi_gmem2_b2_wstrb;
  wire sig_m_axi_gmem2_b2_wuser;
  wire sig_m_axi_gmem2_b2_wvalid;
  wire [31:0] sig_m_axi_gmem2_b3_araddr;
  wire [1:0] sig_m_axi_gmem2_b3_arburst;
  wire [3:0] sig_m_axi_gmem2_b3_arcache;
  wire [5:0] sig_m_axi_gmem2_b3_arid;
  wire [7:0] sig_m_axi_gmem2_b3_arlen;
  wire sig_m_axi_gmem2_b3_arlock;
  wire [2:0] sig_m_axi_gmem2_b3_arprot;
  wire [3:0] sig_m_axi_gmem2_b3_arqos;
  wire sig_m_axi_gmem2_b3_arready;
  wire [3:0] sig_m_axi_gmem2_b3_arregion;
  wire [2:0] sig_m_axi_gmem2_b3_arsize;
  wire sig_m_axi_gmem2_b3_aruser;
  wire sig_m_axi_gmem2_b3_arvalid;
  wire [31:0] sig_m_axi_gmem2_b3_awaddr;
  wire [1:0] sig_m_axi_gmem2_b3_awburst;
  wire [3:0] sig_m_axi_gmem2_b3_awcache;
  wire [5:0] sig_m_axi_gmem2_b3_awid;
  wire [7:0] sig_m_axi_gmem2_b3_awlen;
  wire sig_m_axi_gmem2_b3_awlock;
  wire [2:0] sig_m_axi_gmem2_b3_awprot;
  wire [3:0] sig_m_axi_gmem2_b3_awqos;
  wire sig_m_axi_gmem2_b3_awready;
  wire [3:0] sig_m_axi_gmem2_b3_awregion;
  wire [2:0] sig_m_axi_gmem2_b3_awsize;
  wire sig_m_axi_gmem2_b3_awuser;
  wire sig_m_axi_gmem2_b3_awvalid;
  wire [5:0] sig_m_axi_gmem2_b3_bid;
  wire sig_m_axi_gmem2_b3_bready;
  wire [1:0] sig_m_axi_gmem2_b3_bresp;
  wire sig_m_axi_gmem2_b3_buser;
  wire sig_m_axi_gmem2_b3_bvalid;
  wire [31:0] sig_m_axi_gmem2_b3_rdata;
  wire [5:0] sig_m_axi_gmem2_b3_rid;
  wire sig_m_axi_gmem2_b3_rlast;
  wire sig_m_axi_gmem2_b3_rready;
  wire [1:0] sig_m_axi_gmem2_b3_rresp;
  wire sig_m_axi_gmem2_b3_ruser;
  wire sig_m_axi_gmem2_b3_rvalid;
  wire [31:0] sig_m_axi_gmem2_b3_wdata;
  wire sig_m_axi_gmem2_b3_wlast;
  wire sig_m_axi_gmem2_b3_wready;
  wire [3:0] sig_m_axi_gmem2_b3_wstrb;
  wire sig_m_axi_gmem2_b3_wuser;
  wire sig_m_axi_gmem2_b3_wvalid;
  wire [31:0] sig_m_axi_gmem2_b4_araddr;
  wire [1:0] sig_m_axi_gmem2_b4_arburst;
  wire [3:0] sig_m_axi_gmem2_b4_arcache;
  wire [5:0] sig_m_axi_gmem2_b4_arid;
  wire [7:0] sig_m_axi_gmem2_b4_arlen;
  wire sig_m_axi_gmem2_b4_arlock;
  wire [2:0] sig_m_axi_gmem2_b4_arprot;
  wire [3:0] sig_m_axi_gmem2_b4_arqos;
  wire sig_m_axi_gmem2_b4_arready;
  wire [3:0] sig_m_axi_gmem2_b4_arregion;
  wire [2:0] sig_m_axi_gmem2_b4_arsize;
  wire sig_m_axi_gmem2_b4_aruser;
  wire sig_m_axi_gmem2_b4_arvalid;
  wire [31:0] sig_m_axi_gmem2_b4_awaddr;
  wire [1:0] sig_m_axi_gmem2_b4_awburst;
  wire [3:0] sig_m_axi_gmem2_b4_awcache;
  wire [5:0] sig_m_axi_gmem2_b4_awid;
  wire [7:0] sig_m_axi_gmem2_b4_awlen;
  wire sig_m_axi_gmem2_b4_awlock;
  wire [2:0] sig_m_axi_gmem2_b4_awprot;
  wire [3:0] sig_m_axi_gmem2_b4_awqos;
  wire sig_m_axi_gmem2_b4_awready;
  wire [3:0] sig_m_axi_gmem2_b4_awregion;
  wire [2:0] sig_m_axi_gmem2_b4_awsize;
  wire sig_m_axi_gmem2_b4_awuser;
  wire sig_m_axi_gmem2_b4_awvalid;
  wire [5:0] sig_m_axi_gmem2_b4_bid;
  wire sig_m_axi_gmem2_b4_bready;
  wire [1:0] sig_m_axi_gmem2_b4_bresp;
  wire sig_m_axi_gmem2_b4_buser;
  wire sig_m_axi_gmem2_b4_bvalid;
  wire [31:0] sig_m_axi_gmem2_b4_rdata;
  wire [5:0] sig_m_axi_gmem2_b4_rid;
  wire sig_m_axi_gmem2_b4_rlast;
  wire sig_m_axi_gmem2_b4_rready;
  wire [1:0] sig_m_axi_gmem2_b4_rresp;
  wire sig_m_axi_gmem2_b4_ruser;
  wire sig_m_axi_gmem2_b4_rvalid;
  wire [31:0] sig_m_axi_gmem2_b4_wdata;
  wire sig_m_axi_gmem2_b4_wlast;
  wire sig_m_axi_gmem2_b4_wready;
  wire [3:0] sig_m_axi_gmem2_b4_wstrb;
  wire sig_m_axi_gmem2_b4_wuser;
  wire sig_m_axi_gmem2_b4_wvalid;
  wire [31:0] sig_m_axi_gmem2_b5_araddr;
  wire [1:0] sig_m_axi_gmem2_b5_arburst;
  wire [3:0] sig_m_axi_gmem2_b5_arcache;
  wire [5:0] sig_m_axi_gmem2_b5_arid;
  wire [7:0] sig_m_axi_gmem2_b5_arlen;
  wire sig_m_axi_gmem2_b5_arlock;
  wire [2:0] sig_m_axi_gmem2_b5_arprot;
  wire [3:0] sig_m_axi_gmem2_b5_arqos;
  wire sig_m_axi_gmem2_b5_arready;
  wire [3:0] sig_m_axi_gmem2_b5_arregion;
  wire [2:0] sig_m_axi_gmem2_b5_arsize;
  wire sig_m_axi_gmem2_b5_aruser;
  wire sig_m_axi_gmem2_b5_arvalid;
  wire [31:0] sig_m_axi_gmem2_b5_awaddr;
  wire [1:0] sig_m_axi_gmem2_b5_awburst;
  wire [3:0] sig_m_axi_gmem2_b5_awcache;
  wire [5:0] sig_m_axi_gmem2_b5_awid;
  wire [7:0] sig_m_axi_gmem2_b5_awlen;
  wire sig_m_axi_gmem2_b5_awlock;
  wire [2:0] sig_m_axi_gmem2_b5_awprot;
  wire [3:0] sig_m_axi_gmem2_b5_awqos;
  wire sig_m_axi_gmem2_b5_awready;
  wire [3:0] sig_m_axi_gmem2_b5_awregion;
  wire [2:0] sig_m_axi_gmem2_b5_awsize;
  wire sig_m_axi_gmem2_b5_awuser;
  wire sig_m_axi_gmem2_b5_awvalid;
  wire [5:0] sig_m_axi_gmem2_b5_bid;
  wire sig_m_axi_gmem2_b5_bready;
  wire [1:0] sig_m_axi_gmem2_b5_bresp;
  wire sig_m_axi_gmem2_b5_buser;
  wire sig_m_axi_gmem2_b5_bvalid;
  wire [31:0] sig_m_axi_gmem2_b5_rdata;
  wire [5:0] sig_m_axi_gmem2_b5_rid;
  wire sig_m_axi_gmem2_b5_rlast;
  wire sig_m_axi_gmem2_b5_rready;
  wire [1:0] sig_m_axi_gmem2_b5_rresp;
  wire sig_m_axi_gmem2_b5_ruser;
  wire sig_m_axi_gmem2_b5_rvalid;
  wire [31:0] sig_m_axi_gmem2_b5_wdata;
  wire sig_m_axi_gmem2_b5_wlast;
  wire sig_m_axi_gmem2_b5_wready;
  wire [3:0] sig_m_axi_gmem2_b5_wstrb;
  wire sig_m_axi_gmem2_b5_wuser;
  wire sig_m_axi_gmem2_b5_wvalid;
  wire [31:0] sig_m_axi_gmem2_b6_araddr;
  wire [1:0] sig_m_axi_gmem2_b6_arburst;
  wire [3:0] sig_m_axi_gmem2_b6_arcache;
  wire [5:0] sig_m_axi_gmem2_b6_arid;
  wire [7:0] sig_m_axi_gmem2_b6_arlen;
  wire sig_m_axi_gmem2_b6_arlock;
  wire [2:0] sig_m_axi_gmem2_b6_arprot;
  wire [3:0] sig_m_axi_gmem2_b6_arqos;
  wire sig_m_axi_gmem2_b6_arready;
  wire [3:0] sig_m_axi_gmem2_b6_arregion;
  wire [2:0] sig_m_axi_gmem2_b6_arsize;
  wire sig_m_axi_gmem2_b6_aruser;
  wire sig_m_axi_gmem2_b6_arvalid;
  wire [31:0] sig_m_axi_gmem2_b6_awaddr;
  wire [1:0] sig_m_axi_gmem2_b6_awburst;
  wire [3:0] sig_m_axi_gmem2_b6_awcache;
  wire [5:0] sig_m_axi_gmem2_b6_awid;
  wire [7:0] sig_m_axi_gmem2_b6_awlen;
  wire sig_m_axi_gmem2_b6_awlock;
  wire [2:0] sig_m_axi_gmem2_b6_awprot;
  wire [3:0] sig_m_axi_gmem2_b6_awqos;
  wire sig_m_axi_gmem2_b6_awready;
  wire [3:0] sig_m_axi_gmem2_b6_awregion;
  wire [2:0] sig_m_axi_gmem2_b6_awsize;
  wire sig_m_axi_gmem2_b6_awuser;
  wire sig_m_axi_gmem2_b6_awvalid;
  wire [5:0] sig_m_axi_gmem2_b6_bid;
  wire sig_m_axi_gmem2_b6_bready;
  wire [1:0] sig_m_axi_gmem2_b6_bresp;
  wire sig_m_axi_gmem2_b6_buser;
  wire sig_m_axi_gmem2_b6_bvalid;
  wire [31:0] sig_m_axi_gmem2_b6_rdata;
  wire [5:0] sig_m_axi_gmem2_b6_rid;
  wire sig_m_axi_gmem2_b6_rlast;
  wire sig_m_axi_gmem2_b6_rready;
  wire [1:0] sig_m_axi_gmem2_b6_rresp;
  wire sig_m_axi_gmem2_b6_ruser;
  wire sig_m_axi_gmem2_b6_rvalid;
  wire [31:0] sig_m_axi_gmem2_b6_wdata;
  wire sig_m_axi_gmem2_b6_wlast;
  wire sig_m_axi_gmem2_b6_wready;
  wire [3:0] sig_m_axi_gmem2_b6_wstrb;
  wire sig_m_axi_gmem2_b6_wuser;
  wire sig_m_axi_gmem2_b6_wvalid;
  wire [31:0] sig_m_axi_gmem2_b7_araddr;
  wire [1:0] sig_m_axi_gmem2_b7_arburst;
  wire [3:0] sig_m_axi_gmem2_b7_arcache;
  wire [5:0] sig_m_axi_gmem2_b7_arid;
  wire [7:0] sig_m_axi_gmem2_b7_arlen;
  wire sig_m_axi_gmem2_b7_arlock;
  wire [2:0] sig_m_axi_gmem2_b7_arprot;
  wire [3:0] sig_m_axi_gmem2_b7_arqos;
  wire sig_m_axi_gmem2_b7_arready;
  wire [3:0] sig_m_axi_gmem2_b7_arregion;
  wire [2:0] sig_m_axi_gmem2_b7_arsize;
  wire sig_m_axi_gmem2_b7_aruser;
  wire sig_m_axi_gmem2_b7_arvalid;
  wire [31:0] sig_m_axi_gmem2_b7_awaddr;
  wire [1:0] sig_m_axi_gmem2_b7_awburst;
  wire [3:0] sig_m_axi_gmem2_b7_awcache;
  wire [5:0] sig_m_axi_gmem2_b7_awid;
  wire [7:0] sig_m_axi_gmem2_b7_awlen;
  wire sig_m_axi_gmem2_b7_awlock;
  wire [2:0] sig_m_axi_gmem2_b7_awprot;
  wire [3:0] sig_m_axi_gmem2_b7_awqos;
  wire sig_m_axi_gmem2_b7_awready;
  wire [3:0] sig_m_axi_gmem2_b7_awregion;
  wire [2:0] sig_m_axi_gmem2_b7_awsize;
  wire sig_m_axi_gmem2_b7_awuser;
  wire sig_m_axi_gmem2_b7_awvalid;
  wire [5:0] sig_m_axi_gmem2_b7_bid;
  wire sig_m_axi_gmem2_b7_bready;
  wire [1:0] sig_m_axi_gmem2_b7_bresp;
  wire sig_m_axi_gmem2_b7_buser;
  wire sig_m_axi_gmem2_b7_bvalid;
  wire [31:0] sig_m_axi_gmem2_b7_rdata;
  wire [5:0] sig_m_axi_gmem2_b7_rid;
  wire sig_m_axi_gmem2_b7_rlast;
  wire sig_m_axi_gmem2_b7_rready;
  wire [1:0] sig_m_axi_gmem2_b7_rresp;
  wire sig_m_axi_gmem2_b7_ruser;
  wire sig_m_axi_gmem2_b7_rvalid;
  wire [31:0] sig_m_axi_gmem2_b7_wdata;
  wire sig_m_axi_gmem2_b7_wlast;
  wire sig_m_axi_gmem2_b7_wready;
  wire [3:0] sig_m_axi_gmem2_b7_wstrb;
  wire sig_m_axi_gmem2_b7_wuser;
  wire sig_m_axi_gmem2_b7_wvalid;
  wire sig_reset;
  wire sig_setup_port;
  wire sig_start_port;
  
  TestbenchDUT DUT (.done_port(sig_done_port),
    .m_axi_gmem0_awid(sig_m_axi_gmem0_awid),
    .m_axi_gmem0_awaddr(sig_m_axi_gmem0_awaddr),
    .m_axi_gmem0_awlen(sig_m_axi_gmem0_awlen),
    .m_axi_gmem0_awsize(sig_m_axi_gmem0_awsize),
    .m_axi_gmem0_awburst(sig_m_axi_gmem0_awburst),
    .m_axi_gmem0_awlock(sig_m_axi_gmem0_awlock),
    .m_axi_gmem0_awcache(sig_m_axi_gmem0_awcache),
    .m_axi_gmem0_awprot(sig_m_axi_gmem0_awprot),
    .m_axi_gmem0_awqos(sig_m_axi_gmem0_awqos),
    .m_axi_gmem0_awregion(sig_m_axi_gmem0_awregion),
    .m_axi_gmem0_awuser(sig_m_axi_gmem0_awuser),
    .m_axi_gmem0_awvalid(sig_m_axi_gmem0_awvalid),
    .m_axi_gmem0_wdata(sig_m_axi_gmem0_wdata),
    .m_axi_gmem0_wstrb(sig_m_axi_gmem0_wstrb),
    .m_axi_gmem0_wlast(sig_m_axi_gmem0_wlast),
    .m_axi_gmem0_wuser(sig_m_axi_gmem0_wuser),
    .m_axi_gmem0_wvalid(sig_m_axi_gmem0_wvalid),
    .m_axi_gmem0_bready(sig_m_axi_gmem0_bready),
    .m_axi_gmem0_arid(sig_m_axi_gmem0_arid),
    .m_axi_gmem0_araddr(sig_m_axi_gmem0_araddr),
    .m_axi_gmem0_arlen(sig_m_axi_gmem0_arlen),
    .m_axi_gmem0_arsize(sig_m_axi_gmem0_arsize),
    .m_axi_gmem0_arburst(sig_m_axi_gmem0_arburst),
    .m_axi_gmem0_arlock(sig_m_axi_gmem0_arlock),
    .m_axi_gmem0_arcache(sig_m_axi_gmem0_arcache),
    .m_axi_gmem0_arprot(sig_m_axi_gmem0_arprot),
    .m_axi_gmem0_arqos(sig_m_axi_gmem0_arqos),
    .m_axi_gmem0_arregion(sig_m_axi_gmem0_arregion),
    .m_axi_gmem0_aruser(sig_m_axi_gmem0_aruser),
    .m_axi_gmem0_arvalid(sig_m_axi_gmem0_arvalid),
    .m_axi_gmem0_rready(sig_m_axi_gmem0_rready),
    .m_axi_gmem1_awid(sig_m_axi_gmem1_awid),
    .m_axi_gmem1_awaddr(sig_m_axi_gmem1_awaddr),
    .m_axi_gmem1_awlen(sig_m_axi_gmem1_awlen),
    .m_axi_gmem1_awsize(sig_m_axi_gmem1_awsize),
    .m_axi_gmem1_awburst(sig_m_axi_gmem1_awburst),
    .m_axi_gmem1_awlock(sig_m_axi_gmem1_awlock),
    .m_axi_gmem1_awcache(sig_m_axi_gmem1_awcache),
    .m_axi_gmem1_awprot(sig_m_axi_gmem1_awprot),
    .m_axi_gmem1_awqos(sig_m_axi_gmem1_awqos),
    .m_axi_gmem1_awregion(sig_m_axi_gmem1_awregion),
    .m_axi_gmem1_awuser(sig_m_axi_gmem1_awuser),
    .m_axi_gmem1_awvalid(sig_m_axi_gmem1_awvalid),
    .m_axi_gmem1_wdata(sig_m_axi_gmem1_wdata),
    .m_axi_gmem1_wstrb(sig_m_axi_gmem1_wstrb),
    .m_axi_gmem1_wlast(sig_m_axi_gmem1_wlast),
    .m_axi_gmem1_wuser(sig_m_axi_gmem1_wuser),
    .m_axi_gmem1_wvalid(sig_m_axi_gmem1_wvalid),
    .m_axi_gmem1_bready(sig_m_axi_gmem1_bready),
    .m_axi_gmem1_arid(sig_m_axi_gmem1_arid),
    .m_axi_gmem1_araddr(sig_m_axi_gmem1_araddr),
    .m_axi_gmem1_arlen(sig_m_axi_gmem1_arlen),
    .m_axi_gmem1_arsize(sig_m_axi_gmem1_arsize),
    .m_axi_gmem1_arburst(sig_m_axi_gmem1_arburst),
    .m_axi_gmem1_arlock(sig_m_axi_gmem1_arlock),
    .m_axi_gmem1_arcache(sig_m_axi_gmem1_arcache),
    .m_axi_gmem1_arprot(sig_m_axi_gmem1_arprot),
    .m_axi_gmem1_arqos(sig_m_axi_gmem1_arqos),
    .m_axi_gmem1_arregion(sig_m_axi_gmem1_arregion),
    .m_axi_gmem1_aruser(sig_m_axi_gmem1_aruser),
    .m_axi_gmem1_arvalid(sig_m_axi_gmem1_arvalid),
    .m_axi_gmem1_rready(sig_m_axi_gmem1_rready),
    .m_axi_gmem2_b0_awid(sig_m_axi_gmem2_b0_awid),
    .m_axi_gmem2_b0_awaddr(sig_m_axi_gmem2_b0_awaddr),
    .m_axi_gmem2_b0_awlen(sig_m_axi_gmem2_b0_awlen),
    .m_axi_gmem2_b0_awsize(sig_m_axi_gmem2_b0_awsize),
    .m_axi_gmem2_b0_awburst(sig_m_axi_gmem2_b0_awburst),
    .m_axi_gmem2_b0_awlock(sig_m_axi_gmem2_b0_awlock),
    .m_axi_gmem2_b0_awcache(sig_m_axi_gmem2_b0_awcache),
    .m_axi_gmem2_b0_awprot(sig_m_axi_gmem2_b0_awprot),
    .m_axi_gmem2_b0_awqos(sig_m_axi_gmem2_b0_awqos),
    .m_axi_gmem2_b0_awregion(sig_m_axi_gmem2_b0_awregion),
    .m_axi_gmem2_b0_awuser(sig_m_axi_gmem2_b0_awuser),
    .m_axi_gmem2_b0_awvalid(sig_m_axi_gmem2_b0_awvalid),
    .m_axi_gmem2_b0_wdata(sig_m_axi_gmem2_b0_wdata),
    .m_axi_gmem2_b0_wstrb(sig_m_axi_gmem2_b0_wstrb),
    .m_axi_gmem2_b0_wlast(sig_m_axi_gmem2_b0_wlast),
    .m_axi_gmem2_b0_wuser(sig_m_axi_gmem2_b0_wuser),
    .m_axi_gmem2_b0_wvalid(sig_m_axi_gmem2_b0_wvalid),
    .m_axi_gmem2_b0_bready(sig_m_axi_gmem2_b0_bready),
    .m_axi_gmem2_b0_arid(sig_m_axi_gmem2_b0_arid),
    .m_axi_gmem2_b0_araddr(sig_m_axi_gmem2_b0_araddr),
    .m_axi_gmem2_b0_arlen(sig_m_axi_gmem2_b0_arlen),
    .m_axi_gmem2_b0_arsize(sig_m_axi_gmem2_b0_arsize),
    .m_axi_gmem2_b0_arburst(sig_m_axi_gmem2_b0_arburst),
    .m_axi_gmem2_b0_arlock(sig_m_axi_gmem2_b0_arlock),
    .m_axi_gmem2_b0_arcache(sig_m_axi_gmem2_b0_arcache),
    .m_axi_gmem2_b0_arprot(sig_m_axi_gmem2_b0_arprot),
    .m_axi_gmem2_b0_arqos(sig_m_axi_gmem2_b0_arqos),
    .m_axi_gmem2_b0_arregion(sig_m_axi_gmem2_b0_arregion),
    .m_axi_gmem2_b0_aruser(sig_m_axi_gmem2_b0_aruser),
    .m_axi_gmem2_b0_arvalid(sig_m_axi_gmem2_b0_arvalid),
    .m_axi_gmem2_b0_rready(sig_m_axi_gmem2_b0_rready),
    .m_axi_gmem2_b1_awid(sig_m_axi_gmem2_b1_awid),
    .m_axi_gmem2_b1_awaddr(sig_m_axi_gmem2_b1_awaddr),
    .m_axi_gmem2_b1_awlen(sig_m_axi_gmem2_b1_awlen),
    .m_axi_gmem2_b1_awsize(sig_m_axi_gmem2_b1_awsize),
    .m_axi_gmem2_b1_awburst(sig_m_axi_gmem2_b1_awburst),
    .m_axi_gmem2_b1_awlock(sig_m_axi_gmem2_b1_awlock),
    .m_axi_gmem2_b1_awcache(sig_m_axi_gmem2_b1_awcache),
    .m_axi_gmem2_b1_awprot(sig_m_axi_gmem2_b1_awprot),
    .m_axi_gmem2_b1_awqos(sig_m_axi_gmem2_b1_awqos),
    .m_axi_gmem2_b1_awregion(sig_m_axi_gmem2_b1_awregion),
    .m_axi_gmem2_b1_awuser(sig_m_axi_gmem2_b1_awuser),
    .m_axi_gmem2_b1_awvalid(sig_m_axi_gmem2_b1_awvalid),
    .m_axi_gmem2_b1_wdata(sig_m_axi_gmem2_b1_wdata),
    .m_axi_gmem2_b1_wstrb(sig_m_axi_gmem2_b1_wstrb),
    .m_axi_gmem2_b1_wlast(sig_m_axi_gmem2_b1_wlast),
    .m_axi_gmem2_b1_wuser(sig_m_axi_gmem2_b1_wuser),
    .m_axi_gmem2_b1_wvalid(sig_m_axi_gmem2_b1_wvalid),
    .m_axi_gmem2_b1_bready(sig_m_axi_gmem2_b1_bready),
    .m_axi_gmem2_b1_arid(sig_m_axi_gmem2_b1_arid),
    .m_axi_gmem2_b1_araddr(sig_m_axi_gmem2_b1_araddr),
    .m_axi_gmem2_b1_arlen(sig_m_axi_gmem2_b1_arlen),
    .m_axi_gmem2_b1_arsize(sig_m_axi_gmem2_b1_arsize),
    .m_axi_gmem2_b1_arburst(sig_m_axi_gmem2_b1_arburst),
    .m_axi_gmem2_b1_arlock(sig_m_axi_gmem2_b1_arlock),
    .m_axi_gmem2_b1_arcache(sig_m_axi_gmem2_b1_arcache),
    .m_axi_gmem2_b1_arprot(sig_m_axi_gmem2_b1_arprot),
    .m_axi_gmem2_b1_arqos(sig_m_axi_gmem2_b1_arqos),
    .m_axi_gmem2_b1_arregion(sig_m_axi_gmem2_b1_arregion),
    .m_axi_gmem2_b1_aruser(sig_m_axi_gmem2_b1_aruser),
    .m_axi_gmem2_b1_arvalid(sig_m_axi_gmem2_b1_arvalid),
    .m_axi_gmem2_b1_rready(sig_m_axi_gmem2_b1_rready),
    .m_axi_gmem2_b2_awid(sig_m_axi_gmem2_b2_awid),
    .m_axi_gmem2_b2_awaddr(sig_m_axi_gmem2_b2_awaddr),
    .m_axi_gmem2_b2_awlen(sig_m_axi_gmem2_b2_awlen),
    .m_axi_gmem2_b2_awsize(sig_m_axi_gmem2_b2_awsize),
    .m_axi_gmem2_b2_awburst(sig_m_axi_gmem2_b2_awburst),
    .m_axi_gmem2_b2_awlock(sig_m_axi_gmem2_b2_awlock),
    .m_axi_gmem2_b2_awcache(sig_m_axi_gmem2_b2_awcache),
    .m_axi_gmem2_b2_awprot(sig_m_axi_gmem2_b2_awprot),
    .m_axi_gmem2_b2_awqos(sig_m_axi_gmem2_b2_awqos),
    .m_axi_gmem2_b2_awregion(sig_m_axi_gmem2_b2_awregion),
    .m_axi_gmem2_b2_awuser(sig_m_axi_gmem2_b2_awuser),
    .m_axi_gmem2_b2_awvalid(sig_m_axi_gmem2_b2_awvalid),
    .m_axi_gmem2_b2_wdata(sig_m_axi_gmem2_b2_wdata),
    .m_axi_gmem2_b2_wstrb(sig_m_axi_gmem2_b2_wstrb),
    .m_axi_gmem2_b2_wlast(sig_m_axi_gmem2_b2_wlast),
    .m_axi_gmem2_b2_wuser(sig_m_axi_gmem2_b2_wuser),
    .m_axi_gmem2_b2_wvalid(sig_m_axi_gmem2_b2_wvalid),
    .m_axi_gmem2_b2_bready(sig_m_axi_gmem2_b2_bready),
    .m_axi_gmem2_b2_arid(sig_m_axi_gmem2_b2_arid),
    .m_axi_gmem2_b2_araddr(sig_m_axi_gmem2_b2_araddr),
    .m_axi_gmem2_b2_arlen(sig_m_axi_gmem2_b2_arlen),
    .m_axi_gmem2_b2_arsize(sig_m_axi_gmem2_b2_arsize),
    .m_axi_gmem2_b2_arburst(sig_m_axi_gmem2_b2_arburst),
    .m_axi_gmem2_b2_arlock(sig_m_axi_gmem2_b2_arlock),
    .m_axi_gmem2_b2_arcache(sig_m_axi_gmem2_b2_arcache),
    .m_axi_gmem2_b2_arprot(sig_m_axi_gmem2_b2_arprot),
    .m_axi_gmem2_b2_arqos(sig_m_axi_gmem2_b2_arqos),
    .m_axi_gmem2_b2_arregion(sig_m_axi_gmem2_b2_arregion),
    .m_axi_gmem2_b2_aruser(sig_m_axi_gmem2_b2_aruser),
    .m_axi_gmem2_b2_arvalid(sig_m_axi_gmem2_b2_arvalid),
    .m_axi_gmem2_b2_rready(sig_m_axi_gmem2_b2_rready),
    .m_axi_gmem2_b3_awid(sig_m_axi_gmem2_b3_awid),
    .m_axi_gmem2_b3_awaddr(sig_m_axi_gmem2_b3_awaddr),
    .m_axi_gmem2_b3_awlen(sig_m_axi_gmem2_b3_awlen),
    .m_axi_gmem2_b3_awsize(sig_m_axi_gmem2_b3_awsize),
    .m_axi_gmem2_b3_awburst(sig_m_axi_gmem2_b3_awburst),
    .m_axi_gmem2_b3_awlock(sig_m_axi_gmem2_b3_awlock),
    .m_axi_gmem2_b3_awcache(sig_m_axi_gmem2_b3_awcache),
    .m_axi_gmem2_b3_awprot(sig_m_axi_gmem2_b3_awprot),
    .m_axi_gmem2_b3_awqos(sig_m_axi_gmem2_b3_awqos),
    .m_axi_gmem2_b3_awregion(sig_m_axi_gmem2_b3_awregion),
    .m_axi_gmem2_b3_awuser(sig_m_axi_gmem2_b3_awuser),
    .m_axi_gmem2_b3_awvalid(sig_m_axi_gmem2_b3_awvalid),
    .m_axi_gmem2_b3_wdata(sig_m_axi_gmem2_b3_wdata),
    .m_axi_gmem2_b3_wstrb(sig_m_axi_gmem2_b3_wstrb),
    .m_axi_gmem2_b3_wlast(sig_m_axi_gmem2_b3_wlast),
    .m_axi_gmem2_b3_wuser(sig_m_axi_gmem2_b3_wuser),
    .m_axi_gmem2_b3_wvalid(sig_m_axi_gmem2_b3_wvalid),
    .m_axi_gmem2_b3_bready(sig_m_axi_gmem2_b3_bready),
    .m_axi_gmem2_b3_arid(sig_m_axi_gmem2_b3_arid),
    .m_axi_gmem2_b3_araddr(sig_m_axi_gmem2_b3_araddr),
    .m_axi_gmem2_b3_arlen(sig_m_axi_gmem2_b3_arlen),
    .m_axi_gmem2_b3_arsize(sig_m_axi_gmem2_b3_arsize),
    .m_axi_gmem2_b3_arburst(sig_m_axi_gmem2_b3_arburst),
    .m_axi_gmem2_b3_arlock(sig_m_axi_gmem2_b3_arlock),
    .m_axi_gmem2_b3_arcache(sig_m_axi_gmem2_b3_arcache),
    .m_axi_gmem2_b3_arprot(sig_m_axi_gmem2_b3_arprot),
    .m_axi_gmem2_b3_arqos(sig_m_axi_gmem2_b3_arqos),
    .m_axi_gmem2_b3_arregion(sig_m_axi_gmem2_b3_arregion),
    .m_axi_gmem2_b3_aruser(sig_m_axi_gmem2_b3_aruser),
    .m_axi_gmem2_b3_arvalid(sig_m_axi_gmem2_b3_arvalid),
    .m_axi_gmem2_b3_rready(sig_m_axi_gmem2_b3_rready),
    .m_axi_gmem2_b4_awid(sig_m_axi_gmem2_b4_awid),
    .m_axi_gmem2_b4_awaddr(sig_m_axi_gmem2_b4_awaddr),
    .m_axi_gmem2_b4_awlen(sig_m_axi_gmem2_b4_awlen),
    .m_axi_gmem2_b4_awsize(sig_m_axi_gmem2_b4_awsize),
    .m_axi_gmem2_b4_awburst(sig_m_axi_gmem2_b4_awburst),
    .m_axi_gmem2_b4_awlock(sig_m_axi_gmem2_b4_awlock),
    .m_axi_gmem2_b4_awcache(sig_m_axi_gmem2_b4_awcache),
    .m_axi_gmem2_b4_awprot(sig_m_axi_gmem2_b4_awprot),
    .m_axi_gmem2_b4_awqos(sig_m_axi_gmem2_b4_awqos),
    .m_axi_gmem2_b4_awregion(sig_m_axi_gmem2_b4_awregion),
    .m_axi_gmem2_b4_awuser(sig_m_axi_gmem2_b4_awuser),
    .m_axi_gmem2_b4_awvalid(sig_m_axi_gmem2_b4_awvalid),
    .m_axi_gmem2_b4_wdata(sig_m_axi_gmem2_b4_wdata),
    .m_axi_gmem2_b4_wstrb(sig_m_axi_gmem2_b4_wstrb),
    .m_axi_gmem2_b4_wlast(sig_m_axi_gmem2_b4_wlast),
    .m_axi_gmem2_b4_wuser(sig_m_axi_gmem2_b4_wuser),
    .m_axi_gmem2_b4_wvalid(sig_m_axi_gmem2_b4_wvalid),
    .m_axi_gmem2_b4_bready(sig_m_axi_gmem2_b4_bready),
    .m_axi_gmem2_b4_arid(sig_m_axi_gmem2_b4_arid),
    .m_axi_gmem2_b4_araddr(sig_m_axi_gmem2_b4_araddr),
    .m_axi_gmem2_b4_arlen(sig_m_axi_gmem2_b4_arlen),
    .m_axi_gmem2_b4_arsize(sig_m_axi_gmem2_b4_arsize),
    .m_axi_gmem2_b4_arburst(sig_m_axi_gmem2_b4_arburst),
    .m_axi_gmem2_b4_arlock(sig_m_axi_gmem2_b4_arlock),
    .m_axi_gmem2_b4_arcache(sig_m_axi_gmem2_b4_arcache),
    .m_axi_gmem2_b4_arprot(sig_m_axi_gmem2_b4_arprot),
    .m_axi_gmem2_b4_arqos(sig_m_axi_gmem2_b4_arqos),
    .m_axi_gmem2_b4_arregion(sig_m_axi_gmem2_b4_arregion),
    .m_axi_gmem2_b4_aruser(sig_m_axi_gmem2_b4_aruser),
    .m_axi_gmem2_b4_arvalid(sig_m_axi_gmem2_b4_arvalid),
    .m_axi_gmem2_b4_rready(sig_m_axi_gmem2_b4_rready),
    .m_axi_gmem2_b5_awid(sig_m_axi_gmem2_b5_awid),
    .m_axi_gmem2_b5_awaddr(sig_m_axi_gmem2_b5_awaddr),
    .m_axi_gmem2_b5_awlen(sig_m_axi_gmem2_b5_awlen),
    .m_axi_gmem2_b5_awsize(sig_m_axi_gmem2_b5_awsize),
    .m_axi_gmem2_b5_awburst(sig_m_axi_gmem2_b5_awburst),
    .m_axi_gmem2_b5_awlock(sig_m_axi_gmem2_b5_awlock),
    .m_axi_gmem2_b5_awcache(sig_m_axi_gmem2_b5_awcache),
    .m_axi_gmem2_b5_awprot(sig_m_axi_gmem2_b5_awprot),
    .m_axi_gmem2_b5_awqos(sig_m_axi_gmem2_b5_awqos),
    .m_axi_gmem2_b5_awregion(sig_m_axi_gmem2_b5_awregion),
    .m_axi_gmem2_b5_awuser(sig_m_axi_gmem2_b5_awuser),
    .m_axi_gmem2_b5_awvalid(sig_m_axi_gmem2_b5_awvalid),
    .m_axi_gmem2_b5_wdata(sig_m_axi_gmem2_b5_wdata),
    .m_axi_gmem2_b5_wstrb(sig_m_axi_gmem2_b5_wstrb),
    .m_axi_gmem2_b5_wlast(sig_m_axi_gmem2_b5_wlast),
    .m_axi_gmem2_b5_wuser(sig_m_axi_gmem2_b5_wuser),
    .m_axi_gmem2_b5_wvalid(sig_m_axi_gmem2_b5_wvalid),
    .m_axi_gmem2_b5_bready(sig_m_axi_gmem2_b5_bready),
    .m_axi_gmem2_b5_arid(sig_m_axi_gmem2_b5_arid),
    .m_axi_gmem2_b5_araddr(sig_m_axi_gmem2_b5_araddr),
    .m_axi_gmem2_b5_arlen(sig_m_axi_gmem2_b5_arlen),
    .m_axi_gmem2_b5_arsize(sig_m_axi_gmem2_b5_arsize),
    .m_axi_gmem2_b5_arburst(sig_m_axi_gmem2_b5_arburst),
    .m_axi_gmem2_b5_arlock(sig_m_axi_gmem2_b5_arlock),
    .m_axi_gmem2_b5_arcache(sig_m_axi_gmem2_b5_arcache),
    .m_axi_gmem2_b5_arprot(sig_m_axi_gmem2_b5_arprot),
    .m_axi_gmem2_b5_arqos(sig_m_axi_gmem2_b5_arqos),
    .m_axi_gmem2_b5_arregion(sig_m_axi_gmem2_b5_arregion),
    .m_axi_gmem2_b5_aruser(sig_m_axi_gmem2_b5_aruser),
    .m_axi_gmem2_b5_arvalid(sig_m_axi_gmem2_b5_arvalid),
    .m_axi_gmem2_b5_rready(sig_m_axi_gmem2_b5_rready),
    .m_axi_gmem2_b6_awid(sig_m_axi_gmem2_b6_awid),
    .m_axi_gmem2_b6_awaddr(sig_m_axi_gmem2_b6_awaddr),
    .m_axi_gmem2_b6_awlen(sig_m_axi_gmem2_b6_awlen),
    .m_axi_gmem2_b6_awsize(sig_m_axi_gmem2_b6_awsize),
    .m_axi_gmem2_b6_awburst(sig_m_axi_gmem2_b6_awburst),
    .m_axi_gmem2_b6_awlock(sig_m_axi_gmem2_b6_awlock),
    .m_axi_gmem2_b6_awcache(sig_m_axi_gmem2_b6_awcache),
    .m_axi_gmem2_b6_awprot(sig_m_axi_gmem2_b6_awprot),
    .m_axi_gmem2_b6_awqos(sig_m_axi_gmem2_b6_awqos),
    .m_axi_gmem2_b6_awregion(sig_m_axi_gmem2_b6_awregion),
    .m_axi_gmem2_b6_awuser(sig_m_axi_gmem2_b6_awuser),
    .m_axi_gmem2_b6_awvalid(sig_m_axi_gmem2_b6_awvalid),
    .m_axi_gmem2_b6_wdata(sig_m_axi_gmem2_b6_wdata),
    .m_axi_gmem2_b6_wstrb(sig_m_axi_gmem2_b6_wstrb),
    .m_axi_gmem2_b6_wlast(sig_m_axi_gmem2_b6_wlast),
    .m_axi_gmem2_b6_wuser(sig_m_axi_gmem2_b6_wuser),
    .m_axi_gmem2_b6_wvalid(sig_m_axi_gmem2_b6_wvalid),
    .m_axi_gmem2_b6_bready(sig_m_axi_gmem2_b6_bready),
    .m_axi_gmem2_b6_arid(sig_m_axi_gmem2_b6_arid),
    .m_axi_gmem2_b6_araddr(sig_m_axi_gmem2_b6_araddr),
    .m_axi_gmem2_b6_arlen(sig_m_axi_gmem2_b6_arlen),
    .m_axi_gmem2_b6_arsize(sig_m_axi_gmem2_b6_arsize),
    .m_axi_gmem2_b6_arburst(sig_m_axi_gmem2_b6_arburst),
    .m_axi_gmem2_b6_arlock(sig_m_axi_gmem2_b6_arlock),
    .m_axi_gmem2_b6_arcache(sig_m_axi_gmem2_b6_arcache),
    .m_axi_gmem2_b6_arprot(sig_m_axi_gmem2_b6_arprot),
    .m_axi_gmem2_b6_arqos(sig_m_axi_gmem2_b6_arqos),
    .m_axi_gmem2_b6_arregion(sig_m_axi_gmem2_b6_arregion),
    .m_axi_gmem2_b6_aruser(sig_m_axi_gmem2_b6_aruser),
    .m_axi_gmem2_b6_arvalid(sig_m_axi_gmem2_b6_arvalid),
    .m_axi_gmem2_b6_rready(sig_m_axi_gmem2_b6_rready),
    .m_axi_gmem2_b7_awid(sig_m_axi_gmem2_b7_awid),
    .m_axi_gmem2_b7_awaddr(sig_m_axi_gmem2_b7_awaddr),
    .m_axi_gmem2_b7_awlen(sig_m_axi_gmem2_b7_awlen),
    .m_axi_gmem2_b7_awsize(sig_m_axi_gmem2_b7_awsize),
    .m_axi_gmem2_b7_awburst(sig_m_axi_gmem2_b7_awburst),
    .m_axi_gmem2_b7_awlock(sig_m_axi_gmem2_b7_awlock),
    .m_axi_gmem2_b7_awcache(sig_m_axi_gmem2_b7_awcache),
    .m_axi_gmem2_b7_awprot(sig_m_axi_gmem2_b7_awprot),
    .m_axi_gmem2_b7_awqos(sig_m_axi_gmem2_b7_awqos),
    .m_axi_gmem2_b7_awregion(sig_m_axi_gmem2_b7_awregion),
    .m_axi_gmem2_b7_awuser(sig_m_axi_gmem2_b7_awuser),
    .m_axi_gmem2_b7_awvalid(sig_m_axi_gmem2_b7_awvalid),
    .m_axi_gmem2_b7_wdata(sig_m_axi_gmem2_b7_wdata),
    .m_axi_gmem2_b7_wstrb(sig_m_axi_gmem2_b7_wstrb),
    .m_axi_gmem2_b7_wlast(sig_m_axi_gmem2_b7_wlast),
    .m_axi_gmem2_b7_wuser(sig_m_axi_gmem2_b7_wuser),
    .m_axi_gmem2_b7_wvalid(sig_m_axi_gmem2_b7_wvalid),
    .m_axi_gmem2_b7_bready(sig_m_axi_gmem2_b7_bready),
    .m_axi_gmem2_b7_arid(sig_m_axi_gmem2_b7_arid),
    .m_axi_gmem2_b7_araddr(sig_m_axi_gmem2_b7_araddr),
    .m_axi_gmem2_b7_arlen(sig_m_axi_gmem2_b7_arlen),
    .m_axi_gmem2_b7_arsize(sig_m_axi_gmem2_b7_arsize),
    .m_axi_gmem2_b7_arburst(sig_m_axi_gmem2_b7_arburst),
    .m_axi_gmem2_b7_arlock(sig_m_axi_gmem2_b7_arlock),
    .m_axi_gmem2_b7_arcache(sig_m_axi_gmem2_b7_arcache),
    .m_axi_gmem2_b7_arprot(sig_m_axi_gmem2_b7_arprot),
    .m_axi_gmem2_b7_arqos(sig_m_axi_gmem2_b7_arqos),
    .m_axi_gmem2_b7_arregion(sig_m_axi_gmem2_b7_arregion),
    .m_axi_gmem2_b7_aruser(sig_m_axi_gmem2_b7_aruser),
    .m_axi_gmem2_b7_arvalid(sig_m_axi_gmem2_b7_arvalid),
    .m_axi_gmem2_b7_rready(sig_m_axi_gmem2_b7_rready),
    .clock(clock),
    .reset(sig_reset),
    .start_port(sig_start_port),
    .dram_in(sig_dram_in),
    .dram_w(sig_dram_w),
    .dram_out_b0(sig_dram_out_b0),
    .dram_out_b1(sig_dram_out_b1),
    .dram_out_b2(sig_dram_out_b2),
    .dram_out_b3(sig_dram_out_b3),
    .dram_out_b4(sig_dram_out_b4),
    .dram_out_b5(sig_dram_out_b5),
    .dram_out_b6(sig_dram_out_b6),
    .dram_out_b7(sig_dram_out_b7),
    .cache_reset(sig_setup_port),
    .m_axi_gmem0_awready(sig_m_axi_gmem0_awready),
    .m_axi_gmem0_wready(sig_m_axi_gmem0_wready),
    .m_axi_gmem0_bid(sig_m_axi_gmem0_bid),
    .m_axi_gmem0_bresp(sig_m_axi_gmem0_bresp),
    .m_axi_gmem0_buser(sig_m_axi_gmem0_buser),
    .m_axi_gmem0_bvalid(sig_m_axi_gmem0_bvalid),
    .m_axi_gmem0_arready(sig_m_axi_gmem0_arready),
    .m_axi_gmem0_rid(sig_m_axi_gmem0_rid),
    .m_axi_gmem0_rdata(sig_m_axi_gmem0_rdata),
    .m_axi_gmem0_rresp(sig_m_axi_gmem0_rresp),
    .m_axi_gmem0_rlast(sig_m_axi_gmem0_rlast),
    .m_axi_gmem0_ruser(sig_m_axi_gmem0_ruser),
    .m_axi_gmem0_rvalid(sig_m_axi_gmem0_rvalid),
    .m_axi_gmem1_awready(sig_m_axi_gmem1_awready),
    .m_axi_gmem1_wready(sig_m_axi_gmem1_wready),
    .m_axi_gmem1_bid(sig_m_axi_gmem1_bid),
    .m_axi_gmem1_bresp(sig_m_axi_gmem1_bresp),
    .m_axi_gmem1_buser(sig_m_axi_gmem1_buser),
    .m_axi_gmem1_bvalid(sig_m_axi_gmem1_bvalid),
    .m_axi_gmem1_arready(sig_m_axi_gmem1_arready),
    .m_axi_gmem1_rid(sig_m_axi_gmem1_rid),
    .m_axi_gmem1_rdata(sig_m_axi_gmem1_rdata),
    .m_axi_gmem1_rresp(sig_m_axi_gmem1_rresp),
    .m_axi_gmem1_rlast(sig_m_axi_gmem1_rlast),
    .m_axi_gmem1_ruser(sig_m_axi_gmem1_ruser),
    .m_axi_gmem1_rvalid(sig_m_axi_gmem1_rvalid),
    .m_axi_gmem2_b0_awready(sig_m_axi_gmem2_b0_awready),
    .m_axi_gmem2_b0_wready(sig_m_axi_gmem2_b0_wready),
    .m_axi_gmem2_b0_bid(sig_m_axi_gmem2_b0_bid),
    .m_axi_gmem2_b0_bresp(sig_m_axi_gmem2_b0_bresp),
    .m_axi_gmem2_b0_buser(sig_m_axi_gmem2_b0_buser),
    .m_axi_gmem2_b0_bvalid(sig_m_axi_gmem2_b0_bvalid),
    .m_axi_gmem2_b0_arready(sig_m_axi_gmem2_b0_arready),
    .m_axi_gmem2_b0_rid(sig_m_axi_gmem2_b0_rid),
    .m_axi_gmem2_b0_rdata(sig_m_axi_gmem2_b0_rdata),
    .m_axi_gmem2_b0_rresp(sig_m_axi_gmem2_b0_rresp),
    .m_axi_gmem2_b0_rlast(sig_m_axi_gmem2_b0_rlast),
    .m_axi_gmem2_b0_ruser(sig_m_axi_gmem2_b0_ruser),
    .m_axi_gmem2_b0_rvalid(sig_m_axi_gmem2_b0_rvalid),
    .m_axi_gmem2_b1_awready(sig_m_axi_gmem2_b1_awready),
    .m_axi_gmem2_b1_wready(sig_m_axi_gmem2_b1_wready),
    .m_axi_gmem2_b1_bid(sig_m_axi_gmem2_b1_bid),
    .m_axi_gmem2_b1_bresp(sig_m_axi_gmem2_b1_bresp),
    .m_axi_gmem2_b1_buser(sig_m_axi_gmem2_b1_buser),
    .m_axi_gmem2_b1_bvalid(sig_m_axi_gmem2_b1_bvalid),
    .m_axi_gmem2_b1_arready(sig_m_axi_gmem2_b1_arready),
    .m_axi_gmem2_b1_rid(sig_m_axi_gmem2_b1_rid),
    .m_axi_gmem2_b1_rdata(sig_m_axi_gmem2_b1_rdata),
    .m_axi_gmem2_b1_rresp(sig_m_axi_gmem2_b1_rresp),
    .m_axi_gmem2_b1_rlast(sig_m_axi_gmem2_b1_rlast),
    .m_axi_gmem2_b1_ruser(sig_m_axi_gmem2_b1_ruser),
    .m_axi_gmem2_b1_rvalid(sig_m_axi_gmem2_b1_rvalid),
    .m_axi_gmem2_b2_awready(sig_m_axi_gmem2_b2_awready),
    .m_axi_gmem2_b2_wready(sig_m_axi_gmem2_b2_wready),
    .m_axi_gmem2_b2_bid(sig_m_axi_gmem2_b2_bid),
    .m_axi_gmem2_b2_bresp(sig_m_axi_gmem2_b2_bresp),
    .m_axi_gmem2_b2_buser(sig_m_axi_gmem2_b2_buser),
    .m_axi_gmem2_b2_bvalid(sig_m_axi_gmem2_b2_bvalid),
    .m_axi_gmem2_b2_arready(sig_m_axi_gmem2_b2_arready),
    .m_axi_gmem2_b2_rid(sig_m_axi_gmem2_b2_rid),
    .m_axi_gmem2_b2_rdata(sig_m_axi_gmem2_b2_rdata),
    .m_axi_gmem2_b2_rresp(sig_m_axi_gmem2_b2_rresp),
    .m_axi_gmem2_b2_rlast(sig_m_axi_gmem2_b2_rlast),
    .m_axi_gmem2_b2_ruser(sig_m_axi_gmem2_b2_ruser),
    .m_axi_gmem2_b2_rvalid(sig_m_axi_gmem2_b2_rvalid),
    .m_axi_gmem2_b3_awready(sig_m_axi_gmem2_b3_awready),
    .m_axi_gmem2_b3_wready(sig_m_axi_gmem2_b3_wready),
    .m_axi_gmem2_b3_bid(sig_m_axi_gmem2_b3_bid),
    .m_axi_gmem2_b3_bresp(sig_m_axi_gmem2_b3_bresp),
    .m_axi_gmem2_b3_buser(sig_m_axi_gmem2_b3_buser),
    .m_axi_gmem2_b3_bvalid(sig_m_axi_gmem2_b3_bvalid),
    .m_axi_gmem2_b3_arready(sig_m_axi_gmem2_b3_arready),
    .m_axi_gmem2_b3_rid(sig_m_axi_gmem2_b3_rid),
    .m_axi_gmem2_b3_rdata(sig_m_axi_gmem2_b3_rdata),
    .m_axi_gmem2_b3_rresp(sig_m_axi_gmem2_b3_rresp),
    .m_axi_gmem2_b3_rlast(sig_m_axi_gmem2_b3_rlast),
    .m_axi_gmem2_b3_ruser(sig_m_axi_gmem2_b3_ruser),
    .m_axi_gmem2_b3_rvalid(sig_m_axi_gmem2_b3_rvalid),
    .m_axi_gmem2_b4_awready(sig_m_axi_gmem2_b4_awready),
    .m_axi_gmem2_b4_wready(sig_m_axi_gmem2_b4_wready),
    .m_axi_gmem2_b4_bid(sig_m_axi_gmem2_b4_bid),
    .m_axi_gmem2_b4_bresp(sig_m_axi_gmem2_b4_bresp),
    .m_axi_gmem2_b4_buser(sig_m_axi_gmem2_b4_buser),
    .m_axi_gmem2_b4_bvalid(sig_m_axi_gmem2_b4_bvalid),
    .m_axi_gmem2_b4_arready(sig_m_axi_gmem2_b4_arready),
    .m_axi_gmem2_b4_rid(sig_m_axi_gmem2_b4_rid),
    .m_axi_gmem2_b4_rdata(sig_m_axi_gmem2_b4_rdata),
    .m_axi_gmem2_b4_rresp(sig_m_axi_gmem2_b4_rresp),
    .m_axi_gmem2_b4_rlast(sig_m_axi_gmem2_b4_rlast),
    .m_axi_gmem2_b4_ruser(sig_m_axi_gmem2_b4_ruser),
    .m_axi_gmem2_b4_rvalid(sig_m_axi_gmem2_b4_rvalid),
    .m_axi_gmem2_b5_awready(sig_m_axi_gmem2_b5_awready),
    .m_axi_gmem2_b5_wready(sig_m_axi_gmem2_b5_wready),
    .m_axi_gmem2_b5_bid(sig_m_axi_gmem2_b5_bid),
    .m_axi_gmem2_b5_bresp(sig_m_axi_gmem2_b5_bresp),
    .m_axi_gmem2_b5_buser(sig_m_axi_gmem2_b5_buser),
    .m_axi_gmem2_b5_bvalid(sig_m_axi_gmem2_b5_bvalid),
    .m_axi_gmem2_b5_arready(sig_m_axi_gmem2_b5_arready),
    .m_axi_gmem2_b5_rid(sig_m_axi_gmem2_b5_rid),
    .m_axi_gmem2_b5_rdata(sig_m_axi_gmem2_b5_rdata),
    .m_axi_gmem2_b5_rresp(sig_m_axi_gmem2_b5_rresp),
    .m_axi_gmem2_b5_rlast(sig_m_axi_gmem2_b5_rlast),
    .m_axi_gmem2_b5_ruser(sig_m_axi_gmem2_b5_ruser),
    .m_axi_gmem2_b5_rvalid(sig_m_axi_gmem2_b5_rvalid),
    .m_axi_gmem2_b6_awready(sig_m_axi_gmem2_b6_awready),
    .m_axi_gmem2_b6_wready(sig_m_axi_gmem2_b6_wready),
    .m_axi_gmem2_b6_bid(sig_m_axi_gmem2_b6_bid),
    .m_axi_gmem2_b6_bresp(sig_m_axi_gmem2_b6_bresp),
    .m_axi_gmem2_b6_buser(sig_m_axi_gmem2_b6_buser),
    .m_axi_gmem2_b6_bvalid(sig_m_axi_gmem2_b6_bvalid),
    .m_axi_gmem2_b6_arready(sig_m_axi_gmem2_b6_arready),
    .m_axi_gmem2_b6_rid(sig_m_axi_gmem2_b6_rid),
    .m_axi_gmem2_b6_rdata(sig_m_axi_gmem2_b6_rdata),
    .m_axi_gmem2_b6_rresp(sig_m_axi_gmem2_b6_rresp),
    .m_axi_gmem2_b6_rlast(sig_m_axi_gmem2_b6_rlast),
    .m_axi_gmem2_b6_ruser(sig_m_axi_gmem2_b6_ruser),
    .m_axi_gmem2_b6_rvalid(sig_m_axi_gmem2_b6_rvalid),
    .m_axi_gmem2_b7_awready(sig_m_axi_gmem2_b7_awready),
    .m_axi_gmem2_b7_wready(sig_m_axi_gmem2_b7_wready),
    .m_axi_gmem2_b7_bid(sig_m_axi_gmem2_b7_bid),
    .m_axi_gmem2_b7_bresp(sig_m_axi_gmem2_b7_bresp),
    .m_axi_gmem2_b7_buser(sig_m_axi_gmem2_b7_buser),
    .m_axi_gmem2_b7_bvalid(sig_m_axi_gmem2_b7_bvalid),
    .m_axi_gmem2_b7_arready(sig_m_axi_gmem2_b7_arready),
    .m_axi_gmem2_b7_rid(sig_m_axi_gmem2_b7_rid),
    .m_axi_gmem2_b7_rdata(sig_m_axi_gmem2_b7_rdata),
    .m_axi_gmem2_b7_rresp(sig_m_axi_gmem2_b7_rresp),
    .m_axi_gmem2_b7_rlast(sig_m_axi_gmem2_b7_rlast),
    .m_axi_gmem2_b7_ruser(sig_m_axi_gmem2_b7_ruser),
    .m_axi_gmem2_b7_rvalid(sig_m_axi_gmem2_b7_rvalid));
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
  TestbenchMEMMinimal #(.index(10),
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
    .BITSIZE_val_port(32)) if_addr_dram_in (.val_port(sig_dram_in),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(2),
    .BITSIZE_val_port(32)) if_addr_dram_out_b0 (.val_port(sig_dram_out_b0),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(3),
    .BITSIZE_val_port(32)) if_addr_dram_out_b1 (.val_port(sig_dram_out_b1),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(4),
    .BITSIZE_val_port(32)) if_addr_dram_out_b2 (.val_port(sig_dram_out_b2),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(5),
    .BITSIZE_val_port(32)) if_addr_dram_out_b3 (.val_port(sig_dram_out_b3),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(6),
    .BITSIZE_val_port(32)) if_addr_dram_out_b4 (.val_port(sig_dram_out_b4),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(7),
    .BITSIZE_val_port(32)) if_addr_dram_out_b5 (.val_port(sig_dram_out_b5),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(8),
    .BITSIZE_val_port(32)) if_addr_dram_out_b6 (.val_port(sig_dram_out_b6),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(9),
    .BITSIZE_val_port(32)) if_addr_dram_out_b7 (.val_port(sig_dram_out_b7),
    .clock(clock),
    .setup_port(sig_setup_port));
  IF_PORT_IN #(.index(1),
    .BITSIZE_val_port(32)) if_addr_dram_w (.val_port(sig_dram_w),
    .clock(clock),
    .setup_port(sig_setup_port));
  if_m_axi_gmem0 #(.index(10),
    .BITSIZE_m_axi_gmem0_bid(6),
    .BITSIZE_m_axi_gmem0_bresp(2),
    .BITSIZE_m_axi_gmem0_buser(1),
    .BITSIZE_m_axi_gmem0_rid(6),
    .BITSIZE_m_axi_gmem0_rdata(32),
    .BITSIZE_m_axi_gmem0_rresp(2),
    .BITSIZE_m_axi_gmem0_ruser(1),
    .BITSIZE_m_axi_gmem0_awid(6),
    .BITSIZE_m_axi_gmem0_awaddr(32),
    .BITSIZE_m_axi_gmem0_awlen(8),
    .BITSIZE_m_axi_gmem0_awsize(3),
    .BITSIZE_m_axi_gmem0_awburst(2),
    .BITSIZE_m_axi_gmem0_awlock(1),
    .BITSIZE_m_axi_gmem0_awcache(4),
    .BITSIZE_m_axi_gmem0_awprot(3),
    .BITSIZE_m_axi_gmem0_awqos(4),
    .BITSIZE_m_axi_gmem0_awregion(4),
    .BITSIZE_m_axi_gmem0_awuser(1),
    .BITSIZE_m_axi_gmem0_wdata(32),
    .BITSIZE_m_axi_gmem0_wstrb(4),
    .BITSIZE_m_axi_gmem0_wuser(1),
    .BITSIZE_m_axi_gmem0_arid(6),
    .BITSIZE_m_axi_gmem0_araddr(32),
    .BITSIZE_m_axi_gmem0_arlen(8),
    .BITSIZE_m_axi_gmem0_arsize(3),
    .BITSIZE_m_axi_gmem0_arburst(2),
    .BITSIZE_m_axi_gmem0_arlock(1),
    .BITSIZE_m_axi_gmem0_arcache(4),
    .BITSIZE_m_axi_gmem0_arprot(3),
    .BITSIZE_m_axi_gmem0_arqos(4),
    .BITSIZE_m_axi_gmem0_arregion(4),
    .BITSIZE_m_axi_gmem0_aruser(1)) if_m_axi_gmem0_fu (.m_axi_gmem0_awready(sig_m_axi_gmem0_awready),
    .m_axi_gmem0_wready(sig_m_axi_gmem0_wready),
    .m_axi_gmem0_bid(sig_m_axi_gmem0_bid),
    .m_axi_gmem0_bresp(sig_m_axi_gmem0_bresp),
    .m_axi_gmem0_buser(sig_m_axi_gmem0_buser),
    .m_axi_gmem0_bvalid(sig_m_axi_gmem0_bvalid),
    .m_axi_gmem0_arready(sig_m_axi_gmem0_arready),
    .m_axi_gmem0_rid(sig_m_axi_gmem0_rid),
    .m_axi_gmem0_rdata(sig_m_axi_gmem0_rdata),
    .m_axi_gmem0_rresp(sig_m_axi_gmem0_rresp),
    .m_axi_gmem0_rlast(sig_m_axi_gmem0_rlast),
    .m_axi_gmem0_ruser(sig_m_axi_gmem0_ruser),
    .m_axi_gmem0_rvalid(sig_m_axi_gmem0_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem0_awid(sig_m_axi_gmem0_awid),
    .m_axi_gmem0_awaddr(sig_m_axi_gmem0_awaddr),
    .m_axi_gmem0_awlen(sig_m_axi_gmem0_awlen),
    .m_axi_gmem0_awsize(sig_m_axi_gmem0_awsize),
    .m_axi_gmem0_awburst(sig_m_axi_gmem0_awburst),
    .m_axi_gmem0_awlock(sig_m_axi_gmem0_awlock),
    .m_axi_gmem0_awcache(sig_m_axi_gmem0_awcache),
    .m_axi_gmem0_awprot(sig_m_axi_gmem0_awprot),
    .m_axi_gmem0_awqos(sig_m_axi_gmem0_awqos),
    .m_axi_gmem0_awregion(sig_m_axi_gmem0_awregion),
    .m_axi_gmem0_awuser(sig_m_axi_gmem0_awuser),
    .m_axi_gmem0_awvalid(sig_m_axi_gmem0_awvalid),
    .m_axi_gmem0_wdata(sig_m_axi_gmem0_wdata),
    .m_axi_gmem0_wstrb(sig_m_axi_gmem0_wstrb),
    .m_axi_gmem0_wlast(sig_m_axi_gmem0_wlast),
    .m_axi_gmem0_wuser(sig_m_axi_gmem0_wuser),
    .m_axi_gmem0_wvalid(sig_m_axi_gmem0_wvalid),
    .m_axi_gmem0_bready(sig_m_axi_gmem0_bready),
    .m_axi_gmem0_arid(sig_m_axi_gmem0_arid),
    .m_axi_gmem0_araddr(sig_m_axi_gmem0_araddr),
    .m_axi_gmem0_arlen(sig_m_axi_gmem0_arlen),
    .m_axi_gmem0_arsize(sig_m_axi_gmem0_arsize),
    .m_axi_gmem0_arburst(sig_m_axi_gmem0_arburst),
    .m_axi_gmem0_arlock(sig_m_axi_gmem0_arlock),
    .m_axi_gmem0_arcache(sig_m_axi_gmem0_arcache),
    .m_axi_gmem0_arprot(sig_m_axi_gmem0_arprot),
    .m_axi_gmem0_arqos(sig_m_axi_gmem0_arqos),
    .m_axi_gmem0_arregion(sig_m_axi_gmem0_arregion),
    .m_axi_gmem0_aruser(sig_m_axi_gmem0_aruser),
    .m_axi_gmem0_arvalid(sig_m_axi_gmem0_arvalid),
    .m_axi_gmem0_rready(sig_m_axi_gmem0_rready));
  if_m_axi_gmem1 #(.index(10),
    .BITSIZE_m_axi_gmem1_bid(6),
    .BITSIZE_m_axi_gmem1_bresp(2),
    .BITSIZE_m_axi_gmem1_buser(1),
    .BITSIZE_m_axi_gmem1_rid(6),
    .BITSIZE_m_axi_gmem1_rdata(32),
    .BITSIZE_m_axi_gmem1_rresp(2),
    .BITSIZE_m_axi_gmem1_ruser(1),
    .BITSIZE_m_axi_gmem1_awid(6),
    .BITSIZE_m_axi_gmem1_awaddr(32),
    .BITSIZE_m_axi_gmem1_awlen(8),
    .BITSIZE_m_axi_gmem1_awsize(3),
    .BITSIZE_m_axi_gmem1_awburst(2),
    .BITSIZE_m_axi_gmem1_awlock(1),
    .BITSIZE_m_axi_gmem1_awcache(4),
    .BITSIZE_m_axi_gmem1_awprot(3),
    .BITSIZE_m_axi_gmem1_awqos(4),
    .BITSIZE_m_axi_gmem1_awregion(4),
    .BITSIZE_m_axi_gmem1_awuser(1),
    .BITSIZE_m_axi_gmem1_wdata(32),
    .BITSIZE_m_axi_gmem1_wstrb(4),
    .BITSIZE_m_axi_gmem1_wuser(1),
    .BITSIZE_m_axi_gmem1_arid(6),
    .BITSIZE_m_axi_gmem1_araddr(32),
    .BITSIZE_m_axi_gmem1_arlen(8),
    .BITSIZE_m_axi_gmem1_arsize(3),
    .BITSIZE_m_axi_gmem1_arburst(2),
    .BITSIZE_m_axi_gmem1_arlock(1),
    .BITSIZE_m_axi_gmem1_arcache(4),
    .BITSIZE_m_axi_gmem1_arprot(3),
    .BITSIZE_m_axi_gmem1_arqos(4),
    .BITSIZE_m_axi_gmem1_arregion(4),
    .BITSIZE_m_axi_gmem1_aruser(1)) if_m_axi_gmem1_fu (.m_axi_gmem1_awready(sig_m_axi_gmem1_awready),
    .m_axi_gmem1_wready(sig_m_axi_gmem1_wready),
    .m_axi_gmem1_bid(sig_m_axi_gmem1_bid),
    .m_axi_gmem1_bresp(sig_m_axi_gmem1_bresp),
    .m_axi_gmem1_buser(sig_m_axi_gmem1_buser),
    .m_axi_gmem1_bvalid(sig_m_axi_gmem1_bvalid),
    .m_axi_gmem1_arready(sig_m_axi_gmem1_arready),
    .m_axi_gmem1_rid(sig_m_axi_gmem1_rid),
    .m_axi_gmem1_rdata(sig_m_axi_gmem1_rdata),
    .m_axi_gmem1_rresp(sig_m_axi_gmem1_rresp),
    .m_axi_gmem1_rlast(sig_m_axi_gmem1_rlast),
    .m_axi_gmem1_ruser(sig_m_axi_gmem1_ruser),
    .m_axi_gmem1_rvalid(sig_m_axi_gmem1_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem1_awid(sig_m_axi_gmem1_awid),
    .m_axi_gmem1_awaddr(sig_m_axi_gmem1_awaddr),
    .m_axi_gmem1_awlen(sig_m_axi_gmem1_awlen),
    .m_axi_gmem1_awsize(sig_m_axi_gmem1_awsize),
    .m_axi_gmem1_awburst(sig_m_axi_gmem1_awburst),
    .m_axi_gmem1_awlock(sig_m_axi_gmem1_awlock),
    .m_axi_gmem1_awcache(sig_m_axi_gmem1_awcache),
    .m_axi_gmem1_awprot(sig_m_axi_gmem1_awprot),
    .m_axi_gmem1_awqos(sig_m_axi_gmem1_awqos),
    .m_axi_gmem1_awregion(sig_m_axi_gmem1_awregion),
    .m_axi_gmem1_awuser(sig_m_axi_gmem1_awuser),
    .m_axi_gmem1_awvalid(sig_m_axi_gmem1_awvalid),
    .m_axi_gmem1_wdata(sig_m_axi_gmem1_wdata),
    .m_axi_gmem1_wstrb(sig_m_axi_gmem1_wstrb),
    .m_axi_gmem1_wlast(sig_m_axi_gmem1_wlast),
    .m_axi_gmem1_wuser(sig_m_axi_gmem1_wuser),
    .m_axi_gmem1_wvalid(sig_m_axi_gmem1_wvalid),
    .m_axi_gmem1_bready(sig_m_axi_gmem1_bready),
    .m_axi_gmem1_arid(sig_m_axi_gmem1_arid),
    .m_axi_gmem1_araddr(sig_m_axi_gmem1_araddr),
    .m_axi_gmem1_arlen(sig_m_axi_gmem1_arlen),
    .m_axi_gmem1_arsize(sig_m_axi_gmem1_arsize),
    .m_axi_gmem1_arburst(sig_m_axi_gmem1_arburst),
    .m_axi_gmem1_arlock(sig_m_axi_gmem1_arlock),
    .m_axi_gmem1_arcache(sig_m_axi_gmem1_arcache),
    .m_axi_gmem1_arprot(sig_m_axi_gmem1_arprot),
    .m_axi_gmem1_arqos(sig_m_axi_gmem1_arqos),
    .m_axi_gmem1_arregion(sig_m_axi_gmem1_arregion),
    .m_axi_gmem1_aruser(sig_m_axi_gmem1_aruser),
    .m_axi_gmem1_arvalid(sig_m_axi_gmem1_arvalid),
    .m_axi_gmem1_rready(sig_m_axi_gmem1_rready));
  if_m_axi_gmem2_b0 #(.index(10),
    .BITSIZE_m_axi_gmem2_b0_bid(6),
    .BITSIZE_m_axi_gmem2_b0_bresp(2),
    .BITSIZE_m_axi_gmem2_b0_buser(1),
    .BITSIZE_m_axi_gmem2_b0_rid(6),
    .BITSIZE_m_axi_gmem2_b0_rdata(32),
    .BITSIZE_m_axi_gmem2_b0_rresp(2),
    .BITSIZE_m_axi_gmem2_b0_ruser(1),
    .BITSIZE_m_axi_gmem2_b0_awid(6),
    .BITSIZE_m_axi_gmem2_b0_awaddr(32),
    .BITSIZE_m_axi_gmem2_b0_awlen(8),
    .BITSIZE_m_axi_gmem2_b0_awsize(3),
    .BITSIZE_m_axi_gmem2_b0_awburst(2),
    .BITSIZE_m_axi_gmem2_b0_awlock(1),
    .BITSIZE_m_axi_gmem2_b0_awcache(4),
    .BITSIZE_m_axi_gmem2_b0_awprot(3),
    .BITSIZE_m_axi_gmem2_b0_awqos(4),
    .BITSIZE_m_axi_gmem2_b0_awregion(4),
    .BITSIZE_m_axi_gmem2_b0_awuser(1),
    .BITSIZE_m_axi_gmem2_b0_wdata(32),
    .BITSIZE_m_axi_gmem2_b0_wstrb(4),
    .BITSIZE_m_axi_gmem2_b0_wuser(1),
    .BITSIZE_m_axi_gmem2_b0_arid(6),
    .BITSIZE_m_axi_gmem2_b0_araddr(32),
    .BITSIZE_m_axi_gmem2_b0_arlen(8),
    .BITSIZE_m_axi_gmem2_b0_arsize(3),
    .BITSIZE_m_axi_gmem2_b0_arburst(2),
    .BITSIZE_m_axi_gmem2_b0_arlock(1),
    .BITSIZE_m_axi_gmem2_b0_arcache(4),
    .BITSIZE_m_axi_gmem2_b0_arprot(3),
    .BITSIZE_m_axi_gmem2_b0_arqos(4),
    .BITSIZE_m_axi_gmem2_b0_arregion(4),
    .BITSIZE_m_axi_gmem2_b0_aruser(1)) if_m_axi_gmem2_b0_fu (.m_axi_gmem2_b0_awready(sig_m_axi_gmem2_b0_awready),
    .m_axi_gmem2_b0_wready(sig_m_axi_gmem2_b0_wready),
    .m_axi_gmem2_b0_bid(sig_m_axi_gmem2_b0_bid),
    .m_axi_gmem2_b0_bresp(sig_m_axi_gmem2_b0_bresp),
    .m_axi_gmem2_b0_buser(sig_m_axi_gmem2_b0_buser),
    .m_axi_gmem2_b0_bvalid(sig_m_axi_gmem2_b0_bvalid),
    .m_axi_gmem2_b0_arready(sig_m_axi_gmem2_b0_arready),
    .m_axi_gmem2_b0_rid(sig_m_axi_gmem2_b0_rid),
    .m_axi_gmem2_b0_rdata(sig_m_axi_gmem2_b0_rdata),
    .m_axi_gmem2_b0_rresp(sig_m_axi_gmem2_b0_rresp),
    .m_axi_gmem2_b0_rlast(sig_m_axi_gmem2_b0_rlast),
    .m_axi_gmem2_b0_ruser(sig_m_axi_gmem2_b0_ruser),
    .m_axi_gmem2_b0_rvalid(sig_m_axi_gmem2_b0_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem2_b0_awid(sig_m_axi_gmem2_b0_awid),
    .m_axi_gmem2_b0_awaddr(sig_m_axi_gmem2_b0_awaddr),
    .m_axi_gmem2_b0_awlen(sig_m_axi_gmem2_b0_awlen),
    .m_axi_gmem2_b0_awsize(sig_m_axi_gmem2_b0_awsize),
    .m_axi_gmem2_b0_awburst(sig_m_axi_gmem2_b0_awburst),
    .m_axi_gmem2_b0_awlock(sig_m_axi_gmem2_b0_awlock),
    .m_axi_gmem2_b0_awcache(sig_m_axi_gmem2_b0_awcache),
    .m_axi_gmem2_b0_awprot(sig_m_axi_gmem2_b0_awprot),
    .m_axi_gmem2_b0_awqos(sig_m_axi_gmem2_b0_awqos),
    .m_axi_gmem2_b0_awregion(sig_m_axi_gmem2_b0_awregion),
    .m_axi_gmem2_b0_awuser(sig_m_axi_gmem2_b0_awuser),
    .m_axi_gmem2_b0_awvalid(sig_m_axi_gmem2_b0_awvalid),
    .m_axi_gmem2_b0_wdata(sig_m_axi_gmem2_b0_wdata),
    .m_axi_gmem2_b0_wstrb(sig_m_axi_gmem2_b0_wstrb),
    .m_axi_gmem2_b0_wlast(sig_m_axi_gmem2_b0_wlast),
    .m_axi_gmem2_b0_wuser(sig_m_axi_gmem2_b0_wuser),
    .m_axi_gmem2_b0_wvalid(sig_m_axi_gmem2_b0_wvalid),
    .m_axi_gmem2_b0_bready(sig_m_axi_gmem2_b0_bready),
    .m_axi_gmem2_b0_arid(sig_m_axi_gmem2_b0_arid),
    .m_axi_gmem2_b0_araddr(sig_m_axi_gmem2_b0_araddr),
    .m_axi_gmem2_b0_arlen(sig_m_axi_gmem2_b0_arlen),
    .m_axi_gmem2_b0_arsize(sig_m_axi_gmem2_b0_arsize),
    .m_axi_gmem2_b0_arburst(sig_m_axi_gmem2_b0_arburst),
    .m_axi_gmem2_b0_arlock(sig_m_axi_gmem2_b0_arlock),
    .m_axi_gmem2_b0_arcache(sig_m_axi_gmem2_b0_arcache),
    .m_axi_gmem2_b0_arprot(sig_m_axi_gmem2_b0_arprot),
    .m_axi_gmem2_b0_arqos(sig_m_axi_gmem2_b0_arqos),
    .m_axi_gmem2_b0_arregion(sig_m_axi_gmem2_b0_arregion),
    .m_axi_gmem2_b0_aruser(sig_m_axi_gmem2_b0_aruser),
    .m_axi_gmem2_b0_arvalid(sig_m_axi_gmem2_b0_arvalid),
    .m_axi_gmem2_b0_rready(sig_m_axi_gmem2_b0_rready));
  if_m_axi_gmem2_b1 #(.index(10),
    .BITSIZE_m_axi_gmem2_b1_bid(6),
    .BITSIZE_m_axi_gmem2_b1_bresp(2),
    .BITSIZE_m_axi_gmem2_b1_buser(1),
    .BITSIZE_m_axi_gmem2_b1_rid(6),
    .BITSIZE_m_axi_gmem2_b1_rdata(32),
    .BITSIZE_m_axi_gmem2_b1_rresp(2),
    .BITSIZE_m_axi_gmem2_b1_ruser(1),
    .BITSIZE_m_axi_gmem2_b1_awid(6),
    .BITSIZE_m_axi_gmem2_b1_awaddr(32),
    .BITSIZE_m_axi_gmem2_b1_awlen(8),
    .BITSIZE_m_axi_gmem2_b1_awsize(3),
    .BITSIZE_m_axi_gmem2_b1_awburst(2),
    .BITSIZE_m_axi_gmem2_b1_awlock(1),
    .BITSIZE_m_axi_gmem2_b1_awcache(4),
    .BITSIZE_m_axi_gmem2_b1_awprot(3),
    .BITSIZE_m_axi_gmem2_b1_awqos(4),
    .BITSIZE_m_axi_gmem2_b1_awregion(4),
    .BITSIZE_m_axi_gmem2_b1_awuser(1),
    .BITSIZE_m_axi_gmem2_b1_wdata(32),
    .BITSIZE_m_axi_gmem2_b1_wstrb(4),
    .BITSIZE_m_axi_gmem2_b1_wuser(1),
    .BITSIZE_m_axi_gmem2_b1_arid(6),
    .BITSIZE_m_axi_gmem2_b1_araddr(32),
    .BITSIZE_m_axi_gmem2_b1_arlen(8),
    .BITSIZE_m_axi_gmem2_b1_arsize(3),
    .BITSIZE_m_axi_gmem2_b1_arburst(2),
    .BITSIZE_m_axi_gmem2_b1_arlock(1),
    .BITSIZE_m_axi_gmem2_b1_arcache(4),
    .BITSIZE_m_axi_gmem2_b1_arprot(3),
    .BITSIZE_m_axi_gmem2_b1_arqos(4),
    .BITSIZE_m_axi_gmem2_b1_arregion(4),
    .BITSIZE_m_axi_gmem2_b1_aruser(1)) if_m_axi_gmem2_b1_fu (.m_axi_gmem2_b1_awready(sig_m_axi_gmem2_b1_awready),
    .m_axi_gmem2_b1_wready(sig_m_axi_gmem2_b1_wready),
    .m_axi_gmem2_b1_bid(sig_m_axi_gmem2_b1_bid),
    .m_axi_gmem2_b1_bresp(sig_m_axi_gmem2_b1_bresp),
    .m_axi_gmem2_b1_buser(sig_m_axi_gmem2_b1_buser),
    .m_axi_gmem2_b1_bvalid(sig_m_axi_gmem2_b1_bvalid),
    .m_axi_gmem2_b1_arready(sig_m_axi_gmem2_b1_arready),
    .m_axi_gmem2_b1_rid(sig_m_axi_gmem2_b1_rid),
    .m_axi_gmem2_b1_rdata(sig_m_axi_gmem2_b1_rdata),
    .m_axi_gmem2_b1_rresp(sig_m_axi_gmem2_b1_rresp),
    .m_axi_gmem2_b1_rlast(sig_m_axi_gmem2_b1_rlast),
    .m_axi_gmem2_b1_ruser(sig_m_axi_gmem2_b1_ruser),
    .m_axi_gmem2_b1_rvalid(sig_m_axi_gmem2_b1_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem2_b1_awid(sig_m_axi_gmem2_b1_awid),
    .m_axi_gmem2_b1_awaddr(sig_m_axi_gmem2_b1_awaddr),
    .m_axi_gmem2_b1_awlen(sig_m_axi_gmem2_b1_awlen),
    .m_axi_gmem2_b1_awsize(sig_m_axi_gmem2_b1_awsize),
    .m_axi_gmem2_b1_awburst(sig_m_axi_gmem2_b1_awburst),
    .m_axi_gmem2_b1_awlock(sig_m_axi_gmem2_b1_awlock),
    .m_axi_gmem2_b1_awcache(sig_m_axi_gmem2_b1_awcache),
    .m_axi_gmem2_b1_awprot(sig_m_axi_gmem2_b1_awprot),
    .m_axi_gmem2_b1_awqos(sig_m_axi_gmem2_b1_awqos),
    .m_axi_gmem2_b1_awregion(sig_m_axi_gmem2_b1_awregion),
    .m_axi_gmem2_b1_awuser(sig_m_axi_gmem2_b1_awuser),
    .m_axi_gmem2_b1_awvalid(sig_m_axi_gmem2_b1_awvalid),
    .m_axi_gmem2_b1_wdata(sig_m_axi_gmem2_b1_wdata),
    .m_axi_gmem2_b1_wstrb(sig_m_axi_gmem2_b1_wstrb),
    .m_axi_gmem2_b1_wlast(sig_m_axi_gmem2_b1_wlast),
    .m_axi_gmem2_b1_wuser(sig_m_axi_gmem2_b1_wuser),
    .m_axi_gmem2_b1_wvalid(sig_m_axi_gmem2_b1_wvalid),
    .m_axi_gmem2_b1_bready(sig_m_axi_gmem2_b1_bready),
    .m_axi_gmem2_b1_arid(sig_m_axi_gmem2_b1_arid),
    .m_axi_gmem2_b1_araddr(sig_m_axi_gmem2_b1_araddr),
    .m_axi_gmem2_b1_arlen(sig_m_axi_gmem2_b1_arlen),
    .m_axi_gmem2_b1_arsize(sig_m_axi_gmem2_b1_arsize),
    .m_axi_gmem2_b1_arburst(sig_m_axi_gmem2_b1_arburst),
    .m_axi_gmem2_b1_arlock(sig_m_axi_gmem2_b1_arlock),
    .m_axi_gmem2_b1_arcache(sig_m_axi_gmem2_b1_arcache),
    .m_axi_gmem2_b1_arprot(sig_m_axi_gmem2_b1_arprot),
    .m_axi_gmem2_b1_arqos(sig_m_axi_gmem2_b1_arqos),
    .m_axi_gmem2_b1_arregion(sig_m_axi_gmem2_b1_arregion),
    .m_axi_gmem2_b1_aruser(sig_m_axi_gmem2_b1_aruser),
    .m_axi_gmem2_b1_arvalid(sig_m_axi_gmem2_b1_arvalid),
    .m_axi_gmem2_b1_rready(sig_m_axi_gmem2_b1_rready));
  if_m_axi_gmem2_b2 #(.index(10),
    .BITSIZE_m_axi_gmem2_b2_bid(6),
    .BITSIZE_m_axi_gmem2_b2_bresp(2),
    .BITSIZE_m_axi_gmem2_b2_buser(1),
    .BITSIZE_m_axi_gmem2_b2_rid(6),
    .BITSIZE_m_axi_gmem2_b2_rdata(32),
    .BITSIZE_m_axi_gmem2_b2_rresp(2),
    .BITSIZE_m_axi_gmem2_b2_ruser(1),
    .BITSIZE_m_axi_gmem2_b2_awid(6),
    .BITSIZE_m_axi_gmem2_b2_awaddr(32),
    .BITSIZE_m_axi_gmem2_b2_awlen(8),
    .BITSIZE_m_axi_gmem2_b2_awsize(3),
    .BITSIZE_m_axi_gmem2_b2_awburst(2),
    .BITSIZE_m_axi_gmem2_b2_awlock(1),
    .BITSIZE_m_axi_gmem2_b2_awcache(4),
    .BITSIZE_m_axi_gmem2_b2_awprot(3),
    .BITSIZE_m_axi_gmem2_b2_awqos(4),
    .BITSIZE_m_axi_gmem2_b2_awregion(4),
    .BITSIZE_m_axi_gmem2_b2_awuser(1),
    .BITSIZE_m_axi_gmem2_b2_wdata(32),
    .BITSIZE_m_axi_gmem2_b2_wstrb(4),
    .BITSIZE_m_axi_gmem2_b2_wuser(1),
    .BITSIZE_m_axi_gmem2_b2_arid(6),
    .BITSIZE_m_axi_gmem2_b2_araddr(32),
    .BITSIZE_m_axi_gmem2_b2_arlen(8),
    .BITSIZE_m_axi_gmem2_b2_arsize(3),
    .BITSIZE_m_axi_gmem2_b2_arburst(2),
    .BITSIZE_m_axi_gmem2_b2_arlock(1),
    .BITSIZE_m_axi_gmem2_b2_arcache(4),
    .BITSIZE_m_axi_gmem2_b2_arprot(3),
    .BITSIZE_m_axi_gmem2_b2_arqos(4),
    .BITSIZE_m_axi_gmem2_b2_arregion(4),
    .BITSIZE_m_axi_gmem2_b2_aruser(1)) if_m_axi_gmem2_b2_fu (.m_axi_gmem2_b2_awready(sig_m_axi_gmem2_b2_awready),
    .m_axi_gmem2_b2_wready(sig_m_axi_gmem2_b2_wready),
    .m_axi_gmem2_b2_bid(sig_m_axi_gmem2_b2_bid),
    .m_axi_gmem2_b2_bresp(sig_m_axi_gmem2_b2_bresp),
    .m_axi_gmem2_b2_buser(sig_m_axi_gmem2_b2_buser),
    .m_axi_gmem2_b2_bvalid(sig_m_axi_gmem2_b2_bvalid),
    .m_axi_gmem2_b2_arready(sig_m_axi_gmem2_b2_arready),
    .m_axi_gmem2_b2_rid(sig_m_axi_gmem2_b2_rid),
    .m_axi_gmem2_b2_rdata(sig_m_axi_gmem2_b2_rdata),
    .m_axi_gmem2_b2_rresp(sig_m_axi_gmem2_b2_rresp),
    .m_axi_gmem2_b2_rlast(sig_m_axi_gmem2_b2_rlast),
    .m_axi_gmem2_b2_ruser(sig_m_axi_gmem2_b2_ruser),
    .m_axi_gmem2_b2_rvalid(sig_m_axi_gmem2_b2_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem2_b2_awid(sig_m_axi_gmem2_b2_awid),
    .m_axi_gmem2_b2_awaddr(sig_m_axi_gmem2_b2_awaddr),
    .m_axi_gmem2_b2_awlen(sig_m_axi_gmem2_b2_awlen),
    .m_axi_gmem2_b2_awsize(sig_m_axi_gmem2_b2_awsize),
    .m_axi_gmem2_b2_awburst(sig_m_axi_gmem2_b2_awburst),
    .m_axi_gmem2_b2_awlock(sig_m_axi_gmem2_b2_awlock),
    .m_axi_gmem2_b2_awcache(sig_m_axi_gmem2_b2_awcache),
    .m_axi_gmem2_b2_awprot(sig_m_axi_gmem2_b2_awprot),
    .m_axi_gmem2_b2_awqos(sig_m_axi_gmem2_b2_awqos),
    .m_axi_gmem2_b2_awregion(sig_m_axi_gmem2_b2_awregion),
    .m_axi_gmem2_b2_awuser(sig_m_axi_gmem2_b2_awuser),
    .m_axi_gmem2_b2_awvalid(sig_m_axi_gmem2_b2_awvalid),
    .m_axi_gmem2_b2_wdata(sig_m_axi_gmem2_b2_wdata),
    .m_axi_gmem2_b2_wstrb(sig_m_axi_gmem2_b2_wstrb),
    .m_axi_gmem2_b2_wlast(sig_m_axi_gmem2_b2_wlast),
    .m_axi_gmem2_b2_wuser(sig_m_axi_gmem2_b2_wuser),
    .m_axi_gmem2_b2_wvalid(sig_m_axi_gmem2_b2_wvalid),
    .m_axi_gmem2_b2_bready(sig_m_axi_gmem2_b2_bready),
    .m_axi_gmem2_b2_arid(sig_m_axi_gmem2_b2_arid),
    .m_axi_gmem2_b2_araddr(sig_m_axi_gmem2_b2_araddr),
    .m_axi_gmem2_b2_arlen(sig_m_axi_gmem2_b2_arlen),
    .m_axi_gmem2_b2_arsize(sig_m_axi_gmem2_b2_arsize),
    .m_axi_gmem2_b2_arburst(sig_m_axi_gmem2_b2_arburst),
    .m_axi_gmem2_b2_arlock(sig_m_axi_gmem2_b2_arlock),
    .m_axi_gmem2_b2_arcache(sig_m_axi_gmem2_b2_arcache),
    .m_axi_gmem2_b2_arprot(sig_m_axi_gmem2_b2_arprot),
    .m_axi_gmem2_b2_arqos(sig_m_axi_gmem2_b2_arqos),
    .m_axi_gmem2_b2_arregion(sig_m_axi_gmem2_b2_arregion),
    .m_axi_gmem2_b2_aruser(sig_m_axi_gmem2_b2_aruser),
    .m_axi_gmem2_b2_arvalid(sig_m_axi_gmem2_b2_arvalid),
    .m_axi_gmem2_b2_rready(sig_m_axi_gmem2_b2_rready));
  if_m_axi_gmem2_b3 #(.index(10),
    .BITSIZE_m_axi_gmem2_b3_bid(6),
    .BITSIZE_m_axi_gmem2_b3_bresp(2),
    .BITSIZE_m_axi_gmem2_b3_buser(1),
    .BITSIZE_m_axi_gmem2_b3_rid(6),
    .BITSIZE_m_axi_gmem2_b3_rdata(32),
    .BITSIZE_m_axi_gmem2_b3_rresp(2),
    .BITSIZE_m_axi_gmem2_b3_ruser(1),
    .BITSIZE_m_axi_gmem2_b3_awid(6),
    .BITSIZE_m_axi_gmem2_b3_awaddr(32),
    .BITSIZE_m_axi_gmem2_b3_awlen(8),
    .BITSIZE_m_axi_gmem2_b3_awsize(3),
    .BITSIZE_m_axi_gmem2_b3_awburst(2),
    .BITSIZE_m_axi_gmem2_b3_awlock(1),
    .BITSIZE_m_axi_gmem2_b3_awcache(4),
    .BITSIZE_m_axi_gmem2_b3_awprot(3),
    .BITSIZE_m_axi_gmem2_b3_awqos(4),
    .BITSIZE_m_axi_gmem2_b3_awregion(4),
    .BITSIZE_m_axi_gmem2_b3_awuser(1),
    .BITSIZE_m_axi_gmem2_b3_wdata(32),
    .BITSIZE_m_axi_gmem2_b3_wstrb(4),
    .BITSIZE_m_axi_gmem2_b3_wuser(1),
    .BITSIZE_m_axi_gmem2_b3_arid(6),
    .BITSIZE_m_axi_gmem2_b3_araddr(32),
    .BITSIZE_m_axi_gmem2_b3_arlen(8),
    .BITSIZE_m_axi_gmem2_b3_arsize(3),
    .BITSIZE_m_axi_gmem2_b3_arburst(2),
    .BITSIZE_m_axi_gmem2_b3_arlock(1),
    .BITSIZE_m_axi_gmem2_b3_arcache(4),
    .BITSIZE_m_axi_gmem2_b3_arprot(3),
    .BITSIZE_m_axi_gmem2_b3_arqos(4),
    .BITSIZE_m_axi_gmem2_b3_arregion(4),
    .BITSIZE_m_axi_gmem2_b3_aruser(1)) if_m_axi_gmem2_b3_fu (.m_axi_gmem2_b3_awready(sig_m_axi_gmem2_b3_awready),
    .m_axi_gmem2_b3_wready(sig_m_axi_gmem2_b3_wready),
    .m_axi_gmem2_b3_bid(sig_m_axi_gmem2_b3_bid),
    .m_axi_gmem2_b3_bresp(sig_m_axi_gmem2_b3_bresp),
    .m_axi_gmem2_b3_buser(sig_m_axi_gmem2_b3_buser),
    .m_axi_gmem2_b3_bvalid(sig_m_axi_gmem2_b3_bvalid),
    .m_axi_gmem2_b3_arready(sig_m_axi_gmem2_b3_arready),
    .m_axi_gmem2_b3_rid(sig_m_axi_gmem2_b3_rid),
    .m_axi_gmem2_b3_rdata(sig_m_axi_gmem2_b3_rdata),
    .m_axi_gmem2_b3_rresp(sig_m_axi_gmem2_b3_rresp),
    .m_axi_gmem2_b3_rlast(sig_m_axi_gmem2_b3_rlast),
    .m_axi_gmem2_b3_ruser(sig_m_axi_gmem2_b3_ruser),
    .m_axi_gmem2_b3_rvalid(sig_m_axi_gmem2_b3_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem2_b3_awid(sig_m_axi_gmem2_b3_awid),
    .m_axi_gmem2_b3_awaddr(sig_m_axi_gmem2_b3_awaddr),
    .m_axi_gmem2_b3_awlen(sig_m_axi_gmem2_b3_awlen),
    .m_axi_gmem2_b3_awsize(sig_m_axi_gmem2_b3_awsize),
    .m_axi_gmem2_b3_awburst(sig_m_axi_gmem2_b3_awburst),
    .m_axi_gmem2_b3_awlock(sig_m_axi_gmem2_b3_awlock),
    .m_axi_gmem2_b3_awcache(sig_m_axi_gmem2_b3_awcache),
    .m_axi_gmem2_b3_awprot(sig_m_axi_gmem2_b3_awprot),
    .m_axi_gmem2_b3_awqos(sig_m_axi_gmem2_b3_awqos),
    .m_axi_gmem2_b3_awregion(sig_m_axi_gmem2_b3_awregion),
    .m_axi_gmem2_b3_awuser(sig_m_axi_gmem2_b3_awuser),
    .m_axi_gmem2_b3_awvalid(sig_m_axi_gmem2_b3_awvalid),
    .m_axi_gmem2_b3_wdata(sig_m_axi_gmem2_b3_wdata),
    .m_axi_gmem2_b3_wstrb(sig_m_axi_gmem2_b3_wstrb),
    .m_axi_gmem2_b3_wlast(sig_m_axi_gmem2_b3_wlast),
    .m_axi_gmem2_b3_wuser(sig_m_axi_gmem2_b3_wuser),
    .m_axi_gmem2_b3_wvalid(sig_m_axi_gmem2_b3_wvalid),
    .m_axi_gmem2_b3_bready(sig_m_axi_gmem2_b3_bready),
    .m_axi_gmem2_b3_arid(sig_m_axi_gmem2_b3_arid),
    .m_axi_gmem2_b3_araddr(sig_m_axi_gmem2_b3_araddr),
    .m_axi_gmem2_b3_arlen(sig_m_axi_gmem2_b3_arlen),
    .m_axi_gmem2_b3_arsize(sig_m_axi_gmem2_b3_arsize),
    .m_axi_gmem2_b3_arburst(sig_m_axi_gmem2_b3_arburst),
    .m_axi_gmem2_b3_arlock(sig_m_axi_gmem2_b3_arlock),
    .m_axi_gmem2_b3_arcache(sig_m_axi_gmem2_b3_arcache),
    .m_axi_gmem2_b3_arprot(sig_m_axi_gmem2_b3_arprot),
    .m_axi_gmem2_b3_arqos(sig_m_axi_gmem2_b3_arqos),
    .m_axi_gmem2_b3_arregion(sig_m_axi_gmem2_b3_arregion),
    .m_axi_gmem2_b3_aruser(sig_m_axi_gmem2_b3_aruser),
    .m_axi_gmem2_b3_arvalid(sig_m_axi_gmem2_b3_arvalid),
    .m_axi_gmem2_b3_rready(sig_m_axi_gmem2_b3_rready));
  if_m_axi_gmem2_b4 #(.index(10),
    .BITSIZE_m_axi_gmem2_b4_bid(6),
    .BITSIZE_m_axi_gmem2_b4_bresp(2),
    .BITSIZE_m_axi_gmem2_b4_buser(1),
    .BITSIZE_m_axi_gmem2_b4_rid(6),
    .BITSIZE_m_axi_gmem2_b4_rdata(32),
    .BITSIZE_m_axi_gmem2_b4_rresp(2),
    .BITSIZE_m_axi_gmem2_b4_ruser(1),
    .BITSIZE_m_axi_gmem2_b4_awid(6),
    .BITSIZE_m_axi_gmem2_b4_awaddr(32),
    .BITSIZE_m_axi_gmem2_b4_awlen(8),
    .BITSIZE_m_axi_gmem2_b4_awsize(3),
    .BITSIZE_m_axi_gmem2_b4_awburst(2),
    .BITSIZE_m_axi_gmem2_b4_awlock(1),
    .BITSIZE_m_axi_gmem2_b4_awcache(4),
    .BITSIZE_m_axi_gmem2_b4_awprot(3),
    .BITSIZE_m_axi_gmem2_b4_awqos(4),
    .BITSIZE_m_axi_gmem2_b4_awregion(4),
    .BITSIZE_m_axi_gmem2_b4_awuser(1),
    .BITSIZE_m_axi_gmem2_b4_wdata(32),
    .BITSIZE_m_axi_gmem2_b4_wstrb(4),
    .BITSIZE_m_axi_gmem2_b4_wuser(1),
    .BITSIZE_m_axi_gmem2_b4_arid(6),
    .BITSIZE_m_axi_gmem2_b4_araddr(32),
    .BITSIZE_m_axi_gmem2_b4_arlen(8),
    .BITSIZE_m_axi_gmem2_b4_arsize(3),
    .BITSIZE_m_axi_gmem2_b4_arburst(2),
    .BITSIZE_m_axi_gmem2_b4_arlock(1),
    .BITSIZE_m_axi_gmem2_b4_arcache(4),
    .BITSIZE_m_axi_gmem2_b4_arprot(3),
    .BITSIZE_m_axi_gmem2_b4_arqos(4),
    .BITSIZE_m_axi_gmem2_b4_arregion(4),
    .BITSIZE_m_axi_gmem2_b4_aruser(1)) if_m_axi_gmem2_b4_fu (.m_axi_gmem2_b4_awready(sig_m_axi_gmem2_b4_awready),
    .m_axi_gmem2_b4_wready(sig_m_axi_gmem2_b4_wready),
    .m_axi_gmem2_b4_bid(sig_m_axi_gmem2_b4_bid),
    .m_axi_gmem2_b4_bresp(sig_m_axi_gmem2_b4_bresp),
    .m_axi_gmem2_b4_buser(sig_m_axi_gmem2_b4_buser),
    .m_axi_gmem2_b4_bvalid(sig_m_axi_gmem2_b4_bvalid),
    .m_axi_gmem2_b4_arready(sig_m_axi_gmem2_b4_arready),
    .m_axi_gmem2_b4_rid(sig_m_axi_gmem2_b4_rid),
    .m_axi_gmem2_b4_rdata(sig_m_axi_gmem2_b4_rdata),
    .m_axi_gmem2_b4_rresp(sig_m_axi_gmem2_b4_rresp),
    .m_axi_gmem2_b4_rlast(sig_m_axi_gmem2_b4_rlast),
    .m_axi_gmem2_b4_ruser(sig_m_axi_gmem2_b4_ruser),
    .m_axi_gmem2_b4_rvalid(sig_m_axi_gmem2_b4_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem2_b4_awid(sig_m_axi_gmem2_b4_awid),
    .m_axi_gmem2_b4_awaddr(sig_m_axi_gmem2_b4_awaddr),
    .m_axi_gmem2_b4_awlen(sig_m_axi_gmem2_b4_awlen),
    .m_axi_gmem2_b4_awsize(sig_m_axi_gmem2_b4_awsize),
    .m_axi_gmem2_b4_awburst(sig_m_axi_gmem2_b4_awburst),
    .m_axi_gmem2_b4_awlock(sig_m_axi_gmem2_b4_awlock),
    .m_axi_gmem2_b4_awcache(sig_m_axi_gmem2_b4_awcache),
    .m_axi_gmem2_b4_awprot(sig_m_axi_gmem2_b4_awprot),
    .m_axi_gmem2_b4_awqos(sig_m_axi_gmem2_b4_awqos),
    .m_axi_gmem2_b4_awregion(sig_m_axi_gmem2_b4_awregion),
    .m_axi_gmem2_b4_awuser(sig_m_axi_gmem2_b4_awuser),
    .m_axi_gmem2_b4_awvalid(sig_m_axi_gmem2_b4_awvalid),
    .m_axi_gmem2_b4_wdata(sig_m_axi_gmem2_b4_wdata),
    .m_axi_gmem2_b4_wstrb(sig_m_axi_gmem2_b4_wstrb),
    .m_axi_gmem2_b4_wlast(sig_m_axi_gmem2_b4_wlast),
    .m_axi_gmem2_b4_wuser(sig_m_axi_gmem2_b4_wuser),
    .m_axi_gmem2_b4_wvalid(sig_m_axi_gmem2_b4_wvalid),
    .m_axi_gmem2_b4_bready(sig_m_axi_gmem2_b4_bready),
    .m_axi_gmem2_b4_arid(sig_m_axi_gmem2_b4_arid),
    .m_axi_gmem2_b4_araddr(sig_m_axi_gmem2_b4_araddr),
    .m_axi_gmem2_b4_arlen(sig_m_axi_gmem2_b4_arlen),
    .m_axi_gmem2_b4_arsize(sig_m_axi_gmem2_b4_arsize),
    .m_axi_gmem2_b4_arburst(sig_m_axi_gmem2_b4_arburst),
    .m_axi_gmem2_b4_arlock(sig_m_axi_gmem2_b4_arlock),
    .m_axi_gmem2_b4_arcache(sig_m_axi_gmem2_b4_arcache),
    .m_axi_gmem2_b4_arprot(sig_m_axi_gmem2_b4_arprot),
    .m_axi_gmem2_b4_arqos(sig_m_axi_gmem2_b4_arqos),
    .m_axi_gmem2_b4_arregion(sig_m_axi_gmem2_b4_arregion),
    .m_axi_gmem2_b4_aruser(sig_m_axi_gmem2_b4_aruser),
    .m_axi_gmem2_b4_arvalid(sig_m_axi_gmem2_b4_arvalid),
    .m_axi_gmem2_b4_rready(sig_m_axi_gmem2_b4_rready));
  if_m_axi_gmem2_b5 #(.index(10),
    .BITSIZE_m_axi_gmem2_b5_bid(6),
    .BITSIZE_m_axi_gmem2_b5_bresp(2),
    .BITSIZE_m_axi_gmem2_b5_buser(1),
    .BITSIZE_m_axi_gmem2_b5_rid(6),
    .BITSIZE_m_axi_gmem2_b5_rdata(32),
    .BITSIZE_m_axi_gmem2_b5_rresp(2),
    .BITSIZE_m_axi_gmem2_b5_ruser(1),
    .BITSIZE_m_axi_gmem2_b5_awid(6),
    .BITSIZE_m_axi_gmem2_b5_awaddr(32),
    .BITSIZE_m_axi_gmem2_b5_awlen(8),
    .BITSIZE_m_axi_gmem2_b5_awsize(3),
    .BITSIZE_m_axi_gmem2_b5_awburst(2),
    .BITSIZE_m_axi_gmem2_b5_awlock(1),
    .BITSIZE_m_axi_gmem2_b5_awcache(4),
    .BITSIZE_m_axi_gmem2_b5_awprot(3),
    .BITSIZE_m_axi_gmem2_b5_awqos(4),
    .BITSIZE_m_axi_gmem2_b5_awregion(4),
    .BITSIZE_m_axi_gmem2_b5_awuser(1),
    .BITSIZE_m_axi_gmem2_b5_wdata(32),
    .BITSIZE_m_axi_gmem2_b5_wstrb(4),
    .BITSIZE_m_axi_gmem2_b5_wuser(1),
    .BITSIZE_m_axi_gmem2_b5_arid(6),
    .BITSIZE_m_axi_gmem2_b5_araddr(32),
    .BITSIZE_m_axi_gmem2_b5_arlen(8),
    .BITSIZE_m_axi_gmem2_b5_arsize(3),
    .BITSIZE_m_axi_gmem2_b5_arburst(2),
    .BITSIZE_m_axi_gmem2_b5_arlock(1),
    .BITSIZE_m_axi_gmem2_b5_arcache(4),
    .BITSIZE_m_axi_gmem2_b5_arprot(3),
    .BITSIZE_m_axi_gmem2_b5_arqos(4),
    .BITSIZE_m_axi_gmem2_b5_arregion(4),
    .BITSIZE_m_axi_gmem2_b5_aruser(1)) if_m_axi_gmem2_b5_fu (.m_axi_gmem2_b5_awready(sig_m_axi_gmem2_b5_awready),
    .m_axi_gmem2_b5_wready(sig_m_axi_gmem2_b5_wready),
    .m_axi_gmem2_b5_bid(sig_m_axi_gmem2_b5_bid),
    .m_axi_gmem2_b5_bresp(sig_m_axi_gmem2_b5_bresp),
    .m_axi_gmem2_b5_buser(sig_m_axi_gmem2_b5_buser),
    .m_axi_gmem2_b5_bvalid(sig_m_axi_gmem2_b5_bvalid),
    .m_axi_gmem2_b5_arready(sig_m_axi_gmem2_b5_arready),
    .m_axi_gmem2_b5_rid(sig_m_axi_gmem2_b5_rid),
    .m_axi_gmem2_b5_rdata(sig_m_axi_gmem2_b5_rdata),
    .m_axi_gmem2_b5_rresp(sig_m_axi_gmem2_b5_rresp),
    .m_axi_gmem2_b5_rlast(sig_m_axi_gmem2_b5_rlast),
    .m_axi_gmem2_b5_ruser(sig_m_axi_gmem2_b5_ruser),
    .m_axi_gmem2_b5_rvalid(sig_m_axi_gmem2_b5_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem2_b5_awid(sig_m_axi_gmem2_b5_awid),
    .m_axi_gmem2_b5_awaddr(sig_m_axi_gmem2_b5_awaddr),
    .m_axi_gmem2_b5_awlen(sig_m_axi_gmem2_b5_awlen),
    .m_axi_gmem2_b5_awsize(sig_m_axi_gmem2_b5_awsize),
    .m_axi_gmem2_b5_awburst(sig_m_axi_gmem2_b5_awburst),
    .m_axi_gmem2_b5_awlock(sig_m_axi_gmem2_b5_awlock),
    .m_axi_gmem2_b5_awcache(sig_m_axi_gmem2_b5_awcache),
    .m_axi_gmem2_b5_awprot(sig_m_axi_gmem2_b5_awprot),
    .m_axi_gmem2_b5_awqos(sig_m_axi_gmem2_b5_awqos),
    .m_axi_gmem2_b5_awregion(sig_m_axi_gmem2_b5_awregion),
    .m_axi_gmem2_b5_awuser(sig_m_axi_gmem2_b5_awuser),
    .m_axi_gmem2_b5_awvalid(sig_m_axi_gmem2_b5_awvalid),
    .m_axi_gmem2_b5_wdata(sig_m_axi_gmem2_b5_wdata),
    .m_axi_gmem2_b5_wstrb(sig_m_axi_gmem2_b5_wstrb),
    .m_axi_gmem2_b5_wlast(sig_m_axi_gmem2_b5_wlast),
    .m_axi_gmem2_b5_wuser(sig_m_axi_gmem2_b5_wuser),
    .m_axi_gmem2_b5_wvalid(sig_m_axi_gmem2_b5_wvalid),
    .m_axi_gmem2_b5_bready(sig_m_axi_gmem2_b5_bready),
    .m_axi_gmem2_b5_arid(sig_m_axi_gmem2_b5_arid),
    .m_axi_gmem2_b5_araddr(sig_m_axi_gmem2_b5_araddr),
    .m_axi_gmem2_b5_arlen(sig_m_axi_gmem2_b5_arlen),
    .m_axi_gmem2_b5_arsize(sig_m_axi_gmem2_b5_arsize),
    .m_axi_gmem2_b5_arburst(sig_m_axi_gmem2_b5_arburst),
    .m_axi_gmem2_b5_arlock(sig_m_axi_gmem2_b5_arlock),
    .m_axi_gmem2_b5_arcache(sig_m_axi_gmem2_b5_arcache),
    .m_axi_gmem2_b5_arprot(sig_m_axi_gmem2_b5_arprot),
    .m_axi_gmem2_b5_arqos(sig_m_axi_gmem2_b5_arqos),
    .m_axi_gmem2_b5_arregion(sig_m_axi_gmem2_b5_arregion),
    .m_axi_gmem2_b5_aruser(sig_m_axi_gmem2_b5_aruser),
    .m_axi_gmem2_b5_arvalid(sig_m_axi_gmem2_b5_arvalid),
    .m_axi_gmem2_b5_rready(sig_m_axi_gmem2_b5_rready));
  if_m_axi_gmem2_b6 #(.index(10),
    .BITSIZE_m_axi_gmem2_b6_bid(6),
    .BITSIZE_m_axi_gmem2_b6_bresp(2),
    .BITSIZE_m_axi_gmem2_b6_buser(1),
    .BITSIZE_m_axi_gmem2_b6_rid(6),
    .BITSIZE_m_axi_gmem2_b6_rdata(32),
    .BITSIZE_m_axi_gmem2_b6_rresp(2),
    .BITSIZE_m_axi_gmem2_b6_ruser(1),
    .BITSIZE_m_axi_gmem2_b6_awid(6),
    .BITSIZE_m_axi_gmem2_b6_awaddr(32),
    .BITSIZE_m_axi_gmem2_b6_awlen(8),
    .BITSIZE_m_axi_gmem2_b6_awsize(3),
    .BITSIZE_m_axi_gmem2_b6_awburst(2),
    .BITSIZE_m_axi_gmem2_b6_awlock(1),
    .BITSIZE_m_axi_gmem2_b6_awcache(4),
    .BITSIZE_m_axi_gmem2_b6_awprot(3),
    .BITSIZE_m_axi_gmem2_b6_awqos(4),
    .BITSIZE_m_axi_gmem2_b6_awregion(4),
    .BITSIZE_m_axi_gmem2_b6_awuser(1),
    .BITSIZE_m_axi_gmem2_b6_wdata(32),
    .BITSIZE_m_axi_gmem2_b6_wstrb(4),
    .BITSIZE_m_axi_gmem2_b6_wuser(1),
    .BITSIZE_m_axi_gmem2_b6_arid(6),
    .BITSIZE_m_axi_gmem2_b6_araddr(32),
    .BITSIZE_m_axi_gmem2_b6_arlen(8),
    .BITSIZE_m_axi_gmem2_b6_arsize(3),
    .BITSIZE_m_axi_gmem2_b6_arburst(2),
    .BITSIZE_m_axi_gmem2_b6_arlock(1),
    .BITSIZE_m_axi_gmem2_b6_arcache(4),
    .BITSIZE_m_axi_gmem2_b6_arprot(3),
    .BITSIZE_m_axi_gmem2_b6_arqos(4),
    .BITSIZE_m_axi_gmem2_b6_arregion(4),
    .BITSIZE_m_axi_gmem2_b6_aruser(1)) if_m_axi_gmem2_b6_fu (.m_axi_gmem2_b6_awready(sig_m_axi_gmem2_b6_awready),
    .m_axi_gmem2_b6_wready(sig_m_axi_gmem2_b6_wready),
    .m_axi_gmem2_b6_bid(sig_m_axi_gmem2_b6_bid),
    .m_axi_gmem2_b6_bresp(sig_m_axi_gmem2_b6_bresp),
    .m_axi_gmem2_b6_buser(sig_m_axi_gmem2_b6_buser),
    .m_axi_gmem2_b6_bvalid(sig_m_axi_gmem2_b6_bvalid),
    .m_axi_gmem2_b6_arready(sig_m_axi_gmem2_b6_arready),
    .m_axi_gmem2_b6_rid(sig_m_axi_gmem2_b6_rid),
    .m_axi_gmem2_b6_rdata(sig_m_axi_gmem2_b6_rdata),
    .m_axi_gmem2_b6_rresp(sig_m_axi_gmem2_b6_rresp),
    .m_axi_gmem2_b6_rlast(sig_m_axi_gmem2_b6_rlast),
    .m_axi_gmem2_b6_ruser(sig_m_axi_gmem2_b6_ruser),
    .m_axi_gmem2_b6_rvalid(sig_m_axi_gmem2_b6_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem2_b6_awid(sig_m_axi_gmem2_b6_awid),
    .m_axi_gmem2_b6_awaddr(sig_m_axi_gmem2_b6_awaddr),
    .m_axi_gmem2_b6_awlen(sig_m_axi_gmem2_b6_awlen),
    .m_axi_gmem2_b6_awsize(sig_m_axi_gmem2_b6_awsize),
    .m_axi_gmem2_b6_awburst(sig_m_axi_gmem2_b6_awburst),
    .m_axi_gmem2_b6_awlock(sig_m_axi_gmem2_b6_awlock),
    .m_axi_gmem2_b6_awcache(sig_m_axi_gmem2_b6_awcache),
    .m_axi_gmem2_b6_awprot(sig_m_axi_gmem2_b6_awprot),
    .m_axi_gmem2_b6_awqos(sig_m_axi_gmem2_b6_awqos),
    .m_axi_gmem2_b6_awregion(sig_m_axi_gmem2_b6_awregion),
    .m_axi_gmem2_b6_awuser(sig_m_axi_gmem2_b6_awuser),
    .m_axi_gmem2_b6_awvalid(sig_m_axi_gmem2_b6_awvalid),
    .m_axi_gmem2_b6_wdata(sig_m_axi_gmem2_b6_wdata),
    .m_axi_gmem2_b6_wstrb(sig_m_axi_gmem2_b6_wstrb),
    .m_axi_gmem2_b6_wlast(sig_m_axi_gmem2_b6_wlast),
    .m_axi_gmem2_b6_wuser(sig_m_axi_gmem2_b6_wuser),
    .m_axi_gmem2_b6_wvalid(sig_m_axi_gmem2_b6_wvalid),
    .m_axi_gmem2_b6_bready(sig_m_axi_gmem2_b6_bready),
    .m_axi_gmem2_b6_arid(sig_m_axi_gmem2_b6_arid),
    .m_axi_gmem2_b6_araddr(sig_m_axi_gmem2_b6_araddr),
    .m_axi_gmem2_b6_arlen(sig_m_axi_gmem2_b6_arlen),
    .m_axi_gmem2_b6_arsize(sig_m_axi_gmem2_b6_arsize),
    .m_axi_gmem2_b6_arburst(sig_m_axi_gmem2_b6_arburst),
    .m_axi_gmem2_b6_arlock(sig_m_axi_gmem2_b6_arlock),
    .m_axi_gmem2_b6_arcache(sig_m_axi_gmem2_b6_arcache),
    .m_axi_gmem2_b6_arprot(sig_m_axi_gmem2_b6_arprot),
    .m_axi_gmem2_b6_arqos(sig_m_axi_gmem2_b6_arqos),
    .m_axi_gmem2_b6_arregion(sig_m_axi_gmem2_b6_arregion),
    .m_axi_gmem2_b6_aruser(sig_m_axi_gmem2_b6_aruser),
    .m_axi_gmem2_b6_arvalid(sig_m_axi_gmem2_b6_arvalid),
    .m_axi_gmem2_b6_rready(sig_m_axi_gmem2_b6_rready));
  if_m_axi_gmem2_b7 #(.index(10),
    .BITSIZE_m_axi_gmem2_b7_bid(6),
    .BITSIZE_m_axi_gmem2_b7_bresp(2),
    .BITSIZE_m_axi_gmem2_b7_buser(1),
    .BITSIZE_m_axi_gmem2_b7_rid(6),
    .BITSIZE_m_axi_gmem2_b7_rdata(32),
    .BITSIZE_m_axi_gmem2_b7_rresp(2),
    .BITSIZE_m_axi_gmem2_b7_ruser(1),
    .BITSIZE_m_axi_gmem2_b7_awid(6),
    .BITSIZE_m_axi_gmem2_b7_awaddr(32),
    .BITSIZE_m_axi_gmem2_b7_awlen(8),
    .BITSIZE_m_axi_gmem2_b7_awsize(3),
    .BITSIZE_m_axi_gmem2_b7_awburst(2),
    .BITSIZE_m_axi_gmem2_b7_awlock(1),
    .BITSIZE_m_axi_gmem2_b7_awcache(4),
    .BITSIZE_m_axi_gmem2_b7_awprot(3),
    .BITSIZE_m_axi_gmem2_b7_awqos(4),
    .BITSIZE_m_axi_gmem2_b7_awregion(4),
    .BITSIZE_m_axi_gmem2_b7_awuser(1),
    .BITSIZE_m_axi_gmem2_b7_wdata(32),
    .BITSIZE_m_axi_gmem2_b7_wstrb(4),
    .BITSIZE_m_axi_gmem2_b7_wuser(1),
    .BITSIZE_m_axi_gmem2_b7_arid(6),
    .BITSIZE_m_axi_gmem2_b7_araddr(32),
    .BITSIZE_m_axi_gmem2_b7_arlen(8),
    .BITSIZE_m_axi_gmem2_b7_arsize(3),
    .BITSIZE_m_axi_gmem2_b7_arburst(2),
    .BITSIZE_m_axi_gmem2_b7_arlock(1),
    .BITSIZE_m_axi_gmem2_b7_arcache(4),
    .BITSIZE_m_axi_gmem2_b7_arprot(3),
    .BITSIZE_m_axi_gmem2_b7_arqos(4),
    .BITSIZE_m_axi_gmem2_b7_arregion(4),
    .BITSIZE_m_axi_gmem2_b7_aruser(1)) if_m_axi_gmem2_b7_fu (.m_axi_gmem2_b7_awready(sig_m_axi_gmem2_b7_awready),
    .m_axi_gmem2_b7_wready(sig_m_axi_gmem2_b7_wready),
    .m_axi_gmem2_b7_bid(sig_m_axi_gmem2_b7_bid),
    .m_axi_gmem2_b7_bresp(sig_m_axi_gmem2_b7_bresp),
    .m_axi_gmem2_b7_buser(sig_m_axi_gmem2_b7_buser),
    .m_axi_gmem2_b7_bvalid(sig_m_axi_gmem2_b7_bvalid),
    .m_axi_gmem2_b7_arready(sig_m_axi_gmem2_b7_arready),
    .m_axi_gmem2_b7_rid(sig_m_axi_gmem2_b7_rid),
    .m_axi_gmem2_b7_rdata(sig_m_axi_gmem2_b7_rdata),
    .m_axi_gmem2_b7_rresp(sig_m_axi_gmem2_b7_rresp),
    .m_axi_gmem2_b7_rlast(sig_m_axi_gmem2_b7_rlast),
    .m_axi_gmem2_b7_ruser(sig_m_axi_gmem2_b7_ruser),
    .m_axi_gmem2_b7_rvalid(sig_m_axi_gmem2_b7_rvalid),
    .clock(clock),
    .reset(sig_reset),
    .done_port(sig_done_port),
    .m_axi_gmem2_b7_awid(sig_m_axi_gmem2_b7_awid),
    .m_axi_gmem2_b7_awaddr(sig_m_axi_gmem2_b7_awaddr),
    .m_axi_gmem2_b7_awlen(sig_m_axi_gmem2_b7_awlen),
    .m_axi_gmem2_b7_awsize(sig_m_axi_gmem2_b7_awsize),
    .m_axi_gmem2_b7_awburst(sig_m_axi_gmem2_b7_awburst),
    .m_axi_gmem2_b7_awlock(sig_m_axi_gmem2_b7_awlock),
    .m_axi_gmem2_b7_awcache(sig_m_axi_gmem2_b7_awcache),
    .m_axi_gmem2_b7_awprot(sig_m_axi_gmem2_b7_awprot),
    .m_axi_gmem2_b7_awqos(sig_m_axi_gmem2_b7_awqos),
    .m_axi_gmem2_b7_awregion(sig_m_axi_gmem2_b7_awregion),
    .m_axi_gmem2_b7_awuser(sig_m_axi_gmem2_b7_awuser),
    .m_axi_gmem2_b7_awvalid(sig_m_axi_gmem2_b7_awvalid),
    .m_axi_gmem2_b7_wdata(sig_m_axi_gmem2_b7_wdata),
    .m_axi_gmem2_b7_wstrb(sig_m_axi_gmem2_b7_wstrb),
    .m_axi_gmem2_b7_wlast(sig_m_axi_gmem2_b7_wlast),
    .m_axi_gmem2_b7_wuser(sig_m_axi_gmem2_b7_wuser),
    .m_axi_gmem2_b7_wvalid(sig_m_axi_gmem2_b7_wvalid),
    .m_axi_gmem2_b7_bready(sig_m_axi_gmem2_b7_bready),
    .m_axi_gmem2_b7_arid(sig_m_axi_gmem2_b7_arid),
    .m_axi_gmem2_b7_araddr(sig_m_axi_gmem2_b7_araddr),
    .m_axi_gmem2_b7_arlen(sig_m_axi_gmem2_b7_arlen),
    .m_axi_gmem2_b7_arsize(sig_m_axi_gmem2_b7_arsize),
    .m_axi_gmem2_b7_arburst(sig_m_axi_gmem2_b7_arburst),
    .m_axi_gmem2_b7_arlock(sig_m_axi_gmem2_b7_arlock),
    .m_axi_gmem2_b7_arcache(sig_m_axi_gmem2_b7_arcache),
    .m_axi_gmem2_b7_arprot(sig_m_axi_gmem2_b7_arprot),
    .m_axi_gmem2_b7_arqos(sig_m_axi_gmem2_b7_arqos),
    .m_axi_gmem2_b7_arregion(sig_m_axi_gmem2_b7_arregion),
    .m_axi_gmem2_b7_aruser(sig_m_axi_gmem2_b7_aruser),
    .m_axi_gmem2_b7_arvalid(sig_m_axi_gmem2_b7_arvalid),
    .m_axi_gmem2_b7_rready(sig_m_axi_gmem2_b7_rready));

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
