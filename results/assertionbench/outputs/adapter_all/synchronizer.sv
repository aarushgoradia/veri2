module synchronizer_sva #(
    parameter WIDTH = 3
) (
    input logic clk,
    input logic rst_n,
    input logic [WIDTH:0] d_in,
    input logic [WIDTH:0] d_out
);

    // Reset forces the output low.
    check_reset_forces_output_low: assert property (
        @(posedge clk) !rst_n |-> (d_out == '0)
    );

    // The output is still low on the first clock after reset release.
    check_output_low_on_reset_release: assert property (
        @(posedge clk) disable iff (!rst_n)
        $rose(rst_n) |-> (d_out == '0)
    );

    // The output reflects the input from the previous clock.
    check_output_matches_previous_input: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> (d_out == $past(d_in))
    );

    // A high output must come from a high input on the previous clock.
    check_output_high_requires_previous_input_high: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> (d_out == '0 || $past(d_in) == '1)
    );

    // A low output must come from a low input on the previous clock.
    check_output_low_requires_previous_input_low: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> (d_out == '0 || $past(d_in) == '0)
    );

endmodule