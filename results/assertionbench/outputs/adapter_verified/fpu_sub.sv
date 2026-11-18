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

// Reset clears all state and outputs.
    check_reset_clears_state: assert property (
        @(posedge clk) rst |-> (exponent_a == 11'd0) &&
                             (exponent_b == 11'd0) &&
                             (mantissa_a == 52'd0) &&
                             (mantissa_b == 52'd0) &&
                             (expa_gt_expb == 1'b0) &&
                             (expa_et_expb == 1'b0) &&
                             (mana_gtet_manb == 1'b0) &&
                             (a_gtet_b == 1'b0) &&
                             (sign == 1'b0) &&
                             (exponent_small == 11'd0) &&
                             (exponent_large == 11'd0) &&
                             (mantissa_small == 52'd0) &&
                             (mantissa_large == 52'd0) &&
                             (small_is_denorm == 1'b0) &&
                             (large_is_denorm == 1'b0) &&
                             (large_norm_small_denorm == 1'b0) &&
                             (small_is_nonzero == 1'b0) &&
                             (exponent_diff == 11'd0) &&
                             (minuend == 56'd0) &&
                             (subtrahend == 56'd0) &&
                             (subtra_shift == 56'd0) &&
                             (subtra_shift_3 == 56'd0) &&
                             (diff_shift_2 == 7'd0) &&
                             (diff_shift == 7'd0) &&
                             (diff == 55'd0) &&
                             (diffshift_gt_exponent == 1'b0) &&
                             (diffshift_et_55 == 1'b0) &&
                             (diff_1 == 56'd0) &&
                             (exponent == 11'd0) &&
                             (exponent_2 == 11'd0) &&
                             (diff_2 == 56'd0)
    );

// When enable is low, all state and outputs hold their values.
    check_hold_when_disabled: assert property (
        @(posedge clk) disable iff (rst)
        !enable |=> $stable(exponent_a) &&
                   $stable(exponent_b) &&
                   $stable(mantissa_a) &&
                   $stable(mantissa_b) &&
                   $stable(expa_gt_expb) &&
                   $stable(expa_et_expb) &&
                   $stable(mana_gtet_manb) &&
                   $stable(a_gtet_b) &&
                   $stable(sign) &&
                   $stable(exponent_small) &&
                   $stable(exponent_large) &&
                   $stable(mantissa_small) &&
                   $stable(mantissa_large) &&
                   $stable(small_is_denorm) &&
                   $stable(large_is_denorm) &&
                   $stable(large_norm_small_denorm) &&
                   $stable(small_is_nonzero) &&
                   $stable(exponent_diff) &&
                   $stable(minuend) &&
                   $stable(subtrahend) &&
                   $stable(subtra_shift) &&
                   $stable(subtra_shift_3) &&
                   $stable(diff_shift_2) &&
                   $stable(diff_shift) &&
                   $stable(diff) &&
                   $stable(diffshift_gt_exponent) &&
                   $stable(diffshift_et_55) &&
                   $stable(diff_1) &&
                   $stable(exponent) &&
                   $stable(exponent_2) &&
                   $stable(diff_2)
    );

// exponent_a captures opa[62:52] on the next cycle.
    check_exponent_a_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (exponent_a == $past(opa[62:52]))
    );

// exponent_b captures opb[62:52] on the next cycle.
    check_exponent_b_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (exponent_b == $past(opb[62:52]))
    );

// mantissa_a captures opa[51:0] on the next cycle.
    check_mantissa_a_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (mantissa_a == $past(opa[51:0]))
    );

// mantissa_b captures opb[51:0] on the next cycle.
    check_mantissa_b_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (mantissa_b == $past(opb[51:0]))
    );

// expa_gt_expb reflects exponent_a > exponent_b.
    check_exp_gt_relation: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (expa_gt_expb == ($past(exponent_a) > $past(exponent_b)))
    );

// expa_et_expb reflects exponent_a == exponent_b.
    check_exp_eq_relation: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (expa_et_expb == ($past(exponent_a) == $past(exponent_b)))
    );

// mana_gtet_manb reflects mantissa_a >= mantissa_b.
    check_mant_gt_relation: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (mana_gtet_manb == ($past(mantissa_a) >= $past(mantissa_b)))
    );

// a_gtet_b reflects the signed comparison result.
    check_signed_cmp_result: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (a_gtet_b == (($past(exponent_a) > $past(exponent_b)) ||
                                 (($past(exponent_a) == $past(exponent_b)) &&
                                  (($past(opa[63]) && !$past(opb[63])) ||
                                   (!$past(opa[63]) && $past(opb[63])) ||
                                   ($past(opa[63]) && $past(opb[63]) &&
                                    ($past(mantissa_a) >= $past(mantissa_b)))))))
    );

// sign follows the RTL expression for subtraction.
    check_sign_calculation: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (sign == (($past(exponent_a) > $past(exponent_b)) ||
                             (($past(exponent_a) == $past(exponent_b)) &&
                              (($past(opa[63]) && !$past(opb[63])) ||
                               (!$past(opa[63]) && $past(opb[63])) ||
                               ($past(opa[63]) && $past(opb[63]) &&
                                ($past(mantissa_a) >= $past(mantissa_b)))))))
    );

// exponent_small captures the smaller exponent.
    check_exponent_small_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (exponent_small == ($past(exponent_a) < $past(exponent_b) ? $past(exponent_a) : $past(exponent_b)))
    );

// exponent_large captures the larger exponent.
    check_exponent_large_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (exponent_large == ($past(exponent_a) > $past(exponent_b) ? $past(exponent_a) : $past(exponent_b)))
    );

// mantissa_small captures the mantissa of the smaller exponent.
    check_mantissa_small_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (mantissa_small == ($past(exponent_a) < $past(exponent_b) ? $past(mantissa_a) : $past(mantissa_b)))
    );

// mantissa_large captures the mantissa of the larger exponent.
    check_mantissa_large_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (mantissa_large == ($past(exponent_a) > $past(exponent_b) ? $past(mantissa_a) : $past(mantissa_b)))
    );

// small_is_denorm reflects whether the smaller exponent is denormal.
    check_small_denorm_flag: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (small_is_denorm == ($past(exponent_small) == 11'd0))
    );

// large_is_denorm reflects whether the larger exponent is denormal.
    check_large_denorm_flag: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (large_is_denorm == ($past(exponent_large) == 11'd0))
    );

// large_norm_small_denorm reflects the specific case of a large normalized minus a small denormal.
    check_large_norm_small_denorm_flag: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (large_norm_small_denorm == ($past(exponent_large) > 11'd0 && $past(exponent_small) == 11'd0))
    );

// small_is_nonzero reflects whether the smaller exponent mantissa is nonzero.
    check_small_nonzero_flag: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (small_is_nonzero == ($past(exponent_small) > 11'd0 || |$past(mantissa_small)))
    );

// exponent_diff captures the difference between the two exponents.
    check_exponent_diff_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (exponent_diff == ($past(exponent_large) - $past(exponent_small) - $past(large_norm_small_denorm)))
    );

// minuend is constructed from the larger exponent value.
    check_minuend_construction: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (minuend == {~$past(large_is_denorm), $past(mantissa_large), 2'b00})
    );

// subtrahend is constructed from the smaller exponent value.
    check_subtrahend_construction: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (subtrahend == {~$past(small_is_denorm), $past(mantissa_small), 2'b00})
    );

// subtra_shift is the subtrahend right-shifted by exponent_diff.
    check_subtra_shift_construction: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (subtra_shift == {$past(subtrahend[54:0]) >> $past(exponent_diff)})
    );

// subtra_shift_3 selects between subtra_shift and subtra_shift_2.
    check_subtra_shift_3_selection: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (subtra_shift_3 == ($past(small_is_nonzero) && !$past(subtra_shift_nonzero) ? $past(subtra_shift_2) : $past(subtra_shift)))
    );

// diff_shift_2 captures the previous diff_shift value.
    check_diff_shift_2_capture: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (diff_shift_2 == $past(diff_shift))
    );

// diff captures the subtraction result.
    check_diff_construction: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (diff == ($past(minuend) - $past(subtra_shift_3)))
    );

// diffshift_gt_exponent reflects whether diff_shift_2 exceeds exponent_large.
    check_diff_shift_gt_exponent: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (diffshift_gt_exponent == ($past(diff_shift_2) > $past(exponent_large)))
    );

// diffshift_et_55 reflects whether diff_shift_2 equals 55.
    check_diff_shift_et_55: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (diffshift_et_55 == ($past(diff_shift_2) == 7'd55))
    );

// diff_1 is the shifted difference result.
    check_diff_1_construction: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (diff_1 == ($past(diffshift_gt_exponent) ? {$past(diff) << $past(exponent_large)} : {$past(diff) << $past(diff_shift_2)}))
    );

// exponent captures the final exponent value.
    check_exponent_construction: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (exponent == ($past(diffshift_gt_exponent) ? 11'd0 : $past(exponent_large) - $past(diff_shift_2)))
    );

// exponent_2 is zero when diff_shift_2 equals 55, else it follows exponent.
    check_exponent_2_construction: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (exponent_2 == ($past(diffshift_et_55) ? 11'd0 : $past(exponent)))
    );

// diff_2 is zero when exponent_large is zero, else it follows diff_1.
    check_diff_2_construction: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (diff_2 == ($past(exponent_large) == 11'd0 ? 56'd0 : {$past(in_norm_out_denorm) ? 1'b0 : 1'b1, $past(diff_1) >> 1}))
    );

endmodule
