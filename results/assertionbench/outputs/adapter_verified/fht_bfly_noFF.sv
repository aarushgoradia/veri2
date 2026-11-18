module fht_bfly_noFF_sva (
    input logic        rstn,
    input logic        clk,
    input logic        valid,
    input logic [7:0]  a,
    input logic [7:0]  b,
    input logic [8:0]  c,
    input logic [8:0]  d
);

// c is the 8-bit sum of a and b with sign extension.
    check_c_sum: assert property (
        @(posedge clk) disable iff (!rstn)
        (c[7:0] == (a + b)) && (c[8] == (a[7] ^ b[7]))
    );

// d is the 8-bit difference of a and b with sign extension.
    check_d_difference: assert property (
        @(posedge clk) disable iff (!rstn)
        (d[7:0] == (a - b)) && (d[8] == (a[7] ^ ~b[7]))
    );

// When valid is low, c and d are zero.
    check_idle_outputs_zero: assert property (
        @(posedge clk) disable iff (!rstn)
        !valid |-> ((c == 8'h00) && (c[8] == 1'b0) && (d == 8'h00) && (d[8] == 1'b0))
    );

// A zero b input makes c equal a and d equal zero.
    check_b_zero_behavior: assert property (
        @(posedge clk) disable iff (!rstn)
        (b == 8'h00) |-> ((c == {a, 1'b0}) && (d == 8'h00) && (d[8] == 1'b0))
    );

// A zero a input makes d equal b and c equal zero.
    check_a_zero_behavior: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == 8'h00) |-> ((d == {b, 1'b0}) && (c == 8'h00) && (c[8] == 1'b0))
    );

// Equal inputs produce c equal to twice the input with sign extension.
    check_equal_inputs_double: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == b) |-> ((c == {1'b0, a << 1}) && (c[8] == 1'b0) && (d == 8'h00) && (d[8] == 1'b0))
    );

// Complementary inputs produce c equal to 8'hFF and d equal to 8'h00.
    check_complementary_inputs: assert property (
        @(posedge clk) disable iff (!rstn)
        (a == ~b) |-> ((c == 8'hFF) && (c[8] == 1'b0) && (d == 8'h00) && (d[8] == 1'b0))
    );

endmodule
