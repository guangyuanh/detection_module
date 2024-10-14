`timescale 1ns / 1ps

`define WIDTH_INST 13
`define WIDTH_DATA_0 14
`define WIDTH_DATA_1 17
`define DBG_MODE 9 //Vmax

module mlacc_top #(
parameter WORD_LEN = 32,
parameter FRAC_LEN = 15,
parameter NUM_TRACK = 4
)
(
    input in_clk,
    input in_reset,
    output ila_trig,
    output [255:0] monitored_signal
);
    wire [31:0] addr_x;
    wire [31:0] addr_y;
    wire [31:0] addr_z;
    wire [`WIDTH_INST-1:0] pc;
    wire track_active_0;
    wire track_active_1;
    wire track_active_2;
    wire track_active_3;
    wire mod_vadd;
    wire mod_vmul;
    wire mod_vact0;
    wire mod_mvmul;
    wire we;
    wire we0;
    wire we1;
    wire [127:0] inst;
    wire [127:0] X;
    wire [127:0] Y;
    //(* mark_debug = "true" *) wire [127:0] Z; 
    wire [127:0] Z;
    wire [127:0] rdata_0a;
    wire [127:0] rdata_1a;
    wire [127:0] rdata_0b; // Never used
    wire [127:0] rdata_1b; // Never used
    wire x_sel_mem0;
    wire y_sel_mem0;
	wire x_sel_mem3;
    wire y_sel_mem3;
    //wire [31:0] adder_tree_Z;
    wire [27:0]  mvmul_cur_row;
    wire [1:0]  mvmul_cur_word;
    wire mvmul_writeback;
    wire new_mvmul;
	wire new_vmax;
    wire reset_next;
    wire mod_vmax;
    //wire new_inst;
    wire mod_vdbg;
    wire mod_vslt;
    wire mod_vsub;
    wire mod_vact1;
    wire mod_vact2;
	wire mod_vsslt;
	wire mod_raddi;
	wire mod_ldreg;
	wire mod_streg;
	wire mod_loop;
	wire mod_vnorm;
	//wire mod_vload;
	//wire mod_vstore;
    //wire aluout_mod_mvmul;
    wire ila_trig;
    wire [`WIDTH_DATA_0-1:0] ram0_a_addr;
    wire [`WIDTH_DATA_0-1:0] ram0_b_addr;
    wire [`WIDTH_DATA_1-1:0] ram1_a_addr;
    wire [`WIDTH_DATA_1-1:0] ram1_b_addr;
    //wire [`WIDTH_INST-1:0] inst_addr;
	wire [3:0] aluout_funct;
	wire [127:0] alu0_regval;
    
    assign we0  = (addr_z[31])? 1'b0        : we;
    assign X    = (x_sel_mem3)? rdata_1a    : rdata_0a;
    assign we1  = (~addr_z[31])? 1'b0       : we;
    assign Y    = (x_sel_mem3)? rdata_0a    : rdata_1a;
    
	// x_sel and y_sel should always be different
    assign ram0_a_addr = (x_sel_mem0)? addr_y[`WIDTH_DATA_0-1+4:4]: addr_x[`WIDTH_DATA_0-1+4:4];
    assign ram0_b_addr = addr_z[`WIDTH_DATA_0-1+4:4];
    assign ram1_a_addr = (x_sel_mem0)? addr_x[`WIDTH_DATA_1-1+4:4]: addr_y[`WIDTH_DATA_1-1+4:4];
    assign ram1_b_addr = addr_z[`WIDTH_DATA_1-1+4:4];
    
    inst_mem inst_mem0 (
      .clka(in_clk),    // input wire clka
      .ena(1'b1),      // input wire ena
      .wea(1'b0),      // input wire [0 : 0] wea
      .addra(pc),  // input wire [10 : 0] addra
      .dina(128'b0),    // input wire [127 : 0] dina
      .douta(inst)  // output wire [127 : 0] douta
    );
    
    blk_mem_gen_2 data_ram0(.clka(in_clk),.ena(1'b1),.wea(1'b0),.addra(ram0_a_addr),.dina(128'h0),.douta(rdata_0a),
                            .clkb(in_clk),.enb(1'b1),.web(we0),.addrb(ram0_b_addr),.dinb(Z),.doutb(rdata_0b));
    blk_mem_gen_1 data_ram1(.clka(in_clk),.ena(1'b1),.wea(1'b0),.addra(ram1_a_addr),.dina(128'h0),.douta(rdata_1a),
                            .clkb(in_clk),.enb(1'b1),.web(we1),.addrb(ram1_b_addr),.dinb(Z),.doutb(rdata_1b));
    
    mlacc_ctrl #(WORD_LEN,FRAC_LEN,NUM_TRACK,`WIDTH_INST) ctrl(.in_inst(inst), .in_reset(in_reset), .in_clk(in_clk), .in_mem3_x_data(X),
					.out_we(we),
                    .out_x_sel_mem0(x_sel_mem0),.out_y_sel_mem0(y_sel_mem0),.out_x_sel_mem3(x_sel_mem3),.out_y_sel_mem3(y_sel_mem3), 
					.out_addr_x(addr_x),	.out_addr_y(addr_y),	.out_addr_z(addr_z),	.out_pc(pc),
                    .out_track_active_0(track_active_0),.out_track_active_1(track_active_1),
					.out_track_active_2(track_active_2),.out_track_active_3(track_active_3),
                    .out_mvmul_cur_row(mvmul_cur_row),	.out_mvmul_cur_word(mvmul_cur_word),.out_mvmul_writeback(mvmul_writeback),
					.out_new_mvmul(new_mvmul),	.out_new_vmax(new_vmax),	.out_new_vnorm(new_vnorm),	.out_reset_next(reset_next),
					.out_mod_vadd(mod_vadd),	.out_mod_vmul(mod_vmul),	.out_mod_vact0(mod_vact0),	.out_mod_mvmul(mod_mvmul),
                    .out_mod_vmax(mod_vmax),	//.out_new_inst(new_inst),	
					.out_mod_vdbg(mod_vdbg),	.out_mod_vslt(mod_vslt),
					.out_mod_vsub(mod_vsub),	.out_mod_vact1(mod_vact1),	.out_mod_vact2(mod_vact2),	.out_mod_vsslt(mod_vsslt),
					.out_mod_raddi(mod_raddi),	.out_mod_ldreg(mod_ldreg),	.out_mod_streg(mod_streg),	.out_mod_loop(mod_loop), 
					.out_mod_vnorm(mod_vnorm),
					//.out_mod_vload(mod_vload), .out_mod_vstore(mod_vstore),
					.out_aluout_funct(aluout_funct),
					.out_alu0_regval(alu0_regval)
                    );
    mlacc_datapath #(32,15,4) dp(.in_X(X),.in_Y(Y),.in_clk(in_clk),
								 .in_mod_vact(mod_vact0),.in_mod_vadd(mod_vadd),.in_mod_vmul(mod_vmul),.in_mod_mvmul(mod_mvmul),
                                 .in_mod_vmax(mod_vmax), 	//.in_new_inst(new_inst),		
								 .in_mod_vdbg(mod_vdbg), .in_mod_vslt(mod_vslt), .in_mod_vsub(mod_vsub), 
                                 .in_mod_vact1(mod_vact1), 	.in_mod_vact2(mod_vact2),	.in_mod_vsslt(mod_vsslt),
								 .in_mod_streg(mod_streg),	.in_mod_vnorm(mod_vnorm),
								 //.in_mod_vload(1'b0),	.in_mod_vstore(1'b0),
								 .in_track_active_0(track_active_0),.in_track_active_1(track_active_1),
								 .in_track_active_2(track_active_2),.in_track_active_3(track_active_3),
                                 .in_mvmul_cur_row(mvmul_cur_row),.in_mvmul_cur_word(mvmul_cur_word),.in_mvmul_writeback(mvmul_writeback),
								 .in_new_mvmul(new_mvmul),	.in_new_vmax(new_vmax),	.in_new_vnorm(new_vnorm),
								 .in_reset_next(reset_next),.in_alu0_regval(alu0_regval),
                                 .out_Z(Z)
                                 //,.out_adder_tree(adder_tree_Z)
                                 );
    
    wire [31:0] exec_cycle;
    wire [255:0] monitored_signal;
    assign monitored_signal[255:128] = Z;
    assign monitored_signal[127]      = we;
    assign monitored_signal[126:96]  = 31'h0;
    assign monitored_signal[95:64]   = addr_z;
    assign monitored_signal[63:32]   = 32'h0;
    assign monitored_signal[31:0]    = exec_cycle[31:0]; 
    
    assign ila_trig = we;
                                     
    exec_counter ec(.in_clk(in_clk),.in_reset(in_reset),.out_cycle(exec_cycle));
endmodule
