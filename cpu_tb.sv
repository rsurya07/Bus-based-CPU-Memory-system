/*************************************************
cpu_tb.sv - module that tests the whole system

Name: Surya Ravikumar
Date: 2/24/2019

Description:  This module tests the CPU, Memory system
			  by writing and reading data using the tasks defined
			  in processor_if. 
			  
*****************************************************/

module cpu_tb
(
	main_bus_if.master 	MB,
	processor_if.SndRcv	PROC
);


	logic [3:0][63:0] data;	//array to store data
	logic [63:0] d_read;	//variable to hold data that is being read
	logic [3:0] page;		//page parameter
	logic [11:0] baseAddr;	//base address where data needs to be written or read from
	int i = 0;				//variable to co-ordinate read and write
	int j = 0;				//variable to co-ordinate read and write
	bit rw = 0;				//read = 1 write = 0 - read write flag

	initial
	begin
	
	    baseAddr = 12'b0;	//0th address
	    page = 4'h2;		//page 2
	    data[0] = 64'h6cce35d5efa8f8f4;	//64 bit data
	    data[1] = 64'h58b13c958c9c02a3;
	    data[2] = 64'hd3bb8079325d8f74;
	    data[3] = 64'hcf7bb5e06d74e4ad;

	end

	always_ff @(posedge MB.clk iff MB.resetH == 0)	//on posedge of clock if reset low
	begin

	    if(j == 0 && !rw) 
	    begin	//write data
	        PROC.Proc_wrReq(page, baseAddr+4*i, data[i++]);	//write data using task
	    end

	    else if (j == 0 && rw)	//read data
	    begin
			PROC.Proc_rdReq(page, baseAddr+4*i++, d_read);	//read data using task
	    end
	end

	always_ff @(posedge MB.clk or  posedge MB.resetH)	//update controls
	begin

	    if(M.resetH || (j == 7 && i < 4))
			j <= 0 ;	//data read or write when j == 0
	
	    else if(j == 7 && i == 4 && !rw) //if all 4 locations are written
	    begin
			i <= 0;	//reset parameters
			rw <= 1;
			j <= 0;
	    end
	
	    else if(j == 7 && i == 4 && rw) //if all 4 location read
			$stop;	//then test over -  write data first then read

	    else
			j <= j + 1;	//wait till data is processed
	end

	always_ff @(negedge MB.clk iff MB.resetH == 0)
	begin
	    if(!rw && j == 1)	//display statement for write
			$display("\nWrote %h to page %h address %h \n", data[i-1], page, baseAddr+4*(i-1));

	     else if(rw && j == 7)	//display statement for read
		 	$display("\nRead %h from page %h address %h   Expected %h\n", d_read, page, baseAddr+4*(i-1), data[i-1]);
	end


endmodule:cpu_tb
