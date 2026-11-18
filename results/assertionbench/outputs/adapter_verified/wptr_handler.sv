module wptr_handler_sva (
    input logic wclk,
    input logic wrst_n,
    input logic w_en,
    input logic [3:0] g_rptr_sync,
    input logic [3:0] b_wptr,
    input logic [3:0] g_wptr,
    input logic full
);

// Reset drives b_wptr, g_wptr, and full low.
    check_reset_clears_state: assert property (
        @(posedge wclk) !wrst_n |-> (b_wptr == 4'd0) && (g_wptr == 4'd0) && (full == 1'b0)
    );

// With w_en low, b_wptr holds its value.
    check_b_wptr_holds_when_disabled: assert property (
        @(posedge wclk) disable iff (!wrst_n) (!w_en) |=> (b_wptr == $past(b_wptr))
    );

// With w_en high and not full, b_wptr increments by one.
    check_b_wptr_increments_when_enabled: assert property (
        @(posedge wclk) disable iff (!wrst_n) (w_en && !full) |=> (b_wptr == ($past(b_wptr) + 4'd1))
    );

// With w_en high and full, b_wptr holds its value.
    check_b_wptr_holds_when_full: assert property (
        @(posedge wclk) disable iff (!wrst_n) (w_en && full) |=> (b_wptr == $past(b_wptr))
    );

// g_wptr is the Gray code of the next binary write pointer value.
    check_g_wptr_is_gray_of_next_b_wptr: assert property (
        @(posedge wclk) disable iff (!wrst_n) 1'b1 |=> (g_wptr == (($past(b_wptr_next) >> 1) ^ $past(b_wptr_next)))
    );

// When enabled and not full, g_wptr follows the Gray update from the incremented b_wptr.
    check_g_wptr_updates_when_enabled: assert property (
        @(posedge wclk) disable iff (!wrst_n) (w_en && !full) |=> (g_wptr == (($past(b_wptr) + 4'd1) >> 1) ^ ($past(b_wptr) + 4'd1))
    );

// When enabled and full, g_wptr holds its value.
    check_g_wptr_holds_when_full: assert property (
        @(posedge wclk) disable iff (!wrst_n) (w_en && full) |=> (g_wptr == $past(g_wptr))
    );

// full is high exactly when the next Gray write pointer equals the next Gray read pointer.
    check_full_matches_gray_pointer_comparison: assert property (
        @(posedge wclk) disable iff (!wrst_n) 1'b1 |=> (full == ((($past(b_wptr_next) >> 1) ^ $past(b_wptr_next)) == ((~$past(g_rptr_sync[3:3],1)) ^ $past(g_rptr_sync[2:0],1))))
    );

// When enabled and not full, full must be low on the next cycle.
    check_full_low_when_enabled_and_not_full: assert property (
        @(posedge wclk) disable iff (!wrst_n) (w_en && !full) |=> (full == 1'b0)
    );

// When enabled and full, full must be high on the next cycle.
    check_full_high_when_enabled_and_full: assert property (
        @(posedge wclk) disable iff (!wrst_n) (w_en && full) |=> (full == 1'b1)
    );

endmodule
