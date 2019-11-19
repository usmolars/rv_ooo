
module write_back#(
	parameter N = 1
) (
	input wire clk,
	input wire reset,
	
	input RESULT	[N-1:0] result,
	input wire		[N-1:0]	result_valid,
	output reg		[N-1:0] result_ready,
	
	output reg		[6:0]	write_addr,
	output reg		[31:0]	write_data
);
	
	reg [$clog2(N)-1:0] pending_write_cout;
	reg [$clog2(N)-1:0] result_count;
	reg [N-1:0]	pending_write;
	
	RESULT [N-1:0] write_buffer;
	
	reg write_valid;
	reg [$clog2(N)-1:0] write_valid_index;
	

	always_ff@(posedge clk) begin
		result_ready <= '0;
		if(!(|result_ready) & pending_write_cout < 3 | reset)
			result_ready <= '1;
		if(result_ready & (result_count == 1 | result_count == 0))
			result_ready <= '1;
	end
	
	int i;
	always_comb begin
		result_count = 0;
		for(i=0;i<N;i=i+1)
			if(result_valid[i])
				result_count = result_count + 1;
	end
	
	always_ff@(posedge clk) begin
		if(|pending_write_cout)
			pending_write_cout <= pending_write_cout - 1;
		if(|result_ready)
			pending_write_cout <= result_count;	
	end
	
	int k;
	always_comb begin
		write_valid<=0;
		write_valid_index<=0;
		for(k=N-1;k>=0;k=k-1)
			if(pending_write[k]) begin
				write_valid_index<=k;
				write_valid<=1;
			end
	end
	
	always_ff@(posedge clk) begin
		write_addr <= write_valid ? write_buffer[write_valid_index].dest : '0;
		write_data <= write_valid ? write_buffer[write_valid_index].data : '0;
	end
	
	always_ff@(posedge clk) begin
		if(write_valid)
			pending_write[write_valid_index] <= 0;
		if(result_ready) begin
			write_buffer <= result;
			pending_write <= result_valid;
		end
		if(reset)
			pending_write <= '0;
	end
	
endmodule
