module can_ibo_sva (
    input logic        clk,
    input logic [7:0]  di,
    input logic [7:0]  do_can
);

    // do_can must be the bit-reversed value of di.
    check_bit_reverse_mapping: assert property (
        @(posedge clk) do_can == {di[6], di[5], di[4], di[3], di[2], di[1], di[0], di[7]}
    );

    // do_can[0] must mirror di[7].
    check_bit0_mapping: assert property (
        @(posedge clk) do_can[0] == di[7]
    );

    // do_can[1] must mirror di[6].
    check_bit1_mapping: assert property (
        @(posedge clk) do_can[1] == di[6]
    );

    // do_can[2] must mirror di[5].
    check_bit2_mapping: assert property (
        @(posedge clk) do_can[2] == di[5]
    );

    // do_can[3] must mirror di[4].
    check_bit3_mapping: assert property (
        @(posedge clk) do_can[3] == di[4]
    );

    // do_can[4] must mirror di[3].
    check_bit4_mapping: assert property (
        @(posedge clk) do_can[4] == di[3]
    );

    // do_can[5] must mirror di[2].
    check_bit5_mapping: assert property (
        @(posedge clk) do_can[5] == di[2]
    );

    // do_can[6] must mirror di[1].
    check_bit6_mapping: assert property (
        @(posedge clk) do_can[6] == di[1]
    );

    // do_can[7] must mirror di[0].
    check_bit7_mapping: assert property (
        @(posedge clk) do_can[7] == di[0]
    );

endmodule