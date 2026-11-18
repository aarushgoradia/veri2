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
    check_reset_forces_output_low: assert property (
        @(posedge clk) reset |-> (bitRamOut == 1'b0)
    );

    // When disabled, the output is high-impedance.
    check_disabled_drives_highz: assert property (
        @(posedge clk) disable iff (reset) (!bitRamEn) |-> (bitRamOut == 1'bz)
    );

    // A read returns the previously written value at that address.
    check_read_returns_written_value: assert property (
        @(posedge clk) disable iff (reset)
        (bitRamEn && bitRamRw) |=> (bitRamOut == $past(bitRamIn))
    );

    // A write updates the stored value at that address.
    check_write_updates_memory: assert property (
        @(posedge clk) disable iff (reset)
        (bitRamEn && !bitRamRw) |=> (bitRam[bitRamAddr] == $past(bitRamIn))
    );

    // A write does not change the output while the read path is inactive.
    check_write_does_not_affect_output: assert property (
        @(posedge clk) disable iff (reset)
        (bitRamEn && !bitRamRw) |=> (bitRamOut == $past(bitRamOut))
    );

    // A read does not change the output while the write path is inactive.
    check_read_does_not_affect_output: assert property (
        @(posedge clk) disable iff (reset)
        (bitRamEn && bitRamRw) |=> (bitRamOut == $past(bitRamOut))
    );

endmodule