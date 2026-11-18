module outputReg_sva (
    input logic clk,
    input logic reset,
    input logic outputRw,
    input logic [`outputAddrLen-1:0] outputRwAddr,
    input logic outputWriteIn,
    input logic outputReadOut,
    input logic [`outputNumber-1:0] outputs
);

// Reset drives outputReadOut to high-impedance.
    check_reset_impeds_read: assert property (
        @(posedge clk) reset |-> (outputReadOut == 1'bz)
    );

// Reset clears the output register to zero.
    check_reset_clears_outputs: assert property (
        @(posedge clk) reset |-> (outputs == 128'h0)
    );

// A read cycle returns the selected output bit.
    check_read_returns_selected_bit: assert property (
        @(posedge clk) disable iff (reset)
        outputRw |-> (outputReadOut == outputs[outputRwAddr])
    );

// A write cycle sets the selected output bit to 1.
    check_write_sets_selected_bit: assert property (
        @(posedge clk) disable iff (reset)
        !outputRw |-> (outputs[outputRwAddr] == 1'b1)
    );

// A write cycle leaves all other output bits unchanged.
    check_write_preserves_other_bits: assert property (
        @(posedge clk) disable iff (reset)
        !outputRw |-> (outputs[~outputRwAddr] == $past(outputs[~outputRwAddr]))
    );

// A read cycle leaves all output bits unchanged.
    check_read_preserves_outputs: assert property (
        @(posedge clk) disable iff (reset)
        outputRw |-> (outputs == $past(outputs))
    );

endmodule
