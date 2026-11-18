module crc_control_unit_sva (
    input logic [1:0] byte_sel,
    input logic bypass_byte0,
    input logic buffer_full,
    input logic read_wait,
    input logic bypass_size,
    input logic set_crc_init_sel,
    input logic clear_crc_init_sel,
    input logic crc_out_en,
    input logic byte_en,
    input logic reset_pending,
    input logic [1:0] size_in,
    input logic write,
    input logic reset_chain,
    input logic clk,
    input logic rst_n
);

    // Reset clears all state and derived outputs.
    check_reset_clears_state: assert property (
        @(posedge clk) !rst_n |-> (state_full == EMPTY) &&
                              (state_byte == IDLE) &&
                              (state_reset == NO_RESET) &&
                              (byte_sel == 2'b00) &&
                              (bypass_byte0 == 1'b1) &&
                              (buffer_full == 1'b0) &&
                              (read_wait == 1'b0) &&
                              (bypass_size == 1'b1) &&
                              (set_crc_init_sel == 1'b0) &&
                              (clear_crc_init_sel == 1'b0) &&
                              (crc_out_en == 1'b0) &&
                              (byte_en == 1'b0) &&
                              (reset_pending == 1'b0)
    );

    // buffer_full is asserted only in WRITE_2 with non-last byte.
    check_buffer_full_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        buffer_full == ((state_full == WRITE_2) && !last_byte)
    );

    // read_wait is asserted only when state_byte is not IDLE.
    check_read_wait_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        read_wait == (state_byte != IDLE)
    );

    // bypass_byte0 is high only when state_full is not BYPASS.
    check_bypass_byte0_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        bypass_byte0 == (state_full != BYPASS)
    );

    // has_data is high only in WRITE_2 or BYPASS with non-last byte.
    check_has_data_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        has_data == ((state_full == WRITE_2) || (state_full == BYPASS)) && !last_byte
    );

    // crc_out_en is high only when state_byte is not IDLE.
    check_crc_out_en_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        crc_out_en == (state_byte != IDLE)
    );

    // byte_en matches the implemented byte_en logic.
    check_byte_en_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en == (
            (state_byte == BYTE_0) &&
            ((size_in == HALF_WORD) || (size_in == WORD)) &&
            (state_full != BYPASS)
        ) ||
        (last_byte && has_data)
    );

    // set_crc_init_sel is asserted only when state_byte is BYTE_0.
    check_set_crc_init_sel_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        set_crc_init_sel == (state_byte == BYTE_0)
    );

    // clear_crc_init_sel matches the implemented clear logic.
    check_clear_crc_init_sel_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        clear_crc_init_sel == (
            (state_reset == NO_RESET) && last_byte && reset_chain
        ) ||
        (
            (state_byte == IDLE) && reset_chain
        ) ||
        (
            (state_reset == RESET) && last_byte
        ) ||
        (
            (state_reset == WRITE) && last_byte
        ) ||
        (
            (state_reset == RESET_2) && last_byte
        )
    );

    // reset_pending is high only when state_reset is not NO_RESET.
    check_reset_pending_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        reset_pending == (state_reset != NO_RESET)
    );

    // A write in EMPTY starts the write state machine.
    check_write_starts_write_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == EMPTY) && write |-> (state_full == WRITE_1)
    );

    // A non-write in EMPTY keeps EMPTY.
    check_no_write_keeps_empty: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == EMPTY) && !write |-> (state_full == EMPTY)
    );

    // A write in WRITE_1 with last_byte and no write returns to EMPTY.
    check_write1_last_no_write_returns_empty: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_1) && last_byte && !write |-> (state_full == EMPTY)
    );

    // A write in WRITE_1 with last_byte and write goes to BYPASS.
    check_write1_last_write_goes_bypass: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_1) && last_byte && write |-> (state_full == BYPASS)
    );

    // A non-write in WRITE_1 with last_byte keeps WRITE_1.
    check_write1_last_no_write_keeps_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_1) && last_byte && !write |-> (state_full == WRITE_1)
    );

    // A non-write in WRITE_1 with non-last_byte goes to WRITE_2.
    check_write1_nonlast_no_write_goes_write2: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_1) && !last_byte && !write |-> (state_full == WRITE_2)
    );

    // A write in WRITE_2 with last_byte and no write returns to WRITE_1.
    check_write2_last_no_write_returns_write1: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_2) && last_byte && !write |-> (state_full == WRITE_1)
    );

    // A write in WRITE_2 with last_byte and write goes to BYPASS.
    check_write2_last_write_goes_bypass: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_2) && last_byte && write |-> (state_full == BYPASS)
    );

    // A non-write in WRITE_2 with last_byte keeps WRITE_2.
    check_write2_last_no_write_keeps_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_2) && last_byte && !write |-> (state_full == WRITE_2)
    );

    // A non-write in WRITE_2 with non-last_byte returns to WRITE_1.
    check_write2_nonlast_no_write_returns_write1: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_2) && !last_byte && !write |-> (state_full == WRITE_1)
    );

    // A write in BYPASS with last_byte and no write returns to WRITE_1.
    check_bypass_last_no_write_returns_write1: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == BYPASS) && last_byte && !write |-> (state_full == WRITE_1)
    );

    // A write in BYPASS with last_byte and write goes to BYPASS.
    check_bypass_last_write_goes_bypass: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == BYPASS) && last_byte && write |-> (state_full == BYPASS)
    );

    // A non-write in BYPASS with last_byte keeps BYPASS.
    check_bypass_last_no_write_keeps_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == BYPASS) && last_byte && !write |-> (state_full == BYPASS)
    );

    // A non-write in BYPASS with non-last_byte returns to WRITE_1.
    check_bypass_nonlast_no_write_returns_write1: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == BYPASS) && !last_byte && !write |-> (state_full == WRITE_1)
    );

    // IDLE starts a write in state_byte.
    check_idle_starts_byte_write: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == IDLE) && write |-> (state_byte == BYTE_0)
    );

    // IDLE with no write keeps IDLE.
    check_idle_no_write_keeps_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == IDLE) && !write |-> (state_byte == IDLE)
    );

    // BYTE_0 with BYTE size and no write returns to IDLE.
    check_byte0_byte_last_no_write_returns_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_0) && (size_in == BYTE) && !write && !has_data |-> (state_byte == IDLE)
    );

    // BYTE_0 with BYTE size and write goes to BYTE_1.
    check_byte0_byte_last_write_goes_byte1: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_0) && (size_in == BYTE) && write |-> (state_byte == BYTE_1)
    );

    // BYTE_0 with HALF_WORD size goes to BYTE_1.
    check_byte0_halfword_goes_byte1: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_0) && (size_in == HALF_WORD) |-> (state_byte == BYTE_1)
    );

    // BYTE_0 with WORD size goes to BYTE_2.
    check_byte0_word_goes_byte2: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_0) && (size_in == WORD) |-> (state_byte == BYTE_2)
    );

    // BYTE_1 with HALF_WORD size and has_data returns to BYTE_0.
    check_byte1_halfword_hasdata_returns_byte0: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_1) && (size_in == HALF_WORD) && has_data |-> (state_byte == BYTE_0)
    );

    // BYTE_1 with HALF_WORD size and no write returns to IDLE.
    check_byte1_halfword_last_no_write_returns_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_1) && (size_in == HALF_WORD) && !write && !has_data |-> (state_byte == IDLE)
    );

    // BYTE_1 with HALF_WORD size and write goes to BYTE_0.
    check_byte1_halfword_last_write_goes_byte0: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_1) && (size_in == HALF_WORD) && write |-> (state_byte == BYTE_0)
    );

    // BYTE_1 with WORD size goes to BYTE_2.
    check_byte1_word_goes_byte2: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_1) && (size_in == WORD) |-> (state_byte == BYTE_2)
    );

    // BYTE_2 always goes to BYTE_3.
    check_byte2_goes_byte3: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_2) |-> (state_byte == BYTE_3)
    );

    // BYTE_3 with has_data returns to BYTE_0.
    check_byte3_hasdata_returns_byte0: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_3) && has_data |-> (state_byte == BYTE_0)
    );

    // BYTE_3 with no write returns to IDLE.
    check_byte3_last_no_write_returns_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_3) && !write && !has_data |-> (state_byte == IDLE)
    );

    // BYTE_3 with write goes to BYTE_0.
    check_byte3_last_write_goes_byte0: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_3) && write |-> (state_byte == BYTE_0)
    );

    // NO_RESET with reset_chain and no has_data goes to RESET.
    check_reset_noreset_starts_reset: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == NO_RESET) && reset_chain && !has_data |-> (state_reset == RESET)
    );

    // NO_RESET with reset_chain and has_data goes to WAIT.
    check_reset_noreset_starts_wait: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == NO_RESET) && reset_chain && has_data |-> (state_reset == WAIT)
    );

    // NO_RESET with no reset_chain keeps NO_RESET.
    check_reset_noreset_no_reset_chain_keeps_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == NO_RESET) && !reset_chain |-> (state_reset == NO_RESET)
    );

    // RESET with last_byte returns to NO_RESET.
    check_reset_reset_last_byte_returns_noreset: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == RESET) && last_byte |-> (state_reset == NO_RESET)
    );

    // RESET with no last_byte and write goes to WRITE.
    check_reset_reset_nonlast_write_goes_write: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == RESET) && !last_byte && write |-> (state_reset == WRITE)
    );

    // RESET with no last_byte and no write stays in RESET.
    check_reset_reset_nonlast_no_write_stays_reset: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == RESET) && !last_byte && !write |-> (state_reset == RESET)
    );

    // WAIT with last_byte goes to WRITE.
    check_reset_wait_last_byte_goes_write: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WAIT) && last_byte |-> (state_reset == WRITE)
    );

    // WAIT with no last_byte and write stays in WAIT.
    check_reset_wait_nonlast_write_stays_wait: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WAIT) && !last_byte && write |-> (state_reset == WAIT)
    );

    // WAIT with no last_byte and no write stays in WAIT.
    check_reset_wait_nonlast_no_write_stays_wait: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WAIT) && !last_byte && !write |-> (state_reset == WAIT)
    );

    // WRITE with reset_chain and last_byte goes to RESET.
    check_reset_write_last_byte_goes_reset: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WRITE) && reset_chain && last_byte |-> (state_reset == RESET)
    );

    // WRITE with reset_chain and non-last_byte goes to RESET_2.
    check_reset_write_nonlast_goes_reset2: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WRITE) && reset_chain && !last_byte |-> (state_reset == RESET_2)
    );

    // WRITE without reset_chain and last_byte goes to NO_RESET.
    check_reset_write_no_reset_chain_last_byte_goes_noreset: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WRITE) && !reset_chain && last_byte |-> (state_reset == NO_RESET)
    );

    // WRITE without reset_chain and non-last_byte stays in WRITE.
    check_reset_write_no_reset_chain_nonlast_stays_write: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WRITE) && !reset_chain && !last_byte |-> (state_reset == WRITE)
    );

    // RESET_2 with last_byte goes to WRITE.
    check_reset_reset2_last_byte_goes_write: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == RESET_2) && last_byte |-> (state_reset == WRITE)
    );

    // RESET_2 with no last_byte and write stays in RESET_2.
    check_reset_reset2_nonlast_write_stays_reset2: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == RESET_2) && !last_byte && write |-> (state_reset == RESET_2)
    );

    // RESET_2 with no last_byte and no write stays in RESET_2.
    check_reset_reset2_nonlast_no_write_stays_reset2: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == RESET_2) && !last_byte && !write |-> (state_reset == RESET_2)
    );

endmodule