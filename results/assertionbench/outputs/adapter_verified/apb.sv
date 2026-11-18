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

// PREADY is high for enabled reads/writes to the correct addresses.
    check_pready_valid_addresses: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PSELx && PENABLE && (PADDR == 32'd0 || PADDR == 32'd4 || PADDR == 32'd8 || PADDR == 32'd12)) |-> PREADY
    );

// PREADY is low for all other address/enable combinations.
    check_pready_invalid_addresses: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !(PSELx && PENABLE && (PADDR == 32'd0 || PADDR == 32'd4 || PADDR == 32'd8 || PADDR == 32'd12)) |-> !PREADY
    );

// WR_ENA is asserted only for write enables to address 0.
    check_wrena_definition: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        WR_ENA == (PSELx && PENABLE && PWRITE && (PADDR == 32'd0))
    );

// RD_ENA is asserted only for read enables to address 4.
    check_rdena_definition: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        RD_ENA == (PSELx && PENABLE && !PWRITE && (PADDR == 32'd4))
    );

// PREADY is high for any enabled read/write to address 0.
    check_pready_on_write0: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PSELx && PENABLE && PWRITE && (PADDR == 32'd0)) |-> PREADY
    );

// PREADY is high for any enabled read/write to address 4.
    check_pready_on_read4: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PSELx && PENABLE && !PWRITE && (PADDR == 32'd4)) |-> PREADY
    );

// PREADY is high for any enabled write to address 8.
    check_pready_on_config_write: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PSELx && PENABLE && PWRITE && (PADDR == 32'd8)) |-> PREADY
    );

// PREADY is high for any enabled write to address 12.
    check_pready_on_timeout_write: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PSELx && PENABLE && PWRITE && (PADDR == 32'd12)) |-> PREADY
    );

// PREADY is low for all other address/enable combinations.
    check_pready_low_others: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !(PSELx && PENABLE && (PADDR == 32'd0 || PADDR == 32'd4 || PADDR == 32'd8 || PADDR == 32'd12)) |-> !PREADY
    );

// PRDATA mirrors READ_DATA_ON_RX for address 4.
    check_prdata_on_read4: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PSELx && PENABLE && !PWRITE && (PADDR == 32'd4)) |-> (PRDATA == READ_DATA_ON_RX)
    );

// PRDATA is zero for all other address/enable combinations.
    check_prdata_zero_others: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !(PSELx && PENABLE && !PWRITE && (PADDR == 32'd4)) |-> (PRDATA == 32'h0)
    );

// WRITE_DATA_ON_TX mirrors PWDATA for address 0.
    check_writedata_on_tx_on_write0: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PSELx && PENABLE && PWRITE && (PADDR == 32'd0)) |-> (WRITE_DATA_ON_TX == PWDATA)
    );

// WRITE_DATA_ON_TX is zero for all other address/enable combinations.
    check_writedata_on_tx_zero_others: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !(PSELx && PENABLE && PWRITE && (PADDR == 32'd0)) |-> (WRITE_DATA_ON_TX == 32'h0)
    );

// PSLVERR mirrors ERROR.
    check_psverr_definition: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        PSLVERR == ERROR
    );

// INT_TX mirrors TX_EMPTY.
    check_int_tx_definition: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        INT_TX == TX_EMPTY
    );

// INT_RX mirrors RX_EMPTY.
    check_int_rx_definition: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        INT_RX == RX_EMPTY
    );

// INTERNAL_I2C_REGISTER_CONFIG is loaded from PWDATA on address 8.
    check_config_register_load: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PSELx && PENABLE && PWRITE && (PADDR == 32'd8)) |-> (INTERNAL_I2C_REGISTER_CONFIG == PWDATA[13:0])
    );

// INTERNAL_I2C_REGISTER_TIMEOUT is loaded from PWDATA on address 12.
    check_timeout_register_load: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PSELx && PENABLE && PWRITE && (PADDR == 32'd12)) |-> (INTERNAL_I2C_REGISTER_TIMEOUT == PWDATA[13:0])
    );

// INTERNAL_I2C_REGISTER_CONFIG holds its value when no write occurs.
    check_config_register_hold: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !(PSELx && PENABLE && PWRITE && (PADDR == 32'd8)) |-> (INTERNAL_I2C_REGISTER_CONFIG == $past(INTERNAL_I2C_REGISTER_CONFIG))
    );

// INTERNAL_I2C_REGISTER_TIMEOUT holds its value when no write occurs.
    check_timeout_register_hold: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !(PSELx && PENABLE && PWRITE && (PADDR == 32'd12)) |-> (INTERNAL_I2C_REGISTER_TIMEOUT == $past(INTERNAL_I2C_REGISTER_TIMEOUT))
    );

endmodule
