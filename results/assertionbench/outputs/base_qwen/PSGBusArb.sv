```systemverilog
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
    output logic sel0,
    output logic sel1,
    output logic sel2,
    output logic sel3,
    output logic sel4,
    output logic sel5,
    output logic sel6,
    output logic sel7,
    output logic [2:0] seln
);
    // Reset behavior
    reset: assert property (
        @(posedge clk) disable iff (!rst) (sel0 == 1'b0) && (sel1 == 1'b0) && (sel2 == 1'b0) && (sel3 == 1'b0) && (sel4 == 1'b0) && (sel5 == 1'b0) && (sel6 == 1'b0) && (sel7 == 1'b0) && (seln == 3'd0)
    );

    // Bus selection logic
    bus_selection: assert property (
        @(posedge clk) disable iff (!rst) 
        (req0 |-> sel0 && !sel1 && !sel2 && !sel3 && !sel4 && !sel5 && !sel6 && !sel7 && (seln == 3'd0)) &&
        (req1 |-> !sel0 && sel1 && !sel2 && !sel3 && !sel4 && !sel5 && !sel6 && !sel7 && (seln == 3'd1)) &&
        (req2 |-> !sel0 && !sel1 && sel2 && !sel3 && !sel4 && !sel5 && !sel6 && !sel7 && (seln == 3'd2)) &&
        (req3 |-> !sel0 && !sel1 && !sel2 && sel3 && !sel4 && !sel5 && !sel6 && !sel7 && (seln == 3'd3)) &&
        (req4 |-> !sel0 && !sel1 && !sel2 && !sel3 && sel4 && !sel5 && !sel6 && !sel7 && (seln == 3'd4)) &&
        (req5 |-> !sel0 && !sel1 && !sel2 && !sel3 && !sel4 && sel5 && !sel6 && !sel7 && (seln == 3'd5)) &&
        (req6 |-> !sel0 && !sel1 && !sel2 && !sel3 && !sel4 && !sel5 && sel6 && !sel7 && (seln == 3'd6)) &&
        (req7 |-> !sel0 && !sel1 && !sel2 && !sel3 && !sel4 && !sel5 && !sel6 && sel7 && (seln == 3'd7)) &&
        (!req0 && !req1 && !req2 && !req3 && !req4 && !req5 && !req6 && !req7 |-> sel0 == sel0 && sel1 == sel1 && sel2 == sel2 && sel3 == sel3 && sel4 == sel4 && sel5 == sel5 && sel6 == sel6 && sel7 == sel7 && seln == seln)
    );

    // Clock enable behavior
    clock_enable: assert property (
        @(posedge clk) disable iff (!rst) (ce |-> (sel0 == sel0) && (sel1 == sel1) && (sel2 == sel2) && (sel3 == sel3) && (sel4 == sel4) && (sel5 == sel5) && (sel6 == sel6) && (sel7 == sel7) && (seln == seln))
    );

    // Bus transfer completion behavior
    bus_transfer_completion: assert property (
        @(posedge clk) disable iff (!rst) (ack |-> (sel0 == sel0) && (sel1 == sel1) && (sel2 == sel2) && (sel3 == sel3) && (sel4 == sel4) && (sel5 == sel5) && (sel6 == sel6) && (sel7 == sel7) && (seln == seln))
    );
endmodule
```