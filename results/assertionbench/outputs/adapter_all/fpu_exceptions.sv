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

    // Reset clears all registered outputs.
    check_reset_clears_outputs: assert property (
        @(posedge clk) rst |=> (ex_enable == 1'b0) &&
                               (underflow == 1'b0) &&
                               (overflow == 1'b0) &&
                               (inexact == 1'b0) &&
                               (exception == 1'b0) &&
                               (invalid == 1'b0) &&
                               (out == 64'b0)
    );

    // ex_enable is asserted only when enable_trigger is high.
    check_ex_enable_matches_enable_trigger: assert property (
        @(posedge clk) disable iff (rst)
        ex_enable == $past(enable_trigger)
    );

    // underflow is asserted only when underflow_trigger is high.
    check_underflow_matches_underflow_trigger: assert property (
        @(posedge clk) disable iff (rst)
        underflow == $past(underflow_trigger)
    );

    // overflow is asserted only when overflow_trigger is high.
    check_overflow_matches_overflow_trigger: assert property (
        @(posedge clk) disable iff (rst)
        overflow == $past(overflow_trigger)
    );

    // inexact is asserted only when inexact_trigger is high.
    check_inexact_matches_inexact_trigger: assert property (
        @(posedge clk) disable iff (rst)
        inexact == $past(inexact_trigger)
    );

    // exception is asserted only when except_trigger is high.
    check_exception_matches_except_trigger: assert property (
        @(posedge clk) disable iff (rst)
        exception == $past(except_trigger)
    );

    // invalid is asserted only when invalid_trigger is high.
    check_invalid_matches_invalid_trigger: assert property (
        @(posedge clk) disable iff (rst)
        invalid == $past(invalid_trigger)
    );

    // out follows the registered output chain from the previous cycle.
    check_out_matches_registered_output_chain: assert property (
        @(posedge clk) disable iff (rst)
        out == $past(out_2)
    );

    // out_2 selects the NaN path when NaN_out_trigger is high.
    check_out2_selects_nan_path: assert property (
        @(posedge clk) disable iff (rst)
        $past(NaN_out_trigger) |-> (out_2 == { $past(in_except[63]), $past(NaN_output) })
    );

    // out_2 selects the inf_round_down path when inf_round_down_trigger is high.
    check_out2_selects_inf_round_down_path: assert property (
        @(posedge clk) disable iff (rst)
        $past(inf_round_down_trigger) |-> (out_2 == { $past(in_except[63]), $past(inf_round_down) })
    );

    // out_2 selects the out_inf_trigger path when out_inf_trigger is high.
    check_out2_selects_out_inf_trigger_path: assert property (
        @(posedge clk) disable iff (rst)
        $past(out_inf_trigger) |-> (out_2 == { $past(in_except[63]), $past(out_inf) })
    );

    // out_2 selects the underflow_trigger path when underflow_trigger is high.
    check_out2_selects_underflow_trigger_path: assert property (
        @(posedge clk) disable iff (rst)
        $past(underflow_trigger) |-> (out_2 == { $past(in_except[63]), $past(out_0) })
    );

    // out_2 selects the in_except path when no earlier trigger is high.
    check_out2_selects_in_except_path: assert property (
        @(posedge clk) disable iff (rst)
        !$past(NaN_out_trigger) &&
        !$past(inf_round_down_trigger) &&
        !$past(out_inf_trigger) &&
        !$past(underflow_trigger) |-> (out_2 == $past(in_except))
    );

    // out follows the NaN path when NaN_out_trigger is high.
    check_out_follows_nan_path: assert property (
        @(posedge clk) disable iff (rst)
        $past(NaN_out_trigger) |-> (out == { $past(in_except[63]), $past(NaN_output) })
    );

    // out follows the inf_round_down path when inf_round_down_trigger is high.
    check_out_follows_inf_round_down_path: assert property (
        @(posedge clk) disable iff (rst)
        $past(inf_round_down_trigger) |-> (out == { $past(in_except[63]), $past(inf_round_down) })
    );

    // out follows the out_inf_trigger path when out_inf_trigger is high.
    check_out_follows_out_inf_trigger_path: assert property (
        @(posedge clk) disable iff (rst)
        $past(out_inf_trigger) |-> (out == { $past(in_except[63]), $past(out_inf) })
    );

    // out follows the underflow_trigger path when underflow_trigger is high.
    check_out_follows_underflow_trigger_path: assert property (
        @(posedge clk) disable iff (rst)
        $past(underflow_trigger) |-> (out == { $past(in_except[63]), $past(out_0) })
    );

    // out follows the in_except path when no earlier trigger is high.
    check_out_follows_in_except_path: assert property (
        @(posedge clk) disable iff (rst)
        !$past(NaN_out_trigger) &&
        !$past(inf_round_down_trigger) &&
        !$past(out_inf_trigger) &&
        !$past(underflow_trigger) |-> (out == $past(in_except))
    );

    // exception is asserted only when except_trigger is high.
    check_exception_matches_except_trigger: assert property (
        @(posedge clk) disable iff (rst)
        exception == $past(except_trigger)
    );

    // invalid is asserted only when invalid_trigger is high.
    check_invalid_matches_invalid_trigger: assert property (
        @(posedge clk) disable iff (rst)
        invalid == $past(invalid_trigger)
    );

    // exception and invalid are never asserted together.
    check_exception_and_invalid_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(exception && invalid)
    );

    // exception implies one of the three trigger conditions.
    check_exception_implies_trigger: assert property (
        @(posedge clk) disable iff (rst)
        exception |-> $past(except_trigger)
    );

    // invalid implies one of the three trigger conditions.
    check_invalid_implies_trigger: assert property (
        @(posedge clk) disable iff (rst)
        invalid |-> $past(invalid_trigger)
    );

    // underflow and overflow are never asserted together.
    check_underflow_and_overflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(underflow && overflow)
    );

    // inexact and overflow are never asserted together.
    check_inexact_and_overflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(inexact && overflow)
    );

    // inexact and underflow are never asserted together.
    check_inexact_and_underflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(inexact && underflow)
    );

    // exception and overflow are never asserted together.
    check_exception_and_overflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(exception && overflow)
    );

    // exception and underflow are never asserted together.
    check_exception_and_underflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(exception && underflow)
    );

    // exception and inexact are never asserted together.
    check_exception_and_inexact_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(exception && inexact)
    );

    // invalid and overflow are never asserted together.
    check_invalid_and_overflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(invalid && overflow)
    );

    // invalid and underflow are never asserted together.
    check_invalid_and_underflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(invalid && underflow)
    );

    // invalid and inexact are never asserted together.
    check_invalid_and_inexact_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(invalid && inexact)
    );

    // inexact implies one of the three trigger conditions.
    check_inexact_implies_trigger: assert property (
        @(posedge clk) disable iff (rst)
        inexact |-> $past(inexact_trigger)
    );

    // underflow implies one of the three trigger conditions.
    check_underflow_implies_trigger: assert property (
        @(posedge clk) disable iff (rst)
        underflow |-> $past(underflow_trigger)
    );

    // overflow implies one of the three trigger conditions.
    check_overflow_implies_trigger: assert property (
        @(posedge clk) disable iff (rst)
        overflow |-> $past(overflow_trigger)
    );

    // ex_enable implies one of the three trigger conditions.
    check_ex_enable_implies_trigger: assert property (
        @(posedge clk) disable iff (rst)
        ex_enable |-> $past(enable_trigger)
    );

    // ex_enable implies at least one of the three exception outputs.
    check_ex_enable_implies_exception_output: assert property (
        @(posedge clk) disable iff (rst)
        ex_enable |-> (exception || invalid || overflow || underflow || inexact)
    );

    // exception implies at least one of the three exception outputs.
    check_exception_implies_exception_output: assert property (
        @(posedge clk) disable iff (rst)
        exception |-> (exception || invalid || overflow || underflow || inexact)
    );

    // invalid implies at least one of the three exception outputs.
    check_invalid_implies_exception_output: assert property (
        @(posedge clk) disable iff (rst)
        invalid |-> (exception || invalid || overflow || underflow || inexact)
    );

    // overflow implies at least one of the three exception outputs.
    check_overflow_implies_exception_output: assert property (
        @(posedge clk) disable iff (rst)
        overflow |-> (exception || invalid || overflow || underflow || inexact)
    );

    // underflow implies at least one of the three exception outputs.
    check_underflow_implies_exception_output: assert property (
        @(posedge clk) disable iff (rst)
        underflow |-> (exception || invalid || overflow || underflow || inexact)
    );

    // inexact implies at least one of the three exception outputs.
    check_inexact_implies_exception_output: assert property (
        @(posedge clk) disable iff (rst)
        inexact |-> (exception || invalid || overflow || underflow || inexact)
    );

    // ex_enable is a subset of exception.
    check_ex_enable_subset_of_exception: assert property (
        @(posedge clk) disable iff (rst)
        ex_enable |-> exception
    );

    // exception is a subset of invalid.
    check_exception_subset_of_invalid: assert property (
        @(posedge clk) disable iff (rst)
        exception |-> invalid
    );

    // invalid implies overflow or underflow.
    check_invalid_implies_overflow_or_underflow: assert property (
        @(posedge clk) disable iff (rst)
        invalid |-> (overflow || underflow)
    );

    // overflow and underflow are mutually exclusive.
    check_overflow_and_underflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(overflow && underflow)
    );

    // inexact and overflow are mutually exclusive.
    check_inexact_and_overflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(inexact && overflow)
    );

    // inexact and underflow are mutually exclusive.
    check_inexact_and_underflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(inexact && underflow)
    );

    // exception and overflow are mutually exclusive.
    check_exception_and_overflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(exception && overflow)
    );

    // exception and underflow are mutually exclusive.
    check_exception_and_underflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(exception && underflow)
    );

    // exception and inexact are mutually exclusive.
    check_exception_and_inexact_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(exception && inexact)
    );

    // invalid and overflow are mutually exclusive.
    check_invalid_and_overflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(invalid && overflow)
    );

    // invalid and underflow are mutually exclusive.
    check_invalid_and_underflow_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(invalid && underflow)
    );

    // invalid and inexact are mutually exclusive.
    check_invalid_and_inexact_mutex: assert property (
        @(posedge clk) disable iff (rst)
        !(invalid && inexact)
    );

endmodule