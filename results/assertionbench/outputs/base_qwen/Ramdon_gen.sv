```systemverilog
module Ramdon_gen_sva (
    input logic Clk,
    input logic Reset,
    input logic Init,
    input logic [3:0] RetryCnt,
    output logic Random_time_meet
);
    // Random_sequence should be updated on every clock edge
    random_sequence_update: assert property (
        @(posedge Clk) disable iff (!Reset) Random_sequence[9:0] == {Random_sequence[8:0], ~(Random_sequence[2] ^ Random_sequence[9])}
    );

    // Ramdom should be updated based on RetryCnt on every clock edge
    ramdom_update: assert property (
        @(posedge Clk) disable iff (!Reset) Ramdom == case (RetryCnt)
            4'h0: {9'b0, Random_sequence[0]};
            4'h1: {8'b0, Random_sequence[1:0]};
            4'h2: {7'b0, Random_sequence[2:0]};
            4'h3: {6'b0, Random_sequence[3:0]};
            4'h4: {5'b0, Random_sequence[4:0]};
            4'h5: {4'b0, Random_sequence[5:0]};
            4'h6: {3'b0, Random_sequence[6:0]};
            4'h7: {2'b0, Random_sequence[7:0]};
            4'h8: {1'b0, Random_sequence[8:0]};
            4'h9: {Random_sequence[9:0]};
            default: {Random_sequence[9:0]}
        endcase
    );

    // Slot_time_counter should be reset on every clock edge when Init is high
    slot_time_counter_reset: assert property (
        @(posedge Clk) disable iff (!Reset) Init |-> Slot_time_counter == 0
    );

    // Slot_time_counter should increment on every clock edge when Init is low and Random_time_meet is low
    slot_time_counter_increment: assert property (
        @(posedge Clk) disable iff (!Reset) !Init && !Random_time_meet |-> Slot_time_counter == Slot_time_counter + 1
    );

    // Ramdom_counter should be reset on every clock edge when Init is high
    ramdom_counter_reset: assert property (
        @(posedge Clk) disable iff (!Reset) Init |-> Ramdom_counter == Ramdom
    );

    // Ramdom_counter should decrement on every clock edge when Slot_time_counter reaches 255 and Ramdom_counter is not zero
    ramdom_counter_decrement: assert property (
        @(posedge Clk) disable iff (!Reset) Slot_time_counter == 255 && Ramdom_counter != 0 |-> Ramdom_counter == Ramdom_counter - 1
    );

    // Random_time_meet should be reset on every clock edge when Init is high
    random_time_meet_reset: assert property (
        @(posedge Clk) disable iff (!Reset) Init |-> Random_time_meet == 0
    );

    // Random_time_meet should be set to 1 on every clock edge when Ramdom_counter reaches 0
    random_time_meet_set: assert property (
        @(posedge Clk) disable iff (!Reset) Ramdom_counter == 0 |-> Random_time_meet == 1
    );
endmodule
```