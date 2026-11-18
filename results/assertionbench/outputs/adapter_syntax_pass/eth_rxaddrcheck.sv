module eth_rxaddrcheck_sva (
    input logic        MRxClk,
    input logic        Reset,
    input logic [7:0]  RxData,
    input logic        Broadcast,
    input logic        r_Bro,
    input logic        r_Pro,
    input logic        ByteCntEq0,
    input logic        ByteCntEq2,
    input logic        ByteCntEq3,
    input logic        ByteCntEq4,
    input logic        ByteCntEq5,
    input logic        ByteCntEq6,
    input logic        ByteCntEq7,
    input logic [31:0] HASH0,
    input logic [31:0] HASH1,
    input logic [5:0]  CrcHash,
    input logic        CrcHashGood,
    input logic [1:0]  StateData,
    input logic        RxEndFrm,
    input logic        Multicast,
    input logic [47:0] MAC,
    input logic        RxAbort,
    input logic        AddressMiss,
    input logic        PassAll,
    input logic        ControlFrmAddressOK
);

    // Reset clears AddressMiss on the next clock.
    check_addressmiss_clears_after_reset: assert property (
        @(posedge MRxClk) Reset |=> (AddressMiss == 1'b0)
    );

    // AddressMiss is cleared when ByteCntEq0 is asserted.
    check_addressmiss_clears_on_bytecnteq0: assert property (
        @(posedge MRxClk) disable iff (Reset)
        ByteCntEq0 |=> (AddressMiss == 1'b0)
    );

    // AddressMiss is set when the address check is enabled and ByteCntEq7 is asserted.
    check_addressmiss_sets_on_bytecnteq7: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCntEq7 && (|StateData)) |=> (AddressMiss == 1'b1)
    );

    // AddressMiss is not set when the address check is disabled.
    check_addressmiss_not_set_without_check: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!|StateData && ByteCntEq7) |=> (AddressMiss == 1'b0)
    );

    // AddressMiss is not set when the address check passes.
    check_addressmiss_not_set_on_pass: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCntEq7 && (|StateData) &&
         ((UnicastOK | BroadcastOK | MulticastOK | (PassAll & ControlFrmAddressOK)))) |=> (AddressMiss == 1'b0)
    );

    // AddressMiss is not set when ByteCntEq7 is not asserted.
    check_addressmiss_not_set_without_bytecnteq7: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (|StateData && !ByteCntEq7) |=> (AddressMiss == 1'b0)
    );

    // AddressMiss is not set when the previous cycle was not ByteCntEq0 and ByteCntEq7 was not asserted.
    check_addressmiss_not_set_without_prev_bytecnteq0_or_7: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$past(ByteCntEq0) && !$past(ByteCntEq7)) |=> (AddressMiss == 1'b0)
    );

    // AddressMiss is not set when the previous cycle was ByteCntEq0.
    check_addressmiss_not_set_after_bytecnteq0: assert property (
        @(posedge MRxClk) disable iff (Reset)
        $past(ByteCntEq0) |=> (AddressMiss == 1'b0)
    );

    // AddressMiss is not set when the previous cycle was ByteCntEq7 without the address check enabled.
    check_addressmiss_not_set_after_bytecnteq7_without_check: assert property (
        @(posedge MRxClk) disable iff (Reset)
        ($past(ByteCntEq7) && !$past(|StateData)) |=> (AddressMiss == 1'b0)
    );

    // AddressMiss is not set when the previous cycle was ByteCntEq7 and the address check passed.
    check_addressmiss_not_set_after_bytecnteq7_on_pass: assert property (
        @(posedge MRxClk) disable iff (Reset)
        ($past(ByteCntEq7) && $past(|StateData) &&
         ($past(UnicastOK | BroadcastOK | MulticastOK | (PassAll & ControlFrmAddressOK)))) |=> (AddressMiss == 1'b0)
    );

endmodule