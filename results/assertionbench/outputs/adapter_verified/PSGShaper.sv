module PSGShaper_sva (
    input logic clk_i,
    input logic ce,
    input logic [11:0] tgi,
    input logic [7:0] env,
    input logic [19:0] o
);

// Output updates to tgi * env when ce is high.
    check_shape_on_ce: assert property (
        @(posedge clk_i) ce |=> (o == ($past(tgi) * $past(env)))
    );

// Output holds its value when ce is low.
    check_hold_when_ce_low: assert property (
        @(posedge clk_i) !ce |=> (o == $past(o))
    );

// Output is zero when the previous envelope value was zero.
    check_zero_when_env_zero: assert property (
        @(posedge clk_i) ce && ($past(env) == 8'h00) |=> (o == 20'h00000)
    );

// Output is zero when the previous tone value was zero.
    check_zero_when_tgi_zero: assert property (
        @(posedge clk_i) ce && ($past(tgi) == 12'h000) |=> (o == 20'h00000)
    );

// Output is zero when both previous tone and envelope are zero.
    check_zero_when_both_zero: assert property (
        @(posedge clk_i) ce && ($past(tgi) == 12'h000) && ($past(env) == 8'h00) |=> (o == 20'h00000)
    );

endmodule
