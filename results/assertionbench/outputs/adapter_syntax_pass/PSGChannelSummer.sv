module PSGChannelSummer_sva (
    input logic clk_i,
    input logic [7:0] cnt,
    input logic [3:0] outctrl,
    input logic [19:0] tmc_i,
    input logic [21:0] o
);

    // When cnt is zero, the next cycle's output is zero plus the selected channel.
    check_zero_count_load: assert property (
        @(posedge clk_i)
        (cnt == 8'd0) |=> (o == 22'd0 + (tmc_i & {20{outctrl[cnt[1:0]]}}))
    );

    // When cnt is in 1..3, the next cycle's output adds the selected channel.
    check_nonzero_count_add: assert property (
        @(posedge clk_i)
        (cnt >= 8'd1 && cnt <= 8'd3) |=> (o == ($past(o) + (tmc_i & {20{outctrl[cnt[1:0]]}})))
    );

    // When cnt is 4 or more, the next cycle's output holds its value.
    check_count_ge4_hold: assert property (
        @(posedge clk_i)
        (cnt >= 8'd4) |=> (o == $past(o))
    );

    // The output is always within the zero-plus-selected-channel range.
    check_output_range: assert property (
        @(posedge clk_i)
        o <= 22'd0 + (tmc_i & {20{1'b1}})
    );

    // The output never exceeds the selected channel value.
    check_output_le_selected_channel: assert property (
        @(posedge clk_i)
        o <= tmc_i & {20{outctrl[cnt[1:0]]}}
    );

endmodule