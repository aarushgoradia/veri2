module Ramdon_gen_sva (
    input logic Reset,
    input logic Clk,
    input logic Init,
    input logic [3:0] RetryCnt,
    input logic Random_time_meet,
    input logic [9:0] Random_sequence,
    input logic [9:0] Ramdom,
    input logic [9:0] Ramdom_counter,
    input logic [7:0] Slot_time_counter
);

    // Reset clears all registered state and raises Random_time_meet.
    check_reset_state: assert property (
        @(posedge Clk) Reset |-> ((Random_sequence == 10'd0) &&
                                 (Ramdom == 10'd0) &&
                                 (Ramdom_counter == 10'd0) &&
                                 (Slot_time_counter == 8'd0) &&
                                 (Random_time_meet == 1'b1))
    );

    // Random_sequence is the registered feedback shift register value.
    check_random_sequence_update: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> (Random_sequence == {$past(Random_sequence[8:0]), ~($past(Random_sequence[2]) ^ $past(Random_sequence[9]))})
    );

    // Ramdom selects the appropriate truncated Random_sequence bit slice.
    check_ramdom_mapping: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |-> (Ramdom == ((RetryCnt == 4'h0)  ? {9'b0, $past(Random_sequence[0])}  :
                             (RetryCnt == 4'h1)  ? {8'b0, $past(Random_sequence[1:0])}  :
                             (RetryCnt == 4'h2)  ? {7'b0, $past(Random_sequence[2:0])}  :
                             (RetryCnt == 4'h3)  ? {6'b0, $past(Random_sequence[3:0])}  :
                             (RetryCnt == 4'h4)  ? {5'b0, $past(Random_sequence[4:0])}  :
                             (RetryCnt == 4'h5)  ? {4'b0, $past(Random_sequence[5:0])}  :
                             (RetryCnt == 4'h6)  ? {3'b0, $past(Random_sequence[6:0])}  :
                             (RetryCnt == 4'h7)  ? {2'b0, $past(Random_sequence[7:0])}  :
                             (RetryCnt == 4'h8)  ? {1'b0, $past(Random_sequence[8:0])}  :
                             {1'b0, $past(Random_sequence[9:0])}))
    );

    // Slot_time_counter is cleared on Init and increments otherwise.
    check_slot_time_counter_update: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> (Slot_time_counter == ($past(Init) ? 8'd0 : ($past(Slot_time_counter) == 8'd255 ? 8'd0 : $past(Slot_time_counter) + 8'd1)))
    );

    // Ramdom_counter loads Ramdom on Init and decrements on valid slot counts.
    check_ramdom_counter_update: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> (Ramdom_counter == ($past(Init) ? $past(Ramdom) :
                                           ($past(Ramdom_counter) == 10'd0 ? 10'd0 :
                                            ($past(Slot_time_counter) == 8'd255 ? $past(Ramdom_counter) - 10'd1 : $past(Ramdom_counter)))))
    );

    // Random_time_meet is asserted on Init and is cleared when Ramdom_counter reaches zero.
    check_random_time_meet_update: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> (Random_time_meet == ($past(Init) ? 1'b0 :
                                        ($past(Ramdom_counter) == 10'd0 ? 1'b1 : $past(Random_time_meet))))
    );

endmodule