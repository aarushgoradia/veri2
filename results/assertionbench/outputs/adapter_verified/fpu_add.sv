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

// Reset clears all state and outputs.
    check_reset_clears_state: assert property (
        @(posedge clk) rst |=> (sign == 1'b0 &&
                               exponent_2 == 11'd0 &&
                               sum_2 == 56'd0)
    );

// With enable low, outputs hold their previous values.
    check_hold_when_disabled: assert property (
        @(posedge clk) disable iff (rst)
        !enable |=> $stable(sign) && $stable(sum_2) && $stable(exponent_2)
    );

// With enable high, sign captures opa[63].
    check_sign_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (sign == $past(opa[63]))
    );

// With enable high, exponent_2 captures the larger exponent plus one.
    check_exponent2_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (exponent_2 == ($past(opa[62:52]) > $past(opb[62:52]) ? $past(opa[62:52]) : $past(opb[62:52])) + 11'd1)
    );

// With enable high, sum_2 is zero-extended to 56 bits.
    check_sum2_zero_extended: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (sum_2[55:56] == 2'b00)
    );

endmodule
