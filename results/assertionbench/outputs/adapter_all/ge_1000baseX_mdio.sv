module ge_1000baseX_mdio_sva #(
    parameter logic [4:0] PHY_ADDR = 5'b00000
) (
    input logic reset,
    input logic mdc,
    input logic mdio,
    input logic mdio_out,
    input logic mdio_oe,
    input logic [4:0] data_addr,
    input logic [15:0] data_rd,
    input logic [15:0] data_wr,
    input logic strobe_wr,
    input logic [5:0] preamble_cnt,
    input logic pos_cnt_inc,
    input logic [4:0] pos_cnt,
    input logic st,
    input logic st_latch,
    input logic [1:0] op_code,
    input logic op_code_shift,
    input logic [4:0] phy_addr,
    input logic phy_addr_shift,
    input logic [4:0] reg_addr,
    input logic reg_addr_shift,
    input logic [15:0] data_in,
    input logic data_in_shift,
    input logic [15:0] data_out,
    input logic data_out_load,
    input logic data_out_shift
);

    // Reset clears all state and outputs.
    check_reset_state: assert property (
        @(posedge mdc)
        reset |-> (
            (preamble_cnt == 6'd0) &&
            (pos_cnt == 5'd0) &&
            (st == 1'b0) &&
            (op_code == 2'b00) &&
            (phy_addr == 5'd0) &&
            (reg_addr == 5'd0) &&
            (data_in == 16'h0000) &&
            (data_out == 16'h0000) &&
            (mdio_oe == 1'b0) &&
            (mdio_out == 1'b0) &&
            (strobe_wr == 1'b0) &&
            (data_addr == 5'd0) &&
            (data_wr == 16'h0000)
        )
    );

    // Preamble increments while the current count does not match.
    check_preamble_increment: assert property (
        @(posedge mdc) disable iff (reset)
        (preamble_cnt != 6'd31) |=> (preamble_cnt == ($past(preamble_cnt) + 6'd1))
    );

    // Preamble clears while the current count matches and MDIO is high.
    check_preamble_clear: assert property (
        @(posedge mdc) disable iff (reset)
        (preamble_cnt == 6'd31 && mdio) |=> (preamble_cnt == 6'd0)
    );

    // Preamble holds when the current count matches and MDIO is low.
    check_preamble_hold: assert property (
        @(posedge mdc) disable iff (reset)
        (preamble_cnt == 6'd31 && !mdio) |=> (preamble_cnt == $past(preamble_cnt))
    );

    // Position counter increments when enabled.
    check_pos_cnt_increment: assert property (
        @(posedge mdc) disable iff (reset)
        pos_cnt_inc |=> (pos_cnt == ($past(pos_cnt) + 5'd1))
    );

    // Position counter holds when not enabled.
    check_pos_cnt_hold: assert property (
        @(posedge mdc) disable iff (reset)
        !pos_cnt_inc |=> (pos_cnt == $past(pos_cnt))
    );

    // ST captures MDIO on a latch cycle.
    check_st_capture: assert property (
        @(posedge mdc) disable iff (reset)
        st_latch |=> (st == $past(mdio))
    );

    // ST holds when not latched.
    check_st_hold: assert property (
        @(posedge mdc) disable iff (reset)
        !st_latch |=> (st == $past(st))
    );

    // OP_CODE shifts in MDIO on each shift cycle.
    check_op_code_shift: assert property (
        @(posedge mdc) disable iff (reset)
        op_code_shift |=> (op_code == {$past(op_code[0]), $past(mdio)})
    );

    // OP_CODE holds when not shifting.
    check_op_code_hold: assert property (
        @(posedge mdc) disable iff (reset)
        !op_code_shift |=> (op_code == $past(op_code))
    );

    // PHY_ADDR shifts in MDIO on each shift cycle.
    check_phy_addr_shift: assert property (
        @(posedge mdc) disable iff (reset)
        phy_addr_shift |=> (phy_addr == {$past(phy_addr[3:0]), $past(mdio)})
    );

    // PHY_ADDR holds when not shifting.
    check_phy_addr_hold: assert property (
        @(posedge mdc) disable iff (reset)
        !phy_addr_shift |=> (phy_addr == $past(phy_addr))
    );

    // REG_ADDR shifts in MDIO on each shift cycle.
    check_reg_addr_shift: assert property (
        @(posedge mdc) disable iff (reset)
        reg_addr_shift |=> (reg_addr == {$past(reg_addr[3:0]), $past(mdio)})
    );

    // REG_ADDR holds when not shifting.
    check_reg_addr_hold: assert property (
        @(posedge mdc) disable iff (reset)
        !reg_addr_shift |=> (reg_addr == $past(reg_addr))
    );

    // DATA_IN shifts in MDIO on each shift cycle.
    check_data_in_shift: assert property (
        @(posedge mdc) disable iff (reset)
        data_in_shift |=> (data_in == {$past(data_in[14:0]), $past(mdio)})
    );

    // DATA_IN holds when not shifting.
    check_data_in_hold: assert property (
        @(posedge mdc) disable iff (reset)
        !data_in_shift |=> (data_in == $past(data_in))
    );

    // DATA_OUT loads data_rd on a load cycle.
    check_data_out_load: assert property (
        @(posedge mdc) disable iff (reset)
        data_out_load |=> (data_out == $past(data_rd))
    );

    // DATA_OUT shifts left on a shift cycle.
    check_data_out_shift: assert property (
        @(posedge mdc) disable iff (reset)
        data_out_shift |=> (data_out == {$past(data_out[14:0]), 1'b0})
    );

    // DATA_OUT holds when neither load nor shift is active.
    check_data_out_hold: assert property (
        @(posedge mdc) disable iff (reset)
        !(data_out_load || data_out_shift) |=> (data_out == $past(data_out))
    );

    // MDIO output is forced high during read data capture.
    check_mdio_out_read_capture: assert property (
        @(posedge mdc) disable iff (reset)
        (data_out_shift && (op_code == 2'b10)) |=> (mdio_out == 1'b1)
    );

    // MDIO output follows DATA_OUT[15] during write data capture.
    check_mdio_out_write_capture: assert property (
        @(posedge mdc) disable iff (reset)
        (data_out_shift && (op_code == 2'b01)) |=> (mdio_out == $past(data_out[15]))
    );

    // MDIO output holds when neither capture is active.
    check_mdio_out_hold: assert property (
        @(posedge mdc) disable iff (reset)
        !(data_out_shift && (op_code == 2'b10)) |=> (mdio_out == $past(mdio_out))
    );

    // MDIO output enable is asserted only during read data capture.
    check_mdio_oe_read_capture: assert property (
        @(posedge mdc) disable iff (reset)
        data_out_shift |=> (mdio_oe == (op_code == 2'b10))
    );

    // MDIO output enable holds when no capture is active.
    check_mdio_oe_hold: assert property (
        @(posedge mdc) disable iff (reset)
        !data_out_shift |=> (mdio_oe == $past(mdio_oe))
    );

    // Strobe is asserted only on the write commit state.
    check_strobe_wr_write_commit: assert property (
        @(posedge mdc) disable iff (reset)
        strobe_wr |=> (present == 4'b1000)
    );

    // Strobe holds when the write commit state is not active.
    check_strobe_wr_hold: assert property (
        @(posedge mdc) disable iff (reset)
        !(present == 4'b1000) |=> (strobe_wr == $past(strobe_wr))
    );

    // DATA_ADDR mirrors REG_ADDR.
    check_data_addr_mirror: assert property (
        @(posedge mdc) disable iff (reset)
        data_addr == reg_addr
    );

    // DATA_WR mirrors DATA_IN.
    check_data_wr_mirror: assert property (
        @(posedge mdc) disable iff (reset)
        data_wr == data_in
    );

    // Read data capture drives DATA_OUT with zero-extended data_rd.
    check_read_capture_data_out: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b1000) |=> (data_out == {$past(data_rd), 1'b0})
    );

    // Write data capture drives DATA_OUT with zero-extended data_in.
    check_write_capture_data_out: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0100) |=> (data_out == {$past(data_in), 1'b0})
    );

    // Invalid opcode drives the state machine back to the preamble.
    check_invalid_opcode_reset: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0010) && (op_code == 2'b11) |=> (present == 4'b0000)
    );

    // Invalid PHY address drives the state machine back to the preamble.
    check_invalid_phy_addr_reset: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0100) && !phy_addr_match |=> (present == 4'b0000)
    );

    // Invalid opcode in write data capture drives the state machine back to the preamble.
    check_invalid_opcode_write_reset: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0110) && (op_code == 2'b11) |=> (present == 4'b0000)
    );

    // Invalid opcode in read data capture drives the state machine back to the preamble.
    check_invalid_opcode_read_reset: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b1000) && (op_code == 2'b11) |=> (present == 4'b0000)
    );

    // Invalid opcode in write commit drives the state machine back to the preamble.
    check_invalid_opcode_commit_reset: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b1001) && (op_code == 2'b11) |=> (present == 4'b0000)
    );

endmodule