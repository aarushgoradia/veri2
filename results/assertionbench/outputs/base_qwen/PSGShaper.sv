```systemverilog
module psgshaper_sva (
    input logic clk_i,
    input logic ce,
    input logic [11:0] tgi,
    input logic [7:0] env,
    output logic [19:0] o
);
    // Sequential logic: o is updated on the rising edge of clk_i when ce is high
    sequential_logic: assert property (
        @(posedge clk_i) disable iff (!ce) o == tgi * env
    );
    // Combinational logic: o is updated on the rising edge of clk_i when ce is high
    combinational_logic: assert property (
        @(posedge clk_i) disable iff (!ce) o == tgi * env
    );
endmodule
```