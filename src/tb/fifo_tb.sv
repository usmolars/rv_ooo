
module fifo_tb();

parameter DEPTH = 2;
parameter WIDTH = 4;

reg 				clk		;
reg 				reset   ;

reg 				valid_i ;
wire 				ready_i ;
reg 	[WIDTH-1:0] data_i  ;

wire				valid_o ;
reg					ready_o ;
wire	[WIDTH-1:0]	data_o  ;

wire				almost_full    ;

initial begin
clk<=0;
forever
#10 clk<=~clk;
end

task stream(int length);
	int i;
	
	for(i=0;i<length;i=i+1) begin
		@(posedge clk)
		valid_i <= 1;
		data_i <= '0 + i;
	end
	@(posedge clk)
	valid_i <= '0;
	data_i <= '0;
endtask

initial begin
reset<=1'b1;
data_i<='0;
valid_i<=1'b0;
ready_o<=1'b0;
#100
@(posedge clk)
reset<=1'b0;
stream(4);
@(posedge clk)
ready_o <= 1;
stream(2);
#100
stream(6);
end

fifo#(
.DEPTH(2),
.WIDTH(4)
) fifo (
.clk		(clk		),
.reset      (reset     	),
.valid_i    (valid_i   	),
.ready_i    (ready_i   	),
.data_i     (data_i    	),
.valid_o    (valid_o   	),
.ready_o    (ready_o   	),
.data_o     (data_o    	));

endmodule
