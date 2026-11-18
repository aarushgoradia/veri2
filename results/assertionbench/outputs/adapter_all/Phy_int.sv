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
    // During reset, Tx_en and Tx_er are 0.
    reset_tx_outputs_zero: assert property (
        @(posedge MAC_tx_clk) Reset |-> (Tx_en == 1'b0) && (Tx_er == 1'b0)
    );
    // During reset, Rx_dv_dl1, Rx_dv_dl2, and MCrs_dv are 0.
    reset_rx_sync_regs_zero: assert property (
        @(posedge MAC_rx_clk) Reset |-> (Rx_dv_dl1 == 1'b0) && (Rx_dv_dl2 == 1'b0) && (MCrs_dv == 1'b0)
    );
    // During reset, MRxD and MRxErr are 0.
    reset_rx_outputs_zero: assert property (
        @(posedge MAC_rx_clk) Reset |-> (MRxD == 8'h00) && (MRxErr == 1'b0)
    );
    // During reset, Txd is 0.
    reset_tx_data_zero: assert property (
        @(posedge MAC_tx_clk) Reset |-> (Txd == 8'h00)
    );

    ///// Tx control /////
    // Tx_en reflects MTxEn delayed by one cycle.
    check_tx_en_follows_mt xen: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset) $past(!Reset) |-> (Tx_en == $past(MTxEn))
    );
    // Tx_er is permanently 0.
    check_tx_er_constant_zero: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset) Tx_er == 1'b0
    );
    // Txd follows the implemented muxing of MTxD_dl1 based on Speed and Tx_odd_data_ptr.
    check_txd_mux_behavior: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset)
            $past(!Reset) |-> (
                Txd == (
                    $past(Speed[2]) ? $past(MTxD_dl1) :
                    ($past(MTxEn_dl1) && !$past(Tx_odd_data_ptr)) ? {4'b0, $past(MTxD_dl1[3:0])} :
                    ($past(MTxEn_dl1) && $past(Tx_odd_data_ptr)) ? {4'b0, $past(MTxD_dl1[7:4])} :
                    8'h00
                )
            )
    );
    // MTxD_dl1 captures MTxD from the previous cycle.
    check_mtxd_dl1_capture: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset) $past(!Reset) |-> (MTxD_dl1 == $past(MTxD))
    );
    // MTxEn_dl1 captures MTxEn from the previous cycle.
    check_mt xen_dl1_capture: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset) $past(!Reset) |-> (MTxEn_dl1 == $past(MTxEn))
    );
    // Tx_odd_data_ptr toggles when MTxD_dl1 is high and falls when MTxD_dl1 is low.
    check_tx_odd_data_ptr_toggle: assert property (
        @(posedge MAC_tx_clk) disable iff (Reset)
            $past(!Reset) |-> (Txd == 8'h00) ? (Tx_odd_data_ptr == $past(Tx_odd_data_ptr)) :
            (Txd != 8'h00) ? (Tx_odd_data_ptr == ~$past(Tx_odd_data_ptr)) : 1'b1
    );

    ///// Rx control /////
    // Rx_dv_dl2 is the delayed Rx_dv from two cycles ago.
    check_rx_dv_dl2_delay: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) $past(!Reset,2) |-> (Rx_dv_dl2 == $past(Rx_dv,2))
    );
    // Rx_dv_dl1 is the delayed Rx_dv from one cycle ago.
    check_rx_dv_dl1_delay: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) $past(!Reset,1) |-> (Rx_dv_dl1 == $past(Rx_dv,1))
    );
    // Rx_odd_data_ptr toggles when Rx_dv_dl1 is high and falls when Rx_dv_dl1 is low.
    check_rx_odd_data_ptr_toggle: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset)
            $past(!Reset) |-> (Rx_dv_dl1 == 1'b0) ? (Rx_odd_data_ptr == $past(Rx_odd_data_ptr)) :
            (Rx_dv_dl1 == 1'b1) ? (Rx_odd_data_ptr == ~$past(Rx_odd_data_ptr)) : 1'b1
    );
    // MRxErr captures Rx_er from the previous cycle.
    check_mrxe_capture: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) $past(!Reset) |-> (MRxErr == $past(Rx_er))
    );
    // MCRS captures Crs from the previous cycle.
    check_mcrs_capture: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) $past(!Reset) |-> (MCRS == $past(Crs))
    );
    // MCrs_dv follows the implemented priority mux of Line_loop_en, Rx_dv_dl2, and Tx_en.
    check_mcrs_dv_mux_behavior: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset)
            $past(!Reset) |-> (
                MCrs_dv == (
                    $past(Line_loop_en) ? $past(Tx_en) :
                    ($past(Rx_dv_dl2)) ? 1'b1 :
                    1'b0
                )
            )
    );
    // MRxD follows the implemented mux of Txd and Rxd_dl2 based on Speed and Rx_odd_data_ptr.
    check_mrxd_mux_behavior: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset)
            $past(!Reset) |-> (
                MRxD == (
                    $past(Line_loop_en) ? $past(Txd) :
                    ($past(Speed[2]) && $past(Rx_dv_dl2)) ? $past(Rxd_dl2) :
                    ($past(Rx_dv_dl1) && $past(Rx_odd_data_ptr)) ? { $past(Rxd_dl1[3:0]), $past(Rxd_dl2[3:0]) } :
                    8'h00
                )
            )
    );
    // Rxd_dl1 captures Rxd from the previous cycle.
    check_rxd_dl1_capture: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) $past(!Reset) |-> (Rxd_dl1 == $past(Rxd))
    );
    // Rxd_dl2 captures Rxd_dl1 from the previous cycle.
    check_rxd_dl2_capture: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) $past(!Reset) |-> (Rxd_dl2 == $past(Rxd_dl1))
    );
    // Crs_dl1 captures Crs from the previous cycle.
    check_crs_dl1_capture: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) $past(!Reset) |-> (Crs_dl1 == $past(Crs))
    );
    // Col_dl1 captures Col from the previous cycle.
    check_col_dl1_capture: assert property (
        @(posedge MAC_rx_clk) disable iff (Reset) $past(!Reset) |-> (Col_dl1 == $past(Col))
    );

endmodule