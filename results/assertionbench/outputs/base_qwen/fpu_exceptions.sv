```systemverilog
module fpu_exceptions_sva (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic [1:0] rmode,
    input logic [63:0] opa,
    input logic [63:0] opb,
    input logic [63:0] in_except,
    input logic [11:0] exponent_in,
    input logic [1:0] mantissa_in,
    input logic [2:0] fpu_op,
    output logic [63:0] out,
    output logic ex_enable,
    output logic underflow,
    output logic overflow,
    output logic inexact,
    output logic exception,
    output logic invalid
);
    // Reset behavior
    reset: assert property (
        @(posedge clk) disable iff (!rst) (ex_enable == 1'b0) && (underflow == 1'b0) && (overflow == 1'b0) && (inexact == 1'b0) && (exception == 1'b0) && (invalid == 1'b0) && (out == 64'b0)
    );

    // Enable trigger behavior
    enable_trigger: assert property (
        @(posedge clk) disable iff (!rst) (enable_trigger |-> ex_enable)
    );

    // Exception trigger behavior
    exception_trigger: assert property (
        @(posedge clk) disable iff (!rst) (except_trigger |-> exception)
    );

    // Invalid trigger behavior
    invalid_trigger: assert property (
        @(posedge clk) disable iff (!rst) (invalid_trigger |-> invalid)
    );

    // Overflow trigger behavior
    overflow_trigger: assert property (
        @(posedge clk) disable iff (!rst) (overflow_trigger |-> overflow)
    );

    // Underflow trigger behavior
    underflow_trigger: assert property (
        @(posedge clk) disable iff (!rst) (underflow_trigger |-> underflow)
    );

    // Inexact trigger behavior
    inexact_trigger: assert property (
        @(posedge clk) disable iff (!rst) (inexact_trigger |-> inexact)
    );

    // Output behavior
    output_behavior: assert property (
        @(posedge clk) disable iff (!rst) (out == out_2)
    );

    // NaN output behavior
    NaN_output_behavior: assert property (
        @(posedge clk) disable iff (!rst) (NaN_out_trigger |-> (out[63] == in_except[63]) && (out[62:0] == NaN_output))
    );

    // Infinity output behavior
    infinity_output_behavior: assert property (
        @(posedge clk) disable iff (!rst) (out_inf_trigger |-> (out[63] == in_except[63]) && (out[62:0] == out_inf))
    );

    // Zero output behavior
    zero_output_behavior: assert property (
        @(posedge clk) disable iff (!rst) (underflow_trigger |-> (out[63] == in_except[63]) && (out[62:0] == out_0))
    );

    // Add/Subtract infinity behavior
    addsub_inf_behavior: assert property (
        @(posedge clk) disable iff (!rst) (addsub_inf |-> (out_inf_trigger | (out[63] == in_except[63]) && (out[62:0] == out_inf)))
    );

    // Multiply infinity behavior
    multiply_inf_behavior: assert property (
        @(posedge clk) disable iff (!rst) (mul_inf |-> (out_inf_trigger | (out[63] == in_except[63]) && (out[62:0] == out_inf)))
    );

    // Divide infinity behavior
    divide_inf_behavior: assert property (
        @(posedge clk) disable iff (!rst) (div_inf |-> (out_inf_trigger | (out[63] == in_except[63]) && (out[62:0] == out_inf)))
    );

    // Divide by zero behavior
    divide_by_zero_behavior: assert property (
        @(posedge clk) disable iff (!rst) (div_by_0 |-> (exception | (out[63] == in_except[63]) && (out[62:0] == out_0)))
    );

    // Multiply by zero behavior
    multiply_by_zero_behavior: assert property (
        @(posedge clk) disable iff (!rst) (mul_0_by_inf |-> (exception | (out[63] == in_except[63]) && (out[62:0] == out_0)))
    );

    // Underflow behavior
    underflow_behavior: assert property (
        @(posedge clk) disable iff (!rst) (underflow_trigger |-> (out[63] == in_except[63]) && (out[62:0] == out_0))
    );

    // Invalid operation behavior
    invalid_operation_behavior: assert property (
        @(posedge clk) disable iff (!rst) (invalid_trigger |-> (exception | (out[63] == in_except[63]) && (out[62:0] == out_0)))
    );

    // NaN input behavior
    NaN_input_behavior: assert property (
        @(posedge clk) disable iff (!rst) (NaN_input |-> (exception | (out[63] == in_except[63]) && (out[62:0] == NaN_output)))
    );

    // SNaN input behavior
    SNaN_input_behavior: assert property (
        @(posedge clk) disable iff (!rst) (SNaN_input |-> (exception | (out[63] == in_except[63]) && (out[62:0] == NaN_output)))
    );

    // Add/Subtract invalid behavior
    addsub_invalid_behavior: assert property (
        @(posedge clk) disable iff (!rst) (addsub_inf_invalid |-> (exception | (out[63] == in_except[63]) && (out[62:0] == out_0)))
    );

    // Round to nearest behavior
    round_nearest_behavior: assert property (
        @(posedge clk) disable iff (!rst) (round_nearest |-> (out[63] == in_except[63]) && (out[62:0] == out_0)))
    );

    // Round to zero behavior
    round_to_zero_behavior: assert property (
        @(posedge clk) disable iff (!rst) (round_to_zero |-> (out[63] == in_except[63]) && (out[62:0] == out_0)))
    );

    // Round to positive infinity behavior
    round_to_pos_inf_behavior: assert property (
        @(posedge clk) disable iff (!rst) (round_to_pos_inf |-> (out[63] == in_except[63]) && (out[62:0] == out_0)))
    );

    // Round to negative infinity behavior
    round_to_neg_inf_behavior: assert property (
        @(posedge clk) disable iff (!rst) (round_to_neg_inf |-> (out[63] == in_except[63]) && (out[62:0] == out_0)))
    );

    // Infinity round down behavior
    inf_round_down_behavior: assert property (
        @(posedge clk) disable iff (!rst) (inf_round_down_trigger |-> (out[63] == in_except[63]) && (out[62:0] == inf_round_down))
    );

    // Multiply underflow behavior
    multiply_underflow_behavior: assert property (
        @(posedge clk) disable iff (!rst) (mul_uf |-> (exception | (out[63] == in_except[63]) && (out[62:0] == out_0)))
    );

    // Divide underflow behavior
    divide_underflow_behavior: assert property (
        @(posedge clk) disable iff (!rst) (div_uf |-> (exception | (out[63] == in_except[63]) && (out[62:0] == out_0)))
    );
endmodule
```