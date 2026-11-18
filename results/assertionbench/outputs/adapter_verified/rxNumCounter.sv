module rxNumCounter_sva (
    input logic        clk,
    input logic        reset,
    input logic        receiving,
    input logic [11:0] frame_cnt
);

// Clock: rxclk (posedge). Reset: reset (active-high, asynchronous). Logic: sequential counter.

    // On reset, frame_cnt must be zero.
    reset_clears_counter: assert property (
        @(posedge clk) reset |-> (frame_cnt == 12'h000)
    );

// When receiving is low, the counter clears to zero on the next cycle.
    clear_on_load: assert property (
        @(posedge clk) disable iff (reset)
        !receiving |=> (frame_cnt == 12'h000)
    );

// When receiving is high, the counter increments by one on the next cycle.
    increment_on_en: assert property (
        @(posedge clk) disable iff (reset)
        receiving |=> (frame_cnt == ($past(frame_cnt) + 12'd1))
    );

// The counter wraps from 12'hFFF back to 12'h000.
    wrap_on_max: assert property (
        @(posedge clk) disable iff (reset)
        (receiving && (frame_cnt == 12'hFFF)) |=> (frame_cnt == 12'h000)
    );

endmodule
