```systemverilog
module signed_mult_const_fpga_sva (
    input logic rstn,
    input logic clk,
    input logic valid,
    input  signed [7:0] a,
    output signed [8:0] p
);
    // Sequential logic for a_FF
    // a_FF should only update on the rising edge of clk and when valid is high
    sequential_a_ff: assert property (
        @(posedge clk) disable iff (!rstn) (valid |-> a_FF == a)
    );

    // p should be assigned the result of a_FF multiplied by the constant and right-shifted by 16
    // p should only update on the rising edge of clk
    sequential_p_assignment: assert property (
        @(posedge clk) disable iff (!rstn) p == $signed(a_FF) * $signed(17'd92681) >> 16
    );

    // a_FF should be reset to 0 on the rising edge of clk when rstn is low
    reset_a_ff: assert property (
        @(posedge clk) !rstn |-> a_FF == 0
    );

    // p should be reset to 0 on the rising edge of clk when rstn is low
    reset_p: assert property (
        @(posedge clk) !rstn |-> p == 0
    );
endmodule
```