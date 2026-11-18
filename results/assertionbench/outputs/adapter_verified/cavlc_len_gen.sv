module cavlc_len_gen_sva (
    input logic clk,
    input logic [7:0] cavlc_state,
    input logic [4:0] len_read_total_coeffs_comb,
    input logic [4:0] len_read_levels_comb,
    input logic [3:0] len_read_total_zeros_comb,
    input logic [3:0] len_read_run_befores_comb,
    input logic [4:0] len_comb
);

// len_comb matches the RTL case selection.
    check_len_comb_case_mapping: assert property (
        @(posedge clk)
        len_comb == (
            (cavlc_state[`cavlc_read_total_coeffs_bit]  ? len_read_total_coeffs_comb :
             (cavlc_state[`cavlc_read_t1s_flags_bit]    ||
              cavlc_state[`cavlc_read_level_prefix_bit] ||
              cavlc_state[`cavlc_read_level_suffix_bit] ) ? len_read_levels_comb :
             (cavlc_state[`cavlc_read_total_zeros_bit]   ? len_read_total_zeros_comb :
              (cavlc_state[`cavlc_read_run_befores_bit]   ? len_read_run_befores_comb :
               (cavlc_state[`cavlc_calc_level_bit] ||
                cavlc_state[`cavlc_idle_bit]             ? 5'd0 : 5'bx))))
        )
    );

// cavlc_read_total_coeffs_bit selects len_read_total_coeffs_comb.
    check_len_comb_total_coeffs: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_read_total_coeffs_bit] |-> (len_comb == len_read_total_coeffs_comb)
    );

// cavlc_read_t1s_flags_bit selects len_read_levels_comb.
    check_len_comb_t1s_flags: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_read_t1s_flags_bit] |-> (len_comb == len_read_levels_comb)
    );

// cavlc_read_level_prefix_bit selects len_read_levels_comb.
    check_len_comb_level_prefix: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_read_level_prefix_bit] |-> (len_comb == len_read_levels_comb)
    );

// cavlc_read_level_suffix_bit selects len_read_levels_comb.
    check_len_comb_level_suffix: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_read_level_suffix_bit] |-> (len_comb == len_read_levels_comb)
    );

// cavlc_read_total_zeros_bit selects len_read_total_zeros_comb.
    check_len_comb_total_zeros: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_read_total_zeros_bit] |-> (len_comb == len_read_total_zeros_comb)
    );

// cavlc_read_run_befores_bit selects len_read_run_befores_comb.
    check_len_comb_run_befores: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_read_run_befores_bit] |-> (len_comb == len_read_run_befores_comb)
    );

// cavlc_calc_level_bit selects zero.
    check_len_comb_calc_level_zero: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_calc_level_bit] |-> (len_comb == 5'd0)
    );

// cavlc_idle_bit selects zero.
    check_len_comb_idle_zero: assert property (
        @(posedge clk)
        cavlc_state[`cavlc_idle_bit] |-> (len_comb == 5'd0)
    );

// Any unknown state drives len_comb to 'bx.
    check_len_comb_default_x: assert property (
        @(posedge clk)
        !cavlc_state[`cavlc_read_total_coeffs_bit] &&
        !cavlc_state[`cavlc_read_t1s_flags_bit] &&
        !cavlc_state[`cavlc_read_level_prefix_bit] &&
        !cavlc_state[`cavlc_read_level_suffix_bit] &&
        !cavlc_state[`cavlc_read_total_zeros_bit] &&
        !cavlc_state[`cavlc_read_run_befores_bit] &&
        !cavlc_state[`cavlc_calc_level_bit] &&
        !cavlc_state[`cavlc_idle_bit] |-> (len_comb == 5'bx)
    );

endmodule
