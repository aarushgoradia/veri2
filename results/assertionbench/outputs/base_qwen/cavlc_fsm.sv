```systemverilog
module cavlc_fsm_sva (
    input logic clk,
    input logic rst_n,
    input logic ena,
    input logic start,
    input logic [4:0] max_coeff_num,
    input logic [4:0] TotalCoeff,
    input logic [4:0] TotalCoeff_comb,
    input logic [1:0] TrailingOnes,
    input logic [1:0] TrailingOnes_comb,
    input logic [3:0] ZeroLeft,
    output logic [7:0] state,
    output logic [3:0] i,
    output logic idle,
    output logic valid
);
    // State transitions from IDLE to READ_TOTAL_COEFFS
    state_transition_1: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_idle_s) |-> (ena && start) |-> (state == `cavlc_read_total_coeffs_s)
    );

    // State transitions from READ_TOTAL_COEFFS to READ_T1S_FLAGS
    state_transition_2: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_read_total_coeffs_s) |-> (ena && TrailingOnes_comb > 0 && TotalCoeff_comb > 0) |-> (state == `cavlc_read_t1s_flags_s)
    );

    // State transitions from READ_TOTAL_COEFFS to READ_LEVEL_PREFIX
    state_transition_3: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_read_total_coeffs_s) |-> (ena && TotalCoeff_comb > 0) |-> (state == `cavlc_read_level_prefix_s)
    );

    // State transitions from READ_TOTAL_COEFFS to IDLE and VALID
    state_transition_4: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_read_total_coeffs_s) |-> (ena && TotalCoeff_comb == 0) |-> (state == `cavlc_idle_s) && (valid == 1)
    );

    // State transitions from READ_T1S_FLAGS to READ_TOTAL_ZEROS
    state_transition_5: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_read_t1s_flags_s) |-> (ena && TrailingOnes == TotalCoeff) |-> (state == `cavlc_read_total_zeros_s)
    );

    // State transitions from READ_T1S_FLAGS to READ_LEVEL_PREFIX
    state_transition_6: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_read_t1s_flags_s) |-> (ena && TrailingOnes != TotalCoeff) |-> (state == `cavlc_read_level_prefix_s) && (i == i - TrailingOnes)
    );

    // State transitions from READ_LEVEL_PREFIX to READ_LEVEL_SUFFIX
    state_transition_7: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_read_level_prefix_s) |-> (ena) |-> (state == `cavlc_read_level_suffix_s)
    );

    // State transitions from READ_LEVEL_SUFFIX to CALC_LEVEL
    state_transition_8: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_read_level_suffix_s) |-> (ena) |-> (state == `cavlc_calc_level_s)
    );

    // State transitions from CALC_LEVEL to READ_TOTAL_ZEROS
    state_transition_9: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_calc_level_s) |-> (ena && i == 0 && TotalCoeff < max_coeff_num) |-> (state == `cavlc_read_total_zeros_s)
    );

    // State transitions from CALC_LEVEL to READ_RUN_BEFORSES
    state_transition_10: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_calc_level_s) |-> (ena && i == 0) |-> (state == `cavlc_read_run_befores_s) && (i == TotalCoeff - 1)
    );

    // State transitions from CALC_LEVEL to READ_LEVEL_PREFIX
    state_transition_11: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_calc_level_s) |-> (ena && i != 0) |-> (state == `cavlc_read_level_prefix_s) && (i == i - 1)
    );

    // State transitions from READ_TOTAL_ZEROS to READ_RUN_BEFORSES
    state_transition_12: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_read_total_zeros_s) |-> (ena) |-> (state == `cavlc_read_run_befores_s) && (i == TotalCoeff - 1)
    );

    // State transitions from READ_RUN_BEFORSES to IDLE and VALID
    state_transition_13: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_read_run_befores_s) |-> (ena && (i == 0 || ZeroLeft == 0)) |-> (state == `cavlc_idle_s) && (valid == 1)
    );

    // State transitions from READ_RUN_BEFORSES to READ_RUN_BEFORSES
    state_transition_14: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_read_run_befores_s) |-> (ena && i != 0) |-> (state == `cavlc_read_run_befores_s) && (i == i - 1)
    );

    // At reset, state should be IDLE and valid should be 0
    reset_state: assert property (
        @(posedge clk) !rst_n |-> (state == `cavlc_idle_s) && (valid == 0)
    );

    // i should be decremented in READ_LEVEL_PREFIX and READ_CALC_LEVEL states
    i_decrement: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_read_level_prefix_s || state == `cavlc_calc_level_s) |-> (ena) |-> (i == i - 1)
    );

    // i should be set to TotalCoeff - 1 in READ_TOTAL_COEFFS, READ_TOTAL_ZEROS, and READ_RUN_BEFORSES states
    i_set: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_read_total_coeffs_s || state == `cavlc_read_total_zeros_s || state == `cavlc_read_run_befores_s) |-> (ena) |-> (i == TotalCoeff - 1)
    );

    // idle should be 1 in IDLE state
    idle_state: assert property (
        @(posedge clk) disable iff (!rst_n) (state == `cavlc_idle_s) |-> (idle == 1)
    );

    // idle should be 0 in other states
    idle_not_state: assert property (
        @(posedge clk) disable iff (!rst_n) (state != `cavlc_idle_s) |-> (idle == 0)
    );
endmodule
```