module ack_counter_sva (
    input logic clock,
    input logic reset,
    input logic ready,
    input logic tx_start,
    input logic [15:0] max_count,
    input logic tx_ack,
    input logic start_count,
    input logic start_count_del,
    input logic [15:0] counter
);

    // Reset clears start_count on the next clock sample.
    check_start_count_reset: assert property (
        @(posedge clock) reset |=> (start_count == 1'b0)
    );

    // Reset clears start_count_del on the next clock sample.
    check_start_count_del_reset: assert property (
        @(posedge clock) reset |=> (start_count_del == 1'b0)
    );

    // Reset clears tx_ack on the next clock sample.
    check_tx_ack_reset: assert property (
        @(posedge clock) reset |=> (tx_ack == 1'b0)
    );

    // Reset clears the counter on the next clock sample.
    check_counter_reset: assert property (
        @(posedge clock) reset |=> (counter == 16'h0000)
    );

    // tx_start sets start_count on the next clock sample.
    check_start_count_set_on_tx_start: assert property (
        @(posedge clock) disable iff (reset) tx_start |=> (start_count == 1'b1)
    );

    // tx_start has priority over the terminal-count clear condition.
    check_start_count_set_over_terminal_clear: assert property (
        @(posedge clock) disable iff (reset)
        (tx_start && (counter == max_count) && !ready) |=> (start_count == 1'b1)
    );

    // The terminal-count clear condition clears start_count when tx_start is low.
    check_start_count_clear_on_terminal_count: assert property (
        @(posedge clock) disable iff (reset)
        (!tx_start && (counter == max_count) && !ready) |=> (start_count == 1'b0)
    );

    // start_count_del captures the previous cycle's start_count.
    check_start_count_del_captures_start_count: assert property (
        @(posedge clock) disable iff (reset) 1'b1 |=> (start_count_del == $past(start_count))
    );

    // tx_ack is the AND of the previous cycle's start_count and start_count_del.
    check_tx_ack_matches_previous_controls: assert property (
        @(posedge clock) disable iff (reset) 1'b1 |=> (tx_ack == ($past(start_count) & $past(start_count_del)))
    );

    // tx_ack is high only when the previous cycle had start_count high and start_count_del low.
    check_tx_ack_high_condition: assert property (
        @(posedge clock) disable iff (reset) tx_ack |-> ($past(start_count) && !$past(start_count_del))
    );

    // tx_ack is low whenever the previous cycle had start_count low.
    check_tx_ack_low_when_start_count_low: assert property (
        @(posedge clock) disable iff (reset) !$past(start_count) |-> (tx_ack == 1'b0)
    );

    // tx_ack is low whenever the previous cycle had start_count_del high.
    check_tx_ack_low_when_start_count_del_high: assert property (
        @(posedge clock) disable iff (reset) $past(start_count_del) |-> (tx_ack == 1'b0)
    );

    // A terminal count with ready high clears the counter on the next clock sample.
    check_counter_clears_on_terminal_count_with_ready: assert property (
        @(posedge clock) disable iff (reset)
        (!tx_start && (counter == max_count) && ready) |=> (counter == 16'h0000)
    );

    // A terminal count with ready low holds the counter on the next clock sample.
    check_counter_holds_on_terminal_count_without_ready: assert property (
        @(posedge clock) disable iff (reset)
        (!tx_start && (counter == max_count) && !ready) |=> (counter == $past(counter))
    );

    // start_count_del is low whenever start_count is high.
    check_start_count_del_low_when_start_count_high: assert property (
        @(posedge clock) disable iff (reset) start_count |-> (start_count_del == 1'b0)
    );

endmodule