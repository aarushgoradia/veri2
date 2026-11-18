module dual_port_ram_sva (
    input logic clk,
    input logic r_ena,
    input logic w_ena,
    input logic [31:0] w_data,
    input logic [13:0] w_addr,
    input logic [13:0] r_addr,
    input logic [31:0] r_data
);

// A write to w_addr captures w_data on the next clock.
    check_write_captures_data: assert property (
        @(posedge clk) w_ena |=> (mem[w_addr] == $past(w_data))
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read from r_addr returns the value written to that address since the last read.
    check_read_returns_written_data: assert property (
        @(posedge clk) r_ena |=> (r_data == mem[r_addr])
    );

// A read