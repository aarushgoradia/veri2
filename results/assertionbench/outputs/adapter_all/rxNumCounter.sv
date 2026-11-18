module rxNumCounter_sva (
    input logic        clk,
    input logic        reset,
    input logic        receiving,
    input logic [11:0] frame_cnt
);

    // Reset clears the counter by the next clock.
    check_reset_clears_counter: assert property (
        @(posedge clk) reset |=> (frame_cnt == 12'd0)
    );

    // When not receiving, the counter loads zero on the next clock.
    check_load_zero_when_not_receiving: assert property (
        @(posedge clk) disable iff (reset)
        !receiving |=> (frame_cnt == 12'd0)
    );

    // When receiving, the counter increments by one on the next clock.
    check_increment_when_receiving: assert property (
        @(posedge clk) disable iff (reset)
        receiving |=> (frame_cnt == ($past(frame_cnt) + 12'd1))
    );

    // The counter value is always zero or one greater than the previous value.
    check_counter_progression: assert property (
        @(posedge clk) disable iff (reset)
        1'b1 |=> ((frame_cnt == 12'd0) || (frame_cnt == ($past(frame_cnt) + 12'd1)))
    );

    // The counter wraps from 4095 back to zero when receiving.
    check_counter_wraps_from_max: assert property (
        @(posedge clk) disable iff (reset)
        (receiving && (frame_cnt == 12'd4095)) |=> (frame_cnt == 12'd0)
    );

endmodule