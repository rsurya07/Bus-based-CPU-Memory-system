/************************************************
memArray_if.sv - interface between memory_if and mem

Name: Surya Ravikumar
Date: 2/24/2019

Description: Define signals between memory_if and mem
***************************************************/

interface memArray_if();

	logic [11:0] Addr;
	logic [15:0] DataIn;
	logic [15:0] DataOut;
	logic rdEn;
	logic wrEn;

	modport MemIF (
		input  Addr,
		input  DataIn,
		output DataOut,
		input  rdEn,
		input  wrEn
		);
	
endinterface:memArray_if
