module qadd_sva #(
    parameter int Q = 15,
    parameter int N = 32
) (
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic [N-1:0] c
);

    // No RTL clock or reset; sample combinational behavior on the formal global clock.

    // c must match the RTL's full conditional expression.
    check_full_conditional_mapping: assert property (
        @($global_clock)
        c == (
            (a[N-1] & b[N-1]) ? {1'b1, (a[N-2:0] + b[N-2:0])} :
            ((!a[N-1] & !b[N-1]) ? {1'b0, (a[N-2:0] + b[N-2:0])} :
             (a[N-1] & !b[N-1]) ? {((a[N-2:0] > b[N-2:0]) ? 1'b1 : 1'b0), (a[N-2:0] - b[N-2:0])} :
                                  {((a[N-2:0] < b[N-2:0]) ? 1'b1 : 1'b0), (b[N-2:0] - a[N-2:0])})
        )
    );

    // Both inputs negative must produce a negative result.
    check_both_negative_result_negative: assert property (
        @($global_clock)
        (a[N-1] && b[N-1]) |-> (c[N-1])
    );

    // Both inputs positive must produce a non-negative result.
    check_both_positive_result_nonnegative: assert property (
        @($global_clock)
        (!a[N-1] && !b[N-1]) |-> (!c[N-1])
    );

    // Adding a non-negative and a negative value must preserve the non-negative sign.
    check_add_negative_preserves_nonnegative: assert property (
        @($global_clock)
        (!a[N-1] && b[N-1]) |-> (!c[N-1])
    );

    // Adding a negative and a non-negative value must preserve the negative sign.
    check_add_positive_preserves_negative: assert property (
        @($global_clock)
        (a[N-1] && !b[N-1]) |-> (c[N-1])
    );

    // Adding equal non-negative operands must produce a non-negative result.
    check_equal_nonnegative_result_nonnegative: assert property (
        @($global_clock)
        (!a[N-1] && !b[N-1] && (a[N-2:0] == b[N-2:0])) |-> (!c[N-1])
    );

    // Adding equal negative operands must produce a negative result.
    check_equal_negative_result_negative: assert property (
        @($global_clock)
        (a[N-1] && b[N-1] && (a[N-2:0] == b[N-2:0])) |-> (c[N-1])
    );

    // Adding equal non-negative operands must preserve the operand value.
    check_equal_nonnegative_preserves_value: assert property (
        @($global_clock)
        (!a[N-1] && !b[N-1] && (a[N-2:0] == b[N-2:0])) |-> (c[N-2:0] == a[N-2:0])
    );

    // Adding equal negative operands must produce a zero result.
    check_equal_negative_zero_result: assert property (
        @($global_clock)
        (a[N-1] && b[N-1] && (a[N-2:0] == b[N-2:0])) |-> (c[N-2:0] == '0)
    );

endmodule