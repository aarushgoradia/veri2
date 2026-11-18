module byteNegator_sva (
    input logic [7:0] byteIn,
    input logic       byteN,
    input logic [7:0] byteOut
);

    // byteOut must match the implemented byteN mux behavior.
    check_byte_out_matches_mux: assert property (
        @($global_clock) byteOut == (byteN ? ~byteIn : byteIn)
    );

    // When byteN is low, byteOut must pass through byteIn.
    check_passthrough_when_byteN_low: assert property (
        @($global_clock) !byteN |-> (byteOut == byteIn)
    );

    // When byteN is high, byteOut must be the bitwise inverse of byteIn.
    check_invert_when_byteN_high: assert property (
        @($global_clock) byteN |-> (byteOut == ~byteIn)
    );

    // If both inputs are stable, the output must remain stable.
    check_stable_when_inputs_stable: assert property (
        @($global_clock) $stable({byteIn, byteN}) |-> $stable(byteOut)
    );

    // A change on byteIn must change byteOut when byteN is low.
    check_byte_in_change_affects_output_when_byteN_low: assert property (
        @($global_clock) (byteN && $changed(byteIn)) |-> $changed(byteOut)
    );

    // A change on byteIn must not change byteOut when byteN is high.
    check_byte_in_change_ignored_when_byteN_high: assert property (
        @($global_clock) (byteN && $changed(byteIn)) |-> !$changed(byteOut)
    );

    // A change on byteN must change byteOut when byteN is high.
    check_byteN_change_affects_output_when_byteN_high: assert property (
        @($global_clock) (!byteN && $changed(byteN)) |-> $changed(byteOut)
    );

    // A change on byteN must not change byteOut when byteN is low.
    check_byteN_change_ignored_when_byteN_low: assert property (
        @($global_clock) (!byteN && $changed(byteN)) |-> !$changed(byteOut)
    );

endmodule