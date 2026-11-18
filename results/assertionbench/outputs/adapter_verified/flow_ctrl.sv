module flow_ctrl_sva (
    input logic Reset,
    input logic Clk,
    input logic tx_pause_en,
    input logic xoff_cpu,
    input logic xon_cpu,
    input logic [15:0] pause_quanta,
    input logic pause_quanta_val,
    input logic pause_apply,
    input logic pause_quanta_sub,
    input logic xoff_gen,
    input logic xoff_gen_complete,
    input logic xon_gen,
    input logic xon_gen_complete
);

// Reset clears all registered outputs by the next clock.
    check_reset_clears_outputs: assert property (
        @(posedge Clk) Reset |=> (pause_apply == 1'b0) &&
                               (xoff_gen == 1'b0) &&
                               (xon_gen == 1'b0)
    );

// pause_apply is low when pause_quanta_counter is zero.
    check_pause_apply_low_when_counter_zero: assert property (
        @(posedge Clk) disable iff (Reset)
        (pause_quanta_counter == 16'h0000) |-> (pause_apply == 1'b0)
    );

// pause_apply is high when pause_quanta_counter is non-zero and tx_pause_en is high.
    check_pause_apply_high_when_counter_nonzero_and_tx_pause_en: assert property (
        @(posedge Clk) disable iff (Reset)
        (pause_quanta_counter != 16'h0000 && tx_pause_en == 1'b1) |-> (pause_apply == 1'b1)
    );

// pause_apply can only rise when both conditions are met.
    check_pause_apply_rise_requires_counter_nonzero_and_tx_pause_en: assert property (
        @(posedge Clk) disable iff (Reset)
        $rose(pause_apply) |-> (pause_quanta_counter != 16'h0000 && tx_pause_en == 1'b1)
    );

// pause_apply can only fall when pause_quanta_counter is zero.
    check_pause_apply_fall_requires_counter_zero: assert property (
        @(posedge Clk) disable iff (Reset)
        $fell(pause_apply) |-> (pause_quanta_counter == 16'h0000)
    );

// pause_quanta_counter loads pause_quanta when pause_quanta_val is high.
    check_pause_quanta_counter_loads_pause_quanta: assert property (
        @(posedge Clk) disable iff (Reset)
        (pause_quanta_val == 1'b1) |=> (pause_quanta_counter == $past(pause_quanta))
    );

// pause_quanta_counter decrements when pause_quanta_sub is high and counter is non-zero.
    check_pause_quanta_counter_decrements_when_sub_and_nonzero: assert property (
        @(posedge Clk) disable iff (Reset)
        (pause_quanta_sub == 1'b1 && pause_quanta_counter != 16'h0000) |=> (pause_quanta_counter == ($past(pause_quanta_counter) - 16'd1))
    );

// pause_quanta_counter holds when neither load nor decrement condition is met.
    check_pause_quanta_counter_holds_when_no_update: assert property (
        @(posedge Clk) disable iff (Reset)
        !(pause_quanta_val == 1'b1 || (pause_quanta_sub == 1'b1 && pause_quanta_counter != 16'h0000)) |=> (pause_quanta_counter == $past(pause_quanta_counter))
    );

// xoff_gen is asserted on the cycle after xoff_gen_complete is high.
    check_xoff_gen_asserts_after_complete: assert property (
        @(posedge Clk) disable iff (Reset)
        xoff_gen_complete |=> (xoff_gen == 1'b1)
    );

// xoff_gen is deasserted on the cycle after xoff_gen_complete is high.
    check_xoff_gen_deasserts_after_complete: assert property (
        @(posedge Clk) disable iff (Reset)
        xoff_gen_complete |=> (xoff_gen == 1'b0)
    );

// xoff_gen is high when xoff_cpu is high and previous xoff_cpu was low.
    check_xoff_gen_high_on_cpu_rise: assert property (
        @(posedge Clk) disable iff (Reset)
        (xoff_cpu && !$past(xoff_cpu)) |=> (xoff_gen == 1'b1)
    );

// xoff_gen is low when xoff_cpu is low or previous xoff_cpu was high.
    check_xoff_gen_low_on_cpu_stable_or_fall: assert property (
        @(posedge Clk) disable iff (Reset)
        (!xoff_cpu || $past(xoff_cpu)) |=> (xoff_gen == 1'b0)
    );

// xon_gen is asserted on the cycle after xon_gen_complete is high.
    check_xon_gen_asserts_after_complete: assert property (
        @(posedge Clk) disable iff (Reset)
        xon_gen_complete |=> (xon_gen == 1'b1)
    );

// xon_gen is deasserted on the cycle after xon_gen_complete is high.
    check_xon_gen_deasserts_after_complete: assert property (
        @(posedge Clk) disable iff (Reset)
        xon_gen_complete |=> (xon_gen == 1'b0)
    );

// xon_gen is high when xon_cpu is high and previous xon_cpu was low.
    check_xon_gen_high_on_cpu_rise: assert property (
        @(posedge Clk) disable iff (Reset)
        (xon_cpu && !$past(xon_cpu)) |=> (xon_gen == 1'b1)
    );

// xon_gen is low when xon_cpu is low or previous xon_cpu was high.
    check_xon_gen_low_on_cpu_stable_or_fall: assert property (
        @(posedge Clk) disable iff (Reset)
        (!xon_cpu || $past(xon_cpu)) |=> (xon_gen == 1'b0)
    );

endmodule
