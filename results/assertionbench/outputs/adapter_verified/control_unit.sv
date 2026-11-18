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

// Clock: clk; Reset: rst_n active-low, asynchronous
    // Mixed logic: sequential state machine with combinational outputs

    // IDLE: wait for start or disable_core; next state depends on operation_mode
    check_idle_wait_start: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == IDLE) |-> ((start == 1'b0) || (disable_core == 1'b1) || (next_state == ROUND0_COL0) ||
                             (next_state == ROUND0_COL3) || (next_state == GEN_KEY0) || (next_state == IDLE))
    );

// ROUND0_COL0: next state depends on enc_dec; bypass_rk=1, bypass_key_en=1, key_out_sel=0, col_sel=enc_dec?ADD_RK_OUT:SHIFT_ROWS
    check_round0_col0_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND0_COL0) |-> (sbox_sel == COL_0) && (rk_sel == COL) && (bypass_rk == 1'b1) &&
                                   (bypass_key_en == 1'b1) && (key_out_sel == KEY_0) &&
                                   (col_sel == (encrypt_decrypt ? ADD_RK_OUT : SHIFT_ROWS)) &&
                                   (key_en == (encrypt_decrypt ? EN_COL_0 : COL_ALL)) &&
                                   (col_en == (encrypt_decrypt ? EN_COL_0 : COL_ALL)) &&
                                   (rd_count_en == 1'b0) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                                   (bypass_key_en == 1'b0) && (key_derivation_en == 1'b0)
    );

// ROUND0_COL1: next state depends on enc_dec; bypass_rk=1, bypass_key_en=1, key_out_sel=1, col_sel=ADD_RK_OUT, key_sel=KEY_OUT when enc_dec=0
    check_round0_col1_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND0_COL1) |-> (sbox_sel == COL_1) && (rk_sel == COL) && (bypass_rk == 1'b1) &&
                                   (bypass_key_en == 1'b1) && (key_out_sel == KEY_1) &&
                                   (col_sel == ADD_RK_OUT) &&
                                   (key_en == (encrypt_decrypt ? EN_COL_1 : EN_KEY_1)) &&
                                   (col_en == (encrypt_decrypt ? EN_COL_1 : COL_ALL)) &&
                                   (rd_count_en == 1'b0) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                                   (bypass_key_en == 1'b0) && (key_derivation_en == 1'b0)
    );

// ROUND0_COL2: next state depends on enc_dec; bypass_rk=1, bypass_key_en=1, key_out_sel=2, col_sel=ADD_RK_OUT, key_sel=KEY_OUT when enc_dec=0
    check_round0_col2_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND0_COL2) |-> (sbox_sel == COL_2) && (rk_sel == COL) && (bypass_rk == 1'b1) &&
                                   (bypass_key_en == 1'b1) && (key_out_sel == KEY_2) &&
                                   (col_sel == ADD_RK_OUT) &&
                                   (key_en == (encrypt_decrypt ? EN_COL_2 : EN_KEY_2)) &&
                                   (col_en == (encrypt_decrypt ? EN_COL_2 : COL_ALL)) &&
                                   (rd_count_en == 1'b0) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                                   (bypass_key_en == 1'b0) && (key_derivation_en == 1'b0)
    );

// ROUND0_COL3: next state depends on enc_dec; bypass_rk=1, bypass_key_en=1, key_out_sel=3, col_sel=enc_dec?SHIFT_ROWS:ADD_RK_OUT
    check_round0_col3_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND0_COL3) |-> (sbox_sel == COL_3) && (rk_sel == COL) && (bypass_rk == 1'b1) &&
                                   (bypass_key_en == 1'b1) && (key_out_sel == KEY_3) &&
                                   (col_sel == (encrypt_decrypt ? SHIFT_ROWS : ADD_RK_OUT)) &&
                                   (key_en == (encrypt_decrypt ? COL_ALL : EN_COL_3)) &&
                                   (col_en == (encrypt_decrypt ? COL_ALL : EN_COL_3)) &&
                                   (rd_count_en == 1'b0) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                                   (bypass_key_en == 1'b0) && (key_derivation_en == 1'b0)
    );

// ROUND_KEY0: next state depends on first_round; bypass_rk=0, bypass_key_en=0, key_en=EN_KEY_0, rd_count_en=1
    check_round_key0_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_KEY0) |-> (sbox_sel == G_FUNCTION) && (rk_sel == COL) && (bypass_rk == 1'b0) &&
                                  (bypass_key_en == 1'b0) && (key_out_sel == KEY_0) &&
                                  (key_sel == KEY_OUT) && (key_en == EN_KEY_0) &&
                                  (col_sel == INPUT) && (col_en == COL_DIS) &&
                                  (rd_count_en == 1'b1) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                                  (bypass_key_en == 1'b0) && (key_derivation_en == 1'b0)
    );

// ROUND_COL0: next state depends on enc_dec; bypass_rk=0, bypass_key_en=0, key_sel=KEY_OUT, key_en=EN_KEY_1 when enc_dec=1, col_sel=enc_dec?ADD_RK_OUT:SHIFT_ROWS
    check_round_col0_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL0) |-> (sbox_sel == COL_0) && (rk_sel == (last_round ? MIXCOL_IN : MIXCOL_OUT)) &&
                                  (bypass_rk == 1'b0) && (bypass_key_en == 1'b0) && (key_out_sel == KEY_0) &&
                                  (key_sel == KEY_OUT) && (key_en == (encrypt_decrypt ? EN_KEY_1 : EN_KEY_0)) &&
                                  (col_sel == (encrypt_decrypt ? ADD_RK_OUT : SHIFT_ROWS)) &&
                                  (col_en == (encrypt_decrypt ? EN_COL_0 : COL_ALL)) &&
                                  (rd_count_en == 1'b0) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                                  (bypass_key_en == 1'b0) && (key_derivation_en == 1'b0)
    );

// ROUND_COL1: next state depends on enc_dec; bypass_rk=0, bypass_key_en=0, key_sel=KEY_OUT, key_en=EN_KEY_2 when enc_dec=1, col_sel=ADD_RK_OUT
    check_round_col1_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL1) |-> (sbox_sel == COL_1) && (rk_sel == (last_round ? MIXCOL_IN : MIXCOL_OUT)) &&
                                  (bypass_rk == 1'b0) && (bypass_key_en == 1'b0) && (key_out_sel == KEY_1) &&
                                  (key_sel == KEY_OUT) && (key_en == (encrypt_decrypt ? EN_KEY_2 : EN_KEY_1)) &&
                                  (col_sel == ADD_RK_OUT) &&
                                  (col_en == (encrypt_decrypt ? EN_COL_1 : COL_ALL)) &&
                                  (rd_count_en == 1'b0) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                                  (bypass_key_en == 1'b0) && (key_derivation_en == 1'b0)
    );

// ROUND_COL2: next state depends on enc_dec; bypass_rk=0, bypass_key_en=0, key_sel=KEY_OUT, key_en=EN_KEY_3 when enc_dec=1, col_sel=ADD_RK_OUT
    check_round_col2_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL2) |-> (sbox_sel == COL_2) && (rk_sel == (last_round ? MIXCOL_IN : MIXCOL_OUT)) &&
                                  (bypass_rk == 1'b0) && (bypass_key_en == 1'b0) && (key_out_sel == KEY_2) &&
                                  (key_sel == KEY_OUT) && (key_en == (encrypt_decrypt ? EN_KEY_3 : EN_KEY_2)) &&
                                  (col_sel == ADD_RK_OUT) &&
                                  (col_en == (encrypt_decrypt ? EN_COL_2 : COL_ALL)) &&
                                  (rd_count_en == 1'b0) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                                  (bypass_key_en == 1'b0) && (key_derivation_en == 1'b0)
    );

// ROUND_COL3: next state depends on enc_dec; bypass_rk=0, bypass_key_en=0, key_sel=KEY_OUT, key_en=EN_KEY_3 when enc_dec=0, col_sel=enc_dec?SHIFT_ROWS:ADD_RK_OUT
    check_round_col3_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == ROUND_COL3) |-> (sbox_sel == COL_3) && (rk_sel == (last_round ? MIXCOL_IN : MIXCOL_OUT)) &&
                                  (bypass_rk == 1'b0) && (bypass_key_en == 1'b0) && (key_out_sel == KEY_3) &&
                                  (key_sel == KEY_OUT) && (key_en == (encrypt_decrypt ? COL_ALL : EN_KEY_3)) &&
                                  (col_sel == (encrypt_decrypt ? SHIFT_ROWS : ADD_RK_OUT)) &&
                                  (col_en == (encrypt_decrypt ? COL_ALL : EN_COL_3)) &&
                                  (rd_count_en == 1'b0) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                                  (bypass_key_en == 1'b0) && (key_derivation_en == 1'b0)
    );

// GEN_KEY0: next state=GEN_KEY1; bypass_rk=0, bypass_key_en=0, key_en=EN_KEY_0, rd_count_en=1
    check_gen_key0_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == GEN_KEY0) |-> (sbox_sel == G_FUNCTION) && (rk_sel == COL) && (bypass_rk == 1'b0) &&
                               (bypass_key_en == 1'b0) && (key_out_sel == KEY_0) &&
                               (key_sel == KEY_OUT) && (key_en == EN_KEY_0) &&
                               (col_sel == INPUT) && (col_en == COL_DIS) &&
                               (rd_count_en == 1'b1) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                               (bypass_key_en == 1'b0) && (key_derivation_en == 1'b0)
    );

// GEN_KEY1: next state=GEN_KEY2; bypass_rk=0, bypass_key_en=1, key_en=EN_KEY_1|EN_KEY_0, key_sel=KEY_OUT
    check_gen_key1_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == GEN_KEY1) |-> (sbox_sel == G_FUNCTION) && (rk_sel == COL) && (bypass_rk == 1'b0) &&
                               (bypass_key_en == 1'b1) && (key_out_sel == KEY_0) &&
                               (key_sel == KEY_OUT) && (key_en == (EN_KEY_1 | EN_KEY_0)) &&
                               (col_sel == INPUT) && (col_en == COL_DIS) &&
                               (rd_count_en == 1'b0) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                               (bypass_key_en == 1'b1) && (key_derivation_en == 1'b0)
    );

// GEN_KEY2: next state=GEN_KEY3; bypass_rk=0, bypass_key_en=1, key_en=EN_KEY_2, key_sel=KEY_OUT
    check_gen_key2_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == GEN_KEY2) |-> (sbox_sel == G_FUNCTION) && (rk_sel == COL) && (bypass_rk == 1'b0) &&
                               (bypass_key_en == 1'b1) && (key_out_sel == KEY_0) &&
                               (key_sel == KEY_OUT) && (key_en == EN_KEY_2) &&
                               (col_sel == INPUT) && (col_en == COL_DIS) &&
                               (rd_count_en == 1'b0) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                               (bypass_key_en == 1'b1) && (key_derivation_en == 1'b0)
    );

// GEN_KEY3: next state=READY when last_round; else next state=GEN_KEY0; bypass_rk=0, bypass_key_en=1, key_en=EN_KEY_3, key_sel=KEY_OUT
    check_gen_key3_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == GEN_KEY3) |-> (sbox_sel == G_FUNCTION) && (rk_sel == COL) && (bypass_rk == 1'b0) &&
                               (bypass_key_en == 1'b1) && (key_out_sel == KEY_0) &&
                               (key_sel == KEY_OUT) && (key_en == EN_KEY_3) &&
                               (col_sel == INPUT) && (col_en == COL_DIS) &&
                               (rd_count_en == 1'b0) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                               (bypass_key_en == 1'b1) && (key_derivation_en == 1'b0)
    );

// READY: next state=IDLE; end_comp=1; key_derivation_en=1 when op_mode==KEY_DERIVATION
    check_ready_outputs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (state == READY) |-> (sbox_sel == COL_0) && (rk_sel == COL) && (bypass_rk == 1'b0) &&
                            (bypass_key_en == 1'b0) && (key_out_sel == KEY_0) &&
                            (key_sel == KEY_OUT) && (key_en == KEY_DIS) &&
                            (col_sel == INPUT) && (col_en == COL_DIS) &&
                            (rd_count_en == 1'b0) && (iv_cnt_en == 1'b0) && (iv_cnt_sel == IV_BUS) &&
                            (bypass_key_en == 1'b0) && (key_derivation_en == (op_mode == KEY_DERIVATION)) &&
                            (end_comp == 1'b1)
    );

// end_comp is 1 only when state==READY
    check_end_comp_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        (end_comp == 1'b1) |-> (state == READY)
    );

// key_derivation_en is 1 only when state==READY and op_mode==KEY_DERIVATION
    check_key_derivation_en_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        (key_derivation_en == 1'b1) |-> (state == READY) && (op_mode == KEY_DERIVATION)
    );

// key_sel is KEY_OUT only when state==ROUND_KEY0, ROUND_COL0, ROUND_COL1, ROUND_COL2, ROUND_COL3, GEN_KEY0, GEN_KEY1, GEN_KEY2, GEN_KEY3, READY
    check_key_sel_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        (key_sel == KEY_OUT) |-> (state == ROUND_KEY0) || (state == ROUND_COL0) || (state == ROUND_COL1) ||
                                (state == ROUND_COL2) || (state == ROUND_COL3) || (state == GEN_KEY0) ||
                                (state == GEN_KEY1) || (state == GEN_KEY2) || (state == GEN_KEY3) || (state == READY)
    );

// key_en is EN_KEY_0 only when state==ROUND_KEY0
    check_key_en_key0_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        (key_en == EN_KEY_0) |-> (state == ROUND_KEY0)
    );

// key_en is EN_KEY_1 only when state==ROUND_COL0 and enc_dec=1
    check_key_en_key1_definition: assert property (
        @(posedge clk) disable iff (!rst_n)
        (key_en == EN_KEY_1) |-> (state ==