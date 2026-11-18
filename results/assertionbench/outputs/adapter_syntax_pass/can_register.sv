module can_register_sva #(
    parameter WIDTH = 8
) (
    input logic [WIDTH-1:0] data_in,
    input logic             we,
    input logic             clk,
    input logic [WIDTH-1:0] data_out
);

    // data_out must equal the previous cycle's data_in when we was high.
    check_write_capture: assert property (
        @(posedge clk) we |=> (data_out == $past(data_in))
    );

    // data_out must hold its value when we was low.
    check_hold_when_not_we: assert property (
        @(posedge clk) !we |=> (data_out == $past(data_out))
    );

    // data_out must change only when we was high in the prior cycle.
    check_change_requires_previous_we: assert property (
        @(posedge clk) $changed(data_out) |-> $past(we)
    );

    // data_out must not change when we was low in the prior cycle.
    check_no_change_when_previous_we_low: assert property (
        @(posedge clk) !$past(we) |-> !$changed(data_out)
    );

endmodule