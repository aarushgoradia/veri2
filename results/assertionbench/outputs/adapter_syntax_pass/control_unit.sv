module control_unit_sva (
    input logic [2:0] sbox_sel,
    input logic [1:0] rk_sel,
    input logic [1:0] key_out_sel,
    input logic [1:0] col_sel,
    input logic [3:0] key_en,
    input logic [3:0] col_en,
    input logic [3:0] round,
    input logic bypass_rk,
    input logic bypass_key_en,
    input logic key_sel,
    input logic iv_cnt_en,
    input logic iv_cnt_sel,
    input logic key_derivation_en,
    input logic end_comp,
    input logic key_init,
    input logic key_gen,
    input logic mode_ctr,
    input logic mode_cbc,
    input logic last_round,
    input logic encrypt_decrypt,
    input logic [1:0] operation_mode,
    input logic [1:0] aes_mode,
    input logic start,
    input logic disable_core,
    input logic clk,
    input logic rst_n
);

    // End-of-computation is asserted only in the READY state.
    check_end_comp_ready_only: assert property (
        @(posedge clk) disable iff (!rst_n)
        end_comp |-> (round == 4'd10)
    );

    // End-of-computation is never asserted outside READY.
    check_end_comp_not_in_other_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        !(round == 4'd10) |-> !end_comp
    );

    // Key derivation mode drives key derivation enable.
    check_key_derivation_en_when_mode: assert property (
        @(posedge clk) disable iff (!rst_n)
        (operation_mode == 2'b01) |-> key_derivation_en
    );

    // Non-key derivation mode clears key derivation enable.
    check_key_derivation_en_when_not_mode: assert property (
        @(posedge clk) disable iff (!rst_n)
        (operation_mode != 2'b01) |-> !key_derivation_en
    );

    // In CBC mode, the IV counter is enabled on the last round.
    check_iv_counter_en_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> iv_cnt_en
    );

    // In CTR mode, the IV counter is enabled on the last round.
    check_iv_counter_en_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> iv_cnt_en
    );

    // In CBC mode, the IV counter selects the counter value.
    check_iv_counter_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (iv_cnt_sel == 1'b1)
    );

    // In CTR mode, the IV counter selects the bus value.
    check_iv_counter_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (iv_cnt_sel == 1'b0)
    );

    // In CBC mode, the IV counter is disabled outside the last round.
    check_iv_counter_disabled_outside_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> !iv_cnt_en
    );

    // In CTR mode, the IV counter is disabled outside the last round.
    check_iv_counter_disabled_outside_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> !iv_cnt_en
    );

    // In CBC mode, the last round uses the input column selector.
    check_last_round_input_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b10)
    );

    // In CTR mode, the last round uses the input column selector.
    check_last_round_input_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (col_sel == 2'b10)
    );

    // In CBC mode, non-last rounds use the add-RK-out column selector.
    check_nonlast_round_add_rk_out_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> (col_sel == 2'b01)
    );

    // In CTR mode, non-last rounds use the add-RK-out column selector.
    check_nonlast_round_add_rk_out_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> (col_sel == 2'b01)
    );

    // In CBC mode, the last round uses the shift-rows column selector.
    check_last_round_shift_rows_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b00)
    );

    // In CTR mode, the last round uses the shift-rows column selector.
    check_last_round_shift_rows_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (col_sel == 2'b00)
    );

    // In CBC mode, non-last rounds use the input column selector.
    check_nonlast_round_input_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> (col_sel == 2'b10)
    );

    // In CTR mode, non-last rounds use the input column selector.
    check_nonlast_round_input_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> (col_sel == 2'b10)
    );

    // In CBC mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b01)
    );

    // In CTR mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (col_sel == 2'b01)
    );

    // In CBC mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> (col_sel == 2'b00)
    );

    // In CTR mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> (col_sel == 2'b00)
    );

    // In CBC mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b01)
    );

    // In CTR mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (col_sel == 2'b01)
    );

    // In CBC mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> (col_sel == 2'b00)
    );

    // In CTR mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> (col_sel == 2'b00)
    );

    // In CBC mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b01)
    );

    // In CTR mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (col_sel == 2'b01)
    );

    // In CBC mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> (col_sel == 2'b00)
    );

    // In CTR mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> (col_sel == 2'b00)
    );

    // In CBC mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b01)
    );

    // In CTR mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (col_sel == 2'b01)
    );

    // In CBC mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> (col_sel == 2'b00)
    );

    // In CTR mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> (col_sel == 2'b00)
    );

    // In CBC mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b01)
    );

    // In CTR mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (col_sel == 2'b01)
    );

    // In CBC mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> (col_sel == 2'b00)
    );

    // In CTR mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> (col_sel == 2'b00)
    );

    // In CBC mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b01)
    );

    // In CTR mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (col_sel == 2'b01)
    );

    // In CBC mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> (col_sel == 2'b00)
    );

    // In CTR mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> (col_sel == 2'b00)
    );

    // In CBC mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b01)
    );

    // In CTR mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (col_sel == 2'b01)
    );

    // In CBC mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> (col_sel == 2'b00)
    );

    // In CTR mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> (col_sel == 2'b00)
    );

    // In CBC mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b01)
    );

    // In CTR mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (col_sel == 2'b01)
    );

    // In CBC mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> (col_sel == 2'b00)
    );

    // In CTR mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> (col_sel == 2'b00)
    );

    // In CBC mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b01)
    );

    // In CTR mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (col_sel == 2'b01)
    );

    // In CBC mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> (col_sel == 2'b00)
    );

    // In CTR mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> (col_sel == 2'b00)
    );

    // In CBC mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b01)
    );

    // In CTR mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && last_round) |-> (col_sel == 2'b01)
    );

    // In CBC mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && !last_round) |-> (col_sel == 2'b00)
    );

    // In CTR mode, non-last rounds use the shift-rows column selector.
    check_nonlast_round_shift_rows_sel_in_ctr: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_ctr && !last_round) |-> (col_sel == 2'b00)
    );

    // In CBC mode, the last round uses the add-RK-out column selector.
    check_last_round_add_rk_out_sel_in_cbc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (mode_cbc && last_round) |-> (col_sel == 2'b01