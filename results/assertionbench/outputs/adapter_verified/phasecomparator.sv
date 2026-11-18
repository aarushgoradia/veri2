module phasecomparator_sva (
    input logic InputSignal,
    input logic OutputSignal,
    input logic MainClock,
    input logic Lead,
    input logic Lag
);

// Lead is high exactly when the previous cycle had a rising input edge and output was high.
    check_lead_definition: assert property (
        @(posedge MainClock) 1'b1 |=> (Lead == ($past(InputSignalEdge) && $past(OutputSignal)))
    );

// Lag is high exactly when the previous cycle had a rising input edge and output was low.
    check_lag_definition: assert property (
        @(posedge MainClock) 1'b1 |=> (Lag == ($past(InputSignalEdge) && !$past(OutputSignal)))
    );

// A rising input edge with output high sets Lead high on the next cycle.
    check_lead_on_rise_with_output_high: assert property (
        @(posedge MainClock) (InputSignalEdge && OutputSignal) |=> Lead
    );

// A rising input edge with output low sets Lag high on the next cycle.
    check_lag_on_rise_with_output_low: assert property (
        @(posedge MainClock) (InputSignalEdge && !OutputSignal) |=> Lag
    );

// If the previous cycle had a rising input edge, exactly one of Lead or Lag is high.
    check_onehot_on_input_rise: assert property (
        @(posedge MainClock) 1'b1 |=> (($past(InputSignalEdge) && (Lead ^ Lag)))
    );

// If the previous cycle had no rising input edge, both Lead and Lag are low.
    check_idle_when_no_rise: assert property (
        @(posedge MainClock) !$past(InputSignalEdge) |=> (!Lead && !Lag)
    );

// If both Lead and Lag are high, the previous cycle must have had a rising input edge.
    check_one_rise_when_both_high: assert property (
        @(posedge MainClock) (Lead && Lag) |=> $past(InputSignalEdge)
    );

// If both Lead and Lag are high, the previous output must have been high.
    check_output_high_when_both_high: assert property (
        @(posedge MainClock) (Lead && Lag) |=> $past(OutputSignal)
    );

endmodule
