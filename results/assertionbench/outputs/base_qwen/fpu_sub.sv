```systemverilog
module fpu_sub_sva (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic [63:0] opa,
    input logic [63:0] opb,
    input logic [2:0] fpu_op,
    output logic sign,
    output logic [55:0] diff_2,
    output logic [10:0] exponent_2
);
    // Reset polarity is active low
    // The logic is sequential

    // Assertions for FPU behavior

    // 1. Exponent_a and exponent_b are correctly assigned from opa and opb
    assign_exponents: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (exponent_a == opa[62:52]) && (exponent_b == opb[62:52]))
    ) else $error("Exponent_a and exponent_b not correctly assigned");

    // 2. Mantissa_a and mantissa_b are correctly assigned from opa and opb
    assign_mantissas: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (mantissa_a == opa[51:0]) && (mantissa_b == opb[51:0]))
    ) else $error("Mantissa_a and mantissa_b not correctly assigned");

    // 3. expa_gt_expb is correctly assigned
    assign_exp_gt_expb: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (expa_gt_expb == (exponent_a > exponent_b)))
    ) else $error("expa_gt_expb not correctly assigned");

    // 4. expa_et_expb is correctly assigned
    assign_exp_et_expb: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (expa_et_expb == (exponent_a == exponent_b)))
    ) else $error("expa_et_expb not correctly assigned");

    // 5. mana_gtet_manb is correctly assigned
    assign_mant_gtet_mantb: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (mana_gtet_manb == (mantissa_a >= mantissa_b)))
    ) else $error("mana_gtet_manb not correctly assigned");

    // 6. a_gtet_b is correctly assigned
    assign_a_gtet_b: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (a_gtet_b == (expa_gt_expb | (expa_et_expb & mana_gtet_manb))))
    ) else $error("a_gtet_b not correctly assigned");

    // 7. sign is correctly assigned
    assign_sign: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (sign == (a_gtet_b ? opa[63] : !opb[63] ^ (fpu_op == 3'b000))))
    ) else $error("sign not correctly assigned");

    // 8. exponent_small is correctly assigned
    assign_exponent_small: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (exponent_small == (a_gtet_b ? exponent_b : exponent_a)))
    ) else $error("exponent_small not correctly assigned");

    // 9. exponent_large is correctly assigned
    assign_exponent_large: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (exponent_large == (a_gtet_b ? exponent_a : exponent_b)))
    ) else $error("exponent_large not correctly assigned");

    // 10. mantissa_small is correctly assigned
    assign_mantissa_small: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (mantissa_small == (a_gtet_b ? mantissa_b : mantissa_a)))
    ) else $error("mantissa_small not correctly assigned");

    // 11. mantissa_large is correctly assigned
    assign_mantissa_large: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (mantissa_large == (a_gtet_b ? mantissa_a : mantissa_b)))
    ) else $error("mantissa_large not correctly assigned");

    // 12. small_is_denorm is correctly assigned
    assign_small_is_denorm: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (small_is_denorm == !(exponent_small > 0)))
    ) else $error("small_is_denorm not correctly assigned");

    // 13. large_is_denorm is correctly assigned
    assign_large_is_denorm: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (large_is_denorm == !(exponent_large > 0)))
    ) else $error("large_is_denorm not correctly assigned");

    // 14. large_norm_small_denorm is correctly assigned
    assign_large_norm_small_denorm: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (large_norm_small_denorm == (small_is_denorm && large_is_denorm)))
    ) else $error("large_norm_small_denorm not correctly assigned");

    // 15. small_is_nonzero is correctly assigned
    assign_small_is_nonzero: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (small_is_nonzero == (exponent_small > 0 || mantissa_small[51:0] != 0)))
    ) else $error("small_is_nonzero not correctly assigned");

    // 16. exponent_diff is correctly assigned
    assign_exponent_diff: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (exponent_diff == (exponent_large - exponent_small - large_norm_small_denorm)))
    ) else $error("exponent_diff not correctly assigned");

    // 17. minuend is correctly assigned
    assign_minuend: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (minuend == { !large_is_denorm, mantissa_large, 2'b00 }))
    ) else $error("minuend not correctly assigned");

    // 18. subtrahend is correctly assigned
    assign_subtrahend: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (subtrahend == { !small_is_denorm, mantissa_small, 2'b00 }))
    ) else $error("subtrahend not correctly assigned");

    // 19. subtra_shift is correctly assigned
    assign_subtra_shift: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (subtra_shift == (subtrahend >> exponent_diff)))
    ) else $error("subtra_shift not correctly assigned");

    // 20. subtra_shift_3 is correctly assigned
    assign_subtra_shift_3: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (subtra_shift_3 == (subtra_fraction_enable ? subtra_shift_2 : subtra_shift)))
    ) else $error("subtra_shift_3 not correctly assigned");

    // 21. diff_shift_2 is correctly assigned
    assign_diff_shift_2: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (diff_shift_2 == diff_shift))
    ) else $error("diff_shift_2 not correctly assigned");

    // 22. diff is correctly assigned
    assign_diff: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (diff == (minuend - subtra_shift_3)))
    ) else $error("diff not correctly assigned");

    // 23. diffshift_gt_exponent is correctly assigned
    assign_diffshift_gt_exponent: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (diffshift_gt_exponent == (diff_shift_2 > exponent_large)))
    ) else $error("diffshift_gt_exponent not correctly assigned");

    // 24. diffshift_et_55 is correctly assigned
    assign_diffshift_et_55: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (diffshift_et_55 == (diff_shift_2 == 55)))
    ) else $error("diffshift_et_55 not correctly assigned");

    // 25. diff_1 is correctly assigned
    assign_diff_1: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (diff_1 == (diffshift_gt_exponent ? (diff << exponent_large) : (diff << diff_shift_2))))
    ) else $error("diff_1 not correctly assigned");

    // 26. exponent is correctly assigned
    assign_exponent: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (exponent == (diffshift_gt_exponent ? 0 : (exponent_large - diff_shift_2))))
    ) else $error("exponent not correctly assigned");

    // 27. exponent_2 is correctly assigned
    assign_exponent_2: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (exponent_2 == (diffshift_et_55 ? 0 : exponent)))
    ) else $error("exponent_2 not correctly assigned");

    // 28. diff_2 is correctly assigned
    assign_diff_2: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (diff_2 == (in_norm_out_denorm ? { 1'b0, diff_1 >> 1} : {1'b0, diff_1})))
    ) else $error("diff_2 not correctly assigned");

endmodule
```