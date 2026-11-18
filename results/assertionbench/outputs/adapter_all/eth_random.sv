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

    // Reset clears the random latch on the next clock.
    check_reset_clears_random_latched: assert property (
        @(posedge MTxClk) Reset |=> (RandomLatched == 10'h000)
    );

    // StateJam_q high with StateJam low does not update the random latch.
    check_statejamq_only_does_not_update: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (!StateJam && StateJam_q) |=> (RandomLatched == $past(RandomLatched))
    );

    // StateJam low with StateJam_q low does not update the random latch.
    check_statejam_only_does_not_update: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateJam && !StateJam_q) |=> (RandomLatched == $past(RandomLatched))
    );

    // StateJam low with StateJam_q low holds the random latch value.
    check_no_state_update_holds_latched_value: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (!StateJam && !StateJam_q) |=> (RandomLatched == $past(RandomLatched))
    );

    // StateJam high with StateJam_q high updates the random latch.
    check_statejam_and_statejamq_update_latched_value: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateJam && StateJam_q) |=> (RandomLatched == $past(Random))
    );

    // RandomEq0 reflects whether the latched random value is zero.
    check_random_eq0_matches_latched_value: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (RandomEq0 == (RandomLatched == 10'h000))
    );

    // RandomEqByteCnt reflects whether the latched random value matches ByteCnt.
    check_random_eq_bytecnt_matches_latched_value: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (RandomEqByteCnt == (ByteCnt[9:0] == RandomLatched))
    );

    // RandomEqByteCnt can only be high when the latched random value is zero.
    check_random_eq_bytecnt_implies_random_eq0: assert property (
        @(posedge MTxClk) disable iff (Reset)
        RandomEqByteCnt |-> RandomEq0
    );

    // RandomEq0 and RandomEqByteCnt are never asserted together.
    check_random_outputs_mutually_exclusive: assert property (
        @(posedge MTxClk) disable iff (Reset)
        !(RandomEq0 && RandomEqByteCnt)
    );

endmodule