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

    // MdoEn is low whenever reset is asserted.
    check_mdoen_reset: assert property (
        @(posedge Clk) Reset |-> (MdoEn == 1'b0)
    );

    // Mdo is low whenever reset is asserted.
    check_mdo_reset: assert property (
        @(posedge Clk) Reset |-> (Mdo == 1'b0)
    );

    // MdoEn is low whenever the previous cycle was not in the MDC enable window.
    check_mdoen_idle_low: assert property (
        @(posedge Clk) disable iff (Reset)
        !$past(MdcEn_n) |-> (MdoEn == 1'b0)
    );

    // Mdo is low whenever the previous cycle was not in the MDC enable window.
    check_mdo_idle_low: assert property (
        @(posedge Clk) disable iff (Reset)
        !$past(MdcEn_n) |-> (Mdo == 1'b0)
    );

    // MdoEn is high on the first cycle after MdcEn_n is high.
    check_mdoen_rise_on_mdc_enable: assert property (
        @(posedge Clk) disable iff (Reset)
        $past(!MdcEn_n && MdcEn_n) |-> (MdoEn == 1'b1)
    );

    // Mdo is high on the first cycle after MdcEn_n is high.
    check_mdo_rise_on_mdc_enable: assert property (
        @(posedge Clk) disable iff (Reset)
        $past(!MdcEn_n && MdcEn_n) |-> (Mdo == 1'b1)
    );

    // MdoEn is low on the first cycle after MdcEn_n is low.
    check_mdoen_fall_on_mdc_disable: assert property (
        @(posedge Clk) disable iff (Reset)
        $past(MdcEn_n && !MdcEn_n) |-> (MdoEn == 1'b0)
    );

    // Mdo is low on the first cycle after MdcEn_n is low.
    check_mdo_fall_on_mdc_disable: assert property (
        @(posedge Clk) disable iff (Reset)
        $past(MdcEn_n && !MdcEn_n) |-> (Mdo == 1'b0)
    );

    // MdoEn is the registered delayed version of the previous cycle's MdoEn logic.
    check_mdoen_registered_update: assert property (
        @(posedge Clk) disable iff (Reset)
        !$past(Reset) |-> (MdoEn == $past(MdoEn_2d))
    );

    // Mdo is the registered delayed version of the previous cycle's Mdo logic.
    check_mdo_registered_update: assert property (
        @(posedge Clk) disable iff (Reset)
        !$past(Reset) |-> (Mdo == $past(Mdo_d))
    );

endmodule