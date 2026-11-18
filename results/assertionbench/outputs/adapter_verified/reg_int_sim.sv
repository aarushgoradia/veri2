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

// Tx_Hwmark is a constant 5'h1e.
    check_tx_hwmark_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset) Tx_Hwmark == 5'h1e
    );

// Tx_Lwmark is a constant 5'h19.
    check_tx_lwmark_constant: assert property (
        @(posedge Clk_reg) disable iff (Reset) Tx_Lwmark == 5'h19
    );

// pause_frame_send_en is forced low.
    check_pause_frame_send_en_low: assert property (
        @(posedge Clk_reg) disable iff (Reset) pause_frame_send_en == 1'b0
    );

// pause_quanta_set is forced zero.
    check_pause_quanta_set_zero: assert property (
        @(posedge Clk_reg) disable iff (Reset) pause_quanta_set == 16'h0000
    );

// MAC_tx_add_en is forced low.
    check_mac_tx_add_en_low: assert property (
        @(posedge Clk_reg) disable iff (Reset) MAC_tx_add_en == 1'b0
    );

// FullDuplex is forced high.
    check_full_duplex_high: assert property (
        @(posedge Clk_reg) disable iff (Reset) FullDuplex == 1'b1
    );

// MaxRetry is forced to 2.
    check_max_retry_two: assert property (
        @(posedge Clk_reg) disable iff (Reset) MaxRetry == 4'd2
    );

// IFGset is forced to 10.
    check_ifgset_ten: assert property (
        @(posedge Clk_reg) disable iff (Reset) IFGset == 6'd10
    );

// MAC_tx_add_prom_data is forced zero.
    check_mac_tx_add_prom_data_zero: assert property (
        @(posedge Clk_reg) disable iff (Reset) MAC_tx_add_prom_data == 8'h00
    );

// MAC_tx_add_prom_add is forced zero.
    check_mac_tx_add_prom_add_zero: assert property (
        @(posedge Clk_reg) disable iff (Reset) MAC_tx_add_prom_add == 3'd0
    );

// MAC_tx_add_prom_wr is forced low.
    check_mac_tx_add_prom_wr_low: assert property (
        @(posedge Clk_reg) disable iff (Reset) MAC_tx_add_prom_wr == 1'b0
    );

// tx_pause_en is forced low.
    check_tx_pause_en_low: assert property (
        @(posedge Clk_reg) disable iff (Reset) tx_pause_en == 1'b0
    );

// xoff_cpu is forced low.
    check_xoff_cpu_low: assert property (
        @(posedge Clk_reg) disable iff (Reset) xoff_cpu == 1'b0
    );

// xon_cpu is forced low.
    check_xon_cpu_low: assert property (
        @(posedge Clk_reg) disable iff (Reset) xon_cpu == 1'b0
    );

// MAC_rx_add_chk_en is forced low.
    check_mac_rx_add_chk_en_low: assert property (
        @(posedge Clk_reg) disable iff (Reset) MAC_rx_add_chk_en == 1'b0
    );

// MAC_rx_add_prom_data is forced zero.
    check_mac_rx_add_prom_data_zero: assert property (
        @(posedge Clk_reg) disable iff (Reset) MAC_rx_add_prom_data == 8'h00
    );

// MAC_rx_add_prom_add is forced zero.
    check_mac_rx_add_prom_add_zero: assert property (
        @(posedge Clk_reg) disable iff (Reset) MAC_rx_add_prom_add == 3'd0
    );

// MAC_rx_add_prom_wr is forced low.
    check_mac_rx_add_prom_wr_low: assert property (
        @(posedge Clk_reg) disable iff (Reset) MAC_rx_add_prom_wr == 1'b0
    );

// broadcast_filter_en is forced low.
    check_broadcast_filter_en_low: assert property (
        @(posedge Clk_reg) disable iff (Reset) broadcast_filter_en == 1'b0
    );

// broadcast_MAX is forced to 10.
    check_broadcast_max_ten: assert property (
        @(posedge Clk_reg) disable iff (Reset) broadcast_MAX == 16'd10
    );

// RX_APPEND_CRC is forced low.
    check_rx_append_crc_low: assert property (
        @(posedge Clk_reg) disable iff (Reset) RX_APPEND_CRC == 1'b0
    );

// CRC_chk_en is forced high.
    check_crc_chk_en_high: assert property (
        @(posedge Clk_reg) disable iff (Reset) CRC_chk_en == 1'b1
    );

// RX_IFG_SET is forced to 10.
    check_rx_ifg_set_ten: assert property (
        @(posedge Clk_reg) disable iff (Reset) RX_IFG_SET == 6'd10
    );

// RX_MAX_LENGTH is forced to 1518.
    check_rx_max_length_1518: assert property (
        @(posedge Clk_reg) disable iff (Reset) RX_MAX_LENGTH == 16'd1518
    );

// RX_MIN_LENGTH is forced to 64.
    check_rx_min_length_64: assert property (
        @(posedge Clk_reg) disable iff (Reset) RX_MIN_LENGTH == 7'd64
    );

// CPU_rd_addr is forced zero.
    check_cpu_rd_addr_zero: assert property (
        @(posedge Clk_reg) disable iff (Reset) CPU_rd_addr == 6'd0
    );

// CPU_rd_apply is forced low.
    check_cpu_rd_apply_low: assert property (
        @(posedge Clk_reg) disable iff (Reset) CPU_rd_apply == 1'b0
    );

// Line_loop_en is forced low.
    check_line_loop_en_low: assert property (
        @(posedge Clk_reg) disable iff (Reset) Line_loop_en == 1'b0
    );

// Speed is forced to 3'b001.
    check_speed_001: assert property (
        @(posedge Clk_reg) disable iff (Reset) Speed == 3'b001
    );

// Busy is a sampled input.
    check_busy_sampled: assert property (
        @(posedge Clk_reg) disable iff (Reset) 1'b1 |-> $past(Busy)
    );

// LinkFail is a sampled input.
    check_linkfail_sampled: assert property (
        @(posedge Clk_reg) disable iff (Reset) 1'b1 |-> $past(LinkFail)
    );

// Nvalid is a sampled input.
    check_nvalid_sampled: assert property (
        @(posedge Clk_reg) disable iff (Reset) 1'b1 |-> $past(Nvalid)
    );

// Prsd is a sampled input.
    check_prsd_sampled: assert property (
        @(posedge Clk_reg) disable iff (Reset) 1'b1 |-> $past(Prsd)
    );

// UpdateMIIRX_DATAReg is a sampled input.
    check_update_mii_rx_datareg_sampled: assert property (
        @(posedge Clk_reg) disable iff (Reset) 1'b1 |-> $past(UpdateMIIRX_DATAReg)
    );

endmodule
