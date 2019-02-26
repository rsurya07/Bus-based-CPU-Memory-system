compile:
	vlib work
	vlog mcDefs.sv
	vlog *.sv

mem:
	vsim -c top_memSubSystem -do "run -all; quit"

cpu:
	vsim -c top -do "run -all; quit"

clean:
	rm -rf work transcript vsim.wlf
