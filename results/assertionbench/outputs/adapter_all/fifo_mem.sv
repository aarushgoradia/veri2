module fifo_mem_sva #(
    parameter int DEPTH = 8,
    parameter int DATA_WIDTH = 8,
    parameter int PTR_WIDTH = 3
) (
    input logic wclk,
    input logic w_en,
    input logic rclk,
    input logic r_en,
    input logic [PTR_WIDTH:0] b_wptr,
    input logic [PTR_WIDTH:0] b_rptr,
    input logic [DATA_WIDTH-1:0] data_in,
    input logic full,
    input logic empty,
    input logic [DATA_WIDTH-1:0] data_out
);

    // Clocks: wclk (write), rclk (read). Reset: none.
    // Logic: mixed (sequential write, combinational read).
    // Behavior: write to fifo[b_wptr] when w_en && !full; read from fifo[b_rptr] on rclk.

    // Write updates the selected FIFO entry when enabled and not full.
    check_write_updates_fifo: assert property (
        @(posedge wclk) disable iff (1'b0)
        (w_en && !full) |=> (fifo[b_wptr[PTR_WIDTH-1:0]] == $past(data_in))
    );

    // Write does not update the selected FIFO entry when disabled.
    check_write_disabled_no_update: assert property (
        @(posedge wclk) disable iff (1'b0)
        (!w_en) |=> (fifo[b_wptr[PTR_WIDTH-1:0]] == $past(fifo[b_wptr[PTR_WIDTH-1:0]]))
    );

    // Write does not update the selected FIFO entry when full.
    check_write_full_no_update: assert property (
        @(posedge wclk) disable iff (1'b0)
        (w_en && full) |=> (fifo[b_wptr[PTR_WIDTH-1:0]] == $past(fifo[b_wptr[PTR_WIDTH-1:0]]))
    );

    // Read captures the selected FIFO entry on each read clock.
    check_read_captures_fifo: assert property (
        @(posedge rclk) disable iff (1'b0)
        1'b1 |=> (data_out == $past(fifo[b_rptr[PTR_WIDTH-1:0]]))
    );

    // Read returns the value present in the selected FIFO entry.
    check_read_matches_selected_entry: assert property (
        @(posedge rclk) disable iff (1'b0)
        1'b1 |=> (data_out == $past(fifo[b_rptr[PTR_WIDTH-1:0]]))
    );

    // A read of an empty FIFO returns zero.
    check_read_empty_returns_zero: assert property (
        @(posedge rclk) disable iff (1'b0)
        empty |=> (data_out == '0)
    );

endmodule