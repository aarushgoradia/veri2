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

    // Reset clears the registered statistics counter.
    check_reset_clears_rxstat: assert property (
        @(posedge rxclk) reset |-> (rxStatRegPlus == 18'h000000)
    );

    // The low 18 bits of the counter are always zero.
    check_rxstat_upper_bits_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxStatRegPlus[17:10] == 9'h000)
    );

    // The counter increments by one on each active clock.
    check_rxstat_increments_each_cycle: assert property (
        @(posedge rxclk) disable iff (reset)
        1'b1 |=> (rxStatRegPlus == ($past(rxStatRegPlus) + 18'h000001))
    );

    // The counter never exceeds 256.
    check_rxstat_bounded_by_256: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxStatRegPlus <= 18'h00100)
    );

    // The counter is always even.
    check_rxstat_is_even: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxStatRegPlus[0] == 1'b0)
    );

    // The counter is never zero outside reset.
    check_rxstat_never_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxStatRegPlus != 18'h00000)
    );

endmodule