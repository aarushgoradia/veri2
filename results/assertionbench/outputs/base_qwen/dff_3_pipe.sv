```systemverilog
module dff_3_pipe_sva (
    input logic clk,
    input logic rst_n,
    input logic [DATA_WIDTH-1:0] d0,
    input logic [DATA_WIDTH-1:0] d1,
    input logic [DATA_WIDTH-1:0] d2,
    output logic [DATA_WIDTH-1:0] q0,
    output logic [DATA_WIDTH-1:0] q1,
    output logic [DATA_WIDTH-1:0] q2
);
    parameter DATA_WIDTH = 8;

    ///// Register bank reset /////
    // At reset assertion, all outputs must drive LOW.
    reset: assert property (
        @(posedge clk) !rst_n |-> (q0 == 1'b0) && (q1 == 1'b0) && (q2 == 1'b0)
    );

    ///// Register bank behavior /////
    // q0 should always be equal to d0 after the clock edge.
    q0_behavior: assert property (
        @(posedge clk) disable iff (!rst_n) q0 == d0
    );
    // q1 should always be equal to d1 after the clock edge.
    q1_behavior: assert property (
        @(posedge clk) disable iff (!rst_n) q1 == d1
    );
    // q2 should always be equal to d2 after the clock edge.
    q2_behavior: assert property (
        @(posedge clk) disable iff (!rst_n) q2 == d2
    );
endmodule
```