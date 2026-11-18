module clean_rst_sva (
    input logic clk,
    input logic rsti,
    input logic rsto
);
    // Clock: clk; Reset: rsti (active-high, asynchronous). Sequential logic with two-stage reset clean.

    // rsto is HIGH whenever rsti is HIGH.
    check_rsto_high_when_rsti_high: assert property (
        @(posedge clk) rsti |-> (rsto == 1'b1)
    );

    // If rsti is LOW, rsto must be LOW.
    check_rsto_low_when_rsti_low: assert property (
        @(posedge clk) !rsti |-> (rsto == 1'b0)
    );

    // On rsti rising edge, rsto must be HIGH by the next clock.
    check_rsto_high_on_rsti_rise: assert property (
        @(posedge clk) $rose(rsti) |-> ##1 (rsto == 1'b1)
    );

    // On rsti falling edge, rsto must be LOW by the next clock.
    check_rsto_low_on_rsti_fall: assert property (
        @(posedge clk) $fell(rsti) |-> ##1 (rsto == 1'b0)
    );

    // If rsti is HIGH for two consecutive clocks, rsto is HIGH on the second clock.
    check_rsto_stays_high_while_rsti_high: assert property (
        @(posedge clk) (rsti && $past(rsti)) |-> (rsto == 1'b1)
    );

    // If rsti is LOW for two consecutive clocks, rsto is LOW on the second clock.
    check_rsto_stays_low_while_rsti_low: assert property (
        @(posedge clk) (!rsti && !$past(rsti)) |-> (rsto == 1'b0)
    );

    // If rsto is HIGH, rsti must be HIGH in the same cycle.
    check_rsti_high_when_rsto_high: assert property (
        @(posedge clk) (rsto == 1'b1) |-> (rsti == 1'b1)
    );

    // If rsto is LOW, rsti must be LOW in the same cycle.
    check_rsti_low_when_rsto_low: assert property (
        @(posedge clk) (rsto == 1'b0) |-> (rsti == 1'b0)
    );

    // On rsti rising edge, rsto is HIGH on the next clock.
    check_rsto_high_on_rsti_rise_next: assert property (
        @(posedge clk) $rose(rsti) |-> ##1 (rsto == 1'b1)
    );

    // On rsti falling edge, rsto is LOW on the next clock.
    check_rsto_low_on_rsti_fall_next: assert property (
        @(posedge clk) $fell(rsti) |-> ##1 (rsto == 1'b0)
    );

    // If rsti is HIGH for two consecutive clocks, rsto is HIGH on the next clock.
    check_rsto_next_high_while_rsti_high: assert property (
        @(posedge clk) (rsti && $past(rsti)) |-> ##1 (rsto == 1'b1)
    );

    // If rsti is LOW for two consecutive clocks, rsto is LOW on the next clock.
    check_rsto_next_low_while_rsti_low: assert property (
        @(posedge clk) (!rsti && !$past(rsti)) |-> ##1 (rsto == 1'b0)
    );

endmodule