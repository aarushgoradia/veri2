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

// MCrs_dv is low when reset is asserted.
    check_mcrs_dv_low_on_reset: assert property (
        @(posedge MAC_rx_clk) Reset |-> (MCrs_dv == 1'b0)
    );

// MRxErr is low when reset is asserted.
    check_mrxd_err_low_on_reset: assert property (
        @(posedge MAC_rx_clk) Reset |-> (MRxErr == 1'b0)
    );

// MCRS is low when reset is asserted.
    check_mcrs_low_on_reset: assert property (
        @(posedge MAC_rx_clk) Reset |-> (MCRS == 1'b0)
    );

// Tx_er is always low.
    check_tx_er_low: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset)
        (Tx_er == 1'b0)
    );

// Tx_en is low when reset is asserted.
    check_tx_en_low_on_reset: assert property (
        @(posedge MAC_tx_clk) Reset |-> (Tx_en == 1'b0)
    );

// Txd is zero when reset is asserted.
    check_txd_zero_on_reset: assert property (
        @(posedge MAC_tx_clk) Reset |-> (Txd == 8'h00)
    );

// MRxD is zero when reset is asserted.
    check_mrxd_zero_on_reset: assert property (
        @(posedge MAC_rx_clk) Reset |-> (MRxD == 8'h00)
    );

// MCrs_dv is low when reset is asserted.
    check_mcrs_dv_low_on_reset_rx: assert property (
        @(posedge MAC_rx_clk) Reset |-> (MCrs_dv == 1'b0)
    );

// Rx_odd_data_ptr is cleared when reset is asserted.
    check_rx_odd_data_ptr_zero_on_reset: assert property (
        @(posedge MAC_rx_clk) Reset |-> (Rx_odd_data_ptr == 1'b0)
    );

// Tx_odd_data_ptr is cleared when reset is asserted.
    check_tx_odd_data_ptr_zero_on_reset: assert property (
        @(posedge MAC_tx_clk) Reset |-> (Tx_odd_data_ptr == 1'b0)
    );

endmodule
