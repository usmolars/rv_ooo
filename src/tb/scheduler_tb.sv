
`include "riscv_isa.sv"

module scheduler_tb();

reg						clk							;
reg						reset						;
reg						jump						;
reg		[31:0]			jump_addr					;

reg valid_force;

wire	[31:0]			cache_instruction_addr		;
INSTRUCTION				cache_instruction_data		;
wire					cache_instruction_valid		;

INSTRUCTION_FECHED		fetch_instruction_data		;
wire					fetch_instruction_valid		;
wire					fetch_ready                	;

INSTRUCTION_DECODED		decode_instruction_data		;	
wire 					decode_instruction_valid	;
wire					decode_ready				;

INSTRUCTION_RENAMED		rename_instruction_data	    ;
wire					rename_instruction_valid	;
wire					rename_ready				;

INSTRUCTION_SCHEDULED	scheduler_instruction_data	;
wire					scheduler_instruction_valid ;
reg						scheduler_ready		        ;

reg [127:0]				register_valid				;
	
initial begin
	clk<=0;
	forever	#5 clk<=~clk;
end

initial begin
valid_force<=1;
	reset<=1;
	jump_addr<='0;
	jump<=0;
	scheduler_ready<=0;
	register_valid<='0;
	#20
	@(posedge clk)
	reset<=0;
	@(posedge clk)
	scheduler_ready<=1;
	#100
	@(posedge clk)
	register_valid<=128'd2;
	@(posedge clk)
	register_valid<='0;
	#20
	@(posedge clk)	
	register_valid<='1;
	#50
	@(posedge clk)
	valid_force<=0;
end

scheduler#(.SLOT(4)) scheduler (
.clk			(clk						),
.reset          (reset	                    ),
.register_valid (register_valid             ),
.instruction_i  (rename_instruction_data	),
.valid_i        (rename_instruction_valid	),
.ready_i        (rename_ready				),
.instruction_o  (scheduler_instruction_data	),
.valid_o        (scheduler_instruction_valid),
.ready_o        (scheduler_ready			));

register_rename#(.I_COUNT(32),.O_COUNT(128)) register_rename(
.clk			(clk						),
.reset          (reset						),
.instruction_i  (decode_instruction_data	),
.valid_i        (decode_instruction_valid & valid_force	),
.ready_i        (decode_ready				),
.instruction_o  (rename_instruction_data	),
.valid_o        (rename_instruction_valid	),
.ready_o        (rename_ready				));

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
