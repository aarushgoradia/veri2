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

    // Reset forces the register output to the reset value.
    check_reset_forces_reset_value: assert property (
        @(posedge clk) rst |-> (data_out == RESET_VALUE)
    );

    // A synchronous reset overrides a write and loads the reset value.
    check_sync_reset_priority_over_write: assert property (
        @(posedge clk) disable iff (rst)
        rst_sync |-> (data_out == RESET_VALUE)
    );

    // With reset inactive, a write loads the input value into the register.
    check_write_loads_input_value: assert property (
        @(posedge clk) disable iff (rst)
        (!rst_sync && we) |-> (data_out == data_in)
    );

    // Without reset or write, the register holds its value.
    check_hold_when_idle: assert property (
        @(posedge clk) disable iff (rst)
        (!rst_sync && !we) |-> (data_out == $past(data_out))
    );

endmodule