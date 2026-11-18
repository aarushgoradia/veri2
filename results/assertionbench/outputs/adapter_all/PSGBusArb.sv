module PSGBusArb_sva (
    input logic rst,
    input logic clk,
    input logic ce,
    input logic ack,
    input logic req0,
    input logic req1,
    input logic req2,
    input logic req3,
    input logic req4,
    input logic req5,
    input logic req6,
    input logic req7,
    input logic sel0,
    input logic sel1,
    input logic sel2,
    input logic sel3,
    input logic sel4,
    input logic sel5,
    input logic sel6,
    input logic sel7,
    input logic [2:0] seln
);

    // Reset clears all select outputs and the selected channel.
    check_reset_clears_outputs: assert property (
        @(posedge clk) rst |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                               (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                               (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd0)
    );

    // A cycle with no clock enable or bus acknowledge holds the selected channel.
    check_hold_when_ce_low: assert property (
        @(posedge clk) disable iff (rst)
        (!ce || !ack) |=> (sel0 == $past(sel0)) && (sel1 == $past(sel1)) &&
                          (sel2 == $past(sel2)) && (sel3 == $past(sel3)) &&
                          (sel4 == $past(sel4)) && (sel5 == $past(sel5)) &&
                          (sel6 == $past(sel6)) && (sel7 == $past(sel7)) &&
                          (seln == $past(seln))
    );

    // req0 has highest priority when selected and accepted.
    check_req0_priority: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && req0) |=> (sel0 == 1'b1) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                                (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                                (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd0)
    );

    // req1 selects channel 1 when req0 is low and the bus is accepted.
    check_req1_priority: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && req1) |=> (sel0 == 1'b0) && (sel1 == 1'b1) && (sel2 == 1'b0) &&
                                         (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                                         (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd1)
    );

    // req2 selects channel 2 when higher-priority requests are low and the bus is accepted.
    check_req2_priority: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && req2) |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b1) &&
                                                  (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                                                  (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd2)
    );

    // req3 selects channel 3 when higher-priority requests are low and the bus is accepted.
    check_req3_priority: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && !req2 && req3) |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                                                           (sel3 == 1'b1) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                                                           (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd3)
    );

    // req4 selects channel 4 when higher-priority requests are low and the bus is accepted.
    check_req4_priority: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && !req2 && !req3 && req4) |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                                                                     (sel3 == 1'b0) && (sel4 == 1'b1) && (sel5 == 1'b0) &&
                                                                     (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd4)
    );

    // req5 selects channel 5 when higher-priority requests are low and the bus is accepted.
    check_req5_priority: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && !req2 && !req3 && !req4 && req5) |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                                                                              (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b1) &&
                                                                              (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd5)
    );

    // req6 selects channel 6 when higher-priority requests are low and the bus is accepted.
    check_req6_priority: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && !req2 && !req3 && !req4 && !req5 && req6) |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                                                                                         (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                                                                                         (sel6 == 1'b1) && (sel7 == 1'b0) && (seln == 3'd6)
    );

    // req7 selects channel 7 when higher-priority requests are low and the bus is accepted.
    check_req7_priority: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && !req2 && !req3 && !req4 && !req5 && !req6 && req7) |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                                                                                                  (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                                                                                                  (sel6 == 1'b0) && (sel7 == 1'b1) && (seln == 3'd7)
    );

    // With no requests and the bus accepted, the selected channel holds.
    check_hold_when_no_requests: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && !req2 && !req3 && !req4 && !req5 && !req6 && !req7) |=> (sel0 == $past(sel0)) && (sel1 == $past(sel1)) &&
                                                                                                 (sel2 == $past(sel2)) && (sel3 == $past(sel3)) &&
                                                                                                 (sel4 == $past(sel4)) && (sel5 == $past(sel5)) &&
                                                                                                 (sel6 == $past(sel6)) && (sel7 == $past(sel7)) &&
                                                                                                 (seln == $past(seln))
    );

endmodule