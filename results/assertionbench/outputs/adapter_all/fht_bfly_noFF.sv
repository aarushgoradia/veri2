module fht_bfly_noFF_sva #(
    parameter int N = 8
) (
    input logic             rstn,
    input logic             clk,
    input logic             valid,
    input logic [N-1:0]     a,
    input logic [N-1:0]     b,
    input logic [N:0]       c,
    input logic [N:0]       d
);

    // Reset clears both registered inputs and the combinational outputs.
    check_reset_clears_outputs: assert property (
        @(posedge clk) !rstn |-> ((a == '0) && (b == '0) && (c == '0) && (d == '0))
    );

    // When valid is low, both registered inputs hold their previous values.
    check_hold_when_valid_low: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid |=> ((a == $past(a)) && (b == $past(b)))
    );

    // When valid is high, a is loaded into the registered input on the next cycle.
    check_load_a_when_valid: assert property (
        @(posedge clk) disable iff (!rstn)
        valid |=> (a == $past(a))
    );

    // When valid is high, b is loaded into the registered input on the next cycle.
    check_load_b_when_valid: assert property (
        @(posedge clk) disable iff (!rstn)
        valid |=> (b == $past(b))
    );

    // c is the registered a plus the registered b.
    check_c_matches_registered_sum: assert property (
        @(posedge clk) disable iff (!rstn)
        1'b1 |-> (c == ($past(a) + $past(b)))
    );

    // d is the registered a minus the registered b.
    check_d_matches_registered_difference: assert property (
        @(posedge clk) disable iff (!rstn)
        1'b1 |-> (d == ($past(a) - $past(b)))
    );

    // With valid high, c reflects the previous cycle's a and b.
    check_c_updates_on_valid: assert property (
        @(posedge clk) disable iff (!rstn)
        valid |=> (c == ($past(a) + $past(b)))
    );

    // With valid high, d reflects the previous cycle's a and b.
    check_d_updates_on_valid: assert property (
        @(posedge clk) disable iff (!rstn)
        valid |=> (d == ($past(a) - $past(b)))
    );

    // With valid low, c holds its previous value.
    check_c_holds_when_valid_low: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid |=> (c == $past(c))
    );

    // With valid low, d holds its previous value.
    check_d_holds_when_valid_low: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid |=> (d == $past(d))
    );

endmodule