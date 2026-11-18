```systemverilog
module randomwalkfilter_sva (
    input logic MainClock,
    input logic Lead,
    input logic Lag,
    output logic Positive,
    output logic Negative
);
    // Sequential logic for FilterCounter
    property p_filter_counter;
        @(posedge MainClock) disable iff (!MainClock) 
        (FilterCounter == FilterMaxValue) |-> (FilterCounter == 0) ||
        (FilterCounter == FilterMinValue) |-> (FilterCounter == 0) ||
        (Lead) |-> (FilterCounter == FilterCounter + 1) ||
        (Lag) |-> (FilterCounter == FilterCounter - 1);
    endproperty
    assert property (p_filter_counter) else $error("FilterCounter logic error");

    // Sequential logic for Positive and Negative
    property p_positive_negative;
        @(posedge MainClock) disable iff (!MainClock) 
        (FilterCounter == FilterMaxValue) |-> Positive == 1'b1 &&
        (FilterCounter == FilterMinValue) |-> Negative == 1'b1;
    endproperty
    assert property (p_positive_negative) else $error("Positive/Negative logic error");

    // Sequential logic for ResetterCounter
    property p_resetter_counter;
        @(posedge MainClock) disable iff (!MainClock) 
        (Up) |-> (ResetterCounter == ResetterCounter + 1) ||
        (Down) |-> (ResetterCounter == ResetterCounter - 1) ||
        (ResetterCounter > ResetterCounterMaxValue) & (ResetterCounter < ResetterCounterMinValue) |-> ResetterCounter == 0;
    endproperty
    assert property (p_resetter_counter) else $error("ResetterCounter logic error");

    // Sequential logic for N_FilterCounter
    property p_n_filter_counter;
        @(posedge MainClock) disable iff (!MainClock) 
        (N_FilterCounter == N_FilterMaxValue) |-> (N_FilterCounter == ResetterValue) ||
        (N_FilterCounter == N_FilterMinValue) |-> (N_FilterCounter == ResetterValue) ||
        (Lead) |-> (N_FilterCounter == N_FilterCounter + 1) ||
        (Lag) |-> (N_FilterCounter == N_FilterCounter - 1);
    endproperty
    assert property (p_n_filter_counter) else $error("N_FilterCounter logic error");

    // Sequential logic for Positive and Negative in N_FilterCounter
    property p_n_positive_negative;
        @(posedge MainClock) disable iff (!MainClock) 
        (N_FilterCounter == N_FilterMaxValue) |-> Positive == 1'b1 &&
        (N_FilterCounter == N_FilterMinValue) |-> Negative == 1'b1;
    endproperty
    assert property (p_n_positive_negative) else $error("N_Positive/Negative logic error");
endmodule
```