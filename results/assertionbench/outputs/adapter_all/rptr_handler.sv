module rptr_handler_sva #(parameter PTR_WIDTH=3) (
    input logic rclk,
    input logic rrst_n,
    input logic r_en,
    input logic [PTR_WIDTH:0] g_wptr_sync,
    input logic [PTR_WIDTH:0] b_rptr,
    input logic [PTR_WIDTH:0] g_rptr,
    input logic empty
);

    // Reset forces both pointers and empty low.
    check_reset_state: assert property (
        @(posedge rclk) !rrst_n |-> (b_rptr == '0) && (g_rptr == '0) && (empty == 1'b1)
    );

    // empty reflects whether the current g_rptr matches the previous g_wptr_sync.
    check_empty_matches_previous_wptr: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        (!$initstate && $past(rrst_n)) |-> (empty == ($past(g_wptr_sync) == $past(g_rptr)))
    );

    // empty is the registered version of rempty from the previous cycle.
    check_empty_tracks_rempy: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        (!$initstate && $past(rrst_n)) |-> (empty == $past(rempty))
    );

    // rempty is the XOR of the previous b_rptr and b_rptr shifted right by one.
    check_rempy_matches_previous_bptr: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        (!$initstate && $past(rrst_n)) |-> (rempty == (($past(b_rptr) >> 1) ^ $past(b_rptr)))
    );

    // b_rptr holds its value when reset is asserted.
    check_b_rptr_holds_during_reset: assert property (
        @(posedge rclk) !rrst_n |=> (b_rptr == $past(b_rptr))
    );

    // g_rptr holds its value when reset is asserted.
    check_g_rptr_holds_during_reset: assert property (
        @(posedge rclk) !rrst_n |=> (g_rptr == $past(g_rptr))
    );

    // empty holds its value when reset is asserted.
    check_empty_holds_during_reset: assert property (
        @(posedge rclk) !rrst_n |=> (empty == $past(empty))
    );

    // b_rptr updates from the previous cycle's b_rptr_next.
    check_b_rptr_updates_from_previous_next: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        (!$initstate && $past(rrst_n)) |-> (b_rptr == ($past(b_rptr) + ($past(r_en) & ~$past(empty))))
    );

    // g_rptr updates from the previous cycle's g_rptr_next.
    check_g_rptr_updates_from_previous_next: assert property (
        @(posedge rclk) disable iff (!rrst_n)
        (!$initstate && $past(rrst_n)) |-> (g_rptr == (($past(b_rptr) >> 1) ^ $past(b_rptr)))
    );

endmodule