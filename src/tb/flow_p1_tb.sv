
`include "riscv_isa.sv"

module flow_p1_tb();

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
	
INSTRUCTION_FLOW		flow_instruction_data		;

RESULT 					result_flow        			;    
wire 					result_flow_valid      		;
	
reg [31:0] write_data;
reg  [6:0] write_addr;
	
reg  [1:0][6:0] read_addr;
wire [1:0][31:0] read_data;
	
wire  [6:0]   invalidate_register;
assign invalidate_register = rename_instruction_valid ? rename_instruction_data.rd : '0;
	
	
initial begin
	clk<=0;
	forever	#5 clk<=~clk;
end

initial begin
	valid_force<=1;
	scheduler_ready<=1;
	reset<=1;
	#20
	@(posedge clk)
	reset<=0;
	#100
	@(posedge clk)
	valid_force <= 0;
end

flow_p1 flow_p1(
.clk			(clk					),
.reset          (reset                  ),
.instruction    (flow_instruction_data  ),
.jump           (jump			        ),
.jump_addr      (jump_addr		        ),
.result         (result_flow            ),
.result_valid   (result_flow_valid      ));

flow_p0 flow_p0(
.clk			(clk						),
.reset	        (reset						),
.addra          (read_addr[0]				),
.addrb          (read_addr[1]				),
.dataa          (read_data[0]				),
.datab          (read_data[1]				),
.instruction_i  (scheduler_instruction_data	),
.valid_i        (scheduler_instruction_valid),
.instruction_o  (flow_instruction_data		));

scheduler#(.SLOT(4)) scheduler (
.clk			(clk						),
.reset          (reset	                    ),
.register_valid ('1    			),
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
.valid_i        (decode_instruction_valid	),
.ready_i        (decode_ready				),
.instruction_o  (rename_instruction_data	),
.valid_o        (rename_instruction_valid	),
.ready_o        (rename_ready				));

decode decode(
.clk			(clk						),
.reset          (reset                      ),
.jump			(jump						),
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

icache#(.delay(0),.mem_file("program_flow.mem")) icache(
.clk			(clk						),
.address		(cache_instruction_addr		),
.instruction	(cache_instruction_data		),
.valid			(cache_instruction_valid	));

regbank#(
	.DWIDTH(32),
	.AWIDTH(7),
	.READ_PORT(2)
) regbank (
	.clk				(clk					),
	.reset              (reset                  ),
	.write_data         (write_data             ),
	.write_address      (write_addr	         	),
	.read_addr          (read_addr              ),
	.read_data          (read_data              ),
	.invalidate_register(invalidate_register    ),
	.register_valid     (register_valid         ));

endmodule
