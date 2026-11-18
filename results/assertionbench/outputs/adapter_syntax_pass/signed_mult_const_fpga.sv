module signed_mult_const_fpga_sva #(
    parameter int N = 8
) (
    input logic rstn,
    input logic clk,
    input logic valid,
    input logic signed [N-1:0] a,
    input logic signed [(N+16):0] p
);

    // Reset clears the registered input path.
    check_reset_clears_a_ff: assert property (
        @(posedge clk) !rstn |=> (a == '0)
    );

    // A valid cycle loads the input into the registered path.
    check_valid_loads_a_ff: assert property (
        @(posedge clk) disable iff (!rstn)
        valid |=> (a == $past(a))
    );

    // Without valid, the registered input holds its value.
    check_no_valid_holds_a_ff: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid |=> (a == $past(a))
    );

    // The output is always the registered input shifted right by 16 bits.
    check_output_matches_registered_input: assert property (
        @(posedge clk) disable iff (!rstn)
        (p == ($signed(a) >> 16))
    );

    // A zero input produces a zero output.
    check_zero_input_produces_zero_output: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == '0) |-> (p == '0)
    );

    // A positive input produces a non-negative output.
    check_positive_input_produces_nonnegative_output: assert property (
        @(posedge clk) disable iff (!rstn)
        (a >= 0) |-> (p >= 0)
    );

    // A negative input produces a non-positive output.
    check_negative_input_produces_nonpositive_output: assert property (
        @(posedge clk) disable iff (!rstn)
        (a < 0) |-> (p <= 0)
    );

    // A zero output implies the registered input is zero.
    check_zero_output_implies_zero_input: assert property (
        @(posedge clk) disable iff (!rstn)
        (p == '0) |-> (a == '0)
    );

    // A non-negative output implies the registered input is non-negative.
    check_nonnegative_output_implies_nonnegative_input: assert property (
        @(posedge clk) disable iff (!rstn)
        (p >= 0) |-> (a >= 0)
    );

    // A non-positive output implies the registered input is non-positive.
    check_nonpositive_output_implies_nonpositive_input: assert property (
        @(posedge clk) disable iff (!rstn)
        (p <= 0) |-> (a <= 0)
    );

endmodule