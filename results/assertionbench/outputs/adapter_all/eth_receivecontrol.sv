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
    input logic DecrementPauseTimer,
    input logic PauseTimerEq0,
    input logic PauseTimerEq0_sync1,
    input logic PauseTimerEq0_sync2,
    input logic [15:0] PauseTimer,
    input logic Divider2,
    input logic [5:0] SlotTimer,
    input logic ByteCntEq0,
    input logic ByteCntEq1,
    input logic ByteCntEq2,
    input logic ByteCntEq3,
    input logic ByteCntEq4,
    input logic ByteCntEq5,
    input logic ByteCntEq12,
    input logic ByteCntEq13,
    input logic ByteCntEq14,
    input logic ByteCntEq15,
    input logic ByteCntEq16,
    input logic ByteCntEq17,
    input logic ByteCntEq18,
    input logic ResetByteCnt,
    input logic IncrementByteCnt,
    input logic ByteCntEq18_sync,
    input logic ResetSlotTimer,
    input logic IncrementSlotTimer,
    input logic SlotFinished,
    input logic [15:0] AssembledTimerValue,
    input logic [15:0] LatchedTimerValue,
    input logic ReceivedPauseFrmWAddr,
    input logic TypeLengthOK,
    input logic OpCodeOK,
    input logic DetectionWindow,
    input logic [2:0] DlyCrcCnt
);
    // Reset drives all sequential regs low by the next MRxClk edge.
    reset_clears_regs: assert property (
        @(posedge MRxClk) RxReset |=> (AddressOK == 1'b0 && TypeLengthOK == 1'b0 && OpCodeOK == 1'b0 &&
                                      ReceivedPauseFrmWAddr == 1'b0 && AssembledTimerValue == 16'h0000 &&
                                      LatchedTimerValue == 16'h0000 && ByteCnt == 5'h0 && DetectionWindow == 1'b1 &&
                                      PauseTimer == 16'h0000 && Divider2 == 1'b0 && SlotTimer == 6'h0 &&
                                      ReceivedPauseFrm == 1'b0 && ReceivedPauseFrmWAddr == 1'b0 &&
                                      SetPauseTimer == 1'b0 && DecrementPauseTimer == 1'b0 &&
                                      PauseTimerEq0 == 1'b1 && PauseTimerEq0_sync1 == 1'b1 &&
                                      PauseTimerEq0_sync2 == 1'b1 && Pause == 1'b0)
    );

    // Reset drives all sequential regs low by the next MTxClk edge.
    reset_clears_regs_mt: assert property (
        @(posedge MTxClk) TxReset |=> (PauseTimerEq0 == 1'b1 && PauseTimerEq0_sync1 == 1'b1 &&
                                       PauseTimerEq0_sync2 == 1'b1 && Pause == 1'b0)
    );

    // ReceivedPauseFrmWAddr is a one-cycle pulse.
    pausefrmwaddr_one_cycle: assert property (
        @(posedge MRxClk) disable iff (RxReset) $rose(ReceivedPauseFrmWAddr) |-> !ReceivedPauseFrmWAddr
    );

    // ReceivedPauseFrm is a one-cycle pulse.
    pausefrm_one_cycle: assert property (
        @(posedge MRxClk) disable iff (RxReset) $rose(ReceivedPauseFrm) |-> !ReceivedPauseFrm
    );

    // ReceivedPauseFrmWAddr implies ReceivedPauseFrm.
    pausefrmwaddr_implies_pausefrm: assert property (
        @(posedge MRxClk) disable iff (RxReset) ReceivedPauseFrmWAddr |-> ReceivedPauseFrm
    );

    // ReceivedPauseFrm implies AddressOK, TypeLengthOK, and OpCodeOK.
    pausefrm_implies_conditions: assert property (
        @(posedge MRxClk) disable iff (RxReset) ReceivedPauseFrm |-> (AddressOK && TypeLengthOK && OpCodeOK)
    );

    // ReceivedPauseFrmWAddr implies AddressOK, TypeLengthOK, and OpCodeOK.
    pausefrmwaddr_implies_conditions: assert property (
        @(posedge MRxClk) disable iff (RxReset) ReceivedPauseFrmWAddr |-> (AddressOK && TypeLengthOK && OpCodeOK)
    );

    // ReceivedPauseFrm is gated by r_PassAll on RxStatusWriteLatched_sync2.
    pausefrm_gated_by_passall: assert property (
        @(posedge MRxClk) disable iff (RxReset) (RxStatusWriteLatched_sync2 && !r_PassAll) |-> !ReceivedPauseFrm
    );

    // ReceivedPauseFrm is gated by r_PassAll on ReceivedPauseFrmWAddr.
    pausefrm_gated_by_passall_waddr: assert property (
        @(posedge MRxClk) disable iff (RxReset) (ReceivedPauseFrmWAddr && !r_PassAll) |-> !ReceivedPauseFrm
    );

    // ReceivedPauseFrm is gated by r_PassAll on ReceivedPauseFrm.
    pausefrm_gated_by_passall_pausefrm: assert property (
        @(posedge MRxClk) disable iff (RxReset) (ReceivedPauseFrm && !r_PassAll) |-> !ReceivedPauseFrm
    );

    // ReceivedPauseFrm is gated by r_PassAll on ReceivedPauseFrmWAddr.
    pausefrmwaddr_gated_by_passall: assert property (
        @(posedge MRxClk) disable iff (RxReset) (ReceivedPauseFrmWAddr && !r_PassAll) |-> !ReceivedPauseFrmWAddr
    );

    // ReceivedPauseFrm is gated by r_PassAll on ReceivedPauseFrm.
    pausefrm_gated_by_passall_pausefrm: assert property (
        @(posedge MRxClk) disable iff (RxReset) (ReceivedPauseFrm && !r_PassAll) |-> !ReceivedPauseFrm
    );

    // SetPauseTimer is asserted only on ReceiveEnd with valid pause frame conditions.
    setpausetimer_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset) SetPauseTimer == (ReceiveEnd && ReceivedPauseFrmWAddr &&
                                                                  ReceivedPacketGood && ReceivedLengthOK && RxFlow)
    );

    // DecrementPauseTimer is asserted only on SlotFinished with non-zero PauseTimer.
    decrementpausetimer_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset) DecrementPauseTimer == (SlotFinished && !PauseTimerEq0)
    );

    // PauseTimerEq0_sync1 is the registered copy of PauseTimerEq0 from MTxClk.
    pauseeq0_sync1_registered: assert property (
        @(posedge MTxClk) disable iff (TxReset) 1'b1 |=> (PauseTimerEq0_sync1 == $past(PauseTimerEq0))
    );

    // PauseTimerEq0_sync2 is the registered copy of PauseTimerEq0_sync1 from MTxClk.
    pauseeq0_sync2_registered: assert property (
        @(posedge MTxClk) disable iff (TxReset) 1'b1 |=> (PauseTimerEq0_sync2 == $past(PauseTimerEq0_sync1))
    );

    // Pause is the registered copy of Pause logic from MTxClk.
    pause_registered: assert property (
        @(posedge MTxClk) disable iff (TxReset) 1'b1 |=> (Pause == $past(RxFlow & ~PauseTimerEq0_sync2))
    );

    // Divider2 toggles when |PauseTimer[15:0] & RxFlow is true.
    divider2_toggle_on_pause: assert property (
        @(posedge MRxClk) disable iff (RxReset) (|PauseTimer && RxFlow) |=> (Divider2 == ~$past(Divider2))
    );

    // Divider2 holds when |PauseTimer[15:0] & RxFlow is false.
    divider2_hold_without_pause: assert property (
        @(posedge MRxClk) disable iff (RxReset) (!|PauseTimer || !RxFlow) |=> (Divider2 == $past(Divider2))
    );

    // IncrementSlotTimer is asserted only when Pause & RxFlow & Divider2 are true.
    increment_slot_timer_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset) IncrementSlotTimer == (Pause & RxFlow & Divider2)
    );

    // SlotTimer increments only when IncrementSlotTimer is true.
    slottimer_increment_on_condition: assert property (
        @(posedge MRxClk) disable iff (RxReset) IncrementSlotTimer |=> (SlotTimer == $past(SlotTimer) + 6'd1)
    );

    // SlotTimer holds when IncrementSlotTimer is false.
    slottimer_hold_without_condition: assert property (
        @(posedge MRxClk) disable iff (RxReset) !IncrementSlotTimer |=> (SlotTimer == $past(SlotTimer))
    );

    // SlotFinished is asserted only when SlotTimer is all ones and IncrementSlotTimer is true.
    slotfinished_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset) SlotFinished == (&SlotTimer && IncrementSlotTimer)
    );

    // ReceivedPauseFrmWAddr is asserted only when ByteCntEq16, TypeLengthOK, and OpCodeOK are true.
    pausefrmwaddr_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset) ReceivedPauseFrmWAddr == (ByteCntEq16 && TypeLengthOK && OpCodeOK)
    );

    // ReceivedPauseFrm is asserted only when ByteCntEq16, TypeLengthOK, and OpCodeOK are true.
    pausefrm_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset) ReceivedPauseFrm == (ByteCntEq16 && TypeLengthOK && OpCodeOK)
    );

    // AddressOK updates from previous cycle's detection window and ByteCntEq0/1/2/3/4/5.
    addressok_update_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset)
            AddressOK == ($past(DetectionWindow) &&
                          (($past(ByteCntEq0) && ($past(RxData[7:0]) == 8'h01 || $past(RxData[7:0]) == 8'h02)) ||
                           ($past(ByteCntEq1) && ($past(RxData[7:0]) == 8'h03 || $past(RxData[7:0]) == 8'h04)) ||
                           ($past(ByteCntEq2) && ($past(RxData[7:0]) == 8'h05 || $past(RxData[7:0]) == 8'h06)) ||
                           ($past(ByteCntEq3) && ($past(RxData[7:0]) == 8'h07 || $past(RxData[7:0]) == 8'h08)) ||
                           ($past(ByteCntEq4) && ($past(RxData[7:0]) == 8'h09 || $past(RxData[7:0]) == 8'h0A)) ||
                           ($past(ByteCntEq5) && ($past(RxData[7:0]) == 8'h0B || $past(RxData[7:0]) == 8'h0C))))
    );

    // TypeLengthOK updates from previous cycle's detection window and ByteCntEq12/13.
    typelengthok_update_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset)
            TypeLengthOK == ($past(DetectionWindow) &&
                             ($past(ByteCntEq12) && ($past(RxData[7:0]) == 8'h0D || $past(RxData[7:0]) == 8'h0E)) ||
                             ($past(ByteCntEq13) && ($past(RxData[7:0]) == 8'h0F || $past(RxData[7:0]) == 8'h10)))
    );

    // OpCodeOK updates from previous cycle's detection window and ByteCntEq14/15.
    opcodeok_update_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset)
            OpCodeOK == ($past(DetectionWindow) &&
                         ($past(ByteCntEq14) && ($past(RxData[7:0]) == 8'h11 || $past(RxData[7:0]) == 8'h12)) ||
                         ($past(ByteCntEq15) && ($past(RxData[7:0]) == 8'h13 || $past(RxData[7:0]) == 8'h14)))
    );

    // AssembledTimerValue loads RxData[7:0] on ByteCntEq16.
    assembledtimervalue_load_on_16: assert property (
        @(posedge MRxClk) disable iff (RxReset) ByteCntEq16 |=> (AssembledTimerValue[15:8] == $past(RxData[7:0]))
    );

    // AssembledTimerValue loads RxData[7:0] on ByteCntEq17.
    assembledtimervalue_load_on_17: assert property (
        @(posedge MRxClk) disable iff (RxReset) ByteCntEq17 |=> (AssembledTimerValue[7:0] == $past(RxData[7:0]))
    );

    // AssembledTimerValue holds when ByteCntEq16/17 are false.
    assembledtimervalue_hold_without_16_17: assert property (
        @(posedge MRxClk) disable iff (RxReset) !(ByteCntEq16 || ByteCntEq17) |=> (AssembledTimerValue == $past(AssembledTimerValue))
    );

    // LatchedTimerValue loads AssembledTimerValue on ByteCntEq18 with detection window.
    latchedtimervalue_load_on_18: assert property (
        @(posedge MRxClk) disable iff (RxReset)
            (DetectionWindow && ByteCntEq18) |=> (LatchedTimerValue == $past(AssembledTimerValue))
    );

    // LatchedTimerValue holds when ByteCntEq18 is false or detection window is false.
    latchedtimervalue_hold_without_18: assert property (
        @(posedge MRxClk) disable iff (RxReset) !(DetectionWindow && ByteCntEq18) |=> (LatchedTimerValue == $past(LatchedTimerValue))
    );

    // ByteCnt increments on IncrementByteCnt and is reset on ResetByteCnt.
    bytecnt_update_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset)
            1'b1 |=> (ByteCnt == ($past(ResetByteCnt) ? 5'h0 : ($past(IncrementByteCnt) ? $past(ByteCnt) + 5'd1 : $past(ByteCnt))))
    );

    // DetectionWindow is asserted while ByteCnt is 18 and detection window is true.
    detectionwindow_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset) (ByteCntEq18 && DetectionWindow) |-> DetectionWindow
    );

    // DetectionWindow deasserts on ByteCntEq18.
    detectionwindow_deassert_on_18: assert property (
        @(posedge MRxClk) disable iff (RxReset) ByteCntEq18 |=> !DetectionWindow
    );

    // DetectionWindow asserts on ReceiveEnd.
    detectionwindow_assert_on_receiveend: assert property (
        @(posedge MRxClk) disable iff (RxReset) ReceiveEnd |=> DetectionWindow
    );

    // PauseTimer loads LatchedTimerValue on SetPauseTimer.
    pausetimer_load_on_set: assert property (
        @(posedge MRxClk) disable iff (RxReset) SetPauseTimer |=> (PauseTimer == $past(LatchedTimerValue))
    );

    // PauseTimer decrements on DecrementPauseTimer.
    pausetimer_decrement_on_decrement: assert property (
        @(posedge MRxClk) disable iff (RxReset) DecrementPauseTimer |=> (PauseTimer == $past(PauseTimer) - 16'd1)
    );

    // PauseTimer holds when neither load nor decrement is asserted.
    pausetimer_hold_without_load_or_decrement: assert property (
        @(posedge MRxClk) disable iff (RxReset) !(SetPauseTimer || DecrementPauseTimer) |=> (PauseTimer == $past(PauseTimer))
    );

    // PauseTimerEq0 is the inverse of PauseTimer being non-zero.
    pauseeq0_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset) PauseTimerEq0 == ~(|PauseTimer)
    );

    // Divider2 is low when PauseTimer is zero and RxFlow is true.
    divider2_low_when_pause_zero: assert property (
        @(posedge MRxClk) disable iff (RxReset) (|PauseTimer && RxFlow) |=> (Divider2 == 1'b0)
    );

    // Divider2 is high when PauseTimer is zero and RxFlow is false.
    divider2_high_when_pause_zero: assert property (
        @(posedge MRxClk) disable iff (RxReset) (!|PauseTimer || !RxFlow) |=> (Divider2 == 1'b1)
    );

    // IncrementSlotTimer is asserted only when Pause & RxFlow & Divider2 are true.
    increment_slot_timer_definition: assert property (
        @(posedge MRxClk) disable iff (RxReset) IncrementSlotTimer == (Pause & RxFlow & Divider2)
    );

    // SlotTimer increments only when IncrementSlotTimer is true.
    slottimer_increment_on_condition: assert property (
        @(posedge MRxClk) disable iff (RxReset) IncrementSlotTimer |=> (SlotTimer == $past(SlotTimer) + 6'd1)
   