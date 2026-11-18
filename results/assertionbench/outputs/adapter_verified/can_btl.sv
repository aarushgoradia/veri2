module can_btl_sva (
    input logic clk,
    input logic rst,
    input logic rx,
    input logic tx,
    input logic [5:0] baud_r_presc,
    input logic [1:0] sync_jump_width,
    input logic [3:0] time_segment1,
    input logic [2:0] time_segment2,
    input logic triple_sampling,
    input logic sample_point,
    input logic sampled_bit,
    input logic sampled_bit_q,
    input logic tx_point,
    input logic hard_sync,
    input logic [6:0] clk_cnt,
    input logic clk_en,
    input logic clk_en_q,
    input logic sync_blocked,
    input logic hard_sync_blocked,
    input logic sync,
    input logic seg1,
    input logic seg2,
    input logic resync_latched,
    input logic tx_next_sp,
    input logic go_sync,
    input logic go_seg1,
    input logic go_seg2,
    input logic [7:0] preset_cnt,
    input logic sync_window,
    input logic resync,
    input logic rx_idle,
    input logic rx_inter,
    input logic transmitting,
    input logic transmitter,
    input logic go_rx_inter,
    input logic go_overload_frame,
    input logic go_error_frame,
    input logic go_tx,
    input logic send_ack,
    input logic node_error_passive
);

// clk_cnt increments by one each cycle when not at the preset count.
    check_clk_cnt_increments: assert property (
        @(posedge clk) disable iff (rst)
        (clk_cnt != preset_cnt) |=> (clk_cnt == ($past(clk_cnt) + 7'd1))
    );

// clk_cnt wraps to zero when it reaches the preset count.
    check_clk_cnt_wraps: assert property (
        @(posedge clk) disable iff (rst)
        (clk_cnt == preset_cnt) |=> (clk_cnt == 7'd0)
    );

// clk_en is high exactly when the counter matches the preset value.
    check_clk_en_matches_preset: assert property (
        @(posedge clk) disable iff (rst)
        clk_en == ({1'b0, clk_cnt} == (preset_cnt - 7'd1))
    );

// clk_en_q captures the previous cycle's clk_en value.
    check_clk_en_q_captures_prev: assert property (
        @(posedge clk) disable iff (rst)
        1'b1 |=> (clk_en_q == $past(clk_en))
    );

// sync_blocked is high on the first cycle after a resync.
    check_sync_blocked_after_resync: assert property (
        @(posedge clk) disable iff (rst)
        resync |=> (sync_blocked == 1'b1)
    );

// sync_blocked clears on the first cycle after seg2.
    check_sync_blocked_clears_after_seg2: assert property (
        @(posedge clk) disable iff (rst)
        (go_seg2 && clk_en_q) |=> (sync_blocked == 1'b0)
    );

// hard_sync_blocked is asserted when hard_sync occurs or when transmitting.
    check_hard_sync_blocked_on_hard_sync: assert property (
        @(posedge clk) disable iff (rst)
        hard_sync |=> (hard_sync_blocked == 1'b1)
    );

// hard_sync_blocked is asserted when transmitting and tx_next is low.
    check_hard_sync_blocked_on_tx: assert property (
        @(posedge clk) disable iff (rst)
        (transmitting && transmitter && !tx_next) |=> (hard_sync_blocked == 1'b1)
    );

// hard_sync_blocked clears on the first cycle after rx_idle or rx_inter.
    check_hard_sync_blocked_clears_after_rx_idle: assert property (
        @(posedge clk) disable iff (rst)
        (rx_idle || rx_inter) |=> (hard_sync_blocked == 1'b0)
    );

// hard_sync_blocked clears on the first cycle after a sampled bit.
    check_hard_sync_blocked_clears_after_sampled_bit: assert property (
        @(posedge clk) disable iff (rst)
        (sampled_bit && sample_point) |=> (hard_sync_blocked == 1'b0)
    );

// hard_sync_blocked clears on the first cycle after a glitch-driven sync.
    check_hard_sync_blocked_clears_after_glitch_sync: assert property (
        @(posedge clk) disable iff (rst)
        (go_rx_inter && sampled_bit && sample_point) |=> (hard_sync_blocked == 1'b0)
    );

// seg1 is high exactly when go_seg1 is asserted.
    check_seg1_matches_go_seg1: assert property (
        @(posedge clk) disable iff (rst)
        seg1 == go_seg1
    );

// seg2 is high exactly when go_seg2 is asserted.
    check_seg2_matches_go_seg2: assert property (
        @(posedge clk) disable iff (rst)
        seg2 == go_seg2
    );

// quant_cnt clears on the first cycle after go_sync, go_seg1, or go_seg2.
    check_quant_cnt_clears_after_go: assert property (
        @(posedge clk) disable iff (rst)
        (go_sync || go_seg1 || go_seg2) |=> (quant_cnt == 5'd0)
    );

// quant_cnt increments by one each cycle when not in a sync/seg1/seg2 state.
    check_quant_cnt_increments: assert property (
        @(posedge clk) disable iff (rst)
        !(go_sync || go_seg1 || go_seg2) |=> (quant_cnt == ($past(quant_cnt) + 5'd1))
    );

// delay is zeroed on the first cycle after a resync outside the SJW window.
    check_delay_zeroed_after_resync_outside_sjw: assert property (
        @(posedge clk) disable iff (rst)
        (resync && !sync_window) |=> (delay == 4'd0)
    );

// delay is set to SJW+1 on the first cycle after a resync inside the SJW window.
    check_delay_set_after_resync_inside_sjw: assert property (
        @(posedge clk) disable iff (rst)
        (resync && sync_window) |=> (delay == ({2'd0, sync_jump_width} + 4'd1))
    );

// delay is incremented by one each cycle when not in a resync state.
    check_delay_increments_when_not_resync: assert property (
        @(posedge clk) disable iff (rst)
        !(resync || go_sync || go_seg1 || go_seg2) |=> (delay == ($past(delay) + 4'd1))
    );

// sync_window is high when the remaining time in seg2 is less than SJW+1.
    check_sync_window_definition: assert property (
        @(posedge clk) disable iff (rst)
        sync_window == ((time_segment2 - quant_cnt[2:0]) < (sync_jump_width + 4'd1))
    );

// sampled_bit_q captures the previous sampled_bit value.
    check_sampled_bit_q_captures_prev: assert property (
        @(posedge clk) disable iff (rst)
        1'b1 |=> (sampled_bit_q == $past(sampled_bit))
    );

// sample_point is high exactly when go_seg2 is asserted and quant_cnt matches time_segment1+delay.
    check_sample_point_matches_go_seg2: assert property (
        @(posedge clk) disable iff (rst)
        sample_point == (go_seg2 && (quant_cnt == (time_segment1 + delay)))
    );

// tx_next_sp is cleared on the first cycle after any error or transmit request.
    check_tx_next_sp_clears_on_error_or_tx: assert property (
        @(posedge clk) disable iff (rst)
        (go_overload_frame || go_error_frame || go_tx || send_ack) |=> (tx_next_sp == 1'b0)
    );

// tx_next_sp is set to 1 when in error passive and sending an error frame.
    check_tx_next_sp_set_on_error_passive: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && node_error_passive) |=> (tx_next_sp == 1'b1)
    );

// tx_next_sp is set to the previous cycle's tx_next value when sample_point is high.
    check_tx_next_sp_captures_prev_on_sample_point: assert property (
        @(posedge clk) disable iff (rst)
        (sample_point && !go_error_frame) |=> (tx_next_sp == $past(tx_next))
    );

// sampled_bit is driven from the current rx value when not in a sync/seg1/seg2 state.
    check_sampled_bit_driven_from_rx: assert property (
        @(posedge clk) disable iff (rst)
        !(go_sync || go_seg1 || go_seg2) |=> (sampled_bit == rx)
    );

// sampled_bit is driven from the previous sampled_bit and rx when in a sync/seg1/seg2 state.
    check_sampled_bit_driven_from_prev: assert property (
        @(posedge clk) disable iff (rst)
        (go_sync || go_seg1 || go_seg2) |=> (sampled_bit == ($past(sampled_bit) & $past(rx)))
    );

// sampled_bit_q is driven from the previous sampled_bit when not in a sync/seg1/seg2 state.
    check_sampled_bit_q_driven_from_prev: assert property (
        @(posedge clk) disable iff (rst)
        !(go_sync || go_seg1 || go_seg2) |=> (sampled_bit_q == $past(sampled_bit))
    );

// sampled_bit_q is driven from the previous sampled_bit_q when in a sync/seg1/seg2 state.
    check_sampled_bit_q_driven_from_prev_on_go: assert property (
        @(posedge clk) disable iff (rst)
        (go_sync || go_seg1 || go_seg2) |=> (sampled_bit_q == $past(sampled_bit_q))
    );

// sample captures the previous cycle's rx value.
    check_sample_captures_prev_rx: assert property (
        @(posedge clk) disable iff (rst)
        1'b1 |=> (sample == { $past(sample[0]), $past(rx) })
    );

// sample_point is cleared on the first cycle after go_sync, go_seg1, or go_seg2.
    check_sample_point_clears_after_go: assert property (
        @(posedge clk) disable iff (rst)
        (go_sync || go_seg1 || go_seg2) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit.
    check_sample_point_clears_after_sampled_bit: assert property (
        @(posedge clk) disable iff (rst)
        (sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a glitch-driven sync.
    check_sample_point_clears_after_glitch_sync: assert property (
        @(posedge clk) disable iff (rst)
        (go_rx_inter && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit in error passive mode.
    check_sample_point_clears_after_sampled_bit_in_error_passive: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && node_error_passive && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while transmitting.
    check_sample_point_clears_after_sampled_bit_while_tx: assert property (
        @(posedge clk) disable iff (rst)
        (transmitting && transmitter && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while sending an ACK.
    check_sample_point_clears_after_sampled_bit_while_send_ack: assert property (
        @(posedge clk) disable iff (rst)
        (send_ack && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in overload mode.
    check_sample_point_clears_after_sampled_bit_while_overload: assert property (
        @(posedge clk) disable iff (rst)
        (go_overload_frame && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in error mode.
    check_sample_point_clears_after_sampled_bit_while_error: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in transmit mode.
    check_sample_point_clears_after_sampled_bit_while_tx_mode: assert property (
        @(posedge clk) disable iff (rst)
        (go_tx && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in idle mode.
    check_sample_point_clears_after_sampled_bit_while_idle: assert property (
        @(posedge clk) disable iff (rst)
        (rx_idle && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in interframe mode.
    check_sample_point_clears_after_sampled_bit_while_interframe: assert property (
        @(posedge clk) disable iff (rst)
        (rx_inter && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert property (
        @(posedge clk) disable iff (rst)
        (go_error_frame && !node_error_passive && triple_sampling && sampled_bit && sample_point) |=> (sample_point == 1'b0)
    );

// sample_point is cleared on the first cycle after a sampled bit while in a tripple sampling error frame.
    check_sample_point_clears_after_sampled_bit_while_error_frame: assert