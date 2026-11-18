module can_register_sva #(
    parameter WIDTH = 8
) (
    input logic [WIDTH-1:0] data_in,
    input logic             we,
    input logic             clk,
    input logic [WIDTH-1:0] data_out
);

    // Output holds its value when the write enable is low.
    check_hold_when_disabled: assert property (
        @(posedge clk) !we |=> (data_out == $past(data_out))
    );

    // Output captures the input value when the write enable is high.
    check_capture_when_enabled: assert property (
        @(posedge clk) we |=> (data_out == $past(data_in))
    );

    // Any output change must come from a prior write enable.
    check_change_requires_enable: assert property (
        @(posedge clk) 1'b1 |=> ((data_out != $past(data_out)) |-> $past(we))
    );

    // A write with an unchanged input does not change the output.
    check_no_change_on_same_data: assert property (
        @(posedge clk) (we && (data_in == $past(data_in))) |=> (data_out == $past(data_out))
    );

    // A write with a different input changes the output.
    check_change_on_different_data: assert property (
        @(posedge clk) (we && (data_in != $past(data_in))) |=> (data_out != $past(data_out))
    );

endmodule