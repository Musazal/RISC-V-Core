module Hazard_Detection #(parameter no_of_registers)
	(
		input [($clog2(no_of_registers) - 1):0]rd_pre, rs1_nex, rs2_nex,
		input [6:0]from_IMEM_ID_EX, from_IMEM_EX_MEM,
		input from_assertion,
		output reg clk_stall, branch_kill, jump_kill
	);

	always @(from_IMEM_ID_EX, from_IMEM_EX_MEM, rd_pre, rs1_nex, rs2_nex, from_assertion)
	begin
		if (from_IMEM_ID_EX == 'b0000011 && (rd_pre == rs1_nex || rd_pre == rs2_nex))
			clk_stall = 0;
		else 
			clk_stall = 1;

		if(from_IMEM_EX_MEM == 'b1100011 && from_assertion == 1)  
			branch_kill = 1;
		else 
			branch_kill = 0;

		if (from_IMEM_ID_EX == 'b1101111 || from_IMEM_ID_EX == 'b1100111)
			jump_kill = 1;
		else
			jump_kill = 0;
	end

endmodule