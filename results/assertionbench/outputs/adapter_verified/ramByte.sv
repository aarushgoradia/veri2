module byteRam_sva (
    input logic clk,
    input logic reset,
    input logic byteRamEn,
    input logic byteRamRw,
    input logic [`byteRamLen-1:0] byteRamIn,
    input logic [`byteRamAddrLen-1:0] byteRamAddr,
    input logic [`byteRamLen-1:0] byteRamOut
);

// Reset drives byteRamOut to zero.
    check_reset_clears_out: assert property (
        @(posedge clk) reset |-> (byteRamOut == 8'h00)
    );

// With enable low, byteRamOut is high-impedance.
    check_disable_high_impedance: assert property (
        @(posedge clk) disable iff (reset)
        !byteRamEn |-> (byteRamOut == 8'hZZ)
    );

// With enable high and read asserted, byteRamOut reflects the selected byte.
    check_read_returns_selected_byte: assert property (
        @(posedge clk) disable iff (reset)
        (byteRamEn && byteRamRw) |-> (byteRamOut == byteRam[byteRamAddr])
    );

// With enable high and write asserted, byteRamOut remains unchanged.
    check_write_holds_output: assert property (
        @(posedge clk) disable iff (reset)
        (byteRamEn && !byteRamRw) |-> (byteRamOut == $past(byteRamOut))
    );

// With enable high and write asserted, the selected byte is updated.
    check_write_updates_selected_byte: assert property (
        @(posedge clk) disable iff (reset)
        (byteRamEn && !byteRamRw) |-> (byteRam[byteRamAddr] == $past(byteRamIn))
    );

endmodule
