module rxStatModule_sva (
    input logic        rxclk,
    input logic        reset,
    input logic        good_frame_get,
    input logic        large_error,
    input logic        small_error,
    input logic        crc_check_invalid,
    input logic        receiving,
    input logic        padded_frame,
    input logic        pause_frame,
    input logic        broad_valid,
    input logic        multi_valid,
    input logic        length_65_127,
    input logic        length_128_255,
    input logic        length_256_511,
    input logic        length_512_1023,
    input logic        length_1024_max,
    input logic        jumbo_frame,
    input logic        get_error_code,
    input logic [17:0] rxStatRegPlus
);

// Reset clears the register on the next sampled cycle.
    check_reset_clears_register: assert property (
        @(posedge rxclk) reset |=> (rxStatRegPlus == 18'h00000)
    );

// good_frame_get increments the OK counter.
    check_good_frame_get_increments_ok: assert property (
        @(posedge rxclk) disable iff (reset)
        good_frame_get |=> (rxStatRegPlus[0] == 1'b1)
    );

// crc_check_invalid increments the FCS error counter.
    check_crc_error_increments_fcs_error: assert property (
        @(posedge rxclk) disable iff (reset)
        crc_check_invalid |=> (rxStatRegPlus[1] == 1'b1)
    );

// broad_valid increments the broadcast OK counter.
    check_broadcast_valid_increments_broadcast_ok: assert property (
        @(posedge rxclk) disable iff (reset)
        (broad_valid && good_frame_get) |=> (rxStatRegPlus[2] == 1'b1)
    );

// multi_valid increments the multicast OK counter.
    check_multicast_valid_increments_multicast_ok: assert property (
        @(posedge rxclk) disable iff (reset)
        (multi_valid && good_frame_get) |=> (rxStatRegPlus[3] == 1'b1)
    );

// padded_frame increments the 64-byte OK counter.
    check_padded_frame_increments_64_ok: assert property (
        @(posedge rxclk) disable iff (reset)
        (padded_frame && good_frame_get) |=> (rxStatRegPlus[4] == 1'b1)
    );

// length_65_127 increments the 65-127-byte OK counter.
    check_length_65_127_increments_65_127_ok: assert property (
        @(posedge rxclk) disable iff (reset)
        (length_65_127 && good_frame_get) |=> (rxStatRegPlus[5] == 1'b1)
    );

// length_128_255 increments the 128-255-byte OK counter.
    check_length_128_255_increments_128_255_ok: assert property (
        @(posedge rxclk) disable iff (reset)
        (length_128_255 && good_frame_get) |=> (rxStatRegPlus[6] == 1'b1)
    );

// length_256_511 increments the 256-511-byte OK counter.
    check_length_256_511_increments_256_511_ok: assert property (
        @(posedge rxclk) disable iff (reset)
        (length_256_511 && good_frame_get) |=> (rxStatRegPlus[7] == 1'b1)
    );

// length_512_1023 increments the 512-1023-byte OK counter.
    check_length_512_1023_increments_512_1023_ok: assert property (
        @(posedge rxclk) disable iff (reset)
        (length_512_1023 && good_frame_get) |=> (rxStatRegPlus[8] == 1'b1)
    );

// length_1024_max increments the 1024-1518-byte OK counter.
    check_length_1024_max_increments_1024_max_ok: assert property (
        @(posedge rxclk) disable iff (reset)
        (length_1024_max && good_frame_get) |=> (rxStatRegPlus[9] == 1'b1)
    );

// pause_frame increments the pause OK counter.
    check_pause_frame_increments_pause_ok: assert property (
        @(posedge rxclk) disable iff (reset)
        (pause_frame && good_frame_get) |=> (rxStatRegPlus[10] == 1'b1)
    );

// large_error increments the length out-of-range counter.
    check_large_error_increments_length_error: assert property (
        @(posedge rxclk) disable iff (reset)
        large_error |=> (rxStatRegPlus[11] == 1'b1)
    );

// jumbo_frame increments the jumbo OK counter.
    check_jumbo_frame_increments_jumbo_ok: assert property (
        @(posedge rxclk) disable iff (reset)
        (jumbo_frame && good_frame_get) |=> (rxStatRegPlus[14] == 1'b1)
    );

// small_error increments the undersized counter.
    check_small_error_increments_undersize: assert property (
        @(posedge rxclk) disable iff (reset)
        small_error |=> (rxStatRegPlus[15] == 1'b1)
    );

// get_error_code increments the fragment counter.
    check_get_error_code_increments_fragment: assert property (
        @(posedge rxclk) disable iff (reset)
        (receiving && get_error_code) |=> (rxStatRegPlus[16] == 1'b1)
    );

// receiving increments the receive byte counter.
    check_receiving_increments_receive_bytes: assert property (
        @(posedge rxclk) disable iff (reset)
        receiving |=> (rxStatRegPlus[17] == 1'b1)
    );

endmodule
