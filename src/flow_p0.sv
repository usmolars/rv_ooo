
`include "riscv_isa.sv"

module flow_p0(
	input wire clk,
	input wire reset,
	
	output	wire			[6:0]	addra,
	output	wire			[6:0]	addrb,
	input	wire			[31:0]	dataa,
	input	wire			[31:0]	datab,
	
	input	INSTRUCTION_SCHEDULED 	instruction_i,
	input	logic					valid_i, 
	
	output	INSTRUCTION_FLOW		instruction_o
);

	assign addra = instruction_i.rs1;
	assign addrb = instruction_i.rs2;

	reg is_jal;
	reg is_jalr;
	reg is_branch;
	reg [2:0] funct3;

	reg [31:0] pc;
	reg [31:0] pc_4;
	reg [6:0] rd;
	
	wire [31:0] instruction_raw;
	reg [31:0] imm_b;
	reg [31:0] imm_j;
	reg [31:0] imm_i;
	reg valid_d;
	
	assign instruction_raw = instruction_i.instruction.instruction_raw;

	always_ff@(posedge clk) begin
		valid_d<=valid_i;
		is_jal<=instruction_i.instruction.r_type.opcode == JAL;
		is_jalr<=instruction_i.instruction.r_type.opcode == JALR;
		is_branch<=instruction_i.instruction.r_type.opcode == BRANCH;
		pc<=instruction_i.pc;
		pc_4<=instruction_i.pc_4;
		imm_b <= {{20{instruction_raw[31]}},instruction_raw[11],instruction_raw[30:25],instruction_raw[10:7],1'b0};
		imm_j <= {{12{instruction_raw[31]}},instruction_raw[19:12],instruction_raw[20],instruction_raw[30:21],1'b0};
		imm_i <= {{20{instruction_raw[31]}},instruction_raw[30:20]};	
		funct3 <= instruction_i.instruction.r_type.funct3;
		rd <= instruction_i.rd;
	end
	
	always_ff@(posedge clk) begin
		case({valid_d,is_jal,is_jalr,is_branch})
			4'b1100:	instruction_o.flow_func <= FLOW_JAL;
			4'b1010:	instruction_o.flow_func <= FLOW_JALR;
			4'b1001:	instruction_o.flow_func <= FLOW_BRANCH;
			default:	instruction_o.flow_func <= FLOW_NOP;
		endcase
		case(funct3)
			3'b000	: instruction_o.branch_type<=BEQ 	;
			3'b001	: instruction_o.branch_type<=BNE	;
			3'b100	: instruction_o.branch_type<=BLT 	;
			3'b101	: instruction_o.branch_type<=BGE 	;
			3'b110	: instruction_o.branch_type<=BLTU	;
			3'b111	: instruction_o.branch_type<=BGEU	;
			default	: instruction_o.branch_type<=BINVALID	;
		endcase
		instruction_o.pc_lhs <= is_jalr ? dataa : pc;
		instruction_o.pc_rhs <= is_jal ? imm_j : ( is_jalr ? imm_i : imm_b);
		instruction_o.branch_lhs <= dataa;
		instruction_o.branch_rhs <= datab;		
		instruction_o.pc_4 <= pc_4;
		instruction_o.rd <= rd;
	end
	
	
endmodule
