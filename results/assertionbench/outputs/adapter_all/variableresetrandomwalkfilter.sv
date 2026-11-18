module randomwalkfilter_sva #(
    parameter int FilterLength = 8,
    parameter int FilterResetValue = 4,
    parameter int FilterMaxValue = FilterResetValue,
    parameter int FilterMinValue = 256 - FilterResetValue
) (
    input logic MainClock,
    input logic Lead,
    input logic Lag,
    input logic Positive,
    input logic Negative,
    input logic [FilterLength-1:0] FilterCounter
);

    // Positive is asserted only when the counter reaches the max value.
    check_positive_definition: assert property (
        @(posedge MainClock) Positive == (FilterCounter == FilterMaxValue)
    );

    // Negative is asserted only when the counter reaches the min value.
    check_negative_definition: assert property (
        @(posedge MainClock) Negative == (FilterCounter == FilterMinValue)
    );

    // The counter clears when the terminal count is reached.
    check_counter_clears_at_terminal_value: assert property (
        @(posedge MainClock) ((FilterCounter == FilterMaxValue) || (FilterCounter == FilterMinValue)) |=> (FilterCounter == '0)
    );

    // The counter holds when it is not at a terminal count.
    check_counter_holds_outside_terminal_value: assert property (
        @(posedge MainClock) !((FilterCounter == FilterMaxValue) || (FilterCounter == FilterMinValue)) |=> (FilterCounter == $past(FilterCounter))
    );

    // Lead increments the counter when not at a terminal count.
    check_lead_increments_counter: assert property (
        @(posedge MainClock) (!((FilterCounter == FilterMaxValue) || (FilterCounter == FilterMinValue)) && Lead) |=> (FilterCounter == ($past(FilterCounter) + 1'b1))
    );

    // Lag decrements the counter when not at a terminal count.
    check_lag_decrements_counter: assert property (
        @(posedge MainClock) (!((FilterCounter == FilterMaxValue) || (FilterCounter == FilterMinValue)) && Lag) |=> (FilterCounter == ($past(FilterCounter) - 1'b1))
    );

    // Lead and Lag are ignored when both are asserted.
    check_lead_lag_ignore_when_both_asserted: assert property (
        @(posedge MainClock) (!((FilterCounter == FilterMaxValue) || (FilterCounter == FilterMinValue)) && Lead && Lag) |=> (FilterCounter == $past(FilterCounter))
    );

endmodule

module variableresetrandomwalkfilter_sva #(
    parameter int N_FilterLength = 8,
    parameter int N_FilterResetValue = 8,
    parameter int N_FilterMaxValue = N_FilterResetValue,
    parameter int N_FilterMinValue = 256 - N_FilterResetValue,
    parameter int ResetterCounterLength = 4,
    parameter int ResetterCounterMaxValue = 3,
    parameter int ResetterCounterMinValue = 16 - 3
) (
    input logic MainClock,
    input logic Lead,
    input logic Lag,
    input logic Positive,
    input logic Negative,
    input logic [N_FilterLength-1:0] N_FilterCounter,
    input logic [ResetterCounterLength-1:0] ResetterCounter
);

    // Positive is asserted only when the counter reaches the max value.
    check_positive_definition: assert property (
        @(posedge MainClock) Positive == (N_FilterCounter == N_FilterMaxValue)
    );

    // Negative is asserted only when the counter reaches the min value.
    check_negative_definition: assert property (
        @(posedge MainClock) Negative == (N_FilterCounter == N_FilterMinValue)
    );

    // The counter clears when the terminal count is reached.
    check_counter_clears_at_terminal_value: assert property (
        @(posedge MainClock) ((N_FilterCounter == N_FilterMaxValue) || (N_FilterCounter == N_FilterMinValue)) |=> (N_FilterCounter == '0)
    );

    // The counter holds when it is not at a terminal count.
    check_counter_holds_outside_terminal_value: assert property (
        @(posedge MainClock) !((N_FilterCounter == N_FilterMaxValue) || (N_FilterCounter == N_FilterMinValue)) |=> (N_FilterCounter == $past(N_FilterCounter))
    );

    // Lead increments the counter when not at a terminal count.
    check_lead_increments_counter: assert property (
        @(posedge MainClock) (!((N_FilterCounter == N_FilterMaxValue) || (N_FilterCounter == N_FilterMinValue)) && Lead) |=> (N_FilterCounter == ($past(N_FilterCounter) + 1'b1))
    );

    // Lag decrements the counter when not at a terminal count.
    check_lag_decrements_counter: assert property (
        @(posedge MainClock) (!((N_FilterCounter == N_FilterMaxValue) || (N_FilterCounter == N_FilterMinValue)) && Lag) |=> (N_FilterCounter == ($past(N_FilterCounter) - 1'b1))
    );

    // Lead and Lag are ignored when both are asserted.
    check_lead_lag_ignore_when_both_asserted: assert property (
        @(posedge MainClock) (!((N_FilterCounter == N_FilterMaxValue) || (N_FilterCounter == N_FilterMinValue)) && Lead && Lag) |=> (N_FilterCounter == $past(N_FilterCounter))
    );

    // ResetterCounter increments when the up pulse is asserted and within its range.
    check_resetter_counter_increments_on_up: assert property (
        @(posedge MainClock) (Positive && ((ResetterCounter < ResetterCounterMaxValue) || (ResetterCounter >= ResetterCounterMinValue))) |=> (ResetterCounter == ($past(ResetterCounter) + 1'b1))
    );

    // ResetterCounter decrements when the down pulse is asserted and within its range.
    check_resetter_counter_decrements_on_down: assert property (
        @(posedge MainClock) (Negative && ((ResetterCounter <= ResetterCounterMaxValue) || (ResetterCounter > ResetterCounterMinValue))) |=> (ResetterCounter == ($past(ResetterCounter) - 1'b1))
    );

    // ResetterCounter clears when it is outside the reset range.
    check_resetter_counter_clears_outside_range: assert property (
        @(posedge MainClock) ((ResetterCounter > ResetterCounterMaxValue) && (ResetterCounter < ResetterCounterMinValue)) |=> (ResetterCounter == '0)
    );

    // ResetterCounter holds when it is not at a terminal count.
    check_resetter_counter_holds_outside_terminal_value: assert property (
        @(posedge MainClock) !((ResetterCounter > ResetterCounterMaxValue) && (ResetterCounter < ResetterCounterMinValue)) |=> (ResetterCounter == $past(ResetterCounter))
    );

endmodule