module wptr_handler_sva #(parameter PTR_WIDTH=3) (
    input logic wclk,
    input logic wrst_n,
    input logic w_en,
    input logic [PTR_WIDTH:0] g_rptr_sync,
    input logic [PTR_WIDTH:0] b_wptr,
    input logic [PTR_WIDTH:0] g_wptr,
    input logic full
);

    // Reset clears the binary write pointer.
    check_b_wptr_reset: assert property (
        @(posedge wclk) !wrst_n |-> (b_wptr == {PTR_WIDTH+1{1'b0}})
    );

    // Reset clears the gray write pointer.
    check_g_wptr_reset: assert property (
        @(posedge wclk) !wrst_n |-> (g_wptr == {PTR_WIDTH+1{1'b0}})
    );

    // Reset clears the full flag.
    check_full_reset: assert property (
        @(posedge wclk) !wrst_n |-> (full == 1'b0)
    );

    // The binary write pointer holds when write enable is low.
    check_b_wptr_hold_when_disabled: assert property (
        @(posedge wclk) disable iff (!wrst_n)
        !w_en |=> (b_wptr == $past(b_wptr))
    );

    // The binary write pointer increments by one when enabled.
    check_b_wptr_increment_when_enabled: assert property (
        @(posedge wclk) disable iff (!wrst_n)
        w_en |=> (b_wptr == ($past(b_wptr) + 1'b1))
    );

    // The gray write pointer is the previous binary write pointer.
    check_g_wptr_tracks_b_wptr: assert property (
        @(posedge wclk) disable iff (!wrst_n)
        1'b1 |=> (g_wptr == $past(b_wptr))
    );

    // The full flag holds when the next gray pointer does not match the read pointer.
    check_full_holds_when_not_full: assert property (
        @(posedge wclk) disable iff (!wrst_n)
        !($past(g_wptr_next) == {~$past(g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1]), $past(g_rptr_sync[PTR_WIDTH-2:0])})
        |=> (full == $past(full))
    );

    // The full flag sets when the next gray pointer matches the read pointer.
    check_full_sets_when_full: assert property (
        @(posedge wclk) disable iff (!wrst_n)
        ($past(g_wptr_next) == {~$past(g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1]), $past(g_rptr_sync[PTR_WIDTH-2:0])})
        |=> (full == 1'b1)
    );

endmodule