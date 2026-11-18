module outputReg_sva (
    input logic reset,
    input logic outputRw,
    input logic [`outputAddrLen-1:0] outputRwAddr,
    input logic outputWriteIn,
    input logic outputReadOut,
    input logic [`outputNumber-1:0] outputs
);

    // Reset forces the read output into an unknown state.
    check_reset_forces_unknown_read: assert property (
        @(posedge outputRwAddr[0]) reset |-> (outputReadOut === 1'bz)
    );

    // Reset clears the visible output register bits.
    check_reset_clears_visible_outputs: assert property (
        @(posedge outputRwAddr[0]) reset |-> (outputs === '0)
    );

    // A read cycle returns the output bit at the selected address.
    check_read_returns_selected_output_bit: assert property (
        @(posedge outputRwAddr[0]) !reset && outputRw |-> (outputReadOut === outputs[outputRwAddr])
    );

    // A write cycle updates the output bit at the selected address.
    check_write_updates_selected_output_bit: assert property (
        @(posedge outputRwAddr[0]) !reset && !outputRw |-> (outputs[outputRwAddr] === outputWriteIn)
    );

    // A write cycle does not change the output bits outside the selected address.
    check_write_updates_only_selected_output_bit: assert property (
        @(posedge outputRwAddr[0]) !reset && !outputRw |-> (outputs !== $past(outputs, 1, reset))
    );

    // A read cycle does not change the output bits outside the selected address.
    check_read_does_not_change_visible_outputs: assert property (
        @(posedge outputRwAddr[0]) !reset && outputRw |-> (outputs === $past(outputs, 1, reset))
    );

    // A write cycle does not change the read output bit.
    check_write_does_not_change_read_output: assert property (
        @(posedge outputRwAddr[0]) !reset && !outputRw |-> (outputReadOut === $past(outputReadOut, 1, reset))
    );

    // A read cycle does not change the write input bit.
    check_read_does_not_change_write_input: assert property (
        @(posedge outputRwAddr[0]) !reset && outputRw |-> (outputWriteIn === $past(outputWriteIn, 1, reset))
    );

    // A write cycle does not change the read address.
    check_write_does_not_change_read_address: assert property (
        @(posedge outputRwAddr[0]) !reset && !outputRw |-> (outputRwAddr === $past(outputRwAddr, 1, reset))
    );

endmodule