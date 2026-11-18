```systemverilog
module signed_mult_const_asic_sva (
    input logic clk,
    input logic rstn,
    input logic valid,
    input  [7:0] a,
    output [8:0] p
);
    // Sequential logic: a_FF is updated on the rising edge of clk
    seq_update_a: assert property (
        @(posedge clk) disable iff (!rstn) a_FF == a
    ) else $error("a_FF should be updated to a on the rising edge of clk");

    // Combinational logic: b is calculated based on a_FF
    comb_b_calc: assert property (
        @(posedge clk) disable iff (!rstn) b == (a_FF[7] ? {~a_FF[7:0] + {{7{1'b0}},1'b1}} : a_FF[7:0])
    ) else $error("b should be calculated correctly based on a_FF");

    // Combinational logic: mult_wo_sign is calculated based on b and mult_constant
    comb_mult_wo_sign: assert property (
        @(posedge clk) disable iff (!rstn) mult_wo_sign == b[7:0] * 9'd362
    ) else $error("mult_wo_sign should be calculated correctly based on b and mult_constant");

    // Combinational logic: div256 is calculated based on mult_wo_sign
    comb_div256: assert property (
        @(posedge clk) disable iff (!rstn) div256 == mult_wo_sign >> 8
    ) else $error("div256 should be calculated correctly based on mult_wo_sign");

    // Combinational logic: p is calculated based on a_FF and div256
    comb_p_calc: assert property (
        @(posedge clk) disable iff (!rstn) p == (a_FF[7] ? {1'b1, {~div256[7:0] + {{7{1'b0}},1'b1}}} : {1'b0, div256[7:0]})
    ) else $error("p should be calculated correctly based on a_FF and div256");

    // Reset behavior: p should be 0 on reset
    reset_p: assert property (
        @(posedge clk) !rstn |-> p == 8'd0
    ) else $error("p should be 0 on reset");

    // Reset behavior: a_FF should be 0 on reset
    reset_a_FF: assert property (
        @(posedge clk) !rstn |-> a_FF == 8'd0
    ) else $error("a_FF should be 0 on reset");

    // Reset behavior: b should be 0 on reset
    reset_b: assert property (
        @(posedge clk) !rstn |-> b == 8'd0
    ) else $error("b should be 0 on reset");

    // Reset behavior: mult_wo_sign should be 0 on reset
    reset_mult_wo_sign: assert property (
        @(posedge clk) !rstn |-> mult_wo_sign == 9'd0
    ) else $error("mult_wo_sign should be 0 on reset");

    // Reset behavior: div256 should be 0 on reset
    reset_div256: assert property (
        @(posedge clk) !rstn |-> div256 == 8'd0
    ) else $error("div256 should be 0 on reset");
endmodule
```