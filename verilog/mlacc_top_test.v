`timescale 1ns / 1ps

module mlacc_top_test(

    );
    
    reg clk_in;
    reg reset_in;
    integer fd;

    wire ila_trig;
    wire [255:0] monitored_signal;

    initial begin
        clk_in <= 1'b0;
        reset_in <= 1'b1;
        fd = $fopen("output0.csv","w");
    end
    
    always #5 clk_in <= ~clk_in;
        
    always begin
        #13 reset_in <= 1'b0;
        #10000 begin
            //$fwrite(fd0,"%h\n",uut.data_ram0.inst.native_mem_module.blk_mem_gen_v8_3_3_inst.memory[24220:24230]);
            //$fwrite(fd1,"%h\n",uut.data_ram1.inst.native_mem_module.blk_mem_gen_v8_3_3_inst.memory[0:100]);
            $fclose(fd);

            $stop;
        end
    end

    always @(posedge clk_in) begin
        if(ila_trig) begin
            $fwrite(fd, "%d, %d, %d, %d, %d, %d\n",
                monitored_signal[31:0],
                monitored_signal[95:64],
                monitored_signal[255:224],
                monitored_signal[223:192],
                monitored_signal[191:160],
                monitored_signal[159:128]);
        end
    end
    
    mlacc_top #(32,15,4) 
        uut(.in_clk(clk_in), .in_reset(reset_in),
            .ila_trig(ila_trig), .monitored_signal(monitored_signal)
            );
endmodule
