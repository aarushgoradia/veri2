module clean_rst_sva (
    input logic clk,
    input logic rsti,
    input logic rsto
);

    // rsto is high whenever rsti is high.
    check_rsto_high_during_reset: assert property (
        @(posedge clk) rsti |-> (rsto == 1'b1)
    );

    // rsto is low on the first clock after reset deasserts.
    check_rsto_low_on_reset_release: assert property (
        @(posedge clk) disable iff (rsti) $fell(rsti) |-> (rsto == 1'b0)
    );

    // rsto is high on the first clock after reset deasserts.
    check_rsto_high_on_reset_release: assert property (
        @(posedge clk) disable iff (rsti) $fell(rsti) |-> ##0 (rsto == 1'b1)
    );

    // rsto is low on the first clock after reset is asserted.
    check_rsto_low_on_reset_assert: assert property (
        @(posedge clk) disable iff (rsti) $rose(rsti) |-> (rsto == 1'b0)
    );

    // rsto is high on the first clock after reset is asserted.
    check_rsto_high_on_reset_assert: assert property (
        @(posedge clk) disable iff (rsti) $rose(rsti) |-> ##0 (rsto == 1'b1)
    );

endmodule