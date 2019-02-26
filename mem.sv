//////////////////////////////////////////////////////////////
// mem.sv - Memory simulator for ECE 571 HW #4
//
// Author:	Roy Kravitz (roy.kravitz@pdx.edu)
// Date:	15-Feb-2019
//
// Description:
// ------------
// Implements a simple synchronous Read/Write memory system.  The model is parameterized
// to adjust the width and depth of the memory array
//
// Note:  Original code created by Don T.
////////////////////////////////////////////////////////////////

// global definitions, parameters, etc.
import mcDefs::*;

module mem
(
	main_bus_if							MBUS,	// Main bus interface 
												// you get the clock/reset from here
	memArray_if.MemIF					MIF		// memory control interface
												// you get the memory address, data and control from here
);

// parameters MEMSIZE and BUSWIDTH are provided in mcDefs.sv
localparam ADDRWIDTH = $clog2(MEMSIZE);	// number of address bits for the array

// declare internal variables
logic	[BUSWIDTH-1:0]		M[MEMSIZE];			// memory array

// clear the memory locations
initial begin
	for (int i = 0; i < MEMSIZE; i++) begin
		M[i] = 0;
	end
end // clear the memory locations


// read a location from memory
always_comb begin
	if (MIF.rdEn == 1'b1)
		MIF.DataOut = M[MIF.Addr];
end

// write a location in memory
always @(posedge MBUS.clk) begin
	if (MIF.wrEn == 1'b1) begin
		M[MIF.Addr] <= MIF.DataIn;
	end
end // write a location in memory

endmodule
