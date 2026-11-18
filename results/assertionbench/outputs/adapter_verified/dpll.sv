module dpll_sva (
    input logic SignalIn,
    input logic SignalOut,
    input logic MainClock,
    input logic Positive,
    input logic Negative,
    input logic Lead,
    input logic Lag
);

// Lead and Lag are never asserted together.
    check_lead_lag_mutex: assert property (
        @(posedge MainClock) !(Lead && Lag)
    );

// Positive and Negative are never asserted together.
    check_positive_negative_mutex: assert property (
        @(posedge MainClock) !(Positive && Negative)
    );

// Lead implies Positive.
    check_lead_implies_positive: assert property (
        @(posedge MainClock) Lead |-> Positive
    );

// Lag implies Negative.
    check_lag_implies_negative: assert property (
        @(posedge MainClock) Lag |-> Negative
    );

// Positive implies no Lag.
    check_positive_implies_no_lag: assert property (
        @(posedge MainClock) Positive |-> !Lag
    );

// Negative implies no Lead.
    check_negative_implies_no_lead: assert property (
        @(posedge MainClock) Negative |-> !Lead
    );

// Lead and Positive are asserted together exactly when Lag and Negative are.
    check_lead_positive_equiv_lag_negative: assert property (
        @(posedge MainClock) (Lead && Positive) == (Lag && Negative)
    );

// When neither Lead nor Lag is asserted, both Positive and Negative are low.
    check_idle_outputs_low: assert property (
        @(posedge MainClock) !(Lead || Lag) |-> (!Positive && !Negative)
    );

// When both Lead and Lag are asserted, both Positive and Negative are high.
    check_idle_outputs_high: assert property (
        @(posedge MainClock) (Lead && Lag) |-> (Positive && Negative)
    );

// When both Positive and Negative are asserted, both Lead and Lag are high.
    check_idle_inputs_high: assert property (
        @(posedge MainClock) (Positive && Negative) |-> (Lead && Lag)
    );

// When both Positive and Negative are low, both Lead and Lag are low.
    check_idle_inputs_low: assert property (
        @(posedge MainClock) (!Positive && !Negative) |-> (!Lead && !Lag)
    );

endmodule
