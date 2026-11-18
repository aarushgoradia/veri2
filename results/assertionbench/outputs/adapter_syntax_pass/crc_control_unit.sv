module crc_control_unit_sva (
    input logic [1:0] byte_sel,
    input logic       bypass_byte0,
    input logic       buffer_full,
    input logic       read_wait,
    input logic       bypass_size,
    input logic       set_crc_init_sel,
    input logic       clear_crc_init_sel,
    input logic       crc_out_en,
    input logic       byte_en,
    input logic       reset_pending,
    input logic [1:0] size_in,
    input logic       write,
    input logic       reset_chain,
    input logic       clk,
    input logic       rst_n
);

    // buffer_full is asserted only during the WRITE_2 state.
    check_buffer_full_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        buffer_full == (state_full == 2'b10)
    );

    // read_wait is asserted only during non-IDLE byte states.
    check_read_wait_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        read_wait == (state_byte != 3'b100)
    );

    // bypass_byte0 is high only when the full state is not BYPASS.
    check_bypass_byte0_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        bypass_byte0 == (state_full != 2'b11)
    );

    // bypass_size is high only when the full state is not BYPASS or BYTE_0.
    check_bypass_size_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        bypass_size == !( (state_full != 2'b11 && state_byte != 3'b000) ||
                         (state_full == 2'b11) )
    );

    // crc_out_en is high only when the byte state is not IDLE.
    check_crc_out_en_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        crc_out_en == (state_byte != 3'b100)
    );

    // byte_en is high only for BYTE_0 with half-word or word size in non-BYPASS states.
    check_byte_en_condition: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en == ( (state_byte == 3'b000) &&
                     ( (size_in == 2'b01) || (size_in == 2'b10) ) &&
                     (state_full != 2'b11) )
    );

    // set_crc_init_sel is asserted only during BYTE_0.
    check_set_crc_init_sel_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        set_crc_init_sel == (state_byte == 3'b000)
    );

    // clear_crc_init_sel is asserted only during the appropriate reset states.
    check_clear_crc_init_sel_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        clear_crc_init_sel == ( (state_reset == 3'b000 && last_byte && reset_chain) ||
                                (state_byte  == 3'b100 && reset_chain) ||
                                (state_reset == 3'b001 && last_byte) ||
                                (state_reset == 3'b010 && last_byte) ||
                                (state_reset == 3'b100 && last_byte) )
    );

    // reset_pending is asserted only during non-idle reset states.
    check_reset_pending_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        reset_pending == (state_reset != 3'b000)
    );

    // buffer_full implies read_wait is asserted.
    check_buffer_full_implies_read_wait: assert property (
        @(posedge clk) disable iff (!rst_n)
        buffer_full |-> read_wait
    );

    // buffer_full implies the full state is WRITE_2.
    check_buffer_full_implies_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        buffer_full |-> (state_full == 2'b10)
    );

    // read_wait implies the byte state is not IDLE.
    check_read_wait_implies_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        read_wait |-> (state_byte != 3'b100)
    );

    // reset_pending implies the reset state is not NO_RESET.
    check_reset_pending_implies_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        reset_pending |-> (state_reset != 3'b000)
    );

    // clear_crc_init_sel implies the reset state is not NO_RESET.
    check_clear_crc_init_sel_implies_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        clear_crc_init_sel |-> (state_reset != 3'b000)
    );

    // clear_crc_init_sel implies the reset state is not RESET_2.
    check_clear_crc_init_sel_implies_not_reset2: assert property (
        @(posedge clk) disable iff (!rst_n)
        clear_crc_init_sel |-> (state_reset != 3'b100)
    );

    // clear_crc_init_sel implies the reset state is not WRITE.
    check_clear_crc_init_sel_implies_not_write: assert property (
        @(posedge clk) disable iff (!rst_n)
        clear_crc_init_sel |-> (state_reset != 3'b010)
    );

    // clear_crc_init_sel implies the reset state is not WAIT.
    check_clear_crc_init_sel_implies_not_wait: assert property (
        @(posedge clk) disable iff (!rst_n)
        clear_crc_init_sel |-> (state_reset != 3'b011)
    );

    // clear_crc_init_sel implies the reset state is not RESET.
    check_clear_crc_init_sel_implies_not_reset: assert property (
        @(posedge clk) disable iff (!rst_n)
        clear_crc_init_sel |-> (state_reset != 3'b001)
    );

    // clear_crc_init_sel implies the byte state is not IDLE.
    check_clear_crc_init_sel_implies_not_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        clear_crc_init_sel |-> (state_byte != 3'b100)
    );

    // clear_crc_init_sel implies reset_chain is asserted.
    check_clear_crc_init_sel_implies_reset_chain: assert property (
        @(posedge clk) disable iff (!rst_n)
        clear_crc_init_sel |-> reset_chain
    );

    // clear_crc_init_sel implies last_byte is asserted.
    check_clear_crc_init_sel_implies_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        clear_crc_init_sel |-> last_byte
    );

    // set_crc_init_sel implies the byte state is BYTE_0.
    check_set_crc_init_sel_implies_state: assert property (
        @(posedge clk) disable iff (!rst_n)
        set_crc_init_sel |-> (state_byte == 3'b000)
    );

    // set_crc_init_sel implies reset_chain is deasserted.
    check_set_crc_init_sel_implies_not_reset_chain: assert property (
        @(posedge clk) disable iff (!rst_n)
        set_crc_init_sel |-> !reset_chain
    );

    // set_crc_init_sel implies last_byte is deasserted.
    check_set_crc_init_sel_implies_not_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        set_crc_init_sel |-> !last_byte
    );

    // set_crc_init_sel implies the full state is not BYPASS.
    check_set_crc_init_sel_implies_not_bypass: assert property (
        @(posedge clk) disable iff (!rst_n)
        set_crc_init_sel |-> (state_full != 2'b11)
    );

    // clear_crc_init_sel has priority over set_crc_init_sel.
    check_clear_overrides_set: assert property (
        @(posedge clk) disable iff (!rst_n)
        (clear_crc_init_sel && set_crc_init_sel) |-> !set_crc_init_sel
    );

    // set_crc_init_sel is never asserted with reset_chain deasserted.
    check_set_requires_reset_chain: assert property (
        @(posedge clk) disable iff (!rst_n)
        set_crc_init_sel |-> reset_chain
    );

    // clear_crc_init_sel is never asserted with reset_chain deasserted.
    check_clear_requires_reset_chain: assert property (
        @(posedge clk) disable iff (!rst_n)
        clear_crc_init_sel |-> reset_chain
    );

    // clear_crc_init_sel is never asserted with last_byte deasserted.
    check_clear_requires_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        clear_crc_init_sel |-> last_byte
    );

    // set_crc_init_sel is never asserted with last_byte asserted.
    check_set_requires_not_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        set_crc_init_sel |-> !last_byte
    );

    // set_crc_init_sel is never asserted with the full state in BYPASS.
    check_set_requires_not_bypass: assert property (
        @(posedge clk) disable iff (!rst_n)
        set_crc_init_sel |-> (state_full != 2'b11)
    );

    // byte_en is never asserted for BYTE_0 with byte size in BYPASS states.
    check_byte_en_requires_non_bypass: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> (state_full != 2'b11)
    );

    // byte_en is never asserted for BYTE_0 with half-word or word size in BYPASS states.
    check_byte_en_requires_non_bypass_sizes: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      ( (size_in == 2'b01) || (size_in == 2'b10) ) &&
                      (state_full == 2'b11))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in WRITE_2 states.
    check_byte_en_requires_non_write2_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b10)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en is never asserted for last_byte with data in BYPASS states.
    check_byte_en_requires_non_bypass_last_byte: assert property (
        @(posedge clk) disable iff (!rst_n)
        byte_en |-> !((state_byte == 3'b000) &&
                      (last_byte && (state_full == 2'b11)))
    );

    // byte_en