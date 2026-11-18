module rptr_handler_sva (
    input logic rclk,
    input logic rrst_n,
    input logic r_en,
    input logic [PTR_WIDTH:0] g_wptr_sync,
    input logic [PTR_WIDTH:0] b_rptr,
    input logic [PTR_WIDTH:0] g_rptr,
    input logic empty
);

// Clock: rclk; Reset: rrst_n active-low, asynchronous.
    // Logic: mixed (combinational next-state, sequential empty).
    // Behavior: b_rptr increments when r_en is high and not empty; g_rptr is b_rptr shifted right by 1 XOR b_rptr; empty is asserted when g_wptr_sync equals g_rptr.

    // During reset, b_rptr is 0 on the next cycle.
    check_b_rptr_zero_on_reset: assert property (
        @(posedge rclk) !rrst_n |=> (b_rptr == 1'b0)
    );

// During reset, g_rptr is 0 on the next cycle.
    check_g_rptr_zero_on_reset: assert property (
        @(posedge rclk) !rrst_n |=> (g_rptr == 1'b0)
    );

// During reset, empty is 1 on the next cycle.
    check_empty_one_on_reset: assert property (
        @(posedge rclk) !rrst_n |=> (empty == 1'b1)
    );

// When r_en is 0 or empty is 1, b_rptr holds its value.
    check_b_rptr_hold_when_disabled: assert property (
        @(posedge rclk) disable iff (!rrst_n) (!r_en || empty) |=> (b_rptr == $past(b_rptr))
    );

// When r_en is 1 and not empty, b_rptr increments by 1.
    check_b_rptr_increment_when_enabled: assert property (
        @(posedge rclk) disable iff (!rrst_n) (r_en && !empty) |=> (b_rptr == ($past(b_rptr) + 1))
    );

// g_rptr is the previous b_rptr shifted right by 1 XOR b_rptr.
    check_g_rptr_next_state: assert property (
        @(posedge rclk) disable iff (!rrst_n) 1'b1 |=> (g_rptr == (($past(b_rptr) >> 1) ^ $past(b_rptr)))
    );

// empty is asserted when g_wptr_sync equals g_rptr.
    check_empty_matches_g_wptr_eq_g_rptr: assert property (
        @(posedge rclk) disable iff (!rrst_n) (g_wptr_sync == g_rptr) |-> (empty == 1'b1)
    );

// empty is deasserted when g_wptr_sync differs from g_rptr.
    check_empty_matches_g_wptr_ne_g_rptr: assert property (
        @(posedge rclk) disable iff (!rrst_n) (g_wptr_sync != g_rptr) |-> (empty == 1'b0)
    );

endmodule
