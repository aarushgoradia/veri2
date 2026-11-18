module rptr_handler_sva #(parameter PTR_WIDTH=3) (
    input logic rclk,
    input logic rrst_n,
    input logic r_en,
    input logic [PTR_WIDTH:0] g_wptr_sync,
    input logic [PTR_WIDTH:0] b_rptr,
    input logic [PTR_WIDTH:0] g_rptr,
    input logic empty,
    input logic [PTR_WIDTH:0] b_rptr_next,
    input logic [PTR_WIDTH:0] g_rptr_next,
    input logic rempty
);

    // b_rptr_next is the incremented b_rptr when enabled, else b_rptr.
    check_b_rptr_next_function: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        b_rptr_next == (b_rptr + (r_en & !empty))
    );

    // g_rptr_next is the XOR of b_rptr_next shifted right by one and b_rptr_next.
    check_g_rptr_next_function: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        g_rptr_next == ((b_rptr_next >> 1) ^ b_rptr_next)
    );

    // rempty is the comparison of g_wptr_sync to g_rptr_next.
    check_reempty_function: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        rempty == (g_wptr_sync == g_rptr_next)
    );

    // g_rptr_next is the XOR of b_rptr shifted right by one and b_rptr.
    check_g_rptr_next_matches_b_rptr: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        g_rptr_next == ((b_rptr >> 1) ^ b_rptr)
    );

    // b_rptr_next is the XOR of b_rptr shifted right by one and b_rptr shifted left by one.
    check_b_rptr_next_matches_shifted_b_rptr: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        b_rptr_next == ((b_rptr >> 1) ^ (b_rptr << 1))
    );

    // g_rptr_next is the XOR of b_rptr shifted right by one and b_rptr shifted left by one.
    check_g_rptr_next_matches_shifted_b_rptr: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        g_rptr_next == ((b_rptr >> 1) ^ (b_rptr << 1))
    );

    // empty is the registered comparison of g_wptr_sync to g_rptr.
    check_empty_registered_compare: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        empty == (g_wptr_sync == g_rptr)
    );

    // rempty is the registered comparison of g_wptr_sync to g_rptr_next.
    check_reempty_registered_compare: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        rempty == (g_wptr_sync == g_rptr_next)
    );

    // b_rptr_next is the XOR of b_rptr shifted right by one and b_rptr shifted left by one.
    check_b_rptr_next_matches_shifted_b_rptr: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        b_rptr_next == ((b_rptr >> 1) ^ (b_rptr << 1))
    );

    // g_rptr_next is the XOR of b_rptr shifted right by one and b_rptr shifted left by one.
    check_g_rptr_next_matches_shifted_b_rptr: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        g_rptr_next == ((b_rptr >> 1) ^ (b_rptr << 1))
    );

endmodule