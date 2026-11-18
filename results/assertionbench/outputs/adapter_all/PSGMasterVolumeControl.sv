module PSGMasterVolumeControl_sva (
    input logic rst_i,
    input logic clk_i,
    input logic [15:0] i,
    input logic [3:0] volume,
    input logic [19:0] o
);
    // On reset, next-cycle output is zero.
    reset_clears_output_next: assert property (
        @(posedge clk_i) rst_i |=> (o == 20'd0)
    );

    // When volume[0]==0, next-cycle output equals i shifted left by volume[3:1].
    vol0_shifts_output_next: assert property (
        @(posedge clk_i) disable iff (rst_i)
            (volume[0] == 1'b0) |=> (o == ($past(i) << $past(volume[3:1])))
    );

    // When volume[0]==1, next-cycle output equals i shifted left by volume[3:1] plus i.
    vol0_plus_i_next: assert property (
        @(posedge clk_i) disable iff (rst_i)
            (volume[0] == 1'b1) |=> (o == (($past(i) << $past(volume[3:1])) + $past(i)))
    );

    // When volume[1]==0, next-cycle output equals i shifted left by volume[3:1].
    vol1_shifts_output_next: assert property (
        @(posedge clk_i) disable iff (rst_i)
            (volume[1] == 1'b0) |=> (o == ($past(i) << $past(volume[3:1])))
    );

    // When volume[1]==1, next-cycle output equals i shifted left by volume[3:1] plus i.
    vol1_plus_i_next: assert property (
        @(posedge clk_i) disable iff (rst_i)
            (volume[1] == 1'b1) |=> (o == (($past(i) << $past(volume[3:1])) + $past(i)))
    );

    // When volume[2]==0, next-cycle output equals i shifted left by volume[3:1].
    vol2_shifts_output_next: assert property (
        @(posedge clk_i) disable iff (rst_i)
            (volume[2] == 1'b0) |=> (o == ($past(i) << $past(volume[3:1])))
    );

    // When volume[2]==1, next-cycle output equals i shifted left by volume[3:1] plus i.
    vol2_plus_i_next: assert property (
        @(posedge clk_i) disable iff (rst_i)
            (volume[2] == 1'b1) |=> (o == (($past(i) << $past(volume[3:1])) + $past(i)))
    );

    // When volume[3]==0, next-cycle output equals i shifted left by volume[3:1].
    vol3_shifts_output_next: assert property (
        @(posedge clk_i) disable iff (rst_i)
            (volume[3] == 1'b0) |=> (o == ($past(i) << $past(volume[3:1])))
    );

    // When volume[3]==1, next-cycle output equals i shifted left by volume[3:1] plus i.
    vol3_plus_i_next: assert property (
        @(posedge clk_i) disable iff (rst_i)
            (volume[3] == 1'b1) |=> (o == (($past(i) << $past(volume[3:1])) + $past(i)))
    );

    // Next-cycle output equals i shifted left by volume[3:1] plus i repeated volume[0:2].
    full_output_next: assert property (
        @(posedge clk_i) disable iff (rst_i)
            1'b1 |=> (o == (($past(i) << $past(volume[3:1])) + $past(i) + $past(i) + $past(i)))
    );
endmodule