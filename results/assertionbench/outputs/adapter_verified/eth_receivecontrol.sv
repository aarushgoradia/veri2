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
    input logic SetPauseTimer
);

// Pause is low when either clock edge sees reset asserted.
    check_pause_low_on_reset: assert property (
        @(posedge MTxClk) RxReset |-> (Pause == 1'b0)
    );
    check_pause_low_on_reset: assert property (
        @(posedge MRxClk) RxReset |-> (Pause == 1'b0)
    );

// ReceivedPauseFrm is low when either clock edge sees reset asserted.
    check_pausefrm_low_on_reset: assert property (
        @(posedge MTxClk) RxReset |-> (ReceivedPauseFrm == 1'b0)
    );
    check_pausefrm_low_on_reset: assert property (
        @(posedge MRxClk) RxReset |-> (ReceivedPauseFrm == 1'b0)
    );

// AddressOK is low when either clock edge sees reset asserted.
    check_addressok_low_on_reset: assert property (
        @(posedge MTxClk) RxReset |-> (AddressOK == 1'b0)
    );
    check_addressok_low_on_reset: assert property (
        @(posedge MRxClk) RxReset |-> (AddressOK == 1'b0)
    );

// SetPauseTimer is low when either clock edge sees reset asserted.
    check_setpausetimer_low_on_reset: assert property (
        @(posedge MTxClk) RxReset |-> (SetPauseTimer == 1'b0)
    );
    check_setpausetimer_low_on_reset: assert property (
        @(posedge MRxClk) RxReset |-> (SetPauseTimer == 1'b0)
    );

// Pause is low when either clock edge sees TxReset asserted.
    check_pause_low_on_txreset: assert property (
        @(posedge MTxClk) TxReset |-> (Pause == 1'b0)
    );
    check_pause_low_on_txreset: assert property (
        @(posedge MRxClk) TxReset |-> (Pause == 1'b0)
    );

// ReceivedPauseFrm is low when either clock edge sees TxReset asserted.
    check_pausefrm_low_on_txreset: assert property (
        @(posedge MTxClk) TxReset |-> (ReceivedPauseFrm == 1'b0)
    );
    check_pausefrm_low_on_txreset: assert property (
        @(posedge MRxClk) TxReset |-> (ReceivedPauseFrm == 1'b0)
    );

// AddressOK is low when either clock edge sees TxReset asserted.
    check_addressok_low_on_txreset: assert property (
        @(posedge MTxClk) TxReset |-> (AddressOK == 1'b0)
    );
    check_addressok_low_on_txreset: assert property (
        @(posedge MRxClk) TxReset |-> (AddressOK == 1'b0)
    );

// SetPauseTimer is low when either clock edge sees TxReset asserted.
    check_setpausetimer_low_on_txreset: assert property (
        @(posedge MTxClk) TxReset |-> (SetPauseTimer == 1'b0)
    );
    check_setpausetimer_low_on_txreset: assert property (
        @(posedge MRxClk) TxReset |-> (SetPauseTimer == 1'b0)
    );

endmodule
