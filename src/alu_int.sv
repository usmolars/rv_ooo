
`include "riscv_isa.sv"

module alu_int(
	input wire clk,
	input wire reset,
	
	input 	wire	[127:0]			register_valid,

	input 	INSTRUCTION_RENAMED 	instruction_data,	
	input 	wire 					instruction_valid, 
	output 	wire					instruction_ready,	
	
	output	wire	[1:0][6:0]		read_addr,
	input	wire	[1:0][31:0]		read_data,
	
	output 	wire 					result_valid,
	input 	wire 					result_ready,
	output 	RESULT 					result_data	    
);

	INSTRUCTION_SCHEDULED	scheduler_instruction_data	;
	wire					scheduler_instruction_valid ;
	reg						scheduler_ready		        ;
	INSTRUCTION_ALU			alu_instruction_data		;
	RESULT 					alu_result					;    
	wire 					alu_result_valid			;

fifo#(
.DEPTH(4),
.WIDTH($bits(alu_result))
) alu_result_buffer (
.clk			(clk				),
.reset          (reset				),
.valid_i        (alu_result_valid	),
.ready_i        (scheduler_ready	),
.data_i         (alu_result			),
.valid_o        (result_valid		),
.ready_o        (result_ready		),
.data_o         (result_data		));

alu_p1 alu_p1(
.clk			(clk					),
.reset          (reset                  ),
.instruction	(alu_instruction_data	),
.result			(alu_result				),
.result_valid	(alu_result_valid		));

alu_p0 alu_p0(
.clk			(clk						),
.reset	        (reset						),
.addra          (read_addr[0]				),
.addrb          (read_addr[1]				),
.dataa          (read_data[0]				),
.datab          (read_data[1]				),
.instruction_i  (scheduler_instruction_data	),
.valid_i        (scheduler_instruction_valid),
.instruction_o  (alu_instruction_data		));

scheduler#(.SLOT(4)) scheduler (
.clk			(clk						),
.reset          (reset	                    ),
.register_valid (register_valid             ),
.instruction_i  (instruction_data			),
.valid_i        (instruction_valid & instruction_data.unit == UNIT_ALU_INT),
.ready_i        (instruction_ready			),
.instruction_o  (scheduler_instruction_data	),
.valid_o        (scheduler_instruction_valid),
.ready_o        (scheduler_ready			));

endmodule
