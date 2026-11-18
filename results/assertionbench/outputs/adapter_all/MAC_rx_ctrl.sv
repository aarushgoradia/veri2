module MAC_rx_ctrl_sva (
    input logic        Reset,
    input logic        Clk,
    input logic        MCrs_dv,
    input logic        MRxD,
    input logic        MRxErr,
    input logic        CRC_en,
    input logic        CRC_init,
    input logic        CRC_err,
    input logic        MAC_add_en,
    input logic        MAC_rx_add_chk_err,
    input logic        broadcast_ptr,
    input logic        broadcast_drop,
    input logic [15:0] pause_quanta,
    input logic        pause_quanta_val,
    input logic [7:0]  Fifo_data,
    input logic        Fifo_data_en,
    input logic        Fifo_data_err,
    input logic        Fifo_data_end,
    input logic        Fifo_full,
    input logic        Rx_apply_rmon,
    input logic [2:0]  Rx_pkt_err_type_rmon,
    input logic [2:0]  Rx_pkt_type_rmon,
    input logic [5:0]  RX_IFG_SET,
    input logic [15:0] RX_MAX_LENGTH,
    input logic [6:0]  RX_MIN_LENGTH
);

    ///// CRC control /////
    // CRC_en is asserted only in State_data.
    check_crc_en_state: assert property (
        @(posedge Clk) disable iff (Reset)
        CRC_en |-> (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_data)
    );

    // CRC_init is asserted only in State_SFD.
    check_crc_init_state: assert property (
        @(posedge Clk) disable iff (Reset)
        CRC_init |-> (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_SFD)
    );

    ///// FIFO control /////
    // Fifo_data_en is asserted only in State_data.
    check_fifo_en_state: assert property (
        @(posedge Clk) disable iff (Reset)
        Fifo_data_en |-> (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_data)
    );

    // Fifo_data_end is asserted only in error/end states.
    check_fifo_end_state: assert property (
        @(posedge Clk) disable iff (Reset)
        Fifo_data_end |-> (
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_ErrEnd) ||
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_OkEnd) ||
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_CRCErrEnd) ||
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_FFFullErrEnd)
        )
    );

    // Fifo_data_err is asserted only in error/end states.
    check_fifo_err_state: assert property (
        @(posedge Clk) disable iff (Reset)
        Fifo_data_err |-> (
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_ErrEnd) ||
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_CRCErrEnd) ||
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_FFFullErrEnd)
        )
    );

    ///// RMON status /////
    // Rx_apply_rmon is asserted only in error/end states.
    check_rmon_apply_state: assert property (
        @(posedge Clk) disable iff (Reset)
        Rx_apply_rmon |-> (
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_ErrEnd) ||
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_OkEnd) ||
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_CRCErrEnd) ||
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_FFFullErrEnd)
        )
    );

    // Rx_pkt_err_type_rmon encodes error/end state.
    check_rmon_err_type_state: assert property (
        @(posedge Clk) disable iff (Reset)
        (Rx_pkt_err_type_rmon == 3'b001) |-> (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_CRCErrEnd)
    );
    check_rmon_err_type_state_fffull: assert property (
        @(posedge Clk) disable iff (Reset)
        (Rx_pkt_err_type_rmon == 3'b010) |-> (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_FFFullErrEnd)
    );
    check_rmon_err_type_state_err: assert property (
        @(posedge Clk) disable iff (Reset)
        (Rx_pkt_err_type_rmon == 3'b011) |-> (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_ErrEnd)
    );
    check_rmon_err_type_state_ok: assert property (
        @(posedge Clk) disable iff (Reset)
        (Rx_pkt_err_type_rmon == 3'b100) |-> (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_OkEnd)
    );

    // Rx_pkt_type_rmon encodes broadcast and pause-frame types.
    check_rmon_pkt_type_broadcast: assert property (
        @(posedge Clk) disable iff (Reset)
        (Rx_pkt_type_rmon == 3'b100) |-> (
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_SFD) &&
            (MAC_rx_ctrl.Next_state == MAC_rx_ctrl.State_data) &&
            (MRxD[7:6] == 2'b11)
        )
    );
    check_rmon_pkt_type_pause: assert property (
        @(posedge Clk) disable iff (Reset)
        (Rx_pkt_type_rmon == 3'b000) |-> (
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_OkEnd) &&
            (MAC_rx_ctrl.pause_frame_ptr == 1'b1)
        )
    );
    check_rmon_pkt_type_pause_default: assert property (
        @(posedge Clk) disable iff (Reset)
        (Rx_pkt_type_rmon == 3'b000) |-> (
            (MAC_rx_ctrl.State_current != MAC_rx_ctrl.State_OkEnd) ||
            (MAC_rx_ctrl.pause_frame_ptr != 1'b1)
        )
    );

    ///// Broadcast filter /////
    // broadcast_ptr is cleared in IFG and set on broadcast SFD.
    check_broadcast_ptr_state: assert property (
        @(posedge Clk) disable iff (Reset)
        (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_IFG) |-> (broadcast_ptr == 1'b0)
    );
    check_broadcast_ptr_broadcast: assert property (
        @(posedge Clk) disable iff (Reset)
        (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_SFD) &&
        (MAC_rx_ctrl.Next_state == MAC_rx_ctrl.State_data) &&
        (MRxD[7:6] == 2'b11) |-> (broadcast_ptr == 1'b1)
    );
    check_broadcast_ptr_default: assert property (
        @(posedge Clk) disable iff (Reset)
        !((
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_SFD) &&
            (MAC_rx_ctrl.Next_state == MAC_rx_ctrl.State_data) &&
            (MRxD[7:6] == 2'b11)
        )) |-> (broadcast_ptr == 1'b0)
    );

    ///// Pause control /////
    // pause_quanta_val is asserted only in OkEnd with syn pause state.
    check_pause_val_state: assert property (
        @(posedge Clk) disable iff (Reset)
        pause_quanta_val |-> (
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_OkEnd) &&
            (MAC_rx_ctrl.Pause_current == MAC_rx_ctrl.Pause_syn)
        )
    );

    // pause_quanta_val can only be high for one cycle.
    check_pause_val_single_cycle: assert property (
        @(posedge Clk) disable iff (Reset)
        pause_quanta_val |=> !pause_quanta_val
    );

    // pause_quanta_val is a single-cycle pulse.
    check_pause_val_pulse: assert property (
        @(posedge Clk) disable iff (Reset)
        pause_quanta_val |-> ##1 !pause_quanta_val
    );

    ///// Pause FSM /////
    // Pause_idle only transitions from State_SFD.
    check_pause_idle_transition: assert property (
        @(posedge Clk) disable iff (Reset)
        (MAC_rx_ctrl.Pause_current == MAC_rx_ctrl.Pause_idle) |-> (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_SFD)
    );

    // Pause_pre_syn only occurs at specific frame_length_counter values.
    check_pause_pre_syn_transition: assert property (
        @(posedge Clk) disable iff (Reset)
        (MAC_rx_ctrl.Pause_current == MAC_rx_ctrl.Pause_pre_syn) |-> (
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_SFD) &&
            (
                (MAC_rx_ctrl.Frame_length_counter == 16'd1 && RxD == 8'h01) ||
                (MAC_rx_ctrl.Frame_length_counter == 16'd2 && RxD == 8'h80) ||
                (MAC_rx_ctrl.Frame_length_counter == 16'd3 && RxD == 8'hc2) ||
                (MAC_rx_ctrl.Frame_length_counter == 16'd4 && RxD == 8'h00) ||
                (MAC_rx_ctrl.Frame_length_counter == 16'd5 && RxD == 8'h00) ||
                (MAC_rx_ctrl.Frame_length_counter == 16'd6 && RxD == 8'h01) ||
                (MAC_rx_ctrl.Frame_length_counter == 16'd13 && RxD == 8'h88) ||
                (MAC_rx_ctrl.Frame_length_counter == 16'd14 && RxD == 8'h08) ||
                (MAC_rx_ctrl.Frame_length_counter == 16'd15 && RxD == 8'h00) ||
                (MAC_rx_ctrl.Frame_length_counter == 16'd16 && RxD == 8'h01)
            )
        )
    );

    // Pause_quanta_hi only occurs at frame_length_counter 16.
    check_pause_quanta_hi_transition: assert property (
        @(posedge Clk) disable iff (Reset)
        (MAC_rx_ctrl.Pause_current == MAC_rx_ctrl.Pause_quanta_hi) |-> (
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_SFD) &&
            (MAC_rx_ctrl.Frame_length_counter == 16'd16)
        )
    );

    // Pause_quanta_lo only occurs after Pause_quanta_hi.
    check_pause_quanta_lo_transition: assert property (
        @(posedge Clk) disable iff (Reset)
        (MAC_rx_ctrl.Pause_current == MAC_rx_ctrl.Pause_quanta_lo) |-> (
            (MAC_rx_ctrl.Pause_previous == MAC_rx_ctrl.Pause_quanta_hi)
        )
    );

    // Pause_syn only occurs after Pause_quanta_lo or when IFG is done.
    check_pause_syn_transition: assert property (
        @(posedge Clk) disable iff (Reset)
        (MAC_rx_ctrl.Pause_current == MAC_rx_ctrl.Pause_syn) |-> (
            (MAC_rx_ctrl.Pause_previous == MAC_rx_ctrl.Pause_quanta_lo) ||
            (MAC_rx_ctrl.State_current == MAC_rx_ctrl.State_IFG) &&
            (MAC_rx_ctrl.IFG_counter == RX_IFG_SET - 4'd4)
        )
    );

    // Pause_idle is the only terminal state.
    check_pause_idle_terminal: assert property (
        @(posedge Clk) disable iff (Reset)
        (MAC_rx_ctrl.Pause_current == MAC_rx_ctrl.Pause_idle) |-> (MAC_rx_ctrl.Pause_next == MAC_rx_ctrl.Pause_idle)
    );

    // Pause_pre_syn only transitions to Pause_idle or Pause_idle.
    check_pause_pre_syn_terminal: assert property (
        @(posedge Clk) disable iff (Reset)
        (MAC_rx_ctrl.Pause_current == MAC_rx_ctrl.Pause_pre_syn) |-> (
            (MAC_rx_ctrl.Pause_next == MAC_rx_ctrl.Pause_idle) ||
            (MAC_rx_ctrl.Pause_next == MAC_rx_ctrl.Pause_idle)
        )
    );

    // Pause_quanta_hi only transitions to Pause_quanta_lo.
    check_pause_quanta_hi_terminal: assert property (
        @(posedge Clk) disable iff (Reset)
        (MAC_rx_ctrl.Pause_current == MAC_rx_ctrl.Pause_quanta_hi) |-> (
            (MAC_rx_ctrl.Pause_next == MAC_rx_ctrl.Pause_quanta_lo)
        )
    );

    // Pause_quanta_lo only transitions to Pause_syn.
    check_pause_quanta_lo_terminal: assert property (
        @(posedge Clk) disable iff (Reset)
        (MAC_rx_ctrl.Pause_current == MAC_rx_ctrl.Pause_quanta_lo) |-> (
            (MAC_rx_ctrl.Pause_next == MAC_rx_ctrl.Pause_syn)
        )
    );

    // Pause_syn only transitions to Pause_idle or Pause_idle.
    check_pause_syn_terminal: assert property (
        @(posedge Clk) disable iff (Reset)
        (MAC_rx_ctrl.Pause_current == MAC_rx_ctrl.Pause_syn) |-> (
            (MAC_rx_ctrl.Pause_next == MAC_rx_ctrl.Pause_idle) ||
            (MAC_rx_ctrl.Pause_next == MAC_rx_ctrl.Pause_idle)
        )
    );

endmodule