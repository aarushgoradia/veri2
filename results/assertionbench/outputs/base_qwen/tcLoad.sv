```systemverilog
module manual (
    input logic CLK,
    input logic RESETn,
    input logic [`tcAddrLen-1:0] tcAddr,
    input logic [`tcNumbers-1:0] dnIn,
    input logic [`tcNumbers-1:0] ttIn,
    input logic [`tcNumbers-1:0] cuIn,
    input logic [`tcNumbers-1:0] cdIn,
    output logic [7:0] tcLoadOut
);
    ///// Timer-Counter Load /////
    // tcLoadOut can only transition from its current value when dnIn, ttIn, cuIn, or cdIn changes.
    load_transition: assert property (
        @(posedge CLK) disable iff (!RESETn) $changed(tcLoadOut) |-> $changed(dnIn) || $changed(ttIn) || $changed(cuIn) || $changed(cdIn)
    );
    // tcLoadOut must be a 4-bit value followed by the selected bits from dnIn, ttIn, cuIn, and cdIn.
    load_value: assert property (
        @(posedge CLK) disable iff (!RESETn) tcLoadOut[7:4] == 4'b0 && tcLoadOut[3] == dnIn[tcAddr] && tcLoadOut[2] == ttIn[tcAddr] && tcLoadOut[1] == cuIn[tcAddr] && tcLoadOut[0] == cdIn[tcAddr]
    );
    ///// Device reset /////
    // At reset assertion, a device must drive tcLoadOut LOW.
    reset: assert property (
        @(posedge CLK) !RESETn |-> tcLoadOut == 8'b0
    );
endmodule
```