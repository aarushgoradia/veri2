module Phy_int_sva (
    input logic Reset,
    input logic MAC_rx_clk,
    input logic MAC_tx_clk,
    input logic MCrs_dv,
    input logic [7:0] MRxD,
    input logic MRxErr,
    input logic [7:0] MTxD,
    input logic MTxEn,
    input logic MCRS,
    input logic Tx_er,
    input logic Tx_en,
    input logic [7:0] Txd,
    input logic Rx_er,
    input logic Rx_dv,
    input logic [7:0] Rxd,
    input logic Crs,
    input logic Col,
    input logic Line_loop_en,
    input logic [2:0] Speed
);

    ///// Reset behavior /////
    // During reset, Tx_er must be 0.
    reset_tx_er_low: assert property (
        @(posedge MAC_tx_clk) Reset |-> (Tx_er == 1'b0)
    );
    // During reset, MCrs_dv must be 0.
    reset_mcrs_dv_low: assert property (
        @(posedge MAC_rx_clk) Reset |-> (MCrs_dv == 1'b0)
    );
    // During reset, MRxErr must be 0.
    reset_mrxd_err_low: assert property (
        @(posedge MAC_rx_clk) Reset |-> (MRxErr == 1'b0)
    );
    // During reset, Tx_en must be 0.
    reset_tx_en_low: assert property (
        @(posedge MAC_tx_clk) Reset |-> (Tx_en == 1'b0)
    );
    // During reset, MRxD must be 0.
    reset_mrxd_zero: assert property (
        @(posedge MAC_rx_clk) Reset |-> (MRxD == 8'h00)
    );
    // During reset, Txd must be 0.
    reset_txd_zero: assert property (
        @(posedge MAC_tx_clk) Reset |-> (Txd == 8'h00)
    );
    // During reset, MRxD must be 0.
    reset_mrxd_zero: assert property (
        @(posedge MAC_rx_clk) Reset |-> (MRxD == 8'h00)
    );
    // During reset, Rx_odd_data_ptr must be 0.
    reset_rx_odd_ptr_zero: assert property (
        @(posedge MAC_rx_clk) Reset |-> (Rx_odd_data_ptr == 1'b0)
    );
    // During reset, Tx_odd_data_ptr must be 0.
    reset_tx_odd_ptr_zero: assert property (
        @(posedge MAC_tx_clk) Reset |-> (Tx_odd_data_ptr == 1'b0)
    );

    ///// Tx control /////
    // Tx_er is always 0.
    tx_er_constant_zero: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset) (Tx_er == 1'b0)
    );
    // Tx_en is high only when MTxEn_dl1 is high.
    tx_en_matches_mt xen_dl1: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset) (Tx_en == MTxEn_dl1)
    );
    // Txd is zero-extended from MTxD_dl1 when MTxEn_dl1 is high.
    txd_zero_extended_when_enabled: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset) MTxEn_dl1 |-> (Txd == {4'b0, MTxD_dl1})
    );
    // Txd is zero when MTxEn_dl1 is low.
    txd_zero_when_disabled: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset) !MTxEn_dl1 |-> (Txd == 8'h00)
    );
    // Txd is always even when MTxEn_dl1 is high.
    txd_even_when_enabled: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset) MTxEn_dl1 |-> (Txd[0] == 1'b0)
    );
    // Txd is always odd when MTxEn_dl1 is low.
    txd_odd_when_disabled: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset) !MTxEn_dl1 |-> (Txd[0] == 1'b1)
    );

    ///// Rx control /////
    // MRxErr mirrors Rx_er_dl1.
    mrxd_err_follows_rx_er_dl1: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) (MRxErr == Rx_er_dl1)
    );
    // MCRS mirrors Crs_dl1.
    mcrs_follows_crs_dl1: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) (MCRS == Crs_dl1)
    );
    // MCrs_dv is high only when Line_loop_en is high and Tx_en is high.
    mcrs_dv_when_line_loop_and_tx_en: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) (MCrs_dv == (Line_loop_en && Tx_en))
    );
    // MCrs_dv is high only when Line_loop_en is high and Rx_dv_dl2 is high.
    mcrs_dv_when_line_loop_and_rx_dv: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) (MCrs_dv == (Line_loop_en && Rx_dv_dl2))
    );
    // MCrs_dv is high only when Line_loop_en is high.
    mcrs_dv_when_line_loop: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) (MCrs_dv == Line_loop_en)
    );
    // MCrs_dv is high only when Rx_dv_dl2 is high.
    mcrs_dv_when_rx_dv: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) (MCrs_dv == Rx_dv_dl2)
    );
    // MCrs_dv is low when Line_loop_en is low.
    mcrs_dv_low_when_not_line_loop: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) (!Line_loop_en) |-> (MCrs_dv == 1'b0)
    );
    // MCrs_dv is low when Rx_dv_dl2 is low.
    mcrs_dv_low_when_not_rx_dv: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) (!Rx_dv_dl2) |-> (MCrs_dv == 1'b0)
    );

endmodule