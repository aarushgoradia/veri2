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
    input logic [7:0] state,
    input logic [3:0] i,
    input logic idle,
    input logic valid
);

// Reset drives the idle state and clears valid.
    check_reset_state: assert property (
        @(posedge clk) !rst_n |-> (state == `cavlc_idle_s) && (idle == 1'b1) && (valid == 1'b0)
    );

// idle is asserted only in the idle state.
    check_idle_definition: assert property (
        @(posedge clk) disable iff (!rst_n) (idle == 1'b1) |-> (state == `cavlc_idle_s)
    );

// valid is asserted only in the final run-before-zero state.
    check_valid_definition: assert property (
        @(posedge clk) disable iff (!rst_n) (valid == 1'b1) |-> (state == `cavlc_read_run_befores_s) && (i == 4'd0) && (ZeroLeft == 4'd0)
    );

// idle and valid are never asserted together.
    check_idle_valid_mutex: assert property (
        @(posedge clk) disable iff (!rst_n) !(idle && valid)
    );

// When ena is low, the FSM holds its state and i.
    check_hold_when_ena_low: assert property (
        @(posedge clk) disable iff (!rst_n) !ena |=> (state == $past(state)) && (i == $past(i)) && (valid == $past(valid))
    );

// Start in idle advances to read_total_coeffs.
    check_start_idle_to_read_total_coeffs: assert property (
        @(posedge clk) disable iff (!rst_n) ena && start && (state == `cavlc_idle_s) |=> (state == `cavlc_read_total_coeffs_s) && (i == 4'd0) && (valid == 1'b0)
    );

// With no trailing ones and non-zero TotalCoeff, advance to read_level_prefix.
    check_read_total_coeffs_to_read_level_prefix: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_total_coeffs_s) && (TrailingOnes_comb == 2'd0) && (TotalCoeff_comb != 5'd0) |=> (state == `cavlc_read_level_prefix_s) && (i == (TotalCoeff_comb - 5'd1)) && (valid == 1'b0)
    );

// With trailing ones equal to TotalCoeff, advance to read_total_zeros.
    check_read_total_coeffs_to_read_total_zeros: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_total_coeffs_s) && (TrailingOnes_comb == TotalCoeff_comb) && (TotalCoeff_comb != 5'd0) |=> (state == `cavlc_read_total_zeros_s) && (i == (TotalCoeff_comb - 5'd1)) && (valid == 1'b0)
    );

// With non-zero TotalCoeff, advance to read_level_prefix.
    check_read_total_coeffs_to_read_level_prefix_nonzero: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_total_coeffs_s) && (TotalCoeff_comb != 5'd0) |=> (state == `cavlc_read_level_prefix_s) && (i == (TotalCoeff_comb - 5'd1)) && (valid == 1'b0)
    );

// With zero TotalCoeff, advance to idle and assert valid.
    check_read_total_coeffs_to_idle_zero: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_total_coeffs_s) && (TotalCoeff_comb == 5'd0) |=> (state == `cavlc_idle_s) && (i == 4'd0) && (valid == 1'b1)
    );

// With non-zero TotalCoeff and trailing ones, decrement i and stay in read_t1s_flags.
    check_read_t1s_flags_decrement: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_t1s_flags_s) && (TrailingOnes_comb != 2'd0) && (TotalCoeff_comb != 5'd0) |=> (state == `cavlc_read_t1s_flags_s) && (i == ($past(i) - 4'd1)) && (valid == 1'b0)
    );

// With trailing ones equal to TotalCoeff, advance to read_total_zeros.
    check_read_t1s_flags_to_read_total_zeros: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_t1s_flags_s) && (TrailingOnes_comb == TotalCoeff_comb) && (TotalCoeff_comb != 5'd0) |=> (state == `cavlc_read_total_zeros_s) && (i == ($past(i) - 4'd1)) && (valid == 1'b0)
    );

// With zero trailing ones, advance to read_level_prefix.
    check_read_t1s_flags_to_read_level_prefix: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_t1s_flags_s) && (TrailingOnes_comb == 2'd0) && (TotalCoeff_comb != 5'd0) |=> (state == `cavlc_read_level_prefix_s) && (i == ($past(i) - 4'd1)) && (valid == 1'b0)
    );

// With i==0 and TotalCoeff < max_coeff_num, advance to read_total_zeros.
    check_read_level_suffix_to_read_total_zeros: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_level_suffix_s) && (i == 4'd0) && (TotalCoeff < max_coeff_num) |=> (state == `cavlc_read_total_zeros_s) && (i == 4'd0) && (valid == 1'b0)
    );

// With i==0 and TotalCoeff == max_coeff_num, advance to read_run_befores.
    check_read_level_suffix_to_read_run_befores: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_level_suffix_s) && (i == 4'd0) && (TotalCoeff == max_coeff_num) |=> (state == `cavlc_read_run_befores_s) && (i == (TotalCoeff - 4'd1)) && (valid == 1'b0)
    );

// With i!=0, decrement i and stay in read_level_prefix.
    check_read_level_prefix_decrement: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_level_prefix_s) && (i != 4'd0) |=> (state == `cavlc_read_level_prefix_s) && (i == ($past(i) - 4'd1)) && (valid == 1'b0)
    );

// With i==0 and ZeroLeft > 0, advance to read_run_befores.
    check_read_level_prefix_to_read_run_befores: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_level_prefix_s) && (i == 4'd0) && (ZeroLeft != 4'd0) |=> (state == `cavlc_read_run_befores_s) && (i == (TotalCoeff - 4'd1)) && (valid == 1'b0)
    );

// With i==0 and ZeroLeft == 0, advance to idle and assert valid.
    check_read_level_prefix_to_idle_zero: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_level_prefix_s) && (i == 4'd0) && (ZeroLeft == 4'd0) |=> (state == `cavlc_idle_s) && (i == 4'd0) && (valid == 1'b1)
    );

// With i!=0, decrement i and stay in read_run_befores.
    check_read_run_befores_decrement: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_run_befores_s) && (i != 4'd0) |=> (state == `cavlc_read_run_befores_s) && (i == ($past(i) - 4'd1)) && (valid == 1'b0)
    );

// With i==0 and ZeroLeft > 0, advance to idle and assert valid.
    check_read_run_befores_to_idle_zero: assert property (
        @(posedge clk) disable iff (!rst_n) ena && (state == `cavlc_read_run_befores_s) && (i == 4'd0) && (ZeroLeft != 4'd0) |=> (state == `cavlc_idle_s) && (i == 4'd0) && (valid == 1'b1)
    );

endmodule
