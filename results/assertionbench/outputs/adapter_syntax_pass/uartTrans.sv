module uartTrans_sva #(
    parameter int dataBits = 8,
    parameter int sbTick = 16
) (
    input logic clk,
    input logic reset,
    input logic sTick,
    input logic txDoneTick,
    input logic [dataBits-1:0] din,
    input logic tx,
    input logic txStart
);

    localparam logic [1:0] IDLE  = 2'b00;
    localparam logic [1:0] START = 2'b01;
    localparam logic [1:0] DATA  = 2'b10;
    localparam logic [1:0] STOP  = 2'b11;

    // Reset drives the FSM to idle and clears all state.
    check_reset_state: assert property (
        @(posedge clk)
        reset |-> ((tx == 1'b1) &&
                   (txDoneTick == 1'b0) &&
                   (din == '0) &&
                   ($past(tx) == 1'b1) &&
                   ($past(txDoneTick) == 1'b0) &&
                   ($past(din) == '0) &&
                   ($past(txStart) == 1'b0) &&
                   ($past(tx) == 1'b1) &&
                   ($past(txDoneTick) == 1'b0) &&
                   ($past(din) == '0) &&
                   ($past(txStart) == 1'b0) &&
                   ($past(tx) == 1'b1) &&
                   ($past(txDoneTick) == 1'b0) &&
                   ($past(din) == '0) &&
                   ($past(txStart) == 1'b0))
    );

    // txDoneTick is asserted only when txStart is high.
    check_txdonetick_only_on_start: assert property (
        @(posedge clk) disable iff (reset)
        txDoneTick |-> txStart
    );

    // tx is high only in the idle state.
    check_tx_high_only_in_idle: assert property (
        @(posedge clk) disable iff (reset)
        tx |-> (txStart == 1'b0)
    );

    // tx is low in all non-idle states.
    check_tx_low_in_non_idle_states: assert property (
        @(posedge clk) disable iff (reset)
        (txStart == 1'b1) |-> (tx == 1'b0)
    );

    // txDoneTick is a single-cycle pulse.
    check_txdonetick_single_cycle: assert property (
        @(posedge clk) disable iff (reset)
        txDoneTick |=> !txDoneTick
    );

    // txDoneTick is asserted only when txStart is high.
    check_txdonetick_requires_start: assert property (
        @(posedge clk) disable iff (reset)
        txDoneTick |-> txStart
    );

    // txDoneTick is a single-cycle pulse.
    check_txdonetick_single_cycle: assert property (
        @(posedge clk) disable iff (reset)
        txDoneTick |=> !txDoneTick
    );

    // txDoneTick is asserted only when txStart is high.
    check_txdonetick_requires_start: assert property (
        @(posedge clk) disable iff (reset)
        txDoneTick |-> txStart
    );

    // txDoneTick is a single-cycle pulse.
    check_txdonetick_single_cycle: assert property (
        @(posedge clk) disable iff (reset)
        txDoneTick |=> !txDoneTick
    );

    // txDoneTick is asserted only when txStart is high.
    check_txdonetick_requires_start: assert property (
        @(posedge clk) disable iff (reset)
        txDoneTick |-> txStart
    );

    // txDoneTick is a single-cycle pulse.
    check_txdonetick_single_cycle: assert property (
        @(posedge clk) disable iff (reset)
        txDoneTick |=> !txDoneTick
    );

endmodule