`timescale 1ns / 1ps

module fixedp_mul #(
//Parameterized values
parameter Q = 15,
parameter N = 32
)
(
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
);

    wire [2*N-3:0] product;
    wire [N-2:0] abs_a;
    wire [N-2:0] abs_b;
    wire [N-2:0] valid_abs_c;
    wire [N-2:0] abs_c;
    wire sign_a;
    wire sign_b;
    wire sign_c;
    wire overflow;
    
    assign abs_a  = a[N-2:0];
    assign abs_b  = b[N-2:0];
    assign sign_a = a[N-1];
    assign sign_b = b[N-1];
    
    assign product     = abs_a * abs_b;
    assign sign_c      = sign_a ^ sign_b;
    assign valid_abs_c = product[N-2+Q:Q];
    assign overflow    = (product[2*N-3:N-1+Q] > 0);
    assign abs_c       = overflow? {(N-1){1'b1}} : valid_abs_c;
    
    assign c      = {sign_c, abs_c};

endmodule
