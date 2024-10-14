`timescale 1ns / 1ps

`define SPAD_ADDR_BITS 4
`define SPAD_SIZE 16

module local_scratchpad(
    input [`SPAD_ADDR_BITS-1:0] in_raddr,
    input [`SPAD_ADDR_BITS-1:0] in_waddr,
    input [127:0] in_data,
    input in_we,
    input in_clk,
    output [127:0] out_data
);

    //integer fd;
    
    //initial begin
    //    fd = $fopen("output_data_ram.txt","w");
    //end
    
    reg [127:0] local_mem [`SPAD_SIZE-1:0];
    
    assign out_data = local_mem[in_raddr];
    
    always@(posedge in_clk) begin
        if(in_we) begin
            local_mem[in_waddr] <= in_data;
            //$fwrite(fd,"%h\n",valid_addr_z);
            //$fwrite(fd,"%h\n",in_data_z);
        end
    end
endmodule
