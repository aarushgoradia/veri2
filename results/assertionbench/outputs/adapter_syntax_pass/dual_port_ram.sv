module dual_port_ram_sva
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 14
)
(
    input logic clk,
    input logic r_ena,
    input logic w_ena,
    input logic [DATA_WIDTH-1:0] w_data,
    input logic [ADDR_WIDTH-1:0] w_addr,
    input logic [ADDR_WIDTH-1:0] r_addr,
    input logic [DATA_WIDTH-1:0] r_data
);

    // A write to the memory is captured on the next clock.
    check_write_captures_data: assert property (
        @(posedge clk) disable iff ($initstate)
        w_ena |=> (mem[w_addr] == $past(w_data))
    );

    // A read from the memory is captured on the next clock.
    check_read_captures_data: assert property (
        @(posedge clk) disable iff ($initstate)
        r_ena |=> (r_data == $past(mem[r_addr]))
    );

    // A read from an address with no prior write returns zero.
    check_read_returns_zero_without_write: assert property (
        @(posedge clk) disable iff ($initstate)
        (!r_ena && (r_addr != $past(w_addr))) |=> (r_data == {DATA_WIDTH{1'b0}})
    );

    // A write followed by a read returns the written value.
    check_write_then_read_returns_written_value: assert property (
        @(posedge clk) disable iff ($initstate)
        (w_ena && r_ena && (w_addr == r_addr)) |=> (r_data == $past(w_data))
    );

    // A read followed by a write does not overwrite the read value.
    check_read_then_write_keeps_read_value: assert property (
        @(posedge clk) disable iff ($initstate)
        (r_ena && w_ena && (r_addr != w_addr)) |=> (r_data == $past(mem[r_addr]))
    );

endmodule