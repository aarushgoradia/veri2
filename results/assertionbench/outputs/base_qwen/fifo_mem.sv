```systemverilog
module fifo_mem_sva (
    input logic wclk,
    input logic w_en,
    input logic rclk,
    input logic r_en,
    input logic [3:0] b_wptr,
    input logic [3:0] b_rptr,
    input logic [7:0] data_in,
    input logic full,
    input logic empty,
    output logic [7:0] data_out
);
    // FIFO write operation should only occur when write enable is high and FIFO is not full
    fifo_write: assert property (
        @(posedge wclk) disable iff (!full) w_en |-> !full
    );

    // FIFO read operation should only occur when read enable is high and FIFO is not empty
    fifo_read: assert property (
        @(posedge rclk) disable iff (!empty) r_en |-> !empty
    );

    // Data should be written to the FIFO at the correct address
    fifo_write_addr: assert property (
        @(posedge wclk) disable iff (!full) w_en |-> fifo[b_wptr[PTR_WIDTH-1:0]] == data_in
    );

    // Data should be read from the FIFO at the correct address
    fifo_read_addr: assert property (
        @(posedge rclk) disable iff (!empty) r_en |-> data_out == fifo[b_rptr[PTR_WIDTH-1:0]]
    );

    // Write pointer should not exceed the depth of the FIFO
    fifo_write_ptr: assert property (
        @(posedge wclk) disable iff (!full) w_en |-> b_wptr[PTR_WIDTH-1:0] < DEPTH
    );

    // Read pointer should not exceed the depth of the FIFO
    fifo_read_ptr: assert property (
        @(posedge rclk) disable iff (!empty) r_en |-> b_rptr[PTR_WIDTH-1:0] < DEPTH
    );

    // Write pointer should not wrap around when writing
    fifo_write_wrap: assert property (
        @(posedge wclk) disable iff (!full) w_en |-> b_wptr[PTR_WIDTH-1:0] != DEPTH - 1 |-> b_wptr[PTR_WIDTH-1:0] + 1 == b_wptr[PTR_WIDTH-1:0]
    );

    // Read pointer should not wrap around when reading
    fifo_read_wrap: assert property (
        @(posedge rclk) disable iff (!empty) r_en |-> b_rptr[PTR_WIDTH-1:0] != DEPTH - 1 |-> b_rptr[PTR_WIDTH-1:0] + 1 == b_rptr[PTR_WIDTH-1:0]
    );

    // Data_out should be stable when read enable is high
    fifo_data_out_stable: assert property (
        @(posedge rclk) disable iff (!empty) r_en |-> ##1 data_out == data_out
    );

    // Data_out should be stable when write enable is high
    fifo_data_out_stable_write: assert property (
        @(posedge wclk) disable iff (!full) w_en |-> ##1 data_out == data_out
    );
endmodule
```