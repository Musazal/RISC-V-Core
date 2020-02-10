module Jump_Hazard
	(
		input [6:0]from_IMEM,
		output reg signal
	);
	
	always @(from_IMEM)
	begin
		if (from_IMEM == 'b1101111 || from_IMEM == 'b1100111)
			signal = 1;
		else
			signal = 0;
	end
endmodule