```systemverilog
module decoder_8b10b_sva (
    input logic RBYTECLK,
    input logic reset,
    input logic [9:0] tbi,
    output reg K_out,
    output reg [7:0] ebi,
    output reg coding_err,
    output reg disparity,
    output disparity_err
);

    // Reset polarity is active low
    // Sequential logic

    // K_out should be 0 at reset
    reset_k_out: assert property (
        @(posedge RBYTECLK) disable iff (!reset) K_out == 1'b0
    );

    // ebi should be 0 at reset
    reset_ebi: assert property (
        @(posedge RBYTECLK) disable iff (!reset) ebi == 8'b0
    );

    // coding_err should be 1 at reset
    reset_coding_err: assert property (
        @(posedge RBYTECLK) disable iff (!reset) coding_err == 1'b1
    );

    // disparity should be 0 at reset
    reset_disparity: assert property (
        @(posedge RBYTECLK) disable iff (!reset) disparity == 1'b0
    );

    // disparity_err should be 0 at reset
    reset_disparity_err: assert property (
        @(posedge RBYTECLK) disable iff (!reset) disparity_err == 1'b0
    );

    // K_out should be updated on every clock cycle
    k_out_update: assert property (
        @(posedge RBYTECLK) disable iff (!reset) K_out == K
    );

    // ebi should be updated on every clock cycle
    ebi_update: assert property (
        @(posedge RBYTECLK) disable iff (!reset) ebi == {H, G, F, E, D, C, B, A}
    );

    // coding_err should be updated on every clock cycle
    coding_err_update: assert property (
        @(posedge RBYTECLK) disable iff (!reset) coding_err == (cerr | zerr | xerr)
    );

    // disparity should be updated on every clock cycle
    disparity_update: assert property (
        @(posedge RBYTECLK) disable iff (!reset) disparity == fghjP31 | (DISPARITY6b & fghj22)
    );

    // disparity_err should be updated on every clock cycle
    disparity_err_update: assert property (
        @(posedge RBYTECLK) disable iff (!reset) disparity_err == (derr12 | derr34 | derr56 | derr78)
    );

endmodule
```