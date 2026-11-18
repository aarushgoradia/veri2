module dpll_sva (
    input logic SignalIn,
    input logic SignalOut,
    input logic MainClock,
    input logic Positive,
    input logic Negative,
    input logic Lead,
    input logic Lag
);

    ///// Phase comparator behavior /////
    // Lead is asserted only on input rising edges where SignalIn is HIGH.
    check_lead_definition: assert property (
        @(posedge MainClock) Lead |-> (SignalIn == 1'b1)
    );
    // Lag is asserted only on input rising edges where SignalIn is LOW.
    check_lag_definition: assert property (
        @(posedge MainClock) Lag |-> (SignalIn == 1'b0)
    );
    // Lead and Lag are never asserted together.
    check_lead_lag_mutex: assert property (
        @(posedge MainClock) !(Lead && Lag)
    );
    // Lead and Lag are complementary when either is asserted.
    check_lead_lag_complementary: assert property (
        @(posedge MainClock) (Lead || Lag) |-> (Lead == !Lag)
    );
    // If neither Lead nor Lag is asserted, SignalIn is stable.
    check_no_lead_lag_implies_stable_input: assert property (
        @(posedge MainClock) !(Lead || Lag) |-> $stable(SignalIn)
    );

    ///// Frequency divider behavior /////
    // Positive and Negative are never asserted together.
    check_pos_neg_mutex: assert property (
        @(posedge MainClock) !(Positive && Negative)
    );
    // If neither Positive nor Negative is asserted, the counter increments by 1.
    check_no_pos_neg_increments: assert property (
        @(posedge MainClock) !(Positive || Negative) |-> ##1 $past(DividerCounter) == $past(DividerCounter) + 1
    );
    // If only Positive is asserted, the counter holds.
    check_pos_holds: assert property (
        @(posedge MainClock) Positive |-> ##1 $past(DividerCounter) == $past(DividerCounter)
    );
    // If only Negative is asserted, the counter increments by 2.
    check_neg_increments_by2: assert property (
        @(posedge MainClock) Negative |-> ##1 $past(DividerCounter) == $past(DividerCounter) + 2
    );
    // When the counter reaches DividerMaxValue-1, it wraps to 0.
    check_wrap_on_max_minus1: assert property (
        @(posedge MainClock) ($past(DividerCounter) == DividerMaxValue - 1) |-> ##1 $past(DividerCounter) == 0
    );
    // When the counter is 0, SignalOut toggles.
    check_toggle_on_zero: assert property (
        @(posedge MainClock) ($past(DividerCounter) == 0) |-> ##1 $past(SignalOut) == ~$past(SignalOut)
    );
    // When the counter is not 0, SignalOut holds.
    check_hold_when_not_zero: assert property (
        @(posedge MainClock) ($past(DividerCounter) != 0) |-> ##1 $past(SignalOut) == $past(SignalOut)
    );

    ///// Combinational feedthroughs /////
    // Lead feeds directly into Positive.
    check_lead_feeds_positive: assert property (
        @(posedge MainClock) Lead |-> Positive
    );
    // Lag feeds directly into Negative.
    check_lag_feeds_negative: assert property (
        @(posedge MainClock) Lag |-> Negative
    );

endmodule