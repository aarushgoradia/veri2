module phasecomparator_sva (
    input logic InputSignal,
    input logic OutputSignal,
    input logic MainClock,
    input logic Lead,
    input logic Lag,
    input logic [1:0] InputSignalEdgeDet,
    input logic InputSignalEdge
);

    // InputSignalEdgeDet shifts in the previous InputSignal value.
    check_input_edge_det_shift: assert property (
        @(posedge MainClock)
        1'b1 |=> (InputSignalEdgeDet == {$past(InputSignalEdgeDet[0]), $past(InputSignal)})
    );

    // InputSignalEdge is high exactly when the detector is 01.
    check_input_edge_definition: assert property (
        @(posedge MainClock)
        (InputSignalEdge == (InputSignalEdgeDet == 2'b01))
    );

    // Lag is asserted only when the edge detector is 01 and OutputSignal is low.
    check_lag_definition: assert property (
        @(posedge MainClock)
        (Lag == ((InputSignalEdge == 1'b1) && (OutputSignal == 1'b0)))
    );

    // Lead is asserted only when the edge detector is 01 and OutputSignal is high.
    check_lead_definition: assert property (
        @(posedge MainClock)
        (Lead == ((InputSignalEdge == 1'b1) && (OutputSignal == 1'b1)))
    );

    // Lag and Lead are never asserted together.
    check_lead_lag_mutex: assert property (
        @(posedge MainClock)
        !(Lead && Lag)
    );

    // If the edge detector is 01, exactly one of Lead or Lag is asserted.
    check_edge_detector_sets_one_output: assert property (
        @(posedge MainClock)
        (InputSignalEdge == 1'b1) |-> (Lead ^ Lag)
    );

    // If the edge detector is not 01, both outputs are low.
    check_no_output_when_no_edge: assert property (
        @(posedge MainClock)
        (InputSignalEdge != 1'b1) |-> (!Lead && !Lag)
    );

    // A low OutputSignal can only assert Lag when the edge detector is 01.
    check_lag_requires_output_low: assert property (
        @(posedge MainClock)
        (Lag && (OutputSignal == 1'b1)) |-> (InputSignalEdge == 1'b1)
    );

    // A high OutputSignal can only assert Lead when the edge detector is 01.
    check_lead_requires_output_high: assert property (
        @(posedge MainClock)
        (Lead && (OutputSignal == 1'b0)) |-> (InputSignalEdge == 1'b1)
    );

endmodule