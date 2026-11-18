module uartRec_sva (
    input logic clk,
    input logic reset,
    input logic sTick,
    input logic rx,
    input logic rxDoneTick,
    input logic [7:0] dOut
);

// Reset clears the state machine and output.
    check_reset_clears_state_and_output: assert property (
        @(posedge clk) reset |-> (stateReg == idle) && (sReg == 4'd0) && (bReg == 8'h00) && (nReg == 3'd0) && (dOut == 8'h00) && (rxDoneTick == 1'b0)
    );

// In idle, a low rx advances to start on the next clock.
    check_idle_to_start_on_rx_low: assert property (
        @(posedge clk) disable iff (reset) (stateReg == idle) && !rx |=> (stateReg == start) && (sReg == 4'd0) && (bReg == 8'h00) && (nReg == 3'd0) && (dOut == 8'h00) && (rxDoneTick == 1'b0)
    );

// In idle, a high rx keeps the state idle.
    check_idle_holds_on_rx_high: assert property (
        @(posedge clk) disable iff (reset) (stateReg == idle) && rx |=> (stateReg == idle) && (sReg == 4'd0) && (bReg == 8'h00) && (nReg == 3'd0) && (dOut == 8'h00) && (rxDoneTick == 1'b0)
    );

// In start, sTick increments sReg up to 7.
    check_start_sincs_when_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == start) && sTick |=> (stateReg == start) && (sReg == ($past(sReg) + 4'd1)) && (bReg == 8'h00) && (nReg == 3'd0) && (dOut == 8'h00) && (rxDoneTick == 1'b0)
    );

// In start, sTick at 7 advances to data.
    check_start_to_data_on_sTick_at_7: assert property (
        @(posedge clk) disable iff (reset) (stateReg == start) && sTick && (sReg == 4'd7) |=> (stateReg == data) && (sReg == 4'd0) && (bReg == 8'h00) && (nReg == 3'd0) && (dOut == 8'h00) && (rxDoneTick == 1'b0)
    );

// In start, no sTick keeps the state and counters.
    check_start_holds_when_no_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == start) && !sTick |=> (stateReg == start) && (sReg == 4'd0) && (bReg == 8'h00) && (nReg == 3'd0) && (dOut == 8'h00) && (rxDoneTick == 1'b0)
    );

// In data, sTick increments sReg up to 15.
    check_data_sincs_when_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == data) && sTick |=> (stateReg == data) && (sReg == ($past(sReg) + 4'd1)) && (bReg == {rx, $past(bReg[7:1])}) && (nReg == $past(nReg)) && (dOut == $past(bReg)) && (rxDoneTick == 1'b0)
    );

// In data, sTick at 15 advances to stop when all bits are received.
    check_data_to_stop_on_sTick_at_15_full: assert property (
        @(posedge clk) disable iff (reset) (stateReg == data) && sTick && (sReg == 4'd15) && (nReg == 3'd7) |=> (stateReg == stop) && (sReg == 4'd0) && (bReg == 8'h00) && (nReg == 3'd0) && (dOut == 8'h00) && (rxDoneTick == 1'b1)
    );

// In data, sTick at 15 holds when not all bits are received.
    check_data_holds_on_sTick_at_15_partial: assert property (
        @(posedge clk) disable iff (reset) (stateReg == data) && sTick && (sReg == 4'd15) && (nReg != 3'd7) |=> (stateReg == data) && (sReg == 4'd0) && (bReg == 8'h00) && (nReg == 3'd0) && (dOut == 8'h00) && (rxDoneTick == 1'b0)
    );

// In data, no sTick keeps the state and counters.
    check_data_holds_when_no_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == data) && !sTick |=> (stateReg == data) && (sReg == 4'd0) && (bReg == 8'h00) && (nReg == 3'd0) && (dOut == 8'h00) && (rxDoneTick == 1'b0)
    );

// In stop, sTick increments sReg up to (sbTick-1).
    check_stop_sincs_when_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == stop) && sTick |=> (stateReg == stop) && (sReg == ($past(sReg) + 4'd1)) && (bReg == 8'h00) && (nReg == 3'd0) && (dOut == 8'h00) && (rxDoneTick == 1'b0)
    );

// In stop, sTick at (sbTick-1) advances to idle and raises rxDoneTick.
    check_stop_to_idle_on_sTick_at_sbTick_minus_1: assert property (
        @(posedge clk) disable iff (reset) (stateReg == stop) && sTick && (sReg == (sbTick - 4'd1)) |=> (stateReg == idle) && (sReg == 4'd0) && (bReg == 8'h00) && (nReg == 3'd0) && (dOut == 8'h00) && (rxDoneTick == 1'b1)
    );

// In stop, no sTick keeps the state and counters.
    check_stop_holds_when_no_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == stop) && !sTick |=> (stateReg == stop) && (sReg == 4'd0) && (bReg == 8'h00) && (nReg == 3'd0) && (dOut == 8'h00) && (rxDoneTick == 1'b0)
    );

endmodule
