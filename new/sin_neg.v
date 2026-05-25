`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 18:05:21
// Design Name: 
// Module Name: sin_neg
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


module sin_neg(
    input  wire [15:0] data_in,
    output wire [15:0] data_out
);
    assign data_out = {data_in[15:8], -data_in[7:0]};
endmodule