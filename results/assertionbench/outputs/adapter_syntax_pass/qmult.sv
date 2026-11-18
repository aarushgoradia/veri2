module q15_mult_sva (
    input logic CLK,
    input logic [30:0] a,
    input logic [63:0] b
);
    // b equals a shifted left by 15 bits (zero-extended to 64 bits).
    check_b_is_a_shifted_left_by_15: assert property (
        @(posedge CLK) b == {33'b0, a}
    );

    // Upper 33 bits of b are always zero.
    check_b_upper_bits_zero: assert property (
        @(posedge CLK) b[63:33] == 33'b0
    );

    // Lower 32 bits of b equal a.
    check_b_lower_bits_equal_a: assert property (
        @(posedge CLK) b[32:0] == {33'b0, a}
    );

    // If a is zero, b must be zero.
    check_zero_a_implies_zero_b: assert property (
        @(posedge CLK) (a == 31'b0) |-> (b == 64'h0)
    );

    // If a is all ones, b must be all ones.
    check_all_ones_a_implies_all_ones_b: assert property (
        @(posedge CLK) (a == 31'h3FFFFFFF) |-> (b == 64'h7FFFFFFF)
    );

    // If a is all zeros, b must be all zeros.
    check_all_zeros_a_implies_all_zeros_b: assert property (
        @(posedge CLK) (a == 31'h0) |-> (b == 64'h0)
    );

    // If a is all ones, b must be all ones.
    check_all_ones_a_implies_all_ones_b: assert property (
        @(posedge CLK) (a == 31'h3FFFFFFF) |-> (b == 64'h7FFFFFFF)
    );

    // If a is all zeros, b must be all zeros.
    check_all_zeros_a_implies_all_zeros_b: assert property (
        @(posedge CLK) (a == 31'h0) |-> (b == 64'h0)
    );

    // If a is all ones, b must be all ones.
    check_all_ones_a_implies_all_ones_b: assert property (
        @(posedge CLK) (a == 31'h3FFFFFFF) |-> (b == 64'h7FFFFFFF)
    );

    // If a is all zeros, b must be all zeros.
    check_all_zeros_a_implies_all_zeros_b: assert property (
        @(posedge CLK) (a == 31'h0) |-> (b == 64'h0)
    );
endmodule