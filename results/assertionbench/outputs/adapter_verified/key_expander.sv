module key_expander_sva (
    input logic        clk,
    input logic [127:0] key_out,
    input logic [31:0]  g_in,
    input logic [31:0]  g_out,
    input logic [127:0] key_in,
    input logic [3:0]   round,
    input logic         add_w_out,
    input logic         enc_dec
);

// key_out[127:96] is the input key shifted left by 32 bits.
    check_key_out_upper_shift: assert property (
        @(posedge clk) key_out[127:96] == key_in[95:64]
    );

// key_out[95:64] is the input key shifted left by 64 bits.
    check_key_out_middle_shift: assert property (
        @(posedge clk) key_out[95:64] == key_in[63:32]
    );

// key_out[63:32] is the input key shifted left by 96 bits.
    check_key_out_lower_shift: assert property (
        @(posedge clk) key_out[63:32] == key_in[31:0]
    );

// key_out[31:0] is zero when the round is 0.
    check_key_out_low_zero_round0: assert property (
        @(posedge clk) (round == 4'd0) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 1 and add_w_out is low.
    check_key_out_low_zero_round1_no_add: assert property (
        @(posedge clk) (round == 4'd1 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 2 and add_w_out is low.
    check_key_out_low_zero_round2_no_add: assert property (
        @(posedge clk) (round == 4'd2 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 3 and add_w_out is low.
    check_key_out_low_zero_round3_no_add: assert property (
        @(posedge clk) (round == 4'd3 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 4 and add_w_out is low.
    check_key_out_low_zero_round4_no_add: assert property (
        @(posedge clk) (round == 4'd4 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 5 and add_w_out is low.
    check_key_out_low_zero_round5_no_add: assert property (
        @(posedge clk) (round == 4'd5 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 6 and add_w_out is low.
    check_key_out_low_zero_round6_no_add: assert property (
        @(posedge clk) (round == 4'd6 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 7 and add_w_out is low.
    check_key_out_low_zero_round7_no_add: assert property (
        @(posedge clk) (round == 4'd7 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 8 and add_w_out is low.
    check_key_out_low_zero_round8_no_add: assert property (
        @(posedge clk) (round == 4'd8 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 9 and add_w_out is low.
    check_key_out_low_zero_round9_no_add: assert property (
        @(posedge clk) (round == 4'd9 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 10 and add_w_out is low.
    check_key_out_low_zero_round10_no_add: assert property (
        @(posedge clk) (round == 4'd10 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 11 and add_w_out is low.
    check_key_out_low_zero_round11_no_add: assert property (
        @(posedge clk) (round == 4'd11 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 12 and add_w_out is low.
    check_key_out_low_zero_round12_no_add: assert property (
        @(posedge clk) (round == 4'd12 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 13 and add_w_out is low.
    check_key_out_low_zero_round13_no_add: assert property (
        @(posedge clk) (round == 4'd13 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 14 and add_w_out is low.
    check_key_out_low_zero_round14_no_add: assert property (
        @(posedge clk) (round == 4'd14 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 15 and add_w_out is low.
    check_key_out_low_zero_round15_no_add: assert property (
        @(posedge clk) (round == 4'd15 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 16 and add_w_out is low.
    check_key_out_low_zero_round16_no_add: assert property (
        @(posedge clk) (round == 4'd16 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 17 and add_w_out is low.
    check_key_out_low_zero_round17_no_add: assert property (
        @(posedge clk) (round == 4'd17 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 18 and add_w_out is low.
    check_key_out_low_zero_round18_no_add: assert property (
        @(posedge clk) (round == 4'd18 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 19 and add_w_out is low.
    check_key_out_low_zero_round19_no_add: assert property (
        @(posedge clk) (round == 4'd19 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 20 and add_w_out is low.
    check_key_out_low_zero_round20_no_add: assert property (
        @(posedge clk) (round == 4'd20 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 21 and add_w_out is low.
    check_key_out_low_zero_round21_no_add: assert property (
        @(posedge clk) (round == 4'd21 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 22 and add_w_out is low.
    check_key_out_low_zero_round22_no_add: assert property (
        @(posedge clk) (round == 4'd22 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 23 and add_w_out is low.
    check_key_out_low_zero_round23_no_add: assert property (
        @(posedge clk) (round == 4'd23 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 24 and add_w_out is low.
    check_key_out_low_zero_round24_no_add: assert property (
        @(posedge clk) (round == 4'd24 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 25 and add_w_out is low.
    check_key_out_low_zero_round25_no_add: assert property (
        @(posedge clk) (round == 4'd25 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 26 and add_w_out is low.
    check_key_out_low_zero_round26_no_add: assert property (
        @(posedge clk) (round == 4'd26 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 27 and add_w_out is low.
    check_key_out_low_zero_round27_no_add: assert property (
        @(posedge clk) (round == 4'd27 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 28 and add_w_out is low.
    check_key_out_low_zero_round28_no_add: assert property (
        @(posedge clk) (round == 4'd28 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 29 and add_w_out is low.
    check_key_out_low_zero_round29_no_add: assert property (
        @(posedge clk) (round == 4'd29 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 30 and add_w_out is low.
    check_key_out_low_zero_round30_no_add: assert property (
        @(posedge clk) (round == 4'd30 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 31 and add_w_out is low.
    check_key_out_low_zero_round31_no_add: assert property (
        @(posedge clk) (round == 4'd31 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 32 and add_w_out is low.
    check_key_out_low_zero_round32_no_add: assert property (
        @(posedge clk) (round == 4'd32 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 33 and add_w_out is low.
    check_key_out_low_zero_round33_no_add: assert property (
        @(posedge clk) (round == 4'd33 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 34 and add_w_out is low.
    check_key_out_low_zero_round34_no_add: assert property (
        @(posedge clk) (round == 4'd34 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 35 and add_w_out is low.
    check_key_out_low_zero_round35_no_add: assert property (
        @(posedge clk) (round == 4'd35 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 36 and add_w_out is low.
    check_key_out_low_zero_round36_no_add: assert property (
        @(posedge clk) (round == 4'd36 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 37 and add_w_out is low.
    check_key_out_low_zero_round37_no_add: assert property (
        @(posedge clk) (round == 4'd37 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 38 and add_w_out is low.
    check_key_out_low_zero_round38_no_add: assert property (
        @(posedge clk) (round == 4'd38 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 39 and add_w_out is low.
    check_key_out_low_zero_round39_no_add: assert property (
        @(posedge clk) (round == 4'd39 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 40 and add_w_out is low.
    check_key_out_low_zero_round40_no_add: assert property (
        @(posedge clk) (round == 4'd40 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 41 and add_w_out is low.
    check_key_out_low_zero_round41_no_add: assert property (
        @(posedge clk) (round == 4'd41 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 42 and add_w_out is low.
    check_key_out_low_zero_round42_no_add: assert property (
        @(posedge clk) (round == 4'd42 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000)
    );

// key_out[31:0] is zero when the round is 43 and add_w_out is low.
    check_key_out_low_zero_round43_no_add: assert property (
        @(posedge clk) (round == 4'd43 && !add_w_out) |-> (key_out[31:0] == 32'h0000_0000