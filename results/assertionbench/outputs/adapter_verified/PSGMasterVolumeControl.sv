module PSGMasterVolumeControl_sva (
    input logic rst_i,
    input logic clk_i,
    input logic [15:0] i,
    input logic [3:0] volume,
    input logic [19:0] o
);

// Reset drives the output to zero on the next clock.
    check_reset_clears_output: assert property (
        @(posedge clk_i) rst_i |=> (o == 20'd0)
    );

// With volume[3] low, the output holds its previous value.
    check_volume3_low_holds_output: assert property (
        @(posedge clk_i) disable iff (rst_i)
        !volume[3] |=> (o == $past(o))
    );

// With volume[2] low, the output holds its previous value.
    check_volume2_low_holds_output: assert property (
        @(posedge clk_i) disable iff (rst_i)
        (!volume[3] && !volume[2]) |=> (o == $past(o))
    );

// With volume[1] low, the output holds its previous value.
    check_volume1_low_holds_output: assert property (
        @(posedge clk_i) disable iff (rst_i)
        (!volume[3] && !volume[2] && !volume[1]) |=> (o == $past(o))
    );

// With volume[0] low, the output holds its previous value.
    check_volume0_low_holds_output: assert property (
        @(posedge clk_i) disable iff (rst_i)
        (!volume[3] && !volume[2] && !volume[1] && !volume[0]) |=> (o == $past(o))
    );

// With volume[3] high, the output increments by i.
    check_volume3_high_increments_output: assert property (
        @(posedge clk_i) disable iff (rst_i)
        volume[3] |=> (o == ($past(o) + {16'd0, i}))
    );

// With volume[2] high, the output increments by i*2.
    check_volume2_high_increments_output: assert property (
        @(posedge clk_i) disable iff (rst_i)
        (volume[3] && !volume[2]) |=> (o == ($past(o) + {15'd0, i, 1'b0}))
    );

// With volume[1] high, the output increments by i*4.
    check_volume1_high_increments_output: assert property (
        @(posedge clk_i) disable iff (rst_i)
        (volume[3] && !volume[2] && !volume[1]) |=> (o == ($past(o) + {14'd0, i, 2'b0}))
    );

// With volume[0] high, the output increments by i*8.
    check_volume0_high_increments_output: assert property (
        @(posedge clk_i) disable iff (rst_i)
        (volume[3] && !volume[2] && !volume[1] && !volume[0]) |=> (o == ($past(o) + {13'd0, i, 3'b0}))
    );

endmodule
