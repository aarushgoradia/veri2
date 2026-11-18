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

    // Reset clears all registered outputs.
    check_reset_clears_outputs: assert property (
        @(posedge clk) rst |=> (sign == 1'b0) &&
                               (sum_2 == 56'h000000000000) &&
                               (exponent_2 == 11'd0)
    );

    // When disabled, the registered outputs hold their values.
    check_hold_when_disabled: assert property (
        @(posedge clk) disable iff (rst)
        !enable |=> $stable(sign) &&
                    $stable(sum_2) &&
                    $stable(exponent_2)
    );

    // sign captures the sign bit of opa when enabled.
    check_sign_captures_opa: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (sign == $past(opa[63]))
    );

    // exponent_2 is the previous cycle's exponent_2 when disabled.
    check_exponent_2_holds_when_disabled: assert property (
        @(posedge clk) disable iff (rst)
        !enable |=> (exponent_2 == $past(exponent_2))
    );

    // sum_2 is the previous cycle's sum_2 when disabled.
    check_sum_2_holds_when_disabled: assert property (
        @(posedge clk) disable iff (rst)
        !enable |=> (sum_2 == $past(sum_2))
    );

    // exponent_2 follows the previous cycle's exponent_2 when enabled.
    check_exponent_2_updates_when_enabled: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (exponent_2 == $past(exponent_2))
    );

    // sum_2 follows the previous cycle's sum_2 when enabled.
    check_sum_2_updates_when_enabled: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (sum_2 == $past(sum_2))
    );

    // exponent_2 increments by one after a denorm-to-norm conversion.
    check_exponent_2_increments_after_denorm_to_norm: assert property (
        @(posedge clk) disable iff (rst)
        (enable && $past(exponent_2) && $past(sum_leading_one) && $past(large_is_denorm))
        |=> (exponent_2 == ($past(exponent_2) + 11'd1))
    );

    // exponent_2 holds after a non-denorm-to-norm conversion.
    check_exponent_2_holds_without_denorm_to_norm: assert property (
        @(posedge clk) disable iff (rst)
        (enable && !$past(sum_leading_one) || !$past(large_is_denorm))
        |=> (exponent_2 == $past(exponent_2))
    );

    // sum_2 is the previous cycle's sum_2 after a denorm-to-norm conversion.
    check_sum_2_increments_after_denorm_to_norm: assert property (
        @(posedge clk) disable iff (rst)
        (enable && $past(exponent_2) && $past(sum_leading_one) && $past(large_is_denorm))
        |=> (sum_2 == ($past(sum_2) + 56'h000000000001))
    );

    // sum_2 holds after a non-denorm-to-norm conversion.
    check_sum_2_holds_without_denorm_to_norm: assert property (
        @(posedge clk) disable iff (rst)
        (enable && !$past(sum_leading_one) || !$past(large_is_denorm))
        |=> (sum_2 == $past(sum_2))
    );

endmodule