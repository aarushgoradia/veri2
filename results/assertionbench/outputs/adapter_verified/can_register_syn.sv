module can_register_syn_sva (
    input logic [7:0] data_in,
    input logic       we,
    input logic       clk,
    input logic       rst_sync,
    input logic [7:0] data_out
);

// Clock: clk (posedge). Reset: rst_sync synchronous active-high. Logic: sequential register with write enable.

    // On a synchronous reset cycle, data_out is driven to RESET_VALUE (0) on the next clock.
    check_reset_clears_data_out: assert property (
        @(posedge clk) rst_sync |=> (data_out == 8'h00)
    );

// With we=0, data_out holds its previous value on the next clock.
    check_hold_when_we_low: assert property (
        @(posedge clk) disable iff (rst_sync) !we |=> (data_out == $past(data_out))
    );

// With we=1, data_out captures data_in on the next clock.
    check_capture_when_we_high: assert property (
        @(posedge clk) disable iff (rst_sync) we |=> (data_out == $past(data_in))
    );

// If we=0 in the previous cycle, data_out must be unchanged this cycle.
    check_no_change_when_we_low: assert property (
        @(posedge clk) disable iff (rst_sync) $past(!we) |-> (data_out == $past(data_out))
    );

// If we=1 in the previous cycle, data_out must equal data_in from that cycle.
    check_capture_when_we_high: assert property (
        @(posedge clk) disable iff (rst_sync) $past(we) |-> (data_out == $past(data_in))
    );

// If we=0 for two consecutive cycles, data_out must hold its value from two cycles ago.
    check_hold_two_cycles_when_we_low: assert property (
        @(posedge clk) disable iff (rst_sync) (!we)[*2] |-> (data_out == $past(data_out,2))
    );

// If we=1 for two consecutive cycles, data_out must capture data_in from the first of those two cycles.
    check_capture_two_cycles_when_we_high: assert property (
        @(posedge clk) disable iff (rst_sync) (we)[*2] |-> (data_out == $past(data_in,1))
    );

endmodule
