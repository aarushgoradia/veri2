module freqdivider_sva #(
    parameter DividerLength   = 7,
    parameter DividerMaxValue = 48
) (
    input logic MainClock,
    input logic Positive,
    input logic Negative,
    input logic FrequencyOut,
    input logic [DividerLength-1:0] DividerCounter
);

    // Counter is zero on the first cycle after reset deasserts.
    check_counter_zero_after_reset: assert property (
        @(posedge MainClock) disable iff ($initstate)
        $past($initstate || !($initstate || $past($initstate))) |-> (DividerCounter == '0)
    );

    // Counter is zero on the first cycle after the previous counter was at or above DividerMaxValue.
    check_counter_zero_after_wrap: assert property (
        @(posedge MainClock) disable iff ($initstate)
        $past(DividerCounter >= (DividerMaxValue - 1)) |-> (DividerCounter == '0)
    );

    // Counter increments by one when it is below DividerMaxValue and neither control is asserted.
    check_counter_increment_when_idle: assert property (
        @(posedge MainClock) disable iff ($initstate)
        $past(DividerCounter < (DividerMaxValue - 1)) && !$past(Negative) && !$past(Positive)
        |-> (DividerCounter == $past(DividerCounter) + 1)
    );

    // Counter increments by two when Negative is asserted and below DividerMaxValue.
    check_counter_increment_by_two_when_negative: assert property (
        @(posedge MainClock) disable iff ($initstate)
        $past(DividerCounter < (DividerMaxValue - 1)) && $past(Negative) && !$past(Positive)
        |-> (DividerCounter == $past(DividerCounter) + 2)
    );

    // Counter holds when Positive is asserted and below DividerMaxValue.
    check_counter_holds_when_positive: assert property (
        @(posedge MainClock) disable iff ($initstate)
        $past(DividerCounter < (DividerMaxValue - 1)) && $past(Positive) && !$past(Negative)
        |-> (DividerCounter == $past(DividerCounter))
    );

    // FrequencyOut toggles when the counter is zero.
    check_output_toggle_on_zero_counter: assert property (
        @(posedge MainClock) disable iff ($initstate)
        $past(DividerCounter == '0) |-> (FrequencyOut == ~$past(FrequencyOut))
    );

    // FrequencyOut holds when the counter is nonzero.
    check_output_stable_when_counter_nonzero: assert property (
        @(posedge MainClock) disable iff ($initstate)
        $past(DividerCounter != '0) |-> (FrequencyOut == $past(FrequencyOut))
    );

endmodule