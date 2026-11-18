module inputRegister_sva (
    input logic clk,
    input logic [127:0] inputs,
    input logic [6:0] inputReadAddr,
    input logic inputReadOut
);

    // inputReadOut must equal the input bit selected by inputReadAddr.
    check_input_read_matches_selected_bit: assert property (
        @(posedge clk) inputReadOut == inputs[inputReadAddr]
    );

    // A rising address must select the next input bit.
    check_address_increment_selects_next_bit: assert property (
        @(posedge clk) $rose(inputReadAddr) |-> (inputReadOut == inputs[inputReadAddr])
    );

    // A falling address must select the previous input bit.
    check_address_decrement_selects_previous_bit: assert property (
        @(posedge clk) $fell(inputReadAddr) |-> (inputReadOut == inputs[inputReadAddr])
    );

    // A stable address must keep the output stable.
    check_stable_address_keeps_output_stable: assert property (
        @(posedge clk) $stable(inputReadAddr) |-> $stable(inputReadOut)
    );

    // A stable input bus must keep the output stable.
    check_stable_input_bus_keeps_output_stable: assert property (
        @(posedge clk) $stable(inputs) |-> $stable(inputReadOut)
    );

    // A change on inputReadOut must come from a change on the selected input bit.
    check_output_change_requires_selected_bit_change: assert property (
        @(posedge clk) $changed(inputReadOut) |-> (inputs[inputReadAddr] != $past(inputs[inputReadAddr]))
    );

endmodule