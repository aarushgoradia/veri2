```systemverilog
module manual (
    input logic CLK,
    input logic RESETn,
    input logic bitIn,
    input logic bitN,
    output logic bitOut
);
    ///// Bit negator logic /////
    // bitOut should be the negation of bitIn when bitN is HIGH.
    bit_negation: assert property (
        @(posedge CLK) disable iff (!RESETn) bitN |-> bitOut == ~bitIn
    );
    // bitOut should be the same as bitIn when bitN is LOW.
    bit_pass_through: assert property (
        @(posedge CLK) disable iff (!RESETn) !bitN |-> bitOut == bitIn
    );
endmodule
```