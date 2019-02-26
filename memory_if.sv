/*****************************************************
memory_if.sv - interface that defines memory operations.

Name: Surya Ravikumar
Date: 2/24/2019

Description: 	This interface responds to CPU requests by either
				reading or writing data from/to memory. Both read 
				and write are implemented using state machines, where
				the initial Address state is followed by DATA0, DATA1,
				DATA2 & DATA3 states. While an operation is being performed,
				READ or WRITE, the other operation's state enters the WAITE state.
				THis interface used the slave modport of the mainbus to transact.
***********************************************************************/

import mcDefs::*;

interface memory_if
#(
	parameter logic [3:0] PAGE = 4'h2
)
(
	main_bus_if.slave S, //main bus interface
	memArray_if.MemIF A	 //memory bus interface
);

	typedef enum {ADDR, WAITE, DATA0, DATA1, DATA2, DATA3} state_t;

	state_t rdReq_st, rdReq_ns, wrReq_st, wrReq_ns; //define current and next states for read and write

	bit rdReq_drv, wrReq_drv;	//variable to signal if read or write is being performed

	logic [11:0] baseAddress;	//variable to hold base address supplied by master
	logic [BUSWIDTH-1:0] d;		//variable to hold data

	always_ff @(posedge S.clk or S.resetH)
	begin
	    if(S.resetH)	//if reset high
	    begin
			wrReq_st <= WAITE;	//enter WAITE states
			rdReq_st <= WAITE;
	    end

	    else
	    begin
			wrReq_st <= wrReq_ns;	//else update state
			rdReq_st <= rdReq_ns;
	    end	
	end

	always_comb
	begin:readBlock

	   
	    if(rdReq_st == ADDR) //if read is in address state, receive address
	    begin
		
			if(S.AddrValid && S.rw && S.AddrData[15:12] == PAGE) 	//if address is valid, and read operation and page is current page
			begin
		    	baseAddress = S.AddrData[11:0];	//received base address
		   	 	rdReq_ns = DATA0;	//set next state
		    	A.Addr = 'bz;		
		    	A.rdEn = 1'b1;		//assert read signal to mem
		    	A.wrEn = 1'b0;		//de assert write signal to mem
		    	rdReq_drv = 1'b1;	//read signal being processed
		    	wrReq_drv = 1'b0;

		    	wrReq_ns = WAITE;	//set write's state to WAITE
			end
	    end

	    else if(rdReq_st == DATA0 && rdReq_drv)	//if expecting first chunk of data
	    begin
			A.Addr = baseAddress;	//set read address to base address
			A.rdEn = 1'b1;
			A.wrEn = 1'b0;

			rdReq_ns = DATA1;	//update next state
	    end

	    else if(rdReq_st == DATA1 && rdReq_drv)	//if expecting second chunk of data
	    begin
			A.Addr = baseAddress + 1;	//set read address to base address + 1
			A.rdEn = 1'b1;
			A.wrEn = 1'b0;

			rdReq_ns = DATA2;		//update next state
	    end

	    else if(rdReq_st == DATA2 && rdReq_drv)	//if expecting third chunk of data
	    begin
			A.Addr = baseAddress + 2;	//set read address to base + 2
			A.rdEn = 1'b1;
			A.wrEn = 1'b0;

			rdReq_ns = DATA3;	//update next state
	    end

	    else if(rdReq_st == DATA3 && rdReq_drv)	//if expecting 4th chunk of data
	    begin
			A.Addr = baseAddress + 3;		//set read address to base + 3
			A.rdEn = 1'b1;
			A.wrEn = 1'b0;

			rdReq_ns = ADDR;		//set states of both operations to address
			wrReq_ns = ADDR;
			rdReq_drv = 0;		//finished read request
	    end

	    else if(rdReq_st == WAITE && !wrReq_drv) //if in waitstate and write request not being processed
	    begin
			rdReq_ns = ADDR;	//set read state to address
			rdReq_drv = 0;
	    end

	    //write
	    if(wrReq_st == ADDR)	//write 
	    begin
		
			if(S.AddrValid && !S.rw && S.AddrData[15:12] == PAGE)	//if valid address and write operation and page is current page
			begin
		   	 	baseAddress = S.AddrData[11:0];	//get base address
		    	wrReq_ns = DATA0;	//set next state
		    	A.Addr = 'bz;
		   		A.DataIn = 'bz;	//data write signal not being driven
		   	 	A.rdEn = 1'b0;
		   	 	A.wrEn = 1'b1;	//write signal
		   	 	rdReq_drv = 1'b0;
		   	 	wrReq_drv = 1'b1;	//write being processed

		    	rdReq_ns = WAITE;	//set read to wait
			end

	    end

	    else if(wrReq_st == DATA0) //if writing first chunk
	    begin
			A.Addr = baseAddress; //write to base address
			A.DataIn = S.AddrData;	//data to write

			A.rdEn = 1'b0;
			A.wrEn = 1'b1;

			wrReq_ns = DATA1;	//set next state
	    end

	    else if(wrReq_st == DATA1)	//writing 2nd second
	    begin
			A.Addr = baseAddress + 1;	//write to base + 1
			A.DataIn = S.AddrData;	//data to write

			A.rdEn = 1'b0;
			A.wrEn = 1'b1;

			wrReq_ns = DATA2;	//update state
	    end

	    else if(wrReq_st == DATA2) //writing 3rd chunk
	    begin
			A.Addr = baseAddress + 2;	//write to base + 2
			A.DataIn = S.AddrData;	//data to write

			A.rdEn = 1'b0;
			A.wrEn = 1'b1;

			wrReq_ns = DATA3;	//set next state
	    end

	    else if(wrReq_st == DATA3)	//writing last chunk
	    begin
			A.Addr = baseAddress + 3;	//write to base + 3
			A.DataIn = S.AddrData;	//data to write

			A.rdEn = 1'b0;
			A.wrEn = 1'b1;

			rdReq_ns = ADDR;	//set next states 
			wrReq_ns = ADDR;
			wrReq_drv = 0;	//wrtie request completed
	    end

	    else if(wrReq_st == WAITE && !rdReq_drv) //if write in waite and read request not beign processed
	    begin
			wrReq_ns = ADDR;
			wrReq_drv = 0;
	    end
	    
	end:readBlock

	always_comb
	begin

	    if(rdReq_st == DATA0 || rdReq_st == DATA1 || rdReq_st == DATA2 || rdReq_st == DATA3) //if reading data
			d = A.DataOut;
		
		else
			d = 16'bz;
	end
	assign S.AddrData = d;	//drive inout port of main bus

endinterface:memory_if
		
