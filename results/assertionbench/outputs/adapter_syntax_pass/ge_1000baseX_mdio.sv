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
    input logic phy_addr_match,
    input logic [4:0] reg_addr,
    input logic reg_addr_shift,
    input logic [15:0] data_in,
    input logic data_in_shift,
    input logic [15:0] data_out,
    input logic data_out_load,
    input logic data_out_shift
);

    // Preamble counter increments when the current sample is a 1 outside match.
    check_preamble_counter_increments: assert property (
        @(posedge mdc) disable iff (reset)
        (preamble_cnt != 6'd31) |=> (preamble_cnt == ($past(preamble_cnt) + 6'd1))
    );

    // Preamble counter clears when the current sample is a 0 outside match.
    check_preamble_counter_clears: assert property (
        @(posedge mdc) disable iff (reset)
        (preamble_cnt == 6'd31) |=> (preamble_cnt == 6'd0)
    );

    // Position counter increments when pos_cnt_inc is asserted.
    check_pos_counter_increments: assert property (
        @(posedge mdc) disable iff (reset)
        pos_cnt_inc |=> (pos_cnt == ($past(pos_cnt) + 5'd1))
    );

    // Position counter holds when pos_cnt_inc is deasserted.
    check_pos_counter_holds: assert property (
        @(posedge mdc) disable iff (reset)
        !pos_cnt_inc |=> (pos_cnt == $past(pos_cnt))
    );

    // op_code_shift loads the next bit into op_code.
    check_op_code_shifts: assert property (
        @(posedge mdc) disable iff (reset)
        op_code_shift |=> (op_code == {$past(op_code[0]), $past(mdio)})
    );

    // op_code holds when op_code_shift is deasserted.
    check_op_code_holds: assert property (
        @(posedge mdc) disable iff (reset)
        !op_code_shift |=> (op_code == $past(op_code))
    );

    // phy_addr_shift loads the next bit into phy_addr.
    check_phy_addr_shifts: assert property (
        @(posedge mdc) disable iff (reset)
        phy_addr_shift |=> (phy_addr == {$past(phy_addr[3:0]), $past(mdio)})
    );

    // phy_addr holds when phy_addr_shift is deasserted.
    check_phy_addr_holds: assert property (
        @(posedge mdc) disable iff (reset)
        !phy_addr_shift |=> (phy_addr == $past(phy_addr))
    );

    // reg_addr_shift loads the next bit into reg_addr.
    check_reg_addr_shifts: assert property (
        @(posedge mdc) disable iff (reset)
        reg_addr_shift |=> (reg_addr == {$past(reg_addr[3:0]), $past(mdio)})
    );

    // reg_addr holds when reg_addr_shift is deasserted.
    check_reg_addr_holds: assert property (
        @(posedge mdc) disable iff (reset)
        !reg_addr_shift |=> (reg_addr == $past(reg_addr))
    );

    // data_in_shift loads the next bit into data_in.
    check_data_in_shifts: assert property (
        @(posedge mdc) disable iff (reset)
        data_in_shift |=> (data_in == {$past(data_in[14:0]), $past(mdio)})
    );

    // data_in holds when data_in_shift is deasserted.
    check_data_in_holds: assert property (
        @(posedge mdc) disable iff (reset)
        !data_in_shift |=> (data_in == $past(data_in))
    );

    // data_out_shift loads the next bit into data_out.
    check_data_out_shifts: assert property (
        @(posedge mdc) disable iff (reset)
        data_out_shift |=> (data_out == {$past(data_out[14:0]), 1'b0})
    );

    // data_out holds when data_out_shift is deasserted.
    check_data_out_holds: assert property (
        @(posedge mdc) disable iff (reset)
        !data_out_shift |=> (data_out == $past(data_out))
    );

    // data_out_load captures data_rd into data_out.
    check_data_out_loads: assert property (
        @(posedge mdc) disable iff (reset)
        data_out_load |=> (data_out == $past(data_rd))
    );

    // data_out holds when data_out_load is deasserted.
    check_data_out_holds_when_not_loading: assert property (
        @(posedge mdc) disable iff (reset)
        !data_out_load |=> (data_out == $past(data_out))
    );

    // mdio_oe is asserted only during the last bit of a read or write.
    check_mdio_oe_matches_terminal_count: assert property (
        @(posedge mdc) disable iff (reset)
        mdio_oe == (data_out_shift || (data_out_shift && op_code == 2'b10))
    );

    // mdio_out is driven high only during the last bit of a read.
    check_mdio_out_matches_terminal_count: assert property (
        @(posedge mdc) disable iff (reset)
        mdio_out == (data_out_shift && op_code == 2'b10)
    );

    // data_addr is always a copy of reg_addr.
    check_data_addr_matches_reg_addr: assert property (
        @(posedge mdc) disable iff (reset)
        data_addr == reg_addr
    );

    // data_wr is always a copy of data_in.
    check_data_wr_matches_data_in: assert property (
        @(posedge mdc) disable iff (reset)
        data_wr == data_in
    );

    // st_latch captures mdio on the next cycle.
    check_st_latch_captures_mdio: assert property (
        @(posedge mdc) disable iff (reset)
        1'b1 |=> (st_latch == $past(mdio))
    );

    // st is cleared whenever st_latch is deasserted.
    check_st_clears_on_latch_deassert: assert property (
        @(posedge mdc) disable iff (reset)
        !st_latch |=> (st == 1'b0)
    );

    // st is set whenever st_latch is asserted.
    check_st_sets_on_latch_assert: assert property (
        @(posedge mdc) disable iff (reset)
        st_latch |=> (st == 1'b1)
    );

    // st_match is asserted only when st is low and mdio is high.
    check_st_match_definition: assert property (
        @(posedge mdc) disable iff (reset)
        st_match == (!st && mdio)
    );

    // op_code_done is asserted only at the 1-bit position.
    check_op_code_done_definition: assert property (
        @(posedge mdc) disable iff (reset)
        op_code_done == (pos_cnt == 5'd1)
    );

    // phy_addr_done is asserted only at the 6-bit position.
    check_phy_addr_done_definition: assert property (
        @(posedge mdc) disable iff (reset)
        phy_addr_done == (pos_cnt == 5'd6)
    );

    // reg_addr_done is asserted only at the 11-bit position.
    check_reg_addr_done_definition: assert property (
        @(posedge mdc) disable iff (reset)
        reg_addr_done == (pos_cnt == 5'd11)
    );

    // ta0_done is asserted only at the 12-bit position.
    check_ta0_done_definition: assert property (
        @(posedge mdc) disable iff (reset)
        ta0_done == (pos_cnt == 5'd12)
    );

    // ta1_done is asserted only at the 13-bit position.
    check_ta1_done_definition: assert property (
        @(posedge mdc) disable iff (reset)
        ta1_done == (pos_cnt == 5'd13)
    );

    // data_done is asserted only at the 29-bit position.
    check_data_done_definition: assert property (
        @(posedge mdc) disable iff (reset)
        data_done == (pos_cnt == 5'd29)
    );

    // op_is_rd decodes opcode 10.
    check_op_is_rd_definition: assert property (
        @(posedge mdc) disable iff (reset)
        op_is_rd == (op_code == 2'b10)
    );

    // op_is_wr decodes opcode 01.
    check_op_is_wr_definition: assert property (
        @(posedge mdc) disable iff (reset)
        op_is_wr == (op_code == 2'b01)
    );

    // op_is_invalid decodes any opcode other than 01 or 10.
    check_op_is_invalid_definition: assert property (
        @(posedge mdc) disable iff (reset)
        op_is_invalid == ((op_code != 2'b01) && (op_code != 2'b10))
    );

    // phy_addr_match compares phy_addr to the parameterized PHY address.
    check_phy_addr_match_definition: assert property (
        @(posedge mdc) disable iff (reset)
        phy_addr_match == (phy_addr == PHY_ADDR)
    );

    // strobe_wr is asserted only after a write commit state.
    check_strobe_wr_definition: assert property (
        @(posedge mdc) disable iff (reset)
        strobe_wr == (present == 4'b1000)
    );

    // S_PREAMBLE advances to S_ST when the preamble is detected.
    check_s_preamble_to_s_st: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0000 && !mdio) |=> (present == 4'b0001)
    );

    // S_PREAMBLE stays in S_PREAMBLE when the preamble is not detected.
    check_s_preamble_stays: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0000 && mdio) |=> (present == 4'b0000)
    );

    // S_ST advances to S_OP_CODE when the start-of-frame bit is detected.
    check_s_st_to_s_op_code: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0001 && mdio) |=> (present == 4'b0010)
    );

    // S_ST stays in S_ST when the start-of-frame bit is not detected.
    check_s_st_stays: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0001 && !mdio) |=> (present == 4'b0001)
    );

    // S_OP_CODE shifts the opcode bits until the opcode is complete.
    check_s_op_code_shifts: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0010 && !op_code_shift) |=> (present == 4'b0010)
    );

    // S_OP_CODE loads the opcode bit on the last opcode bit.
    check_s_op_code_loads: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0010 && op_code_shift && op_code_done) |=> (present == 4'b0011)
    );

    // S_OP_CODE returns to S_PREAMBLE on an invalid opcode.
    check_s_op_code_invalid_returns_to_preamble: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0010 && op_code_shift && !op_code_done && op_is_invalid) |=> (present == 4'b0000)
    );

    // S_PHY_ADDR shifts the PHY address bits until the address is complete.
    check_s_phy_addr_shifts: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0011 && !phy_addr_shift) |=> (present == 4'b0011)
    );

    // S_PHY_ADDR loads the PHY address bit on the last address bit.
    check_s_phy_addr_loads: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0011 && phy_addr_shift && phy_addr_done) |=> (present == 4'b0100)
    );

    // S_PHY_ADDR returns to S_PREAMBLE when the PHY address does not match.
    check_s_phy_addr_invalid_returns_to_preamble: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0011 && phy_addr_shift && !phy_addr_done && !phy_addr_match) |=> (present == 4'b0000)
    );

    // S_REG_ADDR shifts the register address bits until the address is complete.
    check_s_reg_addr_shifts: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0100 && !reg_addr_shift) |=> (present == 4'b0100)
    );

    // S_REG_ADDR loads the register address bit on the last address bit.
    check_s_reg_addr_loads: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0100 && reg_addr_shift && reg_addr_done) |=> (present == 4'b0101)
    );

    // S_TA stays in S_TA until the TA1 bit is detected.
    check_s_ta_stays_until_ta1: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0101 && !ta1_done) |=> (present == 4'b0101)
    );

    // S_TA loads data_out from data_rd on a read.
    check_s_ta_loads_on_read: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0101 && ta1_done && op_is_rd) |=> (present == 4'b0110)
    );

    // S_TA stays in S_TA on a write.
    check_s_ta_stays_on_write: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0101 && ta1_done && op_is_wr) |=> (present == 4'b0101)
    );

    // S_WR_DATA shifts the write data bits until the data is complete.
    check_s_wr_data_shifts: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0110 && !data_in_shift) |=> (present == 4'b0110)
    );

    // S_WR_DATA loads the write data bit on the last data bit.
    check_s_wr_data_loads: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0110 && data_in_shift && data_done) |=> (present == 4'b0111)
    );

    // S_WR_DATA stays in S_WR_DATA until the data is complete.
    check_s_wr_data_stays_until_done: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0110 && data_in_shift && !data_done) |=> (present == 4'b0110)
    );

    // S_RD_DATA shifts the read data bits until the data is complete.
    check_s_rd_data_shifts: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0111 && !data_out_shift) |=> (present == 4'b0111)
    );

    // S_RD_DATA loads the read data bit on the last data bit.
    check_s_rd_data_loads: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0111 && data_out_shift && data_done) |=> (present == 4'b0000)
    );

    // S_RD_DATA stays in S_RD_DATA until the data is complete.
    check_s_rd_data_stays_until_done: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0111 && data_out_shift && !data_done) |=> (present == 4'b0111)
    );

    // S_WR_COMMIT asserts strobe_wr and returns to S_PREAMBLE.
    check_s_wr_commit_asserts_strobe: assert property (
        @(posedge mdc) disable iff (reset)
        (present == 4'b0111) |=> (present == 4'b0000 && strobe_wr)
    );

endmodule