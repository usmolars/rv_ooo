`include "riscv_isa.sv"

module fetch_tb();

reg						clk							;
reg						reset						;
reg						jump						;
reg		[31:0]			jump_addr					;

wire	[31:0]			cache_instruction_addr		;
INSTRUCTION				cache_instruction_data		;
wire					cache_instruction_valid		;

INSTRUCTION_FECHED		decode_instruction_data		;
wire					decode_instruction_valid	;
reg						decode_ready                ;

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
	#50
	@(posedge clk)
	decode_ready<=0;
	#50
	@(posedge clk) decode_ready<=1;
	@(posedge clk) decode_ready<=0;
	#50
	@(posedge clk) decode_ready<=1;
	#50;
	@(posedge clk) jump<=1;
	@(posedge clk) jump<=0;
	
	#50 @(posedge clk) jump<=1;
	@(posedge clk) jump<=0;
end

fetch fetch(
.clk						(clk						),				
.reset						(reset						),
.jump						(jump						),
.jump_addr					(jump_addr					),
.cache_instruction_addr		(cache_instruction_addr		),
.cache_instruction_data		(cache_instruction_data		),
.cache_instruction_valid	(cache_instruction_valid	),		
.decode_instruction_data	(decode_instruction_data	),		
.decode_instruction_valid	(decode_instruction_valid	),
.decode_ready               (decode_ready               ));

icache#(.delay(0)) icache(
.clk			(clk						),
.address		(cache_instruction_addr		),
.instruction	(cache_instruction_data		),
.valid			(cache_instruction_valid	));

endmodule
