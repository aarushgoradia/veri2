```systemverilog
module rxNumCounter_sva (
    input logic rxclk,
    input logic reset,
    input logic receiving,
    output logic [`COUNTER_WIDTH-1:0] frame_cnt
);
    // Counter increments only when receiving is high
    counter_increments: assert property (
        @(posedge rxclk) disable iff (!reset) receiving |-> frame_cnt == frame_cnt + 1
    );

    // Counter resets to 0 when receiving is low
    counter_resets: assert property (
        @(posedge rxclk) disable iff (!reset) ~receiving |-> frame_cnt == 0
    );

    // Counter does not increment when reset is high
    counter_no_incr_on_reset: assert property (
        @(posedge rxclk) disable iff (reset) frame_cnt == frame_cnt
    );

    // Counter does not reset when reset is high
    counter_no_reset_on_reset: assert property (
        @(posedge rxclk) disable iff (reset) frame_cnt == frame_cnt
    );

    // Counter width is as expected
    counter_width: assert property (
        @(posedge rxclk) disable iff (!reset) frame_cnt[`COUNTER_WIDTH-1:0] == frame_cnt[`COUNTER_WIDTH-1:0]
    );

    // Counter increments only when enabled
    counter_en_increments: assert property (
        @(posedge rxclk) disable iff (!reset) receiving && ~receiving |-> frame_cnt == frame_cnt
    );

    // Counter does not increment when load is high
    counter_load_no_incr: assert property (
        @(posedge rxclk) disable iff (!reset) ~receiving && load |-> frame_cnt == frame_cnt
    );

    // Counter increments only when load is low
    counter_no_incr_on_load: assert property (
        @(posedge rxclk) disable iff (!reset) receiving && ~load |-> frame_cnt == frame_cnt + 1
    );

    // Counter does not reset when load is low
    counter_no_reset_on_load: assert property (
        @(posedge rxclk) disable iff (!reset) receiving && ~load |-> frame_cnt == frame_cnt
    );

    // Counter increments only when clock is rising edge
    counter_clk_edge: assert property (
        @(posedge rxclk) disable iff (!reset) frame_cnt == frame_cnt
    );
endmodule
```