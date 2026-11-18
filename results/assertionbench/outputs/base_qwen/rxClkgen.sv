```systemverilog
module rxClkgen_sva (
    input logic rxclk_in,
    input logic reset,
    output logic rxclk,
    output logic rxclk_180,
    output logic locked
);
    // Clock and reset signals
    logic clk = rxclk_in;
    logic resetn = ~reset;

    // Assertions
    // rxclk should be the same as rxclk_in
    clk_assignment: assert property (
        @(posedge clk) disable iff (!resetn) (rxclk == rxclk_in)
    ) else $error("rxclk should be the same as rxclk_in");

    // rxclk_180 should be the inverse of rxclk
    clk_180_assignment: assert property (
        @(posedge clk) disable iff (!resetn) (rxclk_180 == ~rxclk)
    ) else $error("rxclk_180 should be the inverse of rxclk");

    // locked should be the inverse of reset
    locked_assignment: assert property (
        @(posedge clk) disable iff (!resetn) (locked == ~reset)
    ) else $error("locked should be the inverse of reset");

    // rxclk_in should not be used directly as an output
    clk_in_not_output: assert property (
        @(posedge clk) disable iff (!resetn) !(rxclk_in == rxclk)
    ) else $error("rxclk_in should not be used directly as an output");

    // rxclk_in should not be used directly as an output
    clk_in_not_output_180: assert property (
        @(posedge clk) disable iff (!resetn) !(rxclk_in == rxclk_180)
    ) else $error("rxclk_in should not be used directly as an output");

    // rxclk_in should not be used directly as an output
    clk_in_not_output_locked: assert property (
        @(posedge clk) disable iff (!resetn) !(rxclk_in == locked)
    ) else $error("rxclk_in should not be used directly as an output");

    // rxclk should not be used directly as an output
    clk_not_output: assert property (
        @(posedge clk) disable iff (!resetn) !(rxclk == rxclk_in)
    ) else $error("rxclk should not be used directly as an output");

    // rxclk_180 should not be used directly as an output
    clk_180_not_output: assert property (
        @(posedge clk) disable iff (!resetn) !(rxclk_180 == rxclk_in)
    ) else $error("rxclk_180 should not be used directly as an output");

    // locked should not be used directly as an output
    locked_not_output: assert property (
        @(posedge clk) disable iff (!resetn) !(locked == rxclk_in)
    ) else $error("locked should not be used directly as an output");

endmodule
```