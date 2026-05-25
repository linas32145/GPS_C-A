`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2026 14:50:18
// Design Name: 
// Module Name: packer_7_to_1
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


module packer_7_to_1(
    input  wire [15:0]  in0,
    input  wire [15:0]  in1,
    input  wire [15:0]  in2,
    input  wire [15:0]  in3,
    input  wire [15:0]  in4,
    input  wire [15:0]  in5,
    input  wire [15:0]  in6,
    input  wire [15:0]  in7,
    output wire [127:0] packed_out
);

    assign packed_out = {in7, in6, in5, in4, in3,  in2,  in1, in0};

endmodule
