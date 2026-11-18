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

// Reset clears all status outputs.
    check_reset_clears_status: assert property (
        @(posedge clk) rst |-> (ex_enable == 1'b0) && (underflow == 1'b0) &&
                               (overflow == 1'b0) && (inexact == 1'b0) &&
                               (exception == 1'b0) && (invalid == 1'b0)
    );

// ex_enable is asserted only when an exception is triggered.
    check_ex_enable_implies_exception: assert property (
        @(posedge clk) disable iff (rst) ex_enable |-> exception
    );

// exception is asserted only when an exception is triggered.
    check_exception_implies_exception: assert property (
        @(posedge clk) disable iff (rst) exception |-> exception
    );

// invalid is asserted only when an invalid operation is triggered.
    check_invalid_implies_invalid: assert property (
        @(posedge clk) disable iff (rst) invalid |-> invalid
    );

// underflow is asserted only when an underflow is triggered.
    check_underflow_implies_underflow: assert property (
        @(posedge clk) disable iff (rst) underflow |-> underflow_trigger
    );

// overflow is asserted only when an overflow is triggered.
    check_overflow_implies_overflow: assert property (
        @(posedge clk) disable iff (rst) overflow |-> overflow_trigger
    );

// inexact is asserted only when an inexact result is triggered.
    check_inexact_implies_inexact: assert property (
        @(posedge clk) disable iff (rst) inexact |-> inexact_trigger
    );

// exception is high exactly when an exception is triggered.
    check_exception_matches_trigger: assert property (
        @(posedge clk) disable iff (rst) exception == except_trigger
    );

// invalid is high exactly when an invalid operation is triggered.
    check_invalid_matches_trigger: assert property (
        @(posedge clk) disable iff (rst) invalid == invalid_trigger
    );

// underflow is high exactly when an underflow is triggered.
    check_underflow_matches_trigger: assert property (
        @(posedge clk) disable iff (rst) underflow == underflow_trigger
    );

// overflow is high exactly when an overflow is triggered.
    check_overflow_matches_trigger: assert property (
        @(posedge clk) disable iff (rst) overflow == overflow_trigger
    );

// inexact is high exactly when an inexact result is triggered.
    check_inexact_matches_trigger: assert property (
        @(posedge clk) disable iff (rst) inexact == inexact_trigger
    );

// ex_enable is high exactly when an exception or inf result is triggered.
    check_ex_enable_matches_trigger: assert property (
        @(posedge clk) disable iff (rst) ex_enable == enable_trigger
    );

// out follows the RTL's priority and rounding logic.
    check_out_priority_and_rounding: assert property (
        @(posedge clk) disable iff (rst)
            out == (invalid_trigger ? {in_except[63], NaN_output} :
                    (out_inf_trigger ? {in_except[63], out_inf} :
                     (underflow_trigger ? {in_except[63], 63'b0} :
                      in_except)))
    );

endmodule
