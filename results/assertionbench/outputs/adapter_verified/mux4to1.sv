module mux4to1_sva (
    input logic clk,
    input logic e,
    input logic [1:0] s,
    input logic [3:0] i0,
    input logic [3:0] i1,
    input logic [3:0] i2,
    input logic [3:0] i3,
    input logic [3:0] z
);

// When enable is low, the output is zero.
    check_disable_clears_output: assert property (
        @(posedge clk) !e |-> (z == 4'b0000)
    );

// When enable is high and select is 00, output equals i0.
    check_select_00_routes_i0: assert property (
        @(posedge clk) (e && (s == 2'b00)) |-> (z == i0)
    );

// When enable is high and select is 01, output equals i1.
    check_select_01_routes_i1: assert property (
        @(posedge clk) (e && (s == 2'b01)) |-> (z == i1)
    );

// When enable is high and select is 10, output equals i2.
    check_select_10_routes_i2: assert property (
        @(posedge clk) (e && (s == 2'b10)) |-> (z == i2)
    );

// When enable is high and select is 11, output equals i3.
    check_select_11_routes_i3: assert property (
        @(posedge clk) (e && (s == 2'b11)) |-> (z == i3)
    );

// When enable is high, output matches the selected input.
    check_enable_selects_input: assert property (
        @(posedge clk) e |-> (z == (s == 2'b00 ? i0 :
                                    s == 2'b01 ? i1 :
                                    s == 2'b10 ? i2 : i3))
    );

// When enable is high, output differs from zero.
    check_enable_nonzero_output: assert property (
        @(posedge clk) e |-> (z != 4'b0000)
    );

endmodule
