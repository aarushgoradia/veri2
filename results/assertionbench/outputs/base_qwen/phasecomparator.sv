```systemverilog
module phasecomparator_sva (
    input logic MainClock,
    input logic InputSignal,
    input logic OutputSignal,
    output logic Lead,
    output logic Lag
);
    // Detector of the rising edge of InputSignal
    reg [1:0] InputSignalEdgeDet;
    always @(posedge MainClock)
        InputSignalEdgeDet <= { InputSignalEdgeDet[0], InputSignal };

    // Simple detector of the Input signal rising edge
    wire InputSignalEdge = (InputSignalEdgeDet == 2'b01);

    // Lead signal generation
    reg Lead, Lag;
    always @(posedge MainClock)
    begin                         
        Lag  <= ((InputSignalEdge == 1'b1)  && (OutputSignal == 1'b0));
        Lead <= ((InputSignalEdge == 1'b1)  && (OutputSignal == 1'b1));
    end

    // Property to check the behavior of Lead signal
    lead_signal: assert property (
        @(posedge MainClock) disable iff (!MainClock) (InputSignalEdge == 1'b1) && (OutputSignal == 1'b1) |-> Lead == 1'b1
    ) else $error("Lead signal should be set to 1 when InputSignal rises and OutputSignal is 1");

    // Property to check the behavior of Lag signal
    lag_signal: assert property (
        @(posedge MainClock) disable iff (!MainClock) (InputSignalEdge == 1'b1) && (OutputSignal == 1'b0) |-> Lag == 1'b1
    ) else $error("Lag signal should be set to 1 when InputSignal rises and OutputSignal is 0");

    // Property to check the behavior of Lead signal when InputSignal does not rise
    no_lead_signal: assert property (
        @(posedge MainClock) disable iff (!MainClock) (InputSignalEdge == 1'b0) |-> Lead == 1'b0
    ) else $error("Lead signal should be 0 when InputSignal does not rise");

    // Property to check the behavior of Lag signal when InputSignal does not rise
    no_lag_signal: assert property (
        @(posedge MainClock) disable iff (!MainClock) (InputSignalEdge == 1'b0) |-> Lag == 1'b0
    ) else $error("Lag signal should be 0 when InputSignal does not rise");

    // Property to check the behavior of Lead signal when OutputSignal is 0
    lead_when_output_zero: assert property (
        @(posedge MainClock) disable iff (!MainClock) (InputSignalEdge == 1'b1) && (OutputSignal == 1'b0) |-> Lead == 1'b1
    ) else $error("Lead signal should be 1 when InputSignal rises and OutputSignal is 0");

    // Property to check the behavior of Lag signal when OutputSignal is 1
    lag_when_output_one: assert property (
        @(posedge MainClock) disable iff (!MainClock) (InputSignalEdge == 1'b1) && (OutputSignal == 1'b1) |-> Lag == 1'b1
    ) else $error("Lag signal should be 1 when InputSignal rises and OutputSignal is 1");

    // Property to check the behavior of Lead signal when InputSignal rises and OutputSignal is 0
    lead_when_output_zero_rising: assert property (
        @(posedge MainClock) disable iff (!MainClock) (InputSignalEdge == 1'b1) && (OutputSignal == 1'b0) |-> Lead == 1'b1
    ) else $error("Lead signal should be 1 when InputSignal rises and OutputSignal is 0");

    // Property to check the behavior of Lag signal when InputSignal rises and OutputSignal is 1
    lag_when_output_one_rising: assert property (
        @(posedge MainClock) disable iff (!MainClock) (InputSignalEdge == 1'b1) && (OutputSignal == 1'b1) |-> Lag == 1'b1
    ) else $error("Lag signal should be 1 when InputSignal rises and OutputSignal is 1");

    // Property to check the behavior of Lead signal when InputSignal does not rise and OutputSignal is 0
    no_lead_when_output_zero_not_rising: assert property (
        @(posedge MainClock) disable iff (!MainClock) (InputSignalEdge == 1'b0) && (OutputSignal == 1'b0) |-> Lead == 1'b0
    ) else $error("Lead signal should be 0 when InputSignal does not rise and OutputSignal is 0");

    // Property to check the behavior of Lag signal when InputSignal does not rise and OutputSignal is 1
    no_lag_when_output_one_not_rising: assert property (
        @(posedge MainClock) disable iff (!MainClock) (InputSignalEdge == 1'b0) && (OutputSignal == 1'b1) |-> Lag == 1'b0
    ) else $error("Lag signal should be 0 when InputSignal does not rise and OutputSignal is 1");
endmodule
```