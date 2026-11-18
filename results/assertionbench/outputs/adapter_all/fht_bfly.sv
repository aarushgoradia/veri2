module fht_bfly_sva #(
    parameter int N = 8
) (
    input logic         rstn,
    input logic         clk,
    input logic         valid,
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic [N:0]   c,
    input logic [N:0]   d
);

    // Reset clears both registered inputs and the combinational outputs.
    check_reset_clears_outputs: assert property (
        @(posedge clk) !rstn |-> ((a == '0) && (b == '0) && (c == '0) && (d == '0))
    );

    // c is the registered sum of a and b from the previous cycle.
    check_c_matches_registered_sum: assert property (
        @(posedge clk) disable iff (!rstn)
        $past(rstn) |-> (c == $past({1'b0, a} + {1'b0, b}))
    );

    // d is the registered difference of a and b from the previous cycle.
    check_d_matches_registered_difference: assert property (
        @(posedge clk) disable iff (!rstn)
        $past(rstn) |-> (d == $past({1'b0, a} - {1'b0, b}))
    );

    // When valid is low, both registered inputs hold their previous values.
    check_hold_when_valid_low: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid |=> ((a == $past(a)) && (b == $past(b)))
    );

    // When valid is high, a loads from the previous cycle's a.
    check_a_loads_when_valid_high: assert property (
        @(posedge clk) disable iff (!rstn)
        valid |=> (a == $past(a))
    );

    // When valid is high, b loads from the previous cycle's b.
    check_b_loads_when_valid_high: assert property (
        @(posedge clk) disable iff (!rstn)
        valid |=> (b == $past(b))
    );

    // With valid high in consecutive cycles, c and d use the same previous a and b.
    check_outputs_use_same_previous_inputs: assert property (
        @(posedge clk) disable iff (!rstn)
        (valid && $past(valid)) |-> ((c == $past({1'b0, a} + {1'b0, b})) &&
                                     (d == $past({1'b0, a} - {1'b0, b})))
    );

    // With valid high in consecutive cycles, c and d are consistent with each other.
    check_outputs_consistent_when_valid: assert property (
        @(posedge clk) disable iff (!rstn)
        (valid && $past(valid)) |-> (c[N] == d[N])
    );

    // With valid high in consecutive cycles, c and d are consistent with the previous a and b.
    check_outputs_consistent_with_previous_inputs: assert property (
        @(posedge clk) disable iff (!rstn)
        (valid && $past(valid)) |-> ((c[N] == $past(a[N])) &&
                                     (d[N] == $past(a[N])))
    );

endmodule