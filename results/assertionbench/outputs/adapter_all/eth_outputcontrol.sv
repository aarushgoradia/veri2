module eth_outputcontrol_sva #(
    parameter Tp = 1
) (
    input logic Clk,
    input logic Reset,
    input logic InProgress,
    input logic ShiftedBit,
    input logic [6:0] BitCounter,
    input logic WriteOp,
    input logic NoPre,
    input logic MdcEn_n,
    input logic Mdo,
    input logic MdoEn
);

    // Reset clears both outputs by the next clock.
    check_reset_clears_outputs: assert property (
        @(posedge Clk) Reset |=> ((MdoEn == 1'b0) && (Mdo == 1'b0))
    );

    // MdoEn is low whenever MdcEn_n is low.
    check_mdoen_low_when_mdcen_low: assert property (
        @(posedge Clk) disable iff (Reset) (!MdcEn_n) |-> (MdoEn == 1'b0)
    );

    // Mdo is low whenever MdcEn_n is low.
    check_mdo_low_when_mdcen_low: assert property (
        @(posedge Clk) disable iff (Reset) (!MdcEn_n) |-> (Mdo == 1'b0)
    );

    // MdoEn is low whenever the write path is inactive.
    check_mdoen_low_when_write_inactive: assert property (
        @(posedge Clk) disable iff (Reset)
        (!MdcEn_n && !WriteOp) |-> (MdoEn == 1'b0)
    );

    // MdoEn is low whenever the read path is inactive.
    check_mdoen_low_when_read_inactive: assert property (
        @(posedge Clk) disable iff (Reset)
        (!MdcEn_n && WriteOp && !InProgress) |-> (MdoEn == 1'b0)
    );

    // MdoEn is low whenever the active read bit range is not selected.
    check_mdoen_low_when_read_range_inactive: assert property (
        @(posedge Clk) disable iff (Reset)
        (!MdcEn_n && WriteOp && InProgress &&
         (BitCounter <= 7 || (BitCounter >= 46 && BitCounter <= 53))) |-> (MdoEn == 1'b0)
    );

    // MdoEn is high whenever the active write bit range is selected.
    check_mdoen_high_when_write_range_active: assert property (
        @(posedge Clk) disable iff (Reset)
        (!MdcEn_n && WriteOp && InProgress &&
         (BitCounter > 31 || (BitCounter == 0 && NoPre))) |-> (MdoEn == 1'b1)
    );

    // Mdo is low whenever the active write bit range is selected.
    check_mdo_low_when_write_range_active: assert property (
        @(posedge Clk) disable iff (Reset)
        (!MdcEn_n && WriteOp && InProgress &&
         (BitCounter > 31 || (BitCounter == 0 && NoPre))) |-> (Mdo == 1'b0)
    );

    // MdoEn is low whenever the active read preamble range is not selected.
    check_mdoen_low_when_read_preamble_inactive: assert property (
        @(posedge Clk) disable iff (Reset)
        (!MdcEn_n && WriteOp && InProgress &&
         (BitCounter > 31 && BitCounter < 46)) |-> (MdoEn == 1'b0)
    );

    // Mdo is high whenever the active read preamble range is selected.
    check_mdo_high_when_read_preamble_active: assert property (
        @(posedge Clk) disable iff (Reset)
        (!MdcEn_n && WriteOp && InProgress &&
         (BitCounter > 31 && BitCounter < 46)) |-> (Mdo == 1'b1)
    );

    // MdoEn is high whenever the active write preamble range is selected.
    check_mdoen_high_when_write_preamble_active: assert property (
        @(posedge Clk) disable iff (Reset)
        (!MdcEn_n && WriteOp && InProgress &&
         (BitCounter == 0 && NoPre)) |-> (MdoEn == 1'b1)
    );

    // Mdo is low whenever the active write preamble range is selected.
    check_mdo_low_when_write_preamble_active: assert property (
        @(posedge Clk) disable iff (Reset)
        (!MdcEn_n && WriteOp && InProgress &&
         (BitCounter == 0 && NoPre)) |-> (Mdo == 1'b0)
    );

endmodule