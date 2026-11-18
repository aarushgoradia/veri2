module apb_sva (
    input logic PCLK,
    input logic PRESETn,
    input logic PSELx,
    input logic PWRITE,
    input logic PENABLE,
    input logic [31:0] PADDR,
    input logic [31:0] PWDATA,
    input logic [31:0] READ_DATA_ON_RX,
    input logic ERROR,
    input logic TX_EMPTY,
    input logic RX_EMPTY,
    input logic [31:0] PRDATA,
    input logic [13:0] INTERNAL_I2C_REGISTER_CONFIG,
    input logic [13:0] INTERNAL_I2C_REGISTER_TIMEOUT,
    input logic [31:0] WRITE_DATA_ON_TX,
    input logic WR_ENA,
    input logic RD_ENA,
    input logic PREADY,
    input logic PSLVERR,
    input logic INT_RX,
    input logic INT_TX
);

    // WR_ENA is asserted only for the enabled TX FIFO write address.
    check_wr_ena_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        WR_ENA == ((PWRITE == 1'b1) && (PENABLE == 1'b1) && (PADDR == 32'd0) && (PSELx == 1'b1))
    );

    // RD_ENA is asserted only for the enabled RX FIFO read address.
    check_rd_ena_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        RD_ENA == ((PWRITE == 1'b0) && (PENABLE == 1'b1) && (PADDR == 32'd4) && (PSELx == 1'b1))
    );

    // PREADY is asserted only for enabled write, read, or timeout/status addresses.
    check_pready_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        PREADY == (((PWRITE == 1'b1) && (PENABLE == 1'b1)) ||
                   ((PWRITE == 1'b0) && (PENABLE == 1'b1) && (PADDR == 32'd4)) ||
                   (PADDR == 32'd8) ||
                   (PADDR == 32'd12))
    );

    // WRITE_DATA_ON_TX routes PWDATA to the TX FIFO write address.
    check_write_data_on_tx_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        WRITE_DATA_ON_TX == ((PADDR == 32'd0) ? PWDATA : 32'h0)
    );

    // PRDATA routes READ_DATA_ON_RX to the RX FIFO read address.
    check_prdata_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        PRDATA == ((PADDR == 32'd4) ? READ_DATA_ON_RX : 32'h0)
    );

    // PSLVERR mirrors ERROR.
    check_pslverr_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        PSLVERR == ERROR
    );

    // INT_TX mirrors TX_EMPTY.
    check_int_tx_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        INT_TX == TX_EMPTY
    );

    // INT_RX mirrors RX_EMPTY.
    check_int_rx_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        INT_RX == RX_EMPTY
    );

    // INTERNAL_I2C_REGISTER_CONFIG holds its value when no write is enabled.
    check_config_register_hold: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (!((PADDR == 32'd8) && (PSELx == 1'b1) && (PWRITE == 1'b1) && (PENABLE == 1'b1)))
        |-> (INTERNAL_I2C_REGISTER_CONFIG == $past(INTERNAL_I2C_REGISTER_CONFIG))
    );

    // INTERNAL_I2C_REGISTER_CONFIG loads PWDATA when the write address is enabled.
    check_config_register_load: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        ((PADDR == 32'd8) && (PSELx == 1'b1) && (PWRITE == 1'b1) && (PENABLE == 1'b1))
        |-> (INTERNAL_I2C_REGISTER_CONFIG == PWDATA[13:0])
    );

    // INTERNAL_I2C_REGISTER_TIMEOUT holds its value when no write is enabled.
    check_timeout_register_hold: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (!((PADDR == 32'd12) && (PSELx == 1'b1) && (PWRITE == 1'b1) && (PENABLE == 1'b1)))
        |-> (INTERNAL_I2C_REGISTER_TIMEOUT == $past(INTERNAL_I2C_REGISTER_TIMEOUT))
    );

    // INTERNAL_I2C_REGISTER_TIMEOUT loads PWDATA when the write address is enabled.
    check_timeout_register_load: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        ((PADDR == 32'd12) && (PSELx == 1'b1) && (PWRITE == 1'b1) && (PENABLE == 1'b1))
        |-> (INTERNAL_I2C_REGISTER_TIMEOUT == PWDATA[13:0])
    );

endmodule