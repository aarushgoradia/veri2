module PSGChannelSummer_sva (
    input logic clk_i,
    input logic [7:0] cnt,
    input logic [3:0] outctrl,
    input logic [19:0] tmc_i,
    input logic [21:0] o
);

// When cnt==0, next cycle o equals current o plus tmc_i masked by outctrl[sel].
    check_cnt0_adds_masked_tmc: assert property (
        @(posedge clk_i) (cnt == 8'd0) |=> (o == ($past(o) + ($past(tmc_i) & {20{$past(outctrl[sel])}})))
    );

// When 1<=cnt<=3, next cycle o equals current o plus tmc_i masked by outctrl[sel].
    check_cnt1_to_3_adds_masked_tmc: assert property (
        @(posedge clk_i) (cnt inside {[8'd1:8'd3]}) |=> (o == ($past(o) + ($past(tmc_i) & {20{$past(outctrl[sel])}})))
    );

// When cnt>=4, next cycle o holds its value.
    check_cnt_ge4_holds_o: assert property (
        @(posedge clk_i) (cnt >= 8'd4) |=> (o == $past(o))
    );

// When cnt==0 and outctrl[sel]==0, next cycle o equals current o.
    check_cnt0_zero_outctrl_holds_o: assert property (
        @(posedge clk_i) (cnt == 8'd0 && outctrl[sel] == 1'b0) |=> (o == $past(o))
    );

// When cnt==0 and outctrl[sel]==1, next cycle o equals current o plus tmc_i.
    check_cnt0_one_outctrl_adds_tmc: assert property (
        @(posedge clk_i) (cnt == 8'd0 && outctrl[sel] == 1'b1) |=> (o == ($past(o) + $past(tmc_i)))
    );

// When 1<=cnt<=3 and outctrl[sel]==0, next cycle o equals current o.
    check_cnt1_to_3_zero_outctrl_holds_o: assert property (
        @(posedge clk_i) (cnt inside {[8'd1:8'd3]} && outctrl[sel] == 1'b0) |=> (o == $past(o))
    );

// When 1<=cnt<=3 and outctrl[sel]==1, next cycle o equals current o plus tmc_i.
    check_cnt1_to_3_one_outctrl_adds_tmc: assert property (
        @(posedge clk_i) (cnt inside {[8'd1:8'd3]} && outctrl[sel] == 1'b1) |=> (o == ($past(o) + $past(tmc_i)))
    );

endmodule
