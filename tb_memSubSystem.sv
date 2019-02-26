/********************************************************
tb_memSubSystem - testbench to test memory sub system

Name: Surya Ravikumar
Date: 2/24/2019

Description:	Testbench that uses the main bus to read and write data to memory.
				First performs 2 consecutives writes and 2 consecutives reads 
				from the same location.
				Then performs 2 single write and read operations.
***********************************************************/ 
import mcDefs::*;

module tb_memSubSystem
(
	input clk, resetH, rw,
	input [11:0] dd,
	main_bus_if.master 	M		// interface to processor is a master
);
	typedef enum {ADDR, WAITE, DATA0, DATA1, DATA2, DATA3} state_t; //states
	logic [15:0] [15:0] data ;	//hold data
	int i, j;
	state_t s, ns;	//current and next state
	logic [15:0] d;
	bit rdReq, wrReq;	//read or write process

	initial
	begin
	
	    data[0] = 16'hf671;		//initialize data
	    data[1] = 16'h1234;
	    data[2] = 16'h5678;
	    data[3] = 16'h9abc;
	    
	    data[4] = 16'h4314;
	    data[5] = 16'h5641;
	    data[6] = 16'hf4f4;
 	    data[7] = 16'h7791;

	    data[8] = 16'h0071;
	    data[9] = 16'h0034;
	    data[10] = 16'h0078;
	    data[11] = 16'h00bc;
	    
	    data[12] = 16'h0014;
	    data[13] = 16'h0041;
	    data[14] = 16'h00f4;
 	    data[15] = 16'h0091;
	        
	    

	    i = 0;
	end

	always_ff @(posedge clk or posedge resetH)
	begin
	   
	    if(M.resetH)	//if reset
	    begin
			s <= ADDR;	//reset all
			rdReq <= 0;
			wrReq <= 0;
	    end
		
	    else
	    begin
			s <= ns;	//update state
			rdReq <= 1;	//can perform read or write
			wrReq <= 1;
	    end

	end
	
	always_comb
	begin
	  //write
	    if(s == ADDR && !rw && wrReq) //
	    begin
			d = {4'b0010, dd}; //set address
			M.AddrValid = 1'b1;	//set address valid
			M.rw = 1'b0;	//write is active low

			ns = DATA0;
			$display("\nWriting...\n");
	    end

	    else if(s == DATA0 && !rw && wrReq) //send first chunk of data
	    begin
			d = data[dd];	//get data to write
			M.AddrValid = 1'b0;
			M.rw = 1'b0;
		
			ns = DATA1;
	    end

	    else if(s == DATA1 && !rw && wrReq)  //2nd chunk
	    begin
			d = data[dd]; //get data to write
			M.AddrValid = 1'b0;
			M.rw = 1'b0;

			ns = DATA2;
	    end

	    else if(s == DATA2 && !rw && wrReq) //3rd chunk
	    begin
			d = data[dd];
			M.AddrValid = 1'b0;
			M.rw = 1'b0;

			ns = DATA3;
	    end

	    else if(s == DATA3 && !rw && wrReq) //4th chunk
	    begin
			d = data[dd];
			M.AddrValid = 1'b0;
			M.rw = 1'b0;

			ns = ADDR;
	    end

	    //read
	    else if(s == ADDR && rw && rdReq) //read
	    begin
			d = {4'b0010, dd};	//set address to read from
			M.AddrValid = 1'b1;	//address valid
			M.rw = 1'b1;	//read active high

			ns = DATA0;
			$display("\nReading...\n");
	    end

	    else if(s == DATA0 && rw && rdReq) //first chunk
	    begin
			d = 'bz;
			M.AddrValid = 1'b0;
			M.rw = 1'b0;
		
			ns = DATA1;

	    end

	    else if(s == DATA1 && rw && rdReq)  //2nd chunk
	    begin

			d = 'bz;
			M.AddrValid = 1'b0;
			M.rw = 1'b0;

			ns = DATA2;
	    end

	    else if(s == DATA2 && rw && rdReq)  //3rd chunk
	    begin

			d = 'bz;
			M.AddrValid = 1'b0;
			M.rw = 1'b0;

			ns = DATA3;
	    end

	    else if(s == DATA3 && rw && rdReq) //4th chunk
	    begin

			d = 'bz;
			M.AddrValid = 1'b0;
			M.rw = 1'b0;

			ns = ADDR;
	    end

	    

	end
	
	assign M.AddrData = d; //drive inout port of main bus

	always_ff @(negedge clk iff resetH == 0) //display messages
	begin 
	
	    if(!rw && (s != ADDR && s != WAITE))  //write message
	    begin
			$display("Writing %h to page %h address %h", data[dd], 4'b0010, dd);
	    end

	    else if(rw && (s != ADDR && s != WAITE)) //read message
	    begin
			$display("Read %h from page %h address %h    Expecting %h", M.AddrData, 4'b0010, dd, data[dd]);
	    end
	end

endmodule:tb_memSubSystem
