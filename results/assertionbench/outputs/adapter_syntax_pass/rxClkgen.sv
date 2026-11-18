module rxClkgen_sva (
    input logic rxclk_in,
    input logic reset,
    input logic rxclk,
    input logic rxclk_180,
    input logic locked
);

    // rxclk is a direct copy of rxclk_in.
    check_rxclk_passthrough: assert property (
        @($global_clock) rxclk === rxclk_in
    );

    // rxclk_180 is the inverted copy of rxclk_in.
    check_rxclk_180_inverted: assert property (
        @($global_clock) rxclk_180 === ~rxclk_in
    );

    // locked is the inverse of reset.
    check_locked_inverse_of_reset: assert property (
        @($global_clock) locked === ~reset
    );

    // locked is high whenever reset is low.
    check_locked_high_when_reset_low: assert property (
        @($global_clock) (reset === 1'b0) |-> (locked === 1'b1)
    );

    // locked is low whenever reset is high.
    check_locked_low_when_reset_high: assert property (
        @($global_clock) (reset === 1'b1) |-> (locked === 1'b0)
    );

    // rxclk and rxclk_180 are always complementary.
    check_rxclk_180_complementary: assert property (
        @($global_clock) (rxclk_180 === ~rxclk)
    );

    // rxclk and rxclk_180 are never equal.
    check_rxclk_180_never_equal: assert property (
        @($global_clock) (rxclk_180 !== rxclk)
    );

endmodule