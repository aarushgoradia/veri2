module signed_mult_const_fpga_sva (
    input logic        clk,
    input logic        rstn,
    input logic        valid,
    input signed [7:0] a,
    input signed [8:0] p
);

// Reset clears the output on the next clock.
    check_reset_clears_output: assert property (
        @(posedge clk) !rstn |=> (p == 9'sd0)
    );

// A valid sample drives the output to the scaled value on the next clock.
    check_valid_sample_updates_output: assert property (
        @(posedge clk) disable iff (!rstn)
        valid |=> (p == $signed({1'b0, a}) * 9'sd92681 >> 16)
    );

// Without a valid sample, the output holds its previous value.
    check_no_valid_sample_holds_output: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid |=> (p == $past(p))
    );

// Zero input produces zero output.
    check_zero_input_yields_zero_output: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == 8'sd0) |=> (p == 9'sd0)
    );

// Positive inputs produce positive outputs.
    check_positive_input_yields_positive_output: assert property (
        @(posedge clk) disable iff (!rstn)
        (a >= 8'sd0) |=> (p >= 9'sd0)
    );

// Negative inputs produce negative outputs.
    check_negative_input_yields_negative_output: assert property (
        @(posedge clk) disable iff (!rstn)
        (a < 8'sd0) |=> (p <= 9'sd0)
    );

// The output range is limited by the 9-bit signed result.
    check_output_range_is_nine_bit_signed: assert property (
        @(posedge clk) disable iff (!rstn)
        1'b1 |=> ((p >= 9'sd-128) && (p <= 9'sd127))
    );

endmodule
