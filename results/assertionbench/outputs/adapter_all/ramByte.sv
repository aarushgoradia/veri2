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
        @(posedge clk) reset |-> (byteRamOut == '0)
    );

    // With enable low, the output is high-impedance.
    check_enable_low_drives_z: assert property (
        @(posedge clk) disable iff (reset)
        !byteRamEn |-> (byteRamOut == 'z)
    );

    // A read returns the byte at the selected address.
    check_read_returns_selected_byte: assert property (
        @(posedge clk) disable iff (reset)
        byteRamEn && byteRamRw |-> (byteRamOut == $past(byteRam[byteRamAddr]))
    );

    // A write updates the byte at the selected address.
    check_write_updates_selected_byte: assert property (
        @(posedge clk) disable iff (reset)
        byteRamEn && !byteRamRw |-> (byteRam[byteRamAddr] == $past(byteRamIn))
    );

    // A write does not change the output while enable stays high.
    check_write_holds_output_when_enabled: assert property (
        @(posedge clk) disable iff (reset)
        byteRamEn && !byteRamRw |-> (byteRamOut == $past(byteRamOut))
    );

    // A read does not change the output while enable stays high.
    check_read_holds_output_when_enabled: assert property (
        @(posedge clk) disable iff (reset)
        byteRamEn && byteRamRw |-> (byteRamOut == $past(byteRamOut))
    );

    // A write followed by a read returns the written value.
    check_write_then_read_returns_written_value: assert property (
        @(posedge clk) disable iff (reset)
        byteRamEn && !byteRamRw ##1 (byteRamEn && byteRamRw)
        |-> (byteRamOut == $past(byteRamIn, 2))
    );

endmodule