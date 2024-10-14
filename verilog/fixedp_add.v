`timescale 1ns / 1ps

module fixedp_add #(
//Parameterized values
parameter Q = 15,
parameter N = 32
)
(
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
);

    wire [N-2:0] abs_a;
    wire [N-2:0] abs_b;
    wire [N-2:0] abs_c;
    wire sign_a;
    wire sign_b;
    wire sign_c;
    wire sign_diff;
    wire [N-1:0] abs_sum;
    wire [N-1:0] abs_diff_ab;
    wire [N-1:0] abs_diff_ba;
    wire [N-2:0] abs_diff;
    wire a_gt_b;
    wire overflow;
    
    assign abs_a  = a[N-2:0];
    assign abs_b  = b[N-2:0];
    assign sign_a = a[N-1];
    assign sign_b = b[N-1];
    
    assign sign_diff    = sign_a ^ sign_b;
    assign abs_sum      = abs_a + abs_b;
    assign abs_diff_ab  = abs_a - abs_b;
    assign abs_diff_ba  = abs_b - abs_a;
    assign a_gt_b       = ~abs_diff_ab[N-1];           // whether a is strictly greater than b
    assign overflow     = (~sign_diff) & abs_sum[N-1]; // addition overflow when two signs are the same
    assign abs_diff     = (a_gt_b)? abs_diff_ab[N-2:0]: abs_diff_ba[N-2:0]; // if the signs are different, choose the bigger abs minus the smaller abs as the abs of result
    
    assign abs_c  = (sign_diff)? abs_diff
                        : (overflow)? {(N-1){1'b1}}: abs_sum;            // if there is an overflow in addition, the result will be filled with 1's which is the largest abs
    assign sign_c = (sign_diff)? ((a_gt_b)? sign_a : sign_b) : sign_a;
    assign c      = {sign_c, abs_c};

endmodule