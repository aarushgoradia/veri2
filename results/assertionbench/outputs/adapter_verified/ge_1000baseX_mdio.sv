module ge_1000baseX_mdio_sva (
    input logic reset,
    input logic mdc,
    input logic mdio,
    input logic mdio_out,
    input logic mdio_oe,
    input logic [4:0] data_addr,
    input logic [15:0] data_rd,
    input logic [15:0] data_wr,
    input logic strobe_wr
);

// Reset drives the FSM to S_PREAMBLE and clears all state.
    check_reset_state: assert property (
        @(posedge mdc) reset |-> (present == S_PREAMBLE) &&
                               (preamble_cnt == 0) &&
                               (pos_cnt == 0) &&
                               (st == 1'b0) &&
                               (op_code == 2'b00) &&
                               (phy_addr == 5'b00000) &&
                               (reg_addr == 5'b00000) &&
                               (data_in == 16'h0000) &&
                               (data_out == 16'h0000) &&
                               (strobe_wr == 1'b0) &&
                               (mdio_oe == 1'b0) &&
                               (mdio_out == 1'b0)
    );

// S_PREAMBLE increments the preamble counter when the previous bit was 0.
    check_preamble_increment: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_PREAMBLE && !preamble_match && !mdio) |-> (preamble_cnt == ($past(preamble_cnt) + 6'd1))
    );

// S_PREAMBLE clears the preamble counter when the previous bit was 1.
    check_preamble_clear: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_PREAMBLE && preamble_match && mdio) |-> (preamble_cnt == 6'd0)
    );

// S_PREAMBLE stays in S_PREAMBLE when the previous bit was 1 and match was 0.
    check_preamble_hold: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_PREAMBLE && !preamble_match && mdio) |-> (present == S_PREAMBLE)
    );

// S_ST captures mdio into st on the first sampled 1 after S_PREAMBLE.
    check_st_capture: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_PREAMBLE && !preamble_match && mdio) |-> (present == S_ST && st == 1'b1)
    );

// S_ST advances to S_OP_CODE on the first sampled 1 after S_PREAMBLE.
    check_st_advance_to_op_code: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_PREAMBLE && !preamble_match && mdio) |-> (present == S_OP_CODE)
    );

// S_OP_CODE shifts in the next bit and advances to S_PHY_ADDR on bit 6.
    check_op_code_shift_and_advance: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_OP_CODE && op_code_done) |-> (present == S_PHY_ADDR && op_code == 2'b10)
    );

// S_OP_CODE stays in S_OP_CODE when bit 6 is not sampled.
    check_op_code_hold: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_OP_CODE && !op_code_done) |-> (present == S_OP_CODE)
    );

// S_PHY_ADDR shifts in the next bit and advances to S_REG_ADDR on bit 11.
    check_phy_addr_shift_and_advance: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_PHY_ADDR && phy_addr_done && phy_addr_match) |-> (present == S_REG_ADDR && phy_addr == PHY_ADDR)
    );

// S_PHY_ADDR stays in S_PHY_ADDR when bit 11 is not sampled or the PHY address does not match.
    check_phy_addr_hold: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_PHY_ADDR && (!phy_addr_done || !phy_addr_match)) |-> (present == S_PHY_ADDR)
    );

// S_REG_ADDR shifts in the next bit and advances to S_TA on bit 12.
    check_reg_addr_shift_and_advance: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_REG_ADDR && ta0_done && phy_addr_match) |-> (present == S_TA && reg_addr == PHY_ADDR)
    );

// S_REG_ADDR stays in S_REG_ADDR when bit 12 is not sampled.
    check_reg_addr_hold: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_REG_ADDR && !ta0_done) |-> (present == S_REG_ADDR)
    );

// S_TA stays in S_TA when bit 13 is not sampled.
    check_ta_hold: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_TA && !ta1_done) |-> (present == S_TA)
    );

// S_TA loads data_out with data_rd on a read and advances to S_RD_DATA.
    check_ta_load_and_advance_read: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_TA && ta1_done && op_is_rd) |-> (present == S_RD_DATA && data_out == data_rd)
    );

// S_TA loads data_out with 0 on a write and advances to S_WR_DATA.
    check_ta_load_and_advance_write: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_TA && ta1_done && op_is_wr) |-> (present == S_WR_DATA && data_out == 16'h0000)
    );

// S_WR_DATA shifts in the next bit and advances to S_WR_COMMIT on bit 29.
    check_wr_data_shift_and_advance: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_WR_DATA && data_done && op_is_wr) |-> (present == S_WR_COMMIT && data_out == {15'h0000, 1'b0})
    );

// S_WR_DATA stays in S_WR_DATA when bit 29 is not sampled.
    check_wr_data_hold: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_WR_DATA && !data_done) |-> (present == S_WR_DATA)
    );

// S_RD_DATA shifts in the next bit and advances to S_PREAMBLE on bit 29.
    check_rd_data_shift_and_advance: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_RD_DATA && data_done && op_is_rd) |-> (present == S_PREAMBLE && data_out == {15'h0000, 1'b0})
    );

// S_RD_DATA stays in S_RD_DATA when bit 29 is not sampled.
    check_rd_data_hold: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_RD_DATA && !data_done) |-> (present == S_RD_DATA)
    );

// S_WR_COMMIT drives strobe_wr high and advances to S_PREAMBLE.
    check_wr_commit_strobe_and_advance: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_WR_COMMIT) |-> (present == S_PREAMBLE && strobe_wr == 1'b1)
    );

// mdio_oe is asserted only on the last bit of a read or the first bit of a write.
    check_mdio_oe_pattern: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_RD_DATA && data_done) || (present == S_WR_DATA && !data_done) |-> (mdio_oe == 1'b1)
    );

// mdio_out is high only on the last bit of a read.
    check_mdio_out_pattern: assert property (
        @(posedge mdc) disable iff (reset)
            (present == S_RD_DATA && data_done) |-> (mdio_out == 1'b1)
    );

endmodule
