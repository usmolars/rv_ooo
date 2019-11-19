
`include "riscv_isa.sv"

module ls_p0(
	input wire clk,
	input wire reset,
	
	output	wire			[6:0]	addra,
	output	wire			[6:0]	addrb,
	input	wire			[31:0]	dataa,
	input	wire			[31:0]	datab,
	
	input	INSTRUCTION_SCHEDULED 	instruction_i,
	input	logic					valid_i, 
	output	wire					ready_i,
	
	output	INSTRUCTION_LS			instruction_o,
	input	wire					ready_o
);

	assign addra = instruction_i.rs1;
	assign addrb = instruction_i.rs2;
	assign ready_i = ready_o;
	
	reg valid_d;
	reg [2:0] funct3;
	reg [6:0] rd;
	
	wire [31:0] instruction_raw;
	reg [31:0] imm_s;
	reg [31:0] imm_i;
	reg is_load;
	reg is_store;

	assign instruction_raw = instruction_i.instruction.instruction_raw;
		
	always_ff@(posedge clk) begin
		valid_d <= valid_i;
		imm_i <= {{20{instruction_raw[31]}},instruction_raw[30:20]};
		imm_s <= {{20{instruction_raw[31]}},instruction_raw[30:25],instruction_raw[11:7]};
		is_load <= instruction_i.instruction.r_type.opcode == LOAD;
		is_store <= instruction_i.instruction.r_type.opcode == STORE;
		funct3 <= instruction_i.instruction.r_type.funct3;
		rd <= instruction_i.rd;
	end
	
	always_ff@(posedge clk) begin
		case({valid_d,is_load,is_store,funct3})
			6'b110000	:	instruction_o.ls_func <= LS_LB	;
			6'b110001	:	instruction_o.ls_func <= LS_LH  ;
			6'b110010	:	instruction_o.ls_func <= LS_LW  ;
			6'b110100	:	instruction_o.ls_func <= LS_LBU ;
			6'b110101	:	instruction_o.ls_func <= LS_LHU ;
			6'b101000	:	instruction_o.ls_func <= LS_SB  ;
			6'b101001	:	instruction_o.ls_func <= LS_SH  ;
			6'b101010	:	instruction_o.ls_func <= LS_SW  ;
			default		:	instruction_o.ls_func <= LS_NOP ;
		endcase
		instruction_o.addr <= is_load ? (dataa + imm_i) : (dataa + imm_s); 
		instruction_o.data <= datab;
		instruction_o.rd <= rd;
	end
	
endmodule
