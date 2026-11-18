module can_register_asyn_syn_sva #(
    parameter WIDTH = 8,
    parameter RESET_VALUE = 0
) (
    input logic [WIDTH-1:0] data_in,
    input logic             we,
    input logic             clk,
    input logic             rst,
    input logic             rst_sync,
    input logic [WIDTH-1:0] data_out
);

    // Reset forces the registered output to RESET_VALUE.
    check_reset_value: assert property (
        @(posedge clk) rst |-> (data_out == RESET_VALUE)
    );

    // Synchronous reset overrides a write and forces the registered output to RESET_VALUE.
    check_sync_reset_priority: assert property (
        @(posedge clk) (rst && rst_sync) |-> (data_out == RESET_VALUE)
    );

    // A write updates the registered output to data_in.
    check_write_updates_output: assert property (
        @(posedge clk) disable iff (rst) we |-> (data_out == data_in)
    );

    // Without a write, the registered output holds its value.
    check_hold_without_write: assert property (
        @(posedge clk) disable iff (rst) !we |-> (data_out == $past(data_out))
    );

endmodule