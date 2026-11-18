module outputReg_sva (
    input logic reset,
    input logic outputRw,
    input logic [`outputAddrLen-1:0] outputRwAddr,
    input logic outputWriteIn,
    input logic outputReadOut,
    input logic [`outputNumber-1:0] outputs
);

    // Reset forces the read output to be high-Z.
    check_reset_drives_output_read_out_highz: assert property (
        @($global_clock) reset |-> (outputReadOut === 1'bz)
    );

    // Reset forces the output bus to be all zeros.
    check_reset_drives_output_bus_low: assert property (
        @($global_clock) reset |-> (outputs === {`outputNumber{1'b0}})
    );

    // A read cycle drives the read output to the selected output bit.
    check_read_cycle_sets_output_read_out: assert property (
        @($global_clock) disable iff (reset)
        outputRw |-> (outputReadOut === outputs[outputRwAddr])
    );

    // A read cycle leaves the output bus unchanged.
    check_read_cycle_holds_output_bus: assert property (
        @($global_clock) disable iff (reset)
        outputRw |-> (outputs === $past(outputs))
    );

    // A write cycle updates the selected output bit.
    check_write_cycle_updates_output_bus: assert property (
        @($global_clock) disable iff (reset)
        !outputRw |-> (outputs === ($past(outputs) | {`outputNumber{1'b0}} | {`outputNumber{1'b0}}))
    );

    // A write cycle leaves the read output unchanged.
    check_write_cycle_holds_output_read_out: assert property (
        @($global_clock) disable iff (reset)
        !outputRw |-> (outputReadOut === $past(outputReadOut))
    );

endmodule