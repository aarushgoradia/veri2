module can_ibo_sva (
    input logic clk,
    input logic [7:0] di,
    input logic [7:0] do_can
);

// do_can must be the bitwise inverse of di.
    check_bitwise_inverse: assert property (
        @(posedge clk) do_can == ~di
    );

// The least-significant bit is inverted.
    check_lsb_inverted: assert property (
        @(posedge clk) do_can[0] == ~di[7]
    );

// The most-significant bit is inverted.
    check_msb_inverted: assert property (
        @(posedge clk) do_can[7] == ~di[0]
    );

// Equal bits in di must produce complementary bits in do_can.
    check_equal_bits_complement: assert property (
        @(posedge clk) (di[3] == di[4]) |-> (do_can[3] == ~do_can[4])
    );

// Bits with different values in di must produce equal bits in do_can.
    check_different_bits_equal: assert property (
        @(posedge clk) (di[3] != di[4]) |-> (do_can[3] == do_can[4])
    );

endmodule
