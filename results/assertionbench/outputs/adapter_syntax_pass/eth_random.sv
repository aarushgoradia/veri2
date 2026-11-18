module eth_random_sva (
    input logic MTxClk,
    input logic Reset,
    input logic StateJam,
    input logic StateJam_q,
    input logic [3:0] RetryCnt,
    input logic [15:0] NibCnt,
    input logic [9:0] ByteCnt,
    input logic RandomEq0,
    input logic RandomEqByteCnt,
    input logic Feedback,
    input logic [9:0] x,
    input logic [9:0] Random,
    input logic [9:0] RandomLatched
);

    // Reset clears the internal shift register.
    check_x_reset: assert property (
        @(posedge MTxClk) Reset |-> (x == 10'h000)
    );

    // Reset clears the latched random value.
    check_random_latched_reset: assert property (
        @(posedge MTxClk) Reset |-> (RandomLatched == 10'h000)
    );

    // Feedback is the XOR of the two MSB taps.
    check_feedback_definition: assert property (
        @(posedge MTxClk) disable iff (Reset)
        Feedback == ~(x[2] ^ x[9])
    );

    // Random[0] is the tapped bit x[0].
    check_random_bit0: assert property (
        @(posedge MTxClk) disable iff (Reset)
        Random[0] == x[0]
    );

    // Random[1] is x[1] when RetryCnt is greater than 1.
    check_random_bit1: assert property (
        @(posedge MTxClk) disable iff (Reset)
        Random[1] == ((RetryCnt > 4'd1) ? x[1] : 1'b0)
    );

    // Random[2] is x[2] when RetryCnt is greater than 2.
    check_random_bit2: assert property (
        @(posedge MTxClk) disable iff (Reset)
        Random[2] == ((RetryCnt > 4'd2) ? x[2] : 1'b0)
    );

    // Random[3] is x[3] when RetryCnt is greater than 3.
    check_random_bit3: assert property (
        @(posedge MTxClk) disable iff (Reset)
        Random[3] == ((RetryCnt > 4'd3) ? x[3] : 1'b0)
    );

    // Random[4] is x[4] when RetryCnt is greater than 4.
    check_random_bit4: assert property (
        @(posedge MTxClk) disable iff (Reset)
        Random[4] == ((RetryCnt > 4'd4) ? x[4] : 1'b0)
    );

    // Random[5] is x[5] when RetryCnt is greater than 5.
    check_random_bit5: assert property (
        @(posedge MTxClk) disable iff (Reset)
        Random[5] == ((RetryCnt > 4'd5) ? x[5] : 1'b0)
    );

    // Random[6] is x[6] when RetryCnt is greater than 6.
    check_random_bit6: assert property (
        @(posedge MTxClk) disable iff (Reset)
        Random[6] == ((RetryCnt > 4'd6) ? x[6] : 1'b0)
    );

    // Random[7] is x[7] when RetryCnt is greater than 7.
    check_random_bit7: assert property (
        @(posedge MTxClk) disable iff (Reset)
        Random[7] == ((RetryCnt > 4'd7) ? x[7] : 1'b0)
    );

    // Random[8] is x[8] when RetryCnt is greater than 8.
    check_random_bit8: assert property (
        @(posedge MTxClk) disable iff (Reset)
        Random[8] == ((RetryCnt > 4'd8) ? x[8] : 1'b0)
    );

    // Random[9] is x[9] when RetryCnt is greater than 9.
    check_random_bit9: assert property (
        @(posedge MTxClk) disable iff (Reset)
        Random[9] == ((RetryCnt > 4'd9) ? x[9] : 1'b0)
    );

    // Random is always a subset of the tapped bits.
    check_random_subset_of_x: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (Random[0] == x[0]) &&
        (Random[1] == ((RetryCnt > 4'd1) ? x[1] : 1'b0)) &&
        (Random[2] == ((RetryCnt > 4'd2) ? x[2] : 1'b0)) &&
        (Random[3] == ((RetryCnt > 4'd3) ? x[3] : 1'b0)) &&
        (Random[4] == ((RetryCnt > 4'd4) ? x[4] : 1'b0)) &&
        (Random[5] == ((RetryCnt > 4'd5) ? x[5] : 1'b0)) &&
        (Random[6] == ((RetryCnt > 4'd6) ? x[6] : 1'b0)) &&
        (Random[7] == ((RetryCnt > 4'd7) ? x[7] : 1'b0)) &&
        (Random[8] == ((RetryCnt > 4'd8) ? x[8] : 1'b0)) &&
        (Random[9] == ((RetryCnt > 4'd9) ? x[9] : 1'b0))
    );

    // RandomLatched captures Random when StateJam and StateJam_q are high.
    check_random_latched_capture: assert property (
        @(posedge MTxClk) disable iff (Reset)
        (StateJam && StateJam_q) |=> (RandomLatched == $past(Random))
    );

    // RandomLatched holds its value when the capture condition is not met.
    check_random_latched_hold: assert property (
        @(posedge MTxClk) disable iff (Reset)
        !(StateJam && StateJam_q) |=> (RandomLatched == $past(RandomLatched))
    );

    // RandomEq0 is high when the latched random value is zero.
    check_random_eq0_definition: assert property (
        @(posedge MTxClk) disable iff (Reset)
        RandomEq0 == (RandomLatched == 10'h000)
    );

    // RandomEqByteCnt is high when ByteCnt matches the latched random value.
    check_random_eq_bytecnt_definition: assert property (
        @(posedge MTxClk) disable iff (Reset)
        RandomEqByteCnt == (ByteCnt[9:0] == (RandomLatched & {7'b0, ~NibCnt[6:0]}))
    );

endmodule