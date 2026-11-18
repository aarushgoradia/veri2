module can_register_asyn_sva #(
    parameter WIDTH = 8,
    parameter RESET_VALUE = 0
) (
    input logic [WIDTH-1:0] data_in,
    input logic             we,
    input logic             clk,
    input logic             rst,
    input logic [WIDTH-1:0] data_out
);

    // Reset drives the register output to the reset value.
    check_reset_value: assert property (
        @(posedge clk) rst |-> (data_out == RESET_VALUE)
    );

    // With reset low, a write captures data_in on the next clock.
    check_write_captures_input: assert property (
        @(posedge clk) disable iff (rst) we |=> (data_out == $past(data_in))
    );

    // Without reset and without a write, the register holds its value.
    check_hold_without_write: assert property (
        @(posedge clk) disable iff (rst) !we |=> (data_out == $past(data_out))
    );

    // A reset cycle followed by a write loads the reset value.
    check_reset_then_write_loads_reset: assert property (
        @(posedge clk) rst ##1 we |=> (data_out == RESET_VALUE)
    );

    // A reset cycle followed by no write keeps the reset value.
    check_reset_then_hold_keeps_reset: assert property (
        @(posedge clk) rst ##1 !we |=> (data_out == RESET_VALUE)
    );

endmodule