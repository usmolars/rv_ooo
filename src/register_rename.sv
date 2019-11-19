
`include "riscv_isa.sv"

module register_rename#(
	parameter I_COUNT = 32,
	parameter O_COUNT = 128
) (
	input wire clk,
	input wire reset,
	
	input	INSTRUCTION_DECODED	instruction_i,
	input	logic				valid_i,
	output	logic				ready_i, 
	
	output 	INSTRUCTION_RENAMED instruction_o,
	output	logic				valid_o,
	input	logic				ready_o
);

	reg [I_COUNT-1:0][$clog2(O_COUNT)-1:0] reg_to_ptr;
	reg [$clog2(O_COUNT)-1:0] next_valid_ptr;
	wire free_ptr;
	assign free_ptr = 1;
	
	
	/* outpointer round robin --- TEMPORARY SOLUTION, MAY CAUSE BUGS
	*/
	
	always_ff@(posedge clk) begin
		if(ready_o & free_ptr & valid_i & (|instruction_i.instruction.r_type.rd))
 			next_valid_ptr <= next_valid_ptr + 1;
		if(reset | (&next_valid_ptr))
			next_valid_ptr<=1;
	end
	
	always_ff@(posedge clk) begin
		valid_o <= valid_i;
		if(ready_o & free_ptr) begin
			instruction_o.instruction	<=	instruction_i.instruction;	
			instruction_o.pc			<= 	instruction_i.pc;					
			instruction_o.pc_4		    <= 	instruction_i.pc_4;		    
			instruction_o.dependancy	<= 	instruction_i.dependancy;	
			instruction_o.unit		    <= 	instruction_i.unit;		    
			instruction_o.rs1			<= 	reg_to_ptr[instruction_i.instruction.r_type.rs1];			
			instruction_o.rs2	        <= 	reg_to_ptr[instruction_i.instruction.r_type.rs2];   
			instruction_o.rd			<=  instruction_i.instruction.r_type.rd == 0 ? '0 : next_valid_ptr;
			reg_to_ptr[instruction_i.instruction.r_type.rd] <= next_valid_ptr;
			reg_to_ptr[0]<='0;
		end
		if(reset)
			reg_to_ptr <= '0;
	end
	
//	DUMMY RENAME
//	always_ff@(posedge clk) begin
//		valid_o <= valid_i;
//		if(ready_o) begin
//			instruction_o.instruction	<=	instruction_i.instruction;	
//			instruction_o.pc			<= 	instruction_i.pc;					
//			instruction_o.pc_4		    <= 	instruction_i.pc_4;		    
//			instruction_o.dependancy	<= 	instruction_i.dependancy;	
//			instruction_o.unit		    <= 	instruction_i.unit;		    
//			instruction_o.rs1			<= 	{2'b00,instruction_i.instruction.r_type.rs1};			
//			instruction_o.rs2	        <= 	{2'b00,instruction_i.instruction.r_type.rs2};   
//			instruction_o.rd			<=  {2'b00,instruction_i.instruction.r_type.rd};
//		end
//	end

	assign ready_i = ready_o & free_ptr;

endmodule
