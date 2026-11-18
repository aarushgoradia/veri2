module bit_negator_sva (
    input logic clk,
    input logic bitIn,
    input logic bitN,
    input logic bitOut
);

// bitOut must match the RTL's conditional inversion.
    check_functional_equivalence: assert property (
        @(posedge clk) bitOut == (bitN ? ~bitIn : bitIn)
    );

// When bitN is high, bitOut must be the inversion of bitIn.
    check_invert_when_bitN_high: assert property (
        @(posedge clk) bitN |-> (bitOut == ~bitIn)
    );

// When bitN is low, bitOut must pass bitIn through.
    check_passthrough_when_bitN_low: assert property (
        @(posedge clk) !bitN |-> (bitOut == bitIn)
    );

// A high bitIn must produce a low bitOut when bitN is high.
    check_high_input_maps_to_low_output: assert property (
        @(posedge clk) (bitN && bitIn) |-> (bitOut == 1'b0)
    );

// A low bitIn must produce a high bitOut when bitN is high.
    check_low_input_maps_to_high_output: assert property (
        @(posedge clk) (bitN && !bitIn) |-> (bitOut == 1'b1)
    );

// A high bitIn must pass through when bitN is low.
    check_high_input_passthrough_when_bitN_low: assert property (
        @(posedge clk) (!bitN && bitIn) |-> (bitOut == 1'b1)
    );

// A low bitIn must pass through when bitN is low.
    check_low_input_passthrough_when_bitN_low: assert property (
        @(posedge clk) (!bitN && !bitIn) |-> (bitOut == 1'b0)
    );

endmodule
