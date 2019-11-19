`include "riscv_isa.sv"

module decode_tb();

reg						clk							;
reg						reset						;
reg						jump						;
reg		[31:0]			jump_addr					;

wire	[31:0]			cache_instruction_addr		;
INSTRUCTION				cache_instruction_data		;
wire					cache_instruction_valid		;

INSTRUCTION_FECHED		fetch_instruction_data		;
wire					fetch_instruction_valid		;
wire					fetch_ready                	;

INSTRUCTION_DECODED		decode_instruction_data		;	
wire 					decode_instruction_valid	;
reg						decode_ready					;

initial begin
	clk<=0;
	forever	#5 clk<=~clk;
end

initial begin
	reset<=1;
	jump_addr<='0;
	jump<=0;
	decode_ready<=0;
	#20
	@(posedge clk)
	reset<=0;
	@(posedge clk)
	decode_ready<=1;
	#60
	@(posedge clk)
	decode_ready<=0;
	#10
	@(posedge clk) decode_ready<=1;
	@(posedge clk) decode_ready<=0;
	#10
	@(posedge clk) decode_ready<=1;
end

decode decode(
.clk			(clk						),
.reset          (reset                      ),
.instruction_i  (fetch_instruction_data	    ),
.valid_i        (fetch_instruction_valid	),
.ready_i        (fetch_ready                ),
.instruction_o  (decode_instruction_data	),	
.valid_o        (decode_instruction_valid	),   
.ready_o        (decode_ready               ));  
	
fetch fetch(
.clk						(clk						),				
.reset						(reset						),
.jump						(jump						),
.jump_addr					(jump_addr					),
.cache_instruction_addr		(cache_instruction_addr		),
.cache_instruction_data		(cache_instruction_data		),
.cache_instruction_valid	(cache_instruction_valid	),		
.decode_instruction_data	(fetch_instruction_data	),		
.decode_instruction_valid	(fetch_instruction_valid	),
.decode_ready               (fetch_ready               ));

icache#(.delay(0),.mem_file("program.mem")) icache(
.clk			(clk						),
.address		(cache_instruction_addr		),
.instruction	(cache_instruction_data		),
.valid			(cache_instruction_valid	));

endmodule
