module cavlc_len_gen_sva (
    input logic clk,
    input logic [7:0] cavlc_state,
    input logic [4:0] len_read_total_coeffs_comb,
    input logic [4:0] len_read_levels_comb,
    input logic [3:0] len_read_total_zeros_comb,
    input logic [3:0] len_read_run_befores_comb,
    input logic [4:0] len_comb
);

    // len_comb must match the RTL case selection.
    check_len_comb_matches_rtl_case: assert property (
        @(posedge clk)
        len_comb == (
            (cavlc_state[`cavlc_read_total_coeffs_bit]  ? len_read_total_coeffs_comb  :
            (cavlc_state[`cavlc_read_t1s_flags_bit]    ||
             cavlc_state[`cavlc_read_level_prefix_bit] ||
             cavlc_state[`cavlc_read_level_suffix_bit]) ? len_read_levels_comb        :
            (cavlc_state[`cavlc_read_total_zeros_bit]   ? len_read_total_zeros_comb   :
            (cavlc_state[`cavlc_read_run_befores_bit]   ? len_read_run_befores_comb   :
            (cavlc_state[`cavlc_calc_level_bit] ||
             cavlc_state[`cavlc_idle_bit])               ? 5'd0                      :
                                                       5'bx))))
    );

    // The idle state forces len_comb to zero.
    check_idle_state_forces_zero: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_idle_bit] |-> (len_comb == 5'd0)
    );

    // The calc-level state forces len_comb to zero.
    check_calc_level_state_forces_zero: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_calc_level_bit] |-> (len_comb == 5'd0)
    );

    // The total-zeros state uses the zero-length counter.
    check_total_zeros_state_uses_zero_counter: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_read_total_zeros_bit] |-> (len_comb == {1'b0, len_read_total_zeros_comb})
    );

    // The run-befores state uses the run-befores counter.
    check_run_befores_state_uses_run_counter: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_read_run_befores_bit] |-> (len_comb == {1'b0, len_read_run_befores_comb})
    );

    // The level-related states use the levels-length counter.
    check_level_states_use_levels_counter: assert property (
        @(posedge clk)
        (cavlc_state[`cavlc_read_t1s_flags_bit] ||
         cavlc_state[`cavlc_read_level_prefix_bit] ||
         cavlc_state[`cavlc_read_level_suffix_bit]) |-> (len_comb == {1'b0, len_read_levels_comb})
    );

    // The total-coeffs state uses the total-coeffs counter.
    check_total_coeffs_state_uses_coeffs_counter: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_read_total_coeffs_bit] |-> (len_comb == {1'b0, len_read_total_coeffs_comb})
    );

    // len_comb must never be x or z.
    check_len_comb_never_unknown: assert property (
        @(posedge clk)
        !$isunknown(len_comb)
    );

endmodule