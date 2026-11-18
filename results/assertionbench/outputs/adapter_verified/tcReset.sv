module tcReset_sva (
    input logic clk,
    input logic tcResetEn,
    input logic resetIn,
    input logic [`tcAddrLen-1:0] tcAddr,
    input logic [`tcNumbers-1:0] resetOut
);

// resetOut is a combinational function of tcResetEn, resetIn, and tcAddr.
    check_resetout_function: assert property (
        @(posedge clk) resetOut == (tcResetEn ? {`tcNumbers{resetIn}} : {`tcNumbers{1'b0}})
    );

// When tcResetEn is LOW, resetOut is all zeros.
    check_reset_disabled_clears_output: assert property (
        @(posedge clk) !tcResetEn |-> (resetOut == {`tcNumbers{1'b0}})
    );

// When tcResetEn is HIGH, resetOut is all ones.
    check_reset_enabled_sets_output: assert property (
        @(posedge clk) tcResetEn |-> (resetOut == {`tcNumbers{1'b1}})
    );

// When tcResetEn is HIGH, resetOut matches the replicated resetIn value.
    check_reset_enabled_matches_replicated_input: assert property (
        @(posedge clk) tcResetEn |-> (resetOut == {`tcNumbers{resetIn}})
    );

// When tcResetEn is LOW, any change on resetIn has no effect on resetOut.
    check_reset_disabled_ignores_input_change: assert property (
        @(posedge clk) !tcResetEn && $changed(resetIn) |-> (resetOut == $past(resetOut))
    );

// When tcResetEn is HIGH, a rising edge on resetIn propagates to all bits of resetOut.
    check_reset_enabled_rise_propagates_to_output: assert property (
        @(posedge clk) tcResetEn && $rose(resetIn) |-> (resetOut == {`tcNumbers{1'b1}})
    );

// When tcResetEn is HIGH, a falling edge on resetIn propagates to all bits of resetOut.
    check_reset_enabled_fall_propagates_to_output: assert property (
        @(posedge clk) tcResetEn && $fell(resetIn) |-> (resetOut == {`tcNumbers{1'b0}})
    );

endmodule
