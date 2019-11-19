
module ls(
	input wire clk,
	input wire reset,
	
	input 	wire	[127:0]			register_valid,

	input 	INSTRUCTION_RENAMED 	instruction_data,	
	input 	wire 					instruction_valid, 
	output 	wire					instruction_ready,	
	
	output	wire	[1:0][6:0]		read_addr,
	input	wire	[1:0][31:0]		read_data,
	
	output 	wire	[31:0]			mem_addr,
	output 	wire	[3:0]			mem_we,
	output 	wire	[31:0]			mem_data_write,
	input 	wire	[31:0]			mem_data_read,
	input 	wire					mem_data_valid,

	output 	wire 					result_valid,
	input 	wire 					result_ready,
	output 	RESULT 					result_data	    
);

	INSTRUCTION_SCHEDULED	scheduler_instruction_data	;
	wire					scheduler_instruction_valid ;
	reg						scheduler_ready		        ;
		
	INSTRUCTION_LS			ls_instruction_data		;
	
	wire ls_p1_ready;
	
	RESULT 					result_ls_data	;    
	wire 					result_ls_valid ;
	wire 					result_ls_ready	;

fifo#(
.DEPTH(4),
.WIDTH($bits(result_ls_data))
) ls_result_buffer (
.clk			(clk				),
.reset          (reset				),
.valid_i        (result_ls_valid	),
.ready_i        (result_ls_ready	),
.data_i         (result_ls_data		),
.valid_o        (result_valid		),
.ready_o        (result_ready		),
.data_o         (result_data		));

ls_p1 ls_p1(
.clk				(clk					),
.reset              (reset                  ),
.instruction        (ls_instruction_data    ),
.instruction_ready  (ls_p1_ready            ),
.addr               (mem_addr               ),
.we                 (mem_we                 ),
.data_write         (mem_data_write         ),
.data_read          (mem_data_read          ),
.data_valid         (mem_data_valid         ),
.result             (result_ls_data         ),
.result_valid       (result_ls_valid        ),
.result_ready       (result_ls_ready        ));

ls_p0 ls_p0(
.clk			(clk							),
.reset          (reset                          ),
.addra          (read_addr[0]                   ),
.addrb          (read_addr[1]                   ),
.dataa          (read_data[0]                   ),
.datab	        (read_data[1]                   ),
.instruction_i  (scheduler_instruction_data	    ),
.valid_i        (scheduler_instruction_valid    ),
.ready_i        (scheduler_ready			    ),
.instruction_o  (ls_instruction_data            ),
.ready_o        (ls_p1_ready                    ));

scheduler#(.SLOT(4)) scheduler (
.clk			(clk						),
.reset          (reset	                    ),
.register_valid (register_valid             ),
.instruction_i  (instruction_data			),
.valid_i        (instruction_valid & instruction_data.unit == UNIT_LOAD_STORE),
.ready_i        (instruction_ready			),
.instruction_o  (scheduler_instruction_data	),
.valid_o        (scheduler_instruction_valid),
.ready_o        (scheduler_ready			));

endmodule
