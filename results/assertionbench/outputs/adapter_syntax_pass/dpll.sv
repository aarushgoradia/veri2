module dpll_sva (
    input logic SignalIn,
    input logic SignalOut,
    input logic MainClock,
    input logic Positive,
    input logic Negative,
    input logic Lead,
    input logic Lag
);

    // Lead is asserted exactly when SignalIn is high at a MainClock edge.
    check_lead_matches_input: assert property (
        @(posedge MainClock) Lead == SignalIn
    );

    // Lag is asserted exactly when SignalIn is low at a MainClock edge.
    check_lag_matches_input: assert property (
        @(posedge MainClock) Lag == !SignalIn
    );

    // Positive is asserted exactly when SignalOut is high at a MainClock edge.
    check_positive_matches_output: assert property (
        @(posedge MainClock) Positive == SignalOut
    );

    // Negative is asserted exactly when SignalOut is low at a MainClock edge.
    check_negative_matches_output: assert property (
        @(posedge MainClock) Negative == !SignalOut
    );

    // SignalOut is the XOR of Lead and Lag.
    check_output_is_lead_xor_lag: assert property (
        @(posedge MainClock) SignalOut == (Lead ^ Lag)
    );

    // Positive and Negative are never asserted together.
    check_positive_negative_mutex: assert property (
        @(posedge MainClock) !(Positive && Negative)
    );

    // If both Lead and Lag are high, Positive must be high.
    check_lead_and_lag_implies_positive: assert property (
        @(posedge MainClock) (Lead && Lag) |-> Positive
    );

    // If both Lead and Lag are low, Negative must be high.
    check_no_lead_no_lag_implies_negative: assert property (
        @(posedge MainClock) (!Lead && !Lag) |-> Negative
    );

    // If Lead is high and Negative is low, Positive must be high.
    check_lead_and_not_negative_implies_positive: assert property (
        @(posedge MainClock) (Lead && !Negative) |-> Positive
    );

    // If Lag is high and Positive is low, Negative must be high.
    check_lag_and_not_positive_implies_negative: assert property (
        @(posedge MainClock) (Lag && !Positive) |-> Negative
    );

endmodule