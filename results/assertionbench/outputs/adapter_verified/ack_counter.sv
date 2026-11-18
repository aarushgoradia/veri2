module ack_counter_sva (
    input logic clock,
    input logic reset,
    input logic ready,
    input logic tx_start,
    input logic [15:0] max_count,
    input logic tx_ack
);

// Reset drives tx_ack low.
    check_reset_clears_tx_ack: assert property (
        @(posedge clock) reset |-> (tx_ack == 1'b0)
    );

// tx_ack is low when start_count is low.
    check_tx_ack_low_when_start_count_low: assert property (
        @(posedge clock) disable iff (reset) (!start_count) |-> (tx_ack == 1'b0)
    );

// tx_ack is high when start_count is high and previous start_count was low.
    check_tx_ack_high_when_start_count_rise: assert property (
        @(posedge clock) disable iff (reset) (start_count && !start_count_del) |-> (tx_ack == 1'b1)
    );

// tx_ack is low when start_count is high and previous start_count was high.
    check_tx_ack_low_when_start_count_hold: assert property (
        @(posedge clock) disable iff (reset) (start_count && start_count_del) |-> (tx_ack == 1'b0)
    );

// tx_ack is low when start_count is high and previous start_count was low but counter is at max_count.
    check_tx_ack_low_when_max_count_and_start_count_rise: assert property (
        @(posedge clock) disable iff (reset) (start_count && !start_count_del && (counter == max_count)) |-> (tx_ack == 1'b0)
    );

// tx_ack is high when start_count is high and previous start_count was low and counter is below max_count.
    check_tx_ack_high_when_below_max_count_and_start_count_rise: assert property (
        @(posedge clock) disable iff (reset) (start_count && !start_count_del && (counter != max_count)) |-> (tx_ack == 1'b1)
    );

endmodule
