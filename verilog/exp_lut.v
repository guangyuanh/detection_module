`timescale 1ns / 1ps

`define lowbit_dot5 14
`define bits_addr 4 // 16 entries for pos/neg each

module exp_lut(
    input [31:0] in_fixedp,
    output [31:0] out_slope,
    output [31:0] out_intercept
);
    wire overflow;
    wire is_neg;
    wire [`bits_addr:0] valid_addr; // bits_addr+1 bits including the sign bit
    
    assign overflow   = |(in_fixedp[30:`bits_addr+`lowbit_dot5]);
    assign is_neg     = in_fixedp[31];
    assign valid_addr = {in_fixedp[31], in_fixedp[`lowbit_dot5+`bits_addr-1:`lowbit_dot5]};
    assign out_slope =  (~is_neg && overflow)? 32'd0:
						(~overflow && valid_addr == 5'd0)? 32'd2147509434:
						(~overflow && valid_addr == 5'd1)? 32'd2147499288:
						(~overflow && valid_addr == 5'd2)? 32'd2147493134:
						(~overflow && valid_addr == 5'd3)? 32'd2147489401:
						(~overflow && valid_addr == 5'd4)? 32'd2147487137:
						(~overflow && valid_addr == 5'd5)? 32'd2147485764:
						(~overflow && valid_addr == 5'd6)? 32'd2147484931:
						(~overflow && valid_addr == 5'd7)? 32'd2147484426:
						(~overflow && valid_addr == 5'd8)? 32'd2147484120:
						(~overflow && valid_addr == 5'd9)? 32'd2147483934:
						(~overflow && valid_addr == 5'd10)? 32'd2147483821:
						(~overflow && valid_addr == 5'd11)? 32'd2147483753:
						(~overflow && valid_addr == 5'd12)? 32'd2147483711:
						(~overflow && valid_addr == 5'd13)? 32'd2147483686:
						(~overflow && valid_addr == 5'd14)? 32'd2147483671:
						(~overflow && valid_addr == 5'd15)? 32'd2147483684:
						32'd0;
    assign out_intercept =  (~is_neg && overflow)? 32'd0:
							(~overflow && valid_addr == 5'd0)? 32'd32768:
							(~overflow && valid_addr == 5'd1)? 32'd27694:
							(~overflow && valid_addr == 5'd2)? 32'd21540:
							(~overflow && valid_addr == 5'd3)? 32'd15942:
							(~overflow && valid_addr == 5'd4)? 32'd11414:
							(~overflow && valid_addr == 5'd5)? 32'd7981:
							(~overflow && valid_addr == 5'd6)? 32'd5482:
							(~overflow && valid_addr == 5'd7)? 32'd3714:
							(~overflow && valid_addr == 5'd8)? 32'd2489:
							(~overflow && valid_addr == 5'd9)? 32'd1653:
							(~overflow && valid_addr == 5'd10)? 32'd1089:
							(~overflow && valid_addr == 5'd11)? 32'd713:
							(~overflow && valid_addr == 5'd12)? 32'd464:
							(~overflow && valid_addr == 5'd13)? 32'd301:
							(~overflow && valid_addr == 5'd14)? 32'd194:
							(~overflow && valid_addr == 5'd15)? 32'd289:
							32'd0;
endmodule
