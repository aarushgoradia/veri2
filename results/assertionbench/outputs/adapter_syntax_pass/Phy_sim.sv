module Phy_sim_sva (
    input logic        Gtx_clk,
    input logic        Rx_clk,
    input logic        Tx_clk,
    input logic        Tx_er,
    input logic        Tx_en,
    input logic [7:0]  Txd,
    input logic        Rx_er,
    input logic        Rx_dv,
    input logic [7:0]  Rxd,
    input logic        Crs,
    input logic        Col,
    input logic [2:0]  Speed
);

    // Rx_er is tied low.
    check_rx_er_tied_low: assert property (
        @(posedge Rx_clk) Rx_er == 1'b0
    );

    // Col is tied low.
    check_col_tied_low: assert property (
        @(posedge Rx_clk) Col == 1'b0
    );

    // Rx_dv mirrors Tx_en.
    check_rx_dv_matches_tx_en: assert property (
        @(posedge Rx_clk) Rx_dv == Tx_en
    );

    // Crs mirrors Tx_en.
    check_crs_matches_tx_en: assert property (
        @(posedge Rx_clk) Crs == Tx_en
    );

    // Rxd mirrors Txd.
    check_rxd_matches_txd: assert property (
        @(posedge Rx_clk) Rxd == Txd
    );

    // Tx_clk is selected from Gtx_clk or the internal 25MHz clock.
    check_tx_clk_select: assert property (
        @(posedge Rx_clk) Tx_clk == (Speed[2] ? Gtx_clk : (Speed[1] ? 1'b0 : 1'b0))
    );

    // Rx_clk is selected from Gtx_clk or the internal 2.5MHz clock.
    check_rx_clk_select: assert property (
        @(posedge Rx_clk) Rx_clk == (Speed[2] ? Gtx_clk : (Speed[1] ? 1'b0 : 1'b0))
    );

    // In 100Mbps mode, Tx_clk is driven by Gtx_clk.
    check_tx_clk_100mbps: assert property (
        @(posedge Rx_clk) Speed[2] |-> (Tx_clk == Gtx_clk)
    );

    // In 100Mbps mode, Rx_clk is driven by Gtx_clk.
    check_rx_clk_100mbps: assert property (
        @(posedge Rx_clk) Speed[2] |-> (Rx_clk == Gtx_clk)
    );

    // In 10Mbps mode, Tx_clk is driven by the internal 25MHz clock.
    check_tx_clk_10mbps: assert property (
        @(posedge Rx_clk) (!Speed[2] && Speed[1]) |-> (Tx_clk == 1'b0)
    );

    // In 10Mbps mode, Rx_clk is driven by the internal 25MHz clock.
    check_rx_clk_10mbps: assert property (
        @(posedge Rx_clk) (!Speed[2] && Speed[1]) |-> (Rx_clk == 1'b0)
    );

    // In 1000Mbps mode, Tx_clk is driven by Gtx_clk.
    check_tx_clk_1000mbps: assert property (
        @(posedge Rx_clk) Speed[2] |-> (Tx_clk == Gtx_clk)
    );

    // In 1000Mbps mode, Rx_clk is driven by Gtx_clk.
    check_rx_clk_1000mbps: assert property (
        @(posedge Rx_clk) Speed[2] |-> (Rx_clk == Gtx_clk)
    );

endmodule