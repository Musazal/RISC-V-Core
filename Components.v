module register #(parameter bits)
	(
		input [(bits - 1):0]d, 
		input clk, async_reset, 
		output reg [(bits - 1):0]q = 0 
	);

	always @(posedge clk)
	begin 
		if (async_reset)
			q <= 0;
		else 
			q <= d;
	end

endmodule

module register_for_reg #(parameter bits)
	(
		input [(bits - 1):0]d, 
		input en, clk, async_reset, 
		output reg [(bits - 1):0]q = 0
	);

	always @(posedge clk)
	begin 
		if (async_reset)
			q <= 0;
		else 
			q <= en ? d : q;
	end

endmodule

module register_for_sp #(parameter bits, addr_width_DMEM)
	(
		input [(bits - 1):0]d, 
		input en, clk, async_reset, 
		output reg [(bits - 1):0]q = 2**addr_width_DMEM
	);

	always @(posedge clk)
	begin 
		if (async_reset)
			q <= 0;
		else 
			q <= en ? d : q;
	end

endmodule

module mux_nto1_nbits #(parameter bits, select_lines)
	(
		input [((bits * (2**select_lines)) - 1):0]x, 
		input [(select_lines - 1):0]sel, 
		output [(bits - 1):0]m
	);

	assign m = x >> (sel * bits);

endmodule

module decoder_nto2_n #(parameter no_of_registers)
	(
		input [($clog2(no_of_registers) - 1):0]x, 
		output [(no_of_registers - 1):0]y
	);

	assign y = 1'b1 << x;

endmodule

module mux2to1_1bits 
(
	input a,b,
	input sel,
	output z
);
	always @(*)
	begin
		case(sel)
		0:z=a;
		1:z=b;
		default:z=a;
	end
endmodule

module mux2to1_1bits 
(
	input a,b,
	input sel,
	output z
);
	always @(*)
	begin	
		z = b;
		if (sel)
			z = a;
	end
endmodule