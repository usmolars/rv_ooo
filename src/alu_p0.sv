
`include "riscv_isa.sv"

module alu_p0(
	input wire clk,
	input wire reset,
	
	output	wire			[6:0]	addra,
	output	wire			[6:0]	addrb,
	input	wire			[31:0]	dataa,
	input	wire			[31:0]	datab,
	
	input	INSTRUCTION_SCHEDULED 	instruction_i,
	input	logic					valid_i, 
	
	output	INSTRUCTION_ALU			instruction_o
);
	
	wire [31:0] instruction_raw;
	assign instruction_raw = instruction_i.instruction.instruction_raw;
	
	reg valid_d;
	reg [31:0] imm_I_type;
	reg [31:0] imm_U_type;
	reg [31:0] pc;
	reg [6:0] rd;
	reg [4:0] shamt;	
	reg [2:0] funct3;
	reg is_imm;
	reg is_shamt;
	reg is_sub_sra;
	reg is_lui;
	reg is_auipc;

	assign addra = instruction_i.rs1;
	assign addrb = instruction_i.rs2;
	
	always_ff@(posedge clk) begin
		valid_d <= valid_i;
		imm_I_type <= {{20{instruction_raw[31]}},instruction_raw[30:20]};
		imm_U_type <= {instruction_raw[31:12],12'b0};
		pc <= instruction_i.pc;
		rd <= instruction_i.rd;
		is_imm <= instruction_i.instruction.r_type.opcode == 7'b0010011;
		is_shamt <= (instruction_i.instruction.r_type.funct3 == SR | instruction_i.instruction.r_type.funct3 == SLL);
		is_sub_sra <= instruction_i.instruction.r_type.funct7 == 7'b0100000;
		funct3 <= instruction_i.instruction.r_type.funct3;
		shamt <= instruction_i.instruction.r_type.rs2;
		is_lui <= instruction_i.instruction.r_type.opcode == 7'b0110111;
		is_auipc <= instruction_i.instruction.r_type.opcode == 7'b0010111;
		if(reset)
			valid_d<='0;
	end
	
	always_ff@(posedge clk) begin
		instruction_o.lhs <= is_lui ? '0 : is_auipc ? pc : dataa;
		instruction_o.rhs <= (is_lui | is_auipc) ? imm_U_type : is_imm ? (is_shamt ? shamt : imm_I_type) : datab;
		instruction_o.rd <= rd;
		case({is_sub_sra,funct3})
			4'b0000: instruction_o.alu_func <= ADD	;
			4'b0001: instruction_o.alu_func <= SLL  ;
			4'b0010: instruction_o.alu_func <= SLTU ;
			4'b0011: instruction_o.alu_func <= SLT  ;
			4'b0100: instruction_o.alu_func <= XOR  ;
			4'b0101: instruction_o.alu_func <= SR   ;
			4'b0110: instruction_o.alu_func <= OR   ;
			4'b0111: instruction_o.alu_func <= AND  ;
			4'b1000: instruction_o.alu_func <= SUB  ;
			4'b1101: instruction_o.alu_func <= SRA  ;
			default: instruction_o.alu_func <= ALU_NOP	;
		endcase
		if (is_lui | is_auipc)
			instruction_o.alu_func <= ADD	;
		if (!valid_d)
			instruction_o.alu_func <= ALU_NOP	;
	end
		
endmodule
	