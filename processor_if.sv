//////////////////////////////////////////////////////////////
// processor_if.sv - processor interface
//
// Author:	Roy Kravitz(roy.kravitz@pdx.edu) 
// Date:	15-Feb-2019
//
// Edited: Surya Ravikumar
// Date:   2/23/2019
//
// Description:
// ------------
// Defines the interface between the CPU (processor) and the main bus.
// The main bus uses the same protocol and signals as used in HW #4.
//
// implements methods to read and write memory.  
// 
// Note:  Original concept by Don T. but the implementation is my own
//////////////////////////////////////////////////////////////////////

// global definitions, parameters, etc.
import mcDefs::*;
	
interface processor_if
(
	main_bus_if.master 	M		// interface to processor is a master
);

modport SndRcv 
(
	import Proc_rdReq,
	import Proc_wrReq
);

// parameters, typedefs, enums, etc.
localparam DBUFWIDTH = BUSWIDTH * DATAPAYLOADSIZE;

typedef enum {ADDR, WAITE, DATA0, DATA1, DATA2, DATA3} state_t;

// local variables
state_t rdReq_st, rdReq_ns, wrReq_st, wrReq_ns;

bit 						rdReq_start, wrReq_start, rdReq_done, wrReq_done;
logic	[BUSWIDTH-1 : 0]	ma;
logic	[BUSWIDTH-1 : 0]	rdReq_dbuf [DATAPAYLOADSIZE], wrReq_dbuf[DATAPAYLOADSIZE];
logic	[BUSWIDTH-1 : 0] 	din, rdReq_dout, wrReq_dout, dout;

bit							rdReq_drv, wrReq_drv;
bit							rdReq_rw, wrReq_rw;
bit							rdReq_AddrValid, wrReq_AddrValid;


// Drive the AddrData bus (it's a tristate bus)
always_comb begin
	if (wrReq_drv) begin
		dout = wrReq_dout;
	end
	else if (rdReq_drv) begin
		dout = rdReq_dout;
	end
	else begin
		dout = 'z;
	end
end  // drive the AddrData bus
assign M.AddrData = dout;		
assign din = M.AddrData;

// drive the control signals
always_comb begin
	M.AddrValid = rdReq_AddrValid | wrReq_AddrValid;
	M.rw = rdReq_rw | wrReq_rw;
end // drive the control signals



////////////////////////
// Memory access methods
////////////////////////

// processor read request
// reads data from memory and returns it in
// the packed array data
task Proc_rdReq
(
	input 	bit [3:0]			page,
	input 	bit [11:0]			baseaddr,
	output 	bit [DBUFWIDTH-1:0]	data
);
begin
	// assign the memory address
	ma = {page, baseaddr};
	
	// kick off the memory access
	@(posedge M.clk);		
	rdReq_start = 1;
	@(posedge M.clk);
	rdReq_start = 0;
	
	// wait for the memory access to finish
	wait(rdReq_done);
	
	// pass the return data back
	data = {rdReq_dbuf[3], rdReq_dbuf[2], rdReq_dbuf[1], rdReq_dbuf[0]};
end
	
endtask: Proc_rdReq


// processor  write request
// writes bits in the packed array data to memory array
task Proc_wrReq
(
	input 	bit [3:0] page,
	input 	bit [11:0] baseaddr,
	input 	bit [DBUFWIDTH-1 : 0]	data
);
begin
	// assign the memory address
	ma = {page, baseaddr};
	
	// fill the data buffer with the write data
	wrReq_dbuf[3] = data[63:48];
	wrReq_dbuf[2] = data[47:32];
	wrReq_dbuf[1] = data[31:16];
	wrReq_dbuf[0] = data[15:0];
	
	// kick off the memory access
	@(posedge M.clk);		
	wrReq_start = 1;
	@(posedge M.clk);
	wrReq_start = 0;
	
	// wait for the memory access to finish
	wait(wrReq_done);
end

endtask: Proc_wrReq;



/////////////////////////////////////
// FSM's to implement memory accesses
/////////////////////////////////////

// implement a memory read as a simple FSM (more of a counter)
// since the address and the 4 data words come out on consecutive
// clock cycles

// memory read - sequential block
always_ff @(posedge M.clk, posedge M.resetH) begin
	if (M.resetH) begin
		rdReq_st <= ADDR;
	end
	else begin
		rdReq_st <= rdReq_ns;
	end
end  // memory read - sequential block

// combinational next state and output block
always_comb begin
	rdReq_ns = ADDR;
	rdReq_drv = 0;
	rdReq_AddrValid = 0;
	rdReq_rw = 0;
	rdReq_done = 0;
	
	unique case (rdReq_st)
		ADDR:  begin
			if (rdReq_start) begin
				rdReq_dout = ma;
				rdReq_AddrValid = 1;
				rdReq_rw = 1;
				rdReq_drv = 1;
				
				rdReq_ns = DATA0;
			end
		end
						
		DATA0: begin
			rdReq_dbuf[0] = din;			
			rdReq_ns = DATA1;
		end
		
		DATA1: begin
			rdReq_dbuf[1] = din;
			rdReq_ns = DATA2;
		end
		
		DATA2: begin
			rdReq_dbuf[2] = din;
			rdReq_ns = DATA3;
		end
		
		DATA3: begin
			rdReq_dbuf[3] = din;
			rdReq_ns = WAITE;
		end
		
		WAITE: begin		// wait for read to finish
			rdReq_ns = ADDR;
			rdReq_done = 1;
		end
	endcase
end // memory read - next state and output block



// implement a memory write as a simple FSM (more of a counter)
// since the address and the 4 data words come out on consecutive
// clock cycles

// sequential block
always_ff @(posedge M.clk, posedge M.resetH) begin
	if (M.resetH) begin
		wrReq_st <= ADDR;
	end
	else begin
		wrReq_st <= wrReq_ns;
	end
end  // memory write - sequential block

// combinational next state and output block
always_comb begin
	wrReq_ns = ADDR;
	wrReq_drv = 0;
	wrReq_AddrValid = 0;
	wrReq_rw = 0;
	wrReq_done = 0;
	
	unique case (wrReq_st)
		ADDR:  begin
			if (wrReq_start) begin
				wrReq_dout = ma;
				wrReq_AddrValid = 1;
				wrReq_rw = 0;
				wrReq_drv = 1;
				
				wrReq_ns = DATA0;
			end
		end
			
		DATA0: begin
			wrReq_dout = wrReq_dbuf[0];	
			wrReq_drv = 1;			
			wrReq_ns = DATA1;
		end
		
		DATA1: begin
			wrReq_dout = wrReq_dbuf[1];
			wrReq_drv = 1;
			wrReq_ns = DATA2;
		end
		
		DATA2: begin
			wrReq_dout = wrReq_dbuf[2];
			wrReq_drv = 1;
			wrReq_ns = DATA3;
		end
		
		DATA3: begin
			wrReq_dout = wrReq_dbuf[3];
			wrReq_drv = 1;
			wrReq_ns = WAITE;
		end
		
		WAITE: begin		// wait for write to finish
			wrReq_ns = ADDR;
			wrReq_done = 1;
		end
			
	endcase
end // memory write - next state and output block

endinterface: processor_if
		
		
			
			
		
			
			
			
	

 

