module PSGMasterVolumeControl_sva (
    input logic rst_i,
    input logic clk_i,
    input logic [15:0] i,
    input logic [3:0] volume,
    input logic [19:0] o
);

    // Reset clears the output on the next clock.
    check_reset_clears_output: assert property (
        @(posedge clk_i) rst_i |=> (o == 20'd0)
    );

    // Volume bit 0 selects i into the output on the next clock.
    check_volume_bit0_selects_i: assert property (
        @(posedge clk_i) disable iff (rst_i)
        volume[0] |=> (o == ($past(i) << 16))
    );

    // Volume bit 1 selects i shifted left by one on the next clock.
    check_volume_bit1_selects_shifted_i: assert property (
        @(posedge clk_i) disable iff (rst_i)
        volume[1] |=> (o == ($past(i) << 17))
    );

    // Volume bit 2 selects i shifted left by two on the next clock.
    check_volume_bit2_selects_shifted_i: assert property (
        @(posedge clk_i) disable iff (rst_i)
        volume[2] |=> (o == ($past(i) << 18))
    );

    // Volume bit 3 selects i shifted left by three on the next clock.
    check_volume_bit3_selects_shifted_i: assert property (
        @(posedge clk_i) disable iff (rst_i)
        volume[3] |=> (o == ($past(i) << 19))
    );

    // With no volume bits set, the output holds its previous value.
    check_no_volume_bits_hold_value: assert property (
        @(posedge clk_i) disable iff (rst_i)
        !volume |=> (o == $past(o))
    );

    // With only volume bit 0 set, the output is i shifted left by one.
    check_volume_0_only_shifts_by_one: assert property (
        @(posedge clk_i) disable iff (rst_i)
        (volume == 4'h1) |=> (o == ($past(i) << 16))
    );

    // With only volume bit 1 set, the output is i shifted left by two.
    check_volume_1_only_shifts_by_two: assert property (
        @(posedge clk_i) disable iff (rst_i)
        (volume == 4'h2) |=> (o == ($past(i) << 17))
    );

    // With only volume bit 2 set, the output is i shifted left by three.
    check_volume_2_only_shifts_by_three: assert property (
        @(posedge clk_i) disable iff (rst_i)
        (volume == 4'h4) |=> (o == ($past(i) << 18))
    );

    // With only volume bit 3 set, the output is i shifted left by four.
    check_volume_3_only_shifts_by_four: assert property (
        @(posedge clk_i) disable iff (rst_i)
        (volume == 4'h8) |=> (o == ($past(i) << 19))
    );

endmodule