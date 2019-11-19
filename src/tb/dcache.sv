
module dcache#(
	parameter delay = 0,
	parameter mem_file = "ramp.mem"
)(
	input wire 				clk,
	
	input wire		[31:0]	address,
	input wire		[3:0]	we,
	input wire		[31:0]	data_write,
	output reg		[31:0]	data_read,
	output reg				valid

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

reg [7:0] ram [2047:0];

initial begin
	int i;
	for(i=0;i<2048;i=i+1)
		ram[i] <= i % 255;
end

always_ff@(posedge clk) begin
	data_read[7:0]=ram[address];
	data_read[15:8]=ram[address+1];
	data_read[23:16]=ram[address+2];
	data_read[31:24]=ram[address+3];
	
	if(we[0])
		ram[address]=data_write[7:0];
	if(we[1])
		ram[address+1]=data_write[15:8];	
	if(we[2])
		ram[address+2]=data_write[23:16];	
	if(we[3])
		ram[address+3]=data_write[31:24];	
	
end
	
endmodule