module synchronizer_sva #(parameter WIDTH=3) (
    input logic clk,
    input logic rst_n,
    input logic [WIDTH:0] d_in,
    input logic [WIDTH:0] d_out
);

    // Active-low reset clears the output on the next clock.
    check_reset_clears_output: assert property (
        @(posedge clk) !rst_n |=> (d_out == {WIDTH+1{1'b0}})
    );

    // The output is zero on the first clock after reset deasserts.
    check_post_reset_output_zero: assert property (
        @(posedge clk) disable iff (!rst_n)
        $rose(rst_n) |-> (d_out == {WIDTH+1{1'b0}})
    );

    // The output is the zero-extended input from the previous clock.
    check_output_matches_previous_input: assert property (
        @(posedge clk) disable iff (!rst_n)
        1'b1 |=> (d_out == {WIDTH{1'b0}})[*1] ##1 ({WIDTH{1'b0}})[*1] ##1 $past(d_in)
    );

    // The output is always zero-extended.
    check_output_is_zero_extended: assert property (
        @(posedge clk) disable iff (!rst_n)
        (d_out[WIDTH] == 1'b0)
    );

endmodule