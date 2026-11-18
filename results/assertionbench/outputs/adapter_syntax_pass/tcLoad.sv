module tcLoad_sva (
    input logic clk,
    input logic [3:0] tcAddr,
    input logic [7:0] dnIn,
    input logic [7:0] ttIn,
    input logic [7:0] cuIn,
    input logic [7:0] cdIn,
    input logic [7:0] tcLoadOut
);

    // tcLoadOut must match the concatenation of the selected input bits.
    check_tcloadout_matches_selected_inputs: assert property (
        @(posedge clk)
        tcLoadOut == {4'b0000, cdIn[tcAddr], cuIn[tcAddr], ttIn[tcAddr], dnIn[tcAddr]}
    );

    // The upper four bits of tcLoadOut must always be zero.
    check_upper_bits_zero: assert property (
        @(posedge clk)
        tcLoadOut[7:4] == 4'b0000
    );

    // The least significant bit of tcLoadOut must come from dnIn[tcAddr].
    check_lsb_from_dn: assert property (
        @(posedge clk)
        tcLoadOut[0] == dnIn[tcAddr]
    );

    // Selecting dnIn must make tcLoadOut[0] equal dnIn[tcAddr].
    check_select_dn: assert property (
        @(posedge clk)
        dnIn[tcAddr] |-> (tcLoadOut[0] == dnIn[tcAddr])
    );

    // Selecting ttIn must make tcLoadOut[1] equal ttIn[tcAddr].
    check_select_tt: assert property (
        @(posedge clk)
        ttIn[tcAddr] |-> (tcLoadOut[1] == ttIn[tcAddr])
    );

    // Selecting cuIn must make tcLoadOut[2] equal cuIn[tcAddr].
    check_select_cu: assert property (
        @(posedge clk)
        cuIn[tcAddr] |-> (tcLoadOut[2] == cuIn[tcAddr])
    );

    // Selecting cdIn must make tcLoadOut[3] equal cdIn[tcAddr].
    check_select_cd: assert property (
        @(posedge clk)
        cdIn[tcAddr] |-> (tcLoadOut[3] == cdIn[tcAddr])
    );

endmodule