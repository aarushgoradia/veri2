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
    input logic [1:0]  StateData,
    input logic        RxEndFrm,
    input logic        PassAll,
    input logic        ControlFrmAddressOK,
    input logic        RxAbort,
    input logic        AddressMiss,
    input logic        BroadcastOK,
    input logic        RxAddressInvalid,
    input logic        RxCheckEn,
    input logic        HashBit,
    input logic [31:0] IntHash,
    input logic [7:0]  ByteHash,
    input logic        MulticastOK,
    input logic        UnicastOK
);

    // Reset clears the abort flag.
    check_reset_clears_abort: assert property (
        @(posedge MRxClk) Reset |=> (RxAbort == 1'b0)
    );

    // Reset clears the address miss flag.
    check_reset_clears_address_miss: assert property (
        @(posedge MRxClk) Reset |=> (AddressMiss == 1'b0)
    );

    // Reset clears the multicast match flag.
    check_reset_clears_multicast_ok: assert property (
        @(posedge MRxClk) Reset |=> (MulticastOK == 1'b0)
    );

    // Reset clears the unicast match flag.
    check_reset_clears_unicast_ok: assert property (
        @(posedge MRxClk) Reset |=> (UnicastOK == 1'b0)
    );

    // BroadcastOK is the broadcast flag masked by the broadcast reject bit.
    check_broadcastok_definition: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (BroadcastOK == (Broadcast & ~r_Bro))
    );

    // RxCheckEn is high when StateData is non-zero.
    check_rxchecken_definition: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (RxCheckEn == (|StateData))
    );

    // RxAddressInvalid is the inverse of the address match terms.
    check_rxaddressinvalid_definition: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (RxAddressInvalid == ~(UnicastOK | BroadcastOK | MulticastOK | (PassAll & ControlFrmAddressOK)))
    );

    // Abort is asserted on the previous cycle when address invalid, byte 7, and check enabled.
    check_abort_asserts_on_invalid_address: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) && $past(RxAddressInvalid && ByteCntEq7 && RxCheckEn))
        |-> (RxAbort == 1'b1)
    );

    // Abort is cleared on the previous cycle when address valid or check disabled.
    check_abort_clears_on_valid_address: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) && !$past(RxAddressInvalid && ByteCntEq7 && RxCheckEn))
        |-> (RxAbort == 1'b0)
    );

    // AddressMiss is cleared on the previous cycle when ByteCntEq0 is high.
    check_address_miss_clears_on_byte0: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) && $past(ByteCntEq0))
        |-> (AddressMiss == 1'b0)
    );

    // AddressMiss is cleared on the previous cycle when ByteCntEq7 and check enabled.
    check_address_miss_clears_on_byte7: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) && $past(ByteCntEq7 && RxCheckEn))
        |-> (AddressMiss == 1'b0)
    );

    // AddressMiss is set on the previous cycle when address invalid and ByteCntEq7.
    check_address_miss_sets_on_invalid_address: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) && $past(RxAddressInvalid && ByteCntEq7 && RxCheckEn))
        |-> (AddressMiss == 1'b1)
    );

    // AddressMiss holds its value when no clear or set condition is true.
    check_address_miss_holds_without_clear_or_set: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) &&
         !$past(ByteCntEq0) &&
         !$past(ByteCntEq7 && RxCheckEn) &&
         !$past(RxAddressInvalid && ByteCntEq7 && RxCheckEn))
        |-> (AddressMiss == $past(AddressMiss))
    );

    // MulticastOK is cleared on the previous cycle when RxEndFrm or RxAbort is high.
    check_multicast_ok_clears_on_endfrm_or_abort: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) && ($past(RxEndFrm) || $past(RxAbort)))
        |-> (MulticastOK == 1'b0)
    );

    // MulticastOK is set on the previous cycle when CRC good, multicast, and hash bit are true.
    check_multicast_ok_sets_on_crcgood_multicast_hashbit: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) &&
         $past(CrcHashGood && Multicast && HashBit))
        |-> (MulticastOK == 1'b1)
    );

    // MulticastOK holds its value when no clear or set condition is true.
    check_multicast_ok_holds_without_clear_or_set: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) &&
         !$past(RxEndFrm) &&
         !$past(RxAbort) &&
         !$past(CrcHashGood && Multicast && HashBit))
        |-> (MulticastOK == $past(MulticastOK))
    );

    // UnicastOK is cleared on the previous cycle when RxEndFrm or RxAbort is high.
    check_unicast_ok_clears_on_endfrm_or_abort: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) && ($past(RxEndFrm) || $past(RxAbort)))
        |-> (UnicastOK == 1'b0)
    );

    // UnicastOK is set on the previous cycle when byte 2 matches MAC[47:40].
    check_unicast_ok_sets_on_byte2_match: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) &&
         $past(RxCheckEn && ByteCntEq2) &&
         $past(RxData[7:0] == MAC[47:40]))
        |-> (UnicastOK == 1'b1)
    );

    // UnicastOK is updated on byte 3 when byte 2 matched and check enabled.
    check_unicast_ok_updates_on_byte3: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) &&
         $past(RxCheckEn && ByteCntEq3) &&
         $past(RxData[7:0] == MAC[39:32]) &&
         $past(UnicastOK))
        |-> (UnicastOK == 1'b1)
    );

    // UnicastOK is updated on byte 4 when byte 3 matched and check enabled.
    check_unicast_ok_updates_on_byte4: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) &&
         $past(RxCheckEn && ByteCntEq4) &&
         $past(RxData[7:0] == MAC[31:24]) &&
         $past(UnicastOK))
        |-> (UnicastOK == 1'b1)
    );

    // UnicastOK is updated on byte 5 when byte 4 matched and check enabled.
    check_unicast_ok_updates_on_byte5: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) &&
         $past(RxCheckEn && ByteCntEq5) &&
         $past(RxData[7:0] == MAC[23:16]) &&
         $past(UnicastOK))
        |-> (UnicastOK == 1'b1)
    );

    // UnicastOK is updated on byte 6 when byte 5 matched and check enabled.
    check_unicast_ok_updates_on_byte6: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) &&
         $past(RxCheckEn && ByteCntEq6) &&
         $past(RxData[7:0] == MAC[15:8]) &&
         $past(UnicastOK))
        |-> (UnicastOK == 1'b1)
    );

    // UnicastOK is updated on byte 7 when byte 6 matched and check enabled.
    check_unicast_ok_updates_on_byte7: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) &&
         $past(RxCheckEn && ByteCntEq7) &&
         $past(RxData[7:0] == MAC[7:0]) &&
         $past(UnicastOK))
        |-> (UnicastOK == 1'b1)
    );

    // UnicastOK holds its value when no clear or update condition is true.
    check_unicast_ok_holds_without_clear_or_update: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (!$initstate && $past(!Reset) &&
         !$past(RxEndFrm) &&
         !$past(RxAbort) &&
         !$past(RxCheckEn && ByteCntEq2 && (RxData[7:0] == MAC[47:40])) &&
         !$past(RxCheckEn && ByteCntEq3 && (RxData[7:0] == MAC[39:32]) && UnicastOK) &&
         !$past(RxCheckEn && ByteCntEq4 && (RxData[7:0] == MAC[31:24]) && UnicastOK) &&
         !$past(RxCheckEn && ByteCntEq5 && (RxData[7:0] == MAC[23:16]) && UnicastOK) &&
         !$past(RxCheckEn && ByteCntEq6 && (RxData[7:0] == MAC[15:8]) && UnicastOK) &&
         !$past(RxCheckEn && ByteCntEq7 && (RxData[7:0] == MAC[7:0]) && UnicastOK))
        |-> (UnicastOK == $past(UnicastOK))
    );

    // HashBit selects the low byte of the selected hash register.
    check_hashbit_selects_hash_low_byte: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (HashBit == (CrcHash[5] ? HASH1[7:0] : HASH0[7:0]))
    );

    // ByteHash selects the CRC hash byte indexed by CrcHash[2:0].
    check_bytehash_selects_crc_hash_byte: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteHash == ((CrcHash[5]) ? HASH1[CrcHash[2:0]*8 +: 8] : HASH0[CrcHash[2:0]*8 +: 8]))
    );

    // ByteHash matches the implemented case statement from CrcHash and IntHash.
    check_bytehash_matches_inthash_case: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteHash == ((CrcHash[5]) ?
                      ((CrcHash[2:0] == 3'b000) ? HASH1[7:0] :
                       (CrcHash[2:0] == 3'b001) ? HASH1[15:8] :
                       (CrcHash[2:0] == 3'b010) ? HASH1[23:16] :
                       (CrcHash[2:0] == 3'b011) ? HASH1[31:24] :
                       (CrcHash[2:0] == 3'b100) ? HASH0[7:0] :
                       (CrcHash[2:0] == 3'b101) ? HASH0[15:8] :
                       (CrcHash[2:0] == 3'b110) ? HASH0[23:16] :
                                                  HASH0[31:24]) :
                      ((CrcHash[2:0] == 3'b000) ? HASH0[7:0] :
                       (CrcHash[2:0] == 3'b001) ? HASH0[15:8] :
                       (CrcHash[2:0] == 3'b010) ? HASH0[23:16] :
                       (CrcHash[2:0] == 3'b011) ? HASH0[31:24] :
                       (CrcHash[2:0] == 3'b100) ? HASH1[7:0] :
                       (CrcHash[2:0] == 3'b101) ? HASH1[15:8] :
                       (CrcHash[2:0] == 3'b110) ? HASH1[23:16] :
                                                  HASH1[31:24])))
    );

endmodule