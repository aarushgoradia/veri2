module Phy_sim_sva (
    input logic Gtx_clk,
    input logic Rx_clk,
    input logic Tx_clk,
    input logic Tx_er,
    input logic Tx_en,
    input logic [7:0] Txd,
    input logic Rx_er,
    input logic Rx_dv,
    input logic [7:0] Rxd,
    input logic Crs,
    input logic Col,
    input logic [2:0] Speed
);

// Rx_dv mirrors Tx_en.
    check_rx_dv_follows_tx_en: assert property (
        @(posedge Rx_clk) Rx_dv == Tx_en
    );

// Rxd mirrors Txd.
    check_rxd_follows_txd: assert property (
        @(posedge Rx_clk) Rxd == Txd
    );

// Rx_er is always 0.
    check_rx_er_constant_zero: assert property (
        @(posedge Rx_clk) Rx_er == 1'b0
    );

// Crs mirrors Tx_en.
    check_crs_follows_tx_en: assert property (
        @(posedge Rx_clk) Crs == Tx_en
    );

// Col is always 0.
    check_col_constant_zero: assert property (
        @(posedge Rx_clk) Col == 1'b0
    );

// Tx_er is unused and has no effect.
    check_tx_er_unused: assert property (
        @(posedge Rx_clk) Tx_er == 1'b0
    );

// Tx_clk is always 0 in this RTL.
    check_tx_clk_zero: assert property (
        @(posedge Rx_clk) Tx_clk == 1'b0
    );

// Rx_clk is driven by the selected clock source.
    check_rx_clk_source: assert property (
        @(posedge Rx_clk) Rx_clk == (Speed[2] ? Gtx_clk : (Speed[1] ? Clk_25m : (Speed[0] ? Clk_2_5m : 1'b0)))
    );

// Clk_25m is a 25-MHz clock generator.
    check_clk_25m_generator: assert property (
        @(posedge Rx_clk) Clk_25m == (Clk_25m_prev ? 1'b0 : 1'b1)
    );

// Clk_2_5m is a 2.5-MHz clock generator.
    check_clk_2_5m_generator: assert property (
        @(posedge Rx_clk) Clk_2_5m == (Clk_2_5m_prev ? 1'b0 : 1'b1)
    );

// Speed[2] selects Gtx_clk when high.
    check_speed2_selects_gtxclk: assert property (
        @(posedge Rx_clk) Speed[2] |-> (Rx_clk == Gtx_clk)
    );

// Speed[1] selects Clk_25m when high and Speed[2] is low.
    check_speed1_selects_clk25m: assert property (
        @(posedge Rx_clk) (!Speed[2] && Speed[1]) |-> (Rx_clk == Clk_25m)
    );

// Speed[0] selects Clk_2_5m when high and neither Speed[2:1] is high.
    check_speed0_selects_clk2_5m: assert property (
        @(posedge Rx_clk) (!Speed[2] && !Speed[1] && Speed[0]) |-> (Rx_clk == Clk_2_5m)
    );

// No valid Speed encoding selects 0.
    check_default_selects_zero: assert property (
        @(posedge Rx_clk) (!Speed[2] && !Speed[1] && !Speed[0]) |-> (Rx_clk == 1'b0)
    );

// Rx_clk is never high when no valid clock source is selected.
    check_rx_clk_low_when_no_source: assert property (
        @(posedge Rx_clk) (!Speed[2] && !Speed[1] && !Speed[0]) |-> (Rx_clk == 1'b0)
    );

// Rx_clk is never high when Speed[2] is high and Gtx_clk is low.
    check_rx_clk_low_when_speed2_without_gtxclk: assert property (
        @(posedge Rx_clk) (Speed[2] && !Gtx_clk) |-> (Rx_clk == 1'b0)
    );

// Rx_clk is never high when Speed[1] is high and Clk_25m is low.
    check_rx_clk_low_when_speed1_without_clk25m: assert property (
        @(posedge Rx_clk) (Speed[1] && !Clk_25m) |-> (Rx_clk == 1'b0)
    );

// Rx_clk is never high when Speed[0] is high and Clk_2_5m is low.
    check_rx_clk_low_when_speed0_without_clk2_5m: assert property (
        @(posedge Rx_clk) (Speed[0] && !Clk_2_5m) |-> (Rx_clk == 1'b0)
    );

endmodule
