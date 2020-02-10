module Assertion #(parameter bits)
	(
		input [9:0]from_IMEM, 
		input [(bits - 1):0]from_alu, 
		output reg to_and_gate
	);
	always @(*)
	begin
		if (from_IMEM == 'h63)
		begin
			if (from_alu == 0)
				to_and_gate = 1;
			else 
				to_and_gate = 0;
		end
		else if (from_IMEM == 'hE3)
		begin
			if (from_alu == 0)
				to_and_gate = 0;
			else to_and_gate = 1;
		end
		else if (from_IMEM == 'h263)
		begin
			if (from_alu == 0)
				to_and_gate = 0;
			else 
				to_and_gate = 1;
		end
		else if (from_IMEM == 'h2E3)
		begin
			if (from_alu == 0)
				to_and_gate = 1;
			else 
				to_and_gate = 0;
		end
		else if (from_IMEM == 'h363)
		begin
			if (from_alu == 0)
				to_and_gate = 0;
			else 
				to_and_gate = 1;
		end
		else if (from_IMEM == 'h2E3)
		begin
			if (from_alu == 0)
				to_and_gate = 1;
			else 
				to_and_gate = 1;
		end
		else to_and_gate = 0;
	end
endmodule