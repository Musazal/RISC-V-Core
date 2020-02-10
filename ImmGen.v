module ImmGen #(parameter bits, sel)
	(
		input [31:7]in_imm, 
		input [2:0]sel_in, 
		output [(bits - 1):0]out_imm
	);

	wire [11:0]for_I;
	wire [6:0] for_S2;
	wire [4:0]for_S1;
	wire [19:0]for_U; 
	wire [(bits - 1):0]out_I, out_S, out_SB, out_U, out_UJ;	
	
	assign	for_I = in_imm[31:20];
	assign	out_I = {{(bits - 12){for_I[11]}}, for_I};
	
	assign	for_S1 = in_imm[11:7];
	assign	for_S2 = in_imm[31:25];
	assign	out_S = {{(bits - 12){for_S2[6]}}, {for_S2, for_S1}};
	
	assign	out_SB = {{(bits - 12){for_S2[6]}},{for_S1[0], for_S2[5:0], for_S1[4:1], 1'b0}};

	assign	for_U = in_imm[31:12];
	assign	out_U = {for_U,{(bits - 20){for_U[19]}}};

	assign	out_UJ = {{(bits - 21){in_imm[31]}},{in_imm[31], in_imm[19:12], in_imm[20], in_imm[30:21], 1'b0}};

	mux_nto1_nbits #(bits, sel) M0
	(
		.x({{(bits){1'b0}}, {(bits){1'b0}}, {(bits){1'b0}}, out_UJ, out_U, out_SB, out_S, out_I}), 
		.sel(sel_in), 
		.m(out_imm)
	);
	
endmodule