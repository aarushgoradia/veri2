module bitRam_sva (
    input logic clk,
    input logic reset,
    input logic bitRamEn,
    input logic bitRamRw,
    input logic bitRamIn,
    input logic [(`bitRamAddrLen-1):0] bitRamAddr,
    input logic bitRamOut
);

    // Reset forces the output low.
    check_reset_forces_out_low: assert property (
        @(posedge clk) reset |-> (bitRamOut == 1'b0)
    );

    // When disabled, the output is high-impedance.
    check_disabled_drives_highz: assert property (
        @(posedge clk) disable iff (reset) (!bitRamEn) |-> (bitRamOut == 1'bz)
    );

    // A read returns the bit at the selected address.
    check_read_returns_selected_bit: assert property (
        @(posedge clk) disable iff (reset)
        (bitRamEn && bitRamRw) |-> (bitRamOut == bitRam[bitRamAddr])
    );

    // A write updates the bit at the selected address.
    check_write_updates_selected_bit: assert property (
        @(posedge clk) disable iff (reset)
        (bitRamEn && !bitRamRw) |=> (bitRam[bitRamAddr] == $past(bitRamIn))
    );

    // A write does not change the output bus.
    check_write_does_not_change_out: assert property (
        @(posedge clk) disable iff (reset)
        (bitRamEn && !bitRamRw) |=> (bitRamOut == $past(bitRamOut))
    );

endmodule