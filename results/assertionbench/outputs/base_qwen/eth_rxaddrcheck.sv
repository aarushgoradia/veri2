```systemverilog
module eth_rxaddrcheck_sva (
    input logic MRxClk,
    input logic Reset,
    input logic [7:0] RxData,
    input logic Broadcast,
    input logic r_Bro,
    input logic r_Pro,
    input logic ByteCntEq0,
    input logic ByteCntEq2,
    input logic ByteCntEq3,
    input logic ByteCntEq4,
    input logic ByteCntEq5,
    input logic ByteCntEq6,
    input logic ByteCntEq7,
    input logic [31:0] HASH0,
    input logic [31:0] HASH1,
    input logic [5:0] CrcHash,
    input logic CrcHashGood,
    input logic Multicast,
    input logic [47:0] MAC,
    input logic [1:0] StateData,
    input logic RxEndFrm,
    input logic PassAll,
    input logic ControlFrmAddressOK,
    output logic RxAbort,
    output logic AddressMiss
);

    // RxAbort should be cleared after one cycle when it is set
    always_ff @(posedge MRxClk or posedge Reset) begin
        if (!Reset) begin
            RxAbort <= 1'b0;
        end else if (RxAbort) begin
            RxAbort <= 1'b0;
        end
    end

    // AddressMiss should be cleared when ByteCntEq0 is asserted
    always_ff @(posedge MRxClk or posedge Reset) begin
        if (!Reset) begin
            AddressMiss <= 1'b0;
        end else if (ByteCntEq0) begin
            AddressMiss <= 1'b0;
        end
    end

    // AddressMiss should be set when ByteCntEq7 is asserted and RxCheckEn is true
    // and the address is not valid
    always_ff @(posedge MRxClk or posedge Reset) begin
        if (!Reset) begin
            AddressMiss <= 1'b0;
        end else if (ByteCntEq7 && RxCheckEn && RxAddressInvalid) begin
            AddressMiss <= 1'b1;
        end
    end

    // UnicastOK should be set when ByteCntEq2 is asserted and the first byte matches the MAC address
    // and should be updated for subsequent bytes
    always_ff @(posedge MRxClk or posedge Reset) begin
        if (!Reset) begin
            UnicastOK <= 1'b0;
        end else if (RxCheckEn && ByteCntEq2) begin
            UnicastOK <= (RxData[7:0] == MAC[47:40]);
        end else if (RxCheckEn && ByteCntEq3) begin
            UnicastOK <= (RxData[7:0] == MAC[39:32]) & UnicastOK;
        end else if (RxCheckEn && ByteCntEq4) begin
            UnicastOK <= (RxData[7:0] == MAC[31:24]) & UnicastOK;
        end else if (RxCheckEn && ByteCntEq5) begin
            UnicastOK <= (RxData[7:0] == MAC[23:16]) & UnicastOK;
        end else if (RxCheckEn && ByteCntEq6) begin
            UnicastOK <= (RxData[7:0] == MAC[15:8]) & UnicastOK;
        end else if (RxCheckEn && ByteCntEq7) begin
            UnicastOK <= (RxData[7:0] == MAC[7:0]) & UnicastOK;
        end else if (RxEndFrm || RxAbort) begin
            UnicastOK <= 1'b0;
        end
    end

    // MulticastOK should be set when RxEndFrm or RxAbort is asserted
    // or when CrcHashGood and Multicast are asserted and HashBit is true
    always_ff @(posedge MRxClk or posedge Reset) begin
        if (!Reset) begin
            MulticastOK <= 1'b0;
        end else if (RxEndFrm || RxAbort) begin
            MulticastOK <= 1'b0;
        end else if (CrcHashGood && Multicast) begin
            MulticastOK <= HashBit;
        end
    end

    // RxAddressInvalid should be false when UnicastOK, BroadcastOK, MulticastOK, or (PassAll and ControlFrmAddressOK) is true
    assign RxAddressInvalid = ~(UnicastOK | BroadcastOK | MulticastOK | (PassAll & ControlFrmAddressOK));

    // BroadcastOK should be true when Broadcast is true and r_Bro is false
    assign BroadcastOK = Broadcast & ~r_Bro;

    // RxCheckEn should be true when StateData is non-zero
    assign RxCheckEn = |StateData;

endmodule
```