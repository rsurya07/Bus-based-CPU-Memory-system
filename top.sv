/////////////////////////////////////////////////////////////////////
// top.sv - Top level module for HW #4
//
// Author:	Roy Kravitz(roy.kravitz@pdx.edu)
// Date:	15-Feb-2019
//
// Description:
// ------------
// Implements the top level module for HW #4.  Instantiates
// the interfaces and the testbenches.
//
// Note: nearly all of the bus functionality is encapsulated in the
// interface(s).
// 
// Note:  Concept provided by D. Thomas but everything else is my own
//////////////////////////////////////////////////////////////////////

import mcDefs::*;

module top;

// internal variables
bit clk = 0, resetH = 0;


// instantiate the interfaces
main_bus_if M(.*);
memArray_if MEMORY();

processor_if P
(
	.M(M.master)
);

// memory interface
memory_if
#(
	.PAGE(MEMPAGE1)
) MC
(
	.S(M.slave),
	.A(MEMORY.MemIF)
);

// memory array
mem MEM
(
	.MBUS(M.slave),
	.MIF(MEMORY.MemIF)
);

// instantiate the modules
cpu_tb CPU
(
	.MB(M.master),
	.PROC(P.SndRcv)
);


initial begin: clockGenerator
	clk = 0;
	repeat(210) #5 clk = ~clk;
end: clockGenerator

// reset the system and start things running
initial begin: setup
	resetH = 1;
	repeat(5) @(posedge clk);
	resetH = 0;
end: setup

endmodule: top
