module eth_txcounters_sva (
    input logic MTxClk,
    input logic Reset,
    input logic StatePreamble,
    input logic StateIPG,
    input logic [1:0] StateData,
    input logic StatePAD,
    input logic StateFCS,
    input logic StateJam,
    input logic StateBackOff,
    input logic StateDefer,
    input logic StateIdle,
    input logic StartDefer,
    input logic StartIPG,
    input logic StartFCS,
    input logic StartJam,
    input logic StartBackoff,
    input logic TxStartFrm,
    input logic [15:0] MinFL,
    input logic [15:0] MaxFL,
    input logic HugEn,
    input logic ExDfrEn,
    input logic PacketFinished_q,
    input logic DlyCrcEn,
    input logic StateSFD,
    input logic [15:0] ByteCnt,
    input logic [15:0] NibCnt,
    input logic ExcessiveDefer,
    input logic NibCntEq7,
    input logic NibCntEq15,
    input logic MaxFrame,
    input logic NibbleMinFl,
    input logic [2:0] DlyCrcCnt
);

// Reset clears all counters and status flags.
    check_reset_clears_state: assert property (
        @(posedge MTxClk) Reset |-> (NibCnt == 16'h0) &&
                                 (ByteCnt == 16'h0) &&
                                 (DlyCrcCnt == 3'h0) &&
                                 (ExcessiveDefer == 1'b0) &&
                                 (NibCntEq7 == 1'b0) &&
                                 (NibCntEq15 == 1'b0) &&
                                 (MaxFrame == 1'b0) &&
                                 (NibbleMinFl == 1'b0)
    );

// Nibble counter increments on IPG, preamble, data, PAD, FCS, or jam states.
    check_nibble_increment_states: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateIPG | StatePreamble | (|StateData) | StatePAD | StateFCS | StateJam) |=> (NibCnt == ($past(NibCnt) + 16'd1))
    );

// Nibble counter increments on backoff when defer is not excessive and TxStartFrm is high.
    check_nibble_increment_backoff: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateBackOff & ~ExcessiveDefer & TxStartFrm) |=> (NibCnt == ($past(NibCnt) + 16'd1))
    );

// Nibble counter resets on defer with excessive deferral and TxStartFrm low.
    check_nibble_reset_excessive_defer: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateDefer & ExcessiveDefer & ~TxStartFrm) |=> (NibCnt == 16'h0)
    );

// Nibble counter resets on preamble at nibble 15.
    check_nibble_reset_preamble_at_15: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StatePreamble & NibCntEq15) |=> (NibCnt == 16'h0)
    );

// Nibble counter resets on jam at nibble 7.
    check_nibble_reset_jam_at_7: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateJam & NibCntEq7) |=> (NibCnt == 16'h0)
    );

// Nibble counter resets on idle.
    check_nibble_reset_idle: assert property (
        @(posedge MTxClk) disable iff (Reset)
        StateIdle |=> (NibCnt == 16'h0)
    );

// Nibble counter resets on start defer.
    check_nibble_reset_start_defer: assert property (
        @(posedge MTxClk) disable iff (Reset)
        StartDefer |=> (NibCnt == 16'h0)
    );

// Nibble counter resets on start IPG.
    check_nibble_reset_start_ipg: assert property (
        @(posedge MTxClk) disable iff (Reset)
        StartIPG |=> (NibCnt == 16'h0)
    );

// Nibble counter resets on start FCS.
    check_nibble_reset_start_fcs: assert property (
        @(posedge MTxClk) disable iff (Reset)
        StartFCS |=> (NibCnt == 16'h0)
    );

// Nibble counter resets on start jam.
    check_nibble_reset_start_jam: assert property (
        @(posedge MTxClk) disable iff (Reset)
        StartJam |=> (NibCnt == 16'h0)
    );

// Excessive defer flag is asserted when the counter reaches 6071 nibbles and excessive deferral is disabled.
    check_excessive_defer_flag: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (NibCnt == 16'h17b7) && !ExDfrEn |=> (ExcessiveDefer == 1'b1)
    );

// Excessive defer flag is cleared when the counter leaves 6071 nibbles or excessive deferral is enabled.
    check_excessive_defer_clear: assert property (
        @(posedge MTxClk) disable iff (Reset)
        ((NibCnt != 16'h17b7) || ExDfrEn) |=> (ExcessiveDefer == 1'b0)
    );

// Nibble counter reaches 15 when the previous nibble count was 14 and the current state is not defer.
    check_nibble_eq15_from_14: assert property (
        @(posedge MTxClk) disable iff (Reset)
        ($past(StateDefer) == 1'b0) && ($past(NibCnt) == 16'd14) && (StateDefer == 1'b0) |=> (NibCntEq15 == 1'b1)
    );

// Nibble counter reaches 7 when the previous nibble count was 6 and the current state is not defer.
    check_nibble_eq7_from_6: assert property (
        @(posedge MTxClk) disable iff (Reset)
        ($past(StateDefer) == 1'b0) && ($past(NibCnt) == 16'd6) && (StateDefer == 1'b0) |=> (NibCntEq7 == 1'b1)
    );

// Nibble counter does not reach 7 when the previous nibble count was 6 and the current state is defer.
    check_nibble_not_eq7_from_6_defer: assert property (
        @(posedge MTxClk) disable iff (Reset)
        ($past(StateDefer) == 1'b1) && ($past(NibCnt) == 16'd6) && (StateDefer == 1'b1) |=> (NibCntEq7 == 1'b0)
    );

// Nibble counter does not reach 15 when the previous nibble count was 14 and the current state is defer.
    check_nibble_not_eq15_from_14_defer: assert property (
        @(posedge MTxClk) disable iff (Reset)
        ($past(StateDefer) == 1'b1) && ($past(NibCnt) == 16'd14) && (StateDefer == 1'b1) |=> (NibCntEq15 == 1'b0)
    );

// Maximum frame flag is asserted when ByteCnt equals MaxFL and hugen is disabled.
    check_max_frame_flag: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (ByteCnt == MaxFL) && !HugEn |=> (MaxFrame == 1'b1)
    );

// Maximum frame flag is cleared when ByteCnt is not equal to MaxFL or hugen is enabled.
    check_max_frame_clear: assert property (
        @(posedge MTxClk) disable iff (Reset)
        ((ByteCnt != MaxFL) || HugEn) |=> (MaxFrame == 1'b0)
    );

// NibbleMinFl is asserted when NibCnt is greater than or equal to the minimum frame length (minus FCS).
    check_nibble_minfl_assert: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (NibCnt >= (((MinFL - 16'd4) << 1) - 1)) |=> (NibbleMinFl == 1'b1)
    );

// NibbleMinFl is cleared when NibCnt is less than the minimum frame length (minus FCS).
    check_nibble_minfl_clear: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (NibCnt < (((MinFL - 16'd4) << 1) - 1)) |=> (NibbleMinFl == 1'b0)
    );

// Delayed CRC counter increments on SFD or data nibble with CRC enabled.
    check_dlycrc_increment_states: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateSFD | (StateData[1] & DlyCrcEn)) |=> (DlyCrcCnt == ($past(DlyCrcCnt) + 3'd1))
    );

// Delayed CRC counter resets on data nibble 4 with CRC enabled.
    check_dlycrc_reset_data4: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateData[1] & DlyCrcEn & (DlyCrcCnt == 3'h4)) |=> (DlyCrcCnt == 3'h0)
    );

// Delayed CRC counter resets on jam.
    check_dlycrc_reset_jam: assert property (
        @(posedge MTxClk) disable iff (Reset)
        StateJam |=> (DlyCrcCnt == 3'h0)
    );

// Delayed CRC counter resets on packet finish.
    check_dlycrc_reset_packet_finish: assert property (
        @(posedge MTxClk) disable iff (Reset)
        PacketFinished_q |=> (DlyCrcCnt == 3'h0)
    );

// Delayed CRC counter holds its value when no reset or increment condition is met.
    check_dlycrc_hold_when_idle: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (!StateSFD && !StateData[1] && (DlyCrcCnt != 3'h4) && !PacketFinished_q && !DlyCrcEn) |=> (DlyCrcCnt == $past(DlyCrcCnt))
    );

endmodule
