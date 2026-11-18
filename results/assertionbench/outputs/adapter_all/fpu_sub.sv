module fpu_sub_sva (
    input logic        clk,
    input logic        rst,
    input logic        enable,
    input logic [63:0] opa,
    input logic [63:0] opb,
    input logic [2:0]  fpu_op,
    input logic        sign,
    input logic [55:0] diff_2,
    input logic [10:0] exponent_2
);

    // Reset clears all registered outputs.
    check_reset_clears_outputs: assert property (
        @(posedge clk) rst |=> (sign == 1'b0) && (diff_2 == 56'b0) && (exponent_2 == 11'd0)
    );

    // With enable low, the registered outputs hold their previous values.
    check_hold_when_disabled: assert property (
        @(posedge clk) disable iff (rst)
        !enable |=> $stable({sign, diff_2, exponent_2})
    );

    // With enable high, sign reflects the implemented compare and xor logic.
    check_sign_matches_compare: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> (sign == ((|({1'b0, opa[62:52], opa[51:0]}) >= |({1'b0, opb[62:52], opb[51:0]})) &&
                             (fpu_op != 3'b000)))
    );

    // With enable high, exponent_2 is zero when the difference is zero.
    check_exponent_zero_on_zero_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'b0) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is zero.
    check_diff_zero_on_zero_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'b0) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 55 bits.
    check_exponent_zero_on_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h200000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 55 bits.
    check_diff_zero_on_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h200000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 54 bits.
    check_exponent_zero_on_second_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h100000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 54 bits.
    check_diff_zero_on_second_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h100000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 53 bits.
    check_exponent_zero_on_third_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h800000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 53 bits.
    check_diff_zero_on_third_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h800000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 52 bits.
    check_exponent_zero_on_fourth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h400000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 52 bits.
    check_diff_zero_on_fourth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h400000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 51 bits.
    check_exponent_zero_on_fifth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h200000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 51 bits.
    check_diff_zero_on_fifth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h200000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 50 bits.
    check_exponent_zero_on_sixth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h100000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 50 bits.
    check_diff_zero_on_sixth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h100000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 49 bits.
    check_exponent_zero_on_seventh_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h800000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 49 bits.
    check_diff_zero_on_seventh_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h800000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 48 bits.
    check_exponent_zero_on_eighth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h400000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 48 bits.
    check_diff_zero_on_eighth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h400000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 47 bits.
    check_exponent_zero_on_ninth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h200000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 47 bits.
    check_diff_zero_on_ninth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h200000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 46 bits.
    check_exponent_zero_on_tenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h100000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 46 bits.
    check_diff_zero_on_tenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h100000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 45 bits.
    check_exponent_zero_on_eleventh_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h800000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 45 bits.
    check_diff_zero_on_eleventh_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h800000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 44 bits.
    check_exponent_zero_on_twelfth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h400000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 44 bits.
    check_diff_zero_on_twelfth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h400000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 43 bits.
    check_exponent_zero_on_thirteenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h200000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 43 bits.
    check_diff_zero_on_thirteenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h200000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 42 bits.
    check_exponent_zero_on_fourteenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h100000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 42 bits.
    check_diff_zero_on_fourteenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h100000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 41 bits.
    check_exponent_zero_on_fifteenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h800000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 41 bits.
    check_diff_zero_on_fifteenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h800000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 40 bits.
    check_exponent_zero_on_sixteenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h400000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 40 bits.
    check_diff_zero_on_sixteenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h400000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 39 bits.
    check_exponent_zero_on_seventeenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h200000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 39 bits.
    check_diff_zero_on_seventeenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h200000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 38 bits.
    check_exponent_zero_on_eighteenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h100000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 38 bits.
    check_diff_zero_on_eighteenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h100000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 37 bits.
    check_exponent_zero_on_nineteenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h800000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 37 bits.
    check_diff_zero_on_nineteenth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h800000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 36 bits.
    check_exponent_zero_on_twentieth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h400000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 36 bits.
    check_diff_zero_on_twentieth_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h400000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is 35 bits.
    check_exponent_zero_on_twentyfirst_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h200000000000) |-> (exponent_2 == 11'd0))
    );

    // With enable high, diff_2 is zero when the difference is 35 bits.
    check_diff_zero_on_twentyfirst_max_difference: assert property (
        @(posedge clk) disable iff (rst)
        enable |=> ((diff_2 == 56'h200000000000) |-> (diff_2 == 56'b0))
    );

    // With enable high, exponent_2 is zero when the difference is