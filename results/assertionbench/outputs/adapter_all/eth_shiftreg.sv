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

    // ByteSelect 1 loads the PHY address and write control bits.
    check_shiftreg_load_byte1: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h1)) |=> (ShiftReg == {2'b01, ~WriteOp, WriteOp, Fiad[4:1]})
    );

    // ByteSelect 2 loads the PHY address and register address.
    check_shiftreg_load_byte2: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h2)) |=> (ShiftReg == {Fiad[0], Rgad[4:0], 2'b10})
    );

    // ByteSelect 4 loads the upper byte of CtrlData.
    check_shiftreg_load_byte4: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h4)) |=> (ShiftReg == CtrlData[15:8])
    );

    // ByteSelect 8 loads the lower byte of CtrlData.
    check_shiftreg_load_byte8: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h8)) |=> (ShiftReg == CtrlData[7:0])
    );

    // With no ByteSelect, ShiftReg shifts in Mdi on each enabled cycle.
    check_shiftreg_shift_mode: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h0)) |=> (ShiftReg == {ShiftReg[6:0], $past(Mdi)})
    );

    // In shift mode, Prsd holds its value when no byte is latched.
    check_prsd_holds_without_latch: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h0) && (LatchByte == 2'b00)) |=> (Prsd == $past(Prsd))
    );

    // In shift mode, LinkFail holds its value when the PHY address is not 0x01.
    check_linkfail_holds_without_latch: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h0) && (LatchByte == 2'b00) && (Rgad != 5'h01)) |=> (LinkFail == $past(LinkFail))
    );

    // In shift mode, LinkFail loads bit [2] of ShiftReg when the PHY address is 0x01.
    check_linkfail_loads_from_shiftreg: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h0) && (LatchByte == 2'b00) && (Rgad == 5'h01)) |=> (LinkFail == $past(ShiftReg[1]))
    );

    // In shift mode, Prsd[7:0] loads the previous ShiftReg[6:0] and Mdi when LatchByte[0] is set.
    check_prsd_latches_low_byte: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h0) && (LatchByte == 2'b01)) |=> (Prsd[7:0] == { $past(ShiftReg[6:0]), $past(Mdi) })
    );

    // In shift mode, Prsd[15:8] loads the previous ShiftReg[6:0] and Mdi when LatchByte[1] is set.
    check_prsd_latches_high_byte: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h0) && (LatchByte == 2'b10)) |=> (Prsd[15:8] == { $past(ShiftReg[6:0]), $past(Mdi) })
    );

    // In shift mode, Prsd[15:8] holds when neither latching bit is set.
    check_prsd_high_byte_holds_without_latch: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h0) && (LatchByte == 2'b00)) |=> (Prsd[15:8] == $past(Prsd[15:8]))
    );

    // In shift mode, Prsd[7:0] holds when neither latching bit is set.
    check_prsd_low_byte_holds_without_latch: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h0) && (LatchByte == 2'b00)) |=> (Prsd[7:0] == $past(Prsd[7:0]))
    );

    // ShiftedBit is the MSB of ShiftReg on each clock.
    check_shiftedbit_matches_shiftreg: assert property (
        @(posedge Clk) disable iff (Reset)
        ShiftedBit == ShiftReg[7]
    );

endmodule