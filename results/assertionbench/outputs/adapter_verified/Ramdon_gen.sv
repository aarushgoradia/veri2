module Ramdon_gen_sva (
    input logic Reset,
    input logic Clk,
    input logic Init,
    input logic [3:0] RetryCnt,
    input logic Random_time_meet
);

// Random_time_meet is HIGH on reset.
    check_reset_high: assert property (
        @(posedge Clk) Reset |-> (Random_time_meet == 1'b1)
    );

// Init drives Random_time_meet LOW on the next cycle.
    check_init_clears_meet: assert property (
        @(posedge Clk) disable iff (Reset)
        Init |=> (Random_time_meet == 1'b0)
    );

// Random_time_meet is LOW when Ramdom_counter is zero.
    check_meet_low_when_counter_zero: assert property (
        @(posedge Clk) disable iff (Reset)
        (Ramdom_counter == 10'd0) |-> (Random_time_meet == 1'b0)
    );

// Random_time_meet is HIGH when Ramdom_counter is non-zero.
    check_meet_high_when_counter_nonzero: assert property (
        @(posedge Clk) disable iff (Reset)
        (Ramdom_counter != 10'd0) |-> (Random_time_meet == 1'b1)
    );

// With Init HIGH and counter non-zero, meet remains LOW on the next cycle.
    check_meet_stays_low_on_init_with_counter: assert property (
        @(posedge Clk) disable iff (Reset)
        (Init && (Ramdom_counter != 10'd0)) |=> (Random_time_meet == 1'b0)
    );

// With Init HIGH and counter zero, meet becomes HIGH on the next cycle.
    check_meet_becomes_high_on_init_with_zero_counter: assert property (
        @(posedge Clk) disable iff (Reset)
        (Init && (Ramdom_counter == 10'd0)) |=> (Random_time_meet == 1'b1)
    );

// With Init LOW and counter non-zero, meet remains HIGH on the next cycle.
    check_meet_stays_high_on_no_init_with_counter: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Init && (Ramdom_counter != 10'd0)) |=> (Random_time_meet == 1'b1)
    );

// With Init LOW and counter zero, meet remains LOW on the next cycle.
    check_meet_stays_low_on_no_init_with_zero_counter: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Init && (Ramdom_counter == 10'd0)) |=> (Random_time_meet == 1'b0)
    );

endmodule
