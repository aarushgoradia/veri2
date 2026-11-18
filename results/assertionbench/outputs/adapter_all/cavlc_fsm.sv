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

    localparam logic [7:0] cavlc_idle_s = 8'b00000001;
    localparam logic [7:0] cavlc_read_total_coeffs_s = 8'b00000010;
    localparam logic [7:0] cavlc_read_t1s_flags_s = 8'b00000100;
    localparam logic [7:0] cavlc_read_level_prefix_s = 8'b00001000;
    localparam logic [7:0] cavlc_read_level_suffix_s = 8'b00010000;
    localparam logic [7:0] cavlc_calc_level_s = 8'b00100000;
    localparam logic [7:0] cavlc_read_total_zeros_s = 8'b01000000;
    localparam logic [7:0] cavlc_read_run_befores_s = 8'b10000000;

    // Reset drives the FSM idle and clears valid.
    reset_state_and_valid: assert property (
        @(posedge clk) !rst_n |-> (state == cavlc_idle_s) && (valid == 1'b0)
    );

    // idle is the decode of the idle state bit.
    check_idle_decode: assert property (
        @(posedge clk) disable iff (!rst_n) (idle == state[`cavlc_idle_bit])
    );

    // valid is asserted only in the idle state.
    check_valid_decode: assert property (
        @(posedge clk) disable iff (!rst_n) (valid == (state == cavlc_idle_s))
    );

    // ena low holds the FSM state and counters.
    hold_when_disabled: assert property (
        @(posedge clk) disable iff (!rst_n)
        (!ena) |=> (state == $past(state)) && (i == $past(i)) && (valid == $past(valid))
    );

    // start in idle starts the read_total_coeffs state.
    start_idle_to_read_total_coeffs: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_idle_s && start) |=> (state == cavlc_read_total_coeffs_s) && (valid == 1'b0)
    );

    // start low in idle keeps the FSM idle.
    start_low_idle_stays_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_idle_s && !start) |=> (state == cavlc_idle_s) && (valid == 1'b0)
    );

    // read_total_coeffs with nonzero trailing ones and coeffs goes to read_t1s_flags.
    read_total_coeffs_to_read_t1s_flags: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_read_total_coeffs_s &&
         (TrailingOnes_comb > 0) && (TotalCoeff_comb > 0)) |=> (state == cavlc_read_t1s_flags_s)
    );

    // read_total_coeffs with nonzero coeffs and no trailing ones goes to read_level_prefix.
    read_total_coeffs_to_read_level_prefix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_read_total_coeffs_s &&
         (TrailingOnes_comb == 0) && (TotalCoeff_comb > 0)) |=> (state == cavlc_read_level_prefix_s)
    );

    // read_total_coeffs with zero coeffs goes to idle and asserts valid.
    read_total_coeffs_zero_coeffs_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_read_total_coeffs_s && (TotalCoeff_comb == 0)) |=> (state == cavlc_idle_s) && (valid == 1'b1)
    );

    // read_t1s_flags with matching trailing ones goes to read_total_zeros.
    read_t1s_flags_match_to_read_total_zeros: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_read_t1s_flags_s &&
         (TrailingOnes == TotalCoeff)) |=> (state == cavlc_read_total_zeros_s)
    );

    // read_t1s_flags with mismatched trailing ones goes to read_level_prefix and decrements i.
    read_t1s_flags_mismatch_to_read_level_prefix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_read_t1s_flags_s &&
         (TrailingOnes != TotalCoeff)) |=> (state == cavlc_read_level_prefix_s) && (i == ($past(i) - $past(TrailingOnes)))
    );

    // read_level_prefix always goes to read_level_suffix.
    read_level_prefix_to_read_level_suffix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_read_level_prefix_s) |=> (state == cavlc_read_level_suffix_s)
    );

    // read_level_suffix always goes to calc_level.
    read_level_suffix_to_calc_level: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_read_level_suffix_s) |=> (state == cavlc_calc_level_s)
    );

    // calc_level with nonzero i decrements i and stays in calc_level.
    calc_level_nonzero_i_decrements: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_calc_level_s && (i != 4'd0)) |=> (state == cavlc_calc_level_s) && (i == ($past(i) - 4'd1))
    );

    // calc_level with zero i and nonzero TotalCoeff goes to read_total_zeros.
    calc_level_zero_i_nonzero_total_coeffs_to_read_total_zeros: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_calc_level_s && (i == 4'd0) && (TotalCoeff != 5'd0)) |=> (state == cavlc_read_total_zeros_s)
    );

    // calc_level with zero i and zero TotalCoeff goes to read_run_befores.
    calc_level_zero_i_zero_total_coeffs_to_read_run_befores: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_calc_level_s && (i == 4'd0) && (TotalCoeff == 5'd0)) |=> (state == cavlc_read_run_befores_s)
    );

    // read_total_zeros always goes to read_run_befores.
    read_total_zeros_to_read_run_befores: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_read_total_zeros_s) |=> (state == cavlc_read_run_befores_s)
    );

    // read_run_befores with nonzero i decrements i and stays in read_run_befores.
    read_run_befores_nonzero_i_decrements: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_read_run_befores_s && (i != 4'd0)) |=> (state == cavlc_read_run_befores_s) && (i == ($past(i) - 4'd1))
    );

    // read_run_befores with zero i or zero ZeroLeft goes to idle and asserts valid.
    read_run_befores_zero_i_or_zero_zeroleft_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && state == cavlc_read_run_befores_s && (i == 4'd0) || (ZeroLeft == 4'd0)) |=> (state == cavlc_idle_s) && (valid == 1'b1)
    );

endmodule