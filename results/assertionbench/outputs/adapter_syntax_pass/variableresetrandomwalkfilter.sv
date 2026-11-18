module randomwalkfilter_sva #(
    parameter int FilterLength      = 8,
    parameter int FilterResetValue  = 4,
    parameter int FilterMaxValue    = FilterResetValue,
    parameter int FilterMinValue    = 256 - FilterResetValue
) (
    input logic MainClock,
    input logic Lead,
    input logic Lag,
    input logic Positive,
    input logic Negative,
    input logic [FilterLength-1:0] FilterCounter
);

    // Positive is asserted exactly when FilterCounter is at FilterMaxValue.
    check_positive_definition: assert property (
        @(posedge MainClock) Positive == (FilterCounter == FilterMaxValue)
    );

    // Negative is asserted exactly when FilterCounter is at FilterMinValue.
    check_negative_definition: assert property (
        @(posedge MainClock) Negative == (FilterCounter == FilterMinValue)
    );

    // Positive and Negative are never asserted together.
    check_outputs_mutually_exclusive: assert property (
        @(posedge MainClock) !(Positive && Negative)
    );

    // FilterCounter is zero on the cycle after it reaches FilterMaxValue or FilterMinValue.
    check_counter_zero_on_boundary: assert property (
        @(posedge MainClock) ((FilterCounter == FilterMaxValue) || (FilterCounter == FilterMinValue)) |=> (FilterCounter == '0)
    );

    // FilterCounter increments by one when Lead is high and not at a boundary.
    check_increment_on_lead: assert property (
        @(posedge MainClock) (Lead && !(FilterCounter == FilterMaxValue) && !(FilterCounter == FilterMinValue)) |=> (FilterCounter == ($past(FilterCounter) + 1'b1))
    );

    // FilterCounter decrements by one when Lag is high and not at a boundary.
    check_decrement_on_lag: assert property (
        @(posedge MainClock) (Lag && !(FilterCounter == FilterMaxValue) && !(FilterCounter == FilterMinValue)) |=> (FilterCounter == ($past(FilterCounter) - 1'b1))
    );

    // FilterCounter holds when neither Lead nor Lag is asserted.
    check_hold_when_idle: assert property (
        @(posedge MainClock) (!Lead && !Lag) |=> (FilterCounter == $past(FilterCounter))
    );

endmodule

module variableresetrandomwalkfilter_sva #(
    parameter int N_FilterLength      = 8,
    parameter int N_FilterResetValue  = 8,
    parameter int N_FilterMaxValue    = N_FilterResetValue,
    parameter int ResetterCounterLength   = 4,
    parameter int ResetterCounterMaxValue = 3,
    parameter int ResetterCounterMinValue = 16 - 3
) (
    input logic MainClock,
    input logic Lead,
    input logic Lag,
    input logic Positive,
    input logic Negative,
    input logic [N_FilterLength-1:0] N_FilterCounter
);

    // Positive is asserted exactly when N_FilterCounter is at N_FilterMaxValue.
    check_positive_definition: assert property (
        @(posedge MainClock) Positive == (N_FilterCounter == N_FilterMaxValue)
    );

    // Negative is asserted exactly when N_FilterCounter is at N_FilterMinValue.
    check_negative_definition: assert property (
        @(posedge MainClock) Negative == (N_FilterCounter == (256 - N_FilterResetValue))
    );

    // Positive and Negative are never asserted together.
    check_outputs_mutually_exclusive: assert property (
        @(posedge MainClock) !(Positive && Negative)
    );

    // N_FilterCounter is zero on the cycle after it reaches N_FilterMaxValue or N_FilterMinValue.
    check_counter_zero_on_boundary: assert property (
        @(posedge MainClock) ((N_FilterCounter == N_FilterMaxValue) || (N_FilterCounter == (256 - N_FilterResetValue))) |=> (N_FilterCounter == '0)
    );

    // N_FilterCounter increments by one when Lead is high and not at a boundary.
    check_increment_on_lead: assert property (
        @(posedge MainClock) (Lead && !(N_FilterCounter == N_FilterMaxValue) && !(N_FilterCounter == (256 - N_FilterResetValue))) |=> (N_FilterCounter == ($past(N_FilterCounter) + 1'b1))
    );

    // N_FilterCounter decrements by one when Lag is high and not at a boundary.
    check_decrement_on_lag: assert property (
        @(posedge MainClock) (Lag && !(N_FilterCounter == N_FilterMaxValue) && !(N_FilterCounter == (256 - N_FilterResetValue))) |=> (N_FilterCounter == ($past(N_FilterCounter) - 1'b1))
    );

    // N_FilterCounter holds when neither Lead nor Lag is asserted.
    check_hold_when_idle: assert property (
        @(posedge MainClock) (!Lead && !Lag) |=> (N_FilterCounter == $past(N_FilterCounter))
    );

endmodule