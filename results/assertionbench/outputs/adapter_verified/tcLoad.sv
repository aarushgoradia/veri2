module tcLoad_sva (
    input logic clk,
    input logic [`tcAddrLen-1:0] tcAddr,
    input logic [`tcNumbers-1:0] dnIn,
    input logic [`tcNumbers-1:0] ttIn,
    input logic [`tcNumbers-1:0] cuIn,
    input logic [`tcNumbers-1:0] cdIn,
    input logic [7:0] tcLoadOut
);

// tcLoadOut is a 4-bit bus with the selected bits in the upper nibble.
    check_output_bus_shape: assert property (
        @(posedge clk) tcLoadOut[3:0] == 4'b0000
    );

// dnIn[tcAddr] selects bit 3 of tcLoadOut.
    check_dn_selects_bit3: assert property (
        @(posedge clk) tcLoadOut[3] == dnIn[tcAddr]
    );

// ttIn[tcAddr] selects bit 2 of tcLoadOut.
    check_tt_selects_bit2: assert property (
        @(posedge clk) tcLoadOut[2] == ttIn[tcAddr]
    );

// cuIn[tcAddr] selects bit 1 of tcLoadOut.
    check_cu_selects_bit1: assert property (
        @(posedge clk) tcLoadOut[1] == cuIn[tcAddr]
    );

// cdIn[tcAddr] selects bit 0 of tcLoadOut.
    check_cd_selects_bit0: assert property (
        @(posedge clk) tcLoadOut[0] == cdIn[tcAddr]
    );

endmodule
