
`include "riscv_isa.sv"

module write_back_tb();

reg clk;
reg reset;

RESULT 	alu_result			;
reg		alu_result_valid	;
RESULT 	ls_result			;
reg		ls_result_valid		;
RESULT 	flow_result			;
reg		flow_result_valid	;


RESULT	[2:0]	result			;
wire	[2:0]	result_valid	;
wire 	[2:0] 	result_ready	;

wire [31:0] write_data;
wire [6:0] write_addr;

initial begin
	clk<=0;
	forever	#5 clk<=~clk;
end

initial begin
reset<=1;
alu_result<='0;
alu_result_valid<=0;
ls_result<='0;
ls_result_valid<=0;
flow_result<='0;
flow_result_valid<=0;
#20
@(posedge clk) reset<=0;
@(posedge clk)
alu_result.dest <= 1;
alu_result_valid <= 1;
ls_result.dest <= 2;
ls_result_valid <= 1;
flow_result.dest <= 3;
flow_result_valid <= 1;
@(posedge clk)
alu_result.dest <= 4;
ls_result.dest <= 5;
flow_result.dest <= 6;
@(posedge clk)
flow_result_valid <= 0;
alu_result_valid <= 0;
ls_result_valid <= 0;
#200
@(posedge clk)
alu_result_valid <= 1;
flow_result_valid <= 1;
alu_result.dest <= 7;
flow_result.dest <= 8;
@(posedge clk)
alu_result_valid <= 1;
alu_result.dest <= 9;
flow_result.dest <= 10;
@(posedge clk)
alu_result_valid <= 1;
alu_result.dest <= 11;
flow_result.dest <= 12;
@(posedge clk)
flow_result_valid <= 0;
alu_result.dest <= 13;
@(posedge clk)
alu_result.dest <= 14;
@(posedge clk)
alu_result_valid <= 0;
end

fifo#(
.DEPTH(4),
.WIDTH($bits(alu_result))
) alu_result_buffer (
.clk			(clk				),
.reset          (reset				),
.valid_i        (alu_result_valid	),
.ready_i        (					),
.data_i         (alu_result			),
.valid_o        (result_valid[0]	),
.ready_o        (result_ready[0]	),
.data_o         (result[0]			));

fifo#(
.DEPTH(4),
.WIDTH($bits(ls_result))
) ls_result_buffer (
.clk			(clk				),
.reset          (reset				),
.valid_i        (ls_result_valid	),
.ready_i        (					),
.data_i         (ls_result			),
.valid_o        (result_valid[1]	),
.ready_o        (result_ready[1]	),
.data_o         (result[1]			));

fifo#(
.DEPTH(4),
.WIDTH($bits(flow_result))
) flow_result_buffer (
.clk			(clk				),
.reset          (reset				),
.valid_i        (flow_result_valid	),
.ready_i        (					),
.data_i         (flow_result		),
.valid_o        (result_valid[2]	),
.ready_o        (result_ready[2]	),
.data_o         (result[2]			));


write_back#(.N(3)) write_back (
.clk			(clk			),
.reset          (reset          ),
.result         (result         ),
.result_valid   (result_valid   ),
.result_ready   (result_ready   ),
.write_addr     (write_addr     ),
.write_data     (write_data     ));

regbank#(
.DWIDTH(32),
.AWIDTH(7),
.READ_PORT(2)
) regbank (
.clk				(clk					),
.reset              (reset                  ),
.write_data         (write_data             ),
.write_address      (write_addr	         	),
.read_addr          ('0              		),
.read_data          (              			),
.invalidate_register('0    					),
.register_valid     (         				));

endmodule
