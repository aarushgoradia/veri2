module PSGOutputSummer_sva (
    input logic clk_i,
    input logic [7:0] cnt,
    input logic [21:0] ufi,
    input logic [21:0] fi,
    input logic [21:0] o
);

    // When cnt is zero, o captures the sum of ufi and fi.
    check_sum_capture: assert property (
        @(posedge clk_i) (cnt == 8'd0) |=> (o == ($past(ufi) + $past(fi)))
    );

    // When cnt is nonzero, o holds its previous value.
    check_hold_when_cnt_nonzero: assert property (
        @(posedge clk_i) (cnt != 8'd0) |=> (o == $past(o))
    );

    // The output is always either unchanged or the previous cycle's sum.
    check_output_change_or_sum: assert property (
        @(posedge clk_i) 1'b1 |=> ((o == $past(o)) || (o == ($past(ufi) + $past(fi))))
    );

endmodule