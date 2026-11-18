```systemverilog
module reg_int_sim_sva (
    input logic Clk_reg,
    input logic Reset
);
    // Assignments are always combinational, so we use clocked assertions
    // to ensure they are consistent with the RTL.

    // Tx_Hwmark is always assigned a constant value
    assign_tx_hwmark: assert property (
        @(posedge Clk_reg) disable iff (!Reset) Tx_Hwmark == 5'h1e
    ) else $error("Tx_Hwmark should always be 5'h1e");

    // Tx_Lwmark is always assigned a constant value
    assign_tx_lwmark: assert property (
        @(posedge Clk_reg) disable iff (!Reset) Tx_Lwmark == 5'h19
    ) else $error("Tx_Lwmark should always be 5'h19");

    // pause_frame_send_en is always assigned a constant value
    assign_pause_frame_send_en: assert property (
        @(posedge Clk_reg) disable iff (!Reset) pause_frame_send_en == 0
    ) else $error("pause_frame_send_en should always be 0");

    // pause_quanta_set is always assigned a constant value
    assign_pause_quanta_set: assert property (
        @(posedge Clk_reg) disable iff (!Reset) pause_quanta_set == 0
    ) else $error("pause_quanta_set should always be 0");

    // MAC_tx_add_en is always assigned a constant value
    assign_mac_tx_add_en: assert property (
        @(posedge Clk_reg) disable iff (!Reset) MAC_tx_add_en == 0
    ) else $error("MAC_tx_add_en should always be 0");

    // FullDuplex is always assigned a constant value
    assign_full_duplex: assert property (
        @(posedge Clk_reg) disable iff (!Reset) FullDuplex == 1
    ) else $error("FullDuplex should always be 1");

    // MaxRetry is always assigned a constant value
    assign_max_retry: assert property (
        @(posedge Clk_reg) disable iff (!Reset) MaxRetry == 2
    ) else $error("MaxRetry should always be 2");

    // IFGset is always assigned a constant value
    assign_ifgset: assert property (
        @(posedge Clk_reg) disable iff (!Reset) IFGset == 10
    ) else $error("IFGset should always be 10");

    // MAC_tx_add_prom_data is always assigned a constant value
    assign_mac_tx_add_prom_data: assert property (
        @(posedge Clk_reg) disable iff (!Reset) MAC_tx_add_prom_data == 0
    ) else $error("MAC_tx_add_prom_data should always be 0");

    // MAC_tx_add_prom_add is always assigned a constant value
    assign_mac_tx_add_prom_add: assert property (
        @(posedge Clk_reg) disable iff (!Reset) MAC_tx_add_prom_add == 0
    ) else $error("MAC_tx_add_prom_add should always be 0");

    // MAC_tx_add_prom_wr is always assigned a constant value
    assign_mac_tx_add_prom_wr: assert property (
        @(posedge Clk_reg) disable iff (!Reset) MAC_tx_add_prom_wr == 0
    ) else $error("MAC_tx_add_prom_wr should always be 0");

    // tx_pause_en is always assigned a constant value
    assign_tx_pause_en: assert property (
        @(posedge Clk_reg) disable iff (!Reset) tx_pause_en == 0
    ) else $error("tx_pause_en should always be 0");

    // xoff_cpu is always assigned a constant value
    assign_xoff_cpu: assert property (
        @(posedge Clk_reg) disable iff (!Reset) xoff_cpu == 0
    ) else $error("xoff_cpu should always be 0");

    // xon_cpu is always assigned a constant value
    assign_xon_cpu: assert property (
        @(posedge Clk_reg) disable iff (!Reset) xon_cpu == 0
    ) else $error("xon_cpu should always be 0");

    // MAC_rx_add_chk_en is always assigned a constant value
    assign_mac_rx_add_chk_en: assert property (
        @(posedge Clk_reg) disable iff (!Reset) MAC_rx_add_chk_en == 0
    ) else $error("MAC_rx_add_chk_en should always be 0");

    // MAC_rx_add_prom_data is always assigned a constant value
    assign_mac_rx_add_prom_data: assert property (
        @(posedge Clk_reg) disable iff (!Reset) MAC_rx_add_prom_data == 0
    ) else $error("MAC_rx_add_prom_data should always be 0");

    // MAC_rx_add_prom_add is always assigned a constant value
    assign_mac_rx_add_prom_add: assert property (
        @(posedge Clk_reg) disable iff (!Reset) MAC_rx_add_prom_add == 0
    ) else $error("MAC_rx_add_prom_add should always be 0");

    // MAC_rx_add_prom_wr is always assigned a constant value
    assign_mac_rx_add_prom_wr: assert property (
        @(posedge Clk_reg) disable iff (!Reset) MAC_rx_add_prom_wr == 0
    ) else $error("MAC_rx_add_prom_wr should always be 0");

    // broadcast_filter_en is always assigned a constant value
    assign_broadcast_filter_en: assert property (
        @(posedge Clk_reg) disable iff (!Reset) broadcast_filter_en == 0
    ) else $error("broadcast_filter_en should always be 0");

    // broadcast_MAX is always assigned a constant value
    assign_broadcast_max: assert property (
        @(posedge Clk_reg) disable iff (!Reset) broadcast_MAX == 10
    ) else $error("broadcast_MAX should always be 10");

    // RX_APPEND_CRC is always assigned a constant value
    assign_rx_append_crc: assert property (
        @(posedge Clk_reg) disable iff (!Reset) RX_APPEND_CRC == 0
    ) else $error("RX_APPEND_CRC should always be 0");

    // CRC_chk_en is always assigned a constant value
    assign_crc_chk_en: assert property (
        @(posedge Clk_reg) disable iff (!Reset) CRC_chk_en == 1
    ) else $error("CRC_chk_en should always be 1");

    // RX_IFG_SET is always assigned a constant value
    assign_rx_ifg_set: assert property (
        @(posedge Clk_reg) disable iff (!Reset) RX_IFG_SET == 10
    ) else $error("RX_IFG_SET should always be 10");

    // RX_MAX_LENGTH is always assigned a constant value
    assign_rx_max_length: assert property (
        @(posedge Clk_reg) disable iff (!Reset) RX_MAX_LENGTH == 1518
    ) else $error("RX_MAX_LENGTH should always be 1518");

    // RX_MIN_LENGTH is always assigned a constant value
    assign_rx_min_length: assert property (
        @(posedge Clk_reg) disable iff (!Reset) RX_MIN_LENGTH == 64
    ) else $error("RX_MIN_LENGTH should always be 64");

    // CPU_rd_addr is always assigned a constant value
    assign_cpu_rd_addr: assert property (
        @(posedge Clk_reg) disable iff (!Reset) CPU_rd_addr == 0
    ) else $error("CPU_rd_addr should always be 0");

    // CPU_rd_apply is always assigned a constant value
    assign_cpu_rd_apply: assert property (
        @(posedge Clk_reg) disable iff (!Reset) CPU_rd_apply == 0
    ) else $error("CPU_rd_apply should always be 0");

    // Line_loop_en is always assigned a constant value
    assign_line_loop_en: assert property (
        @(posedge Clk_reg) disable iff (!Reset) Line_loop_en == 0
    ) else $error("Line_loop_en should always be 0");

    // Speed is always assigned a constant value
    assign_speed: assert property (
        @(posedge Clk_reg) disable iff (!Reset) Speed == 3'b001
    ) else $error("Speed should always be 3'b001");
endmodule
```