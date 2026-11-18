module bitNegator_sva (
    input logic clk,
    input logic bitIn,
    input logic bitN,
    input logic bitOut
);

    // bitOut must match the RTL's muxed inversion function.
    check_bitout_matches_rtl_function: assert property (
        @(posedge clk) bitOut == (bitN ? ~bitIn : bitIn)
    );

    // When bitN is high, bitOut must be the inversion of bitIn.
    check_bitout_inverts_when_bitn_high: assert property (
        @(posedge clk) bitN |-> (bitOut == ~bitIn)
    );

    // When bitN is low, bitOut must pass bitIn through.
    check_bitout_passthrough_when_bitn_low: assert property (
        @(posedge clk) !bitN |-> (bitOut == bitIn)
    );

endmodule