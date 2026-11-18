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

    // Reset clears the shift register and read-status data.
    check_reset_clears_state: assert property (
        @(posedge Clk) Reset |-> ((ShiftReg == 8'h00) && (Prsd == 16'h00) && (LinkFail == 1'b0))
    );

    // ByteSelect 1 loads the PHY address and write control into the shift register.
    check_shiftreg_load_fiad: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h1)) |=> (ShiftReg == {2'b01, ~WriteOp, WriteOp, Fiad[4:1]})
    );

    // ByteSelect 2 loads the register address and control bits into the shift register.
    check_shiftreg_load_rgad: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h2)) |=> (ShiftReg == {Fiad[0], Rgad[4:0], 2'b10})
    );

    // ByteSelect 4 loads the upper byte of CtrlData into the shift register.
    check_shiftreg_load_ctrl_upper: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h4)) |=> (ShiftReg == CtrlData[15:8])
    );

    // ByteSelect 8 loads the lower byte of CtrlData into the shift register.
    check_shiftreg_load_ctrl_lower: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h8)) |=> (ShiftReg == CtrlData[7:0])
    );

    // With no active ByteSelect, the shift register shifts in Mdi.
    check_shiftreg_shift_mode: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h0)) |=> (ShiftReg == {ShiftReg[6:0], $past(Mdi)})
    );

    // LatchByte[0] captures the shifted data into Prsd[7:0].
    check_prsd_capture_lower: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h0) && LatchByte[0]) |=> (Prsd[7:0] == {ShiftReg[6:0], $past(Mdi)})
    );

    // LatchByte[1] captures the shifted data into Prsd[15:8].
    check_prsd_capture_upper: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h0) && LatchByte[1]) |=> (Prsd[15:8] == {ShiftReg[6:0], $past(Mdi)})
    );

    // LinkFail is updated from bit 1 of the captured status when reading PHY 01h.
    check_linkfail_update: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n && (ByteSelect == 4'h0) && LatchByte[0] && (Rgad == 5'h01)) |=> (LinkFail == ~$past(ShiftReg[1]))
    );

    // ShiftedBit is the MSB of the shift register.
    check_shiftedbit_definition: assert property (
        @(posedge Clk) disable iff (Reset)
        (ShiftedBit == ShiftReg[7])
    );

endmodule