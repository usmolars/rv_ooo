`include "riscv_isa.sv"

module decode(
	input	logic	clk,
	input	logic	reset,

	input	logic	jump,

	input	INSTRUCTION_FECHED	instruction_i,
	input	logic				valid_i,
	output	logic				ready_i,

	output 	INSTRUCTION_DECODED	instruction_o,
	output	logic				valid_o,
	input	logic				ready_o
);

	OPCODE_UNIT	unit;
	OPCODE_DEPENDANCY dependancy;
	
	reg wait_for_flow;
	always_ff@(posedge clk)
		if(reset | jump)
			wait_for_flow <= 0;
		else if (unit == UNIT_FLOW & valid_i & !wait_for_flow & jump_delay==0)
			wait_for_flow <= 1;
	
	reg [1:0] jump_delay;
	always_ff@(posedge clk)
		if(reset)
			jump_delay <= '0;
		else
			jump_delay <= {jump_delay[0],wait_for_flow};
	
	assign ready_i = ready_o	;

	always_ff@(posedge clk) begin
		valid_o	<=	valid_i	& !wait_for_flow & jump_delay==0;
		if(ready_o) begin
			instruction_o.unit  		<=	unit						;
			instruction_o.dependancy	<=	dependancy					;
			instruction_o.instruction 	<=	instruction_i.instruction	;
			instruction_o.pc			<=	instruction_i.pc			;
			instruction_o.pc_4			<=	instruction_i.pc_4			;
		end
	end
	
	always_comb begin	
		case(instruction_i.instruction.r_type.opcode)			
			LUI		:	begin	unit		<=	UNIT_ALU_INT	;
								dependancy	<=	DEPENDANCY_NO	;	end
			AUIPC	:	begin	unit		<=	UNIT_ALU_INT	;
								dependancy	<=	DEPENDANCY_NO	;	end			
			JAL	    :	begin	unit		<=	UNIT_FLOW	 	;
								dependancy	<=	DEPENDANCY_NO	;	end			
			JALR 	:	begin	unit		<=	UNIT_FLOW 		;
								dependancy	<=	DEPENDANCY_RS1	;	end			
			BRANCH	:	begin	unit		<=	UNIT_FLOW		;
								dependancy	<=	DEPENDANCY_RS2	;	end			
			LOAD	:	begin	unit		<=	UNIT_LOAD_STORE	;
								dependancy	<=	DEPENDANCY_RS1	;	end			
			STORE	:	begin	unit		<=	UNIT_LOAD_STORE	;
								dependancy	<=	DEPENDANCY_RS2	;	end			
			ALUI	:	begin	unit		<=	UNIT_ALU_INT	;
								dependancy	<=	DEPENDANCY_RS1	;	end			
			ALU	    :	begin	unit		<=	UNIT_ALU_INT	;
								dependancy	<=	DEPENDANCY_RS2	;	end			
			FENCE	:	begin	unit		<=	UNIT_NOT_IMPLEMENTED	;
								dependancy	<=	DEPENDANCY_NO	;	end			
			PRIVI	:	begin	unit		<=	UNIT_NOT_IMPLEMENTED	;
								dependancy	<=	DEPENDANCY_RS1	;	end			
			default :	begin  	unit		<=	UNIT_NOT_IMPLEMENTED	;	
								dependancy	<=	DEPENDANCY_NO	;	end			
		endcase		
	end
   
endmodule
