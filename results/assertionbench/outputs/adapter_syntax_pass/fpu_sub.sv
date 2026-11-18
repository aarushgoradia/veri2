module fpu_sub_sva (
    input logic        clk,
    input logic        rst,
    input logic        enable,
    input logic [63:0] opa,
    input logic [63:0] opb,
    input logic [2:0]  fpu_op,
    input logic        sign,
    input logic [55:0] diff_2,
    input logic [10:0] exponent_2
);

    // Reset clears all registered state by the next clock.
    check_reset_clears_state: assert property (
        @(posedge clk)
        rst |=> (
            $past(exponent_a) == 11'd0 &&
            $past(exponent_b) == 11'd0 &&
            $past(mantissa_a) == 52'd0 &&
            $past(mantissa_b) == 52'd0 &&
            $past(expa_gt_expb) == 1'b0 &&
            $past(expa_et_expb) == 1'b0 &&
            $past(mana_gtet_manb) == 1'b0 &&
            $past(a_gtet_b) == 1'b0 &&
            $past(sign) == 1'b0 &&
            $past(exponent_small) == 11'd0 &&
            $past(exponent_large) == 11'd0 &&
            $past(mantissa_small) == 52'd0 &&
            $past(mantissa_large) == 52'd0 &&
            $past(small_is_denorm) == 1'b0 &&
            $past(large_is_denorm) == 1'b0 &&
            $past(large_norm_small_denorm) == 1'b0 &&
            $past(small_is_nonzero) == 1'b0 &&
            $past(exponent_diff) == 11'd0 &&
            $past(minuend) == 56'd0 &&
            $past(subtrahend) == 56'd0 &&
            $past(subtra_shift) == 56'd0 &&
            $past(subtra_shift_3) == 56'd0 &&
            $past(diff_shift_2) == 7'd0 &&
            $past(diff) == 56'd0 &&
            $past(diffshift_gt_exponent) == 1'b0 &&
            $past(diffshift_et_55) == 1'b0 &&
            $past(diff_1) == 56'd0 &&
            $past(exponent) == 11'd0 &&
            $past(exponent_2) == 11'd0 &&
            $past(diff_2) == 56'd0
        )
    );

    // When enabled, exponent_a captures opa[62:52].
    check_exponent_a_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(exponent_a) == opa[62:52])
    );

    // When enabled, exponent_b captures opb[62:52].
    check_exponent_b_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(exponent_b) == opb[62:52])
    );

    // When enabled, mantissa_a captures opa[51:0].
    check_mantissa_a_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(mantissa_a) == opa[51:0])
    );

    // When enabled, mantissa_b captures opb[51:0].
    check_mantissa_b_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(mantissa_b) == opb[51:0])
    );

    // When enabled, expa_gt_expb compares the two exponents.
    check_exp_gt_compare: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(expa_gt_expb) == ($past(exponent_a) > $past(exponent_b)))
    );

    // When enabled, expa_et_expb compares the two exponents.
    check_exp_et_compare: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(expa_et_expb) == ($past(exponent_a) == $past(exponent_b)))
    );

    // When enabled, mana_gtet_manb compares the two mantissas.
    check_mana_gtet_compare: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(mana_gtet_manb) == ($past(mantissa_a) >= $past(mantissa_b)))
    );

    // When enabled, a_gtet_b selects the greater operand.
    check_a_gtet_b_compare: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(a_gtet_b) == ($past(expa_gt_expb) | ($past(expa_et_expb) & $past(mana_gtet_manb))))
    );

    // When enabled, sign follows the implemented comparison logic.
    check_sign_compare: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(sign) == ($past(a_gtet_b) ? $past(opa[63]) : (!($past(opb[63])) ^ ($past(fpu_op) == 3'b000))))
    );

    // When enabled, exponent_small selects the smaller exponent.
    check_exponent_small_select: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(exponent_small) == ($past(a_gtet_b) ? $past(exponent_b) : $past(exponent_a)))
    );

    // When enabled, exponent_large selects the greater exponent.
    check_exponent_large_select: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(exponent_large) == ($past(a_gtet_b) ? $past(exponent_a) : $past(exponent_b)))
    );

    // When enabled, mantissa_small selects the smaller mantissa.
    check_mantissa_small_select: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(mantissa_small) == ($past(a_gtet_b) ? $past(mantissa_b) : $past(mantissa_a)))
    );

    // When enabled, mantissa_large selects the greater mantissa.
    check_mantissa_large_select: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(mantissa_large) == ($past(a_gtet_b) ? $past(mantissa_a) : $past(mantissa_b)))
    );

    // When enabled, small_is_denorm is the inverse of exponent_small.
    check_small_is_denorm: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(small_is_denorm) == !($past(exponent_small) > 11'd0))
    );

    // When enabled, large_is_denorm is the inverse of exponent_large.
    check_large_is_denorm: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(large_is_denorm) == !($past(exponent_large) > 11'd0))
    );

    // When enabled, large_norm_small_denorm is the two-denorm case.
    check_large_norm_small_denorm: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(large_norm_small_denorm) == ($past(small_is_denorm) && $past(large_is_denorm)))
    );

    // When enabled, small_is_nonzero is true when exponent_small is nonzero.
    check_small_is_nonzero: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(small_is_nonzero) == ($past(exponent_small) > 11'd0 || |$past(mantissa_small[51:0])))
    );

    // When enabled, exponent_diff computes the difference of the two exponents.
    check_exponent_diff_compute: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(exponent_diff) == ($past(exponent_large) - $past(exponent_small) - $past(large_norm_small_denorm)))
    );

    // When enabled, minuend is the shifted large operand.
    check_minuend_compute: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(minuend) == {~$past(large_is_denorm), $past(mantissa_large), 2'b00})
    );

    // When enabled, subtrahend is the shifted small operand.
    check_subtrahend_compute: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(subtrahend) == {~$past(small_is_denorm), $past(mantissa_small), 2'b00})
    );

    // When enabled, subtra_shift is the right-shifted subtrahend.
    check_subtra_shift_compute: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(subtra_shift) == ($past(subtrahend) >> $past(exponent_diff)))
    );

    // When enabled, subtra_shift_3 selects the appropriate shift value.
    check_subtra_shift_3_compute: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(subtra_shift_3) == ($past(subtra_fraction_enable) ? 56'd1 : $past(subtra_shift)))
    );

    // When enabled, diff_shift_2 captures the previous diff_shift value.
    check_diff_shift_2_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(diff_shift_2) == $past(diff_shift))
    );

    // When enabled, diff captures the subtraction result.
    check_diff_compute: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(diff) == ($past(minuend) - $past(subtra_shift_3)))
    );

    // When enabled, diffshift_gt_exponent compares diff_shift_2 to exponent_large.
    check_diffshift_gt_compare: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(diffshift_gt_exponent) == ($past(diff_shift_2) > $past(exponent_large)))
    );

    // When enabled, diffshift_et_55 compares diff_shift_2 to 55.
    check_diffshift_et_55_compare: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(diffshift_et_55) == ($past(diff_shift_2) == 7'd55))
    );

    // When enabled, diff_1 shifts diff based on diff_shift_2 and exponent_large.
    check_diff_1_compute: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(diff_1) == ($past(diffshift_gt_exponent) ? ($past(diff) << $past(exponent_large)) : ($past(diff) << $past(diff_shift_2))))
    );

    // When enabled, exponent is zero when diff_shift_2 exceeds exponent_large.
    check_exponent_zero_on_shift: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(diffshift_gt_exponent) |-> ($past(exponent) == 11'd0))
    );

    // When enabled, exponent is the difference when diff_shift_2 is in range.
    check_exponent_compute: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (!$past(diffshift_gt_exponent) |-> ($past(exponent) == ($past(exponent_large) - $past(diff_shift_2))))
    );

    // When enabled, exponent_2 is zero when diff_shift_2 equals 55.
    check_exponent_2_zero_on_55: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(diffshift_et_55) |-> ($past(exponent_2) == 11'd0))
    );

    // When enabled, exponent_2 passes exponent when diff_shift_2 is in range.
    check_exponent_2_pass_through: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (!$past(diffshift_et_55) |-> ($past(exponent_2) == $past(exponent)))
    );

    // When enabled, diff_2 follows the implemented denorm-to-norm shift.
    check_diff_2_compute: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ($past(diff_2) == ($past(in_norm_out_denorm) ? {1'b0, ($past(diff_1) >> 1)} : {1'b0, $past(diff_1)}))
    );

endmodule