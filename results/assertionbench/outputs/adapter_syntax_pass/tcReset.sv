module tcReset_sva (
    input logic tcResetEn,
    input logic resetIn,
    input logic [3:0] tcAddr,
    input logic [7:0] resetOut
);

    // resetOut must be zero whenever the reset enable is low.
    check_reset_out_low_when_disabled: assert property (
        @(posedge tcResetEn) !tcResetEn |-> (resetOut == 8'h00)
    );

    // A high resetIn must be captured into the selected reset bit on the next cycle.
    check_capture_high_reset: assert property (
        @(posedge tcResetEn) tcResetEn && resetIn |=> (resetOut[tcAddr] == 1'b1)
    );

    // A low resetIn must be captured into the selected reset bit on the next cycle.
    check_capture_low_reset: assert property (
        @(posedge tcResetEn) tcResetEn && !resetIn |=> (resetOut[tcAddr] == 1'b0)
    );

    // A reset bit can only change if the reset enable is high on the prior cycle.
    check_reset_bit_changes_only_when_enabled: assert property (
        @(posedge tcResetEn) $changed(resetOut[tcAddr]) |-> $past(tcResetEn)
    );

endmodule