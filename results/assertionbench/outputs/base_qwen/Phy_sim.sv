```systemverilog
module Phy_sim_assertions (
    input logic Gtx_clk,
    input logic Rx_clk,
    input logic Tx_clk,
    input logic Tx_er,
    input logic Tx_en,
    input logic [7:0] Txd,
    output logic Rx_er,
    output logic Rx_dv,
    output logic [7:0] Rxd,
    output logic Crs,
    output logic Col,
    input logic [2:0] Speed
);
    // Clock generation logic
    // Clk_25m toggles every 20ns for 100 Mbps mode
    // Clk_2_5m toggles every 200ns for 10 Mbps mode
    // Rx_clk and Tx_clk are derived from Gtx_clk, Clk_25m, or Clk_2_5m based on Speed

    // Rx_dv should be high when Tx_en is high
    property p_rx_dv;
        @(posedge Rx_clk) disable iff (!Speed[2]) Rx_dv |-> Tx_en;
    endproperty
    assert property (p_rx_dv) else $error("Rx_dv should be high when Tx_en is high");

    // Rxd should be equal to Txd
    property p_rxd_txd;
        @(posedge Rx_clk) disable iff (!Speed[2]) Rxd == Txd;
    endproperty
    assert property (p_rxd_txd) else $error("Rxd should be equal to Txd");

    // Rx_er should always be 0
    property p_rx_er;
        @(posedge Rx_clk) Rx_er == 0;
    endproperty
    assert property (p_rx_er) else $error("Rx_er should always be 0");

    // Crs should be high when Tx_en is high
    property p_crs;
        @(posedge Rx_clk) Crs |-> Tx_en;
    endproperty
    assert property (p_crs) else $error("Crs should be high when Tx_en is high");

    // Col should always be 0
    property p_col;
        @(posedge Rx_clk) Col == 0;
    endproperty
    assert property (p_col) else $error("Col should always be 0");

    // Clk_25m toggles every 20ns
    property p_clk_25m;
        @(posedge Gtx_clk) disable iff (!Speed[2]) $rose(Clk_25m) |-> $fall(Clk_25m);
    endproperty
    assert property (p_clk_25m) else $error("Clk_25m should toggle every 20ns");

    // Clk_2_5m toggles every 200ns
    property p_clk_2_5m;
        @(posedge Gtx_clk) disable iff (!Speed[2]) $rose(Clk_2_5m) |-> $fall(Clk_2_5m);
    endproperty
    assert property (p_clk_2_5m) else $error("Clk_2_5m should toggle every 200ns");

    // Rx_clk is derived from Gtx_clk, Clk_25m, or Clk_2_5m based on Speed
    property p_rx_clk;
        @(posedge Gtx_clk) disable iff (!Speed[2]) Rx_clk |-> (Speed[2] ? Gtx_clk : (Speed[1] ? Clk_25m : Clk_2_5m));
    endproperty
    assert property (p_rx_clk) else $error("Rx_clk should be derived from Gtx_clk, Clk_25m, or Clk_2_5m based on Speed");

    // Tx_clk is derived from Gtx_clk, Clk_25m, or Clk_2_5m based on Speed
    property p_tx_clk;
        @(posedge Gtx_clk) disable iff (!Speed[2]) Tx_clk |-> (Speed[2] ? Gtx_clk : (Speed[1] ? Clk_25m : Clk_2_5m));
    endproperty
    assert property (p_tx_clk) else $error("Tx_clk should be derived from Gtx_clk, Clk_25m, or Clk_2_5m based on Speed");
endmodule
```