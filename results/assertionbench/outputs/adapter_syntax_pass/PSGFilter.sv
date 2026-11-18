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

    // Reset clears the accumulator.
    check_reset_clears_accumulator: assert property (
        @(posedge clk) rst |-> (acc == 31'd0)
    );

    // Reset clears the output register.
    check_reset_clears_output: assert property (
        @(posedge clk) rst |-> (o == 15'd0)
    );

    // The first tap captures the input sample on cnt==0.
    check_tap0_captures_input: assert property (
        @(posedge clk) disable iff (rst)
        (cnt == 8'd0) |=> (tap[0] == $past(i))
    );

    // Subsequent taps shift the previous tap value on cnt==0.
    genvar tap_idx;
    generate
        for (tap_idx = 1; tap_idx < pTaps; tap_idx = tap_idx + 1) begin : gen_tap_shift
            check_tap_shifts_on_cnt0: assert property (
                @(posedge clk) disable iff (rst)
                (cnt == 8'd0) |=> (tap[tap_idx] == $past(tap[tap_idx-1]))
            );
        end
    endgenerate

    // The first tap holds its value when cnt is nonzero.
    check_tap0_holds_when_cnt_nonzero: assert property (
        @(posedge clk) disable iff (rst)
        (cnt != 8'd0) |=> (tap[0] == $past(tap[0]))
    );

    // Subsequent taps hold their values when cnt is nonzero.
    generate
        for (tap_idx = 1; tap_idx < pTaps; tap_idx = tap_idx + 1) begin : gen_tap_hold
            check_tap_holds_when_cnt_nonzero: assert property (
                @(posedge clk) disable iff (rst)
                (cnt != 8'd0) |=> (tap[tap_idx] == $past(tap[tap_idx]))
            );
        end
    endgenerate

    // A write updates the coefficient at the selected address.
    check_coeff_updates_on_write: assert property (
        @(posedge clk) disable iff (rst)
        wr |=> (coeff[adr] == $past(din[11:0]))
    );

    // A write updates the sign at the selected address.
    check_sgn_updates_on_write: assert property (
        @(posedge clk) disable iff (rst)
        wr |=> (sgn[adr] == $past(din[12]))
    );

    // Without a write, the coefficient and sign registers hold.
    check_coeff_sgn_hold_without_write: assert property (
        @(posedge clk) disable iff (rst)
        !wr |=> ((coeff == $past(coeff)) && (sgn == $past(sgn)))
    );

    // On cnt==0, the accumulator loads the selected tap and coefficient.
    check_acc_loads_selected_tap: assert property (
        @(posedge clk) disable iff (rst)
        (cnt == 8'd0) |=> (acc == ($past(sgn[cnt[3:0]]) ? 31'd0 - ($past(coeff[cnt[3:0]]) * $past(tap[cnt[3:0]])) : 31'd0 + ($past(coeff[cnt[3:0]]) * $past(tap[cnt[3:0]]))))
    );

    // When cnt is nonzero, the accumulator holds its value.
    check_acc_holds_when_cnt_nonzero: assert property (
        @(posedge clk) disable iff (rst)
        (cnt != 8'd0) |=> (acc == $past(acc))
    );

    // On cnt==0, the output register captures the accumulator MSB.
    check_output_captures_acc_msb: assert property (
        @(posedge clk) disable iff (rst)
        (cnt == 8'd0) |=> (o == $past(acc[30:16]))
    );

    // When cnt is nonzero, the output register holds its value.
    check_output_holds_when_cnt_nonzero: assert property (
        @(posedge clk) disable iff (rst)
        (cnt != 8'd0) |=> (o == $past(o))
    );

endmodule