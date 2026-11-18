module can_register_syn_sva #(
    parameter WIDTH = 8,
    parameter RESET_VALUE = 0
) (
    input logic [WIDTH-1:0] data_in,
    input logic             we,
    input logic             clk,
    input logic             rst_sync,
    input logic [WIDTH-1:0] data_out
);

    // Reset drives the register to RESET_VALUE on the next clock.
    check_reset_clears_output: assert property (
        @(posedge clk) rst_sync |=> (data_out == RESET_VALUE)
    );

    // With reset inactive, a write updates the register with data_in.
    check_write_updates_output: assert property (
        @(posedge clk) disable iff (rst_sync) we |=> (data_out == $past(data_in))
    );

    // With reset inactive, a non-write leaves the register unchanged.
    check_hold_when_not_written: assert property (
        @(posedge clk) disable iff (rst_sync) !we |=> (data_out == $past(data_out))
    );

endmodule