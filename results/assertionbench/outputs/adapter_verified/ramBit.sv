module bitRam_sva (
    input logic clk,
    input logic reset,
    input logic bitRamEn,
    input logic bitRamRw,
    input logic bitRamIn,
    input logic [`bitRamAddrLen-1:0] bitRamAddr,
    input logic bitRamOut
);

// Reset drives the output high-impedance.
    check_reset_high_impedance: assert property (
        @(posedge clk) reset |-> (bitRamOut == 1'bz)
    );

// When disabled, the output is high-impedance.
    check_disabled_high_impedance: assert property (
        @(posedge clk) disable iff (reset) (!bitRamEn) |-> (bitRamOut == 1'bz)
    );

// A read returns the previous cycle's stored value.
    check_read_returns_previous_value: assert property (
        @(posedge clk) disable iff (reset) (bitRamEn && !bitRamRw) |-> (bitRamOut == $past(bitRamIn))
    );

// A write updates the stored value on the next read.
    check_write_updates_value: assert property (
        @(posedge clk) disable iff (reset) (bitRamEn && bitRamRw) |-> ##1 (bitRamOut == $past(bitRamIn))
    );

// A write does not change the output on the same cycle.
    check_write_no_immediate_update: assert property (
        @(posedge clk) disable iff (reset) (bitRamEn && bitRamRw) |-> (bitRamOut == 1'bz)
    );

// A read does not change the output on the same cycle.
    check_read_no_immediate_update: assert property (
        @(posedge clk) disable iff (reset) (bitRamEn && !bitRamRw) |-> (bitRamOut == 1'bz)
    );

endmodule
