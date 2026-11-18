module PSGShaper_sva (
    input logic clk_i,
    input logic ce,
    input logic [11:0] tgi,
    input logic [7:0] env,
    input logic [19:0] o
);

    // Output must be zero whenever clock enable is low.
    check_output_zero_when_ce_low: assert property (
        @(posedge clk_i) !ce |-> (o == 20'd0)
    );

    // Output must be zero whenever the envelope is zero.
    check_output_zero_when_env_zero: assert property (
        @(posedge clk_i) ce && (env == 8'd0) |-> (o == 20'd0)
    );

    // Output must be zero whenever the tone generator input is zero.
    check_output_zero_when_tgi_zero: assert property (
        @(posedge clk_i) ce && (tgi == 12'd0) |-> (o == 20'd0)
    );

    // Output must match the previous cycle's product when enabled.
    check_output_matches_previous_product: assert property (
        @(posedge clk_i) ce |-> (o == ($past(tgi) * $past(env)))
    );

    // Output must not exceed the product of the previous cycle's inputs.
    check_output_bounded_by_previous_product: assert property (
        @(posedge clk_i) ce |-> (o <= ($past(tgi) * $past(env)))
    );

    // Output must not exceed the maximum 12x8 product.
    check_output_bounded_by_max_product: assert property (
        @(posedge clk_i) ce |-> (o <= 20'd147456)
    );

endmodule