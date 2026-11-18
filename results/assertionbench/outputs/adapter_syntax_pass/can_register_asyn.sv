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

    // Reset drives the register to RESET_VALUE on the next clock.
    check_reset_clears_output: assert property (
        @(posedge clk) rst |=> (data_out == RESET_VALUE)
    );

    // With write low, the register holds its previous value.
    check_hold_when_we_low: assert property (
        @(posedge clk) disable iff (rst) (!we) |=> (data_out == $past(data_out))
    );

    // With write high, the register captures data_in.
    check_capture_when_we_high: assert property (
        @(posedge clk) disable iff (rst) we |=> (data_out == $past(data_in))
    );

    // The register always matches the previous cycle's update rule.
    check_update_rule: assert property (
        @(posedge clk) disable iff (rst) 1'b1 |=> (data_out == ($past(we) ? $past(data_in) : $past(data_out)))
    );

endmodule