module uartTrans_sva (
    input logic        clk,
    input logic        reset,
    input logic        sTick,
    input logic        txDoneTick,
    input logic [7:0]  din,
    input logic        tx,
    input logic        txStart,
    input logic [1:0]  stateReg,
    input logic [3:0]  sReg,
    input logic [2:0]  nReg,
    input logic [7:0]  bReg,
    input logic        txReg
);

    localparam [1:0] idle  = 2'b00;
    localparam [1:0] start = 2'b01;
    localparam [1:0] data  = 2'b10;
    localparam [1:0] stop  = 2'b11;

    // Reset drives the FSM to idle and clears all state.
    check_reset_state: assert property (
        @(posedge clk) reset |-> (stateReg == idle) &&
                                (sReg == 4'd0) &&
                                (nReg == 3'd0) &&
                                (bReg == 8'h00) &&
                                (txReg == 1'b1)
    );

    // Reset clears the TX done pulse.
    check_reset_txdonetick: assert property (
        @(posedge clk) reset |-> (txDoneTick == 1'b0)
    );

    // txReg mirrors the registered tx output.
    check_tx_reg_matches_tx: assert property (
        @(posedge clk) disable iff (reset) txReg == tx
    );

    // txDoneTick is asserted only when txStart is high in idle.
    check_txdonetick_idle_only: assert property (
        @(posedge clk) disable iff (reset) txDoneTick |-> (stateReg == idle && txStart)
    );

    // txDoneTick is a single-cycle pulse.
    check_txdonetick_single_cycle: assert property (
        @(posedge clk) disable iff (reset) txDoneTick |-> !txDoneTick
    );

    // In idle, tx is high and txDoneTick reflects txStart.
    check_idle_behavior: assert property (
        @(posedge clk) disable iff (reset) (stateReg == idle) |-> (txReg == 1'b1) &&
                                                                 (txDoneTick == txStart)
    );

    // In start, tx is low and the first data bit is loaded into bReg.
    check_start_behavior: assert property (
        @(posedge clk) disable iff (reset) (stateReg == start) |-> (txReg == 1'b0) &&
                                                                 (bReg == din) &&
                                                                 (sReg == 4'd0) &&
                                                                 (nReg == 3'd0)
    );

    // In data, tx reflects the current bit from bReg.
    check_data_behavior: assert property (
        @(posedge clk) disable iff (reset) (stateReg == data) |-> (txReg == bReg[0]) &&
                                                                 (sReg == ($past(sReg) + 4'd1))
    );

    // In data, the bit register shifts right on each sample.
    check_data_bit_shift: assert property (
        @(posedge clk) disable iff (reset) (stateReg == data) |-> (bReg == ($past(bReg) >> 1))
    );

    // In data, the bit counter wraps and the next state is stop when all bits are sent.
    check_data_done_to_stop: assert property (
        @(posedge clk) disable iff (reset) (stateReg == data && sReg == 4'd15 && nReg == 3'd7) |-> (stateReg == stop) &&
                                                                 (sReg == 4'd0) &&
                                                                 (nReg == 3'd0)
    );

    // In data, the bit counter increments until the last bit is sent.
    check_data_bit_count: assert property (
        @(posedge clk) disable iff (reset) (stateReg == data && sReg != 4'd15 && nReg != 3'd7) |-> (stateReg == data) &&
                                                                 (sReg == ($past(sReg) + 4'd1)) &&
                                                                 (nReg == ($past(nReg) + 3'd1))
    );

    // In stop, tx is high and the stop-bit counter holds until the final tick.
    check_stop_behavior: assert property (
        @(posedge clk) disable iff (reset) (stateReg == stop) |-> (txReg == 1'b1) &&
                                                                 (sReg == ($past(sReg) + 4'd1))
    );

    // In stop, the stop-bit counter wraps and the FSM returns to idle on the final tick.
    check_stop_done_to_idle: assert property (
        @(posedge clk) disable iff (reset) (stateReg == stop && sReg == 4'd15) |-> (stateReg == idle) &&
                                                                 (sReg == 4'd0)
    );

endmodule