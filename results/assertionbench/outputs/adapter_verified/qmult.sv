module q15_mult_sva (
    input logic        clk,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [31:0] c
);

// Output is zero when either input is zero.
    check_zero_when_input_zero: assert property (
        @(posedge clk) ((a == 32'h0) || (b == 32'h0)) |-> (c == 32'h0)
    );

// Output equals the signed 32-bit product of the two inputs.
    check_signed_product: assert property (
        @(posedge clk) disable iff (1'b0)
        (c == ((a[31] ? ~a + 1 : a) * (b[31] ? ~b + 1 : b)))
    );

// Output is non-negative when both inputs are non-negative.
    check_nonneg_when_both_nonneg: assert property (
        @(posedge clk) disable iff (1'b0)
        ((!a[31] && !b[31])) |-> (c[31] == 1'b0)
    );

// Output is non-negative when both inputs are negative.
    check_nonneg_when_both_neg: assert property (
        @(posedge clk) disable iff (1'b0)
        ((a[31] && b[31])) |-> (c[31] == 1'b0)
    );

// Output is negative when exactly one input is negative.
    check_neg_when_one_neg: assert property (
        @(posedge clk) disable iff (1'b0)
        ((!a[31] && b[31]) || (a[31] && !b[31])) |-> (c[31] == 1'b1)
    );

// Output equals the unsigned 32-bit product when both inputs are non-negative.
    check_unsigned_product_when_both_nonneg: assert property (
        @(posedge clk) disable iff (1'b0)
        ((!a[31] && !b[31])) |-> (c == (a * b))
    );

// Output equals the unsigned 32-bit product when both inputs are negative.
    check_unsigned_product_when_both_neg: assert property (
        @(posedge clk) disable iff (1'b0)
        ((a[31] && b[31])) |-> (c == (a * b))
    );

// Output equals the unsigned 32-bit product when exactly one input is negative.
    check_unsigned_product_when_one_neg: assert property (
        @(posedge clk) disable iff (1'b0)
        ((!a[31] && b[31]) || (a[31] && !b[31])) |-> (c == (a * b))
    );

endmodule
