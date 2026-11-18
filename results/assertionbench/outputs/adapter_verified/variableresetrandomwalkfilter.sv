module variableresetrandomwalkfilter_sva (
    input logic MainClock,
    input logic Lead,
    input logic Lag,
    input logic Positive,
    input logic Negative
);

// Positive can only rise when the counter is at its maximum value.
    check_positive_rise_at_max: assert property (
        @(posedge MainClock) $rose(Positive) |-> (N_FilterCounter == N_FilterMaxValue)
    );

// Negative can only rise when the counter is at its minimum value.
    check_negative_rise_at_min: assert property (
        @(posedge MainClock) $rose(Negative) |-> (N_FilterCounter == N_FilterMinValue)
    );

// Positive and Negative are never asserted together.
    check_outputs_mutex: assert property (
        @(posedge MainClock) !(Positive && Negative)
    );

// When not at a terminal value, the counter must change by at most one.
    check_counter_change_when_not_terminal: assert property (
        @(posedge MainClock) disable iff (1'b0)
            ((N_FilterCounter != N_FilterMaxValue) && (N_FilterCounter != N_FilterMinValue)) |-> (
                $changed(N_FilterCounter) && (|{N_FilterCounter == N_FilterMaxValue, N_FilterCounter == N_FilterMinValue})
            )
    );

// When at a terminal value, the counter must reset to the next reset value.
    check_counter_reset_when_terminal: assert property (
        @(posedge MainClock) disable iff (1'b0)
            ((N_FilterCounter == N_FilterMaxValue) || (N_FilterCounter == N_FilterMinValue)) |-> (
                $changed(N_FilterCounter) && (|{N_FilterCounter == N_FilterMaxValue, N_FilterCounter == N_FilterMinValue})
            )
    );

// Positive can only rise when Lead is asserted.
    check_positive_rise_requires_lead: assert property (
        @(posedge MainClock) $rose(Positive) |-> Lead
    );

// Negative can only rise when Lag is asserted.
    check_negative_rise_requires_lag: assert property (
        @(posedge MainClock) $rose(Negative) |-> Lag
    );

// Lead can only assert when the counter is not at a terminal value.
    check_lead_requires_non_terminal: assert property (
        @(posedge MainClock) Lead |-> ((N_FilterCounter != N_FilterMaxValue) && (N_FilterCounter != N_FilterMinValue))
    );

// Lag can only assert when the counter is not at a terminal value.
    check_lag_requires_non_terminal: assert property (
        @(posedge MainClock) Lag |-> ((N_FilterCounter != N_FilterMaxValue) && (N_FilterCounter != N_FilterMinValue))
    );

// When both Lead and Lag are asserted, the counter must decrement.
    check_both_inputs_decrement: assert property (
        @(posedge MainClock) (Lead && Lag) |-> (N_FilterCounter == (N_FilterCounter - 1))
    );

endmodule
