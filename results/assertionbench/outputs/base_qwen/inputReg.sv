```systemverilog
module inputRegister_sva (
    input logic CLK,
    input logic RESETn,
    input [`inputNumber-1:0] inputs,
    input [`inputAddrLen-1:0] inputReadAddr,
    output logic inputReadOut
);
    // Ensure that inputReadOut is always assigned a value
    always_ff @(posedge CLK) disable iff (!RESETn) begin
        inputReadOut <= inputs[inputReadAddr];
    end

    // Ensure that inputReadAddr is within valid range
    property p_inputReadAddr_valid;
        @(posedge CLK) disable iff (!RESETn) inputReadAddr inside {[0:`inputAddrLen-1]};
    endproperty
    assert property (p_inputReadAddr_valid) else $error("inputReadAddr out of valid range");

    // Ensure that inputReadOut is assigned a value on every clock cycle
    property p_inputReadOut_assigned;
        @(posedge CLK) disable iff (!RESETn) inputReadOut !== 'x;
    endproperty
    assert property (p_inputReadOut_assigned) else $error("inputReadOut not assigned a value");

endmodule
```