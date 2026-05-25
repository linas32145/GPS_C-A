`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 18:51:54
// Design Name: 
// Module Name: fft_mag_top
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


module fft_mag_top#(
    parameter W     = 24,
    parameter MODE  = 1,
    parameter LANES = 12
)(
    input  wire                      aclk,
    input  wire                      aresetn,
    input  wire [LANES*2*W-1:0]      s_tdata,
    input  wire                      s_tvalid,
    output wire                      s_tready,
    input  wire                      s_tlast,
    (* dont_touch = "true" *)
    output wire [LANES*(2*W+1)-1:0]  m_tdata,
    (* dont_touch = "true" *)
    output wire                      m_tvalid,    
    input  wire                      m_tready,    
    (* dont_touch = "true" *)
    output wire                      m_tlast      
);
    localparam OW = 2*W + 1;          


    (* dont_touch = "true" *) wire [OW-1:0] m_tdata_lane  [0:LANES-1];
    (* dont_touch = "true" *) wire [LANES-1:0]  m_tvalid_lane;
    (* dont_touch = "true" *) wire [LANES-1:0]  m_tlast_lane;
    (* dont_touch = "true" *) wire [LANES-1:0]  s_tready_lane;

    genvar i;
    generate
        for (i = 0; i < LANES; i = i + 1) begin : g_pow
            fft_mag #(
                .W(W),
                .MODE(MODE)
            ) u_pow (
                .aclk     (aclk),
                .aresetn  (aresetn),
                .s_tdata  (s_tdata[i*2*W +: 2*W]),    
                .s_tvalid (s_tvalid),                 
                .s_tready (s_tready_lane[i]),
                .s_tlast  (s_tlast),                  
                .m_tdata  (m_tdata_lane[i]),
                .m_tvalid (m_tvalid_lane[i]),
                .m_tready (m_tready),                 
                .m_tlast  (m_tlast_lane[i])
            );
            assign m_tdata[i*OW +: OW] = m_tdata_lane[i];
        end
    endgenerate

   (* dont_touch = "true" *) assign s_tready = &s_tready_lane;
   (* dont_touch = "true" *) assign m_tvalid = &m_tvalid_lane;
   (* dont_touch = "true" *) assign m_tlast  = &m_tlast_lane;

endmodule
