module Branches#(parameter bits, addr_width)
	(
		input [(addr_width - 1):0]from_PC,
		input [(addr_width - 1):0]from_imm, 
		output [(addr_width - 1):0]to_PCsel
	);
	
	assign to_PCsel = from_imm + from_PC;

endmodule 
