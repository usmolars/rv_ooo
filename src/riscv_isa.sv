`ifndef RISCV_ISA
   `define RISCV_ISA

typedef enum logic [6:0] {
 
	LUI		=	7'b0110111,
	AUIPC	=	7'b0010111,
	JAL	    =	7'b1101111,
	JALR 	=	7'b1100111,
	BRANCH	=	7'b1100011,
	LOAD	=	7'b0000011,
	STORE	=	7'b0100011,
	ALUI	=	7'b0010011,
	ALU	    =	7'b0110011,
	FENCE	=	7'b0001111,
	PRIVI	=	7'b1110011

}	OPCODE;

typedef enum logic [2:0] {
	
	UNIT_FLOW 			= 1,
	UNIT_ALU_INT 		= 2,
	UNIT_LOAD_STORE		= 4,
	UNIT_NOT_IMPLEMENTED = 7

} OPCODE_UNIT;

typedef enum logic [1:0] {

	DEPENDANCY_NO		=	2'b00,
	DEPENDANCY_RS1		=	2'b01,
	DEPENDANCY_RS2		=   2'b11

} OPCODE_DEPENDANCY;

typedef struct packed {

	logic	[6:0]	funct7	;
	logic	[4:0]	rs2     ;
	logic	[4:0]	rs1     ;
	logic	[2:0]	funct3  ;
	logic	[4:0]	rd      ;
	OPCODE			opcode  ;
	
} R_TYPE_INSTRUCTION;

typedef struct packed {

	logic	[11:0]	imm     ;
	logic	[4:0]	rs1     ;
	logic	[2:0]	funct3  ;
	logic	[4:0]	rd      ;
	OPCODE			opcode  ;
	
} I_TYPE_INSTRUCTION;

typedef struct packed {

	logic	[6:0]	imm12   ;
	logic	[4:0]	rs1     ;
	logic	[4:0]	rs2		;
	logic	[2:0]	funct3  ;
	logic	[4:0]	imm5    ;
	OPCODE			opcode  ;
	
} S_TYPE_INSTRUCTION;

typedef struct packed {

	logic	[6:0]	imm12   ;
	logic	[4:0]	rs1     ;
	logic	[4:0]	rs2		;
	logic	[2:0]	funct3  ;
	logic	[4:0]	imm5    ;
	OPCODE			opcode  ;
	
} B_TYPE_INSTRUCTION;

typedef struct packed {

	logic	[19:0]	imm   	;
	logic	[4:0]	rd    	;
	OPCODE			opcode	;
	
} U_TYPE_INSTRUCTION;

typedef struct packed {

	logic	[19:0]	imm   	;
	logic	[4:0]	rd    	;
	OPCODE			opcode  ;
	
} J_TYPE_INSTRUCTION;

typedef union packed {
	R_TYPE_INSTRUCTION 	r_type;
	I_TYPE_INSTRUCTION 	i_type;
	S_TYPE_INSTRUCTION 	s_type;
	B_TYPE_INSTRUCTION 	b_type;
	U_TYPE_INSTRUCTION 	u_type;
	J_TYPE_INSTRUCTION 	j_type;
	logic 	[31:0]		instruction_raw;
} INSTRUCTION;

typedef struct packed {
	INSTRUCTION			instruction	;
	logic	[31:0]		pc			;
	logic	[31:0]		pc_4		;
} INSTRUCTION_FECHED;

typedef struct packed {
	INSTRUCTION			instruction	;
	logic	[31:0]		pc			;
	logic	[31:0]		pc_4		;
	OPCODE_DEPENDANCY	dependancy	;
	OPCODE_UNIT			unit		;
} INSTRUCTION_DECODED;

typedef struct packed {
	INSTRUCTION			instruction	;
	logic	[31:0]		pc			;
	logic	[31:0]		pc_4		;
	OPCODE_DEPENDANCY	dependancy	;
	OPCODE_UNIT			unit		;
	logic	[6:0]		rs1			;
	logic	[6:0]		rs2			;
	logic	[6:0]		rd			;
} INSTRUCTION_RENAMED;


typedef struct packed {
	INSTRUCTION			instruction	;
	logic	[31:0]		pc			;
	logic	[31:0]		pc_4		;
	logic	[6:0]		rs1			;
	logic	[6:0]		rs2			;
	logic	[6:0]		rd			;
} INSTRUCTION_SCHEDULED;

typedef enum logic [3:0] {	
	ADD		=	4'b0000,
	SLL     =	4'b0001,
	SLT     =	4'b0010,
	SLTU    =	4'b0011,
	XOR     =	4'b0100,
	SR 	    =	4'b0101,
	OR      =	4'b0110,
	AND     =	4'b0111,
	SUB		=	4'b1000,
	SRA		=	4'b1101,
	ALU_NOP	= 	4'b1111
}	ALU_FUNC;

typedef struct packed {
	ALU_FUNC		alu_func;
	logic	[31:0]	lhs;
	logic	[31:0]	rhs;
	logic	[6:0]	rd;
} INSTRUCTION_ALU;

typedef enum logic [3:0] {
	LS_LB	= 4'b1000,
	LS_LH   = 4'b1001,
	LS_LW   = 4'b1010,
	LS_LBU  = 4'b1011,
	LS_LHU  = 4'b1100,
	LS_SB   = 4'b1101,
	LS_SH   = 4'b1110,
	LS_SW   = 4'b1111,
	LS_NOP 	= 4'b0000
} LS_FUNC;

typedef struct packed {
	LS_FUNC			ls_func;
	logic	[31:0]	addr;
	logic	[31:0]	data;
	logic 	[6:0]	rd;
} INSTRUCTION_LS;

typedef enum logic [1:0] {
	FLOW_JAL	=	2'b01,
	FLOW_JALR   =	2'b10,
	FLOW_BRANCH = 	2'b11,
	FLOW_NOP	=	2'b00
} FLOW_FUNC;

typedef enum logic [2:0] {
	
	BEQ 	=	3'b000,
	BNE		=	3'b001,
	BLT     =	3'b100,
	BGE     =	3'b101,
	BLTU    =	3'b110,
	BGEU    =	3'b111,
	BINVALID=	3'b011
	
} BRANCH_TYPE;

typedef struct packed {
	FLOW_FUNC		flow_func;
	BRANCH_TYPE		branch_type;
	logic	[31:0]	pc_lhs;
	logic	[31:0]	pc_rhs;
	logic	[31:0]	branch_lhs;
	logic	[31:0]	branch_rhs;
	logic	[31:0]	pc_4;
	logic	[6:0]	rd;
} INSTRUCTION_FLOW;

typedef struct packed {
	logic	[31:0]	data;
	logic	[6:0]	dest;
} RESULT;



`endif  
