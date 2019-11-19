
module inferred_bram_1wr_1rd#(
	parameter AWIDTH = 5,
	parameter DWIDTH = 32
) (
	input wire clk,
	
	input wire [AWIDTH-1:0] write_addr,
	input wire [DWIDTH-1:0]	write_data,
	
	input wire [AWIDTH-1:0] read_addr,
	output reg [DWIDTH-1:0] read_data
);

	reg [DWIDTH-1:0] mem [2**AWIDTH-1:0];
	
	initial begin
		int k;
		for(k=0;k<2**AWIDTH;k=k+1)
			mem[k]='0;
	end
		
	always@(posedge clk) begin
		mem[write_addr] <= write_data;
		read_data <= mem[read_addr];
	end

endmodule
