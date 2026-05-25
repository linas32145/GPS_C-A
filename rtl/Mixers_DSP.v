`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.05.2026 14:04:45
// Design Name: 
// Module Name: Mixers_DSP
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


module Mixers_DSP#(
    parameter integer N_MIXERS = 8
) (
    input  wire                       aclk,
    input  wire [47:0]                s_axis_a_tdata,            
    input  wire                       s_axis_a_tvalid,
    output wire                       s_axis_a_tready,
    input  wire                       s_axis_a_tlast,
    input  wire [N_MIXERS*16-1:0]     s_axis_b_tdata,           
    input  wire                       s_axis_b_tvalid,
    output wire                       s_axis_b_tready,
    input  wire                       s_axis_b_tlast,
    output wire [N_MIXERS*48-1:0]     m_axis_dout_tdata,         
    output wire                       m_axis_dout_tvalid,
    input  wire                       m_axis_dout_tready,
    output wire                       m_axis_dout_tlast
);
    wire [N_MIXERS-1:0] a_tready_lane;
    wire [N_MIXERS-1:0] b_tready_lane;
    wire [N_MIXERS-1:0] dout_tvalid_lane;
    wire [N_MIXERS-1:0] dout_tlast_lane;

    genvar i;
    generate
        for (i = 0; i < N_MIXERS; i = i + 1) begin : g_cmpy
            cmpy_1 u_cmpy (
                .aclk               (aclk),
                .s_axis_a_tvalid    (s_axis_a_tvalid),
                .s_axis_a_tready    (a_tready_lane[i]),
                .s_axis_a_tlast     (s_axis_a_tlast),
                .s_axis_a_tdata     (s_axis_a_tdata),                 
                .s_axis_b_tvalid    (s_axis_b_tvalid),
                .s_axis_b_tready    (b_tready_lane[i]),
                .s_axis_b_tlast     (s_axis_b_tlast),
                .s_axis_b_tdata     (s_axis_b_tdata[i*16 +: 16]),     
                .m_axis_dout_tvalid (dout_tvalid_lane[i]),
                .m_axis_dout_tready (m_axis_dout_tready),
                .m_axis_dout_tlast  (dout_tlast_lane[i]),
                .m_axis_dout_tdata  (m_axis_dout_tdata[i*48 +: 48])
            );
        end
    endgenerate

    assign s_axis_a_tready    = &a_tready_lane;
    assign s_axis_b_tready    = &b_tready_lane;
    assign m_axis_dout_tvalid = &dout_tvalid_lane;
    assign m_axis_dout_tlast  = &dout_tlast_lane;
    
endmodule