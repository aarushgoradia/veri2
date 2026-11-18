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

    // Reset clears all bus grant outputs and the selected channel.
    check_reset_clears_outputs: assert property (
        @(posedge clk) rst |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                               (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                               (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd0)
    );

    // A granted cycle with req0 selected grants only sel0 and sets seln to 0.
    check_grant_req0: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && req0) |=> (sel0 == 1'b1) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                               (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                               (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd0)
    );

    // A granted cycle with req1 selected grants only sel1 and sets seln to 1.
    check_grant_req1: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && req1) |=> (sel0 == 1'b0) && (sel1 == 1'b1) && (sel2 == 1'b0) &&
                                        (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                                        (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd1)
    );

    // A granted cycle with req2 selected grants only sel2 and sets seln to 2.
    check_grant_req2: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && req2) |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b1) &&
                                             (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                                             (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd2)
    );

    // A granted cycle with req3 selected grants only sel3 and sets seln to 3.
    check_grant_req3: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && !req2 && req3) |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                                                       (sel3 == 1'b1) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                                                       (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd3)
    );

    // A granted cycle with req4 selected grants only sel4 and sets seln to 4.
    check_grant_req4: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && !req2 && !req3 && req4) |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                                                               (sel3 == 1'b0) && (sel4 == 1'b1) && (sel5 == 1'b0) &&
                                                               (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd4)
    );

    // A granted cycle with req5 selected grants only sel5 and sets seln to 5.
    check_grant_req5: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && !req2 && !req3 && !req4 && req5) |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                                                                          (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b1) &&
                                                                          (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd5)
    );

    // A granted cycle with req6 selected grants only sel6 and sets seln to 6.
    check_grant_req6: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && !req2 && !req3 && !req4 && !req5 && req6) |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                                                                                     (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                                                                                     (sel6 == 1'b1) && (sel7 == 1'b0) && (seln == 3'd6)
    );

    // A granted cycle with req7 selected grants only sel7 and sets seln to 7.
    check_grant_req7: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && !req2 && !req3 && !req4 && !req5 && !req6 && req7) |=> (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) &&
                                                                                           (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) &&
                                                                                           (sel6 == 1'b0) && (sel7 == 1'b1) && (seln == 3'd7)
    );

    // A granted cycle with no active request holds the previous bus grant.
    check_grant_hold: assert property (
        @(posedge clk) disable iff (rst)
        (ce && ack && !req0 && !req1 && !req2 && !req3 && !req4 && !req5 && !req6 && !req7) |=> (sel0 == $past(sel0)) && (sel1 == $past(sel1)) && (sel2 == $past(sel2)) &&
                                                                                           (sel3 == $past(sel3)) && (sel4 == $past(sel4)) && (sel5 == $past(sel5)) &&
                                                                                           (sel6 == $past(sel6)) && (sel7 == $past(sel7)) && (seln == $past(seln))
    );

endmodule