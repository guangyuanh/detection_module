`timescale 1ns / 1ps

`define LATENCY_INST 4*1
`define ENC_VDBG  0
`define ENC_RADDI 1
`define ENC_VSLT  2
`define ENC_VSUB  3
`define ENC_VADD  4
`define ENC_VMUL  5
`define ENC_VACT0 6
`define ENC_VACT1 7
`define ENC_VACT2 8
`define ENC_VMAX  9
`define ENC_VSSLT 10
`define ENC_LDREG 11
`define ENC_STREG 12
`define ENC_LOOP  13
//`define ENC_VLOAD 14
//`define ENC_VSTORE 7
`define ENC_VNORM  14
`define ENC_MVMUL 15

`define REG_IDX_BITS 5
`define REG_LOOPS       1
`define REG_X_OFFSET_LD 2
`define REG_Y_OFFSET_LD 3
`define REG_Z_OFFSET_ST 4

module mlacc_ctrl#(
parameter WORD_LEN = 32,
parameter FRAC_LEN = 15,
parameter NUM_TRACK = 4,
parameter WIDTH_INST = 1,
parameter ENC_ADDR_WIDTH = 31
)
(
    input [127:0] in_inst,
    input in_reset,
    input in_clk,
	input [WORD_LEN*NUM_TRACK-1:0] in_mem3_x_data,
    output out_we,
    output out_x_sel_mem0,
    output out_y_sel_mem0,
	output out_x_sel_mem3,
    output out_y_sel_mem3,
    output [31:0] out_addr_x,
    output [31:0] out_addr_y,
    output [31:0] out_addr_z,
    output [WIDTH_INST-1:0] out_pc,
    output out_track_active_0,
    output out_track_active_1,
    output out_track_active_2,
    output out_track_active_3,
    output [27:0] out_mvmul_cur_row,
    //output out_mvmul_cur_block_finished,
    output [1:0] out_mvmul_cur_word,
    output out_mvmul_writeback,
    output out_new_mvmul,
	output out_new_vmax,
	output out_new_vnorm,
    output out_reset_next,
    //output out_new_inst,
	output out_mod_vadd,
    output out_mod_vmul,
    output out_mod_vact0,
    output out_mod_mvmul,
    output out_mod_vdbg,
    output out_mod_vslt,
    output out_mod_vsub,
    output out_mod_vact1,
    output out_mod_vact2,
    output out_mod_vsslt,
	output out_mod_vmax,
	output out_mod_raddi,
	output out_mod_ldreg,
	output out_mod_streg,
	output out_mod_loop,
	output out_mod_vload,
	output out_mod_vnorm,
	//output out_mod_vload,
	//output out_mod_vstore,
    //output out_aluout_mod_mvmul
	output [3:0] out_aluout_funct,
	output [WORD_LEN*NUM_TRACK-1:0] out_alu0_regval
    );
    
    // pre-declaration
    wire [13:0] if_inst_length;
    wire [13:0] if_inst_width;
    wire if_inst_one_cycle;
    wire if_fetch_pc;
    reg [WIDTH_INST-1:0] in_pc;
    wire mem0_cur_inst_finished;
    wire mem0_cur_inst_finished_almost;
	wire mem3_loops_en_ldreg;
    reg [31:0] alu0_x_offset_load;
    reg [31:0] alu0_y_offset_load;
    reg [31:0] alu0_z_offset_store;
    
    // instruction state
    reg [WIDTH_INST-1:0]  if_pc;
    
    reg [WIDTH_INST-1:0]     loop_begin;    
    reg [WIDTH_INST-1:0]     loop_end;    
    reg [31:0]               loop_n;        // Number of unexecuted iterations
    
	// loop instruction
	wire should_jump;
	//wire [WIDTH_INST-1:0]     loop_begin_next;
	//wire [WIDTH_INST-1:0]     loop_end_next;
	wire [31:0] loop_n_next;
	
	assign should_jump = (loop_n != 32'd0) && (if_pc == loop_end);
	//assign loop_begin_next = 
	//assign loop_end_next   = 
	assign loop_n_next = //(loop_n == 32'd0)? 32'd0: 
						loop_n - 1;
    
	always @(posedge in_clk) begin
        if(in_reset) begin
			loop_begin	<= {WIDTH_INST{1'b0}};
			loop_end	<= {WIDTH_INST{1'b0}};
			loop_n		<= 32'd0;
        end
        else begin
            if(mem0_cur_inst_finished && (in_inst[127:124] == 4'd`ENC_LOOP)) begin
				loop_begin	<= in_pc + 1;
				loop_end	<= in_inst[64+WIDTH_INST-1:64];
				loop_n		<= in_inst[63:32];
			end
			else begin
				if(mem3_loops_en_ldreg) begin
					loop_begin	<= in_mem3_x_data[WORD_LEN*NUM_TRACK-1: WORD_LEN*(NUM_TRACK-1)];
					loop_end	<= in_mem3_x_data[WORD_LEN*3-1: WORD_LEN*2];
					loop_n		<= in_mem3_x_data[WORD_LEN*2-1: WORD_LEN*1];
				end
				else if(if_fetch_pc && should_jump) begin
					loop_n <= loop_n_next;
				end
            end
        end
    end
	
    //wire [13:0] if_inst_length;
    //wire [13:0] if_inst_width;
    //wire if_inst_one_cycle;
    //wire if_fetch_pc;
	
    assign if_inst_length = in_inst[123:110];
    assign if_inst_width  = in_inst[109:96];
    assign if_inst_one_cycle = 	in_inst[127:124] == 4'd`ENC_LDREG ||
								in_inst[127:124] == 4'd`ENC_STREG ||
								in_inst[127:124] == 4'd`ENC_LOOP  ||
								in_inst[127:124] == 4'd`ENC_RADDI ||
								(~(|(if_inst_length[13:2]) || |(if_inst_width[13:0])));
    assign if_fetch_pc = (mem0_cur_inst_finished && if_inst_one_cycle) || mem0_cur_inst_finished_almost;
    
	
    always @(posedge in_clk) begin
        if(in_reset) begin
            if_pc 		<= {WIDTH_INST{1'b0}};
        end
        else begin
            if(if_fetch_pc) begin
                if_pc <= out_pc;
            end
        end
    end
    
	assign out_pc = should_jump?loop_begin: 
								if_pc+1;
	
	// In stage (after inst BRAM)
	//reg [WIDTH_INST-1:0] in_pc;
	
	always @(posedge in_clk) begin
        if(in_reset) begin
            in_pc <= {WIDTH_INST{1'b0}};
        end
        else
            in_pc <= out_pc;
	end
	
    reg [3:0]   mem0_funct;
    reg [31:0]  mem0_addr_x;
    reg [31:0]  mem0_addr_y;
    reg [31:0]  mem0_addr_z;
    reg         mem0_x_sel;
    reg         mem0_y_sel;
    reg [13:0]  mem0_width_copy;
    //reg         mem0_new_mvmul;
    wire        mem0_new_mvmul;
    reg [127:0] mem0_inst;
    
    // loop state (within an instruction)
    reg [13:0]  mem0_length;
    reg [13:0]  mem0_width;
    reg [31:0]  mem0_x_offset;
    reg [31:0]  mem0_y_offset;
    reg [31:0]  mem0_z_offset;
    reg         mem0_new_inst;
    
	reg [31:0]	mem0_radd_imm;
	reg [`REG_IDX_BITS-1:0] mem0_regop_idx;
	
	reg mem0_use_x_offset_load;
	reg mem0_use_y_offset_load;
	reg mem0_use_z_offset_store;
	
    wire mem0_we;
    wire mem0_inst_valid;
    wire mem0_last_loop;
    //wire mem0_cur_inst_finished;
    //wire mem0_cur_inst_finished_almost;
    wire [13:0] mem0_length_next;
    wire [13:0] mem0_width_next;
    wire [31:0] mem0_x_offset_next;
    wire [31:0] mem0_y_offset_next;
    wire [31:0] mem0_z_offset_next;
    wire [31:0] mem0_mem1_addr_z;
    wire [1:0]  mem0_track_active;
	
    wire mem0_mod_mvmul;
    wire mem0_mod_vdbg;
	wire mem0_mod_vsslt;
	wire mem0_mod_vmax;
	wire mem0_mod_raddi;
	wire mem0_mod_ldreg;
	wire mem0_mod_loop;
	//wire mem0_mod_vload;
	
    wire mem0_cur_col_finished;
    wire mem0_mvmul_cur_col_unfinished;
    wire mem0_first_col;
    wire mem0_reset_next;
    wire mem0_vdbg_cur_col_unfinished;
	wire mem0_vmax_unfinished;
	wire mem0_vnorm_unfinished;

    assign mem0_mod_vdbg 	= (mem0_funct == 4'd`ENC_VDBG);
	assign mem0_mod_vmax   	= (mem0_funct == 4'd`ENC_VMAX);
	assign mem0_mod_vsslt	= (mem0_funct == 4'd`ENC_VSSLT);
	assign mem0_mod_raddi 	= (mem0_funct == 4'd`ENC_RADDI);
	assign mem0_mod_ldreg 	= (mem0_funct == 4'd`ENC_LDREG);
	assign mem0_mod_loop 	= (mem0_funct == 4'd`ENC_LOOP);
	//assign mem0_mod_vload 	= (mem0_funct == 4'd`ENC_VLOAD);
	assign mem0_mod_mvmul	= (mem0_funct == 4'd`ENC_MVMUL);
	assign mem0_mod_vnorm	= (mem0_funct == 4'd`ENC_VNORM);
    
    assign out_addr_x   	= mem0_use_x_offset_load?	mem0_addr_x + mem0_x_offset + alu0_x_offset_load:
														mem0_addr_x + mem0_x_offset;
    assign out_addr_y   	= mem0_use_y_offset_load?	mem0_addr_y + mem0_y_offset + alu0_y_offset_load:
														mem0_addr_y + mem0_y_offset;
	assign out_x_sel_mem0  	= mem0_x_sel;
    assign out_y_sel_mem0  	= mem0_y_sel;
    
    assign mem0_inst_valid          = |(mem0_inst[127:124]);
    assign mem0_last_loop           = mem0_length[13:2] == 12'd0;
    
    // current loop has reached its end and new inst should enter mem 0
    assign mem0_cur_inst_finished   = mem0_last_loop && (mem0_width[13:0] == 14'd0);
    // current loop will reach its end in the next cycle and new inst should be fetched
    //assign mem0_cur_inst_finished_almost    = mem0_last_loop && (mem0_width[13:0] == 14'd1);
    //assign mem0_cur_inst_finished_almost    = (mem0_mod_mvmul)? mem0_last_loop && (mem0_width[13:0] == 14'd1):
    //                                                            (mem0_length[13:2] == 12'd1) && (mem0_width[13:0] == 14'd0);
    assign mem0_cur_inst_finished_almost    = (mem0_mod_mvmul && mem0_last_loop && (mem0_width[13:0] == 14'd1)) ||
                                                                    (mem0_length[13:2] == 12'd1) && (mem0_width_copy[13:0] == 14'd0);
    
    // each stage 4 words of data is processed
    assign mem0_length_next         = (mem0_mvmul_cur_col_unfinished || mem0_vdbg_cur_col_unfinished)?
                                        mem0_length: mem0_length - 4;      
                                        
    // only in mvmul mode the width is not zero and it returns to the head when we finish iterating on the current columns
    assign mem0_width_next          = (mem0_cur_col_finished)? mem0_width_copy: mem0_width-1;
    
    // each stage 4*4 bytes of data is processed  
    assign mem0_x_offset_next       = (mem0_mvmul_cur_col_unfinished)?mem0_x_offset:
                                      (mem0_mod_vdbg)? mem0_x_offset:  mem0_x_offset + 16;                              
    // each stage 4*4 bytes of data is processed
    assign mem0_y_offset_next       = (mem0_mod_vdbg || mem0_mod_vsslt)? mem0_y_offset: // in vsslt mode the scalar should be kept
										mem0_y_offset + 16;
    // in mvmul mode the output offset return to 0 when current column is finished
    assign mem0_z_offset_next       = (mem0_mod_mvmul && mem0_cur_col_finished)?  32'd0:
                                      (mem0_mod_mvmul)? mem0_z_offset + 4: 
									  (mem0_mod_vmax || mem0_mod_vnorm)? mem0_z_offset:  // In vmax mode there is only one output and addr_z won't change
                                        mem0_z_offset + 16;   // In vector mode each stage 4*4 bytes of data is processed
                                        
    assign mem0_mem1_addr_z         = mem0_addr_z + mem0_z_offset;                  // to mem1
    assign mem0_track_active        = (mem0_last_loop)? mem0_length[1:0] : 2'd3;    // to mem1
    assign mem0_cur_col_finished    = ~(| mem0_width);
    
    assign mem0_mvmul_cur_col_unfinished = mem0_mod_mvmul && ~mem0_cur_col_finished;
    //assign mem0_we = (mem0_mod_mvmul)? (mem0_last_loop && 
    assign mem0_first_col           = mem0_mod_mvmul && mem0_x_offset == 32'd0;
    assign mem0_reset_next          = (mem0_z_offset[3:2]==2'd0) && mem0_first_col;
    assign mem0_new_mvmul           = mem0_new_inst && mem0_mod_mvmul;
	
    assign mem0_vdbg_cur_col_unfinished = mem0_mod_vdbg && ~mem0_cur_col_finished;
	assign mem0_vmax_unfinished  = mem0_mod_vmax  && ~mem0_last_loop;
	assign mem0_vnorm_unfinished = mem0_mod_vnorm && ~mem0_last_loop;
	
	assign mem0_we = mem0_inst_valid && ~mem0_vmax_unfinished && ~mem0_vnorm_unfinished &&
					~mem0_mod_vdbg && ~mem0_mod_raddi && 
					~mem0_mod_ldreg && ~mem0_mod_loop;
	
    always @(posedge in_clk) begin
        if(in_reset) begin
            // Upon reset, mem0_length is initialized to 4 * LATENCY(inst)
            // so that the module waits until the first instruction comes in
            mem0_length <= 14'd`LATENCY_INST;
            
            mem0_width  <= 14'd0;
            mem0_funct  <= 4'd0;
            mem0_addr_x <= 32'd0;
            mem0_addr_y <= 32'd0;
            mem0_addr_z <= 32'd0;
            //mem0_we     <= 1'd0;
            mem0_width_copy <= 14'd0;
            //mem0_new_mvmul  <= 1'b0;
            mem0_inst       <= 128'd0;
            mem0_new_inst   <= 1'b0;
			mem0_radd_imm	<= 32'd0;
			mem0_regop_idx	<= `REG_IDX_BITS 'd0;
			mem0_use_x_offset_load	<= 1'b0;
			mem0_use_y_offset_load	<= 1'b0;
			mem0_use_z_offset_store	<= 1'b0;
        end
        else begin
            if(mem0_cur_inst_finished) begin
                mem0_funct  <= in_inst[127:124];
                mem0_length <= in_inst[123:110];
                mem0_width  <= in_inst[109:96];
                mem0_addr_x <= {in_inst[64+ENC_ADDR_WIDTH-1:64],{(32-ENC_ADDR_WIDTH){1'b0}}};
                mem0_addr_y <= {in_inst[32+ENC_ADDR_WIDTH-1:32],{(32-ENC_ADDR_WIDTH){1'b0}}};
                mem0_addr_z <= {in_inst[ENC_ADDR_WIDTH-1:0],{(32-ENC_ADDR_WIDTH){1'b0}}};
                mem0_x_offset   <= 32'd0;
                mem0_y_offset   <= 32'd0;
                mem0_z_offset   <= 32'd0;
                //mem0_we         <= inst_valid;
                mem0_x_sel      <= in_inst[64+ENC_ADDR_WIDTH-1];
                mem0_y_sel      <= in_inst[32+ENC_ADDR_WIDTH-1];
                mem0_width_copy <= in_inst[109:96];
                //mem0_new_mvmul  <= in_inst[127:126] == 2'd3;
                mem0_inst       <= in_inst;
                mem0_new_inst   <= 1'b1;
				mem0_use_x_offset_load	<= in_inst[95];
				mem0_use_y_offset_load	<= in_inst[63];
				mem0_use_z_offset_store	<= in_inst[31];
				
				if(in_inst[127:124] == 4'd`ENC_RADDI) begin
					mem0_radd_imm	<= in_inst[95:64];
				end
				if((in_inst[127:124] == 4'd`ENC_RADDI) || (in_inst[127:124] == 4'd`ENC_LDREG) || (in_inst[127:124] == 4'd`ENC_STREG)) begin
				    mem0_regop_idx	<= in_inst[`REG_IDX_BITS-1+32:32];
				end
            end
            else begin
                mem0_length     <= mem0_length_next;
                mem0_width      <= mem0_width_next;
                mem0_x_offset   <= mem0_x_offset_next;
                mem0_y_offset   <= mem0_y_offset_next;
                mem0_z_offset   <= mem0_z_offset_next;
                //mem0_new_mvmul  <= 1'b0;
                mem0_new_inst   <= 1'b0;
            end
        end
    end
	
    reg [13:0]  mem1_width;
    reg [3:0]   mem1_funct;
    reg [31:0]  mem1_addr_z;
    reg         mem1_we;
    reg         mem1_x_sel;
    reg         mem1_y_sel;
    reg [1:0]   mem1_track_active;
    reg [31:0]  mem1_z_offset;
    reg         mem1_new_mvmul;
    //reg [13:0]  mem1_width;
    reg         mem1_last_loop;
    reg         mem1_reset_next;
    reg         mem1_new_inst;
	reg	[31:0]	mem1_radd_imm;
	reg [`REG_IDX_BITS-1:0] mem1_regop_idx;
	reg mem1_use_z_offset_store;
    
    always @(posedge in_clk) begin
        if(in_reset) begin
            mem1_we     <= 1'd0;
            mem1_new_mvmul  <= 1'b0;
            mem1_new_inst   <= 1'b0;
			mem1_radd_imm	<= 32'd0;
			mem1_regop_idx	<= `REG_IDX_BITS 'd0;
			mem1_use_z_offset_store <= 1'b0;
        end
        else begin
            mem1_width  <= mem0_width;
            mem1_funct  <= mem0_funct;
            mem1_addr_z <= mem0_mem1_addr_z;
            mem1_we     <= mem0_we;
            mem1_x_sel  <= mem0_x_sel;
            mem1_y_sel  <= mem0_y_sel;
            mem1_track_active   <= mem0_track_active;
            mem1_z_offset       <= mem0_z_offset;
            mem1_new_mvmul      <= mem0_new_mvmul;
            //mem1_width          <= mem0_width;
            mem1_last_loop      <= mem0_last_loop;
            mem1_reset_next     <= mem0_reset_next;
            mem1_new_inst       <= mem0_new_inst;
			mem1_radd_imm		<= mem0_radd_imm;
			mem1_regop_idx		<= mem0_regop_idx;
			mem1_use_z_offset_store	<= mem0_use_z_offset_store;
        end
    end
    
    reg [13:0]  mem2_width;
    reg [3:0]   mem2_funct;
    reg [31:0]  mem2_addr_z;
    reg         mem2_we;
    reg         mem2_x_sel;
    reg         mem2_y_sel;
    reg [1:0]   mem2_track_active;
    reg [31:0]  mem2_z_offset;
    reg         mem2_new_mvmul;
    //reg [13:0]  mem2_width;
    reg         mem2_last_loop;
    reg         mem2_reset_next;
    reg         mem2_new_inst;
	reg	[31:0]	mem2_radd_imm;
	reg [`REG_IDX_BITS-1:0] mem2_regop_idx;
	reg mem2_use_z_offset_store;
    
    always @(posedge in_clk) begin
        if(in_reset) begin
            mem2_we     <= 1'd0;
            mem2_new_mvmul <= 1'b0;
            mem2_new_inst   <= 1'b0;
			mem2_radd_imm	<= 32'd0;
			mem2_regop_idx	<= `REG_IDX_BITS 'd0;
			mem2_use_z_offset_store	<= 1'b0;
        end
        else begin
            mem2_width  <= mem1_width;
            mem2_funct  <= mem1_funct;
            mem2_addr_z <= mem1_addr_z;
            mem2_we     <= mem1_we;
            mem2_x_sel  <= mem1_x_sel;
            mem2_y_sel  <= mem1_y_sel;
            mem2_track_active   <= mem1_track_active;
            mem2_z_offset       <= mem1_z_offset;
            mem2_new_mvmul      <= mem1_new_mvmul;
            //mem2_width          <= mem1_width;
            mem2_last_loop      <= mem1_last_loop;
            mem2_reset_next     <= mem1_reset_next;
            mem2_new_inst       <= mem1_new_inst;
			mem2_radd_imm		<= mem1_radd_imm;
			mem2_regop_idx		<= mem1_regop_idx;
			mem2_use_z_offset_store	<= mem1_use_z_offset_store;
        end
    end
    
    reg [13:0]  mem3_width;
    reg [3:0]   mem3_funct;
    reg [31:0]  mem3_addr_z;
    reg         mem3_we;
    reg         mem3_x_sel;
    reg         mem3_y_sel;
    reg [1:0]   mem3_track_active;
    reg [31:0]  mem3_z_offset;
    reg         mem3_new_mvmul;
    //reg [13:0]  mem3_width;
    reg         mem3_last_loop;
    reg         mem3_reset_next;
    reg         mem3_new_inst;
	reg	[31:0]	mem3_radd_imm;
	reg [`REG_IDX_BITS-1:0] mem3_regop_idx;
	reg mem3_use_z_offset_store;
    
    wire        mem3_width_unfinished;
	
	wire		mem3_x_offset_load_en_addi;
	wire		mem3_y_offset_load_en_addi;
	wire		mem3_z_offset_store_en_addi;
	wire		mem3_x_offset_load_en_ldreg;
	wire		mem3_y_offset_load_en_ldreg;
	wire		mem3_z_offset_store_en_ldreg;
	wire [31:0]	mem3_x_offset_load_next;
	wire [31:0]	mem3_y_offset_load_next;
	wire [31:0]	mem3_z_offset_store_next;
    
    always @(posedge in_clk) begin
        if(in_reset) begin
            mem3_we     <= 1'd0;
            mem3_new_inst   <= 1'b0;
			mem3_radd_imm	<= 32'd0;
			mem3_regop_idx	<= `REG_IDX_BITS 'd0;
			mem3_use_z_offset_store	<= 1'b0;
        end
        else begin
            mem3_width  <= mem2_width;
            mem3_funct  <= mem2_funct;
            mem3_addr_z <= mem2_addr_z;
            mem3_we     <= mem2_we;
            mem3_x_sel  <= mem2_x_sel;
            mem3_y_sel  <= mem2_y_sel;
            mem3_track_active   <= mem2_track_active;
            mem3_z_offset       <= mem2_z_offset;
            mem3_new_mvmul      <= mem2_new_mvmul;
            //mem3_width          <= mem2_width;
            mem3_last_loop      <= mem2_last_loop;
            mem3_reset_next     <= mem2_reset_next;
            mem3_new_inst       <= mem2_new_inst;
			mem3_radd_imm		<= mem2_radd_imm;
			mem3_regop_idx		<= mem2_regop_idx;
			mem3_use_z_offset_store	<= mem2_use_z_offset_store;
        end
    end
    
    assign out_x_sel_mem3  	= mem3_x_sel;
    assign out_y_sel_mem3  	= mem3_y_sel;
    assign out_mod_vdbg     = (mem3_funct == 4'd`ENC_VDBG);
    assign out_mod_raddi    = (mem3_funct == 4'd`ENC_RADDI);
    assign out_mod_vslt     = (mem3_funct == 4'd`ENC_VSLT);
    assign out_mod_vsub     = (mem3_funct == 4'd`ENC_VSUB);
    assign out_mod_vadd     = (mem3_funct == 4'd`ENC_VADD);
    assign out_mod_vmul     = (mem3_funct == 4'd`ENC_VMUL);
    assign out_mod_vact0    = (mem3_funct == 4'd`ENC_VACT0); //Sigmoid
    assign out_mod_vact1    = (mem3_funct == 4'd`ENC_VACT1); //tanh
    assign out_mod_vact2    = (mem3_funct == 4'd`ENC_VACT2); //ReLU
    assign out_mod_vmax     = (mem3_funct == 4'd`ENC_VMAX);
    assign out_mod_vsslt    = (mem3_funct == 4'd`ENC_VSSLT);
    assign out_mod_ldreg    = (mem3_funct == 4'd`ENC_LDREG);
    assign out_mod_streg    = (mem3_funct == 4'd`ENC_STREG);
    assign out_mod_loop     = (mem3_funct == 4'd`ENC_LOOP);
    assign out_mod_vnorm    = (mem3_funct == 4'd`ENC_VNORM);
    assign out_mod_mvmul    = (mem3_funct == 4'd`ENC_MVMUL);
    assign out_track_active_0  = 1'b1;
    assign out_track_active_1  = |mem3_track_active;
    assign out_track_active_2  = mem3_track_active[1];
    assign out_track_active_3  = &mem3_track_active;
    assign out_mvmul_cur_row   = mem3_z_offset[31:4];
    assign out_mvmul_cur_word  = mem3_z_offset[3:2];
    assign out_mvmul_writeback = (mem3_last_loop && ~mem3_width_unfinished)? 1'b1:
                                 (mem3_last_loop && mem3_width_unfinished)? (&mem3_z_offset[3:2]):
                                 1'b0;  // if a NUM_TRACK word block in local_mem needs to be written back
    assign out_new_mvmul       = mem3_new_mvmul;
    assign mem3_width_unfinished = |mem3_width;
    //assign out_new_inst     = mem3_new_inst;
	assign out_new_vmax		= mem3_new_inst && out_mod_vmax;
	assign out_new_vnorm	= mem3_new_inst && out_mod_vnorm;
    
	assign mem3_x_offset_load_en_addi	= out_mod_raddi && (mem3_regop_idx == `REG_IDX_BITS 'd`REG_X_OFFSET_LD);
	assign mem3_y_offset_load_en_addi	= out_mod_raddi && (mem3_regop_idx == `REG_IDX_BITS 'd`REG_Y_OFFSET_LD);
	assign mem3_z_offset_store_en_addi	= out_mod_raddi && (mem3_regop_idx == `REG_IDX_BITS 'd`REG_Z_OFFSET_ST);
	assign mem3_x_offset_load_en_ldreg	= out_mod_ldreg && (mem3_regop_idx == `REG_IDX_BITS 'd`REG_X_OFFSET_LD);
	assign mem3_y_offset_load_en_ldreg	= out_mod_ldreg && (mem3_regop_idx == `REG_IDX_BITS 'd`REG_Y_OFFSET_LD);
	assign mem3_z_offset_store_en_ldreg	= out_mod_ldreg && (mem3_regop_idx == `REG_IDX_BITS 'd`REG_Z_OFFSET_ST);
	assign mem3_loops_en_ldreg	        = out_mod_ldreg && (mem3_regop_idx == `REG_IDX_BITS 'd`REG_LOOPS);
	assign mem3_x_offset_load_next	= mem3_x_offset_load_en_ldreg?	in_mem3_x_data[WORD_LEN*NUM_TRACK-1: WORD_LEN*(NUM_TRACK-1)]:
									  mem3_x_offset_load_en_addi?	alu0_x_offset_load + mem3_radd_imm:
																	32'd0;
	assign mem3_y_offset_load_next	= mem3_y_offset_load_en_ldreg?	in_mem3_x_data[WORD_LEN*NUM_TRACK-1: WORD_LEN*(NUM_TRACK-1)]:
									  mem3_y_offset_load_en_addi?	alu0_y_offset_load + mem3_radd_imm:
																	32'd0;
	assign mem3_z_offset_store_next	= mem3_z_offset_store_en_ldreg?	in_mem3_x_data[WORD_LEN*NUM_TRACK-1: WORD_LEN*(NUM_TRACK-1)]:
									  mem3_z_offset_store_en_addi?	alu0_z_offset_store + mem3_radd_imm:
																	32'd0;
	
    reg         alu0_we;
    reg [31:0]  alu0_addr_z;
    reg         alu0_reset_next;
    //reg         alu0_mod_mvmul;
	// For debug and monitoring
	reg [3:0]   alu0_funct;
	//reg [31:0] alu0_x_offset_load;
    //reg [31:0] alu0_y_offset_load;
    //reg [31:0] alu0_z_offset_store;
	//reg 		alu0_mod_vstore;
	reg alu0_use_z_offset_store;
	reg [`REG_IDX_BITS-1:0] alu0_regop_idx;
	reg alu0_mod_streg;
	
	wire [31:0] alu0_addr_z_next;
	wire alu0_streg_offsetx;
	wire alu0_streg_offsety;
	wire alu0_streg_offsetz;
	wire alu0_streg_loop;
	
    always @(posedge in_clk) begin
        if(in_reset) begin
            alu0_we		<= 1'b0;
            //alu0_mod_mvmul <= 1'b0;
			alu0_funct	<= 4'd0;
			alu0_x_offset_load	<= 32'd0;
			alu0_y_offset_load	<= 32'd0;
			alu0_z_offset_store	<= 32'd0;
			//alu0_mod_vstore	<= 1'b0;
			alu0_use_z_offset_store	<= 1'b0;
			alu0_regop_idx	<= `REG_IDX_BITS 'd0;
			alu0_mod_streg <= 1'b0;
        end
        else begin
            alu0_we      <= (out_mod_mvmul)? out_mvmul_writeback: mem3_we;
            alu0_addr_z  <= mem3_addr_z;
            alu0_reset_next <= mem3_reset_next;
            //alu0_mod_mvmul  <= out_mod_mvmul;
			alu0_funct		<= mem3_funct;
			//alu0_mod_vstore	<= out_mod_vstore;
			if(mem3_x_offset_load_en_addi || mem3_x_offset_load_en_ldreg) begin
					alu0_x_offset_load	<= mem3_x_offset_load_next;
			end
			if(mem3_y_offset_load_en_addi || mem3_y_offset_load_en_ldreg) begin
					alu0_y_offset_load	<= mem3_y_offset_load_next;
			end
			if(mem3_z_offset_store_en_addi || mem3_z_offset_store_en_ldreg) begin
					alu0_z_offset_store	<= mem3_z_offset_store_next;
			end
			alu0_use_z_offset_store	<= mem3_use_z_offset_store;
			alu0_regop_idx	<= mem3_regop_idx;
			alu0_mod_streg	<= out_mod_streg;
        end
    end
    
	assign alu0_addr_z_next = alu0_use_z_offset_store? alu0_addr_z + alu0_z_offset_store: alu0_addr_z;
	assign alu0_streg_offsetx = alu0_mod_streg && (alu0_regop_idx == `REG_IDX_BITS 'd`REG_X_OFFSET_LD);
	assign alu0_streg_offsety = alu0_mod_streg && (alu0_regop_idx == `REG_IDX_BITS 'd`REG_Y_OFFSET_LD);
	assign alu0_streg_offsetz = alu0_mod_streg && (alu0_regop_idx == `REG_IDX_BITS 'd`REG_Z_OFFSET_ST);
	assign alu0_streg_loop    = alu0_mod_streg && (alu0_regop_idx == `REG_IDX_BITS 'd`REG_LOOPS);
	
	assign out_reset_next   = alu0_reset_next;
	assign out_alu0_regval[WORD_LEN*NUM_TRACK-1: WORD_LEN*(NUM_TRACK-1)] = (alu0_streg_offsetx)? alu0_x_offset_load:
																		   (alu0_streg_offsety)? alu0_y_offset_load:
																		   (alu0_streg_offsetz)? alu0_z_offset_store:
																		   loop_begin;
	assign out_alu0_regval[WORD_LEN*3-1: WORD_LEN*2] = //(alu0_streg_loop)? 
														loop_end;//:32'd0;
	assign out_alu0_regval[WORD_LEN*2-1: WORD_LEN*1] = //(alu0_streg_loop)? 
														loop_n;//:32'd0;
	assign out_alu0_regval[WORD_LEN*1-1: WORD_LEN*0] = 32'd0;
	
    reg         alu1_we;
    reg [31:0]  alu1_addr_z;
    //reg         alu1_mod_mvmul;
	// For debug and monitoring
	reg [3:0]   alu1_funct;
    
    always @(posedge in_clk) begin
        if(in_reset) begin
            alu1_we     <= 1'b0;
            //alu1_mod_mvmul <= 1'b0;
			alu1_funct	<= 4'd0;
        end
        else begin
            alu1_we      <= alu0_we;
            alu1_addr_z  <= alu0_addr_z_next;
            //alu1_mod_mvmul	<= alu0_mod_mvmul;
			alu1_funct		<= alu0_funct;
        end
    end
    
    reg         alu2_we;
    reg [31:0]  alu2_addr_z;
    //reg         alu2_mod_mvmul;
	// For debug and monitoring
	reg [3:0]   alu2_funct;
    
    always @(posedge in_clk) begin
        if(in_reset) begin
            alu2_we      <= 1'b0;
            //alu2_mod_mvmul <= 1'b0;
			alu2_funct	<= 4'd0;
        end
        else begin
            alu2_we      <= alu1_we;
            alu2_addr_z  <= alu1_addr_z;
            //alu2_mod_mvmul	<= alu1_mod_mvmul;
			alu2_funct		<= alu1_funct;
        end
    end
    
    reg         alu_out_we;
    reg [31:0]  alu_out_addr_z;
    //reg         alu_out_mod_mvmul;
	// For debug and monitoring
	reg [3:0]   alu_out_funct;
    
    always @(posedge in_clk) begin
        if(in_reset) begin
            alu_out_we      <= 1'b0;
            //alu_out_mod_mvmul <= 1'b0;
			alu_out_funct	<= 4'd0;
        end
        else begin
            alu_out_we      <= alu2_we;
            alu_out_addr_z  <= alu2_addr_z;
            //alu_out_mod_mvmul	<= alu2_mod_mvmul;
			alu_out_funct		<= alu2_funct;
        end
    end
    
    assign out_we           = alu_out_we;
    assign out_addr_z       = alu_out_addr_z;
    //assign out_aluout_mod_mvmul = alu_out_mod_mvmul;
	assign out_aluout_funct = alu_out_funct;
endmodule
