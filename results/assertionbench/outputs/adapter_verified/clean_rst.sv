module clean_rst_sva (
    input logic clk,
    input logic rsti,
    input logic rsto
);

// rsto is HIGH whenever rsti is HIGH.
    check_rsto_high_when_rsti_high: assert property (
        @(posedge clk) rsti |-> (rsto == 1'b1)
    );

// rsto is LOW on the first clock after rsti rises.
    check_rsto_low_after_rsti_rise: assert property (
        @(posedge clk) $rose(rsti) |-> (rsto == 1'b0)
    );

// rsto is HIGH on the second clock after rsti rises.
    check_rsto_high_after_two_cycles_from_rsti_rise: assert property (
        @(posedge clk) $rose(rsti) |-> ##1 (rsto == 1'b1)
    );

// rsto is HIGH on the first clock after rsti falls.
    check_rsto_high_after_rsti_fall: assert property (
        @(posedge clk) $fell(rsti) |-> (rsto == 1'b1)
    );

// rsto is LOW on the second clock after rsti falls.
    check_rsto_low_after_two_cycles_from_rsti_fall: assert property (
        @(posedge clk) $fell(rsti) |-> ##1 (rsto == 1'b0)
    );

endmodule
