`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.05.2026 11:24:48
// Design Name: 
// Module Name: SNR_calc
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


module SNR_calc#(
    parameter N_CHANNELS = 12,
    parameter POWER_W    = 48,    // width of peak/noise power inputs
    parameter SNR_INT_W  = 8,     // signed integer dB bits
    parameter SNR_FRAC_W = 8      // fractional dB bits (1/256 dB)
) (
    input  wire                              clk,
    input  wire                              rst_n,
 
    input  wire [N_CHANNELS-1:0]             in_valid,
    input  wire [N_CHANNELS*POWER_W-1:0]     peak_power,
    input  wire [N_CHANNELS*POWER_W-1:0]     noise_power,
 
    output wire [N_CHANNELS-1:0]             out_valid,
    output wire [N_CHANNELS*(SNR_INT_W+SNR_FRAC_W)-1:0] snr_db
);
 
    localparam SNR_W = SNR_INT_W + SNR_FRAC_W;
    localparam LOG_W = SNR_W + 4;             // headroom for log2 result
 
    genvar gi;
    generate
        for (gi = 0; gi < N_CHANNELS; gi = gi + 1) begin : g_ch
 
            wire [POWER_W-1:0] pk;
            wire [POWER_W-1:0] nz;
            assign pk = peak_power [gi*POWER_W +: POWER_W];
            assign nz = noise_power[gi*POWER_W +: POWER_W];
 
            wire [LOG_W-1:0] log2_pk_w;
            wire [LOG_W-1:0] log2_nz_w;
 
            log2_approx #(
                .IN_W   (POWER_W),
                .OUT_W  (LOG_W),
                .FRAC_W (SNR_FRAC_W)
            ) u_log2_pk (
                .x  (pk),
                .y  (log2_pk_w)
            );
 
            log2_approx #(
                .IN_W   (POWER_W),
                .OUT_W  (LOG_W),
                .FRAC_W (SNR_FRAC_W)
            ) u_log2_nz (
                .x  (nz),
                .y  (log2_nz_w)
            );
 
            snr_one_channel #(
                .LOG_W      (LOG_W),
                .SNR_W      (SNR_W),
                .SNR_FRAC_W (SNR_FRAC_W)
            ) u_pipe (
                .clk        (clk),
                .rst_n      (rst_n),
                .in_valid   (in_valid[gi]),
                .log2_pk    (log2_pk_w),
                .log2_nz    (log2_nz_w),
                .out_valid  (out_valid[gi]),
                .snr_db     (snr_db[gi*SNR_W +: SNR_W])
            );
 
        end
    endgenerate
 
endmodule
 
 
// =============================================================================
// snr_one_channel
// -----------------------------------------------------------------------------
// Per-channel 2-stage pipeline. Pulled out of the generate block so signed
// arithmetic behaves consistently across simulators.
// =============================================================================
module snr_one_channel #(
    parameter LOG_W      = 20,
    parameter SNR_W      = 16,
    parameter SNR_FRAC_W = 8
) (
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          in_valid,
    input  wire [LOG_W-1:0]              log2_pk,
    input  wire [LOG_W-1:0]              log2_nz,
    output reg                           out_valid,
    output reg  [SNR_W-1:0]              snr_db
);
 
    // 10 / log2(10) = 3.0103, encoded as Q4.12 = 12333 (unsigned)
    localparam [13:0] DB_SCALE = 14'd12333;
 
    // -------------------------------------------------------------------------
    // Stage 1: signed subtraction of log2 values
    // log2 values are non-negative, so we just sign-extend with a leading 0.
    // -------------------------------------------------------------------------
    wire signed [LOG_W:0]    pk_s    = {1'b0, log2_pk};
    wire signed [LOG_W:0]    nz_s    = {1'b0, log2_nz};
    wire signed [LOG_W:0]    diff_w  = pk_s - nz_s;
 
    reg  signed [LOG_W:0]    diff_r;
    reg                      valid_s1;
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            diff_r   <= {(LOG_W+1){1'b0}};
            valid_s1 <= 1'b0;
        end else begin
            diff_r   <= diff_w;
            valid_s1 <= in_valid;
        end
    end
 
    // -------------------------------------------------------------------------
    // Stage 2: multiply by 3.0103 (Q4.12), shift right by 12 to remove scale,
    // saturate to SNR_W bits.
    // diff_r is signed Q(LOG-FRAC).(FRAC). DB_SCALE is unsigned Q4.12.
    // We treat DB_SCALE as signed-positive by zero-extending.
    // -------------------------------------------------------------------------
    wire signed [14:0]            db_scale_s = {1'b0, DB_SCALE};
    wire signed [LOG_W+15:0]      product    = diff_r * db_scale_s;
    wire signed [LOG_W+3:0]       scaled     = product >>> 12;
 
    // Saturation thresholds (signed, sized to compare against `scaled`)
    wire signed [LOG_W+3:0]       max_thr    = {{(LOG_W+4-SNR_W){1'b0}},
                                                 1'b0, {(SNR_W-1){1'b1}}};
    wire signed [LOG_W+3:0]       min_thr    = {{(LOG_W+4-SNR_W){1'b1}},
                                                 1'b1, {(SNR_W-1){1'b0}}};
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            snr_db    <= {SNR_W{1'b0}};
            out_valid <= 1'b0;
        end else begin
            if (scaled > max_thr)
                snr_db <= {1'b0, {(SNR_W-1){1'b1}}};       // +max
            else if (scaled < min_thr)
                snr_db <= {1'b1, {(SNR_W-1){1'b0}}};       // -max
            else
                snr_db <= scaled[SNR_W-1:0];
            out_valid <= valid_s1;
        end
    end
 
endmodule
 
 
// =============================================================================
// log2_approx
// -----------------------------------------------------------------------------
// Combinational log2 approximation:
//   log2(x) = k + frac
// where k is the position of the leading '1' bit, and frac is the next FRAC_W
// bits below that '1' (linear interpolation of 1+x/2^k).
// Output format: unsigned Q(OUT_W-FRAC_W).(FRAC_W).
// =============================================================================
module log2_approx #(
    parameter IN_W   = 48,
    parameter OUT_W  = 20,
    parameter FRAC_W = 8
) (
    input  wire [IN_W-1:0]    x,
    output reg  [OUT_W-1:0]   y
);
 
    integer i;
    integer k;
    reg [IN_W-1:0]    shifted;
    reg [FRAC_W-1:0]  frac;
 
    always @(*) begin
        // Find leading '1' position (highest index)
        k = 0;
        for (i = 0; i < IN_W; i = i + 1) begin
            if (x[i])
                k = i;
        end
 
        if (x == {IN_W{1'b0}}) begin
            y = {OUT_W{1'b0}};
        end else begin
            shifted = {IN_W{1'b0}};
            frac    = {FRAC_W{1'b0}};
            if (k >= FRAC_W) begin
                frac = x[k-1 -: FRAC_W];
            end else if (k > 0) begin
                shifted = x << (FRAC_W - k);
                frac    = shifted[FRAC_W-1:0];
            end
 
            // Pack: top bits = k (integer part), low FRAC_W bits = frac
            y = {{(OUT_W-FRAC_W-12){1'b0}}, k[11:0], frac};
        end
    end
 
endmodule