module PSGOutputSummer_sva (
    input logic clk_i,
    input logic [7:0] cnt,
    input logic [21:0] ufi,
    input logic [21:0] fi,
    input logic [21:0] o
);

// When cnt is 0, next-cycle output equals current ufi plus current fi.
    check_sum_on_cnt_zero: assert property (
        @(posedge clk_i) (cnt == 8'd0) |=> (o == ($past(ufi) + $past(fi)))
    );

// When cnt is not 0, next-cycle output holds its value.
    check_hold_when_cnt_nonzero: assert property (
        @(posedge clk_i) (cnt != 8'd0) |=> (o == $past(o))
    );

// On the first cycle after cnt reaches 0, output equals ufi plus fi.
    check_sum_on_first_cycle_after_zero: assert property (
        @(posedge clk_i) (cnt == 8'd0) |=> ##1 (o == ($past(ufi) + $past(fi)))
    );

// On the second cycle after cnt reaches 0, output still equals ufi plus fi.
    check_sum_on_second_cycle_after_zero: assert property (
        @(posedge clk_i) (cnt == 8'd0) |=> ##2 (o == ($past(ufi) + $past(fi)))
    );

// On the third cycle after cnt reaches 0, output still equals ufi plus fi.
    check_sum_on_third_cycle_after_zero: assert property (
        @(posedge clk_i) (cnt == 8'd0) |=> ##3 (o == ($past(ufi) + $past(fi)))
    );

endmodule
