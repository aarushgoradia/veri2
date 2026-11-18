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

    // Reset clears the random sequence register.
    check_random_sequence_reset: assert property (
        @(posedge Clk) Reset |=> (Random_sequence == 10'h000)
    );

    // Reset clears the slot time counter.
    check_slot_time_counter_reset: assert property (
        @(posedge Clk) Reset |=> (Slot_time_counter == 8'h00)
    );

    // Reset clears the random counter.
    check_random_counter_reset: assert property (
        @(posedge Clk) Reset |=> (Ramdom_counter == 10'h000)
    );

    // Reset drives Random_time_meet high.
    check_random_time_meet_reset: assert property (
        @(posedge Clk) Reset |=> (Random_time_meet == 1'b1)
    );

    // The random sequence register shifts in the inverse of bit 2 XOR bit 9.
    check_random_sequence_shift: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> (Random_sequence == {$past(Random_sequence[8:0]), ~($past(Random_sequence[2]) ^ $past(Random_sequence[9]))})
    );

    // Ramdom selects the appropriate truncated random sequence slice.
    check_ramdom_decode: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |-> (Ramdom == (({10{RetryCnt}} & Random_sequence) | {10{~RetryCnt}}))
    );

    // Ramdom_counter loads Ramdom on Init.
    check_random_counter_load: assert property (
        @(posedge Clk) disable iff (Reset)
        Init |=> (Ramdom_counter == $past(Ramdom))
    );

    // Ramdom_counter decrements when the slot counter is 255.
    check_random_counter_decrement: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Init && (Ramdom_counter != 10'h000) && (Slot_time_counter == 8'hFF)) |=> (Ramdom_counter == ($past(Ramdom_counter) - 10'h001))
    );

    // Ramdom_counter holds when the decrement condition is not met.
    check_random_counter_hold: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Init || (Ramdom_counter == 10'h000) || (Slot_time_counter != 8'hFF)) |=> (Ramdom_counter == $past(Ramdom_counter))
    );

    // Random_time_meet clears on Init.
    check_random_time_meet_clear: assert property (
        @(posedge Clk) disable iff (Reset)
        Init |=> (Random_time_meet == 1'b0)
    );

    // Random_time_meet sets when Ramdom_counter reaches zero.
    check_random_time_meet_set: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Init && (Ramdom_counter == 10'h000)) |=> (Random_time_meet == 1'b1)
    );

    // Random_time_meet holds when it is not cleared or set.
    check_random_time_meet_hold: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Init || (Ramdom_counter != 10'h000)) |=> (Random_time_meet == $past(Random_time_meet))
    );

endmodule