module IF_ID #(parameter addr_width)
	(
		input clk, async_reset, en,
		input [31:0]inst,
		input [(addr_width - 1):0]addr_wire,
		output [31:0]if_id_out,
		output [(addr_width - 1):0]addr_wire_temp1
	);

	register_for_reg #(32) inst_IF_ID
	(
		.d(inst), 
		.en(en),
		.clk(clk), 
		.async_reset(async_reset),
		.q(if_id_out)
	);

	register_for_reg #(addr_width) PC_IF_ID
	(
		.d(addr_wire),
		.en(en),
		.clk(clk),
		.async_reset(async_reset),
		.q(addr_wire_temp1)
	);

endmodule

module ID_EX #(parameter bits, addr_width)
	( 
		input clk, async_reset,
		input [4:0]rd_temp1,
		input cont_wordA,
		input [(addr_width - 1):0]addr_wire_temp1,
		input [(bits - 1):0]reg_rs1_temp, reg_rs2_temp,
		input [24:0]imm_in_temp,
		input [9:0]if_id_out,
		input [17:0]cont_wordB,
		output [4:0]rd_temp2,
		output cont_word_reg_en_temp1,
		output [(addr_width - 1):0]addr_wire_temp2,
		output [(bits - 1):0]reg_rs1, reg_rs2,
		output [24:0]imm_in,
		output [9:0]if_id_out_temp1,
		output [17:0]cont_wordC
	);
	
	register #(5) rd_ID_EX
	(
		.d(rd_temp1),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(rd_temp2)
	);

	register #(1) reg_en_ID_EX
	(
		.d(cont_wordA),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(cont_word_reg_en_temp1)
	);

	register #(addr_width) PC_ID_EX
	(
		.d(addr_wire_temp1),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(addr_wire_temp2)
	);
		
	register #(bits) reg_rs1_ID_EX
	(
		.d(reg_rs1_temp),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(reg_rs1)
	);

	register #(bits) reg_rs2_ID_EX
	(
		.d(reg_rs2_temp),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(reg_rs2)
	);

	register #(25) imm_in_ID_EX
	(
		.d(imm_in_temp),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(imm_in)
	);

	register #(10) BRANCH_opcode_ID_EX
	(
		.d(if_id_out),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(if_id_out_temp1)
	);

	register #(18) CONT_ID_EX
	(
		.d(cont_wordB),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(cont_wordC)
	);

endmodule


module EX_MEM #(parameter bits, addr_width)
	(
		input clk, async_reset,
		input [4:0]rd_temp2,
		input cont_word_reg_en_temp1, 
		input [(addr_width - 1):0]addr_wire_temp2,
		input [(bits - 1):0]alu_out_temp, reg_rs2,
		input [(addr_width - 1):0]branch_out_temp,
		input [9:0]if_id_out_temp1, 
		input [6:0]cont_wordF,
		output [4:0]rd_temp3,
		output cont_word_reg_en_temp2,
		output [(addr_width - 1):0]PCadder_WB_temp,
		output [(bits - 1):0]alu_out, reg_rs2_DMEM,
		output [(addr_width - 1):0]branch_out,
		output [9:0]if_id_out_temp2,
		output [6:0]cont_wordG
	);
	
	register #(5) rd_EX_MEM
	(
		.d(rd_temp2),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(rd_temp3)
	);

	register #(1) reg_en_EX_MEM
	(
		.d(cont_word_reg_en_temp1),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(cont_word_reg_en_temp2)
	);
	
	register #(addr_width) PC_EX_MEM
	(
		.d(addr_wire_temp2),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(PCadder_WB_temp)
	);

	register #(bits) ALU_EX_M
	(
		.d(alu_out_temp),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(alu_out)
	);

	register #(bits) reg_rs2_EX_M
	(
		.d(reg_rs2),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(reg_rs2_DMEM)
	);

	register #(addr_width) Branch_EX_M
	(
		.d(branch_out_temp),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(branch_out)
	);

	register #(10) BRANCH_opcode_EX_MEM
	(
		.d(if_id_out_temp1),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(if_id_out_temp2)
	);

	register #(7) CONT_EX_M
	(
		.d(cont_wordF),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(cont_wordG)
	);


endmodule


module MEM_WB #(parameter bits)
	(
		input clk, async_reset,
		input [4:0]rd_temp3,
		input cont_word_reg_en_temp2,
		input [(bits - 1):0]write_back_temp,
		output [4:0]rd,
		output cont_word_reg_en_temp3,
		output [(bits - 1):0]write_back
	);
	
	register #(5) rd_MEM_WB
	(
		.d(rd_temp3),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(rd)
	);

	register #(1) reg_en_MEM_WB
	(
		.d(cont_word_reg_en_temp2),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(cont_word_reg_en_temp3)
	);

	register #(bits) WB_MEM_WB
	(
		.d(write_back_temp),
		
		.clk(clk),
		.async_reset(async_reset),
		.q(write_back)
	);	

endmodule