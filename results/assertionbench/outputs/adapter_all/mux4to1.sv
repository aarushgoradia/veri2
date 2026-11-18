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

    // When disabled, the output is all zeros.
    check_disable_drives_zero: assert property (
        @($global_clock) (!e) |-> (z == {WID{1'b0}})
    );

    // When enabled and select is 00, the output matches i0.
    check_select_00_routes_i0: assert property (
        @($global_clock) (e && (s == 2'b00)) |-> (z == i0)
    );

    // When enabled and select is 01, the output matches i1.
    check_select_01_routes_i1: assert property (
        @($global_clock) (e && (s == 2'b01)) |-> (z == i1)
    );

    // When enabled and select is 10, the output matches i2.
    check_select_10_routes_i2: assert property (
        @($global_clock) (e && (s == 2'b10)) |-> (z == i2)
    );

    // When enabled and select is 11, the output matches i3.
    check_select_11_routes_i3: assert property (
        @($global_clock) (e && (s == 2'b11)) |-> (z == i3)
    );

    // With select held at 00, a change on i0 changes the output.
    check_select_00_i0_change_updates_z: assert property (
        @($global_clock) (e && (s == 2'b00) && $stable(s) && $changed(i0)) |-> $changed(z)
    );

    // With select held at 01, a change on i1 changes the output.
    check_select_01_i1_change_updates_z: assert property (
        @($global_clock) (e && (s == 2'b01) && $stable(s) && $changed(i1)) |-> $changed(z)
    );

    // With select held at 10, a change on i2 changes the output.
    check_select_10_i2_change_updates_z: assert property (
        @($global_clock) (e && (s == 2'b10) && $stable(s) && $changed(i2)) |-> $changed(z)
    );

    // With select held at 11, a change on i3 changes the output.
    check_select_11_i3_change_updates_z: assert property (
        @($global_clock) (e && (s == 2'b11) && $stable(s) && $changed(i3)) |-> $changed(z)
    );

    // With select held at 00, a change on i1 does not change the output.
    check_select_00_i1_change_ignored: assert property (
        @($global_clock) (e && (s == 2'b00) && $stable(s) && $changed(i1)) |-> $stable(z)
    );

    // With select held at 00, a change on i2 does not change the output.
    check_select_00_i2_change_ignored: assert property (
        @($global_clock) (e && (s == 2'b00) && $stable(s) && $changed(i2)) |-> $stable(z)
    );

    // With select held at 00, a change on i3 does not change the output.
    check_select_00_i3_change_ignored: assert property (
        @($global_clock) (e && (s == 2'b00) && $stable(s) && $changed(i3)) |-> $stable(z)
    );

    // With select held at 01, a change on i0 does not change the output.
    check_select_01_i0_change_ignored: assert property (
        @($global_clock) (e && (s == 2'b01) && $stable(s) && $changed(i0)) |-> $stable(z)
    );

    // With select held at 01, a change on i2 does not change the output.
    check_select_01_i2_change_ignored: assert property (
        @($global_clock) (e && (s == 2'b01) && $stable(s) && $changed(i2)) |-> $stable(z)
    );

    // With select held at 01, a change on i3 does not change the output.
    check_select_01_i3_change_ignored: assert property (
        @($global_clock) (e && (s == 2'b01) && $stable(s) && $changed(i3)) |-> $stable(z)
    );

    // With select held at 10, a change on i0 does not change the output.
    check_select_10_i0_change_ignored: assert property (
        @($global_clock) (e && (s == 2'b10) && $stable(s) && $changed(i0)) |-> $stable(z)
    );

    // With select held at 10, a change on i1 does not change the output.
    check_select_10_i1_change_ignored: assert property (
        @($global_clock) (e && (s == 2'b10) && $stable(s) && $changed(i1)) |-> $stable(z)
    );

    // With select held at 10, a change on i3 does not change the output.
    check_select_10_i3_change_ignored: assert property (
        @($global_clock) (e && (s == 2'b10) && $stable(s) && $changed(i3)) |-> $stable(z)
    );

    // With select held at 11, a change on i0 does not change the output.
    check_select_11_i0_change_ignored: assert property (
        @($global_clock) (e && (s == 2'b11) && $stable(s) && $changed(i0)) |-> $stable(z)
    );

    // With select held at 11, a change on i1 does not change the output.
    check_select_11_i1_change_ignored: assert property (
        @($global_clock) (e && (s == 2'b11) && $stable(s) && $changed(i1)) |-> $stable(z)
    );

    // With select held at 11, a change on i2 does not change the output.
    check_select_11_i2_change_ignored: assert property (
        @($global_clock) (e && (s == 2'b11) && $stable(s) && $changed(i2)) |-> $stable(z)
    );

endmodule