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

    ///// Reset behavior /////
    // While Reset is asserted, xoff_gen must be 0.
    reset_xoff_gen_low: assert property (
        @(posedge Clk) Reset |-> (xoff_gen == 1'b0)
    );

    // While Reset is asserted, xon_gen must be 0.
    reset_xon_gen_low: assert property (
        @(posedge Clk) Reset |-> (xon_gen == 1'b0)
    );

    // While Reset is asserted, pause_apply must be 0.
    reset_pause_apply_low: assert property (
        @(posedge Clk) Reset |-> (pause_apply == 1'b0)
    );

    // While Reset is asserted, pause_quanta_counter must be 0.
    reset_pause_counter_zero: assert property (
        @(posedge Clk) Reset |-> (pause_quanta_counter == 16'd0)
    );

    ///// xoff_gen behavior /////
    // If xoff_gen_complete is HIGH, xoff_gen must be 0 next cycle.
    xoff_gen_clear_on_complete: assert property (
        @(posedge Clk) disable iff (Reset) xoff_gen_complete |=> (xoff_gen == 1'b0)
    );

    // If xoff_cpu is HIGH and previous xoff_cpu was LOW, xoff_gen must be 1 next cycle.
    xoff_gen_set_on_cpu_rise: assert property (
        @(posedge Clk) disable iff (Reset) (xoff_cpu && !$past(xoff_cpu)) |=> (xoff_gen == 1'b1)
    );

    // If xoff_cpu is LOW and previous xoff_cpu was HIGH, xoff_gen must be 0 next cycle.
    xoff_gen_clear_on_cpu_fall: assert property (
        @(posedge Clk) disable iff (Reset) (!$past(xoff_cpu) && xoff_cpu) |=> (xoff_gen == 1'b0)
    );

    // If xoff_gen is HIGH, previous xoff_cpu must have been HIGH.
    xoff_gen_implies_prev_cpu_high: assert property (
        @(posedge Clk) disable iff (Reset) xoff_gen |-> $past(xoff_cpu)
    );

    // If xoff_gen is HIGH, previous xoff_cpu must have been LOW.
    xoff_gen_implies_prev_cpu_low: assert property (
        @(posedge Clk) disable iff (Reset) xoff_gen |-> !$past(xoff_cpu)
    );

    ///// xon_gen behavior /////
    // If xon_gen_complete is HIGH, xon_gen must be 0 next cycle.
    xon_gen_clear_on_complete: assert property (
        @(posedge Clk) disable iff (Reset) xon_gen_complete |=> (xon_gen == 1'b0)
    );

    // If xon_cpu is HIGH and previous xon_cpu was LOW, xon_gen must be 1 next cycle.
    xon_gen_set_on_cpu_rise: assert property (
        @(posedge Clk) disable iff (Reset) (xon_cpu && !$past(xon_cpu)) |=> (xon_gen == 1'b1)
    );

    // If xon_cpu is LOW and previous xon_cpu was HIGH, xon_gen must be 0 next cycle.
    xon_gen_clear_on_cpu_fall: assert property (
        @(posedge Clk) disable iff (Reset) (!$past(xon_cpu) && xon_cpu) |=> (xon_gen == 1'b0)
    );

    // If xon_gen is HIGH, previous xon_cpu must have been HIGH.
    xon_gen_implies_prev_cpu_high: assert property (
        @(posedge Clk) disable iff (Reset) xon_gen |-> $past(xon_cpu)
    );

    // If xon_gen is HIGH, previous xon_cpu must have been LOW.
    xon_gen_implies_prev_cpu_low: assert property (
        @(posedge Clk) disable iff (Reset) xon_gen |-> !$past(xon_cpu)
    );

    ///// pause_quanta_counter behavior /////
    // If pause_quanta_val is HIGH and previous pause_quanta_val was LOW, counter loads pause_quanta next cycle.
    counter_load_on_val_rise: assert property (
        @(posedge Clk) disable iff (Reset) (pause_quanta_val && !$past(pause_quanta_val)) |=> (pause_quanta_counter == $past(pause_quanta))
    );

    // If pause_quanta_val is LOW and previous pause_quanta_val was HIGH, counter clears next cycle.
    counter_clear_on_val_fall: assert property (
        @(posedge Clk) disable iff (Reset) (!$past(pause_quanta_val) && pause_quanta_val) |=> (pause_quanta_counter == 16'd0)
    );

    // If pause_quanta_sub is HIGH and counter is non-zero, counter decrements next cycle.
    counter_decrement_on_sub: assert property (
        @(posedge Clk) disable iff (Reset) (pause_quanta_sub && (pause_quanta_counter != 16'd0)) |=> (pause_quanta_counter == ($past(pause_quanta_counter) - 16'd1))
    );

    // If pause_quanta_sub is LOW and counter is non-zero, counter holds next cycle.
    counter_hold_when_no_sub: assert property (
        @(posedge Clk) disable iff (Reset) (!pause_quanta_sub && (pause_quanta_counter != 16'd0)) |=> (pause_quanta_counter == $past(pause_quanta_counter))
    );

    // If pause_quanta_sub is HIGH and counter is zero, counter holds next cycle.
    counter_hold_on_sub_when_zero: assert property (
        @(posedge Clk) disable iff (Reset) (pause_quanta_sub && (pause_quanta_counter == 16'd0)) |=> (pause_quanta_counter == 16'd0)
    );

    ///// pause_apply behavior /////
    // If counter is zero, pause_apply must be 0 next cycle.
    pause_apply_clear_on_counter_zero: assert property (
        @(posedge Clk) disable iff (Reset) (pause_quanta_counter == 16'd0) |=> (pause_apply == 1'b0)
    );

    // If counter is non-zero and previous tx_pause_en was HIGH, pause_apply must be 1 next cycle.
    pause_apply_set_on_tx_pause_en: assert property (
        @(posedge Clk) disable iff (Reset) ((pause_quanta_counter != 16'd0) && $past(tx_pause_en)) |=> (pause_apply == 1'b1)
    );

    // If counter is non-zero and previous tx_pause_en was LOW, pause_apply must be 0 next cycle.
    pause_apply_clear_on_no_tx_pause_en: assert property (
        @(posedge Clk) disable iff (Reset) ((pause_quanta_counter != 16'd0) && !$past(tx_pause_en)) |=> (pause_apply == 1'b0)
    );

    // If pause_apply is HIGH, counter must be non-zero.
    pause_apply_implies_counter_nonzero: assert property (
        @(posedge Clk) disable iff (Reset) pause_apply |-> (pause_quanta_counter != 16'd0)
    );

    // If pause_apply is HIGH, previous tx_pause_en must have been HIGH.
    pause_apply_implies_prev_tx_pause_en_high: assert property (
        @(posedge Clk) disable iff (Reset) pause_apply |-> $past(tx_pause_en)
    );

endmodule