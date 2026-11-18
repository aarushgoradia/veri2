module signed_mult_const_asic_sva #(
    parameter int N = 8
) (
    input logic rstn,
    input logic clk,
    input logic valid,
    input logic [N-1:0] a,
    input logic [N:0] p
);

    // Reset clears the registered input path.
    check_reset_clears_a_ff: assert property (
        @(posedge clk) !rstn |=> (a == '0)
    );

    // Reset drives the output to zero.
    check_reset_clears_p: assert property (
        @(posedge clk) !rstn |=> (p == {1'b0, {N{1'b0}}})
    );

    // A valid input sample is captured into a_FF on the next cycle.
    check_a_ff_captures_valid_input: assert property (
        @(posedge clk) disable iff (!rstn)
        valid |=> (a == $past(a))
    );

    // An invalid input sample leaves a_FF unchanged.
    check_a_ff_holds_when_not_valid: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid |=> (a == $past(a))
    );

    // A positive input produces a zero-extended product.
    check_positive_input_output: assert property (
        @(posedge clk) disable iff (!rstn)
        a[N-1] == 1'b0 |-> (p == {1'b0, (a * 9'd362) >> 8})
    );

    // A negative input produces a one-extended two's complement product.
    check_negative_input_output: assert property (
        @(posedge clk) disable iff (!rstn)
        a[N-1] == 1'b1 |-> (p == {1'b1, ((~a) + 1'b1) >> 8})
    );

    // A zero input produces a zero output.
    check_zero_input_output: assert property (
        @(posedge clk) disable iff (!rstn)
        a == '0 |-> (p == {1'b0, {N{1'b0}}})
    );

    // A zero output only occurs for a zero input.
    check_zero_output_implies_zero_input: assert property (
        @(posedge clk) disable iff (!rstn)
        p == {1'b0, {N{1'b0}}} |-> (a == '0)
    );

    // A zero input produces a zero output.
    check_zero_input_output: assert property (
        @(posedge clk) disable iff (!rstn)
        a == '0 |-> (p == {1'b0, {N{1'b0}}})
    );

    // A zero output only occurs for a zero input.
    check_zero_output_implies_zero_input: assert property (
        @(posedge clk) disable iff (!rstn)
        p == {1'b0, {N{1'b0}}} |-> (a == '0)
    );

endmodule