```systemverilog
module eth_shiftreg_sva (
    input logic Clk,
    input logic Reset,
    input logic MdcEn_n,
    input logic Mdi,
    input [4:0] Fiad,
    input [4:0] Rgad,
    input [15:0] CtrlData,
    input logic WriteOp,
    input [3:0] ByteSelect,
    input [1:0] LatchByte,
    output logic ShiftedBit,
    output logic [15:0] Prsd,
    output logic LinkFail
);
    // Shift register should be reset to 0 on reset
    reset_shift_reg: assert property (
        @(posedge Clk) disable iff (!Reset) ShiftReg == 8'h0
    );

    // Prsd should be reset to 0 on reset
    reset_prsd: assert property (
        @(posedge Clk) disable iff (!Reset) Prsd == 16'h0
    );

    // LinkFail should be reset to 0 on reset
    reset_link_fail: assert property (
        @(posedge Clk) disable iff (!Reset) LinkFail == 1'b0
    );

    // ShiftReg should shift bits on the rising edge of Clk when MdcEn_n is asserted
    shift_reg_shift: assert property (
        @(posedge Clk) disable iff (!Reset) (MdcEn_n && |ByteSelect) |-> ShiftReg == {ShiftReg[6:0], Mdi}
    );

    // Prsd should be updated on the rising edge of Clk when LatchByte[0] is asserted
    prsd_update_latch_byte_0: assert property (
        @(posedge Clk) disable iff (!Reset) (LatchByte[0] && Rgad == 5'h01) |-> Prsd[7:0] == {ShiftReg[6:0], Mdi}
    );

    // Prsd should be updated on the rising edge of Clk when LatchByte[1] is asserted
    prsd_update_latch_byte_1: assert property (
        @(posedge Clk) disable iff (!Reset) LatchByte[1] |-> Prsd[15:8] == {ShiftReg[6:0], Mdi}
    );

    // LinkFail should be updated on the rising edge of Clk when Rgad is 0x01 and ShiftReg[1] is not shifted yet
    link_fail_update: assert property (
        @(posedge Clk) disable iff (!Reset) (Rgad == 5'h01 && ShiftReg[1] == 1'b0) |-> LinkFail == ~ShiftReg[1]
    );

    // ShiftedBit should be the least significant bit of ShiftReg
    shifted_bit_check: assert property (
        @(posedge Clk) disable iff (!Reset) ShiftedBit == ShiftReg[7]
    );

    // Prsd should be updated on the rising edge of Clk when ByteSelect[3:0] is 4'h1
    prsd_update_byte_select_1: assert property (
        @(posedge Clk) disable iff (!Reset) (ByteSelect[3:0] == 4'h1) |-> Prsd[7:0] == {2'b01, ~WriteOp, WriteOp, Fiad[4:1]}
    );

    // Prsd should be updated on the rising edge of Clk when ByteSelect[3:0] is 4'h2
    prsd_update_byte_select_2: assert property (
        @(posedge Clk) disable iff (!Reset) (ByteSelect[3:0] == 4'h2) |-> Prsd[7:0] == {Fiad[0], Rgad[4:0], 2'b10}
    );

    // Prsd should be updated on the rising edge of Clk when ByteSelect[3:0] is 4'h4
    prsd_update_byte_select_4: assert property (
        @(posedge Clk) disable iff (!Reset) (ByteSelect[3:0] == 4'h4) |-> Prsd[7:0] == CtrlData[15:8]
    );

    // Prsd should be updated on the rising edge of Clk when ByteSelect[3:0] is 4'h8
    prsd_update_byte_select_8: assert property (
        @(posedge Clk) disable iff (!Reset) (ByteSelect[3:0] == 4'h8) |-> Prsd[7:0] == CtrlData[7:0]
    );
endmodule
```