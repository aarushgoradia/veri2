```systemverilog
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
    output logic [31:0] PRDATA,
    output logic [13:0] INTERNAL_I2C_REGISTER_CONFIG,
    output logic [13:0] INTERNAL_I2C_REGISTER_TIMEOUT,
    output logic WRITE_DATA_ON_TX,
    output logic WR_ENA,
    output logic RD_ENA,
    output logic PREADY,
    output logic PSLVERR,
    output logic INT_RX,
    output logic INT_TX
);

    // Sequential logic for internal registers
    always @(posedge PCLK) disable iff (!PRESETn) begin
        if (PADDR == 32'd8 && PSELx == 1'b1 && PWRITE == 1'b1 && PREADY == 1'b1) begin
            INTERNAL_I2C_REGISTER_CONFIG <= PWDATA[13:0];
        end else if (PADDR == 32'd12 && PSELx == 1'b1 && PWRITE == 1'b1 && PREADY == 1'b1) begin
            INTERNAL_I2C_REGISTER_TIMEOUT <= PWDATA[13:0];
        end
    end

    // Write enable on TX FIFO
    assign WR_ENA = (PWRITE == 1'b1 & PENABLE == 1'b1 & PADDR == 32'd0 & PSELx == 1'b1) ? 1'b1 : 1'b0;

    // Read enable on RX FIFO
    assign RD_ENA = (PWRITE == 1'b0 & PENABLE == 1'b1 & PADDR == 32'd4 & PSELx == 1'b1) ? 1'b1 : 1'b0;

    // PREADY signal
    assign PREADY = ((WR_ENA == 1'b1 | RD_ENA == 1'b1 | PADDR == 32'd8 | PADDR == 32'd12) & (PENABLE == 1'b1 & PSELx == 1'b1)) ? 1'b1 : 1'b0;

    // Write data on TX FIFO
    assign WRITE_DATA_ON_TX = (PADDR == 32'd0) ? PWDATA : PWDATA;

    // PRDATA signal
    assign PRDATA = (PADDR == 32'd4) ? READ_DATA_ON_RX : READ_DATA_ON_RX;

    // PSLVERR signal
    assign PSLVERR = ERROR;

    // INT_TX signal
    assign INT_TX = TX_EMPTY;

    // INT_RX signal
    assign INT_RX = RX_EMPTY;

    // Property to check write enable on TX FIFO
    property p_wr_ena;
        @(posedge PCLK) disable iff (!PRESETn) (PWRITE == 1'b1 & PENABLE == 1'b1 & PADDR == 32'd0 & PSELx == 1'b1) |-> WR_ENA == 1'b1;
    endproperty
    assert property (p_wr_ena) else $error("WR_ENA should be 1'b1 when PWRITE, PENABLE, PADDR, and PSELx are as specified.");

    // Property to check read enable on RX FIFO
    property p_rd_ena;
        @(posedge PCLK) disable iff (!PRESETn) (PWRITE == 1'b0 & PENABLE == 1'b1 & PADDR == 32'd4 & PSELx == 1'b1) |-> RD_ENA == 1'b1;
    endproperty
    assert property (p_rd_ena) else $error("RD_ENA should be 1'b1 when PWRITE, PENABLE, PADDR, and PSELx are as specified.");

    // Property to check PREADY signal
    property p_pready;
        @(posedge PCLK) disable iff (!PRESETn) ((WR_ENA == 1'b1 | RD_ENA == 1'b1 | PADDR == 32'd8 | PADDR == 32'd12) & (PENABLE == 1'b1 & PSELx == 1'b1)) |-> PREADY == 1'b1;
    endproperty
    assert property (p_pready) else $error("PREADY should be 1'b1 when WR_ENA, RD_ENA, PADDR, PENABLE, and PSELx are as specified.");

    // Property to check write data on TX FIFO
    property p_write_data_on_tx;
        @(posedge PCLK) disable iff (!PRESETn) (PADDR == 32'd0) |-> WRITE_DATA_ON_TX == PWDATA;
    endproperty
    assert property (p_write_data_on_tx) else $error("WRITE_DATA_ON_TX should be equal to PWDATA when PADDR is 32'd0.");

    // Property to check PRDATA signal
    property p_prdata;
        @(posedge PCLK) disable iff (!PRESETn) (PADDR == 32'd4) |-> PRDATA == READ_DATA_ON_RX;
    endproperty
    assert property (p_prdata) else $error("PRDATA should be equal to READ_DATA_ON_RX when PADDR is 32'd4.");

    // Property to check PSLVERR signal
    property p_pslverr;
        @(posedge PCLK) disable iff (!PRESETn) PSLVERR == ERROR;
    endproperty
    assert property (p_pslverr) else $error("PSLVERR should be equal to ERROR.");

    // Property to check INT_TX signal
    property p_int_tx;
        @(posedge PCLK) disable iff (!PRESETn) INT_TX == TX_EMPTY;
    endproperty
    assert property (p_int_tx) else $error("INT_TX should be equal to TX_EMPTY.");

    // Property to check INT_RX signal
    property p_int_rx;
        @(posedge PCLK) disable iff (!PRESETn) INT_RX == RX_EMPTY;
    endproperty
    assert property (p_int_rx) else $error("INT_RX should be equal to RX_EMPTY.");

    // Property to check internal register configuration update
    property p_config_update;
        @(posedge PCLK) disable iff (!PRESETn) (PADDR == 32'd8 && PSELx == 1'b1 && PWRITE == 1'b1 && PREADY == 1'b1) |-> INTERNAL_I2C_REGISTER_CONFIG == PWDATA[13:0];
    endproperty
    assert property (p_config_update) else $error("INTERNAL_I2C_REGISTER_CONFIG should be updated when PADDR, PSELx, PWRITE, and PREADY are as specified.");

    // Property to check internal register timeout update
    property p_timeout_update;
        @(posedge PCLK) disable iff (!PRESETn) (PADDR == 32'd12 && PSELx == 1'b1 && PWRITE == 1'b1 && PREADY == 1'b1) |-> INTERNAL_I2C_REGISTER_TIMEOUT == PWDATA[13:0];
    endproperty
    assert property (p_timeout_update) else $error("INTERNAL_I2C_REGISTER_TIMEOUT should be updated when PADDR, PSELx, PWRITE, and PREADY are as specified.");

endmodule
```