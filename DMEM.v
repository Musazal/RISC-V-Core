module DMEM #(parameter bits, addr_width)
	(
		input [2:0]control, 
		input [(bits - 1):0]data, 
		input [(addr_width - 1):0]addrress_sig, test_addr, 
		input we, clk, async_reset, 
		output reg[(bits - 1):0]_q, 
		output [(bits - 1):0]test_out
		);

	reg [(bits - 1):0] ram[((2**addr_width) - 1):0];

	integer i, j, k, l, m, n, p; 
	initial 
	begin: test
		integer qw;
		for(qw = 0; qw <= ((2**addr_width) - 1); qw = qw + 1)
			ram[qw] = {(bits){1'b0}};
	end


	wire [(addr_width - 1):0]addr;
	wire [(addr_width - 1):0]remainder;

	assign addr = addrress_sig >> 3;
	assign remainder = addrress_sig % {{(addr_width - 4){1'b0}},4'd8};

	always @(posedge clk)
	begin: store_Configure
		if(async_reset)
		begin
			for(i = 0; i < addr_width; i = i + 1)
			ram[i] <= 0;
		end
		else if (we)
		begin
			if (control[1:0] == 0)
			begin: store_Bytes
				for (j = 0; j <= ((bits >> 3) - 1); j = j + 1)
				begin:store_Bytes
					if (remainder == j)
						ram[addr][(j * 8) +: 8] <= data[7:0];
				end
			end
			else if(control[1:0] == 1)
			begin:store_HalfWords
				for (k = 0; k <= ((bits >> 3) - 1); k = k + 1)
				begin
					if (remainder == k)
					begin
						if(k == ((bits >> 3) - 1))
						begin
							ram[addr][(k * 8) +: 8] <= data[7:0];
							ram[addr + 1][7:0] <= data[15:8];
						end
						else 
							ram[addr][(k * 8) +: 16] <= data[15:0];
					end			
				end
			end
			else if(control[1:0] == 2)
			begin: store_Words
				for (l = 0; l <= ((bits >> 3) - 1); l = l + 1)
				begin
					if(remainder == l) 
					begin
						if(l == ((bits >> 3) - 3))
						begin
							ram[addr][(l * 8) +: 24] <= data[23:0];
							ram[addr + 1][7:0] <= data[31:24];
						end
						else if (l == ((bits >> 3) - 2))
						begin
							ram[addr][(l * 8) +: 16] <= data[15:0];
							ram[addr + 1][15:0] <= data[31:16];
						end
						else if (l == ((bits >> 3) - 1))
						begin
							ram[addr][(l * 8) +: 8] <= data[7:0];
							ram[addr + 1][23:0] <= data[31:8];
						end
						else 
							ram[addr][(l * 8) +: 32] <= data[31:0];
					end
				end
			end
			else if(control[1:0] == 3)
				ram[addr] <= data;
		end
		else 
			ram[addr] <= ram[addr];
	end

	always @(ram, addr, we, control[1:0], remainder)
	begin:load_configure
		if(we == 0)
		begin
			if (control[1:0] == 0)
			begin:load_Bytes
				if(control[2] == 0)
				begin:Signed
					for (m = 0; m <= ((bits >> 3) - 1); m = m + 1)
					begin
						if (remainder == m)
						begin
							_q[7:0] = ram[addr][(m * 8) +: 8];
							_q[(bits - 1):8] = {(bits - 8){ram[addr][((m * 8) + 7)]}};
						end
					end
				end
				else 
				begin:Unsigned
					_q[(bits - 1):8] = 0;
					for (m = 0; m <= ((bits >> 3) - 1); m = m + 1)
					begin
						if (remainder == m)
						begin
							_q[7:0] = ram[addr][(m * 8) +: 8];
						end
						
					end
				end
			end
			else if (control[1:0] == 1) 
			begin:load_HalfWords
				if(control[2] == 1)
				begin:Unsigned
					_q[(bits - 1):16] = 0;
					for (n = 0; n <= ((bits >> 3) - 1); n = n + 1)
					begin
						if (remainder == n)
						begin
							if (n == ((bits >> 3) - 1))
							begin
								_q[7:0] = ram[addr][(n * 8) +: 8];
								_q[15:8] = ram[addr + 1][7:0];
							end
							else 
								_q[15:0] = ram[addr][(n * 8) +: 8];
						end
						
					end
				end
				else 
				begin:Signed
					for (n = 0; n <= ((bits >> 3) - 1); n = n + 1)
					begin
						if (remainder == n)
						begin
							if(n == ((bits >> 3) - 1))
							begin
								_q[7:0] = ram[addr][(n * 8) +: 8];
								_q[15:8] = ram[addr + 1][7:0];
								_q[(bits - 1):16] = {(bits - 16){ram[addr + 1][7]}};
							end
							else
							begin
								_q[15:0] = ram[addr][(n * 8) +: 16];
								_q[(bits - 1):16] = {(bits - 16){ram[addr][(n * 8) + 15]}};
							end
						end
						
					end
				end
			end

			/////////////////////////////////////////start
			else if (control[1:0] == 2)
			begin:load_Words
				if (control[2] == 0)
				begin:Signed
					for (p = 0; p <= ((bits >> 3) - 1); p = p + 1)
					begin
						if (remainder == p)
						begin
							if (p == ((bits >> 3) - 3))
							begin
								_q[23:0] = ram[addr][(p * 8) +: 24];
								_q[31:24] = ram[addr + 1][7:0];
								_q[(bits - 1):32] = {(bits - 32){ram[addr + 1][7]}};
							end
							else if (p == ((bits >> 3) - 2))
							begin
								_q[15:0] = ram[addr][(p * 8) +: 16];
								_q[31:16] = ram[addr + 1][15:0];
								_q[(bits - 1):32] = {(bits - 32){ram[addr + 1][15]}};
							end
							else if (p == ((bits >> 3) - 1))
							begin
								_q[7:0] = ram[addr][(p * 8) +: 8];
								_q[31:8] = ram[addr + 1][23:0];
								_q[(bits - 1):32] = {(bits - 32){ram[addr + 1][23]}};
							end
							else 
							begin
								_q[31:0] = ram[addr][(p * 8) +: 32];
								_q[(bits - 1):32] = {(bits - 32){ram[addr][(p * 8) + 31]}};
							end
						end
						
					end
				end
				else 
				begin:Unsigned
					_q[(bits - 1):32] = 0;
					for (p = 0; p <= ((bits >> 3) - 1); p = p + 1)
					begin
						if (remainder == p)
						begin
							if (p == ((bits >> 3) - 3))
							begin
								_q[23:0] = ram[addr][(p * 8) +: 24];
								_q[31:24] = ram[addr + 1][7:0];
							end
							else if(p == ((bits >> 3) - 2)) 
							begin
								_q[15:0] = ram[addr][(p * 8) +: 16];
								_q[31:16] = ram[addr + 1][15:0];
							end
							else if(p == ((bits >> 3) - 1)) 
							begin
								_q[7:0] = ram[addr][(p * 8) +: 8];
								_q[31:8] = ram[addr + 1][23:0];
							end
							else 
							begin
								_q[31:0] = ram[addr][(p * 8) +: 32];
							end
						end
						
					end
				end
			end
			/////////////////////////////////////////end

			else
				_q = ram[addr];
		end
		else 
			_q = 0;
	end

	assign	test_out = ram[test_addr];

endmodule
