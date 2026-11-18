module tcLoad_sva (
    input logic clk,
    input logic [3:0] tcAddr,
    input logic [7:0] dnIn,
    input logic [7:0] ttIn,
    input logic [7:0] cuIn,
    input logic [7:0] cdIn,
    input logic [7:0] tcLoadOut
);

    // Output matches the concatenation of the selected input bits.
    check_output_matches_selected_inputs: assert property (
        @(posedge clk)
        tcLoadOut == {4'b0, cdIn[tcAddr], cuIn[tcAddr], ttIn[tcAddr], dnIn[tcAddr]}
    );

    // Output bit 0 comes from the selected dnIn bit.
    check_output_bit0_matches_dn: assert property (
        @(posedge clk)
        tcLoadOut[0] == dnIn[tcAddr]
    );

    // Output bit 1 comes from the selected cuIn bit.
    check_output_bit1_matches_cu: assert property (
        @(posedge clk)
        tcLoadOut[1] == cuIn[tcAddr]
    );

    // Output bit 2 comes from the selected ttIn bit.
    check_output_bit2_matches_tt: assert property (
        @(posedge clk)
        tcLoadOut[2] == ttIn[tcAddr]
    );

    // Output bit 3 comes from the selected cdIn bit.
    check_output_bit3_matches_cd: assert property (
        @(posedge clk)
        tcLoadOut[3] == cdIn[tcAddr]
    );

    // Upper output bits are always zero.
    check_output_upper_bits_zero: assert property (
        @(posedge clk)
        tcLoadOut[7:4] == 4'b0000
    );

endmodule