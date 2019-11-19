
module icache#(
	parameter delay = 0,
	parameter mem_file = "ramp.mem"
)(
	input wire			clk,
	input wire	[31:0]	address,
	output reg [31:0]	instruction,
	output wire			valid

);

reg [7:0] valid_cnt  = '0;
reg [31:0] address_d;

always_ff@(posedge clk) begin
	address_d<=address;
	if(address_d!=address)
		valid_cnt <= delay;
	if(valid_cnt!=0)
		valid_cnt<=valid_cnt-1;
end

assign valid =  valid_cnt==0;

reg [31:0] rom [511:0];

initial
	$readmemh(mem_file, rom);

always_ff@(posedge clk)
	instruction<=rom[address[31:2]];
	
endmodule