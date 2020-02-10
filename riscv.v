module riscv #(parameter bits = 64, addr_width_IMEM = 8, addr_width_DMEM = 5, no_of_registers = 32)
	(
		input CLOCK_50,
		input [7:0]SW, 
		input [3:2]KEY, 
		output [7:0]LEDR,
		output [6:0] HEX3, HEX2, HEX1, HEX0
	);


	wire [(bits - 1):0]disp_DMEM, disp_RegFile;
	wire [(addr_width_DMEM - 1):0] test_addr = SW[(addr_width_DMEM - 1):0];
	wire clk = CLOCK_50;//~KEY[3];
	wire async_reset = ~KEY[2];
	reg [15:0]disp_hex; 
	wire [31:0]inst, if_id_out, inst_temp;
	wire [(addr_width_IMEM - 1):0]PCadder, PCsel_out, addr_wire, branch_out, addr_wire_temp1, addr_wire_temp2, PCadder_WB_temp, PCadder_WB;
	wire [(bits - 1):0]alu_out, reg_rs1, reg_rs2, imm_out, Bsel_out, DMEM_out, write_back, Asel_out, alu_out_temp, reg_rs2_DMEM, write_back_temp;
	wire [($clog2(no_of_registers) - 1):0] rs1, rs2, rd, rd_temp1, rd_temp2, rd_temp3, rd_temp1x;	
	wire [24:0]imm_in, imm_in_temp;
	wire [18:0]cont_wordD, cont_wordZ;
	wire [17:0]cont_wordE, cont_wordY;
	wire [6:0]cont_wordM;
	wire cont_word_reg_en_temp1, cont_word_reg_en_temp2, cont_word_reg_en_temp3, cont_word_reg_en_temp1x;
	wire from_AND, AND_Branch;
	wire [9:0]if_id_out_temp1, if_id_out_temp2;
	wire [(addr_width_IMEM - 1):0]branch_out_temp;
	wire rs1_sel, rs2_sel, rs2_sel_nex, rs1_sel_nex, rs1_sel_nex_nex, rs2_sel_nex_nex, clk_stall;
	wire [(bits - 1):0]reg_rs1_temp1, reg_rs1_temp2, reg_rs2_temp1, reg_rs2_temp2, reg_rs1_temp3, reg_rs2_temp3, reg_rs1_temp4, reg_rs2_temp4;
	wire branch_kill, jump_kill;


	assign LEDR = SW;	

	mux_nto1_nbits #(addr_width_IMEM, 2) PCSel
	(
		.x({{(addr_width_IMEM){1'b0}}, alu_out_temp[(addr_width_IMEM - 1):0], branch_out, PCadder}), 
		.sel({cont_wordE[13], from_AND}), 
		.m(PCsel_out)
	);

	Counter #(addr_width_IMEM) COUNTER
	(
		.d(PCsel_out), 
		.clk(clk), 
		.async_reset(async_reset),
		.en(clk_stall), 
		.q(addr_wire)
	);
	
	assign PCadder = addr_wire + 3'd4;
	
	IMEM #(32, addr_width_IMEM, no_of_registers) rom
	(
		.addr(addr_wire), 
		.clk(~clk), 
		.inst_out(inst_temp)		
	);

	mux_nto1_nbits #(32, 2) IMEM_mux_IF_ID
	(
		.x({{(96){1'b0}}, inst_temp}), 
		.sel({jump_kill, branch_kill}), 
		.m(inst)
	);
		
	IF_ID #(addr_width_IMEM) IF_ID_Pipe
	(
		.clk(clk),
		.async_reset(async_reset),
		.en(clk_stall),
		.inst(inst),
		.addr_wire(addr_wire),
		.if_id_out(if_id_out),
		.addr_wire_temp1(addr_wire_temp1)
	);

	Hazard_Detection #(no_of_registers)HAZARD_DETECTION
	(
		.rd_pre(rd_temp1x),
		.rs1_nex(rs1),
		.rs2_nex(rs2),
		.from_IMEM_ID_EX(if_id_out_temp1[6:0]),
		.from_IMEM_EX_MEM(if_id_out_temp2[6:0]),
		.from_assertion(AND_Branch),
		.clk_stall(clk_stall),
		.branch_kill(branch_kill),
		.jump_kill(jump_kill)
	);

	assign rs1 = if_id_out[19:15];
	assign rs2 = if_id_out[24:20];
	assign rd_temp1x = if_id_out[11:7];
	assign imm_in_temp = if_id_out[31:7];


//////////////////////////////////////////////
	mux_nto1_nbits #(5, 1) rd_Sel
	(
		.x({rd_temp1x, {(5){1'b0}}}),
		.sel(clk_stall),
		.m(rd_temp1)
	);		
//////////////////////////////////////////////	

	Control CONTROL
	(
		.x({if_id_out[31:25], if_id_out[14:12], if_id_out[6:0]}), 
		.y(cont_wordZ)
	);

	mux_nto1_nbits #(19, 3) Control_mux_ID_EX
	(
		.x({{(114){1'b0}}, cont_wordZ, {(19){1'b0}}}), 
		.sel({jump_kill, branch_kill, clk_stall}), 
		.m(cont_wordD)
	);	

	RegFile #(bits, no_of_registers, addr_width_DMEM) REGFILE
	(
		.in_reg1(rs1), 
		.in_reg2(rs2), 
		.write_en(rd), 
		.disp_sel(SW[4:0]), 
		.write_data(write_back),
		.clk(clk), 
		.async_reset(async_reset), 
		.reg_en(cont_word_reg_en_temp3), 
		.out_reg1(reg_rs1_temp1), 
		.out_reg2(reg_rs2_temp1), 
		.disp(disp_RegFile)
	);

	mux_nto1_nbits #(bits, 1) RS1_SEL_MEM_WB
	(
		.x({write_back, reg_rs1_temp1}),
		.sel(rs1_sel_nex_nex),
		.m(reg_rs1_temp2)
	);

	mux_nto1_nbits #(bits, 1) RS1_SEL_EX_MEM
	(
		.x({write_back_temp, reg_rs1_temp2}),
		.sel(rs1_sel_nex),
		.m(reg_rs1_temp3)
	);

	mux_nto1_nbits #(bits, 1) RS1_SEL_ID_EX
	(
		.x({alu_out_temp, reg_rs1_temp3}),
		.sel(rs1_sel),
		.m(reg_rs1_temp4)
	);

	mux_nto1_nbits #(bits, 1) RS2_SEL_MEM_WB
	(
		.x({write_back, reg_rs2_temp1}),
		.sel(rs2_sel_nex_nex),
		.m(reg_rs2_temp2)
	);

	mux_nto1_nbits #(bits, 1) RS2_SEL_EX_MEM
	(
		.x({write_back_temp, reg_rs2_temp2}),
		.sel(rs2_sel_nex),
		.m(reg_rs2_temp3)
	);

	mux_nto1_nbits #(bits, 1) RS2_SEL_ID_EX
	(
		.x({alu_out_temp, reg_rs2_temp3}),
		.sel(rs2_sel),
		.m(reg_rs2_temp4)
	);

	ID_EX #(bits , addr_width_IMEM) ID_EX_Pipe
	(
		.clk(clk),
		.async_reset(async_reset),
		.rd_temp1(rd_temp1),
		.cont_wordA(cont_wordD[10]),
		.addr_wire_temp1(addr_wire_temp1),
		.reg_rs1_temp(reg_rs1_temp4),
		.reg_rs2_temp(reg_rs2_temp4),
		.imm_in_temp(imm_in_temp),
		.if_id_out({if_id_out[14:12], if_id_out[6:0]}),
		.cont_wordB({cont_wordD[18:11], cont_wordD[9:0]}),
		.rd_temp2(rd_temp2),
		.cont_word_reg_en_temp1(cont_word_reg_en_temp1x),
		.addr_wire_temp2(addr_wire_temp2),
		.reg_rs1(reg_rs1),
		.reg_rs2(reg_rs2),
		.imm_in(imm_in),
		.if_id_out_temp1(if_id_out_temp1),
		.cont_wordC(cont_wordY)
	);


	mux_nto1_nbits #(19, 1) Control_mux_EX_MEM
	(
		.x({{(19){1'b0}}, {cont_word_reg_en_temp1x, cont_wordY}}), 
		.sel(branch_kill), 
		.m({cont_word_reg_en_temp1, cont_wordE})
	);

	Forwarding #(no_of_registers) FORWARDING
	(
		.rd_pre(rd_temp2),
		.rd_pre_pre(rd_temp3),
		.rd_pre_pre_pre(rd),
		.rs1_next(rs1),
		.rs2_next(rs2),
		.rd_next(rd_temp1),
		.from_IMEM(if_id_out[6:0]),
		.signal_rs1(rs1_sel),
		.signal_rs2(rs2_sel),
		.signal_rs1_nex(rs1_sel_nex),
		.signal_rs2_nex(rs2_sel_nex),
		.signal_rs1_nex_nex(rs1_sel_nex_nex),
		.signal_rs2_nex_nex(rs2_sel_nex_nex)
	);

	mux_nto1_nbits #(bits, 1) ASel
	(
		.x({{{(bits - addr_width_IMEM){1'b0}}, addr_wire_temp2}, reg_rs1}), 
		.sel(cont_wordE[8]), 
		.m(Asel_out)
	);

	mux_nto1_nbits #(bits, 1) BSel
	(
		.x({imm_out, reg_rs2}), 
		.sel(cont_wordE[9]), 
		.m(Bsel_out)
	);		

	ImmGen #(bits, 3) IMMGEN
	(
		.in_imm(imm_in), 
		.sel_in(cont_wordE[12:10]), 
		.out_imm(imm_out)
	);

	alu #(bits) ALU
	(
		.x(Asel_out), 
		.y(Bsel_out), 
		.s(cont_wordE[7:3]), 
		.z(alu_out_temp)
	);

	Branches #(bits, addr_width_IMEM) BRANCHES
	(
		.from_PC(addr_wire_temp2), 
		.from_imm(imm_out[(addr_width_IMEM - 1):0]), 
		.to_PCsel(branch_out_temp)
	);

	EX_MEM #(bits, addr_width_IMEM) EX_MEM_Pipe
	(
		.clk(clk),
		.async_reset(async_reset),
		.rd_temp2(rd_temp2),
		.cont_word_reg_en_temp1(cont_word_reg_en_temp1),
		.addr_wire_temp2(addr_wire_temp2),
		.alu_out_temp(alu_out_temp),
		.reg_rs2(reg_rs2),
		.branch_out_temp(branch_out_temp),
		.if_id_out_temp1(if_id_out_temp1),
		.cont_wordF({cont_wordE[17:14], cont_wordE[2:0]}),
		.rd_temp3(rd_temp3),
		.cont_word_reg_en_temp2(cont_word_reg_en_temp2),
		.PCadder_WB_temp(PCadder_WB_temp),
		.alu_out(alu_out),
		.reg_rs2_DMEM(reg_rs2_DMEM),
		.branch_out(branch_out),
		.if_id_out_temp2(if_id_out_temp2),
		.cont_wordG(cont_wordM)
	);
	
	assign PCadder_WB = PCadder_WB_temp + 4'd4;
		
	Assertion #(bits) ASSERTION
	(
		.from_IMEM(if_id_out_temp2), 
		.from_alu(alu_out), 
		.to_and_gate(AND_Branch)
	);

	assign from_AND = AND_Branch & cont_wordM[6];

	DMEM #(bits, addr_width_DMEM) RAMBO
	(
		.control(cont_wordM[5:3]), 
		.data(reg_rs2_DMEM), 
		.addrress_sig(alu_out[(addr_width_DMEM - 1):0]), 
		.test_addr(test_addr), 
		.we(cont_wordM[2]), 
		.clk(clk), 
		.async_reset(async_reset), 
		._q(DMEM_out), 
		.test_out(disp_DMEM)
	);

	mux_nto1_nbits #(bits, 2) WBSel
	(
		.x({{(bits){1'b0}}, {{(bits - addr_width_IMEM){1'b0}}, PCadder_WB}, alu_out, DMEM_out}), 
		.sel(cont_wordM[1:0]), 
		.m(write_back_temp)
	);

	MEM_WB #(bits) MEM_WB_Pipe
	(
		.clk(clk),
		.async_reset(async_reset),
		.rd_temp3(rd_temp3),
		.cont_word_reg_en_temp2(cont_word_reg_en_temp2),
		.write_back_temp(write_back_temp),
		.rd(rd),
		.cont_word_reg_en_temp3(cont_word_reg_en_temp3),
		.write_back(write_back)
	);

	always @(SW[7:5], disp_RegFile, disp_DMEM)
	begin: DISPLAY
		case(SW[7:5])
			0: disp_hex = disp_RegFile[15:0];
			1: disp_hex = disp_RegFile[31:16];
			2: disp_hex = disp_RegFile[47:32];
			3: disp_hex = disp_RegFile[63:48];
			4: disp_hex = disp_DMEM[15:0];
			5: disp_hex = disp_DMEM[31:16];
			6: disp_hex = disp_DMEM[47:32];
			7: disp_hex = disp_DMEM[63:48];
			default: disp_hex = 0;
		endcase
	end

	char7seg_4bit C0
	(
		.x(disp_hex[3:0]), 
		.y(HEX0)
	);
	char7seg_4bit C1
	(
		.x(disp_hex[7:4]), 
		.y(HEX1)
	);
	char7seg_4bit C2
	(
		.x(disp_hex[11:8]), 
		.y(HEX2)
	);
	char7seg_4bit C3
	(
		.x(disp_hex[15:12]), 
		.y(HEX3)
	);

endmodule 


module tb;
	wire file_id;
	reg [1:0]key;
	reg [7:0]sw;
	wire [7:0]ledr;
	wire [6:0]hex0, hex1, hex2, hex3;
	
	assign 	file_id = $fopen("D:\\Work\\Projects\\riscvBareMetal\\IMEM.mif","r");

	initial begin:CLOCK
		key[1] = 1'b1;
		repeat(1000) #100 key[1] = ~key[1];    
	end

	riscv yp(sw, key, ledr, hex3, hex2, hex1, hex0);

	initial begin:TESTBENCH
		key[0] = 1'b1; 
		sw[7:5] = 'b100; sw[4:0] = 'd12; #100;

	end
endmodule

module char7seg_4bit
	(
		input [3:0]x, 
		output reg [6:0]y
	);
	always @(*)
	case (x) 
		4'b0000: y = 7'b100_0000;
		4'b0001: y = 7'b111_1001;
		4'b0010: y = 7'b010_0100;
		4'b0011: y = 7'b011_0000;
		4'b0100: y = 7'b001_1001;
		4'b0101: y = 7'b001_0010;
		4'b0110: y = 7'b000_0010;
		4'b0111: y = 7'b111_1000;
		4'b1000: y = 7'b000_0000;
		4'b1001: y = 7'b001_1000;
		4'b1010: y = 7'b000_1000;
		4'b1011: y = 7'b000_0011;
		4'b1100: y = 7'b100_0110;
		4'b1101: y = 7'b010_0001;
		4'b1110: y = 7'b000_0110;
		4'b1111: y = 7'b000_1110;
		default: begin 
			y = 7'b0;
		end
	endcase
endmodule

