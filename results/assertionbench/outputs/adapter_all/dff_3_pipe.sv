module dff_3_pipe_sva #(
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    input logic [DATA_WIDTH-1:0] d0,
    input logic [DATA_WIDTH-1:0] d1,
    input logic [DATA_WIDTH-1:0] d2,
    input logic [DATA_WIDTH-1:0] q0,
    input logic [DATA_WIDTH-1:0] q1,
    input logic [DATA_WIDTH-1:0] q2
);

    // Reset forces all registered outputs low.
    check_reset_clears_outputs: assert property (
        @(posedge clk) !rst_n |-> (q0 == {DATA_WIDTH{1'b0}}) && (q1 == {DATA_WIDTH{1'b0}}) && (q2 == {DATA_WIDTH{1'b0}})
    );

    // q0 captures d0 on the next clock.
    check_q0_captures_d0: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> (q0 == $past(d0))
    );

    // q1 captures d1 on the next clock.
    check_q1_captures_d1: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> (q1 == $past(d1))
    );

    // q2 captures d2 on the next clock.
    check_q2_captures_d2: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> (q2 == $past(d2))
    );

    // q0 reflects the d0 value from two clocks earlier.
    check_q0_two_cycle_latency: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> ##1 (q0 == $past(d0, 2))
    );

    // q1 reflects the d1 value from two clocks earlier.
    check_q1_two_cycle_latency: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> ##1 (q1 == $past(d1, 2))
    );

    // q2 reflects the d2 value from two clocks earlier.
    check_q2_two_cycle_latency: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> ##1 (q2 == $past(d2, 2))
    );

    // q0 reflects the d0 value from three clocks earlier.
    check_q0_three_cycle_latency: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> ##2 (q0 == $past(d0, 3))
    );

    // q1 reflects the d1 value from three clocks earlier.
    check_q1_three_cycle_latency: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> ##2 (q1 == $past(d1, 3))
    );

    // q2 reflects the d2 value from three clocks earlier.
    check_q2_three_cycle_latency: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> ##2 (q2 == $past(d2, 3))
    );

endmodule