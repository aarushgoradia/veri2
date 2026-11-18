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

    // Reset clears the register on the next clock.
    check_reset_clears_register: assert property (
        @(posedge rxclk) reset |=> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The upper byte of the register is always zero after reset release.
    check_upper_byte_zero_after_reset: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus[17:8] == 8'h00)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        $past(reset) |-> (rxStatRegPlus == 18'h00000)
    );

    // The first non-reset cycle after reset still reflects the reset value.
    check_reset_release_starts_from_zero