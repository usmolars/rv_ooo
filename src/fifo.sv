
module fifo#(
parameter DEPTH = 2,
parameter WIDTH = 32,
parameter ALMOST_FULL = 1
) (

input 	wire 				clk,
input 	wire 				reset,

input 	wire 				valid_i,
output 	reg 				ready_i,
input 	wire 	[WIDTH-1:0] data_i,

output	reg					valid_o,
input	wire				ready_o,
output	wire	[WIDTH-1:0]	data_o
);

reg [WIDTH-1:0]	data [2**DEPTH-1:0];
reg [DEPTH-1:0]	ptr_i;
reg	[DEPTH-1:0]	ptr_o;

reg [DEPTH-1:0] fill;

always@(posedge clk) begin
	if(valid_o & ready_o) begin
		ptr_o <= ptr_o + 1;
		fill = fill - 1;
		ready_i <= 1;
		if(fill==0)
			valid_o<=0;
	end
	if(valid_i & ready_i) begin
		fill = fill+1;
		ptr_i <= ptr_i + 1;
		valid_o <= 1;
		if(fill==0)
			ready_i <= 0;
	end
	if(reset) begin
		valid_o <= 0;
		fill = '0;
		ptr_o <= '0;
		ptr_i <= '0;
		ready_i <= 1;
	end
end

always@(posedge clk) begin
	if(valid_i & ready_i)
		data[ptr_i] <= data_i;
end

	//assign valid_o = |fill;
	assign data_o = data[ptr_o];

endmodule
