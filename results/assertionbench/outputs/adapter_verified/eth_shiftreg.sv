module eth_shiftreg_sva (
    input logic Clk,
    input logic Reset,
    input logic MdcEn_n,
    input logic Mdi,
    input logic [4:0] Fiad,
    input logic [4:0] Rgad,
    input logic [15:0] CtrlData,
    input logic WriteOp,
    input logic [3:0] ByteSelect,
    input logic [1:0] LatchByte,
    input logic ShiftedBit,
    input logic [15:0] Prsd,
    input logic LinkFail
);

// Reset clears all state by the next clock.
    check_reset_clears_state: assert property (
        @(posedge Clk) Reset |=> (ShiftReg == 8'h00) && (Prsd == 16'h0000) && (LinkFail == 1'b0)
    );

// With MdcEn_n low, the shift register holds its value.
    check_hold_when_disabled: assert property (
        @(posedge Clk) disable iff (Reset)
        !MdcEn_n |=> (ShiftReg == $past(ShiftReg))
    );

// With MdcEn_n high and ByteSelect != 0, ShiftReg loads the selected control field.
    check_load_ctrl_fields: assert property (
        @(posedge Clk) disable iff (Reset)
        MdcEn_n && (|ByteSelect) |=> (
            ShiftReg == {
                (ByteSelect == 4'h1) ? {2'b01, ~WriteOp, WriteOp, Fiad[4:1]} :
                (ByteSelect == 4'h2) ? {Fiad[0], Rgad[4:0], 2'b10} :
                (ByteSelect == 4'h4) ? {6'b0, CtrlData[15:8]} :
                (ByteSelect == 4'h8) ? {6'b0, CtrlData[7:0]} :
                8'h00
            }
        )
    );

// With MdcEn_n high and ByteSelect == 0, ShiftReg shifts in Mdi and updates Prsd as selected.
    check_shift_and_latch: assert property (
        @(posedge Clk) disable iff (Reset)
        MdcEn_n && !|ByteSelect |=> (
            ShiftReg == {ShiftReg[6:0], Mdi} &&
            Prsd == (
                (LatchByte[0] && (Rgad == 5'h01)) ? {ShiftReg[6:0], Mdi} : Prsd[15:8] &&
                (LatchByte[1]) ? {ShiftReg[6:0], Mdi} : Prsd[7:0]
            ) &&
            LinkFail == (
                (LatchByte[0] && (Rgad == 5'h01)) ? ~ShiftReg[1] : $past(LinkFail)
            )
        )
    );

// With MdcEn_n high and ByteSelect == 0, LatchByte[0] latches into Prsd[7:0] and updates LinkFail.
    check_latch_byte0: assert property (
        @(posedge Clk) disable iff (Reset)
        MdcEn_n && !|ByteSelect && LatchByte[0] |=> (
            Prsd[7:0] == {ShiftReg[6:0], Mdi} &&
            LinkFail == ~ShiftReg[1] &&
            Prsd[15:8] == $past(Prsd[15:8])
        )
    );

// With MdcEn_n high and ByteSelect == 0, LatchByte[1] latches into Prsd[15:8].
    check_latch_byte1: assert property (
        @(posedge Clk) disable iff (Reset)
        MdcEn_n && !|ByteSelect && LatchByte[1] |=> (
            Prsd[15:8] == {ShiftReg[6:0], Mdi} &&
            LinkFail == $past(LinkFail)
        )
    );

// With MdcEn_n high and ByteSelect == 0, neither latch updates Prsd[7:0].
    check_no_latch_byte0: assert property (
        @(posedge Clk) disable iff (Reset)
        MdcEn_n && !|ByteSelect && !LatchByte[0] |=> (
            Prsd[7:0] == $past(Prsd[7:0]) &&
            LinkFail == $past(LinkFail)
        )
    );

// With MdcEn_n high and ByteSelect == 0, neither latch updates Prsd[15:8].
    check_no_latch_byte1: assert property (
        @(posedge Clk) disable iff (Reset)
        MdcEn_n && !|ByteSelect && !LatchByte[1] |=> (
            Prsd[15:8] == $past(Prsd[15:8]) &&
            LinkFail == $past(LinkFail)
        )
    );

// With MdcEn_n high and ByteSelect == 0, LinkFail only changes when Rgad==1 and the shifted bit is 0.
    check_linkfail_update: assert property (
        @(posedge Clk) disable iff (Reset)
        MdcEn_n && !|ByteSelect && (Rgad == 5'h01) |=> (
            LinkFail == ($past(ShiftReg[1]) ? $past(LinkFail) : ~ShiftReg[1])
        )
    );

// With MdcEn_n high and ByteSelect == 0, LinkFail only changes when Rgad==1 and the shifted bit is 0.
    check_linkfail_update: assert property (
        @(posedge Clk) disable iff (Reset)
        MdcEn_n && !|ByteSelect && (Rgad == 5'h01) |=> (
            LinkFail == ($past(ShiftReg[1]) ? $past(LinkFail) : ~ShiftReg[1])
        )
    );

// With MdcEn_n high and ByteSelect == 0, LinkFail only changes when Rgad==1 and the shifted bit is 0.
    check_linkfail_update: assert property (
        @(posedge Clk) disable iff (Reset)
        MdcEn_n && !|ByteSelect && (Rgad == 5'h01) |=> (
            LinkFail == ($past(ShiftReg[1]) ? $past(LinkFail) : ~ShiftReg[1])
        )
    );

endmodule
