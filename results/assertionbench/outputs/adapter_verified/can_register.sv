module can_register_sva (
    input logic [7:0] data_in,
    input logic       we,
    input logic       clk,
    input logic [7:0] data_out
);

// Clock: clk (posedge). No reset in RTL. Logic: sequential register with write enable.

    // When we is HIGH, data_out captures data_in on the next clock.
    check_write_captures_data: assert property (
        @(posedge clk) we |=> (data_out == $past(data_in))
    );

// When we is LOW, data_out holds its previous value on the next clock.
    check_hold_when_write_low: assert property (
        @(posedge clk) !we |=> (data_out == $past(data_out))
    );

// A write followed by another write updates data_out with the second data_in value.
    check_two_writes_update: assert property (
        @(posedge clk) (we ##1 we) |=> (data_out == $past(data_in,2))
    );

// A write followed by a non-write keeps data_out updated with the write data_in value.
    check_write_then_hold: assert property (
        @(posedge clk) (we ##1 !we) |=> (data_out == $past(data_in,2))
    );

// A non-write followed by a write loads data_out with the write data_in value.
    check_hold_then_write: assert property (
        @(posedge clk) (!we ##1 we) |=> (data_out == $past(data_in,2))
    );

// Two non-writes leave data_out unchanged.
    check_two_holds: assert property (
        @(posedge clk) (!we ##1 !we) |=> (data_out == $past(data_out))
    );

endmodule
