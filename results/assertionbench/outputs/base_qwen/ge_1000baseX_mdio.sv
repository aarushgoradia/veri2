```systemverilog
module ge_1000baseX_mdio_sva (
    input logic mdc,
    input logic mdio,
    input logic reset
);
    // Reset polarity is active low
    // The logic is sequential

    // Preamble detection
    // Preamble must be 32 consecutive 1's followed by a 0
    property p_preamble;
        @(posedge mdc) disable iff (!reset) $rose(mdio) |-> (mdio == 1'b0);
    endproperty
    assert property (p_preamble) else $error("Preamble detection failed");

    // State machine states
    localparam S_PREAMBLE = 4'b0000;
    localparam S_ST = 4'b0001;
    localparam S_OP_CODE = 4'b0010;
    localparam S_PHY_ADDR = 4'b0011;
    localparam S_REG_ADDR = 4'b0100;
    localparam S_TA = 4'b0101;
    localparam S_WR_DATA = 4'b0110;
    localparam S_RD_DATA = 4'b0111;
    localparam S_WR_COMMIT = 4'b1000;

    // State machine state transitions
    property p_state_transition;
        @(posedge mdc) disable iff (!reset) 
            (present == S_PREAMBLE && mdio == 1'b0) |-> (next == S_ST) ||
            (present == S_ST && mdio == 1'b1) |-> (next == S_OP_CODE) ||
            (present == S_OP_CODE && op_code_done) |-> (next == S_PHY_ADDR) ||
            (present == S_PHY_ADDR && phy_addr_done) |-> (next == S_REG_ADDR) ||
            (present == S_REG_ADDR && phy_addr_match && reg_addr_done) |-> (next == S_TA) ||
            (present == S_TA && ta1_done) |-> (next == S_WR_COMMIT || next == S_RD_DATA) ||
            (present == S_WR_DATA && data_done) |-> (next == S_WR_COMMIT) ||
            (present == S_RD_DATA && data_done) |-> (next == S_PREAMBLE);
    endproperty
    assert property (p_state_transition) else $error("State transition failed");

    // MDIO output enable
    // MDIO output enable should be high when reading data or shifting data out
    property p_mdio_oe;
        @(posedge mdc) disable iff (!reset) 
            (ta1_done && op_is_rd) |-> (mdio_oe == 1'b1) ||
            (data_out_shift) |-> (mdio_oe == 1'b1) ||
            (mdio_oe == 1'b0);
    endproperty
    assert property (p_mdio_oe) else $error("MDIO output enable failed");

    // MDIO output value
    // MDIO output value should be 1 when reading data, otherwise it should be the most significant bit of data_out
    property p_mdio_out;
        @(posedge mdc) disable iff (!reset) 
            (ta1_done && op_is_rd) |-> (mdio_out == 1'b1) ||
            (data_out_shift) |-> (mdio_out == data_out[15]) ||
            (mdio_out == 1'b0);
    endproperty
    assert property (p_mdio_out) else $error("MDIO output value failed");

    // Data address
    // Data address should be the same as the register address
    property p_data_addr;
        @(posedge mdc) disable iff (!reset) 
            (reg_addr_done) |-> (data_addr == reg_addr);
    endproperty
    assert property (p_data_addr) else $error("Data address failed");

    // Data write
    // Data write should be loaded from data_rd when data_out_load is high
    property p_data_wr;
        @(posedge mdc) disable iff (!reset) 
            (data_out_load) |-> (data_wr == data_rd);
    endproperty
    assert property (p_data_wr) else $error("Data write failed");

    // Data read
    // Data read should be shifted out when data_out_shift is high
    property p_data_out_shift;
        @(posedge mdc) disable iff (!reset) 
            (data_out_shift) |-> (data_out[15:0] == {data_out[14:0], 1'b0});
    endproperty
    assert property (p_data_out_shift) else $error("Data read failed");

    // Strobe write
    // Strobe write should be high when writing data
    property p_strobe_wr;
        @(posedge mdc) disable iff (!reset) 
            (op_is_wr && data_done) |-> (strobe_wr == 1'b1);
    endproperty
    assert property (p_strobe_wr) else $error("Strobe write failed");
endmodule
```