module ack_counter_sva (
    input logic        clock,
    input logic        reset,
    input logic        ready,
    input logic        tx_start,
    input logic [15:0] max_count,
    input logic        tx_ack,
    input logic        start_count,
    input logic        start_count_del,
    input logic [15:0] counter
);

    // Reset clears all registered state.
    check_reset_clears_state: assert property (
        @(posedge clock) reset |-> ((start_count == 1'b0) && (start_count_del == 1'b0) && (counter == 16'd0) && (tx_ack == 1'b0))
    );

    // tx_start sets start_count on the next clock.
    check_start_count_set_on_tx_start: assert property (
        @(posedge clock) disable iff (reset) tx_start |=> (start_count == 1'b1)
    );

    // tx_start has no effect when start_count is already asserted.
    check_start_count_no_repeat_set: assert property (
        @(posedge clock) disable iff (reset) (tx_start && start_count) |=> (start_count == 1'b1)
    );

    // start_count clears when counter equals max_count and ready is low.
    check_start_count_clears_on_max_count_no_ready: assert property (
        @(posedge clock) disable iff (reset) (counter == max_count) && !ready |=> (start_count == 1'b0)
    );

    // start_count holds when neither tx_start nor the clear condition is true.
    check_start_count_holds_without_enable: assert property (
        @(posedge clock) disable iff (reset) (!tx_start && !(counter == max_count && !ready)) |=> (start_count == $past(start_count))
    );

    // counter wraps to zero when it matches max_count.
    check_counter_wraps_on_max_count: assert property (
        @(posedge clock) disable iff (reset) (counter == max_count) |=> (counter == 16'd0)
    );

    // counter increments when start_count is asserted and not at max_count.
    check_counter_increments_when_enabled: assert property (
        @(posedge clock) disable iff (reset) (start_count && (counter != max_count)) |=> (counter == ($past(counter) + 16'd1))
    );

    // counter holds when start_count is deasserted.
    check_counter_holds_when_disabled: assert property (
        @(posedge clock) disable iff (reset) (!start_count) |=> (counter == $past(counter))
    );

    // start_count_del captures start_count on the next clock.
    check_start_count_del_captures_start_count: assert property (
        @(posedge clock) disable iff (reset) 1'b1 |=> (start_count_del == $past(start_count))
    );

    // tx_ack is the registered AND of ~start_count and start_count_del.
    check_tx_ack_registered_function: assert property (
        @(posedge clock) disable iff (reset) 1'b1 |=> (tx_ack == (~$past(start_count) & $past(start_count_del)))
    );

    // tx_ack is high only when start_count was high and start_count_del was low on the prior clock.
    check_tx_ack_high_condition: assert property (
        @(posedge clock) disable iff (reset) tx_ack |-> ($past(start_count) && !$past(start_count_del))
    );

    // tx_ack is low when start_count was low on the prior clock.
    check_tx_ack_low_when_start_count_low: assert property (
        @(posedge clock) disable iff (reset) !$past(start_count) |-> !tx_ack
    );

    // tx_ack is low when start_count_del was high on the prior clock.
    check_tx_ack_low_when_start_count_del_high: assert property (
        @(posedge clock) disable iff (reset) $past(start_count_del) |-> !tx_ack
    );

endmodule