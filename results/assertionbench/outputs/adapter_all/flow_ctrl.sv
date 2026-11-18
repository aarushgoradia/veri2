module flow_ctrl_sva (
    input logic        Reset,
    input logic        Clk,
    input logic        tx_pause_en,
    input logic        xoff_cpu,
    input logic        xon_cpu,
    input logic [15:0] pause_quanta,
    input logic        pause_quanta_val,
    input logic        pause_apply,
    input logic        pause_quanta_sub,
    input logic        xoff_gen,
    input logic        xoff_gen_complete,
    input logic        xon_gen,
    input logic        xon_gen_complete
);

    // Reset clears all registered outputs by the next clock.
    check_reset_clears_outputs: assert property (
        @(posedge Clk) Reset |=> (pause_apply == 1'b0 &&
                                 xoff_gen == 1'b0 &&
                                 xon_gen == 1'b0)
    );

    // pause_apply is low whenever the counter is zero.
    check_pause_apply_low_when_counter_zero: assert property (
        @(posedge Clk) disable iff (Reset)
        (pause_quanta_counter == 16'd0) |-> (pause_apply == 1'b0)
    );

    // pause_apply is high whenever the counter is non-zero.
    check_pause_apply_high_when_counter_nonzero: assert property (
        @(posedge Clk) disable iff (Reset)
        (pause_quanta_counter != 16'd0) |-> (pause_apply == 1'b1)
    );

    // pause_apply follows the tx_pause_en history two clocks earlier.
    check_pause_apply_follows_tx_pause_en_history: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> ##2 (pause_apply == $past(tx_pause_en, 2))
    );

    // pause_apply can only rise when the counter is non-zero.
    check_pause_apply_rise_requires_counter_nonzero: assert property (
        @(posedge Clk) disable iff (Reset)
        $rose(pause_apply) |-> (pause_quanta_counter != 16'd0)
    );

    // pause_apply can only fall when the counter is zero.
    check_pause_apply_fall_requires_counter_zero: assert property (
        @(posedge Clk) disable iff (Reset)
        $fell(pause_apply) |-> (pause_quanta_counter == 16'd0)
    );

    // pause_apply can only change when the counter is non-zero.
    check_pause_apply_change_requires_counter_nonzero: assert property (
        @(posedge Clk) disable iff (Reset)
        $changed(pause_apply) |-> (pause_quanta_counter != 16'd0)
    );

    // pause_apply can only change when tx_pause_en is high two clocks earlier.
    check_pause_apply_change_requires_tx_pause_en_history: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> ##2 ($changed(pause_apply) |-> $past(tx_pause_en, 2))
    );

    // pause_apply is independent of pause_quanta_sub when the counter is non-zero.
    check_pause_apply_independent_of_pause_quanta_sub: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> ##2 ((pause_quanta_counter != 16'd0) &&
                      (pause_apply == $past(pause_apply)) &&
                      (pause_quanta_sub == $past(pause_quanta_sub)))
    );

    // pause_apply is independent of pause_quanta when the counter is non-zero.
    check_pause_apply_independent_of_pause_quanta: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> ##2 ((pause_quanta_counter != 16'd0) &&
                      (pause_apply == $past(pause_apply)) &&
                      (pause_quanta == $past(pause_quanta)))
    );

    // pause_apply is independent of xoff_cpu when the counter is non-zero.
    check_pause_apply_independent_of_xoff_cpu: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> ##2 ((pause_quanta_counter != 16'd0) &&
                      (pause_apply == $past(pause_apply)) &&
                      (xoff_cpu == $past(xoff_cpu)))
    );

    // pause_apply is independent of xon_cpu when the counter is non-zero.
    check_pause_apply_independent_of_xon_cpu: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> ##2 ((pause_quanta_counter != 16'd0) &&
                      (pause_apply == $past(pause_apply)) &&
                      (xon_cpu == $past(xon_cpu)))
    );

    // pause_apply is independent of xoff_gen_complete when the counter is non-zero.
    check_pause_apply_independent_of_xoff_gen_complete: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> ##2 ((pause_quanta_counter != 16'd0) &&
                      (pause_apply == $past(pause_apply)) &&
                      (xoff_gen_complete == $past(xoff_gen_complete)))
    );

    // pause_apply is independent of xon_gen_complete when the counter is non-zero.
    check_pause_apply_independent_of_xon_gen_complete: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> ##2 ((pause_quanta_counter != 16'd0) &&
                      (pause_apply == $past(pause_apply)) &&
                      (xon_gen_complete == $past(xon_gen_complete)))
    );

endmodule