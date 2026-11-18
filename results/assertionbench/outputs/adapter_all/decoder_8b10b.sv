module decoder_8b10b_sva (
    input logic reset,
    input logic RBYTECLK,
    input logic [9:0] tbi,
    input logic K_out,
    input logic [7:0] ebi,
    input logic coding_err,
    input logic disparity,
    input logic disparity_err
);

    // Reset drives all registered outputs high.
    check_reset_state: assert property (
        @(posedge RBYTECLK) reset |-> (K_out == 1'b1 && ebi == 8'h00 && coding_err == 1'b1 && disparity == 1'b0 && disparity_err == 1'b1)
    );

    // K_out reflects the registered K value from the previous cycle.
    check_k_out_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        $past(!reset) |-> (K_out == $past(K))
    );

    // ebi reflects the registered 8-bit byte from the previous cycle.
    check_ebi_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        $past(!reset) |-> (ebi == $past({H, G, F, E, D, C, B, A}))
    );

    // coding_err reflects the registered coding error from the previous cycle.
    check_coding_err_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        $past(!reset) |-> (coding_err == $past(cerr | zerr | xerr))
    );

    // disparity reflects the registered disparity value from the previous cycle.
    check_disparity_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        $past(!reset) |-> (disparity == $past(fghjP31 | (DISPARITY6b & fghj22)))
    );

    // disparity_err reflects the registered disparity error from the previous cycle.
    check_disparity_err_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        $past(!reset) |-> (disparity_err == $past(derr12 | derr34 | derr56 | derr78))
    );

    // coding_err is high whenever any coding error source is asserted.
    check_coding_err_sources: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        (cerr | zerr | xerr) |-> (coding_err == 1'b1)
    );

    // disparity_err is high whenever any disparity error source is asserted.
    check_disparity_err_sources: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        (derr12 | derr34 | derr56 | derr78) |-> (disparity_err == 1'b1)
    );

    // A high coding error forces disparity_err high on the next cycle.
    check_coding_err_sets_disparity_err: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        coding_err |=> (disparity_err == 1'b1)
    );

    // A high disparity error forces coding_err high on the next cycle.
    check_disparity_err_sets_coding_err: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        disparity_err |=> (coding_err == 1'b1)
    );

    // A high coding error forces disparity low on the next cycle.
    check_coding_err_clears_disparity: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        coding_err |=> (disparity == 1'b0)
    );

    // A high disparity forces coding_err low on the next cycle.
    check_disparity_clears_coding_err: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        disparity |=> (coding_err == 1'b0)
    );

endmodule