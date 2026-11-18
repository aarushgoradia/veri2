```systemverilog
module eth_random_sva (
    input logic MTxClk,
    input logic Reset,
    input logic StateJam,
    input logic StateJam_q,
    input [3:0] RetryCnt,
    input [15:0] NibCnt,
    input [9:0] ByteCnt,
    output logic RandomEq0,
    output logic RandomEqByteCnt
);
    // Reset behavior: RandomLatched and x should be zero at reset
    reset_behavior: assert property (
        @(posedge MTxClk) disable iff (!Reset) (RandomLatched == 10'h000 && x == 10'h000)
    );

    // Feedback calculation: Feedback should be the XOR of the 9th and 2nd bits of x
    feedback_calculation: assert property (
        @(posedge MTxClk) disable iff (!Reset) (Feedback == ~(x[2] ^ x[9]))
    );

    // Random bit assignment: Random[0] should be the 0th bit of x
    random_bit_0: assert property (
        @(posedge MTxClk) disable iff (!Reset) (Random[0] == x[0])
    );

    // Random bit assignment: Random[1] should be the 1st bit of x if RetryCnt > 1
    random_bit_1: assert property (
        @(posedge MTxClk) disable iff (!Reset) (Random[1] == (RetryCnt > 1 ? x[1] : 1'b0))
    );

    // Random bit assignment: Random[2] should be the 2nd bit of x if RetryCnt > 2
    random_bit_2: assert property (
        @(posedge MTxClk) disable iff (!Reset) (Random[2] == (RetryCnt > 2 ? x[2] : 1'b0))
    );

    // Random bit assignment: Random[3] should be the 3rd bit of x if RetryCnt > 3
    random_bit_3: assert property (
        @(posedge MTxClk) disable iff (!Reset) (Random[3] == (RetryCnt > 3 ? x[3] : 1'b0))
    );

    // Random bit assignment: Random[4] should be the 4th bit of x if RetryCnt > 4
    random_bit_4: assert property (
        @(posedge MTxClk) disable iff (!Reset) (Random[4] == (RetryCnt > 4 ? x[4] : 1'b0))
    );

    // Random bit assignment: Random[5] should be the 5th bit of x if RetryCnt > 5
    random_bit_5: assert property (
        @(posedge MTxClk) disable iff (!Reset) (Random[5] == (RetryCnt > 5 ? x[5] : 1'b0))
    );

    // Random bit assignment: Random[6] should be the 6th bit of x if RetryCnt > 6
    random_bit_6: assert property (
        @(posedge MTxClk) disable iff (!Reset) (Random[6] == (RetryCnt > 6 ? x[6] : 1'b0))
    );

    // Random bit assignment: Random[7] should be the 7th bit of x if RetryCnt > 7
    random_bit_7: assert property (
        @(posedge MTxClk) disable iff (!Reset) (Random[7] == (RetryCnt > 7 ? x[7] : 1'b0))
    );

    // Random bit assignment: Random[8] should be the 8th bit of x if RetryCnt > 8
    random_bit_8: assert property (
        @(posedge MTxClk) disable iff (!Reset) (Random[8] == (RetryCnt > 8 ? x[8] : 1'b0))
    );

    // Random bit assignment: Random[9] should be the 9th bit of x if RetryCnt > 9
    random_bit_9: assert property (
        @(posedge MTxClk) disable iff (!Reset) (Random[9] == (RetryCnt > 9 ? x[9] : 1'b0))
    );

    // RandomLatched update: RandomLatched should be updated when StateJam and StateJam_q are high
    random_latched_update: assert property (
        @(posedge MTxClk) disable iff (!Reset) (StateJam && StateJam_q |-> RandomLatched == Random)
    );

    // RandomEq0 calculation: RandomEq0 should be true if RandomLatched is zero
    random_eq_0: assert property (
        @(posedge MTxClk) disable iff (!Reset) (RandomEq0 == (RandomLatched == 10'h0))
    );

    // RandomEqByteCnt calculation: RandomEqByteCnt should be true if ByteCnt matches RandomLatched and NibCnt[6:0] is all ones
    random_eq_byte_cnt: assert property (
        @(posedge MTxClk) disable iff (!Reset) (RandomEqByteCnt == (ByteCnt[9:0] == RandomLatched && (&NibCnt[6:0])))
    );
endmodule
```