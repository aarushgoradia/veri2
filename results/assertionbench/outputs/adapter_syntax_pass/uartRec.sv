module uartRec_sva #(
    parameter int dataBits = 8,
    parameter int sbTick = 16
) (
    input logic clk,
    input logic reset,
    input logic sTick,
    input logic rx,
    input logic rxDoneTick,
    input logic [dataBits-1:0] dOut,
    input logic [1:0] stateReg,
    input logic [3:0] sReg,
    input logic [2:0] nReg,
    input logic [7:0] bReg
);

    localparam logic [1:0] idle  = 2'b00;
    localparam logic [1:0] start = 2'b01;
    localparam logic [1:0] data  = 2'b10;
    localparam logic [1:0] stop  = 2'b11;

    // Reset clears the state and clears the output.
    check_reset_state_and_output: assert property (
        @(posedge clk)
        reset |-> ((stateReg == idle) && (sReg == 4'd0) && (nReg == 3'd0) && (bReg == 8'h00) && (dOut == 8'h00) && (rxDoneTick == 1'b0))
    );

    // Idle waits for rx to be low.
    check_idle_wait_for_rx: assert property (
        @(posedge clk) disable iff (reset)
        (stateReg == idle) |-> (rx == 1'b0)
    );

    // Idle starts the start state on rx low.
    check_idle_starts_start: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == idle) && (rx == 1'b0)) |-> ((stateReg == start) && (sReg == 4'd0) && (nReg == 3'd0))
    );

    // Start increments the sample counter until bit 7.
    check_start_samples_to_bit7: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == start) && (sReg < 4'd7)) |-> ((stateReg == start) && (sReg == ($past(sReg) + 4'd1)) && (nReg == 3'd0))
    );

    // Start moves to data on bit 7 with sTick high.
    check_start_moves_to_data_on_bit7: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == start) && (sReg == 4'd7) && sTick) |-> ((stateReg == data) && (sReg == 4'd0) && (nReg == 3'd0))
    );

    // Data increments the sample counter until bit 15.
    check_data_samples_to_bit15: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == data) && (sReg < 4'd15)) |-> ((stateReg == data) && (sReg == ($past(sReg) + 4'd1)) && (nReg == $past(nReg)))
    );

    // Data shifts in rx into bReg on bit 15.
    check_data_shifts_received_data: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == data) && (sReg == 4'd15)) |-> ((stateReg == data) && (sReg == 4'd0) && (bReg == { $past(rx), $past(bReg[7:1]) }) && (nReg == ($past(nReg) + 3'd1)))
    );

    // Data moves to stop when all data bits are received.
    check_data_moves_to_stop_on_complete: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == data) && (sReg == 4'd15) && (nReg == (dataBits - 3'd1))) |-> ((stateReg == stop) && (sReg == 4'd0))
    );

    // Stop increments the sample counter until the stop-bit tick.
    check_stop_samples_to_stop_tick: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == stop) && (sReg < (sbTick - 4'd1))) |-> ((stateReg == stop) && (sReg == ($past(sReg) + 4'd1)))
    );

    // Stop returns to idle on the stop-bit tick.
    check_stop_returns_to_idle_on_tick: assert property (
        @(posedge clk) disable iff (reset)
        ((stateReg == stop) && (sReg == (sbTick - 4'd1))) |-> ((stateReg == idle) && (sReg == 4'd0) && (rxDoneTick == 1'b1))
    );

    // dOut always mirrors bReg.
    check_dout_matches_breg: assert property (
        @(posedge clk) disable iff (reset)
        (dOut == bReg)
    );

    // rxDoneTick is asserted only in the stop state.
    check_rxdonetick_only_in_stop: assert property (
        @(posedge clk) disable iff (reset)
        (rxDoneTick == 1'b1) |-> (stateReg == stop)
    );

endmodule