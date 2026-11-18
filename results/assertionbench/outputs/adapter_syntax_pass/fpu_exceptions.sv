module fpu_exceptions_sva (
    input logic        clk,
    input logic        rst,
    input logic        enable,
    input logic [1:0]  rmode,
    input logic [63:0] opa,
    input logic [63:0] opb,
    input logic [63:0] in_except,
    input logic [11:0] exponent_in,
    input logic [1:0]  mantissa_in,
    input logic [2:0]  fpu_op,
    input logic [63:0] out,
    input logic        ex_enable,
    input logic        underflow,
    input logic        overflow,
    input logic        inexact,
    input logic        exception,
    input logic        invalid
);

    // Reset clears all status and output registers.
    check_reset_clears_status: assert property (
        @(posedge clk)
        rst |-> ((ex_enable == 1'b0) &&
                 (underflow == 1'b0) &&
                 (overflow == 1'b0) &&
                 (inexact == 1'b0) &&
                 (exception == 1'b0) &&
                 (invalid == 1'b0) &&
                 (out == 64'h0))
    );

    // Reset clears the internal exception and output state.
    check_reset_clears_internal_state: assert property (
        @(posedge clk)
        rst |-> ((ex_enable == 1'b0) &&
                 (underflow == 1'b0) &&
                 (overflow == 1'b0) &&
                 (inexact == 1'b0) &&
                 (exception == 1'b0) &&
                 (invalid == 1'b0) &&
                 (out == 64'h0))
    );

    // ex_enable is asserted only when enable_trigger is high.
    check_ex_enable_matches_enable_trigger: assert property (
        @(posedge clk) disable iff (rst)
        ex_enable == enable_trigger
    );

    // underflow is asserted only when underflow_trigger is high.
    check_underflow_matches_underflow_trigger: assert property (
        @(posedge clk) disable iff (rst)
        underflow == underflow_trigger
    );

    // overflow is asserted only when overflow_trigger is high.
    check_overflow_matches_overflow_trigger: assert property (
        @(posedge clk) disable iff (rst)
        overflow == overflow_trigger
    );

    // inexact is asserted only when inexact_trigger is high.
    check_inexact_matches_inexact_trigger: assert property (
        @(posedge clk) disable iff (rst)
        inexact == inexact_trigger
    );

    // exception is asserted only when except_trigger is high.
    check_exception_matches_except_trigger: assert property (
        @(posedge clk) disable iff (rst)
        exception == except_trigger
    );

    // invalid is asserted only when invalid_trigger is high.
    check_invalid_matches_invalid_trigger: assert property (
        @(posedge clk) disable iff (rst)
        invalid == invalid_trigger
    );

    // out is zero-extended from the internal 62-bit output value.
    check_out_upper_bits_zero: assert property (
        @(posedge clk) disable iff (rst)
        out[63] == 1'b0
    );

    // out is zero when enable is low.
    check_out_zero_when_disabled: assert property (
        @(posedge clk) disable iff (rst)
        !enable |-> (out == 64'h0)
    );

    // out is zero when enable_trigger is low.
    check_out_zero_when_no_trigger: assert property (
        @(posedge clk) disable iff (rst)
        !enable_trigger |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is low.
    check_out_zero_when_invalid_no_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && !NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when underflow_trigger is high and out_inf_trigger is low.
    check_out_zero_when_underflow_no_inf: assert property (
        @(posedge clk) disable iff (rst)
        (underflow_trigger && !out_inf_trigger) |-> (out == 64'h0)
    );

    // out is zero when underflow_trigger is high and inf_round_down_trigger is high.
    check_out_zero_when_underflow_inf_round_down: assert property (
        @(posedge clk) disable iff (rst)
        (underflow_trigger && inf_round_down_trigger) |-> (out == 64'h0)
    );

    // out is zero when overflow_trigger is high and out_inf_trigger is low.
    check_out_zero_when_overflow_no_inf: assert property (
        @(posedge clk) disable iff (rst)
        (overflow_trigger && !out_inf_trigger) |-> (out == 64'h0)
    );

    // out is zero when inexact_trigger is high and out_inf_trigger is low.
    check_out_zero_when_inexact_no_inf: assert property (
        @(posedge clk) disable iff (rst)
        (inexact_trigger && !out_inf_trigger) |-> (out == 64'h0)
    );

    // out is zero when inexact_trigger is high and inf_round_down_trigger is high.
    check_out_zero_when_inexact_inf_round_down: assert property (
        @(posedge clk) disable iff (rst)
        (inexact_trigger && inf_round_down_trigger) |-> (out == 64'h0)
    );

    // out is zero when exception is high and out_inf_trigger is low.
    check_out_zero_when_exception_no_inf: assert property (
        @(posedge clk) disable iff (rst)
        (exception && !out_inf_trigger) |-> (out == 64'h0)
    );

    // out is zero when exception is high and inf_round_down_trigger is high.
    check_out_zero_when_exception_inf_round_down: assert property (
        @(posedge clk) disable iff (rst)
        (exception && inf_round_down_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid is high and NaN_out_trigger is low.
    check_out_zero_when_invalid_no_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid && !NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when out_inf_trigger is high and inf_round_down_trigger is high.
    check_out_zero_when_inf_round_down: assert property (
        @(posedge clk) disable iff (rst)
        (out_inf_trigger && inf_round_down_trigger) |-> (out == 64'h0)
    );

    // out is zero when out_inf_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_inf_nan: assert property (
        @(posedge clk) disable iff (rst)
        (out_inf_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when out_inf_trigger is high and SNaN_trigger is high.
    check_out_zero_when_inf_snan: assert property (
        @(posedge clk) disable iff (rst)
        (out_inf_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when NaN_out_trigger is high and SNaN_trigger is high.
    check_out_zero_when_nan_snan: assert property (
        @(posedge clk) disable iff (rst)
        (NaN_out_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when NaN_out_trigger is high and invalid_trigger is high.
    check_out_zero_when_nan_invalid: assert property (
        @(posedge clk) disable iff (rst)
        (NaN_out_trigger && invalid_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check_out_zero_when_invalid_nan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && NaN_out_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and SNaN_trigger is high.
    check_out_zero_when_invalid_snan: assert property (
        @(posedge clk) disable iff (rst)
        (invalid_trigger && SNaN_trigger) |-> (out == 64'h0)
    );

    // out is zero when invalid_trigger is high and NaN_out_trigger is high.
    check