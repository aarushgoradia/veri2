module MAC_rx_ctrl_sva (
    input logic Reset,
    input logic Clk,
    input logic MCrs_dv,
    input logic MRxD,
    input logic MRxErr,
    input logic CRC_en,
    input logic CRC_init,
    input logic CRC_err,
    input logic MAC_add_en,
    input logic MAC_rx_add_chk_err,
    input logic broadcast_ptr,
    input logic broadcast_drop,
    input logic [15:0] pause_quanta,
    input logic pause_quanta_val,
    input logic [7:0] Fifo_data,
    input logic Fifo_data_en,
    input logic Fifo_data_err,
    input logic Fifo_data_end,
    input logic Fifo_full,
    input logic [15:0] Rx_pkt_length_rmon,
    input logic Rx_apply_rmon,
    input logic [2:0] Rx_pkt_err_type_rmon,
    input logic [2:0] Rx_pkt_type_rmon,
    input logic [5:0] RX_IFG_SET,
    input logic [15:0] RX_MAX_LENGTH,
    input logic [6:0] RX_MIN_LENGTH
);

    // CRC_en is asserted only during the data state.
    check_crc_en_during_data: assert property (
        @(posedge Clk) disable iff (Reset)
        (CRC_en == (Current_state == State_data))
    );

    // CRC_init is asserted only during the SFD state.
    check_crc_init_during_sfd: assert property (
        @(posedge Clk) disable iff (Reset)
        (CRC_init == (Current_state == State_SFD))
    );

    // Rx_pkt_length_rmon is the previous frame length minus one.
    check_rx_pkt_length_rmon_from_counter: assert property (
        @(posedge Clk) disable iff (Reset)
        (Rx_pkt_length_rmon == (Frame_length_counter - 16'd1))
    );

    // Rx_apply_rmon is asserted on the cycle after an end-of-frame state.
    check_rx_apply_rmon_after_end_state: assert property (
        @(posedge Clk) disable iff (Reset)
        (Rx_apply_rmon == (Rx_apply_rmon_tmp_pl1 == 1'b1))
    );

    // Rx_apply_rmon_tmp is asserted on the cycle after an end-of-frame state.
    check_rx_apply_rmon_tmp_after_end_state: assert property (
        @(posedge Clk) disable iff (Reset)
        (Rx_apply_rmon_tmp == (Current_state inside {State_OkEnd, State_ErrEnd, State_CRCErrEnd, State_FFFullErrEnd}))
    );

    // Rx_apply_rmon_tmp is cleared on the next cycle after an end-of-frame state.
    check_rx_apply_rmon_tmp_clears_after_end_state: assert property (
        @(posedge Clk) disable iff (Reset)
        (Rx_apply_rmon_tmp_pl1 == 1'b0) |=> (Rx_apply_rmon_tmp == 1'b0)
    );

    // Rx_pkt_err_type_rmon encodes CRC error, full FIFO error, and normal error.
    check_rx_pkt_err_type_rmon_encoding: assert property (
        @(posedge Clk) disable iff (Reset)
        (Rx_pkt_err_type_rmon inside {3'b001, 3'b010, 3'b011, 3'b100})
    );

    // pause_quanta_val is asserted only on the syn wait cycle after an OK end.
    check_pause_quanta_val_after_ok_end: assert property (
        @(posedge Clk) disable iff (Reset)
        (pause_quanta_val == (Current_state == State_OkEnd && Pause_current == Pause_syn))
    );

    // pause_quanta_val is also asserted on the next cycle after a pause value pulse.
    check_pause_quanta_val_after_pause_value_pulse: assert property (
        @(posedge Clk) disable iff (Reset)
        (pause_quanta_val_tmp == 1'b1) |=> (pause_quanta_val == 1'b1)
    );

    // pause_quanta_val is cleared on the next cycle after a pause value pulse.
    check_pause_quanta_val_clears_after_pause_value_pulse: assert property (
        @(posedge Clk) disable iff (Reset)
        (pause_quanta_val_tmp == 1'b0) |=> (pause_quanta_val == 1'b0)
    );

    // pause_quanta_val is cleared on the next cycle after an OK end syn wait.
    check_pause_quanta_val_clears_after_ok_end_syn_wait: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |=> (pause_quanta_val == 1'b0)
    );

    // pause_quanta_val is cleared on the next cycle after a pause value pulse.
    check_pause_quanta_val_clears_after_pause_value_pulse: assert property (
        @(posedge Clk) disable iff (Reset)
        (pause_quanta_val_tmp == 1'b1) |=> (pause_quanta_val == 1'b1)
    );

    // pause_quanta_val is cleared on the next cycle after an OK end syn wait.
    check_pause_quanta_val_clears_after_ok_end_syn_wait: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |=> (pause_quanta_val == 1'b0)
    );

    // pause_quanta_val is cleared on the next cycle after a pause value pulse.
    check_pause_quanta_val_clears_after_pause_value_pulse: assert property (
        @(posedge Clk) disable iff (Reset)
        (pause_quanta_val_tmp == 1'b1) |=> (pause_quanta_val == 1'b1)
    );

    // pause_quanta_val is cleared on the next cycle after an OK end syn wait.
    check_pause_quanta_val_clears_after_ok_end_syn_wait: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |=> (pause_quanta_val == 1'b0)
    );

endmodule