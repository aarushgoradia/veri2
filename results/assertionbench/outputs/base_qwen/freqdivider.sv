```systemverilog
module freqdivider_sva (
    input logic MainClock,
    input logic Positive,
    input logic Negative,
    output logic FrequencyOut
);
    parameter DividerLength = 7;
    parameter DividerMaxValue = 48;

    reg [DividerLength-1 : 0] DividerCounter;

    // Divider counter increments by 2 when Negative is high
    property p_divider_counter_incr_2;
        @(posedge MainClock) disable iff (!MainClock) Negative |-> DividerCounter == DividerCounter + 2;
    endproperty
    assert property (p_divider_counter_incr_2) else $error("Divider counter should increment by 2 when Negative is high");

    // Divider counter increments by 1 when Positive is high
    property p_divider_counter_incr_1;
        @(posedge MainClock) disable iff (!MainClock) Positive |-> DividerCounter == DividerCounter + 1;
    endproperty
    assert property (p_divider_counter_incr_1) else $error("Divider counter should increment by 1 when Positive is high");

    // Divider counter does not change when both Positive and Negative are high
    property p_divider_counter_no_change;
        @(posedge MainClock) disable iff (!MainClock) Positive && Negative |-> DividerCounter == DividerCounter;
    endproperty
    assert property (p_divider_counter_no_change) else $error("Divider counter should not change when both Positive and Negative are high");

    // Divider counter resets to 0 when it reaches DividerMaxValue - 1
    property p_divider_counter_reset;
        @(posedge MainClock) disable iff (!MainClock) DividerCounter == DividerMaxValue - 1 |-> DividerCounter == 0;
    endproperty
    assert property (p_divider_counter_reset) else $error("Divider counter should reset to 0 when it reaches DividerMaxValue - 1");

    // FrequencyOut toggles when DividerCounter is 0
    property p_frequency_out_toggle;
        @(posedge MainClock) disable iff (!MainClock) DividerCounter == 0 |-> FrequencyOut == ~FrequencyOut;
    endproperty
    assert property (p_frequency_out_toggle) else $error("FrequencyOut should toggle when DividerCounter is 0");

endmodule
```