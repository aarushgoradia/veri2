module eth_outputcontrol_sva (
    input logic        Clk,
    input logic        Reset,
    input logic        WriteOp,
    input logic        NoPre,
    input logic        InProgress,
    input logic        ShiftedBit,
    input logic [6:0]  BitCounter,
    input logic        MdcEn_n,
    input logic        Mdo,
    input logic        MdoEn
);

// MdoEn is low when Reset is asserted.
    check_mdoen_reset_low: assert property (
        @(posedge Clk) Reset |-> (MdoEn == 1'b0)
    );

// Mdo is low when Reset is asserted.
    check_mdo_reset_low: assert property (
        @(posedge Clk) Reset |-> (Mdo == 1'b0)
    );

// MdoEn is low when MdcEn_n is low.
    check_mdoen_low_when_mdcen_low: assert property (
        @(posedge Clk) disable iff (Reset) (!MdcEn_n) |-> (MdoEn == 1'b0)
    );

// Mdo is low when MdcEn_n is low.
    check_mdo_low_when_mdcen_low: assert property (
        @(posedge Clk) disable iff (Reset) (!MdcEn_n) |-> (Mdo == 1'b0)
    );

// MdoEn is high when MdcEn_n is high and the enable condition is true.
    check_mdoen_high_when_enabled: assert property (
        @(posedge Clk) disable iff (Reset) (MdcEn_n && enable_condition) |-> (MdoEn == 1'b1)
    );

// Mdo is high when MdcEn_n is high and the data output condition is true.
    check_mdo_high_when_data_enabled: assert property (
        @(posedge Clk) disable iff (Reset) (MdcEn_n && data_condition) |-> (Mdo == 1'b1)
    );

// MdoEn is low when MdcEn_n is high and the enable condition is false.
    check_mdoen_low_when_disabled: assert property (
        @(posedge Clk) disable iff (Reset) (MdcEn_n && !enable_condition) |-> (MdoEn == 1'b0)
    );

// Mdo is low when MdcEn_n is high and the data output condition is false.
    check_mdo_low_when_data_disabled: assert property (
        @(posedge Clk) disable iff (Reset) (MdcEn_n && !data_condition) |-> (Mdo == 1'b0)
    );

endmodule
