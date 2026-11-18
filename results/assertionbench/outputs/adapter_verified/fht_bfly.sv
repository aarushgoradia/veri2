module fht_bfly_sva (
    input logic rstn,
    input logic clk,
    input logic valid,
    input logic [7:0] a,
    input logic [7:0] b,
    input logic [8:0] c,
    input logic [8:0] d
);

// c is the 8-bit sum of a and b with sign extension.
    check_c_sum: assert property (
        @(posedge clk) disable iff (!rstn)
        (c[7:0] == (a + b)) && (c[8] == (a[7] ^ b[7]))
    );

// d is the 8-bit difference of a and b with sign extension.
    check_d_difference: assert property (
        @(posedge clk) disable iff (!rstn)
        (d[7:0] == (a - b)) && (d[8] == (a[7] ^ b[7]))
    );

// When valid is low, c and d hold their previous values.
    check_hold_when_valid_low: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid |=> (c == $past(c)) && (d == $past(d))
    );

// When valid is high, c and d reflect the previous cycle's a and b.
    check_update_when_valid_high: assert property (
        @(posedge clk) disable iff (!rstn)
        valid |=> (c == {$past(b[7]), $past(a) + $past(b)}) &&
                 (d == {$past(b[7]), $past(a) - $past(b)})
    );

endmodule
