```systemverilog
module manual (
    input logic CLK,
    input logic RESETn,
    input logic tcResetEn,
    input logic [`tcAddrLen-1:0] tcAddr,
    input logic resetIn,
    output logic [`tcNumbers-1:0] resetOut
);
    ///// Timer-Counter reset /////
    // resetOut must be driven by resetIn when tcResetEn is HIGH.
    tc_reset: assert property (
        @(posedge CLK) disable iff (!RESETn) (tcResetEn == 1'b1) |-> (resetOut[tcAddr] == resetIn)
    );
endmodule
```