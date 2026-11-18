module bitNegator_sva (
    input logic clk,
    input logic bitIn,
    input logic bitN,
    input logic bitOut
);

    // bitOut must match the implemented bitN ? ~bitIn : bitIn function.
    check_bitout_function: assert property (
        @(posedge clk) bitOut == (bitN ? ~bitIn : bitIn)
    );

    // When bitN is high, bitOut must be the inverse of bitIn.
    check_bitout_inverts_when_bitn_high: assert property (
        @(posedge clk) bitN |-> (bitOut == ~bitIn)
    );

    // When bitN is low, bitOut must pass through bitIn.
    check_bitout_passthrough_when_bitn_low: assert property (
        @(posedge clk) !bitN |-> (bitOut == bitIn)
    );

    // If both inputs are stable, the output must remain stable.
    check_stable_inputs_keep_output_stable: assert property (
        @(posedge clk) $stable({bitIn, bitN}) |-> $stable(bitOut)
    );

endmodule