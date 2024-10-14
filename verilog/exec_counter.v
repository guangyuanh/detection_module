`timescale 1ns / 1ps

module exec_counter(
    input in_clk,
    input in_reset,
    output [31:0] out_cycle
    );
    
    reg [31:0] execution_cycle;
    always @(posedge in_clk) begin
        if (in_reset) begin
            execution_cycle <= 32'd0;
        end
        else begin
            execution_cycle <= execution_cycle+1;
        end
    end
    
    assign out_cycle = execution_cycle;
endmodule
