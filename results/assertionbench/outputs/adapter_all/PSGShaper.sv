module PSGShaper_sva (
    input logic        clk_i,
    input logic        ce,
    input logic [11:0] tgi,
    input logic [7:0]  env,
    input logic [19:0] o
);

    // Output holds when clock enable is low.
    check_hold_when_ce_low: assert property (
        @(posedge clk_i) !ce |=> (o == $past(o))
    );

    // Output updates with the previous cycle's tgi * env when enabled.
    check_update_when_ce_high: assert property (
        @(posedge clk_i) ce |=> (o == ($past(tgi) * $past(env)))
    );

    // Zero envelope forces the output to zero on the next cycle.
    check_zero_env_forces_zero: assert property (
        @(posedge clk_i) ce && (env == 8'h00) |=> (o == 20'h00000)
    );

    // Zero tone generator forces the output to zero on the next cycle.
    check_zero_tgi_forces_zero: assert property (
        @(posedge clk_i) ce && (tgi == 12'h000) |=> (o == 20'h00000)
    );

    // Maximum envelope value passes the tone generator value through.
    check_max_env_passthrough: assert property (
        @(posedge clk_i) ce && (env == 8'hFF) |=> (o == ($past(tgi) << 8))
    );

    // Maximum tone generator value passes the envelope value through.
    check_max_tgi_passthrough: assert property (
        @(posedge clk_i) ce && (tgi == 12'hFFF) |=> (o == ($past(env) << 12))
    );

    // Output always matches the previous cycle's enabled update or hold.
    check_output_matches_previous_cycle: assert property (
        @(posedge clk_i) 1'b1 |=> (o == ($past(ce) ? ($past(tgi) * $past(env)) : $past(o)))
    );

endmodule