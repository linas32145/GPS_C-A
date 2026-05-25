`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 15:56:03
// Design Name: 
// Module Name: phase_acc_sweep
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


module phase_acc_sweep #(
    parameter real    F_SAMPLE_HZ    = 100_000_000.0,
    parameter real    F_START_HZ     =  -1_000_000.0,
    parameter real    F_STOP_HZ      =  10_000_000.0,
    parameter real    F_STEP_HZ      =     100_000.0,
    parameter integer SWEEP_INTERVAL = 2024,
    parameter integer ACC_WIDTH      = 32
)(
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 en,
    output reg  [15:0]          m_axis_phase_tdata,
    output reg                  m_axis_phase_tvalid,
    input  wire                 m_axis_phase_tready
);
    localparam signed [ACC_WIDTH-1:0] PHASE_INC_START =
        (F_START_HZ / F_SAMPLE_HZ) * (2.0 ** ACC_WIDTH);
    localparam signed [ACC_WIDTH-1:0] PHASE_INC_STOP  =
        (F_STOP_HZ  / F_SAMPLE_HZ) * (2.0 ** ACC_WIDTH);
    localparam signed [ACC_WIDTH-1:0] PHASE_INC_STEP  =
        (F_STEP_HZ  / F_SAMPLE_HZ) * (2.0 ** ACC_WIDTH);

    localparam integer CNT_WIDTH =
        (SWEEP_INTERVAL <= 1) ? 1 : $clog2(SWEEP_INTERVAL);

    reg        [ACC_WIDTH-1:0] phase_acc;
    reg signed [ACC_WIDTH-1:0] phase_inc;
    reg        [CNT_WIDTH-1:0] sweep_cnt;

    wire [15:0] phase_q3_13 =
        { {3{phase_acc[ACC_WIDTH-1]}},
          phase_acc[ACC_WIDTH-2 -: 13] };

    always @(posedge clk) begin
        if (!rst_n) begin
            phase_acc           <= {ACC_WIDTH{1'b0}};
            phase_inc           <= PHASE_INC_START;
            sweep_cnt           <= {CNT_WIDTH{1'b0}};
            m_axis_phase_tdata  <= 16'h0000;
            m_axis_phase_tvalid <= 1'b0;
        end else begin
            m_axis_phase_tvalid <= en;

            if (en && m_axis_phase_tready) begin
                m_axis_phase_tdata <= phase_q3_13;
                phase_acc          <= phase_acc + phase_inc;
                if (sweep_cnt == SWEEP_INTERVAL-1) begin
                    sweep_cnt <= {CNT_WIDTH{1'b0}};
                    if ($signed(phase_inc + PHASE_INC_STEP) > $signed(PHASE_INC_STOP))
                        phase_inc <= PHASE_INC_START;
                    else
                        phase_inc <= phase_inc + PHASE_INC_STEP;
                end else begin
                    sweep_cnt <= sweep_cnt + 1'b1;
                end
            end
        end
    end
endmodule