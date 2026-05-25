`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.05.2026 14:06:25
// Design Name: 
// Module Name: CA_STREAM
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


module CA_STREAM#(
    parameter integer NUM_CHANNELS = 2
)(
    input  wire                        clk,
    input  wire                        rstn,
    input  wire [NUM_CHANNELS*16-1:0]  data,           
    input  wire                        m_axis_tready,
    output reg                         m_axis_tvalid,
    output wire                        m_axis_tlast,
    output reg  [NUM_CHANNELS*16-1:0]  m_axis_tdata,
    output reg  [10:0]                 addr           
);
 
    reg [10:0] send_cnt;
    reg        first;
    reg        second;   
 
    assign m_axis_tlast = m_axis_tvalid && (send_cnt == 11'd2047);
 
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            addr          <= 11'd0;
            send_cnt      <= 11'd0;
            m_axis_tdata  <= {(NUM_CHANNELS*16){1'b0}};
            m_axis_tvalid <= 1'b0;
            first         <= 1'b1;
            second        <= 1'b0;
        end else begin

            if (!m_axis_tvalid || m_axis_tready) begin
                addr <= (addr == 11'd2047) ? 11'd0 : addr + 1;
                if (first) begin
                    first         <= 1'b0;
                    second        <= 1'b1;
                    m_axis_tvalid <= 1'b0;
                end else if (second) begin
                    second        <= 1'b0;
                    m_axis_tvalid <= 1'b0;
                end else begin
                    m_axis_tvalid <= 1'b1;
                    m_axis_tdata  <= data;          
                    if (m_axis_tvalid && m_axis_tready) begin
                        send_cnt <= (send_cnt == 11'd2047) ? 11'd0 : send_cnt + 1;
                    end
                end
            end
        end
    end
 
endmodule