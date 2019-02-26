/************************************
top_memSubSytem - top level module to instantiate and test memory sub system

Name: Surya Ravikumar
Data: 2/24/2019

Description:	Top level module that instantiates and tests memory subsystem.
				This module sends read or write signals, and base address to the test, and works
				with the testbench to perform 2 consecutive write and reads,
				and 2 single write and read operation to test the working
				of memory_if and memArray_if bus.
******************************************/
import mcDefs::*;

module top_memSubSystem;

// internal variables
bit clk, resetH;
bit rw; //read write signal read = 1 write = 0
logic [11:0] dd;	//address variable
int i, j;

// instantiate the interfaces
main_bus_if M(.*);
memArray_if MEMORY();

tb_memSubSystem P
(
	clk, 
	resetH, 
	rw,
	dd,
	M.master
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

initial begin: clockGenerator
	resetH = 1;
	clk = 0;
	i = 0;
	j = 0;
	rw = 0;
	#2;
	dd = 0;	//write starting from address
	resetH = 0;

	for(j = 0; j < 10; j++) // 2 consecutive writes
	begin
	 	rw = 0;
		clk = 1;
		#2;
		clk = 0;
		#2;

		if(j != 0 && j !=5)
		   dd = dd+1;	//increment address except iteration 0 and 5 when the module will be in address phase
		   				//test bench module contains data to be written
	end

	dd = 0; //read starting from address

	for(j = 0; j < 10; j++) //2 consecutive reads
	begin
		
		clk = 1;
		rw = 1;
		#2;
		clk = 0;
		#2;
		
		if(j != 0 && j != 5)
		   dd = dd+1;	//increment address except iteration 0 and 5 when the module will be in address phase
		   				//test bench module contains data to be written

	end

	dd = 8;	//write starting from address

	for(j = 0; j < 5; j++)	//single write
	begin

	    rw = 0;
	    clk = 1;
	    #2;

	    clk = 0;
	    #2;

	    if(j != 0) //0 is address phase
	    	dd = dd+1;
	end

	dd = 8; //read from address

	for(j = 0; j < 5; j++)	//single read
	begin

	    rw = 1;
	    clk = 1;
	    #2;

	    clk = 0;
	    #2;

	    if(j != 0)	//0 is address phase
	    	dd = dd+1;
	end 

	dd = 12;	//write starting from address

	for(j = 0; j < 5; j++)	//single write
	begin

	    rw = 0;
	    clk = 1;
	    #2;

	    clk = 0;
	    #2;

	    if(j != 0)	//0 is address phase
	    	dd = dd+1;
	end

	dd = 12;	//read from address

	for(j = 0; j < 5; j++)
	begin

	    rw = 1;
	    clk = 1;
	    #2;

	    clk = 0;
	    #2;

	    if(j != 0)	//0 is address phase
	    	dd = dd+1;
	end 

		

end:clockGenerator

endmodule: top_memSubSystem
