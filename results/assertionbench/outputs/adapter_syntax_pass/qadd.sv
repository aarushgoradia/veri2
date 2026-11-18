module qadd_sva #(parameter int N = 32) (
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic [N-1:0] c
);

    // c must always match the RTL's selected arithmetic result.
    check_selected_result: assert property (
        @($global_clock)
        c == ((a[N-1] == 1'b0 && b[N-1] == 1'b0) ? {1'b0, (a[N-2:0] + b[N-2:0])} :
              ((a[N-1] == 1'b0 && b[N-1] == 1'b1) ? {1'b1, (a[N-2:0] - b[N-2:0])} :
              ((a[N-1] == 1'b1 && b[N-1] == 1'b0) ? {1'b1, (a[N-2:0] + b[N-2:0])} :
              {1'b0, (b[N-2:0] - a[N-2:0])})))
    );

    // When both operands are non-negative, c is the sum of the low 15 bits.
    check_add_nonnegative: assert property (
        @($global_clock)
        (a[N-1] == 1'b0 && b[N-1] == 1'b0) |-> (c == {1'b0, (a[N-2:0] + b[N-2:0])})
    );

    // When both operands are negative, c is the sum of the low 15 bits with sign 1.
    check_add_negative: assert property (
        @($global_clock)
        (a[N-1] == 1'b1 && b[N-1] == 1'b1) |-> (c == {1'b1, (a[N-2:0] + b[N-2:0])})
    );

    // When a is non-negative and b is negative, c is the difference with sign 1.
    check_subtract_b_greater: assert property (
        @($global_clock)
        (a[N-1] == 1'b0 && b[N-1] == 1'b1 && (a[N-2:0] > b[N-2:0])) |-> (c == {1'b1, (a[N-2:0] - b[N-2:0])})
    );

    // When a is non-negative and b is negative, c is the difference with sign 0 when a is greater.
    check_subtract_a_greater: assert property (
        @($global_clock)
        (a[N-1] == 1'b0 && b[N-1] == 1'b1 && (a[N-2:0] <= b[N-2:0])) |-> (c == {1'b0, (a[N-2:0] - b[N-2:0])})
    );

    // When a is negative and b is non-negative, c is the difference with sign 1 when b is greater.
    check_subtract_b_negative: assert property (
        @($global_clock)
        (a[N-1] == 1'b1 && b[N-1] == 1'b0 && (a[N-2:0] < b[N-2:0])) |-> (c == {1'b1, (b[N-2:0] - a[N-2:0])})
    );

    // When a is negative and b is non-negative, c is the difference with sign 0 when a is greater.
    check_subtract_a_negative: assert property (
        @($global_clock)
        (a[N-1] == 1'b1 && b[N-1] == 1'b0 && (a[N-2:0] >= b[N-2:0])) |-> (c == {1'b0, (b[N-2:0] - a[N-2:0])})
    );

endmodule