```systemverilog
module psg_output_summer_sva (
    input logic clk_i,
    input logic [7:0] cnt,
    input logic [21:0] ufi,
    input logic [21:0] fi,
    output logic [21:0] o
);
    // Sequential logic: o is updated on the rising edge of clk_i
    // o is the sum of ufi and fi when cnt is 0
    sum_update: assert property (
        @(posedge clk_i) disable iff (!clk_i) (cnt == 8'd0) |-> (o == ufi + fi)
    );
endmodule
```