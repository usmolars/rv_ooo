
module regbank_tb();

reg clk;
reg reset; 
reg [31:0] write_data;
reg  [4:0] write_address;
	
reg  [5:0][6:0] read_addr;
wire [5:0][31:0] read_data;
	
reg  [4:0]   invalidate_register;
wire [31:0] register_valid;

initial begin
	clk<=0;
	forever	#5 clk<=~clk;
end

initial begin
reset<=1;
write_address<=0;
write_data<=0;
#100
@(posedge clk)
reset<=0;


@(posedge clk)
invalidate_register <= 5;
read_addr[0]<=0;
read_addr[1]<=1;
read_addr[2]<=2;
read_addr[3]<=3;
read_addr[4]<=4;
read_addr[5]<=5;
@(posedge clk)
invalidate_register <= 0;
write_data<=255;
@(posedge clk)
write_address<=5;
@(posedge clk)
write_address<=0;
invalidate_register <= 2;
@(posedge clk)
write_address<=4;
@(posedge clk)
invalidate_register <= 0;
end


regbank regbank (
	.clk				(clk					),
	.reset              (reset                  ),
	.write_data         (write_data             ),
	.write_address      (write_address          ),
	.read_addr          (read_addr[1:0]         ),
	.read_data          (read_data[1:0]         ),
	.invalidate_register(invalidate_register    ),
	.register_valid     (register_valid         ));


endmodule
