module dff_3_pipe_sva (
    input logic clk,
    input logic rst_n,
    input logic [7:0] d0,
    input logic [7:0] d1,
    input logic [7:0] d2,
    input logic [7:0] q0,
    input logic [7:0] q1,
    input logic [7:0] q2
);

// q0 captures d0 on the next clock when reset is inactive.
    check_q0_captures_d0: assert property (
        @(posedge clk) disable iff (!rst_n) 1'b1 |=> (q0 == $past(d0))
    );

// q1 captures d1 on the next clock when reset is inactive.
    check_q1_captures_d1: assert property (
        @(posedge clk) disable iff (!rst_n) 1'b1 |=> (q1 == $past(d1))
    );

// q2 captures d2 on the next clock when reset is inactive.
    check_q2_captures_d2: assert property (
        @(posedge clk) disable iff (!rst_n) 1'b1 |=> (q2 == $past(d2))
    );

// All outputs are zero on the first clock after reset deassertion.
    check_reset_release_clears_outputs: assert property (
        @(posedge clk) disable iff (!rst_n) $rose(rst_n) |-> (q0 == 8'h00) && (q1 == 8'h00) && (q2 == 8'h00)
    );

endmodule
