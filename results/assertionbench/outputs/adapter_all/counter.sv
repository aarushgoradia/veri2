module counter_sva (
    input logic clk,
    input logic reset,
    input logic load,
    input logic en,
    input logic [7:0] value
);

    // Reset clears the counter on the next clock.
    check_reset_clears_value: assert property (
        @(posedge clk) reset |=> (value == 8'h00)
    );

    // Load clears the counter on the next clock.
    check_load_clears_value: assert property (
        @(posedge clk) disable iff (reset) load |=> (value == 8'h00)
    );

    // Load has priority over enable when both are asserted.
    check_load_priority_over_enable: assert property (
        @(posedge clk) disable iff (reset) (load && en) |=> (value == 8'h00)
    );

    // Enable increments the counter when load is low.
    check_enable_increments_value: assert property (
        @(posedge clk) disable iff (reset) (!load && en) |=> (value == ($past(value) + 8'd1))
    );

    // The counter holds its value when load and enable are both low.
    check_hold_when_idle: assert property (
        @(posedge clk) disable iff (reset) (!load && !en) |=> (value == $past(value))
    );

    // The counter wraps from 0xFF to 0x00 when enabled.
    check_wrap_from_max: assert property (
        @(posedge clk) disable iff (reset) (!load && en && (value == 8'hFF)) |=> (value == 8'h00)
    );

endmodule