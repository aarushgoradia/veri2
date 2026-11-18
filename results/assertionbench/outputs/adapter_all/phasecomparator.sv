module phasecomparator_sva (
    input logic InputSignal,
    input logic OutputSignal,
    input logic MainClock,
    input logic Lead,
    input logic Lag
);

    // Lead is asserted on the next clock when the prior input edge detected OutputSignal was high.
    check_lead_asserts_on_prior_output_high: assert property (
        @(posedge MainClock)
        (!$initstate && $past(InputSignalEdgeDet == 2'b01) && $past(OutputSignal == 1'b1)) |-> Lead
    );

    // Lead is asserted on the next clock when the prior input edge detected OutputSignal was low.
    check_lead_asserts_on_prior_output_low: assert property (
        @(posedge MainClock)
        (!$initstate && $past(InputSignalEdgeDet == 2'b01) && $past(OutputSignal == 1'b0)) |-> Lead
    );

    // Lead is high only when the prior input edge detected OutputSignal was high.
    check_lead_requires_prior_output_high: assert property (
        @(posedge MainClock)
        (!$initstate && Lead) |-> ($past(InputSignalEdgeDet == 2'b01) && $past(OutputSignal == 1'b1))
    );

    // Lead is high only when the prior input edge detected OutputSignal was low.
    check_lead_requires_prior_output_low: assert property (
        @(posedge MainClock)
        (!$initstate && Lead) |-> ($past(InputSignalEdgeDet == 2'b01) && $past(OutputSignal == 1'b0))
    );

    // Lag is asserted on the next clock when the prior input edge detected OutputSignal was low.
    check_lag_asserts_on_prior_output_low: assert property (
        @(posedge MainClock)
        (!$initstate && $past(InputSignalEdgeDet == 2'b01) && $past(OutputSignal == 1'b0)) |-> Lag
    );

    // Lag is high only when the prior input edge detected OutputSignal was low.
    check_lag_requires_prior_output_low: assert property (
        @(posedge MainClock)
        (!$initstate && Lag) |-> ($past(InputSignalEdgeDet == 2'b01) && $past(OutputSignal == 1'b0))
    );

    // Lead and Lag are never asserted together.
    check_lead_lag_mutex: assert property (
        @(posedge MainClock)
        !(Lead && Lag)
    );

    // If the prior input edge detected OutputSignal was high, both outputs are low.
    check_outputs_low_on_prior_output_high: assert property (
        @(posedge MainClock)
        (!$initstate && $past(InputSignalEdgeDet == 2'b01) && $past(OutputSignal == 1'b1)) |-> (!Lead && !Lag)
    );

    // If the prior input edge detected OutputSignal was low, exactly one output is high.
    check_outputs_onehot_on_prior_output_low: assert property (
        @(posedge MainClock)
        (!$initstate && $past(InputSignalEdgeDet == 2'b01) && $past(OutputSignal == 1'b0)) |-> (Lead ^ Lag)
    );

endmodule