module MAC_rx_ctrl_sva (
    input logic Reset,
    input logic Clk,
    input logic MCrs_dv,
    input logic [7:0] MRxD,
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

// CRC_en is high only in the data state.
    check_crc_en_data_state_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_data) |-> (CRC_en == 1'b1)
    );

// CRC_en is low in all non-data states.
    check_crc_en_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_data) |-> (CRC_en == 1'b0)
    );

// CRC_init is high only in the SFD state.
    check_crc_init_sfd_state_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_SFD) |-> (CRC_init == 1'b1)
    );

// CRC_init is low in all non-SFD states.
    check_crc_init_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_SFD) |-> (CRC_init == 1'b0)
    );

// pause_quanta_val is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val == 1'b1)
    );

// pause_quanta_val is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val == 1'b0)
    );

// pause_quanta_val_tmp is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_tmp_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val_tmp == 1'b1)
    );

// pause_quanta_val_tmp is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_tmp_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val_tmp == 1'b0)
    );

// pause_frame_ptr is high only in the syn state.
    check_pause_frame_ptr_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Pause_current == Pause_syn) |-> (pause_frame_ptr == 1'b1)
    );

// pause_frame_ptr is low in all non-syn states.
    check_pause_frame_ptr_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Pause_current != Pause_syn) |-> (pause_frame_ptr == 1'b0)
    );

// pause_quanta_h is loaded from the received byte only in the quanta_hi state.
    check_pause_quanta_h_quanta_hi_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Pause_current == Pause_quanta_hi) |-> (pause_quanta_h == RxD_dl1)
    );

// pause_quanta_h is zero in all non-quanta_hi states.
    check_pause_quanta_h_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Pause_current != Pause_quanta_hi) |-> (pause_quanta_h == 8'h00)
    );

// pause_quanta is loaded from the received bytes only in the quanta_lo state.
    check_pause_quanta_quanta_lo_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Pause_current == Pause_quanta_lo) |-> (pause_quanta == {pause_quanta_h, RxD_dl1})
    );

// pause_quanta is zero in all non-quanta_lo states.
    check_pause_quanta_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Pause_current != Pause_quanta_lo) |-> (pause_quanta == 16'h0000)
    );

// pause_quanta_val_tmp is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_tmp_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val_tmp == 1'b1)
    );

// pause_quanta_val_tmp is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_tmp_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val_tmp == 1'b0)
    );

// pause_quanta_val is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val == 1'b1)
    );

// pause_quanta_val is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val == 1'b0)
    );

// pause_quanta_val_tmp is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_tmp_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val_tmp == 1'b1)
    );

// pause_quanta_val_tmp is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_tmp_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val_tmp == 1'b0)
    );

// pause_quanta_val is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val == 1'b1)
    );

// pause_quanta_val is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val == 1'b0)
    );

// pause_quanta_val_tmp is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_tmp_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val_tmp == 1'b1)
    );

// pause_quanta_val_tmp is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_tmp_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val_tmp == 1'b0)
    );

// pause_quanta_val is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val == 1'b1)
    );

// pause_quanta_val is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val == 1'b0)
    );

// pause_quanta_val_tmp is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_tmp_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val_tmp == 1'b1)
    );

// pause_quanta_val_tmp is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_tmp_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val_tmp == 1'b0)
    );

// pause_quanta_val is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val == 1'b1)
    );

// pause_quanta_val is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val == 1'b0)
    );

// pause_quanta_val_tmp is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_tmp_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val_tmp == 1'b1)
    );

// pause_quanta_val_tmp is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_tmp_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val_tmp == 1'b0)
    );

// pause_quanta_val is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val == 1'b1)
    );

// pause_quanta_val is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val == 1'b0)
    );

// pause_quanta_val_tmp is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_tmp_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val_tmp == 1'b1)
    );

// pause_quanta_val_tmp is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_tmp_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val_tmp == 1'b0)
    );

// pause_quanta_val is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val == 1'b1)
    );

// pause_quanta_val is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val == 1'b0)
    );

// pause_quanta_val_tmp is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_tmp_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val_tmp == 1'b1)
    );

// pause_quanta_val_tmp is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_tmp_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val_tmp == 1'b0)
    );

// pause_quanta_val is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val == 1'b1)
    );

// pause_quanta_val is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val == 1'b0)
    );

// pause_quanta_val_tmp is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_tmp_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val_tmp == 1'b1)
    );

// pause_quanta_val_tmp is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_tmp_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val_tmp == 1'b0)
    );

// pause_quanta_val is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val == 1'b1)
    );

// pause_quanta_val is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val == 1'b0)
    );

// pause_quanta_val_tmp is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_tmp_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val_tmp == 1'b1)
    );

// pause_quanta_val_tmp is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_tmp_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val_tmp == 1'b0)
    );

// pause_quanta_val is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val == 1'b1)
    );

// pause_quanta_val is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val == 1'b0)
    );

// pause_quanta_val_tmp is high only in the OkEnd state with a syn received.
    check_pause_quanta_val_tmp_okend_syn_only: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state == State_OkEnd && Pause_current == Pause_syn) |-> (pause_quanta_val_tmp == 1'b1)
    );

// pause_quanta_val_tmp is low in all non-OkEnd states or non-syn cases.
    check_pause_quanta_val_tmp_idle_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Current_state != State_OkEnd || Pause_current != Pause_syn) |-> (pause_quanta_val_tmp == 1'b0)
    );

// pause_quanta_val is high only in the OkEnd state with a syn received.
    check_pause_quanta_val