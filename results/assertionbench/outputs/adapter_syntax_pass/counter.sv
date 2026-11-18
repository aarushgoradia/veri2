module counter_sva #(
    parameter WIDTH = 8
) (
    input logic clk,
    input logic reset,
    input logic load,
    input logic en,
    input logic [WIDTH-1:0] value
);

    // Reset forces the counter to zero.
    check_reset_clears_value: assert property (
        @(posedge clk) reset |-> (value == {WIDTH{1'b0}})
    );

    // Load clears the counter on the next clock.
    check_load_clears_value: assert property (
        @(posedge clk) disable iff (reset)
        load |=> (value == {WIDTH{1'b0}})
    );

    // Load has priority over enable when both are asserted.
    check_load_priority_over_enable: assert property (
        @(posedge clk) disable iff (reset)
        (load && en) |=> (value == {WIDTH{1'b0}})
    );

    // Enable increments the counter when load is low.
    check_enable_increments_value: assert property (
        @(posedge clk) disable iff (reset)
        (!load && en) |=> (value == ($past(value) + 1'b1))
    );

    // The counter holds its value when load and enable are both low.
    check_hold_when_idle: assert property (
        @(posedge clk) disable iff (reset)
        (!load && !en) |=> (value == $past(value))
    );

    // The counter wraps from all ones back to zero when enabled.
    check_wrap_from_max: assert property (
        @(posedge clk) disable iff (reset)
        (!load && en && (value == {WIDTH{1'b1}})) |=> (value == {WIDTH{1'b0}})
    );

endmodule