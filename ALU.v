module alu #(parameter bits)
	(
		input [(bits - 1):0]x, y, 
		input [4:0]s, 
		output reg [(bits - 1):0]z
	);
	always @(*)
	case(s)
		0: z = $signed(x) + $signed(y);
		1: z = x & y;
		2: z = x | y;
		3: z = x ^ y;
		4: z = x >> y;
		5: z = $signed(x) >>> y;
		6: z = x << y;
		7: z = (x < y) ? {{(bits - 1){1'b0}}, 1'b1} : {{(bits - 1){1'b0}}, 1'b0};
		//8: z = $signed(x) / $signed(y);
		//9: z = $signed(x) % $signed(y);
		10: z = $signed(x) * $signed(y);
		11: z = ($signed(x) * $signed(y)) >> bits;
		12: z = $signed(x) - $signed(y);
		13: z = ($unsigned(x) < $unsigned(y)) ? {{(bits - 1){1'b0}}, 1'b1} : {{(bits - 1){1'b0}}, 1'b0};
		14: z = y;

		/////////////////////////////////////////start
		15: z = $signed(x[(bits - 32) - 1:0]) + $signed(y[(bits - 32) - 1:0]);
		16: z = $signed(x[(bits - 32) - 1:0]) - $signed(y[(bits - 32) - 1:0]);
		17: z = x[(bits - 32) - 1:0] << y[(bits - 32) - 1:0];
		18: z = x[(bits - 32) - 1:0] >> y[(bits - 32) - 1:0];
		19: z = $signed(x[(bits - 32) - 1:0]) >>> y[(bits - 32) - 1:0];
		/////////////////////////////////////////end

		20: z = ($unsigned(x) * $unsigned(y)) >> bits;
		21: z = ($signed(x) * $unsigned(y)) >> bits;
		//22: z = $unsigned(x) / $unsigned(y);
		//23: z = $unsigned(x) % $unsigned(y);
		default: z = 0;		 
	endcase

endmodule 

