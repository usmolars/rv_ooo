
`include "riscv_isa.sv"

module flow(
	input wire clk,
	input wire reset,
	
	input 	wire	[127:0]			register_valid,

	input 	INSTRUCTION_RENAMED 	instruction_data,	
	input 	wire 					instruction_valid, 
	output 	wire					instruction_ready,	
	
	output	wire	[31:0]			jump_addr,
	output	wire					jump,
	
	output	wire	[1:0][6:0]		read_addr,
	input	wire	[1:0][31:0]		read_data,
	
	output 	wire 					result_valid,
	input 	wire 					result_ready,
	output 	RESULT 					result_data	    
);

	INSTRUCTION_SCHEDULED	scheduler_instruction_data	;
	wire					scheduler_instruction_valid ;
	reg						scheduler_ready		        ;
		
	INSTRUCTION_FLOW		flow_instruction_data		;
	
	RESULT 					result_flow        			;    
	wire 					result_flow_valid      		;


fifo#(
.DEPTH(4),
.WIDTH($bits(result_flow))
) flow_result_buffer (
.clk			(clk				),
.reset          (reset				),
.valid_i        (result_flow_valid	),
.ready_i        (scheduler_ready	),
.data_i         (result_flow		),
.valid_o        (result_valid		),
.ready_o        (result_ready		),
.data_o         (result_data		));

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

scheduler#(.SLOT(4)) scheduler_flow (
.clk			(clk						),
.reset          (reset	                    ),
.register_valid (register_valid    			),
.instruction_i  (instruction_data			),
.valid_i        (instruction_valid & instruction_data.unit == UNIT_FLOW	),
.ready_i        (instruction_ready			),
.instruction_o  (scheduler_instruction_data	),
.valid_o        (scheduler_instruction_valid),
.ready_o        (scheduler_ready			));

endmodule
