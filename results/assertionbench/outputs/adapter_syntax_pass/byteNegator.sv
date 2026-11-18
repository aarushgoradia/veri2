module byteNegator_sva (
    input logic clk,
    input logic [7:0] byteIn,
    input logic byteN,
    input logic [7:0] byteOut
);

    // byteOut must match the implemented byteN mux.
    check_byte_out_matches_mux: assert property (
        @(posedge clk) byteOut == (byteN ? ~byteIn : byteIn)
    );

    // When byteN is high, byteOut must be the bitwise inverse of byteIn.
    check_byte_out_inverted_when_byteN_high: assert property (
        @(posedge clk) byteN |-> (byteOut == ~byteIn)
    );

    // When byteN is low, byteOut must pass byteIn through.
    check_byte_out_passthrough_when_byteN_low: assert property (
        @(posedge clk) !byteN |-> (byteOut == byteIn)
    );

    // A change on byteIn must update byteOut on the next cycle.
    check_byte_in_change_updates_byte_out: assert property (
        @(posedge clk) $changed(byteIn) |=> (byteOut == (byteN ? ~byteIn : byteIn))
    );

    // A change on byteN must update byteOut on the next cycle.
    check_byteN_change_updates_byte_out: assert property (
        @(posedge clk) $changed(byteN) |=> (byteOut == (byteN ? ~byteIn : byteIn))
    );

endmodule