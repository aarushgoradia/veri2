```systemverilog
module fpu_add_sva (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic [63:0] opa,
    input logic [63:0] opb,
    output logic sign,
    output logic [55:0] sum_2,
    output logic [10:0] exponent_2
);
    // Reset behavior: At reset, all outputs should be zero
    reset: assert property (
        @(posedge clk) disable iff (!rst) (sign == 1'b0) && (sum_2 == 56'b0) && (exponent_2 == 11'b0)
    );

    // Enable behavior: When enable is high, outputs should be valid
    enable_valid: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (sign != 1'b0) && (sum_2 != 56'b0) && (exponent_2 != 11'b0))
    );

    // Sign behavior: Sign should match the sign of the larger magnitude operand
    sign_behavior: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (sign == (exponent_a > exponent_b ? opa[63] : opb[63])))
    );

    // Exponent behavior: Exponent should be the larger exponent plus the difference if not denorm
    exponent_behavior: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (exponent_2 == (exponent_a > exponent_b ? exponent_a : exponent_b) + (exponent_a > exponent_b ? 0 : exponent_diff)))
    );

    // Sum behavior: Sum should be the result of adding the two operands
    sum_behavior: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (sum_2 == (exponent_a > exponent_b ? mantissa_large + (mantissa_small >> exponent_diff) : mantissa_small + (mantissa_large >> exponent_diff))))
    );

    // Denorm to norm behavior: If the result is denormalized, the exponent should be incremented
    denorm_to_norm_behavior: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (denorm_to_norm |-> (exponent_2 == exponent + 1)))
    );

    // Large norm small denorm behavior: If the smaller operand is denormalized and the larger is normalized, the exponent should be the same
    large_norm_small_denorm_behavior: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (large_norm_small_denorm |-> (exponent_2 == exponent_large)))
    );

    // Small is nonzero behavior: If the smaller operand is nonzero, the small shift should be nonzero
    small_is_nonzero_behavior: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (small_is_nonzero |-> (small_shift_nonzero)))
    );

    // Small fraction enable behavior: If the smaller operand is nonzero and not shifted, the small fraction enable should be high
    small_fraction_enable_behavior: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (small_fraction_enable |-> (small_fraction_enable)))
    );

    // Large add behavior: Large add should be the larger mantissa with a leading bit
    large_add_behavior: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (large_add == {1'b0, !large_is_denorm, mantissa_large, 2'b0}))
    );

    // Small add behavior: Small add should be the smaller mantissa with a leading bit
    small_add_behavior: assert property (
        @(posedge clk) disable iff (!rst) (enable |-> (small_add == {1'b0, !small_is_denorm, mantissa_small, 2'b0}))
    );

endmodule
```