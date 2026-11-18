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

    // Reset clears the state and counters.
    check_reset_state: assert property (
        @(posedge clk) !rst_n |-> (state == 8'h01) && (i == 4'd0) && (valid == 1'b0)
    );

    // Reset clears the idle and valid outputs.
    check_reset_outputs: assert property (
        @(posedge clk) !rst_n |-> (idle == 1'b0) && (valid == 1'b0)
    );

    // idle is asserted only in the idle state.
    check_idle_decode: assert property (
        @(posedge clk) disable iff (!rst_n)
        (idle == 1'b1) |-> (state == 8'h01)
    );

    // valid is asserted only in the idle state.
    check_valid_decode: assert property (
        @(posedge clk) disable iff (!rst_n)
        (valid == 1'b1) |-> (state == 8'h01)
    );

    // valid can only be asserted when idle is asserted.
    check_valid_implies_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        valid |-> idle
    );

    // valid is a single-cycle pulse.
    check_valid_one_cycle: assert property (
        @(posedge clk) disable iff (!rst_n)
        valid |=> !valid
    );

    // idle is a single-cycle pulse.
    check_idle_one_cycle: assert property (
        @(posedge clk) disable iff (!rst_n)
        idle |=> !idle
    );

    // idle and valid are never asserted together.
    check_idle_valid_mutex: assert property (
        @(posedge clk) disable iff (!rst_n)
        !(idle && valid)
    );

    // start has no effect when ena is low.
    check_start_no_effect_when_disabled: assert property (
        @(posedge clk) disable iff (!rst_n)
        (!ena && start) |=> (state == $past(state) && i == $past(i) && valid == $past(valid))
    );

    // idle state holds when ena and start are low.
    check_idle_holds_when_disabled: assert property (
        @(posedge clk) disable iff (!rst_n)
        (!ena && !start && (state == 8'h01)) |=> (state == 8'h01 && i == $past(i) && valid == $past(valid))
    );

    // idle state holds when ena and start are low.
    check_idle_holds_when_disabled: assert property (
        @(posedge clk) disable iff (!rst_n)
        (!ena && !start && (state == 8'h01)) |=> (state == 8'h01 && i == $past(i) && valid == $past(valid))
    );

    // read_total_coeffs advances to read_t1s_flags when applicable.
    check_read_total_coeffs_to_read_t1s_flags: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h02) && (TrailingOnes_comb > 1'b0) && (TotalCoeff_comb > 1'b0))
        |=> (state == 8'h04 && i == $past(TotalCoeff_comb) - 4'd1)
    );

    // read_total_coeffs advances to read_level_prefix when applicable.
    check_read_total_coeffs_to_read_level_prefix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h02) && ((TrailingOnes_comb == 2'b00) || (TotalCoeff_comb == 5'd0)))
        |=> (state == 8'h08 && i == $past(TotalCoeff_comb) - 4'd1)
    );

    // read_total_coeffs advances to idle when TotalCoeff is zero.
    check_read_total_coeffs_to_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h02) && (TotalCoeff_comb == 5'd0))
        |=> (state == 8'h01 && i == 4'd0 && valid == 1'b1)
    );

    // read_t1s_flags advances to read_total_zeros when applicable.
    check_read_t1s_flags_to_read_total_zeros: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h04) && (TrailingOnes == TotalCoeff))
        |=> (state == 8'h40 && i == $past(TotalCoeff) - 4'd1)
    );

    // read_t1s_flags advances to read_level_prefix when applicable.
    check_read_t1s_flags_to_read_level_prefix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h04) && (TrailingOnes != TotalCoeff))
        |=> (state == 8'h08 && i == $past(i) - 4'd1)
    );

    // read_level_prefix advances to read_level_suffix.
    check_read_level_prefix_to_read_level_suffix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h08)) |=> (state == 8'h10)
    );

    // read_level_suffix advances to calc_level.
    check_read_level_suffix_to_calc_level: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h10)) |=> (state == 8'h20)
    );

    // calc_level advances to read_total_zeros when applicable.
    check_calc_level_to_read_total_zeros: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h20) && (i == 4'd0) && (TotalCoeff < $past(max_coeff_num)))
        |=> (state == 8'h40 && i == $past(TotalCoeff) - 4'd1)
    );

    // calc_level advances to read_run_befores when applicable.
    check_calc_level_to_read_run_befores: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h20) && (i == 4'd0))
        |=> (state == 8'h80 && i == $past(TotalCoeff) - 4'd1)
    );

    // calc_level decrements i when i is nonzero.
    check_calc_level_decrements_i: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h20) && (i != 4'd0))
        |=> (state == 8'h40 && i == $past(i) - 4'd1)
    );

    // read_total_zeros advances to read_run_befores.
    check_read_total_zeros_to_read_run_befores: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h40)) |=> (state == 8'h80 && i == $past(TotalCoeff) - 4'd1)
    );

    // read_run_befores decrements i until it reaches zero.
    check_read_run_befores_decrements_i: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h80) && (i != 4'd0))
        |=> (state == 8'h80 && i == $past(i) - 4'd1)
    );

    // read_run_befores advances to idle when i reaches zero.
    check_read_run_befores_to_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (ena && (state == 8'h80) && (i == 4'd0))
        |=> (state == 8'h01 && i == 4'd0 && valid == 1'b1)
    );

endmodule