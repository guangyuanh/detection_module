`timescale 1ns / 1ps

module fixedp_cmp #(
parameter Q=15,
parameter N=32
)
(
    input [N-1:0] a,
    input [N-1:0] b,
    output algb
    );
    wire sign_a;
    wire sign_b;
    wire [N-2:0] abs_a;
    wire [N-2:0] abs_b;
    wire abs_algb;
    
    assign sign_a = a[N-1];
    assign sign_b = b[N-1];
    assign abs_a  = a[N-2:0];
    assign abs_b  = b[N-2:0];
    assign abs_algb = abs_a > abs_b;
    
    assign algb = (sign_a && ~sign_b)? 1'b0:
                    (sign_b && ~sign_a)? 1'b1:
                    (sign_a)? ~abs_algb:abs_algb;
endmodule
