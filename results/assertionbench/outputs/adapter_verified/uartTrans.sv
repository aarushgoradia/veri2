module uartTrans_sva (
    input logic clk,
    input logic reset,
    input logic sTick,
    input logic txDoneTick,
    input logic [7:0] din,
    input logic tx,
    input logic txStart
);

// Reset drives tx high and txDoneTick low.
    check_reset_state: assert property (
        @(posedge clk) reset |-> (tx == 1'b1) && (txDoneTick == 1'b0)
    );

// txStart high in idle drives tx high and generates a txDoneTick on the next clock.
    check_txstart_idle: assert property (
        @(posedge clk) disable iff (reset)
        (txStart && (stateReg == idle)) |=> (tx == 1'b1) && (txDoneTick == 1'b1)
    );

// txStart high in start drives tx low and holds txDoneTick low.
    check_txstart_start: assert property (
        @(posedge clk) disable iff (reset)
        (txStart && (stateReg == start)) |=> (tx == 1'b0) && (txDoneTick == 1'b0)
    );

// txStart high in data drives tx low and holds txDoneTick low.
    check_txstart_data: assert property (
        @(posedge clk) disable iff (reset)
        (txStart && (stateReg == data)) |=> (tx == 1'b0) && (txDoneTick == 1'b0)
    );

// txStart high in stop drives tx high and holds txDoneTick low.
    check_txstart_stop: assert property (
        @(posedge clk) disable iff (reset)
        (txStart && (stateReg == stop)) |=> (tx == 1'b1) && (txDoneTick == 1'b0)
    );

// In start, sTick with sReg==15 transitions to data.
    check_start_to_data_on_s15: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == start) && sTick && (sReg == 4'd15)) |=> (stateReg == data) && (sReg == 4'd0)
    );

// In start, sTick below 15 increments sReg.
    check_start_increment_sreg: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == start) && sTick && (sReg != 4'd15)) |=> (stateReg == start) && (sReg == ($past(sReg) + 4'd1))
    );

// In start, sTick low holds sReg.
    check_start_hold_sreg: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == start) && !sTick) |=> (stateReg == start) && (sReg == $past(sReg))
    );

// In data, sTick with sReg==15 and nReg==(dataBits-1) transitions to stop.
    check_data_to_stop_on_nmax: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == data) && sTick && (sReg == 4'd15) && (nReg == (dataBits - 3'd1))) |=> (stateReg == stop) && (sReg == 4'd0) && (nReg == 3'd0)
    );

// In data, sTick with sReg==15 and nReg!=(dataBits-1) increments nReg.
    check_data_increment_nreg: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == data) && sTick && (sReg == 4'd15) && (nReg != (dataBits - 3'd1))) |=> (stateReg == data) && (sReg == 4'd0) && (nReg == ($past(nReg) + 3'd1))
    );

// In data, sTick below 15 increments sReg.
    check_data_increment_sreg: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == data) && sTick && (sReg != 4'd15)) |=> (stateReg == data) && (sReg == ($past(sReg) + 4'd1))
    );

// In data, sTick low holds sReg.
    check_data_hold_sreg: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == data) && !sTick) |=> (stateReg == data) && (sReg == $past(sReg))
    );

// In stop, sTick with sReg==(sbTick-1) transitions to idle.
    check_stop_to_idle_on_smax: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == stop) && sTick && (sReg == (sbTick - 4'd1))) |=> (stateReg == idle) && (sReg == 4'd0)
    );

// In stop, sTick below (sbTick-1) increments sReg.
    check_stop_increment_sreg: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == stop) && sTick && (sReg != (sbTick - 4'd1))) |=> (stateReg == stop) && (sReg == ($past(sReg) + 4'd1))
    );

// In stop, sTick low holds sReg.
    check_stop_hold_sreg: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == stop) && !sTick) |=> (stateReg == stop) && (sReg == $past(sReg))
    );

endmodule
