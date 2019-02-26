
	
interface main_bus_if
(
	input logic clk,
	input logic resetH
);
	import mcDefs::*;
	// bus signals
	tri [BUSWIDTH-1: 0] AddrData;
	logic 	AddrValid;
	logic 	rw;
	
	modport master (
		input	clk,
		input	resetH,
		output	AddrValid,
		output	rw,
		inout	AddrData
	);
	
	modport slave (
		input	clk,
		input	resetH,
		input	AddrValid,
		input	rw,
		inout	AddrData
	);
	
endinterface: main_bus_if