module RegFile #(parameter bits, no_of_registers, addr_width_DMEM)
	(
		input [($clog2(no_of_registers) - 1):0]in_reg1, in_reg2, write_en, disp_sel,
		input [(bits - 1):0]write_data, 
		input clk, async_reset, reg_en, 
		output [(bits - 1):0]out_reg1, out_reg2, disp
	);

	wire [((bits * no_of_registers) - 1):0]wire_for_reg;
	wire [(no_of_registers - 1):0]wire_for_decoder;
	
	decoder_nto2_n #(no_of_registers) DECODER
	(
		.x(write_en), 
		.y(wire_for_decoder)
	);

	generate
		genvar i;
		for (i = 0; i < no_of_registers; i = i + 1)
		begin:Registers
			if (i == 0)
				register_for_reg #(bits) REGISTER
				(
					.d(write_data), 
					.en(wire_for_decoder[i] & 1'b0), 
					.clk(clk), 
					.async_reset(async_reset), 
					.q(wire_for_reg[((bits * (i + 1)) - 1):(i * bits)])
				);
				else if (i == 2)
					register_for_sp #(bits, addr_width_DMEM) REGISTER
				(
				.d(write_data), 
				.en((wire_for_decoder[i] & reg_en)), 
				.clk(clk), 
				.async_reset(async_reset), 
				.q(wire_for_reg[((bits * (i + 1)) - 1):(i * bits)])
				);
			else
				register_for_reg #(bits) REGISTER
				(
				.d(write_data), 
				.en((wire_for_decoder[i] & reg_en)), 
				.clk(clk), 
				.async_reset(async_reset), 
				.q(wire_for_reg[((bits * (i + 1)) - 1):(i * bits)])
				);
		end
	endgenerate

	mux_nto1_nbits #(bits, $clog2(no_of_registers)) MUX1
	(
		.x(wire_for_reg), 
		.sel(in_reg1), 
		.m(out_reg1)
	);
	mux_nto1_nbits #(bits, $clog2(no_of_registers)) MUX2
	(
		.x(wire_for_reg), 
		.sel(in_reg2), 
		.m(out_reg2)
	);

	mux_nto1_nbits #(bits, $clog2(no_of_registers)) MUX3
	(
		.x(wire_for_reg), 
		.sel(disp_sel), 
		.m(disp)
	);

endmodule 

