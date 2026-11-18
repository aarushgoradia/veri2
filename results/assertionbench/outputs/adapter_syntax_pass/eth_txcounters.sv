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

    // Reset clears the nibble counter.
    check_reset_clears_nibble_counter: assert property (
        @(posedge MTxClk) Reset |-> (NibCnt == 16'h0)
    );

    // Reset clears the byte counter.
    check_reset_clears_byte_counter: assert property (
        @(posedge MTxClk) Reset |-> (ByteCnt == 16'h0)
    );

    // Reset clears the delayed CRC counter.
    check_reset_clears_crc_counter: assert property (
        @(posedge MTxClk) Reset |-> (DlyCrcCnt == 3'h0)
    );

    // ExcessiveDefer is asserted when the nibble counter matches the threshold.
    check_excessive_defer_threshold: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (NibCnt[13:0] == 14'h17b7) |-> (ExcessiveDefer == !ExDfrEn)
    );

    // ExcessiveDefer is only asserted when excessive deferral is disabled.
    check_excessive_defer_disabled: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (!ExDfrEn) |-> !ExcessiveDefer
    );

    // ExcessiveDefer is never asserted when excessive deferral is enabled.
    check_excessive_defer_enabled: assert property (
        @(posedge MTxClk) disable iff (Reset)
        ExDfrEn |-> !ExcessiveDefer
    );

    // NibCntEq7 is high when the low three nibble bits are all high.
    check_nibble_eq7_definition: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (NibCntEq7 == (&NibCnt[2:0]))
    );

    // NibCntEq15 is high when the low four nibble bits are all high.
    check_nibble_eq15_definition: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (NibCntEq15 == (&NibCnt[3:0]))
    );

    // NibbleMinFl compares the nibble counter against the adjusted minimum length.
    check_nibble_minfl_definition: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (NibbleMinFl == (NibCnt >= (((MinFL - 16'd4) << 1) - 1)))
    );

    // MaxFrame is asserted when the byte counter matches the maximum frame length.
    check_max_frame_definition: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (MaxFrame == (ByteCnt == MaxFL) && !HugEn)
    );

    // MaxFrame is never asserted when hug frames are enabled.
    check_max_frame_with_hug_enabled: assert property (
        @(posedge MTxClk) disable iff (Reset)
        HugEn |-> !MaxFrame
    );

    // MaxFrame is never asserted when the byte counter is below the maximum length.
    check_max_frame_below_max_length: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (ByteCnt < MaxFL) |-> !MaxFrame
    );

    // MaxFrame is never asserted when the byte counter exceeds the maximum length.
    check_max_frame_above_max_length: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (ByteCnt > MaxFL) |-> !MaxFrame
    );

    // The nibble counter increments when the current state increments it.
    check_nibble_counter_increment: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (IncrementNibCnt && !ResetNibCnt) |=> (NibCnt == ($past(NibCnt) + 16'd1))
    );

    // The nibble counter resets when the current state resets it.
    check_nibble_counter_reset: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (ResetNibCnt && !IncrementNibCnt) |=> (NibCnt == 16'h0)
    );

    // The nibble counter holds when no increment or reset condition is active.
    check_nibble_counter_hold: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (!IncrementNibCnt && !ResetNibCnt) |=> (NibCnt == $past(NibCnt))
    );

    // The byte counter increments when the current state increments it.
    check_byte_counter_increment: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (IncrementByteCnt && !ResetByteCnt) |=> (ByteCnt == ($past(ByteCnt) + 16'd1))
    );

    // The byte counter resets when the current state resets it.
    check_byte_counter_reset: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (ResetByteCnt && !IncrementByteCnt) |=> (ByteCnt == 16'h0)
    );

    // The byte counter holds when no increment or reset condition is active.
    check_byte_counter_hold: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (!IncrementByteCnt && !ResetByteCnt) |=> (ByteCnt == $past(ByteCnt))
    );

    // The delayed CRC counter increments when the current state increments it.
    check_crc_counter_increment: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (DlyCrcEn && (StateSFD || StateData[1] && (|DlyCrcCnt[2:0]))) && (DlyCrcCnt != 3'h4) && !PacketFinished_q && !StartJam
        |=> (DlyCrcCnt == ($past(DlyCrcCnt) + 3'd1))
    );

    // The delayed CRC counter resets when the current state resets it.
    check_crc_counter_reset: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateData[1] && DlyCrcCnt == 3'h4 || StartJam || PacketFinished_q) |=> (DlyCrcCnt == 3'h0)
    );

    // The delayed CRC counter holds when no increment or reset condition is active.
    check_crc_counter_hold: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (!DlyCrcEn || (StateData[1] && DlyCrcCnt == 3'h4) || StartJam || PacketFinished_q) |=> (DlyCrcCnt == $past(DlyCrcCnt))
    );

endmodule