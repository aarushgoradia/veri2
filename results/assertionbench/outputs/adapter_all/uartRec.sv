module uartRec_sva (
    input logic clk,
    input logic reset,
    input logic sTick,
    input logic rx,
    input logic rxDoneTick,
    input logic [7:0] dOut,
    input logic [1:0] stateReg,
    input logic [3:0] sReg,
    input logic [2:0] nReg,
    input logic [7:0] bReg
);
    // Reset drives stateReg, sReg, bReg, nReg to 0 and rxDoneTick low.
    reset_state_and_regs: assert property (
        @(posedge clk) reset |-> (stateReg == 2'b00) && (sReg == 4'd0) && (bReg == 8'h00) && (nReg == 3'd0) && (rxDoneTick == 1'b0)
    );

    // rxDoneTick can be high only in stop state.
    rxDoneTick_implies_stop_state: assert property (
        @(posedge clk) disable iff (reset) rxDoneTick |-> (stateReg == 2'b11)
    );

    // In idle, rx high causes start state and resets sReg.
    idle_start_on_rx: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b00 && rx) |-> (stateReg == 2'b01) && (sReg == 4'd0)
    );

    // In idle, rx low holds state and registers.
    idle_hold_when_rx_low: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b00 && !rx) |-> (stateReg == 2'b00) && (sReg == $past(sReg)) && (bReg == $past(bReg)) && (nReg == $past(nReg))
    );

    // In start, sTick at sReg==7 moves to data state, resets sReg and nReg.
    start_to_data_on_sTick_at_7: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b01 && sTick && (sReg == 4'd7)) |-> (stateReg == 2'b10) && (sReg == 4'd0) && (nReg == 3'd0)
    );

    // In start, sTick at non-7 increments sReg.
    start_increment_on_sTick_not_7: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b01 && sTick && (sReg != 4'd7)) |-> (stateReg == 2'b01) && (sReg == $past(sReg) + 4'd1) && (nReg == $past(nReg))
    );

    // In start, without sTick holds state and registers.
    start_hold_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b01 && !sTick) |-> (stateReg == 2'b01) && (sReg == $past(sReg)) && (bReg == $past(bReg)) && (nReg == $past(nReg))
    );

    // In data, sTick at sReg==15 shifts rx into bReg[7:1], increments nReg, and holds sReg.
    data_shift_and_inc_n_on_sTick_at_15: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10 && sTick && (sReg == 4'd15)) |-> (stateReg == 2'b10) && (sReg == 4'd15) && (bReg == { $past(rx), $past(bReg[7:1]) }) && (nReg == $past(nReg) + 3'd1)
    );

    // In data, sTick at non-15 increments sReg.
    data_increment_on_sTick_not_15: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10 && sTick && (sReg != 4'd15)) |-> (stateReg == 2'b10) && (sReg == $past(sReg) + 4'd1) && (bReg == $past(bReg)) && (nReg == $past(nReg))
    );

    // In data, without sTick holds state and registers.
    data_hold_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10 && !sTick) |-> (stateReg == 2'b10) && (sReg == $past(sReg)) && (bReg == $past(bReg)) && (nReg == $past(nReg))
    );

    // In stop, sTick at sReg==(sbTick-1) raises rxDoneTick, goes to idle, and holds bReg.
    stop_done_on_sTick_at_sbTick_minus_1: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b11 && sTick && (sReg == ($past(sbTick) - 4'd1))) |-> (stateReg == 2'b00) && (sReg == 4'd0) && (bReg == $past(bReg)) && (nReg == $past(nReg)) && (rxDoneTick == 1'b1)
    );

    // In stop, sTick at non-(sbTick-1) increments sReg.
    stop_increment_on_sTick_not_sbTick_minus_1: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b11 && sTick && (sReg != ($past(sbTick) - 4'd1))) |-> (stateReg == 2'b11) && (sReg == $past(sReg) + 4'd1) && (bReg == $past(bReg)) && (nReg == $past(nReg))
    );

    // In stop, without sTick holds state and registers.
    stop_hold_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b11 && !sTick) |-> (stateReg == 2'b11) && (sReg == $past(sReg)) && (bReg == $past(bReg)) && (nReg == $past(nReg))
    );

    // dOut always mirrors bReg.
    dOut_matches_bReg: assert property (
        @(posedge clk) disable iff (reset) (dOut == bReg)
    );

    // rxDoneTick is a single-cycle pulse.
    rxDoneTick_single_cycle: assert property (
        @(posedge clk) disable iff (reset) rxDoneTick |-> ##1 !rxDoneTick
    );

    // rxDoneTick implies data state and nReg==(dataBits-1).
    rxDoneTick_implies_data_and_n_max: assert property (
        @(posedge clk) disable iff (reset) rxDoneTick |-> (stateReg == 2'b10) && (nReg == ($past(dataBits) - 3'd1))
    );

    // In data, nReg increments only when sTick at sReg==15.
    data_nReg_increment_only_on_sTick_at_15: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10) |-> (nReg == ($past(nReg) + 3'd1)) == ($past(sTick) && ($past(sReg) == 4'd15))
    );

    // In data, nReg holds when sTick at non-15 or without sTick.
    data_nReg_hold_when_not_at_15: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10) |-> (nReg == $past(nReg)) == ((!($past(sTick) && ($past(sReg) == 4'd15))) && !($past(sTick)))
    );

    // In data, bReg shifts on sTick at sReg==15 and holds otherwise.
    data_bReg_shifts_on_sTick_at_15: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10) |-> (bReg == $past(bReg)) == ((!($past(sTick) && ($past(sReg) == 4'd15))) && $past(sTick))
    );

    // In data, sReg holds when sTick at non-15 or without sTick.
    data_sReg_hold_when_not_at_15: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10) |-> (sReg == $past(sReg)) == ((!($past(sTick) && ($past(sReg) == 4'd15))) && !($past(sTick)))
    );

    // In data, sReg increments on sTick at sReg==15.
    data_sReg_increment_on_sTick_at_15: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10) |-> (sReg == $past(sReg) + 4'd1) == ($past(sTick) && ($past(sReg) == 4'd15))
    );

    // In data, sReg holds when not at 15 and without sTick.
    data_sReg_hold_when_not_at_15_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10) |-> (sReg == $past(sReg)) == ((!($past(sTick) && ($past(sReg) == 4'd15))) && !($past(sTick)))
    );

    // In data, bReg holds when not at 15 and without sTick.
    data_bReg_hold_when_not_at_15_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10) |-> (bReg == $past(bReg)) == ((!($past(sTick) && ($past(sReg) == 4'd15))) && !($past(sTick)))
    );

    // In data, nReg holds when not at 15 and without sTick.
    data_nReg_hold_when_not_at_15_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10) |-> (nReg == $past(nReg)) == ((!($past(sTick) && ($past(sReg) == 4'd15))) && !($past(sTick)))
    );

    // In start, sReg holds when not at 7 and without sTick.
    start_sReg_hold_when_not_at_7_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b01) |-> (sReg == $past(sReg)) == ((!($past(sTick) && ($past(sReg) == 4'd7))) && !($past(sTick)))
    );

    // In start, sReg increments when sTick at sReg==7.
    start_sReg_increment_on_sTick_at_7: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b01) |-> (sReg == $past(sReg) + 4'd1) == ($past(sTick) && ($past(sReg) == 4'd7))
    );

    // In start, sReg holds when not at 7 and without sTick.
    start_sReg_hold_when_not_at_7_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b01) |-> (sReg == $past(sReg)) == ((!($past(sTick) && ($past(sReg) == 4'd7))) && !($past(sTick)))
    );

    // In start, nReg holds when not at 7 and without sTick.
    start_nReg_hold_when_not_at_7_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b01) |-> (nReg == $past(nReg)) == ((!($past(sTick) && ($past(sReg) == 4'd7))) && !($past(sTick)))
    );

    // In stop, sReg holds when not at (sbTick-1) and without sTick.
    stop_sReg_hold_when_not_at_sbTick_minus_1_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b11) |-> (sReg == $past(sReg)) == ((!($past(sTick) && ($past(sReg) == ($past(sbTick) - 4'd1)))) && !($past(sTick)))
    );

    // In stop, sReg increments when sTick at sReg==(sbTick-1).
    stop_sReg_increment_on_sTick_at_sbTick_minus_1: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b11) |-> (sReg == $past(sReg) + 4'd1) == ($past(sTick) && ($past(sReg) == ($past(sbTick) - 4'd1)))
    );

    // In stop, sReg holds when not at (sbTick-1) and without sTick.
    stop_sReg_hold_when_not_at_sbTick_minus_1_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b11) |-> (sReg == $past(sReg)) == ((!($past(sTick) && ($past(sReg) == ($past(sbTick) - 4'd1)))) && !($past(sTick)))
    );

    // In stop, bReg holds when not at (sbTick-1) and without sTick.
    stop_bReg_hold_when_not_at_sbTick_minus_1_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b11) |-> (bReg == $past(bReg)) == ((!($past(sTick) && ($past(sReg) == ($past(sbTick) - 4'd1)))) && !($past(sTick)))
    );

    // In stop, nReg holds when not at (sbTick-1) and without sTick.
    stop_nReg_hold_when_not_at_sbTick_minus_1_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b11) |-> (nReg == $past(nReg)) == ((!($past(sTick) && ($past(sReg) == ($past(sbTick) - 4'd1)))) && !($past(sTick)))
    );

    // In idle, sReg holds when without sTick.
    idle_sReg_hold_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b00) |-> (sReg == $past(sReg)) == (!($past(sTick)))
    );

    // In idle, bReg holds when without sTick.
    idle_bReg_hold_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b00) |-> (bReg == $past(bReg)) == (!($past(sTick)))
    );

    // In idle, nReg holds when without sTick.
    idle_nReg_hold_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b00) |-> (nReg == $past(nReg)) == (!($past(sTick)))
    );

    // In idle, state holds when without sTick.
    idle_state_hold_without_sTick: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b00) |-> (stateReg == $past(stateReg)) == (!($past(sTick)))
    );

    // In idle, rxDoneTick is low.
    idle_rxDoneTick_low: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b00) |-> (rxDoneTick == 1'b0)
    );

    // In data, rxDoneTick is low.
    data_rxDoneTick_low: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10) |-> (rxDoneTick == 1'b0)
    );

    // In start, rxDoneTick is low.
    start_rxDoneTick_low: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b01) |-> (rxDoneTick == 1'b0)
    );

    // In stop, rxDoneTick is low when not at (sbTick-1).
    stop_rxDoneTick_low_when_not_at_sbTick_minus_1: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b11 && (sReg != ($past(sbTick) - 4'd1))) |-> (rxDoneTick == 1'b0)
    );

    // In stop, rxDoneTick is high when at (sbTick-1).
    stop_rxDoneTick_high_when_at_sbTick_minus_1: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b11 && (sReg == ($past(sbTick) - 4'd1))) |-> (rxDoneTick == 1'b1)
    );

    // In stop, rxDoneTick is a single-cycle pulse.
    stop_rxDoneTick_single_cycle: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b11 && (sReg == ($past(sbTick) - 4'd1))) |-> (rxDoneTick == 1'b1) ##1 (stateReg == 2'b11) && (sReg == ($past(sbTick) - 4'd1)) && (rxDoneTick == 1'b0)
    );

    // In data, rxDoneTick is low when nReg!=(dataBits-1).
    data_rxDoneTick_low_when_n_not_max: assert property (
        @(posedge clk) disable iff (reset) (stateReg == 2'b10 && (nReg != ($past(dataBits) - 3'd1))) |-> (rxDoneTick == 1'b0)
    );

    // In data, rxDoneTick is high when nReg==(dataBits-1).
    data_rxD