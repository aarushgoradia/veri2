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
    ///// Combinational decode checks /////
    // WR_ENA equals PWRITE&PENABLE&PSELx&PADDR==0.
    check_wr_ena_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn) WR_ENA == (PWRITE & PENABLE & PSELx & (PADDR == 32'd0))
    );
    // RD_ENA equals !PWRITE&PENABLE&PSELx&PADDR==4.
    check_rd_ena_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn) RD_ENA == (!PWRITE & PENABLE & PSELx & (PADDR == 32'd4))
    );
    // PREADY equals (WR_ENA|RD_ENA|PADDR==8|PADDR==12) & PENABLE&PSELx.
    check_pready_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn) PREADY == ((WR_ENA | RD_ENA | (PADDR == 32'd8) | (PADDR == 32'd12)) & PENABLE & PSELx)
    );
    // WRITE_DATA_ON_TX equals PWDATA when PADDR==0, else PWDATA.
    check_write_data_on_tx_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn) WRITE_DATA_ON_TX == PWDATA
    );
    // PRDATA equals READ_DATA_ON_RX when PADDR==4, else READ_DATA_ON_RX.
    check_prdata_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn) PRDATA == READ_DATA_ON_RX
    );
    // PSLVERR equals ERROR.
    check_pslverr_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn) PSLVERR == ERROR
    );
    // INT_TX equals TX_EMPTY.
    check_int_tx_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn) INT_TX == TX_EMPTY
    );
    // INT_RX equals RX_EMPTY.
    check_int_rx_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn) INT_RX == RX_EMPTY
    );

    ///// Sequential register update checks /////
    // When not in reset, INTERNAL_I2C_REGISTER_CONFIG loads PWDATA[13:0] on write to 0x08.
    check_config_load_on_addr8: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            (PADDR == 32'd8 && PSELx == 1'b1 && PWRITE == 1'b1 && PENABLE == 1'b1 && PREADY == 1'b1)
            |=> (INTERNAL_I2C_REGISTER_CONFIG == $past(PWDATA[13:0]))
    );
    // When not in reset, INTERNAL_I2C_REGISTER_TIMEOUT loads PWDATA[13:0] on write to 0x0C.
    check_timeout_load_on_addr12: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            (PADDR == 32'd12 && PSELx == 1'b1 && PWRITE == 1'b1 && PENABLE == 1'b1 && PREADY == 1'b1)
            |=> (INTERNAL_I2C_REGISTER_TIMEOUT == $past(PWDATA[13:0]))
    );
    // When not in reset, INTERNAL_I2C_REGISTER_CONFIG holds its value on non-matching write addresses.
    check_config_hold_on_other_writes: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            (!(PADDR == 32'd8 || PADDR == 32'd12) && PSELx == 1'b1 && PWRITE == 1'b1 && PENABLE == 1'b1 && PREADY == 1'b1)
            |=> (INTERNAL_I2C_REGISTER_CONFIG == $past(INTERNAL_I2C_REGISTER_CONFIG))
    );
    // When not in reset, INTERNAL_I2C_REGISTER_TIMEOUT holds its value on non-matching write addresses.
    check_timeout_hold_on_other_writes: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            (!(PADDR == 32'd12) && PSELx == 1'b1 && PWRITE == 1'b1 && PENABLE == 1'b1 && PREADY == 1'b1)
            |=> (INTERNAL_I2C_REGISTER_TIMEOUT == $past(INTERNAL_I2C_REGISTER_TIMEOUT))
    );
    // When not in reset, INTERNAL_I2C_REGISTER_CONFIG holds its value on non-write cycles.
    check_config_hold_on_nonwrite: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            (PSELx == 1'b1 && PENABLE == 1'b1 && !(PWRITE == 1'b1 && PADDR == 32'd8 && PREADY == 1'b1))
            |=> (INTERNAL_I2C_REGISTER_CONFIG == $past(INTERNAL_I2C_REGISTER_CONFIG))
    );
    // When not in reset, INTERNAL_I2C_REGISTER_TIMEOUT holds its value on non-write cycles.
    check_timeout_hold_on_nonwrite: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            (PSELx == 1'b1 && PENABLE == 1'b1 && !(PWRITE == 1'b1 && PADDR == 32'd12 && PREADY == 1'b1))
            |=> (INTERNAL_I2C_REGISTER_TIMEOUT == $past(INTERNAL_I2C_REGISTER_TIMEOUT))
    );
    // On reset assertion, both internal registers clear to zero.
    check_reset_clears_registers: assert property (
        @(posedge PCLK) !PRESETn |=> (INTERNAL_I2C_REGISTER_CONFIG == 14'd0) && (INTERNAL_I2C_REGISTER_TIMEOUT == 14'd0)
    );
endmodule