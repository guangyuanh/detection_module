`timescale 1ns / 1ps

module relu_rom(
input [31:0] in_fixedp,
    output [31:0] out_slope,
    output [31:0] out_intercept
);
    wire is_neg;
    // ReLu
    assign is_neg       = in_fixedp[31];
    assign out_slope    = (is_neg)? 32'd0: 32'h0000_8000;
    assign out_intercept= 32'd0;
endmodule
