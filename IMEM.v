
module IMEM #(parameter bits, addr_width, no_of_reg)
	(
		input [(addr_width - 1):0]addr, 
		input clk, 
		output [(bits-1):0]inst_out 
		
	);

	wire [(addr_width - 1):0]addr_sig;	
	assign addr_sig = addr >> 2;

	/////////////////////////////////////////start for manual making of rom
	// reg [(bits - 1):0] rom[((2**addr_width) - 1):0];
	// initial
	// begin
	//  	$readmemh("D:\\Work\\Internship\\RISCV_Pipelined_test\\IMEM.txt", rom);
	// end
	// assign inst_out = rom[addr_sig];
	/////////////////////////////////////////end for manual making of rom



	/////////////////////////////////////////start for in-built rom
	wire [(bits - 1):0]q_sig;
	rom_one_port rom_one_port_inst
	(
		.address(addr_sig), 
		.clock(clk), 
		.q(q_sig)
	);

	assign inst_out = q_sig;
	/////////////////////////////////////////end for in-built rom

	

endmodule 


