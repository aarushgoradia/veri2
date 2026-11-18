module fht_bfly_noFF_sva #(
    parameter int N = 8
) (
    input logic rstn,
    input logic clk,
    input logic valid,
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic [N  :0] c,
    input logic [N  :0] d
);

    // c is the zero-extended sum of the previous cycle's a and b.
    check_c_matches_previous_inputs: assert property (
        @(posedge clk) disable iff (!rstn)
        1'b1 |=> (c == {1'b0, ($past(a) + $past(b))})
    );

    // d is the zero-extended difference of the previous cycle's a and b.
    check_d_matches_previous_inputs: assert property (
        @(posedge clk) disable iff (!rstn)
        1'b1 |=> (d == {1'b0, ($past(a) - $past(b))})
    );

    // c and d are never negative.
    check_outputs_nonnegative: assert property (
        @(posedge clk) disable iff (!rstn)
        (c[N] == 1'b0) && (d[N] == 1'b0)
    );

    // When a and b are equal, c is twice the previous a and d is zero.
    check_equal_inputs_behavior: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == b) |=> ((c == {1'b0, ($past(a) << 1)}) && (d == {N{1'b0}}))
    );

    // When a is zero, c is the previous b and d is the previous b.
    check_a_zero_behavior: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == {N{1'b0}}) |=> ((c == {1'b0, $past(b)}) && (d == {1'b0, $past(b)}))
    );

    // When b is zero, c is the previous a and d is the previous a.
    check_b_zero_behavior: assert property (
        @(posedge clk) disable iff (!rstn)
        (b == {N{1'b0}}) |=> ((c == {1'b0, $past(a)}) && (d == {1'b0, $past(a)}))
    );

    // When a is all ones, c is all ones and d is all zeros.
    check_a_all_ones_behavior: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == {N{1'b1}}) |=> ((c == {N{1'b1}}) && (d == {N{1'b0}}))
    );

    // When b is all ones, c is all zeros and d is all ones.
    check_b_all_ones_behavior: assert property (
        @(posedge clk) disable iff (!rstn)
        (b == {N{1'b1}}) |=> ((c == {N{1'b0}}) && (d == {N{1'b1}}))
    );

endmodule