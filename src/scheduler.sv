
`include "riscv_isa.sv"

module scheduler#(
	parameter SLOT = 4,
	parameter REGISTER_COUNT = 128
) (
	input wire clk,
	input wire reset, 
	
	input wire [REGISTER_COUNT-1:0] register_valid,
	
	input	INSTRUCTION_RENAMED	instruction_i,
	input	logic				valid_i,
	output	logic				ready_i, 
	
	output 	INSTRUCTION_SCHEDULED 	instruction_o,
	output 	logic 					valid_o,
	input	logic					ready_o
);


	INSTRUCTION_RENAMED [SLOT-1:0] pending_instruction;
	INSTRUCTION_RENAMED instruction_scheduled;
	
	reg instruction_valid;
	reg [$clog2(SLOT)-1:0] instruction_valid_index;
	
	reg [$clog2(SLOT)-1:0] fill;
	reg [SLOT-1:0] instruction_in_slot;
	reg [$clog2(SLOT)-1:0] empty_slot;

	wire [SLOT-1:0] instruction_dependancy_check;
	
	genvar i;
	generate 			
		for(i=0;i<SLOT;i=i+1) begin
			wire [6:0] rs1;
			wire [6:0] rs2;
			wire rs1_valid;
			wire rs2_valid;
			OPCODE_DEPENDANCY dependancy;		
			assign rs1 = pending_instruction[i].rs1;
			assign rs2 = pending_instruction[i].rs2;
			assign dependancy = pending_instruction[i].dependancy;
			assign rs1_valid = (register_valid[rs1]|(dependancy==DEPENDANCY_NO));
			assign rs2_valid = (register_valid[rs2]|(dependancy!=DEPENDANCY_RS2));
			assign instruction_dependancy_check[i] = rs1_valid & rs2_valid;	
		end
	endgenerate

	// find first empty slot
	int j;
	always_comb begin
		empty_slot<='0;
		for(j=SLOT-1;j>=0;j=j-1)
			if(!instruction_in_slot[j])
				empty_slot<=j;
	end

	// find first valid instruction
	int k;
	always_comb begin
		instruction_valid<=0;
		instruction_valid_index<=0;
		for(k=SLOT-1;k>=0;k=k-1)
			if(instruction_dependancy_check[k] & instruction_in_slot[k]) begin
				instruction_valid_index<=k;
				instruction_valid<=1;
			end
	end

/*
	always_comb begin
		empty_slot <= 0;
		if(!instruction_in_slot[3])
			empty_slot <= 3;
		if(!instruction_in_slot[2])
			empty_slot <= 2;
		if(!instruction_in_slot[1])
			empty_slot <= 1;
		if(!instruction_in_slot[0])
			empty_slot <= 0;
	end
	
	always_comb begin
		instruction_valid_index<=0;
		instruction_valid<=0;
		if(instruction_dependancy_check[3] & instruction_in_slot[3]) begin
			instruction_valid_index<=3;
			instruction_valid<=1;
		end
		if(instruction_dependancy_check[2] & instruction_in_slot[2]) begin
			instruction_valid_index<=2;
			instruction_valid<=1;
		end
		if(instruction_dependancy_check[1] & instruction_in_slot[1]) begin
			instruction_valid_index<=1;
			instruction_valid<=1;
		end
		if(instruction_dependancy_check[0] & instruction_in_slot[0]) begin
			instruction_valid_index<=0;
			instruction_valid<=1;
		end		
	end
*/	
	always_ff@(posedge clk) begin
		valid_o <= instruction_valid;
		if(instruction_valid & ready_o) begin
			instruction_scheduled <= pending_instruction[instruction_valid_index];
			instruction_in_slot[instruction_valid_index] <= 0;
			fill = fill - 1;
			ready_i <= 1;
		end
		if(valid_i & ready_i) begin
			pending_instruction[empty_slot] <= instruction_i;
			instruction_in_slot[empty_slot] <= 1;
			fill = fill + 1;
			if(fill==SLOT-1)
				ready_i <= 0;
		end
		if(reset) begin
			instruction_in_slot <= '0;
			fill = '0;
			ready_i <= 1;
		end
	end

	assign instruction_o.instruction	=	instruction_scheduled.instruction	;	
	assign instruction_o.pc				=   instruction_scheduled.pc			;
	assign instruction_o.pc_4			=   instruction_scheduled.pc_4		    ;
	assign instruction_o.rs1			=	instruction_scheduled.rs1		    ;
	assign instruction_o.rs2			=	instruction_scheduled.rs2		    ;
	assign instruction_o.rd				= 	instruction_scheduled.rd			;
	
endmodule
