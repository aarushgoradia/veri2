module reg_int_sim_sva (
    input logic        Reset,
    input logic        Clk_reg,
    input logic [4:0]  Tx_Hwmark,
    input logic [4:0]  Tx_Lwmark,
    input logic        pause_frame_send_en,
    input logic [15:0] pause_quanta_set,
    input logic        MAC_tx_add_en,
    input logic        FullDuplex,
    input logic [3:0]  MaxRetry,
    input logic [5:0]  IFGset,
    input logic [7:0]  MAC_tx_add_prom_data,
    input logic [2:0]  MAC_tx_add_prom_add,
    input logic        MAC_tx_add_prom_wr,
    input logic        tx_pause_en,
    input logic        xoff_cpu,
    input logic        xon_cpu,
    input logic        MAC_rx_add_chk_en,
    input logic [7:0]  MAC_rx_add_prom_data,
    input logic [2:0]  MAC_rx_add_prom_add,
    input logic        MAC_rx_add_prom_wr,
    input logic        broadcast_filter_en,
    input logic [15:0] broadcast_MAX,
    input logic        RX_APPEND_CRC,
    input logic        CRC_chk_en,
    input logic [5:0]  RX_IFG_SET,
    input logic [15:0] RX_MAX_LENGTH,
    input logic [6:0]  RX_MIN_LENGTH,
    input logic [5:0]  CPU_rd_addr,
    input logic        CPU_rd_apply,
    input logic        CPU_rd_grant,
    input logic [31:0] CPU_rd_dout,
    input logic        Line_loop_en,
    input logic [2:0]  Speed,
    input logic        Busy,
    input logic        LinkFail,
    input logic        Nvalid,
    input logic [15:0] Prsd,
    input logic        UpdateMIIRX_DATAReg
);

    // Tx_Hwmark is the constant 5'h1e.
    check_tx_hwmark_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        Tx_Hwmark == 5'h1e
    );

    // Tx_Lwmark is the constant 5'h19.
    check_tx_lwmark_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        Tx_Lwmark == 5'h19
    );

    // pause_frame_send_en is tied low.
    check_pause_frame_send_en_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        pause_frame_send_en == 1'b0
    );

    // pause_quanta_set is tied low.
    check_pause_quanta_set_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        pause_quanta_set == 16'h0000
    );

    // MAC_tx_add_en is tied low.
    check_mac_tx_add_en_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        MAC_tx_add_en == 1'b0
    );

    // FullDuplex is tied high.
    check_full_duplex_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        FullDuplex == 1'b1
    );

    // MaxRetry is tied to 2.
    check_max_retry_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        MaxRetry == 4'd2
    );

    // IFGset is tied to 10.
    check_ifgset_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        IFGset == 6'd10
    );

    // MAC_tx_add_prom_data is tied low.
    check_mac_tx_add_prom_data_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        MAC_tx_add_prom_data == 8'h00
    );

    // MAC_tx_add_prom_add is tied low.
    check_mac_tx_add_prom_add_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        MAC_tx_add_prom_add == 3'd0
    );

    // MAC_tx_add_prom_wr is tied low.
    check_mac_tx_add_prom_wr_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        MAC_tx_add_prom_wr == 1'b0
    );

    // tx_pause_en is tied low.
    check_tx_pause_en_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        tx_pause_en == 1'b0
    );

    // xoff_cpu is tied low.
    check_xoff_cpu_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        xoff_cpu == 1'b0
    );

    // xon_cpu is tied low.
    check_xon_cpu_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        xon_cpu == 1'b0
    );

    // MAC_rx_add_chk_en is tied low.
    check_mac_rx_add_chk_en_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        MAC_rx_add_chk_en == 1'b0
    );

    // MAC_rx_add_prom_data is tied low.
    check_mac_rx_add_prom_data_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        MAC_rx_add_prom_data == 8'h00
    );

    // MAC_rx_add_prom_add is tied low.
    check_mac_rx_add_prom_add_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        MAC_rx_add_prom_add == 3'd0
    );

    // MAC_rx_add_prom_wr is tied low.
    check_mac_rx_add_prom_wr_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        MAC_rx_add_prom_wr == 1'b0
    );

    // broadcast_filter_en is tied low.
    check_broadcast_filter_en_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        broadcast_filter_en == 1'b0
    );

    // broadcast_MAX is tied to 10.
    check_broadcast_max_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        broadcast_MAX == 16'd10
    );

    // RX_APPEND_CRC is tied low.
    check_rx_append_crc_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        RX_APPEND_CRC == 1'b0
    );

    // CRC_chk_en is tied high.
    check_crc_chk_en_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        CRC_chk_en == 1'b1
    );

    // RX_IFG_SET is tied to 10.
    check_rx_ifg_set_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        RX_IFG_SET == 6'd10
    );

    // RX_MAX_LENGTH is tied to 1518.
    check_rx_max_length_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        RX_MAX_LENGTH == 16'd1518
    );

    // RX_MIN_LENGTH is tied to 64.
    check_rx_min_length_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        RX_MIN_LENGTH == 7'd64
    );

    // CPU_rd_addr is tied low.
    check_cpu_rd_addr_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        CPU_rd_addr == 6'd0
    );

    // CPU_rd_apply is tied low.
    check_cpu_rd_apply_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        CPU_rd_apply == 1'b0
    );

    // Line_loop_en is tied low.
    check_line_loop_en_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        Line_loop_en == 1'b0
    );

    // Speed is tied to 3'b001.
    check_speed_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        Speed == 3'b001
    );

    // CPU_rd_grant is not asserted in this RTL.
    check_cpu_rd_grant_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        CPU_rd_grant == 1'b0
    );

    // CPU_rd_dout is not driven in this RTL.
    check_cpu_rd_dout_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        CPU_rd_dout == 32'h00000000
    );

    // Busy is not driven in this RTL.
    check_busy_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        Busy == 1'b0
    );

    // LinkFail is not driven in this RTL.
    check_linkfail_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        LinkFail == 1'b0
    );

    // Nvalid is not driven in this RTL.
    check_nvalid_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        Nvalid == 1'b0
    );

    // Prsd is not driven in this RTL.
    check_prsd_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        Prsd == 16'h0000
    );

    // UpdateMIIRX_DATAReg is not driven in this RTL.
    check_update_miirx_datareg_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset)
        UpdateMIIRX_DATAReg == 1'b0
    );

endmodule