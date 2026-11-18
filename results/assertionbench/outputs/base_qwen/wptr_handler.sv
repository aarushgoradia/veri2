```systemverilog
module wptr_handler_sva (
    input logic wclk,
    input logic wrst_n,
    input logic w_en,
    input [PTR_WIDTH:0] g_rptr_sync,
    output logic [PTR_WIDTH:0] b_wptr,
    output logic [PTR_WIDTH:0] g_wptr,
    output logic full
);
    // Sequential logic for write pointer and full flag
    // b_wptr should only increment when w_en is high and full is low
    b_wptr_increment: assert property (
        @(posedge wclk) disable iff (!wrst_n) (w_en & !full) |-> b_wptr == b_wptr_next
    );
    // g_wptr should be updated based on b_wptr_next
    g_wptr_update: assert property (
        @(posedge wclk) disable iff (!wrst_n) g_wptr == g_wptr_next
    );
    // full flag should be updated based on g_wptr_next and g_rptr_sync
    full_update: assert property (
        @(posedge wclk) disable iff (!wrst_n) full == wfull
    );
    // wfull should be high when g_wptr_next equals the circular buffer boundary
    wfull_check: assert property (
        @(posedge wclk) disable iff (!wrst_n) (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]}) |-> wfull == 1'b1
    );
    // b_wptr_next should be b_wptr incremented by 1 when w_en is high and full is low
    b_wptr_next_check: assert property (
        @(posedge wclk) disable iff (!wrst_n) (w_en & !full) |-> b_wptr_next == b_wptr + 1
    );
    // g_wptr_next should be the XOR of b_wptr_next shifted right by 1 and b_wptr_next
    g_wptr_next_check: assert property (
        @(posedge wclk) disable iff (!wrst_n) g_wptr_next == (b_wptr_next >> 1) ^ b_wptr_next
    );
    // b_wptr should not wrap around when w_en is high and full is low
    b_wptr_wrap_check: assert property (
        @(posedge wclk) disable iff (!wrst_n) (w_en & !full) |-> b_wptr_next != b_wptr
    );
    // g_wptr should not wrap around when w_en is high and full is low
    g_wptr_wrap_check: assert property (
        @(posedge wclk) disable iff (!wrst_n) (w_en & !full) |-> g_wptr_next != g_wptr
    );
    // b_wptr should be zero at reset
    b_wptr_reset_check: assert property (
        @(posedge wclk) !wrst_n |-> b_wptr == 0
    );
    // g_wptr should be zero at reset
    g_wptr_reset_check: assert property (
        @(posedge wclk) !wrst_n |-> g_wptr == 0
    );
    // full should be zero at reset
    full_reset_check: assert property (
        @(posedge wclk) !wrst_n |-> full == 0
    );
endmodule
```