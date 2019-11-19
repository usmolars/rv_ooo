
module core_top_tb();

reg reset;
reg clk;


wire	[31:0]	instruction_addr   	;
wire	[31:0]	instruction_data   	;
wire			instruction_valid  	;

wire	[31:0]	mem_addr       		;	    	
wire	[3:0]	mem_we         		;    	
wire	[31:0]	mem_data_write 		;    	
wire	[31:0]	mem_data_read  		;    	
wire			mem_data_valid 		;    	
	
initial begin
	clk<=0;
	forever	#5 clk<=~clk;
end

initial begin
	reset<=1;
	#20
	@(posedge clk)
	reset<=0;
end

core_top core_top(
.clk				(clk				),
.reset              (reset              ),
.instruction_addr   (instruction_addr   ),
.instruction_data   (instruction_data   ),
.instruction_valid  (instruction_valid  ),
.mem_addr           (mem_addr           ),
.mem_we             (mem_we             ),
.mem_data_write     (mem_data_write     ),
.mem_data_read      (mem_data_read      ),
.mem_data_valid     (mem_data_valid     ));

icache#(.delay(0),.mem_file("program.mem")) icache(
.clk			(clk					),
.address		(instruction_addr   	),
.instruction	(instruction_data   	),
.valid			(instruction_valid  	));

dcache#(.delay(0),.mem_file("ramp.mem")) dcache(
.clk			(clk					),
.address        (mem_addr           	),
.we             (mem_we             	),
.data_write     (mem_data_write     	),
.data_read      (mem_data_read      	),
.valid          (mem_data_valid     	));


endmodule
