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

// buffer_full is high when the full buffer state is active and the last byte is not the current one.
    check_buffer_full_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_2 && !last_byte) || (state_full == BYPASS && !last_byte) |-> buffer_full
    );

// read_wait is high when the byte state is not idle.
    check_read_wait_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte != IDLE) |-> read_wait
    );

// bypass_byte0 is high when the full buffer state is not active.
    check_bypass_byte0_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full != BYPASS) |-> bypass_byte0
    );

// bypass_size is high when the full buffer state is active or the byte state is idle.
    check_bypass_size_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        ((state_full != BYPASS) && (state_byte != BYTE_0)) || (state_full == BYPASS) |-> bypass_size
    );

// crc_out_en is high when the byte state is not idle.
    check_crc_out_en_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte != IDLE) |-> crc_out_en
    );

// byte_en is high for the first byte of a half-word or word write, or for the last byte of a write.
    check_byte_en_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        ((state_byte == BYTE_0) && (size_in == HALF_WORD || size_in == WORD) && (state_full != BYPASS)) ||
        (last_byte && has_data) |-> byte_en
    );

// set_crc_init_sel is high only when the byte state is BYTE_0.
    check_set_crc_init_sel_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_0) |-> set_crc_init_sel
    );

// clear_crc_init_sel is high for the last byte of a write with reset_chain asserted.
    check_clear_crc_init_sel_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        (last_byte && write && reset_chain) |-> clear_crc_init_sel
    );

// reset_pending is high when the reset state is not NO_RESET.
    check_reset_pending_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset != NO_RESET) |-> reset_pending
    );

// A write to the full buffer state advances to WRITE_2 when the last byte is not the current one.
    check_full_to_write2_when_not_last: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_1 && !last_byte && write) |-> (state_full == WRITE_2)
    );

// A write to the full buffer state advances to BYPASS when the last byte is the current one.
    check_full_to_bypass_when_last: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_1 && last_byte && write) |-> (state_full == BYPASS)
    );

// A non-write to the full buffer state returns to EMPTY when the last byte is the current one.
    check_full_to_empty_when_last_no_write: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_1 && last_byte && !write) |-> (state_full == EMPTY)
    );

// A non-write to WRITE_2 returns to WRITE_1 when the last byte is the current one.
    check_write2_to_write1_when_last_no_write: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == WRITE_2 && last_byte && !write) |-> (state_full == WRITE_1)
    );

// A write to BYPASS returns to WRITE_1 when the last byte is the current one.
    check_bypass_to_write1_when_last: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == BYPASS && last_byte && write) |-> (state_full == WRITE_1)
    );

// A non-write to BYPASS returns to EMPTY when the last byte is the current one.
    check_bypass_to_empty_when_last_no_write: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_full == BYPASS && last_byte && !write) |-> (state_full == EMPTY)
    );

// A write to IDLE in the byte state advances to BYTE_0.
    check_idle_to_byte0_when_write: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == IDLE && write) |-> (state_byte == BYTE_0)
    );

// A non-write to BYTE_0 advances to BYTE_1 for half-word or word, or to IDLE for byte.
    check_byte0_to_byte1_when_not_last: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_0 && !last_byte && (size_in == HALF_WORD || size_in == WORD)) |-> (state_byte == BYTE_1)
    );

// A non-write to BYTE_0 advances to IDLE for byte.
    check_byte0_to_idle_when_last: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_0 && last_byte && (size_in == BYTE)) |-> (state_byte == IDLE)
    );

// A write to BYTE_1 advances to BYTE_0 when there is data or the buffer is not full.
    check_byte1_to_byte0_when_has_data_or_not_full: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_1 && write && (has_data || !buffer_full)) |-> (state_byte == BYTE_0)
    );

// A non-write to BYTE_1 advances to IDLE when there is no data and the buffer is full.
    check_byte1_to_idle_when_no_data_and_full: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_1 && !write && !has_data && buffer_full) |-> (state_byte == IDLE)
    );

// A non-write to BYTE_1 advances to BYTE_2 for half-word or word.
    check_byte1_to_byte2_when_not_last: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_1 && !last_byte && (size_in == HALF_WORD || size_in == WORD)) |-> (state_byte == BYTE_2)
    );

// A write to BYTE_2 advances to BYTE_3.
    check_byte2_to_byte3_when_write: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_2 && write) |-> (state_byte == BYTE_3)
    );

// A non-write to BYTE_2 advances to BYTE_0 when there is data or the buffer is not full.
    check_byte2_to_byte0_when_has_data_or_not_full: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_2 && !write && (has_data || !buffer_full)) |-> (state_byte == BYTE_0)
    );

// A non-write to BYTE_2 advances to IDLE when there is no data and the buffer is full.
    check_byte2_to_idle_when_no_data_and_full: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_2 && !write && !has_data && buffer_full) |-> (state_byte == IDLE)
    );

// A write to BYTE_3 advances to BYTE_0 when there is data or the buffer is not full.
    check_byte3_to_byte0_when_has_data_or_not_full: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_3 && write && (has_data || !buffer_full)) |-> (state_byte == BYTE_0)
    );

// A non-write to BYTE_3 advances to IDLE when there is no data and the buffer is full.
    check_byte3_to_idle_when_no_data_and_full: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_3 && !write && !has_data && buffer_full) |-> (state_byte == IDLE)
    );

// A non-write to BYTE_3 advances to BYTE_0 when there is data and the buffer is not full.
    check_byte3_to_byte0_when_has_data_and_not_full: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_byte == BYTE_3 && !write && has_data && !buffer_full) |-> (state_byte == BYTE_0)
    );

// A write to IDLE in the reset state advances to RESET.
    check_reset_idle_to_reset_when_write: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == NO_RESET && write) |-> (state_reset == RESET)
    );

// A non-write to IDLE in the reset state advances to WAIT when there is data.
    check_reset_idle_to_wait_when_has_data: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == NO_RESET && !write && has_data) |-> (state_reset == WAIT)
    );

// A non-write to IDLE in the reset state advances to WRITE when there is no data.
    check_reset_idle_to_write_when_no_data: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == NO_RESET && !write && !has_data) |-> (state_reset == WRITE)
    );

// A write to RESET advances to WRITE when there is no data.
    check_reset_to_write_when_no_data: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == RESET && !write && !has_data) |-> (state_reset == WRITE)
    );

// A non-write to RESET advances to WAIT when there is data.
    check_reset_to_wait_when_has_data: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == RESET && write && has_data) |-> (state_reset == WAIT)
    );

// A non-write to RESET advances to RESET when there is no data.
    check_reset_to_reset_when_no_data: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == RESET && !write && !has_data) |-> (state_reset == RESET)
    );

// A write to WAIT advances to WRITE when there is no data.
    check_wait_to_write_when_no_data: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WAIT && !write && !has_data) |-> (state_reset == WRITE)
    );

// A non-write to WAIT advances to WAIT when there is data.
    check_wait_to_wait_when_has_data: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WAIT && write && has_data) |-> (state_reset == WAIT)
    );

// A non-write to WAIT advances to RESET when there is no data.
    check_wait_to_reset_when_no_data: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WAIT && !write && !has_data) |-> (state_reset == RESET)
    );

// A write to WRITE advances to RESET when there is no data and reset_chain is asserted.
    check_write_to_reset_when_no_data_and_chain: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WRITE && !write && !has_data && reset_chain) |-> (state_reset == RESET)
    );

// A non-write to WRITE advances to NO_RESET when there is no data and reset_chain is asserted.
    check_write_to_no_reset_when_no_data_and_chain: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WRITE && !write && !has_data && !reset_chain) |-> (state_reset == NO_RESET)
    );

// A write to WRITE advances to RESET_2 when there is data and reset_chain is asserted.
    check_write_to_reset2_when_has_data_and_chain: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WRITE && write && has_data && reset_chain) |-> (state_reset == RESET_2)
    );

// A non-write to WRITE advances to WRITE when there is data and reset_chain is asserted.
    check_write_to_write_when_has_data_and_chain: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WRITE && write && has_data && !reset_chain) |-> (state_reset == WRITE)
    );

// A non-write to WRITE advances to NO_RESET when there is no data and reset_chain is deasserted.
    check_write_to_no_reset_when_no_data_and_no_chain: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == WRITE && !write && !has_data && !reset_chain) |-> (state_reset == NO_RESET)
    );

// A write to RESET_2 advances to RESET when there is no data and reset_chain is asserted.
    check_reset2_to_reset_when_no_data_and_chain: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == RESET_2 && !write && !has_data && reset_chain) |-> (state_reset == RESET)
    );

// A non-write to RESET_2 advances to RESET when there is data.
    check_reset2_to_reset_when_has_data: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == RESET_2 && write && has_data) |-> (state_reset == RESET)
    );

// A non-write to RESET_2 advances to RESET_2 when there is no data.
    check_reset2_to_reset2_when_no_data: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state_reset == RESET_2 && !write && !has_data) |-> (state_reset == RESET_2)
    );

endmodule
