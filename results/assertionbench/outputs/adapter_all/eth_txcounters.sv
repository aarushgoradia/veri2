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

    // Reset clears all counters and state flags.
    check_reset_clears_counters: assert property (
        @(posedge MTxClk)
        Reset |-> ((NibCnt == 16'h0000) &&
                   (ByteCnt == 16'h0000) &&
                   (DlyCrcCnt == 3'h0) &&
                   (ExcessiveDefer == 1'b0) &&
                   (NibCntEq7 == 1'b0) &&
                   (NibCntEq15 == 1'b0) &&
                   (MaxFrame == 1'b0) &&
                   (NibbleMinFl == 1'b0))
    );

    // Nibble counter increments when IPG, preamble, or data states are active.
    check_nibble_counter_increments: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateIPG || StatePreamble || (|StateData)) |=> (NibCnt == ($past(NibCnt) + 16'd1))
    );

    // Nibble counter increments when PAD or FCS states are active with nibble 0.
    check_nibble_counter_increments_pad_fcs: assert property (
        @(posedge MTxClk) disable iff (Reset)
        ((StatePAD || StateFCS) && $past(NibCnt[0])) |=> (NibCnt == ($past(NibCnt) + 16'd1))
    );

    // Nibble counter increments on backoff nibble 0 when data is not active.
    check_nibble_counter_increments_backoff: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateBackOff && $past(NibCnt[6:0]) && !(|StateData)) |=> (NibCnt == ($past(NibCnt) + 16'd1))
    );

    // Nibble counter resets on start defer, start IPG, start FCS, start jam, or idle.
    check_nibble_counter_resets_on_start_events: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StartDefer || StartIPG || StartFCS || StartJam || StateIdle) |=> (NibCnt == 16'h0000)
    );

    // Nibble counter resets on excessive defer with no start frame.
    check_nibble_counter_resets_on_excessive_defer: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateDefer && $past(ExcessiveDefer) && !$past(TxStartFrm)) |=> (NibCnt == 16'h0000)
    );

    // Nibble counter resets on preamble nibble 15.
    check_nibble_counter_resets_on_preamble_15: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StatePreamble && $past(NibCntEq15)) |=> (NibCnt == 16'h0000)
    );

    // Nibble counter resets on jam nibble 7.
    check_nibble_counter_resets_on_jam_7: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateJam && $past(NibCntEq7)) |=> (NibCnt == 16'h0000)
    );

    // Nibble counter holds when no active increment condition is true.
    check_nibble_counter_holds_without_active_condition: assert property (
        @(posedge MTxClk) disable iff (Reset)
        !(StateIPG || StatePreamble || (|StateData) || (StatePAD || StateFCS) || StateBackOff ||
          (StateDefer && !$past(ExcessiveDefer) && $past(TxStartFrm)) ||
          (StatePreamble && $past(NibCntEq15)) ||
          (StateJam && $past(NibCntEq7)) ||
          StateIdle || StartDefer || StartIPG || StartFCS || StartJam)
        |=> (NibCnt == $past(NibCnt))
    );

    // Nibble equality flags reflect the current nibble count.
    check_nibble_eq_flags_match_count: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (NibCntEq7 == (&NibCnt[2:0])) &&
        (NibCntEq15 == (&NibCnt[3:0]))
    );

    // Nibble minimum frame flag reflects the current nibble count and minimum length.
    check_nibble_minfl_matches_count: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (NibbleMinFl == (NibCnt >= (((MinFL - 16'd4) << 1) - 1)))
    );

    // Excessive defer flag matches the implemented compare value.
    check_excessive_defer_flag: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (ExcessiveDefer == ($past(NibCnt[13:0]) == 14'h17b7))
    );

    // Excessive defer flag is masked when excessive defer is disabled.
    check_excessive_defer_masked_when_disabled: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (!ExDfrEn) |-> (ExcessiveDefer == 1'b0)
    );

    // Byte counter increments when data state 1 is active and not at max.
    check_byte_counter_increments_data1: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateData[1] && !$past(ByteCntMax)) |=> (ByteCnt == ($past(ByteCnt) + 16'd1))
    );

    // Byte counter increments on backoff nibble 0 when data is not active and not at max.
    check_byte_counter_increments_backoff: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateBackOff && $past(NibCnt[6:0]) && !(|StateData) && !$past(ByteCntMax)) |=> (ByteCnt == ($past(ByteCnt) + 16'd1))
    );

    // Byte counter increments on PAD or FCS nibble 0 when not at max.
    check_byte_counter_increments_pad_fcs: assert property (
        @(posedge MTxClk) disable iff (Reset)
        ((StatePAD || StateFCS) && $past(NibCnt[0]) && !$past(ByteCntMax)) |=> (ByteCnt == ($past(ByteCnt) + 16'd1))
    );

    // Byte counter resets on start backoff, idle with start frame, or packet finish.
    check_byte_counter_resets_on_start_events: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StartBackoff || StateIdle && $past(TxStartFrm) || PacketFinished_q) |=> (ByteCnt == 16'h0000)
    );

    // Byte counter holds when no active increment condition is true.
    check_byte_counter_holds_without_active_condition: assert property (
        @(posedge MTxClk) disable iff (Reset)
        !(StateData[1] && !$past(ByteCntMax)) &&
        !(StateBackOff && $past(NibCnt[6:0]) && !(|StateData) && !$past(ByteCntMax)) &&
        !((StatePAD || StateFCS) && $past(NibCnt[0]) && !$past(ByteCntMax)) &&
        !(StartBackoff || StateIdle && $past(TxStartFrm) || PacketFinished_q)
        |=> (ByteCnt == $past(ByteCnt))
    );

    // Maximum frame flag matches the implemented compare value.
    check_max_frame_flag: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (MaxFrame == ($past(ByteCnt[15:0]) == $past(MaxFL[15:0]) && !$past(HugEn)))
    );

    // Maximum frame flag is masked when hug enable is asserted.
    check_max_frame_masked_when_hug_enabled: assert property (
        @(posedge MTxClk) disable iff (Reset)
        HugEn |-> (MaxFrame == 1'b0)
    );

    // Delayed CRC counter increments on SFD, data state 1, or enabled data nibbles.
    check_dlycrc_counter_increments: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateSFD || StateData[1] || (DlyCrcEn && (|StateData))) |=> (DlyCrcCnt == ($past(DlyCrcCnt) + 3'd1))
    );

    // Delayed CRC counter resets on start jam, packet finish, or data state 1 at 4 nibbles.
    check_dlycrc_counter_resets_on_reset_events: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StartJam || PacketFinished_q || (StateData[1] && $past(DlyCrcCnt == 3'h4))) |=> (DlyCrcCnt == 3'h0)
    );

    // Delayed CRC counter holds when no active increment condition is true.
    check_dlycrc_counter_holds_without_active_condition: assert property (
        @(posedge MTxClk) disable iff (Reset)
        !(StateSFD || StateData[1] || (DlyCrcEn && (|StateData))) &&
        !(StartJam || PacketFinished_q || (StateData[1] && $past(DlyCrcCnt == 3'h4)))
        |=> (DlyCrcCnt == $past(DlyCrcCnt))
    );

endmodule