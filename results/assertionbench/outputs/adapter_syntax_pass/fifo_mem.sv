module fifo_mem_sva #(parameter DEPTH=8, DATA_WIDTH=8, PTR_WIDTH=3) (
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

    // Write enables a new data sample into the selected memory location.
    check_write_capture: assert property (
        @(posedge wclk) disable iff (1'b0)
        (w_en && !full) |=> (fifo[b_wptr[PTR_WIDTH-1:0]] == $past(data_in))
    );

    // Write does not overwrite an existing sample when the memory is full.
    check_write_no_overwrite_when_full: assert property (
        @(posedge wclk) disable iff (1'b0)
        (w_en && full) |=> (fifo[b_wptr[PTR_WIDTH-1:0]] == $past(fifo[b_wptr[PTR_WIDTH-1:0]]))
    );

    // Read captures the data sample from the selected memory location.
    check_read_capture: assert property (
        @(posedge rclk) disable iff (1'b0)
        (r_en && !empty) |=> (data_out == $past(fifo[b_rptr[PTR_WIDTH-1:0]]))
    );

    // Read returns zero-extended data when the memory is empty.
    check_read_zero_when_empty: assert property (
        @(posedge rclk) disable iff (1'b0)
        (r_en && empty) |=> (data_out == {DATA_WIDTH{1'b0}})
    );

endmodule