module fht_bfly_sva #(
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
    check_outputs_are_nonnegative: assert property (
        @(posedge clk) disable iff (!rstn)
        (c[N] == 1'b0) && (d[N] == 1'b0)
    );

    // When a and b are equal, the outputs are both zero.
    check_equal_inputs_drive_zero_outputs: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == b) |=> ((c == {N+1{1'b0}}) && (d == {N+1{1'b0}}))
    );

    // When a is zero, c passes through b and d passes through zero.
    check_zero_a_passthrough: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == {N{1'b0}}) |=> ((c == {N+1{1'b0}}) && (d == {N+1{1'b0}}))
    );

    // When b is zero, c passes through a and d passes through zero.
    check_zero_b_passthrough: assert property (
        @(posedge clk) disable iff (!rstn)
        (b == {N{1'b0}}) |=> ((c == {N+1{1'b0}}) && (d == {N+1{1'b0}}))
    );

    // When a is all ones, c is all ones and d is zero.
    check_all_ones_a_outputs_all_ones_c_zero_d: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == {N{1'b1}}) |=> ((c == {N+1{1'b1}}) && (d == {N+1{1'b0}}))
    );

    // When b is all ones, c is zero and d is all ones.
    check_all_ones_b_outputs_zero_c_all_ones_d: assert property (
        @(posedge clk) disable iff (!rstn)
        (b == {N{1'b1}}) |=> ((c == {N+1{1'b0}}) && (d == {N+1{1'b1}}))
    );

    // When a is all ones and b is zero, c is all ones and d is zero.
    check_all_ones_a_zero_b_outputs_all_ones_c_zero_d: assert property (
        @(posedge clk) disable iff (!rstn)
        ((a == {N{1'b1}}) && (b == {N{1'b0}})) |=> ((c == {N+1{1'b1}}) && (d == {N+1{1'b0}}))
    );

    // When a is zero and b is all ones, c is zero and d is all ones.
    check_zero_a_all_ones_b_outputs_zero_c_all_ones_d: assert property (
        @(posedge clk) disable iff (!rstn)
        ((a == {N{1'b0}}) && (b == {N{1'b1}})) |=> ((c == {N+1{1'b0}}) && (d == {N+1{1'b1}}))
    );

endmodule