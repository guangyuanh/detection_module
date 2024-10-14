`timescale 1ns / 1ps

module mlacc_fpga_top(
    input sys_clk_p,
    input sys_clk_n,
    input in_reset//,
    //output led
    );
    
    wire in_clk;
    wire sys_clk;
    
    wire ila_trig;
    wire [255:0] monitored_signal;
    
    mlacc_top #(32,15,4)
        top0(.in_clk(in_clk), .in_reset(in_reset),
             .ila_trig(ila_trig), .monitored_signal(monitored_signal)
             );
    
    ila_0 dbg_ila (.clk(in_clk), // input wire clk
                   .trig_in(ila_trig),// input wire trig_in 
                   .trig_in_ack(),// output wire trig_in_ack 
                   .probe0(monitored_signal) // input wire [127:0] probe0
                   );
    
    clk_wiz_0 clk_converter
            (
            // Clock in ports
             .clk_in1(sys_clk),      // input clk_in1
             // Clock out ports
             .clk_out1(in_clk));    // output clk_out1
             
                                         
    IBUFGDS #(
             .DIFF_TERM("FALSE"), // Differential Termination
             .IBUF_LOW_PWR("TRUE"), // Low power="TRUE", Highest performance="FALSE"
             .IOSTANDARD("LVDS") // Specify the input I/O standard
             ) IBUFGDS_inst (
             .O(sys_clk), // Clock buffer output
             .I(sys_clk_p), // Diff_p clock buffer input (connect directly to top-level port)
             .IB(sys_clk_n) // Diff_n clock buffer input (connect directly to top-level port)
             );
endmodule
