`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 17:11:56
// Design Name: 
// Module Name: packer
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


module packer(
    input  wire [15:0]  in0,
    input  wire [15:0]  in1,
    input  wire [15:0]  in2,
    input  wire [15:0]  in3,
    input  wire [15:0]  in4,
    input  wire [15:0]  in5,
    input  wire [15:0]  in6,
    input  wire [15:0]  in7,
    input  wire [15:0]  in8,
    input  wire [15:0]  in9,
    input  wire [15:0]  in10,
    input  wire [15:0]  in11,
    output wire [191:0] packed_out
);

    assign packed_out = {in11, in10, in9, in8, in7, in6, in5, in4, in3,  in2,  in1, in0};

endmodule
