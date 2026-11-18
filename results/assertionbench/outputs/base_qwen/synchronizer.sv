```systemverilog
module synchronizer_sva (
    input logic clk,
    input logic rst_n,
    input logic [2:0] d_in,
    output logic [2:0] d_out
);
    ///// Synchronization logic /////
    // d_out should always be equal to d_in after one clock cycle.
    sync_check: assert property (
        @(posedge clk) disable iff (!rst_n) d_out == d_in
    );
    // d_out should be 0 at reset.
    reset_check: assert property (
        @(posedge clk) !rst_n |-> d_out == 0
    );
endmodule
```