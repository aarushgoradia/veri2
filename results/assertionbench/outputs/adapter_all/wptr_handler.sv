module wptr_handler_sva #(parameter PTR_WIDTH=3) (
    input logic wclk,
    input logic wrst_n,
    input logic w_en,
    input logic [PTR_WIDTH:0] g_rptr_sync,
    input logic [PTR_WIDTH:0] b_wptr,
    input logic [PTR_WIDTH:0] g_wptr,
    input logic full
);

    // Reset clears both pointers and the full flag.
    check_reset_clears_state: assert property (
        @(posedge wclk) !wrst_n |-> (b_wptr == '0) && (g_wptr == '0) && (full == 1'b0)
    );

    // Binary pointer holds when write enable is low.
    check_binary_pointer_holds_when_disabled: assert property (
        @(posedge wclk) disable iff (!wrst_n)
        !w_en |=> (b_wptr == $past(b_wptr))
    );

    // Binary pointer increments by one when write enable is high.
    check_binary_pointer_increments_when_enabled: assert property (
        @(posedge wclk) disable iff (!wrst_n)
        w_en |=> (b_wptr == ($past(b_wptr) + 1'b1))
    );

    // Gray pointer updates from the previous binary pointer value.
    check_gray_pointer_updates_from_previous_binary: assert property (
        @(posedge wclk) disable iff (!wrst_n)
        1'b1 |=> (g_wptr == (($past(b_wptr) >> 1) ^ $past(b_wptr)))
    );

    // Full reflects whether the next gray pointer equals the next read pointer.
    check_full_matches_next_pointer_compare: assert property (
        @(posedge wclk) disable iff (!wrst_n)
        1'b1 |=> (full == (($past(b_wptr) + 1'b1) == ({~$past(g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1]), $past(g_rptr_sync[PTR_WIDTH-2:0])})))
    );

    // Full holds when the next compare result is false.
    check_full_holds_when_next_compare_false: assert property (
        @(posedge wclk) disable iff (!wrst_n)
        !((($past(b_wptr) + 1'b1) == ({~$past(g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1]), $past(g_rptr_sync[PTR_WIDTH-2:0])}))) |=> (full == $past(full))
    );

    // Full sets when the next compare result is true.
    check_full_sets_when_next_compare_true: assert property (
        @(posedge wclk) disable iff (!wrst_n)
        (($past(b_wptr) + 1'b1) == ({~$past(g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1]), $past(g_rptr_sync[PTR_WIDTH-2:0])})) |=> (full == 1'b1)
    );

endmodule