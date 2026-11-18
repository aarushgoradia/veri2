module PSGFilter_sva #(
    parameter int pTaps = 16
) (
    input logic rst,
    input logic clk,
    input logic [7:0] cnt,
    input logic wr,
    input logic [3:0] adr,
    input logic [12:0] din,
    input logic [14:0] i,
    input logic [14:0] o,
    input logic [30:0] acc,
    input logic [14:0] tap [0:pTaps-1],
    input logic [11:0] coeff [0:pTaps-1],
    input logic [pTaps-1:0] sgn
);

    // Reset clears the accumulator and output.
    check_reset_clears_state: assert property (
        @(posedge clk) rst |-> (acc == 31'd0 && o == 15'd0)
    );

    // Write updates the coefficient and sign at the selected address.
    check_coeff_write: assert property (
        @(posedge clk) disable iff (rst)
        wr |=> (coeff[adr] == $past(din[11:0]) && sgn[adr] == $past(din[12]))
    );

    // Without a write, the coefficient and sign registers hold their values.
    check_coeff_hold_without_write: assert property (
        @(posedge clk) disable iff (rst)
        !wr |=> (coeff == $past(coeff) && sgn == $past(sgn))
    );

    // The first cycle after reset, the accumulator and output remain zero.
    check_reset_hold_state: assert property (
        @(posedge clk) disable iff (rst)
        $past(rst) |-> (acc == 31'd0 && o == 15'd0)
    );

    // On the first cycle of each count value, the first tap captures the input.
    check_tap0_loads_input: assert property (
        @(posedge clk) disable iff (rst)
        (cnt == 8'd0) |=> (tap[0] == $past(i))
    );

    // On the first cycle of each count value, the taps shift from the previous tap[0].
    check_taps_shift_from_tap0: assert property (
        @(posedge clk) disable iff (rst)
        (cnt == 8'd0) |=> (tap[1:pTaps-1] == $past(tap[0:pTaps-2]))
    );

    // On non-first-cycle counts, the taps hold their values.
    check_taps_hold_without_load: assert property (
        @(posedge clk) disable iff (rst)
        (cnt != 8'd0) |=> (tap == $past(tap))
    );

    // On the first cycle of each count value, the accumulator loads the selected tap product.
    check_acc_loads_selected_product: assert property (
        @(posedge clk) disable iff (rst)
        (cnt == 8'd0) |=> (
            acc == ($past(sgn[cnt[3:0]]) ? 31'sh0 - ($past(coeff[cnt[3:0]]) * $past(tap[cnt[3:0]]))
                                          : 31'sh0 + ($past(coeff[cnt[3:0]]) * $past(tap[cnt[3:0]])))
        )
    );

    // On non-first-cycle counts, the accumulator holds its value.
    check_acc_hold_without_load: assert property (
        @(posedge clk) disable iff (rst)
        (cnt != 8'd0) |=> (acc == $past(acc))
    );

    // On the first cycle of each count value, the output loads the accumulator's upper half.
    check_output_loads_acc_upper: assert property (
        @(posedge clk) disable iff (rst)
        (cnt == 8'd0) |=> (o == $past(acc[30:16]))
    );

    // On non-first-cycle counts, the output holds its value.
    check_output_hold_without_load: assert property (
        @(posedge clk) disable iff (rst)
        (cnt != 8'd0) |=> (o == $past(o))
    );

endmodule