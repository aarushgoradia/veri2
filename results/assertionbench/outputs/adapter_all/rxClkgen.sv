module rxClkgen_sva (
    input logic rxclk_in,
    input logic reset,
    input logic rxclk,
    input logic rxclk_180,
    input logic locked
);
    // rxclk mirrors rxclk_in.
    check_rxclk_mirrors_input: assert property (
        @(posedge rxclk_in) rxclk == 1'b1
    );

    // rxclk_180 is the complement of rxclk_in.
    check_rxclk_180_complement: assert property (
        @(posedge rxclk_in) rxclk_180 == 1'b0
    );

    // locked is the inverse of reset.
    check_locked_inverts_reset: assert property (
        @(posedge rxclk_in) locked == !reset
    );

    // When reset is asserted, locked must be 0.
    check_locked_low_when_reset: assert property (
        @(posedge rxclk_in) reset |-> (locked == 1'b0)
    );

    // When reset is deasserted, locked must be 1.
    check_locked_high_when_reset_deasserted: assert property (
        @(posedge rxclk_in) !reset |-> (locked == 1'b1)
    );

    // rxclk_180 is always the complement of rxclk.
    check_rxclk_180_complement_of_rxclk: assert property (
        @(posedge rxclk) rxclk_180 == 1'b0
    );

    // rxclk is always high when sampled on rxclk_in rising edge.
    check_rxclk_high_on_input_edge: assert property (
        @(posedge rxclk_in) rxclk == 1'b1
    );

    // rxclk_180 is always low when sampled on rxclk_in rising edge.
    check_rxclk_180_low_on_input_edge: assert property (
        @(posedge rxclk_in) rxclk_180 == 1'b0
    );

    // locked is high when sampled on rxclk_in rising edge.
    check_locked_high_on_input_edge: assert property (
        @(posedge rxclk_in) locked == 1'b1
    );

    // rxclk_180 is the complement of rxclk when sampled on rxclk rising edge.
    check_rxclk_180_complement_of_rxclk_on_rxclk_edge: assert property (
        @(posedge rxclk) rxclk_180 == 1'b0
    );
endmodule