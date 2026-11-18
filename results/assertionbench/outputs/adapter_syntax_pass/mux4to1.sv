module mux4to1_sva #(
    parameter WID = 4
) (
    input logic e,
    input logic [1:0] s,
    input logic [WID:1] i0,
    input logic [WID:1] i1,
    input logic [WID:1] i2,
    input logic [WID:1] i3,
    input logic [WID:1] z
);

    // When disabled, the output is forced to zero.
    check_disable_forces_zero: assert property (
        @($global_clock) (!e) |-> (z == {WID{1'b0}})
    );

    // When enabled and select is 00, i0 is routed to z.
    check_select_00_routes_i0: assert property (
        @($global_clock) (e && (s == 2'b00)) |-> (z == i0)
    );

    // When enabled and select is 01, i1 is routed to z.
    check_select_01_routes_i1: assert property (
        @($global_clock) (e && (s == 2'b01)) |-> (z == i1)
    );

    // When enabled and select is 10, i2 is routed to z.
    check_select_10_routes_i2: assert property (
        @($global_clock) (e && (s == 2'b10)) |-> (z == i2)
    );

    // When enabled and select is 11, i3 is routed to z.
    check_select_11_routes_i3: assert property (
        @($global_clock) (e && (s == 2'b11)) |-> (z == i3)
    );

endmodule