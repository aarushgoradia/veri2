module rxNumCounter_sva (
    input logic rxclk,
    input logic reset,
    input logic receiving,
    input logic [`COUNTER_WIDTH-1:0] frame_cnt
);

    // Reset clears the counter on the next clock sample.
    check_reset_clears_counter: assert property (
        @(posedge rxclk) reset |=> (frame_cnt == '0)
    );

    // When receiving is low, the counter is in load mode and holds its value.
    check_load_mode_holds_value: assert property (
        @(posedge rxclk) disable iff (reset)
        !receiving |=> (frame_cnt == $past(frame_cnt))
    );

    // When receiving is high, the counter increments by one on the next clock.
    check_increment_mode_updates_value: assert property (
        @(posedge rxclk) disable iff (reset)
        receiving |=> (frame_cnt == ($past(frame_cnt) + 12'd1))
    );

    // The counter value never exceeds the maximum valid Ethernet frame length.
    check_counter_bounded_by_max_length: assert property (
        @(posedge rxclk) disable iff (reset)
        (frame_cnt <= 12'h0be)
    );

endmodule