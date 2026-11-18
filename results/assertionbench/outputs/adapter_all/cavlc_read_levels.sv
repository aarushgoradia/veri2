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
    // Reset drives all outputs to zero.
    reset_outputs_zero: assert property (
        @(posedge clk) !rst_n |-> (level_0 == 9'd0) && (level_1 == 9'd0) && (level_2 == 9'd0) && (level_3 == 9'd0) &&
                                 (level_4 == 9'd0) && (level_5 == 9'd0) && (level_6 == 9'd0) && (level_7 == 9'd0) &&
                                 (level_8 == 9'd0) && (level_9 == 9'd0) && (level_10 == 9'd0) && (level_11 == 9'd0) &&
                                 (level_12 == 9'd0) && (level_13 == 9'd0) && (level_14 == 9'd0) && (level_15 == 9'd0) &&
                                 (len_comb == 5'd0)
    );

    // len_comb is zero when no active select is asserted.
    len_comb_zero_when_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (!t1s_sel && !prefix_sel && !suffix_sel) |-> (len_comb == 5'd0)
    );

    // len_comb equals TrailingOnes when t1s_sel is asserted.
    len_comb_t1s_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        t1s_sel |-> (len_comb == TrailingOnes)
    );

    // len_comb equals level_prefix_comb + 1 when prefix_sel is asserted.
    len_comb_prefix_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        prefix_sel |-> (len_comb == ($past(level_prefix_comb) + 5'd1))
    );

    // len_comb equals suffixLength when suffix_sel is asserted and level_prefix <= 14.
    len_comb_suffix_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel && ($past(level_prefix) <= 4'd14)) |-> (len_comb == $past(suffixLength))
    );

    // len_comb equals 4 when suffix_sel is asserted and level_prefix == 14.
    len_comb_suffix_14_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel && ($past(level_prefix) == 4'd14)) |-> (len_comb == 5'd4)
    );

    // len_comb equals 12 when suffix_sel is asserted and level_prefix == 15.
    len_comb_suffix_15_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel && ($past(level_prefix) == 4'd15)) |-> (len_comb == 5'd12)
    );

    // len_comb is at most 12 for all active cases.
    len_comb_max_bound: assert property (
        @(posedge clk) disable iff (!rst_n)
        len_comb <= 5'd12
    );

    // level_0 is zero when t1s_sel is asserted.
    level_0_zero_on_t1s: assert property (
        @(posedge clk) disable iff (!rst_n)
        t1s_sel |-> (level_0 == 9'd0)
    );

    // level_0 is zero when prefix_sel is asserted and i != 0.
    level_0_zero_on_prefix_nonzero: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i != 4'd0)) |-> (level_0 == 9'd0)
    );

    // level_0 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 0.
    level_0_prefix_i0_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd0)) |-> (level_0 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_1 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 1.
    level_1_prefix_i1_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd1)) |-> (level_1 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_2 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 2.
    level_2_prefix_i2_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd2)) |-> (level_2 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_3 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 3.
    level_3_prefix_i3_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd3)) |-> (level_3 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_4 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 4.
    level_4_prefix_i4_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd4)) |-> (level_4 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_5 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 5.
    level_5_prefix_i5_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd5)) |-> (level_5 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_6 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 6.
    level_6_prefix_i6_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd6)) |-> (level_6 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_7 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 7.
    level_7_prefix_i7_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd7)) |-> (level_7 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_8 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 8.
    level_8_prefix_i8_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd8)) |-> (level_8 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_9 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 9.
    level_9_prefix_i9_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd9)) |-> (level_9 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_10 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 10.
    level_10_prefix_i10_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd10)) |-> (level_10 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_11 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 11.
    level_11_prefix_i11_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd11)) |-> (level_11 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_12 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 12.
    level_12_prefix_i12_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd12)) |-> (level_12 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_13 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 13.
    level_13_prefix_i13_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd13)) |-> (level_13 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_14 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 14.
    level_14_prefix_i14_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd14)) |-> (level_14 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_15 equals rbsp[0] ? -1 : 1 when prefix_sel is asserted and i == 15.
    level_15_prefix_i15_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (prefix_sel && (i == 4'd15)) |-> (level_15 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_0 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 0.
    level_0_calc_i0_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd0)) |-> (level_0 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_1 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 1.
    level_1_calc_i1_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd1)) |-> (level_1 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_2 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 2.
    level_2_calc_i2_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd2)) |-> (level_2 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_3 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 3.
    level_3_calc_i3_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd3)) |-> (level_3 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_4 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 4.
    level_4_calc_i4_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd4)) |-> (level_4 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_5 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 5.
    level_5_calc_i5_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd5)) |-> (level_5 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_6 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 6.
    level_6_calc_i6_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd6)) |-> (level_6 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_7 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 7.
    level_7_calc_i7_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd7)) |-> (level_7 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_8 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 8.
    level_8_calc_i8_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd8)) |-> (level_8 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_9 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 9.
    level_9_calc_i9_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd9)) |-> (level_9 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_10 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 10.
    level_10_calc_i10_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd10)) |-> (level_10 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_11 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 11.
    level_11_calc_i11_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd11)) |-> (level_11 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_12 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 12.
    level_12_calc_i12_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd12)) |-> (level_12 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_13 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 13.
    level_13_calc_i13_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd13)) |-> (level_13 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_14 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 14.
    level_14_calc_i14_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4'd14)) |-> (level_14 == ($past(rbsp[0]) ? -9'd1 : 9'd1))
    );

    // level_15 equals rbsp[0] ? -1 : 1 when calc_sel is asserted and i == 15.
    level_15_calc_i15_mapping: assert property (
        @(posedge clk) disable iff (!rst_n)
        (calc_sel && (i == 4