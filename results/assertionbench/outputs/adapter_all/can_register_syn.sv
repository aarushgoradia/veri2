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
    check_reset_loads_value: assert property (
        @(posedge clk) rst_sync |=> (data_out == RESET_VALUE)
    );

    // With reset low and write high, the register captures data_in.
    check_write_captures_input: assert property (
        @(posedge clk) disable iff (rst_sync) we |=> (data_out == $past(data_in))
    );

    // With reset low and write low, the register holds its value.
    check_hold_when_write_low: assert property (
        @(posedge clk) disable iff (rst_sync) !we |=> (data_out == $past(data_out))
    );

    // Any change in the register must come from reset or a prior write.
    check_change_requires_reset_or_write: assert property (
        @(posedge clk) disable iff (rst_sync) (data_out != $past(data_out)) |-> ($past(rst_sync) || $past(we))
    );

endmodule