
`include "riscv_isa.sv"

module alu_p1(
	input wire clk,
	input wire reset,
	
	input	INSTRUCTION_ALU instruction,
	output 	RESULT			result,
	output	reg 			result_valid
);

	always_ff@(posedge clk) begin
		case(instruction.alu_func)
			ADD		:	begin
							result.dest <= instruction.rd;
							result.data <= instruction.lhs + instruction.rhs;
							result_valid <= 1;
						end	
			SLL 	: 	begin
							result.dest <= instruction.rd;
							result.data <= instruction.lhs << instruction.rhs;
							result_valid <= 1;
						end	
			SLT 	: 	begin
							result.dest <= instruction.rd;
							result.data <= ($signed(instruction.lhs)) < ($signed(instruction.rhs)) ? '1 : '0;
							result_valid <= 1;
						end	
			SLTU	: 	begin
							result.dest <= instruction.rd;
							result.data <= instruction.lhs < instruction.rhs ? '1 : '0;
							result_valid <= 1;
						end	
			XOR 	: 	begin
							result.dest <= instruction.rd;
							result.data <= instruction.lhs ^ instruction.rhs;
							result_valid <= 1;
						end	
			SR 		: 	begin
							result.dest <= instruction.rd;
							result.data <= instruction.lhs >> instruction.rhs;
							result_valid <= 1;
						end	
			OR  	: 	begin
							result.dest <= instruction.rd;
							result.data <= instruction.lhs | instruction.rhs;
							result_valid <= 1;
						end	
			AND 	: 	begin   
							result.dest <= instruction.rd;
							result.data <= instruction.lhs & instruction.rhs;
							result_valid <= 1;
						end	
			SUB		: 	begin
							result.dest <= instruction.rd;
							result.data <= instruction.lhs - instruction.rhs;
							result_valid <= 1;
						end
			SRA		: 	begin
							result.dest <= instruction.rd;
							result.data <= instruction.lhs >>> instruction.rhs;
							result_valid <= 1;
						end
			default	: 	begin   
							result.dest <= '0;
							result.data <= '0;
							result_valid <= 0;
						end
		endcase
	end

endmodule
