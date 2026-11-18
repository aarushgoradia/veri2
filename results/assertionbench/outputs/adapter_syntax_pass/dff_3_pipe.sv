module dff_3_pipe_sva
#(
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

    // q0 captures d0 on the previous rising clock edge.
    check_q0_captures_d0: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> (q0 == $past(d0))
    );

    // q1 captures d1 on the previous rising clock edge.
    check_q1_captures_d1: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> (q1 == $past(d1))
    );

    // q2 captures d2 on the previous rising clock edge.
    check_q2_captures_d2: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> (q2 == $past(d2))
    );

    // All three outputs are zero on the first clock after reset deasserts.
    check_post_reset_zero: assert property (
        @(posedge clk) disable iff (!rst_n)
        $rose(rst_n) |-> ((q0 == {DATA_WIDTH{1'b0}}) &&
                          (q1 == {DATA_WIDTH{1'b0}}) &&
                          (q2 == {DATA_WIDTH{1'b0}}))
    );

endmodule