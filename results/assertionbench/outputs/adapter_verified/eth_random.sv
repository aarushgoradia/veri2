module eth_random_sva (
    input logic MTxClk,
    input logic Reset,
    input logic StateJam,
    input logic StateJam_q,
    input logic [3:0] RetryCnt,
    input logic [15:0] NibCnt,
    input logic [9:0] ByteCnt,
    input logic RandomEq0,
    input logic RandomEqByteCnt
);

// RandomEq0 is high exactly when the latched random value is zero.
    check_random_eq0_definition: assert property (
        @(posedge MTxClk) disable iff (Reset)
        RandomEq0 == (RandomLatched == 10'h0)
    );

// RandomEqByteCnt is high exactly when the latched random value matches ByteCnt[9:0].
    check_random_eq_bytecnt_definition: assert property (
        @(posedge MTxClk) disable iff (Reset)
        RandomEqByteCnt == (RandomLatched == ByteCnt[9:0])
    );

// When StateJam and StateJam_q are high, the next cycle's latched random value equals the current random value.
    check_latch_captures_random_on_statejam: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateJam && StateJam_q) |=> (RandomLatched == $past(RandomLatched))
    );

// When StateJam and StateJam_q are low, the next cycle's latched random value holds its previous value.
    check_latch_holds_when_no_statejam: assert property (
        @(posedge MTxClk) disable iff (Reset)
        !(StateJam && StateJam_q) |=> (RandomLatched == $past(RandomLatched))
    );

// If StateJam and StateJam_q are high for two consecutive cycles, the latched value is stable across those cycles.
    check_latch_stable_across_statejam: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateJam && StateJam_q) ##1 (StateJam && StateJam_q) |-> (RandomLatched == $past(RandomLatched,2))
    );

// If StateJam and StateJam_q are low for two consecutive cycles, the latched value is stable across those cycles.
    check_latch_stable_across_no_statejam: assert property (
        @(posedge MTxClk) disable iff (Reset)
        !(StateJam && StateJam_q) ##1 !(StateJam && StateJam_q) |-> (RandomLatched == $past(RandomLatched,2))
    );

// If StateJam and StateJam_q are high for three consecutive cycles, the latched value is stable across those cycles.
    check_latch_stable_across_three_statejam: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateJam && StateJam_q) ##1 (StateJam && StateJam_q) ##1 (StateJam && StateJam_q) |-> (RandomLatched == $past(RandomLatched,3))
    );

// If StateJam and StateJam_q are low for three consecutive cycles, the latched value is stable across those cycles.
    check_latch_stable_across_three_no_statejam: assert property (
        @(posedge MTxClk) disable iff (Reset)
        !(StateJam && StateJam_q) ##1 !(StateJam && StateJam_q) ##1 !(StateJam && StateJam_q) |-> (RandomLatched == $past(RandomLatched,3))
    );

endmodule
