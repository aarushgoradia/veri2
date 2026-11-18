module q15_mult_sva (
    input logic        clk,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [31:0] c
);

    // c must match the RTL's sign-extended 32-bit product.
    check_c_matches_sign_extended_product: assert property (
        @(posedge clk)
        c == {a[31], ((a[30:0] * b[30:0]) >> 15)}
    );

    // When both operands are non-negative, c must be the unsigned product.
    check_non_negative_operands_produce_unsigned_product: assert property (
        @(posedge clk)
        (!a[31] && !b[31]) |-> (c == (a[30:0] * b[30:0]))
    );

    // When both operands are negative, c must be the unsigned product.
    check_negative_operands_produce_unsigned_product: assert property (
        @(posedge clk)
        (a[31] && b[31]) |-> (c == (a[30:0] * b[30:0]))
    );

    // When the a operand is negative and b is non-negative, c must be the unsigned product.
    check_negative_a_non_negative_b_produces_unsigned_product: assert property (
        @(posedge clk)
        (a[31] && !b[31]) |-> (c == (a[30:0] * b[30:0]))
    );

    // When the a operand is non-negative and b is negative, c must be the unsigned product.
    check_non_negative_a_negative_b_produces_unsigned_product: assert property (
        @(posedge clk)
        (!a[31] && b[31]) |-> (c == (a[30:0] * b[30:0]))
    );

    // When a is zero, c must be zero.
    check_zero_a_forces_zero_c: assert property (
        @(posedge clk)
        (a == 32'h0000_0000) |-> (c == 32'h0000_0000)
    );

    // When b is zero, c must be zero.
    check_zero_b_forces_zero_c: assert property (
        @(posedge clk)
        (b == 32'h0000_0000) |-> (c == 32'h0000_0000)
    );

    // When a is all ones, c must be the unsigned product of b and 31.
    check_all_ones_a_produces_b_times_31: assert property (
        @(posedge clk)
        (a == 32'hFFFF_FFFF) |-> (c == (b[30:0] * 31))
    );

    // When b is all ones, c must be the unsigned product of a and 31.
    check_all_ones_b_produces_a_times_31: assert property (
        @(posedge clk)
        (b == 32'hFFFF_FFFF) |-> (c == (a[30:0] * 31))
    );

    // When a is 31, c must be the unsigned product of b and 31.
    check_a_is_31_produces_b_times_31: assert property (
        @(posedge clk)
        (a == 32'h0000_001F) |-> (c == (b[30:0] * 31))
    );

    // When b is 31, c must be the unsigned product of a and 31.
    check_b_is_31_produces_a_times_31: assert property (
        @(posedge clk)
        (b == 32'h0000_001F) |-> (c == (a[30:0] * 31))
    );

endmodule