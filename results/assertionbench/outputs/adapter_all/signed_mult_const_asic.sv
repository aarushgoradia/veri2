module signed_mult_const_asic_sva #(
    parameter int N = 8
) (
    input logic        rstn,
    input logic        clk,
    input logic        valid,
    input logic [N-1:0] a,
    input logic [N:0]  p
);

    // Reset clears the registered output on the next clock.
    check_reset_clears_output: assert property (
        @(posedge clk) !rstn |=> (p == {1'b0, {N{1'b0}}})
    );

    // A valid input updates the registered output on the next clock.
    check_valid_updates_output: assert property (
        @(posedge clk) disable iff (!rstn)
        valid |=> (p == {1'b0, $past(a)})
    );

    // An invalid input leaves the registered output unchanged.
    check_invalid_holds_output: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid |=> (p == $past(p))
    );

    // The output is always zero-extended to N+1 bits.
    check_output_zero_extended: assert property (
        @(posedge clk) disable iff (!rstn)
        (p[N] == 1'b0)
    );

    // A zero input produces a zero output.
    check_zero_input_zero_output: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == {N{1'b0}}) |=> (p == {1'b0, {N{1'b0}}})
    );

    // A zero output implies the previous input was zero.
    check_zero_output_implies_zero_input: assert property (
        @(posedge clk) disable iff (!rstn)
        ($past(rstn) && (p == {1'b0, {N{1'b0}}})) |-> ($past(a) == {N{1'b0}})
    );

    // A nonzero output implies the previous input was nonzero.
    check_nonzero_output_implies_nonzero_input: assert property (
        @(posedge clk) disable iff (!rstn)
        ($past(rstn) && (p != {1'b0, {N{1'b0}}})) |-> ($past(a) != {N{1'b0}})
    );

    // The upper bit of the output is always zero after reset release.
    check_output_upper_bit_zero: assert property (
        @(posedge clk) disable iff (!rstn)
        (p[N] == 1'b0)
    );

    // The lower N bits of the output equal the previous input after reset release.
    check_output_lower_bits_match_input: assert property (
        @(posedge clk) disable iff (!rstn)
        (p[N-1:0] == $past(a))
    );

endmodule