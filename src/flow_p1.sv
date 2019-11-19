
`include "riscv_isa.sv"

module flow_p1(
	input wire clk,
	input wire reset,
	
	input	INSTRUCTION_FLOW	instruction,
	
	output	reg					jump,
	output	reg			[31:0]	jump_addr,
	
	output 	RESULT				result,
	output	reg 				result_valid
);

	reg branch_taken;
	
	always_comb
		case(instruction.branch_type)
			BEQ 	:	branch_taken <= instruction.branch_lhs == instruction.branch_rhs;
			BNE		:   branch_taken <= instruction.branch_lhs != instruction.branch_rhs;
			BLT 	:   branch_taken <= ($signed(instruction.branch_lhs)) <  ($signed(instruction.branch_rhs));
			BGE 	:   branch_taken <= ($signed(instruction.branch_lhs)) >= ($signed(instruction.branch_rhs));
			BLTU	:   branch_taken <= ($unsigned(instruction.branch_lhs)) <  ($unsigned(instruction.branch_rhs));
			BGEU	:   branch_taken <= ($unsigned(instruction.branch_lhs)) >= ($unsigned(instruction.branch_rhs));
			default	:   branch_taken <= 0;
		endcase
	
	always_ff@(posedge clk) begin
		jump_addr <= (branch_taken | instruction.flow_func == FLOW_JAL | instruction.flow_func == FLOW_JALR) ? instruction.pc_rhs + instruction.pc_lhs : instruction.pc_4;
		jump <= instruction.flow_func != FLOW_NOP;
		result.dest <= instruction.rd;
		result.data <= instruction.pc_4;
		result_valid <= instruction.flow_func == FLOW_JAL | instruction.flow_func == FLOW_JALR;
	end
	
endmodule
