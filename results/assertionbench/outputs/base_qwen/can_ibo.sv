```systemverilog
module can_ibo_sva (
    input logic CLK,
    input logic RESETn,
    input logic [7:0] di,
    output logic [7:0] do_can
);
    // The logic is purely combinational, so we will use @(posedge CLK) for assertions.

    // The output do_can should be the bit-reversed version of the input di.
    bit_reversal: assert property (
        @(posedge CLK) disable iff (!RESETn) (do_can == {di[7:0][::-1]})
    );
endmodule
```