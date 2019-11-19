
module regbank#(
	parameter DWIDTH = 32,
	parameter AWIDTH = 5,
	parameter READ_PORT = 2
) (
	input wire clk,
	input wire reset, 
	
	input wire [DWIDTH-1:0] write_data,
	input wire [AWIDTH-1:0] write_address,
	
	input wire [READ_PORT-1:0][AWIDTH-1:0] read_addr,
	output wire [READ_PORT-1:0][DWIDTH-1:0] read_data,
	
	input wire [AWIDTH-1:0] invalidate_register,
	output reg [2**AWIDTH-1:0] register_valid
);

	always_ff@(posedge clk) begin
		register_valid[invalidate_register] <= 0;
		register_valid[write_address] <= 1;
		register_valid[0] <= 1;
		if (reset)
			register_valid <= '1;
	end

	genvar i;
	generate
		for(i=0;i<READ_PORT;i=i+1) begin

			wire [31:0] read_data_int;
		
			inferred_bram_1wr_1rd#(.AWIDTH(AWIDTH),.DWIDTH(DWIDTH)) ram (
				.clk		(clk			),
				.write_addr (write_address  ),
				.write_data (write_data     ),
				.read_addr  (read_addr[i]   ),
				.read_data  (read_data_int  ));
			
			assign read_data[i] = |read_addr[i] ? read_data_int : '0;

		end
	endgenerate



endmodule
