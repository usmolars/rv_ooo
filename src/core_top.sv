
`include "riscv_isa.sv"

module core_top(
	input wire clk,
	input wire reset,
	
	output	wire [31:0]	instruction_addr,
	input 	wire [31:0]	instruction_data,
	input 	wire		instruction_valid,
	
	output reg		[31:0]	mem_addr,
	output reg		[3:0]	mem_we,
	output reg		[31:0]	mem_data_write,
	input wire		[31:0]	mem_data_read,
	input wire				mem_data_valid
);

wire						jump						;
wire		[31:0]			jump_addr					;

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
wire	[2:0]			rename_ready				;

RESULT	[2:0]	result_data			;
wire	[2:0]	result_valid	;
wire 	[2:0] 	result_ready	;

wire [5:0][6:0] 	read_addr;
wire [5:0][31:0]	read_data;
wire [31:0] write_data;
wire [6:0] write_addr;

wire 	[127:0] register_valid;
wire  	[6:0]   invalidate_register;
assign invalidate_register = rename_instruction_valid ? rename_instruction_data.rd : '0;

write_back#(.N(3)) write_back (
.clk			(clk			),
.reset          (reset          ),
.result         (result_data    ),
.result_valid   (result_valid   ),
.result_ready   (result_ready   ),
.write_addr     (write_addr     ),
.write_data     (write_data     ));

ls ls(
.clk				(clk							),
.reset              (reset                          ),
.register_valid     (register_valid                 ),
.instruction_data	(rename_instruction_data	    ),
.instruction_valid  (rename_instruction_valid	    ),
.instruction_ready	(rename_ready[2]				),
.read_addr          ({read_addr[4],read_addr[5]}    ),
.read_data          ({read_data[4],read_data[5]}    ),
.mem_addr           (mem_addr                       ),
.mem_we             (mem_we                         ),
.mem_data_write     (mem_data_write                 ),
.mem_data_read      (mem_data_read                  ),
.mem_data_valid     (mem_data_valid                 ),
.result_valid       (result_valid[2]                ),
.result_ready       (result_ready[2]                ),
.result_data	    (result_data[2]                 ));

alu_int alu(
.clk				(clk							),
.reset              (reset                          ),
.register_valid     (register_valid                 ),
.instruction_data	(rename_instruction_data	    ),
.instruction_valid  (rename_instruction_valid	    ),
.instruction_ready	(rename_ready[1]				),
.read_addr          ({read_addr[2],read_addr[3]}    ),
.read_data          ({read_data[2],read_data[3]}    ),
.result_valid       (result_valid[1]                ),
.result_ready       (result_ready[1]                ),
.result_data	    (result_data[1]                 ));

flow flow(
.clk				(clk							),
.reset              (reset                          ),
.register_valid     (register_valid                 ),
.instruction_data	(rename_instruction_data	    ),
.instruction_valid  (rename_instruction_valid	    ),
.instruction_ready	(rename_ready[0]			    ),
.jump_addr          (jump_addr                      ),
.jump               (jump                           ),
.read_addr          ({read_addr[0],read_addr[1]}    ),
.read_data          ({read_data[0],read_data[1]}    ),
.result_valid       (result_valid[0]                ),
.result_ready       (result_ready[0]                ),
.result_data	    (result_data[0]                 ));

register_rename#(.I_COUNT(32),.O_COUNT(128)) register_rename(
.clk			(clk						),
.reset          (reset						),
.instruction_i  (decode_instruction_data	),
.valid_i        (decode_instruction_valid	),
.ready_i        (decode_ready				),
.instruction_o  (rename_instruction_data	),
.valid_o        (rename_instruction_valid	),
.ready_o        (&rename_ready				));

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
.cache_instruction_addr		(instruction_addr			),
.cache_instruction_data		(instruction_data			),
.cache_instruction_valid	(instruction_valid			),		
.decode_instruction_data	(fetch_instruction_data		),		
.decode_instruction_valid	(fetch_instruction_valid	),
.decode_ready               (fetch_ready               ));

regbank#(
	.DWIDTH(32),
	.AWIDTH(7),
	.READ_PORT(6)
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
