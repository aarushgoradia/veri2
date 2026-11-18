module fpu_add_sva (
    input logic        clk,
    input logic        rst,
    input logic        enable,
    input logic [63:0] opa,
    input logic [63:0] opb,
    input logic        sign,
    input logic [55:0] sum_2,
    input logic [10:0] exponent_2
);

    // Reset clears all registered state by the next clock.
    check_reset_clears_state: assert property (
        @(posedge clk)
        rst |=> ((sign == 1'b0) &&
                 (exponent_2 == 11'd0) &&
                 (sum_2 == 56'd0))
    );

    // sign captures the sign bit of opa on enable.
    check_sign_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (sign == $past(opa[63]))
    );

    // exponent_2 captures the exponent of the previous result.
    check_exponent_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (exponent_2 == $past(exponent))
    );

    // sum_2 is zero-extended from the previous sum.
    check_sum2_zero_extended: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (sum_2[55] == 1'b0)
    );

    // sum_2 is the previous sum shifted right by one when overflow occurs.
    check_sum2_shift_on_overflow: assert property (
        @(posedge clk) disable iff (rst)
        enable && $past(sum_overflow) |=> (sum_2 == ($past(sum) >> 1))
    );

    // sum_2 holds its value when overflow does not occur.
    check_sum2_holds_without_overflow: assert property (
        @(posedge clk) disable iff (rst)
        enable && !$past(sum_overflow) |=> (sum_2 == $past(sum_2))
    );

    // sum_2 is always even after enable.
    check_sum2_even_after_enable: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (sum_2[0] == 1'b0)
    );

    // sum_2 is always even after reset.
    check_sum2_even_after_reset: assert property (
        @(posedge clk)
        rst |=> (sum_2[0] == 1'b0)
    );

endmodule