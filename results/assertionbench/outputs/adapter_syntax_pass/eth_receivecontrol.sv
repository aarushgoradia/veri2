module eth_receivecontrol_sva (
    input logic MTxClk,
    input logic MRxClk,
    input logic TxReset,
    input logic RxReset,
    input logic [7:0] RxData,
    input logic RxValid,
    input logic RxStartFrm,
    input logic RxEndFrm,
    input logic RxFlow,
    input logic ReceiveEnd,
    input logic [47:0] MAC,
    input logic DlyCrcEn,
    input logic TxDoneIn,
    input logic TxAbortIn,
    input logic TxStartFrmOut,
    input logic ReceivedLengthOK,
    input logic ReceivedPacketGood,
    input logic TxUsedDataOutDetected,
    input logic RxStatusWriteLatched_sync2,
    input logic r_PassAll,
    input logic Pause,
    input logic ReceivedPauseFrm,
    input logic AddressOK,
    input logic SetPauseTimer,
    input logic PauseTimerEq0_sync1,
    input logic PauseTimerEq0_sync2,
    input logic [15:0] PauseTimer,
    input logic Divider2,
    input logic [5:0] SlotTimer
);

    // PauseTimerEq0_sync1 is the first synchronizer stage.
    check_pause_eq0_sync1: assert property (
        @(posedge MTxClk) disable iff (TxReset)
        1'b1 |=> (PauseTimerEq0_sync1 == $past(PauseTimerEq0))
    );

    // PauseTimerEq0_sync2 is the second synchronizer stage.
    check_pause_eq0_sync2: assert property (
        @(posedge MTxClk) disable iff (TxReset)
        1'b1 |=> (PauseTimerEq0_sync2 == $past(PauseTimerEq0_sync1))
    );

    // Pause is cleared whenever the transmitter is active or the data path is idle.
    check_pause_clear_conditions: assert property (
        @(posedge MTxClk) disable iff (TxReset)
        1'b1 |=> (Pause == ($past(TxDoneIn | TxAbortIn | ~TxUsedDataOutDetected) | ~TxStartFrmOut))
    );

    // Pause is set when flow control is enabled and the pause timer is non-zero.
    check_pause_set_condition: assert property (
        @(posedge MTxClk) disable iff (TxReset)
        1'b1 |=> (Pause == ($past(RxFlow & ~PauseTimerEq0_sync2)))
    );

    // Pause is never asserted when the pause timer is zero.
    check_pause_never_when_timer_zero: assert property (
        @(posedge MTxClk) disable iff (TxReset)
        1'b1 |=> (Pause == ($past(RxFlow & ~PauseTimerEq0_sync2) & ~PauseTimerEq0_sync1))
    );

    // Pause is never asserted when flow control is disabled.
    check_pause_never_when_flow_disabled: assert property (
        @(posedge MTxClk) disable iff (TxReset)
        1'b1 |=> (Pause == ($past(RxFlow & ~PauseTimerEq0_sync2) & ~PauseTimerEq0_sync1 & ~~RxFlow))
    );

    // Divider2 is cleared whenever the pause timer is zero or flow control is disabled.
    check_divider2_clear_conditions: assert property (
        @(posedge MRxClk) disable iff (RxReset)
        1'b1 |=> (Divider2 == ($past(|PauseTimer[15:0] & RxFlow) & ~PauseTimerEq0_sync1))
    );

    // Divider2 is set whenever the pause timer is non-zero and flow control is enabled.
    check_divider2_set_condition: assert property (
        @(posedge MRxClk) disable iff (RxReset)
        1'b1 |=> (Divider2 == ($past(|PauseTimer[15:0] & RxFlow) & ~PauseTimerEq0_sync1 & ~PauseTimerEq0_sync2))
    );

    // SlotTimer is cleared whenever the pause timer is zero or flow control is disabled.
    check_slot_timer_clear_conditions: assert property (
        @(posedge MRxClk) disable iff (RxReset)
        1'b1 |=> (SlotTimer == ($past(ResetSlotTimer) | ~PauseTimerEq0_sync1))
    );

    // SlotTimer increments whenever the divider is high and flow control is enabled.
    check_slot_timer_increment_condition: assert property (
        @(posedge MRxClk) disable iff (RxReset)
        1'b1 |=> (SlotTimer == ($past(ResetSlotTimer) | ~PauseTimerEq0_sync1 | ($past(IncrementSlotTimer) & ~PauseTimerEq0_sync2)))
    );

    // SlotTimer is never incremented when the pause timer is zero.
    check_slot_timer_never_when_timer_zero: assert property (
        @(posedge MRxClk) disable iff (RxReset)
        1'b1 |=> (SlotTimer == ($past(ResetSlotTimer) | ~PauseTimerEq0_sync1 | ($past(IncrementSlotTimer) & ~PauseTimerEq0_sync2 & ~PauseTimerEq0_sync1)))
    );

    // SlotTimer is never incremented when flow control is disabled.
    check_slot_timer_never_when_flow_disabled: assert property (
        @(posedge MRxClk) disable iff (RxReset)
        1'b1 |=> (SlotTimer == ($past(ResetSlotTimer) | ~PauseTimerEq0_sync1 | ($past(IncrementSlotTimer) & ~PauseTimerEq0_sync2 & ~PauseTimerEq0_sync1 & ~~RxFlow)))
    );

    // SlotTimer is never incremented when the divider is low.
    check_slot_timer_never_when_divider_low: assert property (
        @(posedge MRxClk) disable iff (RxReset)
        1'b1 |=> (SlotTimer == ($past(ResetSlotTimer) | ~PauseTimerEq0_sync1 | ($past(IncrementSlotTimer) & ~PauseTimerEq0_sync2 & ~PauseTimerEq0_sync1 & ~~RxFlow & ~Divider2)))
    );

    // ReceivedPauseFrm is cleared whenever the pause frame is masked or the packet is rejected.
    check_pause_frame_clear_conditions: assert property (
        @(posedge MRxClk) disable iff (RxReset)
        1'b1 |=> (ReceivedPauseFrm == ($past(RxStatusWriteLatched_sync2 & r_PassAll) | ~$past(r_PassAll)))
    );

    // ReceivedPauseFrm is set when the Type/Length field matches 0x8808.
    check_pause_frame_set_condition: assert property (
        @(posedge MRxClk) disable iff (RxReset)
        1'b1 |=> (ReceivedPauseFrm == ($past(RxStatusWriteLatched_sync2 & r_PassAll) | ~$past(r_PassAll) | ($past(ByteCntEq12) & ($past(RxData[7:0]) == 8'h88) & $past(TypeLengthOK))))
    );

endmodule