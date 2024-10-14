`timescale 1ns / 1ps

`define lowbit_idx 13 // step: 0.25
`define bits_addr 4 // 16 entries for pos/neg each

module tanh_rom(
input [31:0] in_fixedp,
    output [31:0] out_slope,
    output [31:0] out_intercept
);
    // tanh
    wire overflow;
    wire is_neg;
    wire [4:0] valid_addr;
    
    assign overflow   = |(in_fixedp[30:`lowbit_idx+`bits_addr]);
    assign is_neg     = in_fixedp[31];
    assign valid_addr = {in_fixedp[31], in_fixedp[`lowbit_idx+`bits_addr-1:`lowbit_idx]};
    assign out_slope =  (~is_neg && overflow)? 32'd0:
						(~overflow && valid_addr == 5'd15)? 32'd144:
						(~overflow && valid_addr == 5'd14)? 32'd93:
						(~overflow && valid_addr == 5'd13)? 32'd154:
						(~overflow && valid_addr == 5'd12)? 32'd254:
						(~overflow && valid_addr == 5'd11)? 32'd418:
						(~overflow && valid_addr == 5'd10)? 32'd687:
						(~overflow && valid_addr == 5'd9)? 32'd1125:
						(~overflow && valid_addr == 5'd8)? 32'd1834:
						(~overflow && valid_addr == 5'd7)? 32'd2969:
						(~overflow && valid_addr == 5'd6)? 32'd4748:
						(~overflow && valid_addr == 5'd5)? 32'd7453:
						(~overflow && valid_addr == 5'd4)? 32'd11362:
						(~overflow && valid_addr == 5'd3)? 32'd16573:
						(~overflow && valid_addr == 5'd2)? 32'd22679:
						(~overflow && valid_addr == 5'd1)? 32'd28468:
						(~overflow && valid_addr == 5'd0)? 32'd32101:
						(~overflow && valid_addr == 5'd16)? 32'd32101:
						(~overflow && valid_addr == 5'd17)? 32'd28468:
						(~overflow && valid_addr == 5'd18)? 32'd22679:
						(~overflow && valid_addr == 5'd19)? 32'd16573:
						(~overflow && valid_addr == 5'd20)? 32'd11362:
						(~overflow && valid_addr == 5'd21)? 32'd7453:
						(~overflow && valid_addr == 5'd22)? 32'd4748:
						(~overflow && valid_addr == 5'd23)? 32'd2969:
						(~overflow && valid_addr == 5'd24)? 32'd1834:
						(~overflow && valid_addr == 5'd25)? 32'd1125:
						(~overflow && valid_addr == 5'd26)? 32'd687:
						(~overflow && valid_addr == 5'd27)? 32'd418:
						(~overflow && valid_addr == 5'd28)? 32'd254:
						(~overflow && valid_addr == 5'd29)? 32'd154:
						(~overflow && valid_addr == 5'd30)? 32'd93:
						(~overflow && valid_addr == 5'd31)? 32'd144:
						(is_neg && overflow)? 32'd0:32'd0;
    assign out_intercept =  (~is_neg && overflow)? 32'd32768:
							(~overflow && valid_addr == 5'd15)? 32'd32188:
							(~overflow && valid_addr == 5'd14)? 32'd32379:
							(~overflow && valid_addr == 5'd13)? 32'd32166:
							(~overflow && valid_addr == 5'd12)? 32'd31841:
							(~overflow && valid_addr == 5'd11)? 32'd31349:
							(~overflow && valid_addr == 5'd10)? 32'd30610:
							(~overflow && valid_addr == 5'd9)? 32'd29515:
							(~overflow && valid_addr == 5'd8)? 32'd27919:
							(~overflow && valid_addr == 5'd7)? 32'd25651:
							(~overflow && valid_addr == 5'd6)? 32'd22537:
							(~overflow && valid_addr == 5'd5)? 32'd18479:
							(~overflow && valid_addr == 5'd4)? 32'd13593:
							(~overflow && valid_addr == 5'd3)? 32'd8382:
							(~overflow && valid_addr == 5'd2)? 32'd3802:
							(~overflow && valid_addr == 5'd1)? 32'd908:
							(~overflow && valid_addr == 5'd0)? 32'd0:
							(~overflow && valid_addr == 5'd16)? 32'd0:
							(~overflow && valid_addr == 5'd17)? 32'd2147484556:
							(~overflow && valid_addr == 5'd18)? 32'd2147487450:
							(~overflow && valid_addr == 5'd19)? 32'd2147492030:
							(~overflow && valid_addr == 5'd20)? 32'd2147497241:
							(~overflow && valid_addr == 5'd21)? 32'd2147502127:
							(~overflow && valid_addr == 5'd22)? 32'd2147506185:
							(~overflow && valid_addr == 5'd23)? 32'd2147509299:
							(~overflow && valid_addr == 5'd24)? 32'd2147511567:
							(~overflow && valid_addr == 5'd25)? 32'd2147513163:
							(~overflow && valid_addr == 5'd26)? 32'd2147514258:
							(~overflow && valid_addr == 5'd27)? 32'd2147514997:
							(~overflow && valid_addr == 5'd28)? 32'd2147515489:
							(~overflow && valid_addr == 5'd29)? 32'd2147515814:
							(~overflow && valid_addr == 5'd30)? 32'd2147516027:
							(~overflow && valid_addr == 5'd31)? 32'd2147515836:
							(is_neg && overflow)? 32'd2147516416:32'd0;
endmodule
