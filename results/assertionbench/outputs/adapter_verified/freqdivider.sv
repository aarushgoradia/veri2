module freqdivider_sva (
    input logic MainClock,
    input logic Positive,
    input logic Negative,
    input logic FrequencyOut,
    input logic [6:0] DividerCounter
);

// DividerCounter increments by 1 when both inputs are low.
    check_counter_increments_when_both_low: assert property (
        @(posedge MainClock) (!Positive && !Negative) |=> (DividerCounter == ($past(DividerCounter) + 7'd1))
    );

// DividerCounter increments by 2 when Negative is high.
    check_counter_increments_by_two_when_negative: assert property (
        @(posedge MainClock) Negative |=> (DividerCounter == ($past(DividerCounter) + 7'd2))
    );

// DividerCounter holds its value when Positive is high.
    check_counter_holds_when_positive: assert property (
        @(posedge MainClock) Positive |=> (DividerCounter == $past(DividerCounter))
    );

// DividerCounter wraps from 47 to 0 when the maximum value is reached.
    check_counter_wraps_from_max: assert property (
        @(posedge MainClock) (DividerCounter == 7'd47) |=> (DividerCounter == 7'd0)
    );

// FrequencyOut toggles on the next rising edge when DividerCounter is 0.
    check_output_toggles_on_zero: assert property (
        @(posedge MainClock) (DividerCounter == 7'd0) |=> (FrequencyOut == ~$past(FrequencyOut))
    );

// FrequencyOut holds its value on the next rising edge when DividerCounter is non-zero.
    check_output_holds_when_counter_nonzero: assert property (
        @(posedge MainClock) (DividerCounter != 7'd0) |=> (FrequencyOut == $past(FrequencyOut))
    );

endmodule
