`timescale 1ns / 1ps

`define ONE_ENCOD	32'h0000_8000
`define MIN_32 		32'hffff_ffff
`define SPAD_ADDR_BITS 4

module mlacc_datapath #(
parameter WORD_LEN = 32,
parameter FRAC_LEN = 15,
parameter NUM_TRACK = 4
)
(
    input [WORD_LEN*NUM_TRACK-1:0] in_X,
    input [WORD_LEN*NUM_TRACK-1:0] in_Y,
    input in_clk,
    input in_track_active_0,
    input in_track_active_1,
    input in_track_active_2,
    input in_track_active_3,
    input [27:0] in_mvmul_cur_row,
    input [1:0] in_mvmul_cur_word,
    input in_mvmul_writeback,
    input in_new_mvmul,
	input in_new_vmax,
	input in_new_vnorm,
    input in_reset_next,
    //input in_new_inst,
	input in_mod_vact,
    input in_mod_vadd,
    input in_mod_vmul,
    input in_mod_mvmul,
    input in_mod_vdbg,
    input in_mod_vslt,
    input in_mod_vsub,
    input in_mod_vact1,
    input in_mod_vact2,
	input in_mod_vmax,
	input in_mod_vsslt,
	input in_mod_streg,
	//input in_mod_vload,
	//input in_mod_vstore,
	input in_mod_vnorm,
	input [127:0] in_alu0_regval,
    output [WORD_LEN*NUM_TRACK-1:0] out_Z
    //output [WORD_LEN-1:0] out_adder_tree
);

    reg alu0_mod_vact;
    reg alu0_mod_vadd;
    reg alu0_mod_vmul;
    reg alu0_mod_mvmul;
    reg [27:0] alu0_mvmul_cur_row;
    reg [1:0] alu0_mvmul_cur_word;
    reg alu0_mvmul_writeback;
    reg alu0_new_mvmul;
	reg alu0_new_vmax;
	reg alu0_new_vnorm;
    reg alu0_mod_vmax;
    reg alu0_mod_vdbg;
    reg alu0_mod_vslt;
    reg alu0_mod_vsub;
    reg alu0_mod_vact1;
    reg alu0_mod_vact2;
    reg alu0_reset_next;
	reg alu0_mod_vsslt;
	//reg alu0_mod_vload;
	//reg alu0_mod_vstore;
	reg alu0_mod_streg;
	reg alu0_mod_vnorm;
    
    reg alu0_track_active_0;
    reg alu0_track_active_1;
    reg alu0_track_active_2;
    reg alu0_track_active_3;

    reg [WORD_LEN-1:0] alu0_X0;
    reg [WORD_LEN-1:0] alu0_Y0;
    reg [WORD_LEN-1:0] alu0_X1;
    reg [WORD_LEN-1:0] alu0_Y1;
    reg [WORD_LEN-1:0] alu0_X2;
    reg [WORD_LEN-1:0] alu0_Y2;
    reg [WORD_LEN-1:0] alu0_X3;
    reg [WORD_LEN-1:0] alu0_Y3;
    
    always @(posedge in_clk) begin
        alu0_X0 <= in_X[127:96];
        alu0_X1 <= in_X[95:64];
        alu0_X2 <= in_X[63:32];
        alu0_X3 <= in_X[31:0];
        alu0_Y0 <= in_Y[127:96];
        alu0_Y1 <= in_Y[95:64];
        alu0_Y2 <= in_Y[63:32];
        alu0_Y3 <= in_Y[31:0];
        
        alu0_mod_vact    <= in_mod_vact;
        alu0_mod_vadd    <= in_mod_vadd;
        alu0_mod_vmul    <= in_mod_vmul;
        alu0_mod_mvmul   <= in_mod_mvmul;
        alu0_mvmul_cur_row   <= in_mvmul_cur_row;
        alu0_mvmul_cur_word  <= in_mvmul_cur_word;
        alu0_mvmul_writeback <= in_mvmul_writeback;
        alu0_mod_vmax   <= in_mod_vmax;
        alu0_new_mvmul  <= in_new_mvmul;
		alu0_new_vmax   <= in_new_vmax;
		alu0_new_vnorm	<= in_new_vnorm;
        alu0_mod_vdbg   <= in_mod_vdbg;
        alu0_mod_vslt   <= in_mod_vslt;
        alu0_mod_vsub   <= in_mod_vsub;
        alu0_mod_vact1  <= in_mod_vact1;
        alu0_mod_vact2  <= in_mod_vact2;
		alu0_mod_vsslt	<= in_mod_vsslt;
		//alu0_mod_vload	<= in_mod_vload;
		//alu0_mod_vstore	<= in_mod_vstore;
		alu0_mod_streg	<= in_mod_streg;
		alu0_mod_vnorm	<= in_mod_vnorm;
        
        alu0_track_active_0 <= in_track_active_0;
        alu0_track_active_1 <= in_track_active_1;
        alu0_track_active_2 <= in_track_active_2;
        alu0_track_active_3 <= in_track_active_3;
        
        alu0_reset_next <= in_reset_next;
    end
    
    wire [WORD_LEN-1:0] act0_slope0;
    wire [WORD_LEN-1:0] act0_slope1;
    wire [WORD_LEN-1:0] act0_slope2;
    wire [WORD_LEN-1:0] act0_slope3;
    wire [WORD_LEN-1:0] act0_intercept0;
    wire [WORD_LEN-1:0] act0_intercept1;
    wire [WORD_LEN-1:0] act0_intercept2;
    wire [WORD_LEN-1:0] act0_intercept3;
    
    wire [WORD_LEN-1:0] act1_slope0;
    wire [WORD_LEN-1:0] act1_slope1;
    wire [WORD_LEN-1:0] act1_slope2;
    wire [WORD_LEN-1:0] act1_slope3;
    wire [WORD_LEN-1:0] act1_intercept0;
    wire [WORD_LEN-1:0] act1_intercept1;
    wire [WORD_LEN-1:0] act1_intercept2;
    wire [WORD_LEN-1:0] act1_intercept3;
        
    wire [WORD_LEN-1:0] act2_slope0;
    wire [WORD_LEN-1:0] act2_slope1;
    wire [WORD_LEN-1:0] act2_slope2;
    wire [WORD_LEN-1:0] act2_slope3;
    wire [WORD_LEN-1:0] act2_intercept0;
    wire [WORD_LEN-1:0] act2_intercept1;
    wire [WORD_LEN-1:0] act2_intercept2;
    wire [WORD_LEN-1:0] act2_intercept3;
    
    sigmoid_rom sig0(.in_fixedp(alu0_X0), .out_slope(act0_slope0), .out_intercept(act0_intercept0));
    sigmoid_rom sig1(.in_fixedp(alu0_X1), .out_slope(act0_slope1), .out_intercept(act0_intercept1));
    sigmoid_rom sig2(.in_fixedp(alu0_X2), .out_slope(act0_slope2), .out_intercept(act0_intercept2));
    sigmoid_rom sig3(.in_fixedp(alu0_X3), .out_slope(act0_slope3), .out_intercept(act0_intercept3));
    
    tanh_rom tanh0(.in_fixedp(alu0_X0), .out_slope(act1_slope0), .out_intercept(act1_intercept0));
    tanh_rom tanh1(.in_fixedp(alu0_X1), .out_slope(act1_slope1), .out_intercept(act1_intercept1));
    tanh_rom tanh2(.in_fixedp(alu0_X2), .out_slope(act1_slope2), .out_intercept(act1_intercept2));
    tanh_rom tanh3(.in_fixedp(alu0_X3), .out_slope(act1_slope3), .out_intercept(act1_intercept3));
    
    exp_lut exp0(.in_fixedp(alu0_X0), .out_slope(act2_slope0), .out_intercept(act2_intercept0));
    exp_lut exp1(.in_fixedp(alu0_X1), .out_slope(act2_slope1), .out_intercept(act2_intercept1));
    exp_lut exp2(.in_fixedp(alu0_X2), .out_slope(act2_slope2), .out_intercept(act2_intercept2));
    exp_lut exp3(.in_fixedp(alu0_X3), .out_slope(act2_slope3), .out_intercept(act2_intercept3));
    
    reg alu1_mod_vact;
    reg alu1_mod_vadd;
    reg alu1_mod_vmul;
    reg alu1_mod_mvmul;
    reg [27:0] alu1_mvmul_cur_row;
    reg [1:0] alu1_mvmul_cur_word;
    reg alu1_mvmul_writeback;
    reg alu1_new_mvmul;
	reg alu1_new_vmax;
	reg alu1_new_vnorm;
    reg alu1_mod_vmax;
    reg alu1_mod_vdbg;
    reg alu1_mod_vslt;
    reg alu1_mod_vsub;
    reg alu1_reset_next;
	reg alu1_mod_vsslt;
	reg alu1_mod_vdatamv;
	reg alu1_mod_vnorm;
    
    reg alu1_track_active_0;
    reg alu1_track_active_1;
    reg alu1_track_active_2;
    reg alu1_track_active_3;

    reg [WORD_LEN-1:0] alu1_X0;
    reg [WORD_LEN-1:0] alu1_Y0;
    reg [WORD_LEN-1:0] alu1_X1;
    reg [WORD_LEN-1:0] alu1_Y1;
    reg [WORD_LEN-1:0] alu1_X2;
    reg [WORD_LEN-1:0] alu1_Y2;
    reg [WORD_LEN-1:0] alu1_X3;
    reg [WORD_LEN-1:0] alu1_Y3;
    
    reg [WORD_LEN-1:0] alu1_intercept0;
    reg [WORD_LEN-1:0] alu1_intercept1;
    reg [WORD_LEN-1:0] alu1_intercept2;
    reg [WORD_LEN-1:0] alu1_intercept3;
    
    always @(posedge in_clk) begin
        alu1_X0 <= (alu0_mod_streg)? in_alu0_regval[WORD_LEN*NUM_TRACK-1: WORD_LEN*(NUM_TRACK-1)]:
					(alu0_track_active_0)?alu0_X0:32'd0;
        alu1_X1 <= (alu0_mod_streg)? in_alu0_regval[WORD_LEN*3-1: WORD_LEN*2]:
					(alu0_track_active_1)?alu0_X1:32'd0;
        alu1_X2 <= (alu0_mod_streg)? in_alu0_regval[WORD_LEN*2-1: WORD_LEN*1]:
					(alu0_track_active_2)?alu0_X2:32'd0;
        alu1_X3 <= (alu0_mod_streg)? in_alu0_regval[WORD_LEN*1-1: WORD_LEN*0]:
					(alu0_track_active_3)?alu0_X3:32'd0;
        alu1_Y0 <= (~alu0_track_active_0)?32'd0:
                    (alu0_mod_vact)?act0_slope0:
                    (alu0_mod_vact1)?act1_slope0:
                    (alu0_mod_vact2)?act2_slope0:
					(alu0_mod_vnorm)?alu0_X0: alu0_Y0;
        alu1_Y1 <= (~alu0_track_active_1)?32'd0:
                    (alu0_mod_vact)?act0_slope1:
                    (alu0_mod_vact1)?act1_slope1:
                    (alu0_mod_vact2)?act2_slope1:
					(alu0_mod_vsslt)?alu0_Y0: 
					(alu0_mod_vnorm)?alu0_X1: alu0_Y1;
        alu1_Y2 <= (~alu0_track_active_2)?32'd0:
                    (alu0_mod_vact)?act0_slope2:
                    (alu0_mod_vact1)?act1_slope2:
                    (alu0_mod_vact2)?act2_slope2:
					(alu0_mod_vsslt)?alu0_Y0: 
					(alu0_mod_vnorm)?alu0_X2: alu0_Y2;
        alu1_Y3 <= (~alu0_track_active_3)?32'd0:
                    (alu0_mod_vact)?act0_slope3:
                    (alu0_mod_vact1)?act1_slope3:
                    (alu0_mod_vact2)?act2_slope3:
					(alu0_mod_vsslt)?alu0_Y0: 
					(alu0_mod_vnorm)?alu0_X3: alu0_Y3;
        alu1_intercept0 <= (~alu0_track_active_0)?32'd0:
                    (alu0_mod_vact)?act0_intercept0:
                    (alu0_mod_vact1)?act1_intercept0:
                    (alu0_mod_vact2)?act2_intercept0: 32'd0;
        alu1_intercept1 <= (~alu0_track_active_1)?32'd0: 
                    (alu0_mod_vact)?act0_intercept1:
                    (alu0_mod_vact1)?act1_intercept1:
                    (alu0_mod_vact2)?act2_intercept1: 32'd0;
        alu1_intercept2 <= (~alu0_track_active_2)?32'd0: 
                    (alu0_mod_vact)?act0_intercept2:
                    (alu0_mod_vact1)?act1_intercept2:
                    (alu0_mod_vact2)?act2_intercept2: 32'd0;
        alu1_intercept3 <= (~alu0_track_active_3)?32'd0: 
                    (alu0_mod_vact)?act0_intercept3:
                    (alu0_mod_vact1)?act1_intercept3:
                    (alu0_mod_vact2)?act2_intercept3: 32'd0;
        
        alu1_mod_vact    <= alu0_mod_vact || alu0_mod_vact1 || alu0_mod_vact2;
        alu1_mod_vadd    <= alu0_mod_vadd;
        alu1_mod_vmul    <= alu0_mod_vmul;
        alu1_mod_mvmul   <= alu0_mod_mvmul;
        alu1_mvmul_cur_row   <= alu0_mvmul_cur_row;
        alu1_mvmul_cur_word  <= alu0_mvmul_cur_word;
        alu1_mvmul_writeback <= alu0_mvmul_writeback;
        alu1_mod_vmax    <= alu0_mod_vmax;
        alu1_new_mvmul   <= alu0_new_mvmul;
		alu1_new_vmax    <= alu0_new_vmax;
		alu1_new_vnorm   <= alu0_new_vnorm;
        alu1_mod_vdbg    <= alu0_mod_vdbg;
        alu1_mod_vslt    <= alu0_mod_vslt;
        alu1_mod_vsub    <= alu0_mod_vsub;
		alu1_mod_vnorm	 <= alu0_mod_vnorm;
        //alu1_mod_vact1    <= alu0_mod_vact1;
        //alu1_mod_vact2    <= alu0_mod_vact2;
		alu1_mod_vsslt	<= alu0_mod_vsslt;
		//alu1_mod_vdatamv<= alu0_mod_vload || alu0_mod_vstore;
		alu1_mod_vdatamv<= alu0_mod_streg;
        
        alu1_track_active_0 <= alu0_track_active_0;
        alu1_track_active_1 <= alu0_track_active_1;
        alu1_track_active_2 <= alu0_track_active_2;
        alu1_track_active_3 <= alu0_track_active_3;
        
        alu1_reset_next  <= alu0_reset_next;
    end
    
    wire [WORD_LEN-1:0] mulin_Y0;
    wire [WORD_LEN-1:0] mulin_Y1;
    wire [WORD_LEN-1:0] mulin_Y2;
    wire [WORD_LEN-1:0] mulin_Y3;
    
    wire [WORD_LEN-1:0] product0;
    wire [WORD_LEN-1:0] product1;
    wire [WORD_LEN-1:0] product2;
    wire [WORD_LEN-1:0] product3;
    
    assign mulin_Y0 = alu1_Y0;
    assign mulin_Y1 = alu1_Y1;
    assign mulin_Y2 = alu1_Y2;
    assign mulin_Y3 = alu1_Y3;
    
    fixedp_mul #(FRAC_LEN, WORD_LEN) multiplier0 (.a(alu1_X0), .b(mulin_Y0), .c(product0));
    fixedp_mul #(FRAC_LEN, WORD_LEN) multiplier1 (.a(alu1_X1), .b(mulin_Y1), .c(product1));
    fixedp_mul #(FRAC_LEN, WORD_LEN) multiplier2 (.a(alu1_X2), .b(mulin_Y2), .c(product2));
    fixedp_mul #(FRAC_LEN, WORD_LEN) multiplier3 (.a(alu1_X3), .b(mulin_Y3), .c(product3));
    
	wire [WORD_LEN-1:0] X0_abs;
	wire [WORD_LEN-1:0] X1_abs;
    wire [WORD_LEN-1:0] minus_X2_abs;
    wire [WORD_LEN-1:0] minus_X3_abs;
	wire [WORD_LEN-1:0] minus_Y0;
    wire [WORD_LEN-1:0] minus_Y1;
    wire [WORD_LEN-1:0] minus_Y2;
    wire [WORD_LEN-1:0] minus_Y3;
	wire [WORD_LEN-1:0] alu2_X0_next;
	wire [WORD_LEN-1:0] alu2_X1_next;
	wire [WORD_LEN-1:0] alu2_X2_next;
	wire [WORD_LEN-1:0] alu2_X3_next;
	wire [WORD_LEN-1:0] alu2_Y0_next;
	wire [WORD_LEN-1:0] alu2_Y1_next;
	wire [WORD_LEN-1:0] alu2_Y2_next;
	wire [WORD_LEN-1:0] alu2_Y3_next;
	
	assign X0_abs = {1'b0, alu1_X0[WORD_LEN-2:0]};
	assign X1_abs = {1'b0, alu1_X1[WORD_LEN-2:0]};
	assign minus_X2_abs = {1'b1, alu1_X2[WORD_LEN-2:0]};
	assign minus_X3_abs = {1'b1, alu1_X3[WORD_LEN-2:0]};
	assign minus_Y0 = {~alu1_Y0[WORD_LEN-1], alu1_Y0[WORD_LEN-2:0]};
    assign minus_Y1 = {~alu1_Y1[WORD_LEN-1], alu1_Y1[WORD_LEN-2:0]};
    assign minus_Y2 = {~alu1_Y2[WORD_LEN-1], alu1_Y2[WORD_LEN-2:0]};
    assign minus_Y3 = {~alu1_Y3[WORD_LEN-1], alu1_Y3[WORD_LEN-2:0]};
	
	assign alu2_X0_next = (alu1_mod_vadd || alu1_mod_vdbg || alu1_mod_vslt || 
							alu1_mod_vsub || alu1_mod_vsslt || alu1_mod_vdatamv)? alu1_X0:
							(alu1_mod_vmax)? X0_abs: product0;
	assign alu2_X1_next = (alu1_mod_vadd || alu1_mod_vdbg || alu1_mod_vslt || 
							alu1_mod_vsub || alu1_mod_vsslt || alu1_mod_vdatamv)? alu1_X1:
							(alu1_mod_vmax)? X1_abs: product1;
	assign alu2_X2_next = (alu1_mod_vadd || alu1_mod_vdbg || alu1_mod_vslt || 
							alu1_mod_vsub || alu1_mod_vsslt || alu1_mod_vdatamv)? alu1_X2:
							product2;
	assign alu2_X3_next = (alu1_mod_vadd || alu1_mod_vdbg || alu1_mod_vslt || 
							alu1_mod_vsub || alu1_mod_vsslt || alu1_mod_vdatamv)? alu1_X3:
							product3;
	assign alu2_Y0_next = (alu1_mod_vslt || alu1_mod_vsub || alu1_mod_vsslt)? minus_Y0:
							(alu1_mod_vact)? alu1_intercept0:
							(alu1_mod_mvmul || alu1_mod_vnorm)? product2:
							(alu1_mod_vmax)? minus_X2_abs: alu1_Y0;
	assign alu2_Y1_next = (alu1_mod_vslt || alu1_mod_vsub || alu1_mod_vsslt)? minus_Y1:
							(alu1_mod_vact)? alu1_intercept1:
							(alu1_mod_mvmul || alu1_mod_vnorm)? product3:
							(alu1_mod_vmax)? minus_X3_abs: alu1_Y1;
	assign alu2_Y2_next = (alu1_mod_vslt || alu1_mod_vsub || alu1_mod_vsslt)? minus_Y2:
							(alu1_mod_vact)? alu1_intercept2: alu1_Y2;
	assign alu2_Y3_next = (alu1_mod_vslt || alu1_mod_vsub || alu1_mod_vsslt)? minus_Y3:
							(alu1_mod_vact)? alu1_intercept3: alu1_Y3;
	
    reg alu2_mod_vact;
    reg alu2_mod_vadd;
    reg alu2_mod_vmul;
    reg alu2_mod_mvmul;
    reg [27:0]  alu2_mvmul_cur_row;
    reg [1:0]   alu2_mvmul_cur_word;
    reg alu2_mvmul_writeback;
    reg alu2_new_mvmul;
	reg alu2_new_vmax;
	reg alu2_new_vnorm;
    reg alu2_mod_vmax;
	reg alu2_mod_vmax2;
    reg alu2_mod_vdbg;
    reg alu2_mod_vslt;
    reg alu2_mod_vsub;
	reg alu2_mod_vsub2;
    //reg alu2_mod_vact1;
    //reg alu2_mod_vact2;
    reg alu2_reset_next;
	reg alu2_mod_vsslt;
	reg alu2_mod_vsslt2;
	reg alu2_mod_vdatamv;
	reg alu2_mod_vnorm;
    
    reg alu2_track_active_0;
    reg alu2_track_active_1;
    reg alu2_track_active_2;
    reg alu2_track_active_3;

    reg [WORD_LEN-1:0] alu2_X0;
	//reg [WORD_LEN-1:0] alu2_X0__2;
    reg [WORD_LEN-1:0] alu2_Y0;
    reg [WORD_LEN-1:0] alu2_X1;
    reg [WORD_LEN-1:0] alu2_Y1;
    reg [WORD_LEN-1:0] alu2_X2;
    reg [WORD_LEN-1:0] alu2_Y2;
    reg [WORD_LEN-1:0] alu2_X3;
    reg [WORD_LEN-1:0] alu2_Y3;
    
    always @(posedge in_clk) begin
        alu2_X0 <= alu2_X0_next;
		//alu2_X0__2 <= (alu1_mod_vadd || alu1_mod_vdbg || alu1_mod_vslt || 
					//alu1_mod_vsub || alu1_mod_vmax || alu1_mod_vsslt)? alu1_X0: product0;
        alu2_X1 <= alu2_X1_next;
        alu2_X2 <= alu2_X2_next;
        alu2_X3 <= alu2_X3_next;
        alu2_Y0 <= alu2_Y0_next;
        alu2_Y1 <= alu2_Y1_next;
        alu2_Y2 <= alu2_Y2_next;
        alu2_Y3 <= alu2_Y3_next;
        
        alu2_mod_vact    <= alu1_mod_vact;
        alu2_mod_vadd    <= alu1_mod_vadd;
        alu2_mod_vmul    <= alu1_mod_vmul;
        alu2_mod_mvmul   <= alu1_mod_mvmul;
        alu2_mvmul_cur_row   <= alu1_mvmul_cur_row;
        alu2_mvmul_cur_word  <= alu1_mvmul_cur_word;
        alu2_mvmul_writeback <= alu1_mvmul_writeback;
        alu2_mod_vmax    <= alu1_mod_vmax;
		alu2_mod_vmax2   <= alu1_mod_vmax;
        alu2_new_mvmul   <= alu1_new_mvmul;
		alu2_new_vmax    <= alu1_new_vmax;
		alu2_new_vnorm   <= alu1_new_vnorm;
        alu2_mod_vdbg    <= alu1_mod_vdbg;
        alu2_mod_vslt    <= alu1_mod_vslt;
        alu2_mod_vsub    <= alu1_mod_vsub;
		alu2_mod_vsub2   <= alu1_mod_vsub;
        //alu2_mod_vact1    <= alu1_mod_vact1;
        //alu2_mod_vact2    <= alu1_mod_vact2;
		alu2_mod_vsslt	<= alu1_mod_vsslt;
		alu2_mod_vsslt2	<= alu1_mod_vsslt;
		alu2_mod_vdatamv<= alu1_mod_vdatamv;
		alu2_mod_vnorm  <= alu1_mod_vnorm;
        
        alu2_track_active_0 <= alu1_track_active_0;
        alu2_track_active_1 <= alu1_track_active_1;
        alu2_track_active_2 <= alu1_track_active_2;
        alu2_track_active_3 <= alu1_track_active_3;
        
        alu2_reset_next  <= alu1_reset_next;
    end
    
    wire [WORD_LEN*NUM_TRACK-1:0] local_mem_idata;
    wire [WORD_LEN*NUM_TRACK-1:0] local_mem_odata;
    wire [WORD_LEN-1:0] psum;
    wire [`SPAD_ADDR_BITS-1:0] local_mem_raddr;
    wire local_mem_we;         
    wire [`SPAD_ADDR_BITS-1:0] local_mem_waddr;      
    
    assign local_mem_idata = //(//mvmul_writeback || 
                                //new_mvmul)? 128'd0:
                                alu_out_Z_next;
    //assign local_mem_raddr = (alu2_new_mvmul || alu2_mod_vmax)? 6'd0:                              // when a mvmul inst comes in, clear the first entry in local mem
    //                         (alu2_mvmul_writeback)? alu2_mvmul_cur_row[5:0]: alu2_mvmul_cur_row[5:0];   // when a block finishes being processed, still read the current entry
	assign local_mem_raddr = alu2_mvmul_cur_row[`SPAD_ADDR_BITS-1:0];
    assign local_mem_we    = alu2_mod_mvmul || alu2_mod_vmax2 || alu2_mod_vnorm; // enable write when the incoming inst is mvmul, no need to save the last block
    //assign local_mem_waddr = (alu2_new_mvmul || alu2_mod_vmax)? 6'd0:                              // when a mvmul inst comes in, clear the first entry in local mem
    //                         (alu2_mvmul_writeback)? alu2_mvmul_cur_row[5:0]: alu2_mvmul_cur_row[5:0];   // when a block finishes being processed, clear the next entry in local mem
	assign local_mem_waddr = alu2_mvmul_cur_row[`SPAD_ADDR_BITS-1:0];
    
    local_scratchpad local_mem(.in_raddr(local_mem_raddr),.in_waddr(local_mem_waddr),.in_data(local_mem_idata),.in_we(local_mem_we),.in_clk(in_clk),.out_data(local_mem_odata)); 
    
    assign psum = (alu2_reset_next || alu2_new_mvmul || alu2_new_vnorm)? 32'd0:
                  (alu2_mvmul_cur_word == 2'd3)? local_mem_odata[31:0]:
                  (alu2_mvmul_cur_word == 2'd2)? local_mem_odata[63:32]:
                  (alu2_mvmul_cur_word == 2'd1)? local_mem_odata[95:64]:
                  (alu2_mvmul_cur_word == 2'd0)? local_mem_odata[127:96]: 32'd0;
    
    wire [WORD_LEN-1:0] addin_X0;
    wire [WORD_LEN-1:0] addin_X1;
    wire [WORD_LEN-1:0] addin_X2;
    wire [WORD_LEN-1:0] addin_X3;
    wire [WORD_LEN-1:0] addin_Y0;
    wire [WORD_LEN-1:0] addin_Y1;
    wire [WORD_LEN-1:0] addin_Y2;
    wire [WORD_LEN-1:0] addin_Y3;
    wire [WORD_LEN-1:0] sum0;
    wire [WORD_LEN-1:0] sum1;
    wire [WORD_LEN-1:0] sum2;
    wire [WORD_LEN-1:0] sum3;
	
    wire [WORD_LEN-1:0] slt_out0;
    wire [WORD_LEN-1:0] slt_out1;
    wire [WORD_LEN-1:0] slt_out2;
    wire [WORD_LEN-1:0] slt_out3;

	wire lg_2_0;
    wire lg_3_1;
	wire [WORD_LEN-1:0] Xmax_02;
    //wire [WORD_LEN-1:0] Xmax_13;
	wire [WORD_LEN-1:0] minus_Xmax_13;
    wire lg_13_02;
	//wire [WORD_LEN-1:0] Xmax_0123; 
	wire [WORD_LEN-1:0] minus_Xmax_0123;
	wire [WORD_LEN-1:0] old_Xmax;
    wire lg_new_old;
	wire [WORD_LEN-1:0] final_Xmax;
    
    assign addin_X0 = alu2_X0;
    assign addin_X1 = alu2_X1;
    assign addin_X2 =	(alu2_mod_mvmul || alu2_mod_vnorm)? sum0:
						(alu2_mod_vmax2)?Xmax_02: alu2_X2;
    assign addin_X3 =	(alu2_mod_mvmul || alu2_mod_vnorm)? sum2:
						(alu2_mod_vmax2)? old_Xmax:
						alu2_X3;
    assign addin_Y0 = //(alu2_mod_vslt || alu2_mod_vsub || alu2_mod_vsslt)? minus_Y0: // COMMENTED after minus_Y0 is moved to alu1
						//(alu2_mod_mvmul)? alu2_X2:   // COMMENTED after alu1_mod_mvmul is used by alu2_Y0_next
						//(alu2_mod_vmax)? minus_X2:  // X0-X2 in vsslt mode
						alu2_Y0;
    assign addin_Y1 = //(alu2_mod_vslt || alu2_mod_vsub || alu2_mod_vsslt)? minus_Y1: // COMMENTED after minus_Y1 is moved to alu1
                        //(alu2_mod_mvmul)? alu2_X3:  // COMMENTED after alu1_mod_mvmul is used by alu2_Y0_next
						//(alu2_mod_vmax)? minus_X3:  // X1-X3 in vsslt mode
						alu2_Y1;
    assign addin_Y2 = //(alu2_mod_vslt || alu2_mod_vsub2 || alu2_mod_vsslt2)? minus_Y2: 
                        (alu2_mod_mvmul || alu2_mod_vnorm)? sum1:
						(alu2_mod_vmax2)?minus_Xmax_13: // X02 - X13 in vsslt mode
						alu2_Y2;
    assign addin_Y3 = //(alu2_mod_vslt || alu2_mod_vsub2 || alu2_mod_vsslt2)? minus_Y3: 
                        (alu2_mod_mvmul || alu2_mod_vnorm)? psum:
						(alu2_mod_vmax2)?minus_Xmax_0123:
						alu2_Y3;
	assign lg_2_0   = sum0[WORD_LEN-1];
	assign lg_3_1   = sum1[WORD_LEN-1];
	assign Xmax_02  = (lg_2_0)? {1'b0, alu2_Y0[WORD_LEN-2:0]}:  // if X0-X2 < 0, Xmax_01 = X2(alu2_Y0)
								{1'b0, alu2_X0[WORD_LEN-2:0]};
    assign minus_Xmax_13  = (lg_3_1)?	{1'b1, alu2_Y1[WORD_LEN-2:0]}:  // if X1-X3 < 0, Xmax_23 = X3(alu2_Y1)
										{1'b1, alu2_X1[WORD_LEN-2:0]};
	//assign minus_Xmax_13 	= {~Xmax_13[WORD_LEN-1], Xmax_13[WORD_LEN-2:0]};
	assign lg_13_02			= sum2[WORD_LEN-1];
	assign minus_Xmax_0123 	= (lg_13_02)?	{1'b1, minus_Xmax_13[WORD_LEN-2:0]}:  // if X02-X13 < 0, X_0123 = X13
											{1'b1, Xmax_02[WORD_LEN-2:0]};
	//assign minus_Xmax_0123 	= {~Xmax_0123[WORD_LEN-1], Xmax_0123[WORD_LEN-2:0]};
	assign old_Xmax 		= (alu2_new_vmax)?	32'd0: // when new vmax comes in, the old maximum is set to the minimum representable number
												local_mem_odata[127:96];
	assign lg_new_old		= sum3[WORD_LEN-1];
	assign final_Xmax		= (lg_new_old)? {1'b0, minus_Xmax_0123[WORD_LEN-2:0]}: // if oldMax-newMax < 0, finalMax = newMax
											old_Xmax;
	
    fixedp_add #(FRAC_LEN, WORD_LEN) adder0 (.a(addin_X0), .b(addin_Y0), .c(sum0));
    fixedp_add #(FRAC_LEN, WORD_LEN) adder1 (.a(addin_X1), .b(addin_Y1), .c(sum1));
    fixedp_add #(FRAC_LEN, WORD_LEN) adder2 (.a(addin_X2), .b(addin_Y2), .c(sum2));
    fixedp_add #(FRAC_LEN, WORD_LEN) adder3 (.a(addin_X3), .b(addin_Y3), .c(sum3));
    
    assign slt_out0 = (~sum0[WORD_LEN-1] && (|sum0[WORD_LEN-2:0]))? `ONE_ENCOD: 32'd0;
    assign slt_out1 = (~sum1[WORD_LEN-1] && (|sum1[WORD_LEN-2:0]))? `ONE_ENCOD: 32'd0;
    assign slt_out2 = (~sum2[WORD_LEN-1] && (|sum2[WORD_LEN-2:0]))? `ONE_ENCOD: 32'd0;
    assign slt_out3 = (~sum3[WORD_LEN-1] && (|sum3[WORD_LEN-2:0]))? `ONE_ENCOD: 32'd0;
    
    wire [WORD_LEN*NUM_TRACK-1:0] alu_out_Z_next;
    
    assign alu_out_Z_next[127:96] =  (alu2_mod_vact || alu2_mod_vadd || alu2_mod_vsub)? sum0: 
                            (alu2_mod_vmul || alu2_mod_vdatamv || alu2_mod_vdbg)? alu2_X0:
                            ((alu2_mod_mvmul && (alu2_mvmul_cur_word == 2'd0)) || alu2_mod_vnorm)? sum3:
                            (alu2_mod_mvmul)? local_mem_odata[127:96]:
                            (alu2_mod_vslt || alu2_mod_vsslt)? slt_out0:
							(alu2_mod_vmax)? final_Xmax:
							32'd0;
    assign alu_out_Z_next[95:64]  =  (alu2_mod_vact || alu2_mod_vadd || alu2_mod_vsub)? sum1: 
                            (alu2_mod_vmul || alu2_mod_vdatamv || alu2_mod_vdbg)? alu2_X1:
                            (alu2_reset_next || alu2_new_mvmul || alu2_mod_vnorm)? 32'd0:
                            (alu2_mod_mvmul && (alu2_mvmul_cur_word == 2'd1))? sum3:
                            (alu2_mod_mvmul)? local_mem_odata[95:64]:
                            //(alu2_mod_vdbg)? alu2_X1:
                            (alu2_mod_vslt || alu2_mod_vsslt)? slt_out1: 32'd0;
    assign alu_out_Z_next[63:32]  =  (alu2_mod_vact || alu2_mod_vadd || alu2_mod_vsub2)? sum2: 
                            (alu2_mod_vmul || alu2_mod_vdatamv || alu2_mod_vdbg)? alu2_X2:
                            (alu2_reset_next || alu2_new_mvmul || alu2_mod_vnorm)? 32'd0:
                            (alu2_mod_mvmul && (alu2_mvmul_cur_word == 2'd2))? sum3:
                            (alu2_mod_mvmul)? local_mem_odata[63:32]:
                            //(alu2_mod_vdbg)? alu2_X2:
                            (alu2_mod_vslt || alu2_mod_vsslt2)? slt_out2: 32'd0;
    assign alu_out_Z_next[31:0]   =  (alu2_mod_vact || alu2_mod_vadd || alu2_mod_vsub2)? sum3:
                            (alu2_mod_vmul || alu2_mod_vdatamv || alu2_mod_vdbg)? alu2_X3:
                            (alu2_reset_next || alu2_new_mvmul || alu2_mod_vnorm)? 32'd0:
                            (alu2_mod_mvmul && (alu2_mvmul_cur_word == 2'd3))? sum3:
                            (alu2_mod_mvmul)? local_mem_odata[31:0]:
                            //(alu2_mod_vdbg)? alu2_X3:
                            (alu2_mod_vslt || alu2_mod_vsslt2)? slt_out3: 32'd0;

    reg [WORD_LEN*NUM_TRACK-1:0] alu_out_Z;
    
    always @(posedge in_clk) begin
        alu_out_Z   <= alu_out_Z_next;
    end
    
    assign out_Z = alu_out_Z;
    
    /*
    wire lg_0_1;
    wire lg_2_3;
    wire lg_01_23;
    wire lg_new_old;
    wire [1:0] winner_0123;
    wire [WORD_LEN-1:0] Xmax_01;
    wire [WORD_LEN-1:0] Xmax_23;
    wire [WORD_LEN-1:0] Xmax_0123; 
    
    fixedp_cmp #(FRAC_LEN, WORD_LEN) cmp0 (.a(X0),.b(X1),.algb(lg_0_1));
    fixedp_cmp #(FRAC_LEN, WORD_LEN) cmp1 (.a(X2),.b(X3),.algb(lg_2_3));
    
    assign Xmax_01 = (lg_0_1)? X0:X1;
    assign Xmax_23 = (lg_2_3)? X2:X3;
    
    fixedp_cmp #(FRAC_LEN, WORD_LEN) cmp2 (.a(Xmax_01),.b(Xmax_23),.algb(lg_01_23));
    
    assign Xmax_0123 = (lg_01_23)? Xmax_01: Xmax_23;
    
    fixedp_cmp #(FRAC_LEN, WORD_LEN) cmp3 (.a(Xmax_0123),.b(local_mem_odata[31:0]),.algb(lg_new_old));
    */
endmodule
