module PSGOutputSummer_sva (
    input logic        clk_i,
    input logic [7:0]  cnt,
    input logic [21:0] ufi,
    input logic [21:0] fi,
    input logic [21:0] o
);

    // Output holds when the divider is not zero.
    check_hold_when_cnt_nonzero: assert property (
        @(posedge clk_i) (cnt != 8'd0) |=> (o == $past(o))
    );

    // Output updates on the cycle after the divider reaches zero.
    check_update_on_cnt_zero: assert property (
        @(posedge clk_i) (cnt == 8'd0) |=> (o == ($past(ufi) + $past(fi)))
    );

    // Output reflects the previous cycle's filtered and unfiltered sums.
    check_update_matches_previous_inputs: assert property (
        @(posedge clk_i) 1'b1 |=> (o == ($past(ufi) + $past(fi)))
    );

endmodule