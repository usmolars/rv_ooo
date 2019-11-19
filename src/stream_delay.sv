
module stream_delay#(
	parameter WIDTH = 32,
	parameter N = 1
) (
	input wire clk,
	input wire reset,
	
	input wire [WIDTH-1:0] data_i,
	input wire valid_i,
	output wire ready_i,
	
	output wire [WIDTH-1:0] data_o,
	output wire valid_o,
	input wire ready_o
);

	generate
		if(N>0) begin
			
			int i;
			
			reg [N-1:0][WIDTH-1:0] data_delay;
			reg [N-1:0] valid_delay ;
	
			always@(posedge clk) begin
				data_delay[0] <= data_i;
				valid_delay[0] <= valid_i;
				for(i=0;i<N-1;i=i+1) begin
					data_delay[i+1] <= data_delay[i];
					valid_delay[i+1] <= valid_delay[i];
				end
				if(reset)
					valid_delay <= '0;
			end
			
			assign data_o = data_delay[N-1];
			assign valid_o = valid_delay[N-1];
			assign ready_i = ready_o;
			
		end else begin
		
			assign data_o = data_i;
			assign valid_o = valid_i;
			assign ready_i = ready_o;
			
		end	
	endgenerate	
endmodule

