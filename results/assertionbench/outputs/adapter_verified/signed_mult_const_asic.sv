module signed_mult_const_asic_sva (
    input logic        rstn,
    input logic        clk,
    input logic        valid,
    input logic [7:0]  a,
    input logic [8:0]  p
);

// Reset clears the output to zero.
    check_reset_clears_output: assert property (
        @(posedge clk) !rstn |-> (p == 9'd0)
    );

// A valid positive input produces the signed 9-bit result.
    check_positive_valid_result: assert property (
        @(posedge clk) disable iff (!rstn)
        valid && !a[7] |-> (p == {1'b0, (a * 8'd362) >> 8})
    );

// A valid negative input produces the signed 9-bit result.
    check_negative_valid_result: assert property (
        @(posedge clk) disable iff (!rstn)
        valid && a[7] |-> (p == {1'b1, (-(a * 8'd362)) >> 8})
    );

// Without valid, the output holds its previous value.
    check_hold_when_no_valid: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid |=> (p == $past(p))
    );

// A positive input with zero valid produces zero.
    check_zero_when_no_valid: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid && !a[7] |-> (p == 9'd0)
    );

// A negative input with zero valid produces zero.
    check_zero_when_no_valid_negative: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid && a[7] |-> (p == 9'd0)
    );

endmodule
