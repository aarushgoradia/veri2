module cavlc_len_gen_sva (
    input logic        clk,
    input logic [7:0]  cavlc_state,
    input logic [4:0]  len_read_total_coeffs_comb,
    input logic [4:0]  len_read_levels_comb,
    input logic [3:0]  len_read_total_zeros_comb,
    input logic [3:0]  len_read_run_befores_comb,
    input logic [4:0]  len_comb
);

    // State bit 0 drives len_comb from len_read_total_coeffs_comb.
    check_len_from_total_coeffs: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_read_total_coeffs_bit] |-> (len_comb == len_read_total_coeffs_comb)
    );

    // States 1, 2, and 3 drive len_comb from len_read_levels_comb.
    check_len_from_levels_states: assert property (
        @(posedge clk)
        (cavlc_state[`cavlc_read_t1s_flags_bit] ||
         cavlc_state[`cavlc_read_level_prefix_bit] ||
         cavlc_state[`cavlc_read_level_suffix_bit]) |-> (len_comb == len_read_levels_comb)
    );

    // State 6 drives len_comb from len_read_total_zeros_comb.
    check_len_from_total_zeros: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_read_total_zeros_bit] |-> (len_comb == len_read_total_zeros_comb)
    );

    // State 7 drives len_comb from len_read_run_befores_comb.
    check_len_from_run_befores: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_read_run_befores_bit] |-> (len_comb == len_read_run_befores_comb)
    );

    // States 5 and 0 drive len_comb to zero.
    check_len_zero_states: assert property (
        @(posedge clk)
        (cavlc_state[`cavlc_calc_level_bit] || cavlc_state[`cavlc_idle_bit]) |-> (len_comb == 5'd0)
    );

    // len_comb always matches the selected source length.
    check_len_matches_selected_source: assert property (
        @(posedge clk)
        len_comb == (
            (cavlc_state[`cavlc_read_total_coeffs_bit] ? len_read_total_coeffs_comb :
             (cavlc_state[`cavlc_read_t1s_flags_bit]  ||
              cavlc_state[`cavlc_read_level_prefix_bit] ||
              cavlc_state[`cavlc_read_level_suffix_bit] ? len_read_levels_comb :
             (cavlc_state[`cavlc_read_total_zeros_bit] ? len_read_total_zeros_comb :
              (cavlc_state[`cavlc_read_run_befores_bit] ? len_read_run_befores_comb :
               (cavlc_state[`cavlc_calc_level_bit] || cavlc_state[`cavlc_idle_bit] ? 5'd0 : 5'bx))))
        )
    );

endmodule