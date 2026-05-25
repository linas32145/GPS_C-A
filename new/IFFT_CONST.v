`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 18:36:08
// Design Name: 
// Module Name: IFFT_CONST
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


module IFFT_CONST(
    output wire [407:0] val_const
    );
    wire [11:0] FFT_DIRECTION=12'b000000000000;
    wire [21:0] FFT_SCHEDULE=22'b00_00_00_01_00_01_01_00_00_01_01_01;
    assign val_const = {132'b0, {12{FFT_SCHEDULE}}, FFT_DIRECTION};
endmodule
