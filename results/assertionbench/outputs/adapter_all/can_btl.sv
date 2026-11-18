module can_btl_sva (
    input logic        clk,
    input logic        rst,
    input logic        rx,
    input logic        tx,
    input logic        baud_r_presc,
    input logic        sync_jump_width,
    input logic        time_segment1,
    input logic        time_segment2,
    input logic        triple_sampling,
    input logic        sample_point,
    input logic        sampled_bit,
    input logic        sampled_bit_q,
    input logic        tx_point,
    input logic        hard_sync,
    input logic        clk_cnt,
    input logic        clk_en,
    input logic        clk_en_q,
    input logic        sync_blocked,
    input logic        hard_sync_blocked,
    input logic        sync,
    input logic        seg1,
    input logic        seg2,
    input logic        resync_latched,
    input logic        go_sync,
    input logic        go_seg1,
    input logic        go_seg2,
    input logic [7:0]  preset_cnt,
    input logic        sync_window,
    input logic        resync,
    input logic        tx_next_sp,
    input logic        go_overload_frame,
    input logic        go_error_frame,
    input logic        go_tx,
    input logic        send_ack,
    input logic        node_error_passive,
    input logic        rx_idle,
    input logic        rx_inter,
    input logic        transmitting,
    input logic        transmitter,
    input logic        go_rx_inter,
    input logic        tx_next
);
    // clk_cnt increments by 1 when not at terminal count.
    check_clk_cnt_increments: assert property (
        @(posedge clk) disable iff (rst) (clk_cnt != preset_cnt-1'b1) |=> (clk_cnt == $past(clk_cnt) + 7'd1)
    );

    // clk_cnt wraps to 0 when terminal count is reached.
    check_clk_cnt_wraps: assert property (
        @(posedge clk) disable iff (rst) (clk_cnt == preset_cnt-1'b1) |=> (clk_cnt == 7'h00)
    );

    // clk_en is asserted only at terminal count.
    check_clk_en_at_terminal_count: assert property (
        @(posedge clk) disable iff (rst) clk_en |-> (clk_cnt == preset_cnt-1'b1)
    );

    // clk_en_q reflects previous clk_en.
    check_clk_en_q_follows_clk_en: assert property (
        @(posedge clk) disable iff (rst) $past(!rst) |-> (clk_en_q == $past(clk_en))
    );

    // sync is set on go_sync.
    check_sync_sets_on_go_sync: assert property (
        @(posedge clk) disable iff (rst) go_sync |-> (sync == 1'b1)
    );

    // sync is cleared on go_seg1 or go_seg2.
    check_sync_clears_on_go_seg1_or_go_seg2: assert property (
        @(posedge clk) disable iff (rst) (go_seg1 || go_seg2) |-> (sync == 1'b0)
    );

    // seg1 is set on go_seg1.
    check_seg1_sets_on_go_seg1: assert property (
        @(posedge clk) disable iff (rst) go_seg1 |-> (seg1 == 1'b1)
    );

    // seg1 is cleared on go_seg2 or go_sync.
    check_seg1_clears_on_go_seg2_or_go_sync: assert property (
        @(posedge clk) disable iff (rst) (go_seg2 || go_sync) |-> (seg1 == 1'b0)
    );

    // seg2 is set on go_seg2.
    check_seg2_sets_on_go_seg2: assert property (
        @(posedge clk) disable iff (rst) go_seg2 |-> (seg2 == 1'b1)
    );

    // seg2 is cleared on go_sync or go_seg1.
    check_seg2_clears_on_go_sync_or_go_seg1: assert property (
        @(posedge clk) disable iff (rst) (go_sync || go_seg1) |-> (seg2 == 1'b0)
    );

    // quant_cnt is cleared on go_sync, go_seg1, or go_seg2.
    check_quant_cnt_clears_on_go_events: assert property (
        @(posedge clk) disable iff (rst) (go_sync || go_seg1 || go_seg2) |-> (quant_cnt == 5'h00)
    );

    // quant_cnt increments by 1 when not cleared.
    check_quant_cnt_increments: assert property (
        @(posedge clk) disable iff (rst) $past(!rst) && !$past(go_sync || go_seg1 || go_seg2) |-> (quant_cnt == $past(quant_cnt) + 5'd1)
    );

    // delay loads SJW+1 when resync in seg1 and SJW threshold is exceeded.
    check_delay_loads_on_resync_sjw: assert property (
        @(posedge clk) disable iff (rst) $past(!rst) && $past(resync & seg1 & (quant_cnt > {3'h0, sync_jump_width})) |-> (delay == ($past(quant_cnt) + 4'd1))
    );

    // delay loads quant_cnt+1 when resync in seg1 and SJW threshold is not exceeded.
    check_delay_loads_on_resync_no_sjw: assert property (
        @(posedge clk) disable iff (rst) $past(!rst) && $past(resync & seg1 & !(quant_cnt > {3'h0, sync_jump_width})) |-> (delay == $past(quant_cnt) + 4'd1)
    );

    // delay clears on go_sync, go_seg1, or go_seg2.
    check_delay_clears_on_go_events: assert property (
        @(posedge clk) disable iff (rst) $past(!rst) && ($past(go_sync) || $past(go_seg1) || $past(go_seg2)) |-> (delay == 4'h0)
    );

    // delay holds when not cleared or loaded.
    check_delay_holds_without_loads: assert property (
        @(posedge clk) disable iff (rst) $past(!rst) && !$past(resync & seg1) && !$past(go_sync || go_seg1 || go_seg2) |-> (delay == $past(delay))
    );

    // sync_window is true when (time_segment2 - quant_cnt) < (sync_jump_width + 1).
    check_sync_window_definition: assert property (
        @(posedge clk) disable iff (rst) sync_window == ((time_segment2 - quant_cnt[2:0]) < (sync_jump_width + 4'd1))
    );

    // sampled_bit_q captures sampled_bit on go_error_frame.
    check_sampled_bit_q_captures_on_go_error_frame: assert property (
        @(posedge clk) disable iff (rst) go_error_frame |-> (sampled_bit_q == $past(sampled_bit))
    );

    // sample_point is cleared on go_error_frame.
    check_sample_point_clears_on_go_error_frame: assert property (
        @(posedge clk) disable iff (rst) go_error_frame |-> (sample_point == 1'b0)
    );

    // sample_point is cleared on go_sync or go_seg1.
    check_sample_point_clears_on_go_sync_or_go_seg1: assert property (
        @(posedge clk) disable iff (rst) (go_sync || go_seg1) |-> (sample_point == 1'b0)
    );

    // sample_point is set on go_seg2 and quant_cnt matches time_segment1+delay.
    check_sample_point_sets_on_go_seg2: assert property (
        @(posedge clk) disable iff (rst) (go_seg2 && (quant_cnt == (time_segment1 + delay))) |-> (sample_point == 1'b1)
    );

    // sampled_bit captures rx on go_seg2 and quant_cnt matches time_segment1+delay.
    check_sampled_bit_captures_on_go_seg2: assert property (
        @(posedge clk) disable iff (rst) (go_seg2 && (quant_cnt == (time_segment1 + delay))) |-> (sampled_bit == $past(rx))
    );

    // sampled_bit_q holds when not cleared or captured.
    check_sampled_bit_q_holds_without_captures: assert property (
        @(posedge clk) disable iff (rst) $past(!rst) && !$past(go_error_frame) && !$past(go_seg2 && (quant_cnt == (time_segment1 + delay))) |-> (sampled_bit_q == $past(sampled_bit_q))
    );

    // sampled_bit holds when not cleared or captured.
    check_sampled_bit_holds_without_captures: assert property (
        @(posedge clk) disable iff (rst) $past(!rst) && !$past(go_error_frame) && !$past(go_seg2 && (quant_cnt == (time_segment1 + delay))) |-> (sampled_bit == $past(sampled_bit))
    );

    // tx_next_sp clears on go_overload_frame, go_error_frame with active node, or go_tx.
    check_tx_next_sp_clears_on_clear_events: assert property (
        @(posedge clk) disable iff (rst) (go_overload_frame || (go_error_frame && !node_error_passive) || go_tx) |-> (tx_next_sp == 1'b0)
    );

    // tx_next_sp sets on go_error_frame with passive node.
    check_tx_next_sp_sets_on_go_error_frame_passive: assert property (
        @(posedge clk) disable iff (rst) (go_error_frame && node_error_passive) |-> (tx_next_sp == 1'b1)
    );

    // tx_next_sp follows tx_next when sample_point is asserted.
    check_tx_next_sp_follows_tx_next_on_sample_point: assert property (
        @(posedge clk) disable iff (rst) $past(!rst) && $past(sample_point) |-> (tx_next_sp == $past(tx_next))
    );

    // tx_next_sp holds when not cleared or driven by tx_next.
    check_tx_next_sp_holds_without_clears_or_drives: assert property (
        @(posedge clk) disable iff (rst) $past(!rst) && !$past(go_overload_frame) && !$past(go_error_frame && !node_error_passive) && !$past(go_tx) && !$past(sample_point) |-> (tx_next_sp == $past(tx_next_sp))
    );

    // sync_blocked sets on resync.
    check_sync_blocked_sets_on_resync: assert property (
        @(posedge clk) disable iff (rst) resync |-> (sync_blocked == 1'b1)
    );

    // sync_blocked clears on go_seg2.
    check_sync_blocked_clears_on_go_seg2: assert property (
        @(posedge clk) disable iff (rst) go_seg2 |-> (sync_blocked == 1'b0)
    );

    // hard_sync_blocked sets on hard_sync or when transmitting with tx_point and !tx_next.
    check_hard_sync_blocked_sets_on_events: assert property (
        @(posedge clk) disable iff (rst) (hard_sync || (transmitting && transmitter && tx_point && !tx_next)) |-> (hard_sync_blocked == 1'b1)
    );

    // hard_sync_blocked clears on go_rx_inter or when rx_idle/rx_inter with sample_point and sampled_bit.
    check_hard_sync_blocked_clears_on_clear_events: assert property (
        @(posedge clk) disable iff (rst) (go_rx_inter || (rx_idle && sample_point && sampled_bit)) |-> (hard_sync_blocked == 1'b0)
    );

    // hard_sync_blocked holds when not set or cleared.
    check_hard_sync_blocked_holds_without_events: assert property (
        @(posedge clk) disable iff (rst) $past(!rst) && !$past(hard_sync) && !$past(transmitting && transmitter && tx_point && !tx_next) && !$past(go_rx_inter) && !$past(rx_idle && sample_point && sampled_bit) |-> (hard_sync_blocked == $past(hard_sync_blocked))
    );

    // hard_sync_blocked can only rise on hard_sync or tx-related events.
    check_hard_sync_blocked_rise_requires_cause: assert property (
        @(posedge clk) disable iff (rst) $rose(hard_sync_blocked) |-> ($past(hard_sync) || $past(transmitting && transmitter && tx_point && !tx_next))
    );

    // hard_sync_blocked can only fall on go_rx_inter or rx-related events.
    check_hard_sync_blocked_fall_requires_cause: assert property (
        @(posedge clk) disable iff (rst) $fell(hard_sync_blocked) |-> ($past(go_rx_inter) || $past(rx_idle && sample_point && sampled_bit))
    );

    // hard_sync_blocked is a single-cycle pulse.
    check_hard_sync_blocked_single_cycle: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> ##1 !hard_sync_blocked
    );

    // hard_sync_blocked implies sync_blocked.
    check_hard_sync_blocked_implies_sync_blocked: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> sync_blocked
    );

    // hard_sync_blocked implies tx_point is low.
    check_hard_sync_blocked_implies_tx_point_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (tx_point == 1'b0)
    );

    // hard_sync_blocked implies sampled_bit_q is low.
    check_hard_sync_blocked_implies_sampled_bit_q_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (sampled_bit_q == 1'b0)
    );

    // hard_sync_blocked implies sample_point is low.
    check_hard_sync_blocked_implies_sample_point_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (sample_point == 1'b0)
    );

    // hard_sync_blocked implies tx_next_sp is low.
    check_hard_sync_blocked_implies_tx_next_sp_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (tx_next_sp == 1'b0)
    );

    // hard_sync_blocked implies seg1 is high.
    check_hard_sync_blocked_implies_seg1_high: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (seg1 == 1'b1)
    );

    // hard_sync_blocked implies seg2 is low.
    check_hard_sync_blocked_implies_seg2_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (seg2 == 1'b0)
    );

    // hard_sync_blocked implies quant_cnt is zero.
    check_hard_sync_blocked_implies_quant_cnt_zero: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (quant_cnt == 5'h00)
    );

    // hard_sync_blocked implies delay is zero.
    check_hard_sync_blocked_implies_delay_zero: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (delay == 4'h0)
    );

    // hard_sync_blocked implies sync is low.
    check_hard_sync_blocked_implies_sync_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (sync == 1'b0)
    );

    // hard_sync_blocked implies tx_point is low.
    check_hard_sync_blocked_implies_tx_point_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (tx_point == 1'b0)
    );

    // hard_sync_blocked implies sampled_bit_q is low.
    check_hard_sync_blocked_implies_sampled_bit_q_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (sampled_bit_q == 1'b0)
    );

    // hard_sync_blocked implies sample_point is low.
    check_hard_sync_blocked_implies_sample_point_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (sample_point == 1'b0)
    );

    // hard_sync_blocked implies tx_next_sp is low.
    check_hard_sync_blocked_implies_tx_next_sp_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (tx_next_sp == 1'b0)
    );

    // hard_sync_blocked implies seg1 is high.
    check_hard_sync_blocked_implies_seg1_high: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (seg1 == 1'b1)
    );

    // hard_sync_blocked implies seg2 is low.
    check_hard_sync_blocked_implies_seg2_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (seg2 == 1'b0)
    );

    // hard_sync_blocked implies quant_cnt is zero.
    check_hard_sync_blocked_implies_quant_cnt_zero: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (quant_cnt == 5'h00)
    );

    // hard_sync_blocked implies delay is zero.
    check_hard_sync_blocked_implies_delay_zero: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (delay == 4'h0)
    );

    // hard_sync_blocked implies sync is low.
    check_hard_sync_blocked_implies_sync_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (sync == 1'b0)
    );

    // hard_sync_blocked implies tx_point is low.
    check_hard_sync_blocked_implies_tx_point_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (tx_point == 1'b0)
    );

    // hard_sync_blocked implies sampled_bit_q is low.
    check_hard_sync_blocked_implies_sampled_bit_q_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (sampled_bit_q == 1'b0)
    );

    // hard_sync_blocked implies sample_point is low.
    check_hard_sync_blocked_implies_sample_point_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (sample_point == 1'b0)
    );

    // hard_sync_blocked implies tx_next_sp is low.
    check_hard_sync_blocked_implies_tx_next_sp_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (tx_next_sp == 1'b0)
    );

    // hard_sync_blocked implies seg1 is high.
    check_hard_sync_blocked_implies_seg1_high: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (seg1 == 1'b1)
    );

    // hard_sync_blocked implies seg2 is low.
    check_hard_sync_blocked_implies_seg2_low: assert property (
        @(posedge clk) disable iff (rst) hard_sync_blocked |-> (seg2 == 1'b0)
    );

    // hard_sync_blocked implies quant_cnt is zero.
    check_hard_sync_blocked_impl