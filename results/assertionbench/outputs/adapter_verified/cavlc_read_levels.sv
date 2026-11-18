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

// len_comb is zero when no active selector is asserted.
    check_len_comb_zero_when_idle: assert property (
        @(posedge clk) disable iff (!rst_n)
        (!t1s_sel && !prefix_sel && !suffix_sel) |-> (len_comb == 5'd0)
    );

// len_comb equals TrailingOnes when t1s_sel is active.
    check_len_comb_t1s_sel: assert property (
        @(posedge clk) disable iff (!rst_n)
        t1s_sel |-> (len_comb == TrailingOnes)
    );

// len_comb equals level_prefix_comb plus one when prefix_sel is active.
    check_len_comb_prefix_sel: assert property (
        @(posedge clk) disable iff (!rst_n)
        prefix_sel |-> (len_comb == (level_prefix_comb + 5'd1))
    );

// len_comb equals suffixLength when suffix_sel is active and level_prefix <= 14.
    check_len_comb_suffix_sel_valid_prefix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel && (level_prefix <= 4'd14)) |-> (len_comb == suffixLength)
    );

// len_comb equals 4 when suffix_sel is active and level_prefix == 14.
    check_len_comb_suffix_sel_prefix_14: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel && (level_prefix == 4'd14)) |-> (len_comb == 5'd4)
    );

// len_comb equals 12 when suffix_sel is active and level_prefix == 15.
    check_len_comb_suffix_sel_prefix_15: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel && (level_prefix == 4'd15)) |-> (len_comb == 5'd12)
    );

// len_comb is zero when suffix_sel is active but level_prefix > 14.
    check_len_comb_suffix_sel_invalid_prefix: assert property (
        @(posedge clk) disable iff (!rst_n)
        (suffix_sel && (level_prefix > 4'd14)) |-> (len_comb == 5'd0)
    );

endmodule
