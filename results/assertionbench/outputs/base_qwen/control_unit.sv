```systemverilog
module control_unit_sva (
    input logic clk,
    input logic rst_n,
    input logic [1:0] operation_mode,
    input logic [1:0] aes_mode,
    input logic start,
    input logic disable_core,
    output reg [2:0] sbox_sel,
    output reg [1:0] rk_sel,
    output reg [1:0] key_out_sel,
    output reg [1:0] col_sel,
    output reg [3:0] key_en,
    output reg [3:0] col_en,
    output reg [3:0] round,
    output reg bypass_rk,
    output reg bypass_key_en,
    output reg key_sel,
    output reg iv_cnt_en,
    output reg iv_cnt_sel,
    output reg key_derivation_en,
    output reg end_comp,
    output reg key_init,
    output reg key_gen,
    output reg mode_ctr,
    output reg mode_cbc,
    output reg last_round,
    output reg encrypt_decrypt
);
    // State transitions
    state_transition_1: assert property (
        @(posedge clk) disable iff (!rst_n) (start && operation_mode == ENCRYPTION) |-> (sbox_sel == COL_0 && rk_sel == COL && bypass_rk == ENABLE && key_out_sel == KEY_0 && col_sel == ADD_RK_OUT && col_en == EN_COL_0 && rd_count_en == ENABLE)
    );
    state_transition_2: assert property (
        @(posedge clk) disable iff (!rst_n) (start && operation_mode == DECRYPTION) |-> (sbox_sel == COL_3 && rk_sel == COL && bypass_rk == ENABLE && key_out_sel == KEY_3 && col_sel == ADD_RK_OUT && col_en == EN_COL_3 && rd_count_en == ENABLE)
    );
    state_transition_3: assert property (
        @(posedge clk) disable iff (!rst_n) (start && operation_mode == KEY_DERIVATION) |-> (sbox_sel == G_FUNCTION && key_en == EN_KEY_0 && rd_count_en == ENABLE)
    );
    state_transition_4: assert property (
        @(posedge clk) disable iff (!rst_n) (start && operation_mode == DECRYP_W_DERIV) |-> (sbox_sel == G_FUNCTION && key_en == EN_KEY_0 && rd_count_en == ENABLE)
    );

    // Round counter behavior
    round_counter_1: assert property (
        @(posedge clk) disable iff (!rst_n) (rd_count_en && !last_round) |-> (rd_count == round + 1)
    );
    round_counter_2: assert property (
        @(posedge clk) disable iff (!rst_n) (rd_count_en && last_round) |-> (rd_count == NUMBER_ROUND || rd_count == NUMBER_ROUND_INC)
    );

    // End of AES completion
    end_of_aes_1: assert property (
        @(posedge clk) disable iff (!rst_n) (state == READY) |-> (end_comp == ENABLE)
    );

    // Key derivation enable
    key_derivation_enable_1: assert property (
        @(posedge clk) disable iff (!rst_n) (state == READY && operation_mode == KEY_DERIVATION) |-> (key_derivation_en == ENABLE)
    );

    // Mode selection
    mode_selection_1: assert property (
        @(posedge clk) disable iff (!rst_n) (aes_mode == CTR) |-> (mode_ctr == ENABLE && mode_cbc == DISABLE)
    );
    mode_selection_2: assert property (
        @(posedge clk) disable iff (!rst_n) (aes_mode == CBC) |-> (mode_ctr == DISABLE && mode_cbc == ENABLE)
    );

    // Key selection
    key_selection_1: assert property (
        @(posedge clk) disable iff (!rst_n) (key_sel == KEY_HOST) |-> (key_en == KEY_DIS)
    );
    key_selection_2: assert property (
        @(posedge clk) disable iff (!rst_n) (key_sel == KEY_OUT) |-> (key_en == KEY_ALL)
    );

    // Bypass logic
    bypass_logic_1: assert property (
        @(posedge clk) disable iff (!rst_n) (bypass_rk == ENABLE) |-> (key_en == EN_KEY_1)
    );
    bypass_logic_2: assert property (
        @(posedge clk) disable iff (!rst_n) (bypass_key_en == ENABLE) |-> (key_en == EN_KEY_1 | EN_KEY_0)
    );

    // IV counter enable
    iv_counter_enable_1: assert property (
        @(posedge clk) disable iff (!rst_n) (mode_ctr && last_round && !encrypt_decrypt) |-> (iv_cnt_en == ENABLE && iv_cnt_sel == IV_CNT)
    );

    // Encrypt/Decrypt logic
    encrypt_decrypt_logic_1: assert property (
        @(posedge clk) disable iff (!rst_n) (encrypt_decrypt) |-> (key_gen == ENABLE)
    );
endmodule
```