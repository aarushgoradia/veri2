module cavlc_read_levels_sva (
    input logic clk,
    input logic rst_n,
    input logic ena,
    input logic t1s_sel,
    input logic prefix_sel,
    input logic suffix_sel,
    input logic calc_sel,
    input logic [1:0] TrailingOnes,
    input logic [4:0] TotalCoeff,
    input logic [0:15] rbsp,
    input logic [3:0] i,
    input logic [8:0] level_0,
    input logic [8:0] level_1,
    input logic [8:0] level_2,
    input logic [8:0] level_3,
    input logic [8:0] level_4,
    input logic [8:0] level_5,
    input logic [8:0] level_6,
    input logic [8:0] level_7,
    input logic [8:0] level_8,
    input logic [8:0] level_9,
    input logic [8:0] level_10,
    input logic [8:0] level_11,
    input logic [8:0] level_12,
    input logic [8:0] level_13,
    input logic [8:0] level_14,
    input logic [8:0] level_15,
    input logic [4:0] len_comb
);

    // len_comb must be zero whenever the idle state is active.
    check_len_comb_zero_in_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b0) |-> (len_comb == 5'd0)
    );

    // len_comb must match the selected prefix value when prefix_sel is active.
    check_len_comb_matches_prefix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel == 1'b1) |-> (len_comb == (level_0[3:0] + 5'd1))
    );

    // len_comb must match the selected suffix length when suffix_sel is active.
    check_len_comb_matches_suffix_length: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel == 1'b1 && level_0[3:0] <= 4'd14 && level_0[3:0] >= 4'd0 && level_0[8] == 1'b0) |-> (len_comb == level_0[3:0])
    );

    // len_comb must be 4 when the selected level is 14 and suffix_sel is active.
    check_len_comb_four_for_level_14: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel == 1'b1 && level_0[3:0] == 4'd14) |-> (len_comb == 5'd4)
    );

    // len_comb must be 12 when the selected level is 15 and suffix_sel is active.
    check_len_comb_twelve_for_level_15: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel == 1'b1 && level_0[3:0] == 4'd15) |-> (len_comb == 5'd12)
    );

    // level_0 must be zero whenever the idle state is active.
    check_level_0_zero_in_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b0) |-> (level_0 == 9'd0)
    );

    // level_0 must be zero whenever prefix_sel is active.
    check_level_0_zero_in_prefix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel == 1'b1) |-> (level_0 == 9'd0)
    );

    // level_0 must be zero whenever suffix_sel is active.
    check_level_0_zero_in_suffix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel == 1'b1) |-> (level_0 == 9'd0)
    );

    // level_0 must be zero whenever calc_sel is active.
    check_level_0_zero_in_calc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel == 1'b1) |-> (level_0 == 9'd0)
    );

    // level_0 must be zero whenever t1s_sel is active and i is not zero.
    check_level_0_zero_in_t1s_nonzero_index: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i != 4'd0) |-> (level_0 == 9'd0)
    );

    // level_0 must be 1 whenever t1s_sel is active and i is zero.
    check_level_0_one_in_t1s_zero_index: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd0) |-> (level_0 == 9'd1)
    );

    // level_1 must be zero whenever the idle state is active.
    check_level_1_zero_in_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b0) |-> (level_1 == 9'd0)
    );

    // level_1 must be zero whenever prefix_sel is active.
    check_level_1_zero_in_prefix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel == 1'b1) |-> (level_1 == 9'd0)
    );

    // level_1 must be zero whenever suffix_sel is active.
    check_level_1_zero_in_suffix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel == 1'b1) |-> (level_1 == 9'd0)
    );

    // level_1 must be zero whenever calc_sel is active.
    check_level_1_zero_in_calc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel == 1'b1) |-> (level_1 == 9'd0)
    );

    // level_1 must be 1 whenever t1s_sel is active and i is one.
    check_level_1_one_in_t1s_one_index: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd1) |-> (level_1 == 9'd1)
    );

    // level_1 must be 1 whenever t1s_sel is active and i is zero and TrailingOnes[1] is high.
    check_level_1_one_in_t1s_zero_index_with_trailing_one: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd0 && TrailingOnes[1] == 1'b1) |-> (level_1 == 9'd1)
    );

    // level_1 must be 0 whenever t1s_sel is active and i is zero and TrailingOnes[1] is low.
    check_level_1_zero_in_t1s_zero_index_without_trailing_one: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd0 && TrailingOnes[1] == 1'b0) |-> (level_1 == 9'd0)
    );

    // level_2 must be zero whenever the idle state is active.
    check_level_2_zero_in_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b0) |-> (level_2 == 9'd0)
    );

    // level_2 must be zero whenever prefix_sel is active.
    check_level_2_zero_in_prefix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel == 1'b1) |-> (level_2 == 9'd0)
    );

    // level_2 must be zero whenever suffix_sel is active.
    check_level_2_zero_in_suffix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel == 1'b1) |-> (level_2 == 9'd0)
    );

    // level_2 must be zero whenever calc_sel is active.
    check_level_2_zero_in_calc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel == 1'b1) |-> (level_2 == 9'd0)
    );

    // level_2 must be 1 whenever t1s_sel is active and i is two.
    check_level_2_one_in_t1s_two_index: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd2) |-> (level_2 == 9'd1)
    );

    // level_2 must be 1 whenever t1s_sel is active and i is one and TrailingOnes[1] is high.
    check_level_2_one_in_t1s_one_index_with_trailing_one: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd1 && TrailingOnes[1] == 1'b1) |-> (level_2 == 9'd1)
    );

    // level_2 must be 0 whenever t1s_sel is active and i is one and TrailingOnes[1] is low.
    check_level_2_zero_in_t1s_one_index_without_trailing_one: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd1 && TrailingOnes[1] == 1'b0) |-> (level_2 == 9'd0)
    );

    // level_2 must be 1 whenever t1s_sel is active and i is zero and TrailingOnes is 3.
    check_level_2_one_in_t1s_zero_index_with_trailing_three: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd0 && TrailingOnes == 2'd3) |-> (level_2 == 9'd1)
    );

    // level_2 must be 0 whenever t1s_sel is active and i is zero and TrailingOnes is not 3.
    check_level_2_zero_in_t1s_zero_index_without_trailing_three: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd0 && TrailingOnes != 2'd3) |-> (level_2 == 9'd0)
    );

    // level_3 must be zero whenever the idle state is active.
    check_level_3_zero_in_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b0) |-> (level_3 == 9'd0)
    );

    // level_3 must be zero whenever prefix_sel is active.
    check_level_3_zero_in_prefix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel == 1'b1) |-> (level_3 == 9'd0)
    );

    // level_3 must be zero whenever suffix_sel is active.
    check_level_3_zero_in_suffix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel == 1'b1) |-> (level_3 == 9'd0)
    );

    // level_3 must be zero whenever calc_sel is active.
    check_level_3_zero_in_calc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel == 1'b1) |-> (level_3 == 9'd0)
    );

    // level_3 must be 1 whenever t1s_sel is active and i is three.
    check_level_3_one_in_t1s_three_index: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd3) |-> (level_3 == 9'd1)
    );

    // level_3 must be 1 whenever t1s_sel is active and i is two and TrailingOnes[1] is high.
    check_level_3_one_in_t1s_two_index_with_trailing_one: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd2 && TrailingOnes[1] == 1'b1) |-> (level_3 == 9'd1)
    );

    // level_3 must be 0 whenever t1s_sel is active and i is two and TrailingOnes[1] is low.
    check_level_3_zero_in_t1s_two_index_without_trailing_one: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd2 && TrailingOnes[1] == 1'b0) |-> (level_3 == 9'd0)
    );

    // level_3 must be 1 whenever t1s_sel is active and i is one and TrailingOnes is 3.
    check_level_3_one_in_t1s_one_index_with_trailing_three: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd1 && TrailingOnes == 2'd3) |-> (level_3 == 9'd1)
    );

    // level_3 must be 0 whenever t1s_sel is active and i is one and TrailingOnes is not 3.
    check_level_3_zero_in_t1s_one_index_without_trailing_three: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd1 && TrailingOnes != 2'd3) |-> (level_3 == 9'd0)
    );

    // level_3 must be 1 whenever t1s_sel is active and i is zero and TrailingOnes is 3.
    check_level_3_one_in_t1s_zero_index_with_trailing_three: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd0 && TrailingOnes == 2'd3) |-> (level_3 == 9'd1)
    );

    // level_3 must be 0 whenever t1s_sel is active and i is zero and TrailingOnes is not 3.
    check_level_3_zero_in_t1s_zero_index_without_trailing_three: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd0 && TrailingOnes != 2'd3) |-> (level_3 == 9'd0)
    );

    // level_4 must be zero whenever the idle state is active.
    check_level_4_zero_in_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b0) |-> (level_4 == 9'd0)
    );

    // level_4 must be zero whenever prefix_sel is active.
    check_level_4_zero_in_prefix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel == 1'b1) |-> (level_4 == 9'd0)
    );

    // level_4 must be zero whenever suffix_sel is active.
    check_level_4_zero_in_suffix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel == 1'b1) |-> (level_4 == 9'd0)
    );

    // level_4 must be zero whenever calc_sel is active.
    check_level_4_zero_in_calc: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel == 1'b1) |-> (level_4 == 9'd0)
    );

    // level_4 must be 1 whenever t1s_sel is active and i is four.
    check_level_4_one_in_t1s_four_index: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd4) |-> (level_4 == 9'd1)
    );

    // level_4 must be 1 whenever t1s_sel is active and i is three and TrailingOnes[1] is high.
    check_level_4_one_in_t1s_three_index_with_trailing_one: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd3 && TrailingOnes[1] == 1'b1) |-> (level_4 == 9'd1)
    );

    // level_4 must be 0 whenever t1s_sel is active and i is three and TrailingOnes[1] is low.
    check_level_4_zero_in_t1s_three_index_without_trailing_one: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd3 && TrailingOnes[1] == 1'b0) |-> (level_4 == 9'd0)
    );

    // level_4 must be 1 whenever t1s_sel is active and i is two and TrailingOnes is 3.
    check_level_4_one_in_t1s_two_index_with_trailing_three: assert property (
        @(posedge clk) disable iff (!rst_n)
        (t1s_sel == 1'b1 && i == 4'd2 && TrailingOnes == 2'd3) |-> (level_4 == 9'd1)
    );

    // level_4 must be 0 whenever t1s_sel is active and i is two and TrailingOn