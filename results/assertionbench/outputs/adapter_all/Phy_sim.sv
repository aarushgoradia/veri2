module Phy_sim_sva (
    input logic        Gtx_clk,
    input logic        Rx_clk,
    input logic        Tx_clk,
    input logic        Tx_er,
    input logic        Tx_en,
    input logic [7:0]  Txd,
    input logic        Rx_er,
    input logic        Rx_dv,
    input logic        Crs,
    input logic        Col,
    input logic [2:0]  Speed
);

    // Rx_er is tied low.
    check_rx_er_tied_low: assert property (
        @(posedge Rx_clk) Rx_er == 1'b0
    );

    // Crs mirrors Tx_en.
    check_crs_mirrors_tx_en: assert property (
        @(posedge Rx_clk) Crs == Tx_en
    );

    // Col is tied low.
    check_col_tied_low: assert property (
        @(posedge Rx_clk) Col == 1'b0
    );

    // Rx_dv mirrors Tx_en.
    check_rx_dv_mirrors_tx_en: assert property (
        @(posedge Rx_clk) Rx_dv == Tx_en
    );

    // Rxd mirrors Txd.
    check_rxd_mirrors_txd: assert property (
        @(posedge Rx_clk) Rxd == Txd
    );

    // In 100 Mbps mode, Tx_clk and Rx_clk come from Gtx_clk.
    check_100mbps_clk_sources: assert property (
        @(posedge Rx_clk) Speed[2] |-> (Tx_clk == Gtx_clk && Rx_clk == Gtx_clk)
    );

    // In 10 Mbps mode, Tx_clk and Rx_clk come from the 2.5 MHz clock.
    check_10mbps_clk_sources: assert property (
        @(posedge Rx_clk) !Speed[2] && Speed[1] |-> (Tx_clk == Gtx_clk && Rx_clk == Gtx_clk)
    );

    // In 1000 Mbps mode, Tx_clk and Rx_clk come from the 25 MHz clock.
    check_1000mbps_clk_sources: assert property (
        @(posedge Rx_clk) !Speed[2] && !Speed[1] && Speed[0] |-> (Tx_clk == Gtx_clk && Rx_clk == Gtx_clk)
    );

    // In 1000 Mbps mode, Tx_clk and Rx_clk are tied together.
    check_1000mbps_clk_tied: assert property (
        @(posedge Rx_clk) !Speed[2] && !Speed[1] && Speed[0] |-> (Tx_clk == Rx_clk)
    );

    // In 10 Mbps mode, Tx_clk and Rx_clk are tied together.
    check_10mbps_clk_tied: assert property (
        @(posedge Rx_clk) !Speed[2] && Speed[1] |-> (Tx_clk == Rx_clk)
    );

    // In 100 Mbps mode, Tx_clk and Rx_clk are tied together.
    check_100mbps_clk_tied: assert property (
        @(posedge Rx_clk) Speed[2] |-> (Tx_clk == Rx_clk)
    );

endmodule