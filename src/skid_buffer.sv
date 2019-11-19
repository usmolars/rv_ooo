
module skid_buffer#(
parameter WIDTH = 32,
parameter RST = 0,
parameter RSTVAL = 0,
parameter OREG = 0
) (			
input 	logic				clk,
input 	logic				reset,
input 	logic				ready_o,
input 	logic	[WIDTH-1:0] data_i,
output	logic	[WIDTH-1:0]	data_o
);

logic reset_int;
assign reset_int = reset & RST;

logic	stored_data	;
logic	ready_o_d	;
	
logic [WIDTH-1:0] buffer;
logic [WIDTH-1:0] output_mux;
logic [WIDTH-1:0] output_reg;	
	
always_ff@(posedge clk)
	ready_o_d <= ready_o	;
	
always_ff@(posedge clk) begin
	if(ready_o_d)
		buffer	<= data_i	;
	if(reset_int)
		buffer 	<=	RSTVAL	;
end	
	
assign output_mux =	stored_data ? buffer : data_i	;
	
always_ff@(posedge clk) begin
	if(ready_o)
		output_reg	<=	output_mux;
	if(reset)
		output_reg 	<=	RSTVAL		;
end		
always_ff@(posedge clk)
	if(ready_o)
		stored_data<=0;
	else
		stored_data<=1;

assign data_o = OREG ? output_reg : output_mux ;

endmodule