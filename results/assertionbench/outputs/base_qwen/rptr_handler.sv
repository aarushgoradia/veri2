```systemverilog
module rptr_handler_sva (
    input logic rclk,
    input logic rrst_n,
    input logic r_en,
    input logic [PTR_WIDTH:0] g_wptr_sync,
    output logic [PTR_WIDTH:0] b_rptr,
    output logic [PTR_WIDTH:0] g_rptr,
    output logic empty
);
    // Sequential logic for b_rptr and g_rptr
    // b_rptr increments when r_en is high and empty is low
    b_rptr_update: assert property (
        @(posedge rclk) disable iff (!rrst_n) (r_en & !empty) |-> b_rptr == b_rptr_next
    );
    // g_rptr is updated based on b_rptr_next
    g_rptr_update: assert property (
        @(posedge rclk) disable iff (!rrst_n) g_rptr == g_rptr_next
    );
    // g_rptr_next is calculated as (b_rptr_next >> 1) ^ b_rptr_next
    g_rptr_next_calc: assert property (
        @(posedge rclk) disable iff (!rrst_n) g_rptr_next == (b_rptr_next >> 1) ^ b_rptr_next
    );
    // b_rptr_next is calculated as b_rptr + (r_en & !empty)
    b_rptr_next_calc: assert property (
        @(posedge rclk) disable iff (!rrst_n) b_rptr_next == b_rptr + (r_en & !empty)
    );
    // empty is updated based on rempty
    empty_update: assert property (
        @(posedge rclk) disable iff (!rrst_n) empty == rempty
    );
    // rempty is calculated as (g_wptr_sync == g_rptr_next)
    rempty_calc: assert property (
        @(posedge rclk) disable iff (!rrst_n) rempty == (g_wptr_sync == g_rptr_next)
    );
    // At reset, b_rptr and g_rptr are driven to 0
    reset_b_rptr: assert property (
        @(posedge rclk) !rrst_n |-> b_rptr == 0
    );
    // At reset, g_rptr is driven to 0
    reset_g_rptr: assert property (
        @(posedge rclk) !rrst_n |-> g_rptr == 0
    );
    // At reset, empty is driven to 1
    reset_empty: assert property (
        @(posedge rclk) !rrst_n |-> empty == 1
    );
endmodule
```