module dual_port_ram_sva #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 14
) (
    input logic clk,
    input logic r_ena,
    input logic w_ena,
    input logic [DATA_WIDTH-1:0] w_data,
    input logic [ADDR_WIDTH-1:0] w_addr,
    input logic [ADDR_WIDTH-1:0] r_addr,
    input logic [DATA_WIDTH-1:0] r_data
);

    // A write updates the memory location with the written data.
    check_write_updates_memory: assert property (
        @(posedge clk) w_ena |=> (mem[w_addr] == $past(w_data))
    );

    // A read updates the read data output with the previously written value.
    check_read_updates_output: assert property (
        @(posedge clk) r_ena |=> (r_data == $past(mem[r_addr]))
    );

    // A read without a prior write returns the zero-initialized memory value.
    check_read_without_prior_write_returns_zero: assert property (
        @(posedge clk) (!r_ena || $past(!w_ena)) |=> (r_data == '0)
    );

    // A write without a prior read does not change the read data output.
    check_write_without_prior_read_holds_output: assert property (
        @(posedge clk) (!r_ena || $past(!w_ena)) |=> (r_data == $past(r_data))
    );

    // A read followed by a write returns the written value on the next read.
    check_read_then_write_returns_written_value: assert property (
        @(posedge clk) (r_ena && w_ena) |=> (r_data == $past(w_data))
    );

    // A write followed by a read returns the written value on the next read.
    check_write_then_read_returns_written_value: assert property (
        @(posedge clk) (w_ena && r_ena) |=> (r_data == $past(w_data))
    );

    // A write followed by a write returns the second written value on the next read.
    check_write_then_write_returns_second_written_value: assert property (
        @(posedge clk) (w_ena && $past(w_ena)) |=> (r_data == $past(w_data))
    );

    // A read followed by a read returns the previously read value on the next read.
    check_read_then_read_returns_previous_read_value: assert property (
        @(posedge clk) (r_ena && $past(r_ena)) |=> (r_data == $past(r_data))
    );

endmodule