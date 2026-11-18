module qadd_sva (
    input logic clk,
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic [N-1:0] c
);

// No RTL clock or reset; sample this combinational logic on clk.

    // c must match the RTL's full 16.15-bit result.
    check_full_result: assert property (
        @(posedge clk) c == res
    );

// Both operands negative produce a negative result.
    check_both_negative_result: assert property (
        @(posedge clk) (a[N-1] && b[N-1]) |-> (c[N-1] && (c[N-2:0] == (a[N-2:0] + b[N-2:0])))
    );

// Both operands positive produce a non-negative result.
    check_both_positive_result: assert property (
        @(posedge clk) (!a[N-1] && !b[N-1]) |-> (!c[N-1] && (c[N-2:0] == (a[N-2:0] + b[N-2:0])))
    );

// a is non-negative and b is negative uses a[N-2:0] as the minuend.
    check_subtract_a_minus_b_result: assert property (
        @(posedge clk) (!a[N-1] && b[N-1]) |-> (c[N-1] == (a[N-2:0] >= b[N-2:0])) &&
                                             (c[N-2:0] == (a[N-2:0] - b[N-2:0]))
    );

// a is negative and b is non-negative uses b[N-2:0] as the minuend.
    check_subtract_b_minus_a_result: assert property (
        @(posedge clk) (a[N-1] && !b[N-1]) |-> (c[N-1] == (b[N-2:0] >= a[N-2:0])) &&
                                             (c[N-2:0] == (b[N-2:0] - a[N-2:0]))
    );

// Equal non-negative operands produce zero.
    check_equal_positive_operands_zero: assert property (
        @(posedge clk) (!a[N-1] && !b[N-1] && (a[N-2:0] == b[N-2:0])) |-> (!c[N-1] && (c[N-2:0] == 16'd0))
    );

// Equal negative operands produce zero.
    check_equal_negative_operands_zero: assert property (
        @(posedge clk) (a[N-1] && b[N-1] && (a[N-2:0] == b[N-2:0])) |-> (c[N-1] && (c[N-2:0] == 16'd0))
    );

// Subtracting equal magnitudes with different signs yields 16'h8000.
    check_equal_magnitude_different_signs: assert property (
        @(posedge clk) (a[N-1] != b[N-1] && (a[N-2:0] == b[N-2:0])) |-> (c[N-1] && (c[N-2:0] == 16'h8000))
    );

endmodule
