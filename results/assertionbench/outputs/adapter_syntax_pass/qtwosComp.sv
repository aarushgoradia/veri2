module qtwosComp_sva (
    input logic [30:0] a,
    input logic [63:0] b
);

    // b must equal the zero-extended 31-bit two's complement of a.
    check_twos_comp_mapping: assert property (
        @($global_clock) b == {33'b0, (({31'b0, a} + 31'h0000_0001) & 31'hFFFF_FFFF)}
    );

    // The low 31 bits of b must match the low 31 bits of a.
    check_low_bits_passthrough: assert property (
        @($global_clock) b[30:0] == a
    );

    // The upper 32 bits of b must be zero.
    check_upper_bits_zero: assert property (
        @($global_clock) b[63:31] == 33'b0
    );

    // Zero input must produce zero output.
    check_zero_input_zero_output: assert property (
        @($global_clock) (a == 31'h0000_0000) |-> (b == 64'h0000_0000_0000_0000)
    );

    // All-ones input must produce zero output.
    check_all_ones_input_zero_output: assert property (
        @($global_clock) (a == 31'hFFFF_FFFF) |-> (b == 64'h0000_0000_0000_0000)
    );

    // The least-significant input bit must invert in the output.
    check_lsb_inverts: assert property (
        @($global_clock) b[30] == ~a[0]
    );

    // Input bit 1 must remain unchanged in the output.
    check_bit1_passthrough: assert property (
        @($global_clock) b[29] == a[1]
    );

    // Input bit 30 must remain unchanged in the output.
    check_bit30_passthrough: assert property (
        @($global_clock) b[0] == a[30]
    );

endmodule