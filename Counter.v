module Counter #(parameter addr_width)
	(
		input [(addr_width - 1):0]d, 
		input clk, async_reset, en, 
		output reg [(addr_width - 1):0] q = 0 
	);

	always @(posedge clk)
	if (async_reset)
		q <= 0;
	else 
	begin
		q <= en ? d : q; 
	end
	
endmodule