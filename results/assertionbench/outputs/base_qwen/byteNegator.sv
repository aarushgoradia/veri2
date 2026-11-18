```systemverilog
module manual (
    input logic CLK,
    input logic RESETn,
    input logic [7:0] byteIn,
    input logic byteN,
    output logic [7:0] byteOut
);
    ///// Byte negator logic /////
    // byteOut should be the negation of byteIn when byteN is HIGH.
    negation: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteN == 1'b1) |-> (byteOut == ~byteIn)
    );
    // byteOut should be the same as byteIn when byteN is LOW.
    identity: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteN == 1'b0) |-> (byteOut == byteIn)
    );
    // byteOut should not change when byteN is LOW.
    stable: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteN == 1'b0) |-> byteOut[*1] == byteOut
    );
    // byteOut should not change when byteN is HIGH.
    stable_negated: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteN == 1'b1) |-> byteOut[*1] == byteOut
    );
    // byteOut should be within the valid range [0, 255].
    valid_range: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteOut inside {[0:255]})
    );
    // byteOut should not be all zeros when byteN is HIGH.
    non_zero: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteN == 1'b1) |-> byteOut != 8'b0
    );
    // byteOut should not be all ones when byteN is HIGH.
    non_all_ones: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteN == 1'b1) |-> byteOut != 8'b11111111
    );
    // byteOut should not be all zeros when byteN is LOW.
    non_zero_identity: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteN == 1'b0) |-> byteOut != 8'b0
    );
    // byteOut should not be all ones when byteN is LOW.
    non_all_ones_identity: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteN == 1'b0) |-> byteOut != 8'b11111111
    );
    // byteOut should not change when byteN is LOW and byteIn is unchanged.
    stable_identity: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteN == 1'b0) |-> byteIn[*1] == byteIn |-> byteOut[*1] == byteOut
    );
    // byteOut should not change when byteN is HIGH and byteIn is unchanged.
    stable_negated_identity: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteN == 1'b1) |-> byteIn[*1] == byteIn |-> byteOut[*1] == byteOut
    );
endmodule
```