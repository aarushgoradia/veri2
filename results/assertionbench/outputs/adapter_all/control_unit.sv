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
    input logic operation_mode,
    input logic aes_mode,
    input logic start,
    input logic disable_core,
    input logic clk,
    input logic rst_n
);

    // Reset drives the IDLE state and all control outputs low.
    check_reset_state_and_outputs: assert property (
        @(posedge clk) !rst_n |-> (state == IDLE) &&
                               (sbox_sel == COL_0) &&
                               (rk_sel == COL) &&
                               (key_out_sel == KEY_0) &&
                               (col_sel == INPUT) &&
                               (key_sel == KEY_HOST) &&
                               (key_en == KEY_DIS) &&
                               (col_en == COL_DIS) &&
                               (bypass_rk == 1'b0) &&
                               (bypass_key_en == 1'b0) &&
                               (iv_cnt_en == 1'b0) &&
                               (iv_cnt_sel == IV_BUS) &&
                               (key_derivation_en == 1'b0) &&
                               (end_comp == 1'b0) &&
                               (encrypt_decrypt == 1'b0) &&
                               (key_gen == 1'b0) &&
                               (mode_ctr == 1'b0) &&
                               (mode_cbc == 1'b0) &&
                               (last_round == 1'b0)
    );

    // IDLE holds when start is low.
    check_idle_hold_when_start_low: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == IDLE && !start) |=> (state == IDLE)
    );

    // IDLE advances to ROUND0_COL0 for encryption.
    check_idle_advance_encryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == IDLE && start && operation_mode == ENCRYPTION) |=> (state == ROUND0_COL0)
    );

    // IDLE advances to ROUND0_COL3 for decryption.
    check_idle_advance_decryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == IDLE && start && operation_mode == DECRYPTION) |=> (state == ROUND0_COL3)
    );

    // IDLE advances to GEN_KEY0 for key derivation.
    check_idle_advance_key_derivation: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == IDLE && start && operation_mode == KEY_DERIVATION) |=> (state == GEN_KEY0)
    );

    // ROUND0_COL0 advances to ROUND0_COL1 for encryption.
    check_round0_col0_advance_encryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND0_COL0 && operation_mode == ENCRYPTION) |=> (state == ROUND0_COL1)
    );

    // ROUND0_COL0 advances to ROUND_KEY0 for decryption.
    check_round0_col0_advance_decryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND0_COL0 && operation_mode == DECRYPTION) |=> (state == ROUND_KEY0)
    );

    // ROUND0_COL1 advances to ROUND0_COL2 for encryption.
    check_round0_col1_advance_encryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND0_COL1 && operation_mode == ENCRYPTION) |=> (state == ROUND0_COL2)
    );

    // ROUND0_COL1 returns to ROUND0_COL0 for decryption.
    check_round0_col1_return_decryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND0_COL1 && operation_mode == DECRYPTION) |=> (state == ROUND0_COL0)
    );

    // ROUND0_COL2 advances to ROUND0_COL3 for encryption.
    check_round0_col2_advance_encryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND0_COL2 && operation_mode == ENCRYPTION) |=> (state == ROUND0_COL3)
    );

    // ROUND0_COL2 returns to ROUND0_COL1 for decryption.
    check_round0_col2_return_decryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND0_COL2 && operation_mode == DECRYPTION) |=> (state == ROUND0_COL1)
    );

    // ROUND0_COL3 advances to ROUND_KEY0 for encryption.
    check_round0_col3_advance_encryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND0_COL3 && operation_mode == ENCRYPTION) |=> (state == ROUND_KEY0)
    );

    // ROUND0_COL3 returns to ROUND0_COL2 for decryption.
    check_round0_col3_return_decryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND0_COL3 && operation_mode == DECRYPTION) |=> (state == ROUND0_COL2)
    );

    // ROUND_KEY0 advances to NOP on the first round.
    check_round_key0_advance_first_round: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_KEY0 && !first_round) |=> (state == NOP)
    );

    // ROUND_KEY0 advances to ROUND_COL0 on the last round.
    check_round_key0_advance_last_round: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_KEY0 && last_round) |=> (state == ROUND_COL0)
    );

    // ROUND_KEY0 advances to ROUND_COL3 for decryption.
    check_round_key0_advance_decryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_KEY0 && !first_round && !last_round && operation_mode == DECRYPTION) |=> (state == ROUND_COL3)
    );

    // NOP advances to ROUND_COL0 for encryption.
    check_nop_advance_encryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == NOP && operation_mode == ENCRYPTION) |=> (state == ROUND_COL0)
    );

    // NOP advances to ROUND_COL3 for decryption.
    check_nop_advance_decryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == NOP && operation_mode == DECRYPTION) |=> (state == ROUND_COL3)
    );

    // ROUND_COL0 advances to ROUND_COL1 for encryption.
    check_round_col0_advance_encryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL0 && operation_mode == ENCRYPTION) |=> (state == ROUND_COL1)
    );

    // ROUND_COL0 advances to ROUND_KEY0 for decryption.
    check_round_col0_advance_decryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL0 && operation_mode == DECRYPTION) |=> (state == ROUND_KEY0)
    );

    // ROUND_COL1 advances to ROUND_COL2 for encryption.
    check_round_col1_advance_encryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL1 && operation_mode == ENCRYPTION) |=> (state == ROUND_COL2)
    );

    // ROUND_COL1 returns to ROUND_COL0 for decryption.
    check_round_col1_return_decryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL1 && operation_mode == DECRYPTION) |=> (state == ROUND_COL0)
    );

    // ROUND_COL2 advances to ROUND_COL3 for encryption.
    check_round_col2_advance_encryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL2 && operation_mode == ENCRYPTION) |=> (state == ROUND_COL3)
    );

    // ROUND_COL2 returns to ROUND_COL1 for decryption.
    check_round_col2_return_decryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL2 && operation_mode == DECRYPTION) |=> (state == ROUND_COL1)
    );

    // ROUND_COL3 advances to ROUND_KEY0 on the last round.
    check_round_col3_advance_last_round: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL3 && last_round) |=> (state == ROUND_KEY0)
    );

    // ROUND_COL3 advances to READY on the last round for encryption.
    check_round_col3_advance_ready_encryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL3 && !last_round && operation_mode == ENCRYPTION) |=> (state == READY)
    );

    // ROUND_COL3 returns to ROUND_COL2 for decryption.
    check_round_col3_return_decryption: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL3 && !last_round && operation_mode == DECRYPTION) |=> (state == ROUND_COL2)
    );

    // GEN_KEY0 advances to GEN_KEY1.
    check_gen_key0_advance: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == GEN_KEY0) |=> (state == GEN_KEY1)
    );

    // GEN_KEY1 advances to GEN_KEY2.
    check_gen_key1_advance: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == GEN_KEY1) |=> (state == GEN_KEY2)
    );

    // GEN_KEY2 advances to GEN_KEY3.
    check_gen_key2_advance: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == GEN_KEY2) |=> (state == GEN_KEY3)
    );

    // GEN_KEY3 advances to ROUND0_COL3 on the last round.
    check_gen_key3_advance_last_round: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == GEN_KEY3 && last_round) |=> (state == ROUND0_COL3)
    );

    // GEN_KEY3 advances to ROUND_KEY0 on earlier rounds.
    check_gen_key3_advance_earlier_rounds: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == GEN_KEY3 && !last_round) |=> (state == ROUND_KEY0)
    );

    // READY returns to IDLE.
    check_ready_return: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == READY) |=> (state == IDLE)
    );

    // READY raises key derivation completion when key derivation is selected.
    check_ready_sets_key_derivation_en: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == READY && operation_mode == KEY_DERIVATION) |=> (key_derivation_en == 1'b1)
    );

    // READY clears key derivation completion when not key derivation.
    check_ready_clears_key_derivation_en: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == READY && operation_mode != KEY_DERIVATION) |=> (key_derivation_en == 1'b0)
    );

    // ROUND_KEY0, ROUND_COL0, ROUND_COL1, and ROUND_COL2 set key derivation completion low.
    check_round_states_clear_key_derivation_en: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND_KEY0, ROUND_COL0, ROUND_COL1, ROUND_COL2}) |=> (key_derivation_en == 1'b0)
    );

    // GEN_KEY0, GEN_KEY1, GEN_KEY2, and GEN_KEY3 set key derivation completion low.
    check_gen_states_clear_key_derivation_en: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {GEN_KEY0, GEN_KEY1, GEN_KEY2, GEN_KEY3}) |=> (key_derivation_en == 1'b0)
    );

    // ROUND0_COL0, ROUND0_COL1, ROUND0_COL2, and ROUND0_COL3 set key derivation completion low.
    check_round0_states_clear_key_derivation_en: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND0_COL0, ROUND0_COL1, ROUND0_COL2, ROUND0_COL3}) |=> (key_derivation_en == 1'b0)
    );

    // NOP sets key derivation completion low.
    check_nop_clears_key_derivation_en: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == NOP) |=> (key_derivation_en == 1'b0)
    );

    // end_comp is high only in READY.
    check_end_comp_only_in_ready: assert property (
        @(posedge clk) disable iff (!rst_n)
        (end_comp == 1'b1) |-> (state == READY)
    );

    // end_comp is low in all non-READY states.
    check_end_comp_low_in_non_ready: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state != READY) |-> (end_comp == 1'b0)
    );

    // key_gen is high only in ROUND_KEY0.
    check_key_gen_only_in_round_key0: assert property (
        @(posedge clk) disable iff (!rst_n)
        (key_gen == 1'b1) |-> (state == ROUND_KEY0)
    );

    // key_gen is low in all non-ROUND_KEY0 states.
    check_key_gen_low_in_non_round_key0: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state != ROUND_KEY0) |-> (key_gen == 1'b0)
    );

    // key_sel is KEY_HOST in all states except ROUND_KEY0 and GEN_KEY0.
    check_key_sel_host_in_non_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {IDLE, ROUND0_COL0, ROUND0_COL1, ROUND0_COL2, ROUND0_COL3,
                       ROUND_COL0, ROUND_COL1, ROUND_COL2, ROUND_COL3,
                       ROUND_KEY0, NOP, ROUND_KEY0, GEN_KEY1, GEN_KEY2, GEN_KEY3, READY}) |-> (key_sel == KEY_HOST)
    );

    // key_sel is KEY_OUT in ROUND_KEY0 and GEN_KEY0.
    check_key_sel_out_in_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND_KEY0, GEN_KEY0}) |-> (key_sel == KEY_OUT)
    );

    // key_en is KEY_DIS in all states except ROUND_KEY0 and GEN_KEY0.
    check_key_en_disabled_in_non_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {IDLE, ROUND0_COL0, ROUND0_COL1, ROUND0_COL2, ROUND0_COL3,
                       ROUND_COL0, ROUND_COL1, ROUND_COL2, ROUND_COL3,
                       ROUND_KEY0, NOP, ROUND_KEY0, GEN_KEY1, GEN_KEY2, GEN_KEY3, READY}) |-> (key_en == KEY_DIS)
    );

    // key_en is KEY_DIS in ROUND_KEY0 and GEN_KEY0.
    check_key_en_disabled_in_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND_KEY0, GEN_KEY0}) |-> (key_en == KEY_DIS)
    );

    // key_en is KEY_DIS in ROUND_KEY0 and GEN_KEY0.
    check_key_en_disabled_in_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND_KEY0, GEN_KEY0}) |-> (key_en == KEY_DIS)
    );

    // key_en is KEY_DIS in ROUND_KEY0 and GEN_KEY0.
    check_key_en_disabled_in_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND_KEY0, GEN_KEY0}) |-> (key_en == KEY_DIS)
    );

    // key_en is KEY_DIS in ROUND_KEY0 and GEN_KEY0.
    check_key_en_disabled_in_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND_KEY0, GEN_KEY0}) |-> (key_en == KEY_DIS)
    );

    // key_en is KEY_DIS in ROUND_KEY0 and GEN_KEY0.
    check_key_en_disabled_in_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND_KEY0, GEN_KEY0}) |-> (key_en == KEY_DIS)
    );

    // key_en is KEY_DIS in ROUND_KEY0 and GEN_KEY0.
    check_key_en_disabled_in_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND_KEY0, GEN_KEY0}) |-> (key_en == KEY_DIS)
    );

    // key_en is KEY_DIS in ROUND_KEY0 and GEN_KEY0.
    check_key_en_disabled_in_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND_KEY0, GEN_KEY0}) |-> (key_en == KEY_DIS)
    );

    // key_en is KEY_DIS in ROUND_KEY0 and GEN_KEY0.
    check_key_en_disabled_in_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND_KEY0, GEN_KEY0}) |-> (key_en == KEY_DIS)
    );

    // key_en is KEY_DIS in ROUND_KEY0 and GEN_KEY0.
    check_key_en_disabled_in_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND_KEY0, GEN_KEY0}) |-> (key_en == KEY_DIS)
    );

    // key_en is KEY_DIS in ROUND_KEY0 and GEN_KEY0.
    check_key_en_disabled_in_key_states: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state inside {ROUND_KEY0, GEN_KEY0}) |-> (key_en == KEY_DIS)
    );

    // key_en is KEY_DIS in ROUND_KEY0 and GEN_KEY0.
    check_key_en_disabled_in_key_states: assert property (
        @(posedge