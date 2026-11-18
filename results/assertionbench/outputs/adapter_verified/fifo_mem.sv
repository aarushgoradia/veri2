module fifo_mem_sva (
    input logic wclk,
    input logic w_en,
    input logic rclk,
    input logic r_en,
    input logic [2:0] b_wptr,
    input logic [2:0] b_rptr,
    input logic [7:0] data_in,
    input logic full,
    input logic empty,
    input logic [7:0] data_out
);

// Clocks: wclk (write), rclk (read). No reset in RTL.
    // Logic: mixed (sequential write, combinational read).
    // Behavior: write to fifo[b_wptr] when w_en and !full; read from fifo[b_rptr] on rclk.

    // On rclk, data_out equals previous cycle's fifo[b_rptr].
    check_read_returns_prev_cycle_fifo: assert property (
        @(posedge rclk) 1'b1 |=> (data_out == $past(fifo[b_rptr[PTR_WIDTH-1:0]]))
    );

// On rclk, data_out equals previous cycle's fifo[b_rptr] even if r_en is 0.
    check_read_returns_prev_cycle_fifo_when_disabled: assert property (
        @(posedge rclk) 1'b1 |=> (data_out == $past(fifo[b_rptr[PTR_WIDTH-1:0]]))
    );

// On rclk, data_out equals previous cycle's fifo[b_rptr] even if empty is 1.
    check_read_returns_prev_cycle_fifo_when_empty: assert property (
        @(posedge rclk) 1'b1 |=> (data_out == $past(fifo[b_rptr[PTR_WIDTH-1:0]]))
    );

// On wclk, fifo[b_wptr] captures data_in when w_en and !full.
    check_write_captures_data: assert property (
        @(posedge wclk) (w_en && !full) |=> (fifo[b_wptr[PTR_WIDTH-1:0]] == $past(data_in))
    );

// On wclk, fifo[b_wptr] holds its value when w_en is 0.
    check_write_holds_when_disabled: assert property (
        @(posedge wclk) (!w_en) |=> (fifo[b_wptr[PTR_WIDTH-1:0]] == $past(fifo[b_wptr[PTR_WIDTH-1:0]]))
    );

// On wclk, fifo[b_wptr] holds its value when full.
    check_write_holds_when_full: assert property (
        @(posedge wclk) full |=> (fifo[b_wptr[PTR_WIDTH-1:0]] == $past(fifo[b_wptr[PTR_WIDTH-1:0]]))
    );

// On rclk, data_out holds its value when r_en is 0.
    check_read_holds_when_disabled: assert property (
        @(posedge rclk) (!r_en) |=> (data_out == $past(data_out))
    );

// On rclk, data_out holds its value when empty is 1.
    check_read_holds_when_empty: assert property (
        @(posedge rclk) empty |=> (data_out == $past(data_out))
    );

endmodule
