module signed_mult_const_fpga_sva #(
    parameter int N = 8
) (
    input logic rstn,
    input logic clk,
    input logic valid,
    input  signed [N-1:0] a,
    input  signed [N  :0] p
);

    // Reset clears the registered input path by the next clock.
    check_reset_clears_a_ff: assert property (
        @(posedge clk) !rstn |=> (a == '0)
    );

    // Reset clears the registered output path by the next clock.
    check_reset_clears_p: assert property (
        @(posedge clk) !rstn |=> (p == '0)
    );

    // A valid cycle loads the input into the registered path.
    check_valid_loads_a_ff: assert property (
        @(posedge clk) disable iff (!rstn)
        valid |=> (a == $past(a))
    );

    // Without valid, the registered input path holds its value.
    check_no_valid_holds_a_ff: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid |=> (a == $past(a))
    );

    // The output is always the registered input path scaled by the constant.
    check_output_matches_scaled_a_ff: assert property (
        @(posedge clk) disable iff (!rstn)
        (p == ($signed($past(a)) * 18'sd92681) >> 16)
    );

    // A zero input produces a zero output.
    check_zero_input_produces_zero_output: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == '0) |-> (p == '0)
    );

    // A zero output implies the registered input path is zero.
    check_zero_output_implies_zero_a_ff: assert property (
        @(posedge clk) disable iff (!rstn)
        (p == '0) |-> ($past(a) == '0)
    );

    // A zero output implies the input was zero on the prior valid cycle.
    check_zero_output_implies_prior_valid_zero_input: assert property (
        @(posedge clk) disable iff (!rstn)
        (p == '0) |-> ($past(valid) && ($past(a) == '0))
    );

    // A nonzero output implies the registered input path is nonzero.
    check_nonzero_output_implies_nonzero_a_ff: assert property (
        @(posedge clk) disable iff (!rstn)
        (p != '0) |-> ($past(a) != '0)
    );

    // A nonzero output implies the prior valid cycle had a nonzero input.
    check_nonzero_output_implies_prior_valid_nonzero_input: assert property (
        @(posedge clk) disable iff (!rstn)
        (p != '0) |-> ($past(valid) && ($past(a) != '0))
    );

endmodule