module qtwosComp_sva (
    input logic        clk,
    input logic [30:0] a,
    input logic [63:0] b
);

    // b must equal the 64-bit two's complement of a.
    check_twos_complement: assert property (
        @(posedge clk) b == {34'b0, (~a) + 31'b1}
    );

    // The low 31 bits of b must equal the low 31 bits of a.
    check_low_bits_match: assert property (
        @(posedge clk) b[30:0] == a
    );

    // The upper 33 bits of b must be zero.
    check_upper_bits_zero: assert property (
        @(posedge clk) b[63:31] == 33'b0
    );

    // Zero input must produce zero output.
    check_zero_input_zero_output: assert property (
        @(posedge clk) (a == 31'b0) |-> (b == 64'b0)
    );

    // The most negative 31-bit value must map to itself.
    check_most_negative_self_inverse: assert property (
        @(posedge clk) (a == 31'h80000000) |-> (b == 64'h00000000_80000000)
    );

    // The largest positive 31-bit value must map to the largest negative 31-bit value.
    check_largest_positive_self_inverse: assert property (
        @(posedge clk) (a == 31'h7FFFFFFF) |-> (b == 64'hFFFF_FFFF_80000000)
    );

    // The smallest positive 31-bit value must map to the smallest negative 31-bit value.
    check_smallest_positive_self_inverse: assert property (
        @(posedge clk) (a == 31'h00000001) |-> (b == 64'hFFFF_FFFF_80000001)
    );

    // The largest negative 31-bit value must map to the largest positive 31-bit value.
    check_largest_negative_self_inverse: assert property (
        @(posedge clk) (a == 31'hFFFFFFFE) |-> (b == 64'h00000000_7FFFFFFE)
    );

    // The smallest negative 31-bit value must map to the smallest positive 31-bit value.
    check_smallest_negative_self_inverse: assert property (
        @(posedge clk) (a == 31'hFFFFFFFF) |-> (b == 64'h00000000_7FFFFFFF)
    );

endmodule