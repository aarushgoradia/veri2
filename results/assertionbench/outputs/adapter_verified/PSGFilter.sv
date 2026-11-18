module PSGFilter_sva (
    input logic rst,
    input logic clk,
    input logic [7:0] cnt,
    input logic wr,
    input logic [3:0] adr,
    input logic [12:0] din,
    input logic [14:0] i,
    input logic [14:0] o
);

// Reset clears the output on the next clock.
    check_reset_clears_output: assert property (
        @(posedge clk) rst |=> (o == 15'd0)
    );

// A write to the coefficient memory updates the magnitude value.
    check_coeff_magnitude_write: assert property (
        @(posedge clk) disable iff (rst)
        wr && (adr == 4'd0) |=> (coeff[0] == $past(din[11:0]))
    );

// A write to the coefficient memory updates the sign value.
    check_coeff_sign_write: assert property (
        @(posedge clk) disable iff (rst)
        wr && (adr == 4'd0) |=> (sgn[0] == $past(din[12]))
    );

// The first cycle of a new count loads the input into the first tap.
    check_tap_load_first_cycle: assert property (
        @(posedge clk) disable iff (rst)
        (cnt == 8'd0) |=> (tap[0] == $past(i))
    );

// The first cycle of a new count shifts the taps left by one.
    check_tap_shift_first_cycle: assert property (
        @(posedge clk) disable iff (rst)
        (cnt == 8'd0) |=> (tap[1] == $past(tap[0])) &&
                         (tap[2] == $past(tap[1])) &&
                         (tap[3] == $past(tap[2])) &&
                         (tap[4] == $past(tap[3])) &&
                         (tap[5] == $past(tap[4])) &&
                         (tap[6] == $past(tap[5])) &&
                         (tap[7] == $past(tap[6])) &&
                         (tap[8] == $past(tap[7])) &&
                         (tap[9] == $past(tap[8])) &&
                         (tap[10] == $past(tap[9])) &&
                         (tap[11] == $past(tap[10])) &&
                         (tap[12] == $past(tap[11])) &&
                         (tap[13] == $past(tap[12])) &&
                         (tap[14] == $past(tap[13])) &&
                         (tap[15] == $past(tap[14]))
    );

// The first cycle of a new count updates the accumulator with the first tap.
    check_accumulator_first_cycle: assert property (
        @(posedge clk) disable iff (rst)
        (cnt == 8'd0) |=> (acc == ($past(sgn[0]) ? 31'd0 - ($past(coeff[0]) * $past(tap[0])) : 31'd0 + ($past(coeff[0]) * $past(tap[0]))))
    );

// The first cycle of a new count updates the output from the accumulator.
    check_output_first_cycle: assert property (
        @(posedge clk) disable iff (rst)
        (cnt == 8'd0) |=> (o == $past(acc[30:16]))
    );

// Counts below the tap count update the accumulator with the current tap.
    check_accumulator_update_below_tap_count: assert property (
        @(posedge clk) disable iff (rst)
        (cnt < 8'd16) |=> (acc == ($past(sgn[cnt[3:0]]) ? $past(acc) - ($past(coeff[cnt[3:0]]) * $past(tap[cnt[3:0]])) : $past(acc) + ($past(coeff[cnt[3:0]]) * $past(tap[cnt[3:0]]))))
    );

// Counts below the tap count update the output from the accumulator.
    check_output_update_below_tap_count: assert property (
        @(posedge clk) disable iff (rst)
        (cnt < 8'd16) |=> (o == $past(acc[30:16]))
    );

endmodule
