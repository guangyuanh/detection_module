`timescale 1ns / 1ps

module sigmoid_rom(
    input [31:0] in_fixedp,
    output [31:0] out_slope,
    output [31:0] out_intercept
);
    // sigmoid
    wire overflow;
    wire is_neg;
    wire [4:0] valid_addr;
    
    assign overflow   = |(in_fixedp[30:19]);
    assign is_neg     = in_fixedp[31];
    assign valid_addr = {in_fixedp[31], in_fixedp[18:15]};
    assign out_slope =  (~is_neg && overflow)? 32'd0:                 // when x>= 16
                        (~overflow && valid_addr == 5'd15)? 32'd0:    // when 16>x>=15
                        (~overflow && valid_addr == 5'd14)? 32'd0:
                        (~overflow && valid_addr == 5'd13)? 32'd0:
                        (~overflow && valid_addr == 5'd12)? 32'd0:
                        (~overflow && valid_addr == 5'd11)? 32'd0:
                        (~overflow && valid_addr == 5'd10)? 32'd0:
                        (~overflow && valid_addr == 5'd9)? 32'd2:
                        (~overflow && valid_addr == 5'd8)? 32'd6:
                        (~overflow && valid_addr == 5'd7)? 32'd18:
                        (~overflow && valid_addr == 5'd6)? 32'd51:
                        (~overflow && valid_addr == 5'd5)? 32'd138:
                        (~overflow && valid_addr == 5'd4)? 32'd370:
                        (~overflow && valid_addr == 5'd3)? 32'd964:
                        (~overflow && valid_addr == 5'd2)? 32'd2351:
                        (~overflow && valid_addr == 5'd1)? 32'd4906:
                        (~overflow && valid_addr == 5'd0)? 32'd7571:     // when 1>x>=0
                        (~overflow && valid_addr == 5'd16)? 32'd7571:    // also when 1>x>=0
                        (~overflow && valid_addr == 5'd17)? 32'd4906:
                        (~overflow && valid_addr == 5'd18)? 32'd2351:
                        (~overflow && valid_addr == 5'd19)? 32'd964:
                        (~overflow && valid_addr == 5'd20)? 32'd370:
                        (~overflow && valid_addr == 5'd21)? 32'd138:
                        (~overflow && valid_addr == 5'd22)? 32'd51:
                        (~overflow && valid_addr == 5'd23)? 32'd18:
                        (~overflow && valid_addr == 5'd24)? 32'd6:
                        (~overflow && valid_addr == 5'd25)? 32'd2:
                        (~overflow && valid_addr == 5'd26)? 32'd0:
                        (~overflow && valid_addr == 5'd27)? 32'd0:
                        (~overflow && valid_addr == 5'd28)? 32'd0:
                        (~overflow && valid_addr == 5'd29)? 32'd0:
                        (~overflow && valid_addr == 5'd30)? 32'd0:
                        (~overflow && valid_addr == 5'd31)? 32'd0:
                        (is_neg && overflow)? 32'd0:32'd0;
    assign out_intercept =  (~is_neg && overflow)? 32'd32768:                 // when x>= 16
                            (~overflow && valid_addr == 5'd15)? 32'd32767:    // when 16>x>=15
                            (~overflow && valid_addr == 5'd14)? 32'd32767:
                            (~overflow && valid_addr == 5'd13)? 32'd32767:
                            (~overflow && valid_addr == 5'd12)? 32'd32766:
                            (~overflow && valid_addr == 5'd11)? 32'd32763:
                            (~overflow && valid_addr == 5'd10)? 32'd32757:
                            (~overflow && valid_addr == 5'd9)?  32'd32740:
                            (~overflow && valid_addr == 5'd8)?  32'd32701:
                            (~overflow && valid_addr == 5'd7)?  32'd32606:
                            (~overflow && valid_addr == 5'd6)?  32'd32379:
                            (~overflow && valid_addr == 5'd5)?  32'd31857:
                            (~overflow && valid_addr == 5'd4)?  32'd30698:
                            (~overflow && valid_addr == 5'd3)?  32'd28319:
                            (~overflow && valid_addr == 5'd2)?  32'd24157:
                            (~overflow && valid_addr == 5'd1)?  32'd19048:
                            (~overflow && valid_addr == 5'd0)?  32'd16384:     // when 1>x>=0
                            (~overflow && valid_addr == 5'd16)? 32'd16384:    // also when 1>x>=0
                            (~overflow && valid_addr == 5'd17)? 32'd13719:
                            (~overflow && valid_addr == 5'd18)? 32'd8610:
                            (~overflow && valid_addr == 5'd19)? 32'd4448:
                            (~overflow && valid_addr == 5'd20)? 32'd2069:
                            (~overflow && valid_addr == 5'd21)? 32'd910:
                            (~overflow && valid_addr == 5'd22)? 32'd388:
                            (~overflow && valid_addr == 5'd23)? 32'd161:
                            (~overflow && valid_addr == 5'd24)? 32'd66:
                            (~overflow && valid_addr == 5'd25)? 32'd27:
                            (~overflow && valid_addr == 5'd26)? 32'd10:
                            (~overflow && valid_addr == 5'd27)? 32'd4:
                            (~overflow && valid_addr == 5'd28)? 32'd1:
                            (~overflow && valid_addr == 5'd29)? 32'd0:
                            (~overflow && valid_addr == 5'd30)? 32'd0:
                            (~overflow && valid_addr == 5'd31)? 32'd0:
                            (is_neg && overflow)? 32'd0:32'd0;
endmodule
