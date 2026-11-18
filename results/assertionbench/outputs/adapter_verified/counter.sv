module counter_sva (
    input logic clk,
    input logic reset,
    input logic load,
    input logic en,
    input logic [7:0] value
);

// Reset drives value to zero on the next clock.
    check_reset_clears_value: assert property (
        @(posedge clk) reset |=> (value == 8'h00)
    );

// Load forces value to zero on the next clock.
    check_load_clears_value: assert property (
        @(posedge clk) disable iff (reset)
        load |=> (value == 8'h00)
    );

// When enabled, value increments by one on the next clock.
    check_en_increments_value: assert property (
        @(posedge clk) disable iff (reset)
        (!load && en) |=> (value == ($past(value) + 8'd1))
    );

// When not enabled, value holds its previous value on the next clock.
    check_en_low_holds_value: assert property (
        @(posedge clk) disable iff (reset)
        (!load && !en) |=> (value == $past(value))
    );

// Load has priority over enable when both are asserted.
    check_load_priority_over_en: assert property (
        @(posedge clk) disable iff (reset)
        (load && en) |=> (value == 8'h00)
    );

endmodule
