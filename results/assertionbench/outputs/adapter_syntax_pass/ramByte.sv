module byteRam_sva (
    input logic clk,
    input logic reset,
    input logic byteRamEn,
    input logic byteRamRw,
    input logic [`byteRamLen-1:0] byteRamIn,
    input logic [`byteRamAddrLen-1:0] byteRamAddr,
    input logic [`byteRamLen-1:0] byteRamOut
);

    // Reset forces the output to zero.
    check_reset_clears_output: assert property (
        @(posedge clk) reset |-> (byteRamOut == {`byteRamLen{1'b0}})
    );

    // A read cycle returns the byte at the selected address.
    check_read_returns_selected_byte: assert property (
        @(posedge clk) disable iff (reset)
        (byteRamEn && !byteRamRw) |-> (byteRamOut == $past(byteRam[byteRamAddr]))
    );

    // A write cycle updates the byte at the selected address.
    check_write_updates_selected_byte: assert property (
        @(posedge clk) disable iff (reset)
        (byteRamEn && byteRamRw) |-> (byteRam[byteRamAddr] == $past(byteRamIn))
    );

    // With enable low, the output is left unconnected.
    check_disabled_cycle_keeps_output_unconnected: assert property (
        @(posedge clk) disable iff (reset)
        !byteRamEn |-> (byteRamOut === 1'bx)
    );

    // A read cycle leaves the RAM unchanged.
    check_read_does_not_modify_ram: assert property (
        @(posedge clk) disable iff (reset)
        (byteRamEn && !byteRamRw) |-> (byteRam == $past(byteRam))
    );

    // A write cycle leaves the RAM unchanged except at the selected address.
    check_write_updates_only_selected_address: assert property (
        @(posedge clk) disable iff (reset)
        (byteRamEn && byteRamRw) |-> (
            (byteRam == $past(byteRam)) ||
            (byteRam[byteRamAddr] == $past(byteRamIn))
        )
    );

endmodule