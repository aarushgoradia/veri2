module can_register_asyn_sva (
    input logic [7:0] data_in,
    input logic       we,
    input logic       clk,
    input logic       rst,
    input logic [7:0] data_out
);

// Clock: clk (posedge). Reset: rst (asynchronous, active-high). Logic: sequential register with write enable.

    // On reset assertion, data_out is driven to RESET_VALUE (0) on the next clock.
    reset_clears_next: assert property (
        @(posedge clk) rst |=> (data_out == 8'h00)
    );

// While reset is held high across consecutive clocks, data_out remains 0.
    reset_holds_zero: assert property (
        @(posedge clk) (rst && $past(rst)) |-> (data_out == 8'h00)
    );

// With we=0, data_out holds its previous value on the next clock.
    hold_when_we_low: assert property (
        @(posedge clk) disable iff (rst) (!we) |=> (data_out == $past(data_out))
    );

// With we=1, data_out captures data_in on the next clock.
    capture_when_we_high: assert property (
        @(posedge clk) disable iff (rst) we |=> (data_out == $past(data_in))
    );

// If we=0 in consecutive cycles, data_out is unchanged from the previous cycle.
    stable_when_we_low_consecutive: assert property (
        @(posedge clk) disable iff (rst) (!we)[*2] |-> (data_out == $past(data_out,2))
    );

// If we=1 in consecutive cycles, data_out reflects the earlier data_in.
    stable_when_we_high_consecutive: assert property (
        @(posedge clk) disable iff (rst) we[*2] |-> (data_out == $past(data_in,2))
    );

endmodule
