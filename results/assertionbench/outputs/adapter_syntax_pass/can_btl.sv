module can_btl_sva (
    input logic        clk,
    input logic        rst,
    input logic        rx,
    input logic        tx,
    input logic [5:0]  baud_r_presc,
    input logic [1:0]  sync_jump_width,
    input logic [3:0]  time_segment1,
    input logic [2:0]  time_segment2,
    input logic        triple_sampling,
    input logic        sample_point,
    input logic        sampled_bit,
    input logic        sampled_bit_q,
    input logic        tx_point,
    input logic        hard_sync,
    input logic        rx_idle,
    input logic        rx_inter,
    input logic        transmitting,
    input logic        transmitter,
    input logic        go_rx_inter,
    input logic        tx_next,
    input logic        go_overload_frame,
    input logic        go_error_frame,
    input logic        go_tx,
    input logic        send_ack,
    input logic        node_error_passive
);

    // clk_cnt increments by one while below the baud rate limit.
    check_clk_cnt_increments: assert property (
        @(posedge clk) disable iff (rst)
        (clk_cnt < ((baud_r_presc + 6'd1) << 1)) |=> (clk_cnt == ($past(clk_cnt) + 7'd1))
    );

    // clk_cnt wraps to zero when the baud rate limit is reached.
    check_clk_cnt_wraps: assert property (
        @(posedge clk) disable iff (rst)
        (clk_cnt >= ((baud_r_presc + 6'd1) << 1)) |=> (clk_cnt == 7'h00)
    );

    // clk_en is asserted on the last clock of the baud rate period.
    check_clk_en_asserts_on_last_cycle: assert property (
        @(posedge clk) disable iff (rst)
        (clk_cnt == ((baud_r_presc + 6'd1) << 1) - 7'd1) |=> (clk_en == 1'b1)
    );

    // clk_en is deasserted on the next clock after the baud rate period.
    check_clk_en_deasserts_after_last_cycle: assert property (
        @(posedge clk) disable iff (rst)
        (clk_cnt == ((baud_r_presc + 6'd1) << 1)) |=> (clk_en == 1'b0)
    );

    // clk_en_q is the previous cycle's clk_en value.
    check_clk_en_q_tracks_clk_en: assert property (
        @(posedge clk) disable iff (rst)
        1'b1 |=> (clk_en_q == $past(clk_en))
    );

    // sync is asserted on the last clock of the sync window.
    check_sync_asserts_on_sync_window: assert property (
        @(posedge clk) disable iff (rst)
        (clk_en_q && (quant_cnt[2:0] == time_segment2) &&
         ((time_segment2 - quant_cnt[2:0]) < (sync_jump_width + 3'd1))) |=> (sync == 1'b1)
    );

    // sync is deasserted on the next clock after the sync window.
    check_sync_deasserts_after_sync_window: assert property (
        @(posedge clk) disable iff (rst)
        (clk_en_q && (quant_cnt[2:0] == time_segment2) &&
         !((time_segment2 - quant_cnt[2:0]) < (sync_jump_width + 3'd1))) |=> (sync == 1'b0)
    );

    // seg1 is asserted on the last clock of seg1.
    check_seg1_asserts_on_seg1_window: assert property (
        @(posedge clk) disable iff (rst)
        (clk_en_q && (sync | hard_sync | (resync & seg2 & sync_window) |
                      (resync_latched & sync_window)) &&
         (quant_cnt == (time_segment1 + delay))) |=> (seg1 == 1'b1)
    );

    // seg1 is deasserted on the next clock after seg1.
    check_seg1_deasserts_after_seg1_window: assert property (
        @(posedge clk) disable iff (rst)
        (clk_en_q && (sync | hard_sync | (resync & seg2 & sync_window) |
                      (resync_latched & sync_window)) &&
         (quant_cnt != (time_segment1 + delay))) |=> (seg1 == 1'b0)
    );

    // seg2 is asserted on the last clock of seg2.
    check_seg2_asserts_on_seg2_window: assert property (
        @(posedge clk) disable iff (rst)
        (clk_en_q && (seg1 & (~hard_sync) & (quant_cnt == (time_segment1 + delay)))) |=> (seg2 == 1'b1)
    );

    // seg2 is deasserted on the next clock after seg2.
    check_seg2_deasserts_after_seg2_window: assert property (
        @(posedge clk) disable iff (rst)
        (clk_en_q && (seg1 & (~hard_sync) & (quant_cnt != (time_segment1 + delay)))) |=> (seg2 == 1'b0)
    );

    // quant_cnt increments by one while seg1, seg2, or sync is active.
    check_quant_cnt_increments_on_active_windows: assert property (
        @(posedge clk) disable iff (rst)
        (clk_en_q && (go_sync | go_seg1 | go_seg2)) |=> (quant_cnt == ($past(quant_cnt) + 5'd1))
    );

    // quant_cnt is cleared on the next clock after seg1, seg2, or sync.
    check_quant_cnt_clears_after_active_windows: assert property (
        @(posedge clk) disable iff (rst)
        (clk_en_q && !(go_sync | go_seg1 | go_seg2)) |=> (quant_cnt == 5'h00)
    );

    // delay is cleared when resync is not active.
    check_delay_clears_without_resync: assert property (
        @(posedge clk) disable iff (rst)
        !(resync & seg1 & (~transmitting | (transmitting & (tx_next_sp | (tx & (~rx)))))) |=> (delay == 4'h0)
    );

    // delay is loaded from quant_cnt when resync is active.
    check_delay_loads_from_quant_cnt: assert property (
        @(posedge clk) disable iff (rst)
        (resync & seg1 & (~transmitting | (transmitting & (tx_next_sp | (tx & (~rx)))))) |=> (
            delay == (($past(quant_cnt) > {3'h0, sync_jump_width}) ?
                     ({2'h0, sync_jump_width} + 4'd1) :
                     ($past(quant_cnt) + 4'd1))
        )
    );

    // sampled_bit_q captures sampled_bit on the next clock.
    check_sampled_bit_q_captures_sampled_bit: assert property (
        @(posedge clk) disable iff (rst)
        1'b1 |=> (sampled_bit_q == $past(sampled_bit))
    );

    // sample_point is asserted on the last clock of seg1.
    check_sample_point_asserts_on_seg1_window: assert property (
        @(posedge clk) disable iff (rst)
        (clk_en_q && seg1 && (quant_cnt == (time_segment1 + delay))) |=> (sample_point == 1'b1)
    );

    // sample_point is deasserted on the next clock after seg1.
    check_sample_point_deasserts_after_seg1_window: assert property (
        @(posedge clk) disable iff (rst)
        (clk_en_q && seg1 && (quant_cnt != (time_segment1 + delay))) |=> (sample_point == 1'b0)
    );

    // sampled_bit_q is cleared when go_error_frame is asserted.
    check_sampled_bit_q_clears_on_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        go_error_frame |=> (sampled_bit_q == 1'b0)
    );

    // sampled_bit_q holds when no error frame is active.
    check_sampled_bit_q_holds_without_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        !go_error_frame |=> (sampled_bit_q == $past(sampled_bit_q))
    );

    // tx_point is cleared when go_overload_frame is asserted.
    check_tx_point_clears_on_overload_frame: assert property (
        @(posedge clk) disable iff (rst)
        go_overload_frame |=> (tx_point == 1'b0)
    );

    // tx_point holds when no overload frame is active.
    check_tx_point_holds_without_overload_frame: assert property (
        @(posedge clk) disable iff (rst)
        !go_overload_frame |=> (tx_point == $past(tx_point))
    );

    // tx_point is cleared when go_error_frame is asserted and node is not passive.
    check_tx_point_clears_on_error_frame_when_not_passive: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive) |=> (tx_point == 1'b0)
    );

    // tx_point holds when no error frame is active or node is passive.
    check_tx_point_holds_without_error_frame_or_passive_node: assert property (
        @(posedge clk) disable iff (rst)
        (!(go_error_frame && !node_error_passive)) |=> (tx_point == $past(tx_point))
    );

    // tx_point is set when go_error_frame is asserted and node is passive.
    check_tx_point_sets_on_error_frame_when_passive_node: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && node_error_passive) |=> (tx_point == 1'b1)
    );

    // tx_point is cleared when go_tx is asserted.
    check_tx_point_clears_on_go_tx: assert property (
        @(posedge clk) disable iff (rst)
        go_tx |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when send_ack is asserted.
    check_tx_point_clears_on_send_ack: assert property (
        @(posedge clk) disable iff (rst)
        send_ack |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when tx_next_sp is asserted.
    check_tx_point_clears_on_tx_next_sp: assert property (
        @(posedge clk) disable iff (rst)
        tx_next_sp |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when tx is asserted and rx is deasserted.
    check_tx_point_clears_on_tx_without_rx: assert property (
        @(posedge clk) disable iff (rst)
        (tx && !rx) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when rx_idle or rx_inter is asserted and sample_point is high.
    check_tx_point_clears_on_rx_idle_or_inter: assert property (
        @(posedge clk) disable iff (rst)
        ((rx_idle | rx_inter) && sample_point) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when rx_idle or rx_inter is asserted and sampled_bit is high.
    check_tx_point_clears_on_rx_idle_or_inter_with_sampled_bit: assert property (
        @(posedge clk) disable iff (rst)
        ((rx_idle | rx_inter) && sampled_bit) |=> (tx_point == 1'b0)
    );

    // tx_point is set when sample_point is asserted and tx_next is high.
    check_tx_point_sets_on_sample_point_with_tx_next: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && tx_next) |=> (tx_point == 1'b1)
    );

    // tx_point is set when sample_point is asserted and tx is high and rx is low.
    check_tx_point_sets_on_sample_point_with_tx_without_rx: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && tx && !rx) |=> (tx_point == 1'b1)
    );

    // tx_point is cleared when sample_point is asserted and tx is low.
    check_tx_point_clears_on_sample_point_with_tx_low: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && !tx) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and rx is high.
    check_tx_point_clears_on_sample_point_with_rx_high: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && rx) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and sampled_bit is high.
    check_tx_point_clears_on_sample_point_with_sampled_bit: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && sampled_bit) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and sampled_bit_q is high.
    check_tx_point_clears_on_sample_point_with_sampled_bit_q: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && sampled_bit_q) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and tx_point is high.
    check_tx_point_clears_on_sample_point_with_self: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && tx_point) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and tx_next_sp is high.
    check_tx_point_clears_on_sample_point_with_tx_next_sp: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && tx_next_sp) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and go_overload_frame is asserted.
    check_tx_point_clears_on_sample_point_with_overload_frame: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && go_overload_frame) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and go_error_frame is asserted.
    check_tx_point_clears_on_sample_point_with_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && go_error_frame) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and go_tx is asserted.
    check_tx_point_clears_on_sample_point_with_go_tx: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && go_tx) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and send_ack is asserted.
    check_tx_point_clears_on_sample_point_with_send_ack: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && send_ack) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and tx is asserted and rx is low.
    check_tx_point_clears_on_sample_point_with_tx_without_rx: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && tx && !rx) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and rx_idle or rx_inter is asserted.
    check_tx_point_clears_on_sample_point_with_rx_idle_or_inter: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && (rx_idle | rx_inter)) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and sampled_bit is high.
    check_tx_point_clears_on_sample_point_with_sampled_bit: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && sampled_bit) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and sampled_bit_q is high.
    check_tx_point_clears_on_sample_point_with_sampled_bit_q: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && sampled_bit_q) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and tx_point is high.
    check_tx_point_clears_on_sample_point_with_self: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && tx_point) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and tx_next_sp is high.
    check_tx_point_clears_on_sample_point_with_tx_next_sp: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && tx_next_sp) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and go_overload_frame is asserted.
    check_tx_point_clears_on_sample_point_with_overload_frame: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && go_overload_frame) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and go_error_frame is asserted.
    check_tx_point_clears_on_sample_point_with_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && go_error_frame) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and go_tx is asserted.
    check_tx_point_clears_on_sample_point_with_go_tx: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && go_tx) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and send_ack is asserted.
    check_tx_point_clears_on_sample_point_with_send_ack: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && send_ack) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and tx is asserted and rx is low.
    check_tx_point_clears_on_sample_point_with_tx_without_rx: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && tx && !rx) |=> (tx_point == 1'b0)
    );

    // tx_point is cleared when sample_point is asserted and rx_idle or rx_inter is asserted.
    check_tx_point_clears_on_sample_point_with_rx_idle_or_inter: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && (rx_idle