module can_register_asyn_syn_sva (
    input logic [7:0] data_in,
    input logic       we,
    input logic       clk,
    input logic       rst,
    input logic       rst_sync,
    input logic [7:0] data_out
);

// Clock: clk (posedge). Resets: rst (active-high), rst_sync (active-high).
    // Logic: sequential register with synchronous reset and write enable.

    // When rst is asserted, data_out is driven to RESET_VALUE (0) on the next cycle.
    check_reset_forces_zero: assert property (
        @(posedge clk) rst |=> (data_out == 8'h00)
    );

// When rst_sync is asserted and not in reset, data_out is driven to RESET_VALUE (0) on the next cycle.
    check_sync_reset_forces_zero: assert property (
        @(posedge clk) disable iff (rst) rst_sync |=> (data_out == 8'h00)
    );

// When we is high and not in reset, data_out captures data_in on the next cycle.
    check_write_captures_data: assert property (
        @(posedge clk) disable iff (rst) we |=> (data_out == $past(data_in))
    );

// When we is low and not in reset, data_out holds its previous value on the next cycle.
    check_hold_when_no_write: assert property (
        @(posedge clk) disable iff (rst) !we |=> (data_out == $past(data_out))
    );

// When we is low and rst_sync is high, data_out is still held to its previous value on the next cycle.
    check_hold_when_sync_reset_and_no_write: assert property (
        @(posedge clk) disable iff (rst) (!we && rst_sync) |=> (data_out == $past(data_out))
    );

// If both we and rst_sync are high, write has priority and data_out captures data_in.
    check_priority_write_over_sync_reset: assert property (
        @(posedge clk) disable iff (rst) (we && rst_sync) |=> (data_out == $past(data_in))
    );

endmodule
