module PSGChannelSummer_sva (
    input logic        clk_i,
    input logic [7:0]  cnt,
    input logic [3:0]  outctrl,
    input logic [19:0] tmc_i,
    input logic [21:0] o
);

    // When cnt is zero, the next cycle accumulates the selected channel data.
    check_zero_count_loads_selected_data: assert property (
        @(posedge clk_i)
        (cnt == 8'd0) |=> (o == ($past(o) + ($past(tmc_i) & {20{$past(outctrl[cnt[1:0])}}}))
    );

    // When cnt is 1, 2, or 3, the next cycle accumulates the selected channel data.
    check_nonzero_count_accumulates_selected_data: assert property (
        @(posedge clk_i)
        (cnt >= 8'd1 && cnt <= 8'd3) |=> (o == ($past(o) + ($past(tmc_i) & {20{$past(outctrl[cnt[1:0])}})))
    );

    // When cnt is 4 or greater, the next cycle holds the previous value.
    check_nonselected_counts_hold_value: assert property (
        @(posedge clk_i)
        (cnt >= 8'd4) |=> (o == $past(o))
    );

    // A zero channel select mask clears the accumulated output on the next cycle.
    check_zero_mask_clears_output: assert property (
        @(posedge clk_i)
        (outctrl[cnt[1:0]] == 1'b0) |=> (o == $past(o))
    );

    // With no active channel selected, the output holds its value.
    check_no_active_channel_holds_output: assert property (
        @(posedge clk_i)
        (outctrl == 4'b0000) |=> (o == $past(o))
    );

    // With all channels selected, the output accumulates the full channel data.
    check_all_channels_selected_accumulate_full_data: assert property (
        @(posedge clk_i)
        (outctrl == 4'b1111) |=> (o == ($past(o) + $past(tmc_i)))
    );

endmodule