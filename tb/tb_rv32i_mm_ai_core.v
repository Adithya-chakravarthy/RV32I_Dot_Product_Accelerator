`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2026 18:52:03
// Design Name: 
// Module Name: tb_rv32i_mm_ai_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module tb_rv32i_mm_ai_core;

reg clk;
reg reset;
reg [2:0] debug_select;

wire [31:0] debug_out;
wire ai_done;

rv32i_mm_ai_core DUT(
    .clk(clk),
    .reset(reset),
    .debug_select(debug_select),
    .debug_out(debug_out),
    .ai_done(ai_done)
);

always #5 clk = ~clk;

initial
begin
    clk = 0;
    reset = 1;
    debug_select = 3'b100; // accelerator result

    #20;
    reset = 0;

    // Wait enough time for CPU to configure accelerator, start it, and read result
    #1500;

    debug_select = 3'b100;
    #10;
    $display("Accelerator Result = %d", debug_out);

    debug_select = 3'b101;
    #10;
    $display("Register x5 Result = %d", debug_out);

    debug_select = 3'b110;
    #10;
    $display("Register x6 Cycles = %d", debug_out);

    debug_select = 3'b111;
    #10;
    $display("Accelerator Cycles = %d", debug_out);

    $display("AI Done = %b", ai_done);

    $finish;
end

endmodule
