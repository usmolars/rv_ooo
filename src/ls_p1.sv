
`include "riscv_isa.sv"

module ls_p1(
	input wire clk,
	input wire reset,
	
	input	INSTRUCTION_LS	instruction,
	output	wire			instruction_ready,
	
	output reg		[31:0]	addr,
	output reg		[3:0]	we,
	output reg		[31:0]	data_write,
	input wire		[31:0]	data_read,
	input wire				data_valid,
	
	output 	RESULT			result,
	output	reg 			result_valid,
	input	wire			result_ready
);

	assign instruction_ready = result_ready;
	
	LS_FUNC [1:0] ls_func;
	reg [1:0][6:0] rd;
	
	always_ff@(posedge clk) begin
		addr <= instruction.addr;
		data_write <= instruction.data;
		case(instruction.ls_func)
			LS_SB	:	we <= 4'b0001;
			LS_SH	:	we <= 4'b0011;
			LS_SW	:	we <= 4'b1111;
			default	:	we <= 4'b0000;
		endcase
		ls_func <= {ls_func[0],instruction.ls_func};
		rd <= {rd[0],instruction.rd};
	end
	
	always_ff@(posedge clk) begin
		case(ls_func[1])
			LS_LB	: begin	result_valid <= 1;
							result.data <= {{24{data_read[7]}},data_read[7:0]};
							result.dest	<= rd[1];	end
			LS_LH   : begin result_valid <= 1;
							result.data <= {{16{data_read[15]}},data_read[15:0]};
							result.dest	<= rd[1];	end		
			LS_LW   : begin result_valid <= 1;
							result.data <= data_read;
							result.dest	<= rd[1];	end		
			LS_LBU  : begin result_valid <= 1;
							result.data <= {{24{1'b0}},data_read[7:0]};
							result.dest	<= rd[1];	end		
			LS_LHU  : begin result_valid <= 1;
							result.data <= {{16{1'b0}},data_read[7:0]};
							result.dest	<= rd[1];	end		
			default	: begin result_valid <= 0;	
							result.data <= '0;
							result.dest	<= '0;	end			
		endcase
	end
	
endmodule
