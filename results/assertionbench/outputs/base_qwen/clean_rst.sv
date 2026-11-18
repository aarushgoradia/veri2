```systemverilog
module clean_rst_sva (
    input logic clk,
    input logic rsti,
    output logic rsto
);
    // Reset polarity is active LOW
    // Sequential logic with clocked assertions

    // At reset assertion, rsto should be driven LOW
    reset_assertion: assert property (
        @(posedge clk) disable iff (!rsti) rsto == 1'b0
    ) else $error("rsto should be LOW at reset");

    // After reset, rsto should follow the value of rsti
    rsti_follows_rsto: assert property (
        @(posedge clk) disable iff (!rsti) (rsti == rsto)
    ) else $error("rsto should follow the value of rsti after reset");

    // rsto should be stable after reset
    rsto_stable: assert property (
        @(posedge clk) disable iff (!rsti) ##1 rsto == rsto
    ) else $error("rsto should be stable after reset");

    // rsto should be LOW when rsti is LOW
    rsti_low_rsto_low: assert property (
        @(posedge clk) disable iff (!rsti) (rsti == 1'b0) |-> (rsto == 1'b0)
    ) else $error("rsto should be LOW when rsti is LOW");

    // rsto should be HIGH when rsti is HIGH
    rsti_high_rsto_high: assert property (
        @(posedge clk) disable iff (!rsti) (rsti == 1'b1) |-> (rsto == 1'b1)
    ) else $error("rsto should be HIGH when rsti is HIGH");

    // rsto should not change when rsti is LOW
    rsti_low_rsto_no_change: assert property (
        @(posedge clk) disable iff (!rsti) (rsti == 1'b0) |-> ##1 rsto == rsto
    ) else $error("rsto should not change when rsti is LOW");

    // rsto should not change when rsti is HIGH
    rsti_high_rsto_no_change: assert property (
        @(posedge clk) disable iff (!rsti) (rsti == 1'b1) |-> ##1 rsto == rsto
    ) else $error("rsto should not change when rsti is HIGH");

    // rsto should be stable after reset
    rsto_stable_after_reset: assert property (
        @(posedge clk) disable iff (!rsti) ##1 rsto == rsto
    ) else $error("rsto should be stable after reset");

    // rsto should be LOW when rsti is LOW
    rsti_low_rsto_low_after_reset: assert property (
        @(posedge clk) disable iff (!rsti) (rsti == 1'b0) |-> (rsto == 1'b0)
    ) else $error("rsto should be LOW when rsti is LOW after reset");

    // rsto should be HIGH when rsti is HIGH
    rsti_high_rsto_high_after_reset: assert property (
        @(posedge clk) disable iff (!rsti) (rsti == 1'b1) |-> (rsto == 1'b1)
    ) else $error("rsto should be HIGH when rsti is HIGH after reset");
endmodule
```