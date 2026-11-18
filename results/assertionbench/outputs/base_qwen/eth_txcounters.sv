```systemverilog
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
    input logic StateSFD,
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
    output logic [15:0] ByteCnt,
    output logic [15:0] NibCnt,
    output logic ExcessiveDefer,
    output logic NibCntEq7,
    output logic NibCntEq15,
    output logic MaxFrame,
    output logic NibbleMinFl,
    output logic [2:0] DlyCrcCnt
);

    // Nibble Counter
    property p_reset_nibcnt;
        @(posedge MTxClk) disable iff (!Reset) ResetNibCnt |-> NibCnt == 16'h0;
    endproperty
    assert property (p_reset_nibcnt) else $error("Nibble counter not reset on reset");

    property p_increment_nibcnt;
        @(posedge MTxClk) disable iff (!Reset) IncrementNibCnt |-> NibCnt == NibCnt + 16'd1;
    endproperty
    assert property (p_increment_nibcnt) else $error("Nibble counter not incremented correctly");

    property p_reset_bytecnt;
        @(posedge MTxClk) disable iff (!Reset) ResetByteCnt |-> ByteCnt == 16'h0;
    endproperty
    assert property (p_reset_bytecnt) else $error("Byte counter not reset on reset");

    property p_increment_bytecnt;
        @(posedge MTxClk) disable iff (!Reset) IncrementByteCnt |-> ByteCnt == ByteCnt + 16'd1;
    endproperty
    assert property (p_increment_bytecnt) else $error("Byte counter not incremented correctly");

    property p_max_frame;
        @(posedge MTxClk) disable iff (!Reset) MaxFrame |-> ByteCnt == MaxFL;
    endproperty
    assert property (p_max_frame) else $error("Max frame not detected correctly");

    property p_excessive_defer;
        @(posedge MTxClk) disable iff (!Reset) ExcessiveDefer |-> NibCnt[13:0] == 14'h17b7 & ~ExDfrEn;
    endproperty
    assert property (p_excessive_defer) else $error("Excessive defer not detected correctly");

    property p_nibble_min_fl;
        @(posedge MTxClk) disable iff (!Reset) NibbleMinFl |-> NibCnt >= (((MinFL-16'd4)<<1) -1);
    endproperty
    assert property (p_nibble_min_fl) else $error("Nibble min frame length not detected correctly");

    property p_dly_crc_cnt;
        @(posedge MTxClk) disable iff (!Reset) DlyCrcCnt |-> DlyCrcCnt == DlyCrcCnt + 3'd1;
    endproperty
    assert property (p_dly_crc_cnt) else $error("Delayed CRC counter not incremented correctly");

endmodule
```