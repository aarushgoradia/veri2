```systemverilog
module Phy_int_sva (
    input logic Reset,
    input logic MAC_rx_clk,
    input logic MAC_tx_clk,
    output logic MCrs_dv,
    output logic [7:0] MRxD,
    output logic MRxErr,
    input logic [7:0] MTxD,
    input logic MTxEn,
    output logic MCRS,
    output logic Tx_er,
    output logic Tx_en,
    output logic [7:0] Txd,
    input logic Rx_er,
    input logic Rx_dv,
    input logic [7:0] Rxd,
    input logic Crs,
    input logic Col,
    input logic Line_loop_en,
    input logic [2:0] Speed
);
    // Reset behavior
    reset: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) (Reset == 1'b0)
    );

    // Tx interface behavior
    // MTxEn_dl1 can only transition from HIGH to LOW when MTxEn is LOW.
    tx_en_dl1_fall: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $fell(MTxEn_dl1) |-> (MTxEn == 1'b0)
    );

    // Txd can only transition from HIGH to LOW when MTxEn_dl1 is LOW.
    txd_fall: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $fell(Txd) |-> (MTxEn_dl1 == 1'b0)
    );

    // Rx interface behavior
    // Rx_dv_dl2 can only transition from HIGH to LOW when Rx_dv_dl1 is LOW.
    rx_dv_dl2_fall: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(Rx_dv_dl2) |-> (Rx_dv_dl1 == 1'b0)
    );

    // MRxD can only transition from HIGH to LOW when Rx_dv_dl2 is LOW.
    mrxd_fall: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(MRxD) |-> (Rx_dv_dl2 == 1'b0)
    );

    // MCrs_dv can only transition from HIGH to LOW when Rx_dv_dl2 is LOW.
    mcrs_fall: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(MCrs_dv) |-> (Rx_dv_dl2 == 1'b0)
    );

    // Line_loop_en can only transition from HIGH to LOW when Rx_dv_dl2 is LOW.
    line_loop_en_fall: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(Line_loop_en) |-> (Rx_dv_dl2 == 1'b0)
    );

    // Speed[2] can only transition from HIGH to LOW when Rx_dv_dl2 is LOW.
    speed_2_fall: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(Speed[2]) |-> (Rx_dv_dl2 == 1'b0)
    );

    // Crs_dl1 can only transition from HIGH to LOW when Rx_dv_dl2 is LOW.
    crs_dl1_fall: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(Crs_dl1) |-> (Rx_dv_dl2 == 1'b0)
    );

    // Col_dl1 can only transition from HIGH to LOW when Rx_dv_dl2 is LOW.
    col_dl1_fall: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(Col_dl1) |-> (Rx_dv_dl2 == 1'b0)
    );

    // Tx_er is always 0.
    tx_er_zero: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) Tx_er == 1'b0
    );

    // MCRS can only transition from HIGH to LOW when Tx_en is LOW.
    mcrs_tx_en_fall: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(MCRS) |-> (Tx_en == 1'b0)
    );

    // MRxErr is always equal to Rx_er_dl1.
    mrxerr_equal_rx_er_dl1: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) MRxErr == Rx_er_dl1
    );

    // MCrs_dv can only transition from HIGH to LOW when Tx_en is LOW.
    mcrs_tx_en_fall_2: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(MCrs_dv) |-> (Tx_en == 1'b0)
    );

    // MRxD can only transition from HIGH to LOW when Txd is LOW.
    mrxd_txd_fall: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(MRxD) |-> (Txd == 1'b0)
    );

    // Rx_odd_data_ptr can only transition from HIGH to LOW when Rx_dv_dl1 is LOW.
    rx_odd_data_ptr_fall: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(Rx_odd_data_ptr) |-> (Rx_dv_dl1 == 1'b0)
    );

    // Tx_odd_data_ptr can only transition from HIGH to LOW when MTxEn_dl1 is LOW.
    tx_odd_data_ptr_fall: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $fell(Tx_odd_data_ptr) |-> (MTxEn_dl1 == 1'b0)
    );

    // MTxD_dl1 can only transition from HIGH to LOW when MTxEn_dl1 is LOW.
    mtxd_dl1_fall: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $fell(MTxD_dl1) |-> (MTxEn_dl1 == 1'b0)
    );

    // MTxD_dl1 can only transition from LOW to HIGH when MTxEn_dl1 is HIGH.
    mtxd_dl1_rose: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(MTxD_dl1) |-> (MTxEn_dl1 == 1'b1)
    );

    // Txd can only transition from LOW to HIGH when MTxEn_dl1 is HIGH and Speed[2] is HIGH.
    txd_rose: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(Txd) |-> (MTxEn_dl1 == 1'b1 && Speed[2] == 1'b1)
    );

    // MRxD can only transition from LOW to HIGH when Rx_dv_dl2 is HIGH and Speed[2] is HIGH.
    mrxd_rose: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(MRxD) |-> (Rx_dv_dl2 == 1'b1 && Speed[2] == 1'b1)
    );

    // MRxD can only transition from LOW to HIGH when Txd is HIGH and Rx_odd_data_ptr is HIGH.
    mrxd_rose_2: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(MRxD) |-> (Txd == 1'b1 && Rx_odd_data_ptr == 1'b1)
    );

    // Txd can only transition from LOW to HIGH when Rx_dv_dl1 is HIGH and Rx_odd_data_ptr is HIGH.
    txd_rose_2: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(Txd) |-> (Rx_dv_dl1 == 1'b1 && Rx_odd_data_ptr == 1'b1)
    );

    // Tx_en can only transition from LOW to HIGH when MTxEn_dl1 is HIGH.
    tx_en_rose: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(Tx_en) |-> (MTxEn_dl1 == 1'b1)
    );

    // Tx_en can only transition from HIGH to LOW when MTxEn_dl1 is LOW.
    tx_en_fall: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $fell(Tx_en) |-> (MTxEn_dl1 == 1'b0)
    );

    // MCrs_dv can only transition from LOW to HIGH when Tx_en is HIGH.
    mcrs_rose: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(MCrs_dv) |-> (Tx_en == 1'b1)
    );

    // MCrs_dv can only transition from HIGH to LOW when Tx_en is LOW.
    mcrs_fall_2: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(MCrs_dv) |-> (Tx_en == 1'b0)
    );

    // MRxD can only transition from LOW to HIGH when Txd is HIGH.
    mrxd_rose_3: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(MRxD) |-> (Txd == 1'b1)
    );

    // MRxD can only transition from HIGH to LOW when Txd is LOW.
    mrxd_fall_2: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(MRxD) |-> (Txd == 1'b0)
    );

    // Rx_odd_data_ptr can only transition from LOW to HIGH when Rx_dv_dl1 is HIGH.
    rx_odd_data_ptr_rose: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(Rx_odd_data_ptr) |-> (Rx_dv_dl1 == 1'b1)
    );

    // Tx_odd_data_ptr can only transition from LOW to HIGH when MTxEn_dl1 is HIGH.
    tx_odd_data_ptr_rose: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(Tx_odd_data_ptr) |-> (MTxEn_dl1 == 1'b1)
    );

    // MTxD_dl1 can only transition from LOW to HIGH when MTxEn_dl1 is HIGH.
    mtxd_dl1_rose_2: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(MTxD_dl1) |-> (MTxEn_dl1 == 1'b1)
    );

    // MTxD_dl1 can only transition from HIGH to LOW when MTxEn_dl1 is LOW.
    mtxd_dl1_fall_2: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $fell(MTxD_dl1) |-> (MTxEn_dl1 == 1'b0)
    );

    // Txd can only transition from LOW to HIGH when MTxEn_dl1 is HIGH and Speed[2] is HIGH.
    txd_rose_3: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(Txd) |-> (MTxEn_dl1 == 1'b1 && Speed[2] == 1'b1)
    );

    // MRxD can only transition from LOW to HIGH when Rx_dv_dl2 is HIGH and Speed[2] is HIGH.
    mrxd_rose_4: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(MRxD) |-> (Rx_dv_dl2 == 1'b1 && Speed[2] == 1'b1)
    );

    // MRxD can only transition from LOW to HIGH when Txd is HIGH and Rx_odd_data_ptr is HIGH.
    mrxd_rose_5: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(MRxD) |-> (Txd == 1'b1 && Rx_odd_data_ptr == 1'b1)
    );

    // Txd can only transition from LOW to HIGH when Rx_dv_dl1 is HIGH and Rx_odd_data_ptr is HIGH.
    txd_rose_4: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(Txd) |-> (Rx_dv_dl1 == 1'b1 && Rx_odd_data_ptr == 1'b1)
    );

    // Tx_en can only transition from LOW to HIGH when MTxEn_dl1 is HIGH.
    tx_en_rose_2: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(Tx_en) |-> (MTxEn_dl1 == 1'b1)
    );

    // Tx_en can only transition from HIGH to LOW when MTxEn_dl1 is LOW.
    tx_en_fall_2: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $fell(Tx_en) |-> (MTxEn_dl1 == 1'b0)
    );

    // MCrs_dv can only transition from LOW to HIGH when Tx_en is HIGH.
    mcrs_rose_2: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(MCrs_dv) |-> (Tx_en == 1'b1)
    );

    // MCrs_dv can only transition from HIGH to LOW when Tx_en is LOW.
    mcrs_fall_3: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(MCrs_dv) |-> (Tx_en == 1'b0)
    );

    // MRxD can only transition from LOW to HIGH when Txd is HIGH.
    mrxd_rose_6: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(MRxD) |-> (Txd == 1'b1)
    );

    // MRxD can only transition from HIGH to LOW when Txd is LOW.
    mrxd_fall_3: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(MRxD) |-> (Txd == 1'b0)
    );

    // Rx_odd_data_ptr can only transition from LOW to HIGH when Rx_dv_dl1 is HIGH.
    rx_odd_data_ptr_rose_2: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(Rx_odd_data_ptr) |-> (Rx_dv_dl1 == 1'b1)
    );

    // Tx_odd_data_ptr can only transition from LOW to HIGH when MTxEn_dl1 is HIGH.
    tx_odd_data_ptr_rose_2: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(Tx_odd_data_ptr) |-> (MTxEn_dl1 == 1'b1)
    );

    // MTxD_dl1 can only transition from LOW to HIGH when MTxEn_dl1 is HIGH.
    mtxd_dl1_rose_3: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(MTxD_dl1) |-> (MTxEn_dl1 == 1'b1)
    );

    // MTxD_dl1 can only transition from HIGH to LOW when MTxEn_dl1 is LOW.
    mtxd_dl1_fall_3: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $fell(MTxD_dl1) |-> (MTxEn_dl1 == 1'b0)
    );

    // Txd can only transition from LOW to HIGH when MTxEn_dl1 is HIGH and Speed[2] is HIGH.
    txd_rose_5: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(Txd) |-> (MTxEn_dl1 == 1'b1 && Speed[2] == 1'b1)
    );

    // MRxD can only transition from LOW to HIGH when Rx_dv_dl2 is HIGH and Speed[2] is HIGH.
    mrxd_rose_7: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(MRxD) |-> (Rx_dv_dl2 == 1'b1 && Speed[2] == 1'b1)
    );

    // MRxD can only transition from LOW to HIGH when Txd is HIGH and Rx_odd_data_ptr is HIGH.
    mrxd_rose_8: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(MRxD) |-> (Txd == 1'b1 && Rx_odd_data_ptr == 1'b1)
    );

    // Txd can only transition from LOW to HIGH when Rx_dv_dl1 is HIGH and Rx_odd_data_ptr is HIGH.
    txd_rose_6: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(Txd) |-> (Rx_dv_dl1 == 1'b1 && Rx_odd_data_ptr == 1'b1)
    );

    // Tx_en can only transition from LOW to HIGH when MTxEn_dl1 is HIGH.
    tx_en_rose_3: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $rose(Tx_en) |-> (MTxEn_dl1 == 1'b1)
    );

    // Tx_en can only transition from HIGH to LOW when MTxEn_dl1 is LOW.
    tx_en_fall_3: assert property (
        @(posedge MAC_tx_clk) disable iff (!Reset) $fell(Tx_en) |-> (MTxEn_dl1 == 1'b0)
    );

    // MCrs_dv can only transition from LOW to HIGH when Tx_en is HIGH.
    mcrs_rose_3: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(MCrs_dv) |-> (Tx_en == 1'b1)
    );

    // MCrs_dv can only transition from HIGH to LOW when Tx_en is LOW.
    mcrs_fall_4: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(MCrs_dv) |-> (Tx_en == 1'b0)
    );

    // MRxD can only transition from LOW to HIGH when Txd is HIGH.
    mrxd_rose_9: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $rose(MRxD) |-> (Txd == 1'b1)
    );

    // MRxD can only transition from HIGH to LOW when Txd is LOW.
    mrxd_fall_4: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset) $fell(MRxD) |-> (Txd == 1'b0)
    );

    // Rx_odd_data_ptr can only transition from LOW to HIGH when Rx_dv_dl1 is HIGH.
    rx_odd_data_ptr_rose_3: assert property (
        @(posedge MAC_rx_clk) disable iff (!Reset