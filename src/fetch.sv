
`include "riscv_isa.sv"

module fetch(
	input	wire				clk							,
	input	wire				reset						,

	input	wire				jump						,
	input	wire	[31:0]		jump_addr					,
		
	output	logic	[31:0]		cache_instruction_addr		,
	input	INSTRUCTION			cache_instruction_data		,
	input	logic				cache_instruction_valid		,

	output 	INSTRUCTION_FECHED	decode_instruction_data		,
	output	logic				decode_instruction_valid	,
	input	logic				decode_ready
);
	
	
	logic	[31:0]	pc_reg		;
	logic	[31:0]	pc_d		;	
	logic	decode_instruction_valid_d0;
	skid_buffer#(
		.WIDTH  (32	),
		.RST	(0  ),
		.OREG   (1  )
	)	instruction_buffer	(
	.clk	 (clk						),
	.reset   (reset                     ),
	.ready_o (decode_ready				),
	.data_i  (cache_instruction_data    ),
	.data_o  (decode_instruction_data.instruction   ));
	
	skid_buffer#(
		.WIDTH  (32	),
		.RST	(0  ),
		.OREG   (1  )
	)	pc_buffer	(
	.clk	 (clk							),
	.reset   (reset                     	),
	.ready_o (decode_ready					),
	.data_i  (pc_d    						),
	.data_o  (decode_instruction_data.pc   	));
	
	skid_buffer#(
		.WIDTH  (32	),
		.RST	(0  ),
		.OREG   (1  )
	)	pc_4_buffer	(
	.clk	 (clk							),
	.reset   (reset                     	),
	.ready_o (decode_ready					),
	.data_i  (pc_reg   						),
	.data_o  (decode_instruction_data.pc_4 	));
	
	skid_buffer#(
		.WIDTH  (1	),
		.RST	(1  ),
		.OREG   (1  )
	)	valid_buffer	(
	.clk	 (clk						),
	.reset   (reset                     ),
	.ready_o (decode_ready				),
	.data_i  (cache_instruction_valid   ),
	.data_o  (decode_instruction_valid_d0  ));
	
	always_ff@(posedge clk) begin
		pc_d<=pc_reg;
		if(decode_ready & cache_instruction_valid)
			pc_reg<=pc_reg + 4;
		if(jump==1)
			pc_reg<=jump_addr;
		if(reset==1)
			pc_reg<='0;
	end
    
	always_ff@(posedge clk)
		decode_instruction_valid <= decode_instruction_valid_d0;
		
	assign cache_instruction_addr = pc_reg;
	
endmodule
