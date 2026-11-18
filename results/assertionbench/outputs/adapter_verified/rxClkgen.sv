module rxClkgen_sva (
    input logic rxclk_in,
    input logic reset,
    input logic rxclk,
    input logic rxclk_180,
    input logic locked
);

// rxclk is a direct copy of rxclk_in.
    check_rxclk_passthrough: assert property (
        @(posedge rxclk_in) disable iff (reset) (rxclk == rxclk_in)
    );

// rxclk_180 is the bitwise complement of rxclk_in.
    check_rxclk_180_complement: assert property (
        @(posedge rxclk_in) disable iff (reset) (rxclk_180 == ~rxclk_in)
    );

// locked is the inverse of reset.
    check_locked_inverts_reset: assert property (
        @(posedge rxclk_in) (locked == ~reset)
    );

// When reset is asserted, locked must be low.
    check_locked_low_on_reset: assert property (
        @(posedge rxclk_in) reset |-> (locked == 1'b0)
    );

// When reset is low, locked must be high.
    check_locked_high_when_not_reset: assert property (
        @(posedge rxclk_in) !reset |-> (locked == 1'b1)
    );

// When reset is low, rxclk equals rxclk_in.
    check_rxclk_equals_input_when_not_reset: assert property (
        @(posedge rxclk_in) !reset |-> (rxclk == rxclk_in)
    );

// When reset is low, rxclk_180 is the bitwise complement of rxclk_in.
    check_rxclk_180_complement_when_not_reset: assert property (
        @(posedge rxclk_in) !reset |-> (rxclk_180 == ~rxclk_in)
    );

endmodule
