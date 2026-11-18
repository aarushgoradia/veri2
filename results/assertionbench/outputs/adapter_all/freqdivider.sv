module freqdivider_sva #(
    parameter int DividerLength = 7,
    parameter int DividerMaxValue = 48
) (
    input logic MainClock,
    input logic Positive,
    input logic Negative,
    input logic FrequencyOut,
    input logic [DividerLength-1:0] DividerCounter
);

    // Counter wraps to zero when the previous value was DividerMaxValue-1.
    check_counter_wraps_at_max: assert property (
        @(posedge MainClock)
        ($past(DividerCounter) == DividerMaxValue - 1) |-> (DividerCounter == '0)
    );

    // Counter increments by 2 when Negative was high and not at max.
    check_counter_increments_by_two_on_negative: assert property (
        @(posedge MainClock)
        (!$past(DividerCounter) == DividerMaxValue - 1) && $past(Negative)
        |-> (DividerCounter == $past(DividerCounter) + 2)
    );

    // Counter holds its value when Positive was high and not at max.
    check_counter_holds_on_positive: assert property (
        @(posedge MainClock)
        (!$past(DividerCounter) == DividerMaxValue - 1) && $past(Positive)
        |-> (DividerCounter == $past(DividerCounter))
    );

    // Counter increments by 1 when neither phase signal was high and not at max.
    check_counter_increments_by_one_without_phase: assert property (
        @(posedge MainClock)
        (!$past(DividerCounter) == DividerMaxValue - 1) && !$past(Positive) && !$past(Negative)
        |-> (DividerCounter == $past(DividerCounter) + 1)
    );

    // FrequencyOut toggles when the previous counter value was zero.
    check_frequencyout_toggles_on_zero_counter: assert property (
        @(posedge MainClock)
        $past(DividerCounter) == '0 |-> (FrequencyOut == ~$past(FrequencyOut))
    );

    // FrequencyOut holds its value when the previous counter value was nonzero.
    check_frequencyout_holds_on_nonzero_counter: assert property (
        @(posedge MainClock)
        $past(DividerCounter) != '0 |-> (FrequencyOut == $past(FrequencyOut))
    );

endmodule