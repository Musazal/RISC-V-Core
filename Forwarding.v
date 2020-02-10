module Forwarding #(parameter no_of_registers)
	(
		input [($clog2(no_of_registers) - 1):0]rd_pre, rd_pre_pre, rd_pre_pre_pre, rs1_next, rs2_next, rd_next,
		input [6:0]from_IMEM,
		output reg signal_rs1, signal_rs2, signal_rs1_nex, signal_rs2_nex, signal_rs1_nex_nex, signal_rs2_nex_nex
	);
	reg mux_signal;
	wire [($clog2(no_of_registers) - 1):0]choice;


	always @(*)
	begin
		if (from_IMEM == 'b0100011)
		begin
			mux_signal = 1;
		end
		else 
			mux_signal = 0;
	end

		mux_nto1_nbits #(5, 1) SW_or_others
		(
			.x({{(5){1'b1}}, rd_next}), 
			.sel(mux_signal), 
			.m(choice)
		);

	always @(choice, rs1_next, rs2_next, rd_pre, rd_pre_pre, rd_pre_pre_pre)
	begin		
		if (choice != 0)
		begin
			if (rd_pre == rs1_next && rs1_next != 0)
				signal_rs1 = 1;
			else
				signal_rs1 = 0;			
			if (rd_pre == rs2_next && rs2_next != 0)
				signal_rs2  = 1;
			else
				signal_rs2 = 0;
			//////////////////////////////////////////////////////
			if (rd_pre_pre == rs1_next && rs1_next != 0)
				signal_rs1_nex = 1;
			else 
				signal_rs1_nex = 0;			
			if (rd_pre_pre == rs2_next && rs2_next != 0)
				signal_rs2_nex = 1;
			else 
				signal_rs2_nex = 0;
			//////////////////////////////////////////////////////
			if (rd_pre_pre_pre == rs1_next && rs1_next != 0)
				signal_rs1_nex_nex = 1;
			else 
				signal_rs1_nex_nex = 0;

			if (rd_pre_pre_pre == rs2_next && rs2_next != 0)
				signal_rs2_nex_nex = 1;
			else 
				signal_rs2_nex_nex = 0;
		end
		else 
		begin
			signal_rs1 = 0;
			signal_rs2 = 0;
			signal_rs1_nex = 0;
			signal_rs2_nex = 0;
			signal_rs1_nex_nex = 0;
			signal_rs2_nex_nex = 0;
		end
	end

endmodule