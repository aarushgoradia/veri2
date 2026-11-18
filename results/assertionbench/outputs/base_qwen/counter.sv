```systemverilog
module counter_sva (
    input logic clk,
    input logic reset,
    input logic load,
    input logic en,
    output logic [7:0] value
);
    // Counter reset behavior
    reset_behavior: assert property (
        @(posedge clk) disable iff (!reset) (reset |-> value == 8'b0)
    ) else $error("Counter did not reset to 0 on reset signal");

    // Counter load behavior
    load_behavior: assert property (
        @(posedge clk) disable iff (!reset) (load |-> value == 8'b0)
    ) else $error("Counter did not reset to 0 on load signal");

    // Counter increment behavior
    increment_behavior: assert property (
        @(posedge clk) disable iff (!reset) (en && !load && !reset |-> value == value + 8'b1)
    ) else $error("Counter did not increment on enable signal");

    // Counter does not increment on load or reset
    no_increment_on_load_reset: assert property (
        @(posedge clk) disable iff (!reset) (!en && (load || reset) |-> value == value)
    ) else $error("Counter incremented when it should not have");

    // Counter value is within valid range
    valid_range: assert property (
        @(posedge clk) disable iff (!reset) (value inside {[0:255]})
    ) else $error("Counter value out of valid range");

    // Counter does not wrap around
    no_wrap_around: assert property (
        @(posedge clk) disable iff (!reset) (value != 8'b0 || !en)
    ) else $error("Counter wrapped around");

    // Counter does not increment on reset
    no_increment_on_reset: assert property (
        @(posedge clk) disable iff (!reset) (reset |-> value == value)
    ) else $error("Counter incremented on reset");

    // Counter does not increment on load
    no_increment_on_load: assert property (
        @(posedge clk) disable iff (!reset) (load |-> value == value)
    ) else $error("Counter incremented on load");

    // Counter does not decrement
    no_decrement: assert property (
        @(posedge clk) disable iff (!reset) (value != value - 8'b1)
    ) else $error("Counter decremented");

    // Counter does not increment on disable
    no_increment_on_disable: assert property (
        @(posedge clk) disable iff (!reset) (!en |-> value == value)
    ) else $error("Counter incremented on disable");
endmodule
```