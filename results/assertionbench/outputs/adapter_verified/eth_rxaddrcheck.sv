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

// Reset clears both outputs on the next clock.
    check_reset_clears_outputs: assert property (
        @(posedge MRxClk) Reset |=> (AddressMiss == 1'b0) && (RxAbort == 1'b0)
    );

// AddressMiss is cleared when ByteCntEq0 is asserted.
    check_addressmiss_clear_on_bytecnteq0: assert property (
        @(posedge MRxClk) disable iff (Reset)
        ByteCntEq0 |=> (AddressMiss == 1'b0)
    );

// AddressMiss is set when ByteCntEq7 is asserted and address checking is enabled.
    check_addressmiss_set_on_bytecnteq7: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCntEq7 && |StateData) |=> (AddressMiss == 1'b1)
    );

// AddressMiss is cleared when ByteCntEq7 is asserted and address checking is enabled.
    check_addressmiss_clear_on_bytecnteq7: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCntEq7 && |StateData) |=> (AddressMiss == 1'b0)
    );

// AddressMiss is cleared when a frame ends.
    check_addressmiss_clear_on_rxendfrm: assert property (
        @(posedge MRxClk) disable iff (Reset)
        RxEndFrm |=> (AddressMiss == 1'b0)
    );

// AddressMiss is cleared when a frame is aborted.
    check_addressmiss_clear_on_rxabort: assert property (
        @(posedge MRxClk) disable iff (Reset)
        RxAbort |=> (AddressMiss == 1'b0)
    );

// AddressMiss is cleared when PassAll and ControlFrmAddressOK are both high.
    check_addressmiss_clear_on_passall_and_control: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (PassAll && ControlFrmAddressOK) |=> (AddressMiss == 1'b0)
    );

// AddressMiss is high when ByteCntEq7 is asserted and address checking is enabled,
// and no address match is found.
    check_addressmiss_high_when_no_match: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCntEq7 && |StateData && !((UnicastOK | BroadcastOK | MulticastOK) || (PassAll && ControlFrmAddressOK))) |=> (AddressMiss == 1'b1)
    );

// AddressMiss is low when ByteCntEq7 is asserted and address checking is enabled,
// and at least one address match is found.
    check_addressmiss_low_when_any_match: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCntEq7 && |StateData && ((UnicastOK | BroadcastOK | MulticastOK) || (PassAll && ControlFrmAddressOK))) |=> (AddressMiss == 1'b0)
    );

endmodule
