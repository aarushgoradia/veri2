module inputRegister_sva (
    input logic clk,
    input logic [`inputNumber-1:0] inputs,
    input logic [`inputAddrLen-1:0] inputReadAddr,
    input logic inputReadOut
);
    // Output equals the bit selected by inputReadAddr.
    check_output_matches_selected_bit: assert property (
        @(posedge clk) inputReadOut == inputs[inputReadAddr]
    );

    // If inputs and address are stable, output remains stable.
    check_output_stable_when_inputs_addr_stable: assert property (
        @(posedge clk) $stable(inputs) && $stable(inputReadAddr) |-> $stable(inputReadOut)
    );

    // If address is stable and only selected bit changes, output changes.
    check_output_changes_when_selected_bit_changes: assert property (
        @(posedge clk) $stable(inputReadAddr) && $changed(inputs[inputReadAddr]) |-> $changed(inputReadOut)
    );

    // If address is stable and only non-selected bits change, output is stable.
    check_output_stable_when_nonselected_bits_change: assert property (
        @(posedge clk) $stable(inputReadAddr) && $changed(inputs) && !$changed(inputs[inputReadAddr]) |-> $stable(inputReadOut)
    );

    // If inputs are stable and address changes, output changes.
    check_output_changes_when_address_changes: assert property (
        @(posedge clk) $stable(inputs) && $changed(inputReadAddr) |-> $changed(inputReadOut)
    );

    // If address changes and selected bit does not change, output is stable.
    check_output_stable_when_address_changes_but_selected_bit_stable: assert property (
        @(posedge clk) $changed(inputReadAddr) && $stable(inputs[inputReadAddr]) |-> $stable(inputReadOut)
    );

    // If address changes and selected bit changes, output changes.
    check_output_changes_when_address_changes_and_selected_bit_changes: assert property (
        @(posedge clk) $changed(inputReadAddr) && $changed(inputs[inputReadAddr]) |-> $changed(inputReadOut)
    );

    // If inputs change and address is stable, output changes.
    check_output_changes_when_inputs_change: assert property (
        @(posedge clk) $changed(inputs) && $stable(inputReadAddr) |-> $changed(inputReadOut)
    );

    // If inputs change and address changes, output changes.
    check_output_changes_when_inputs_and_address_change: assert property (
        @(posedge clk) $changed(inputs) && $changed(inputReadAddr) |-> $changed(inputReadOut)
    );

    // If address changes and only non-selected bits change, output is stable.
    check_output_stable_when_address_changes_and_nonselected_bits_change: assert property (
        @(posedge clk) $changed(inputReadAddr) && $changed(inputs) && !$changed(inputs[inputReadAddr]) |-> $stable(inputReadOut)
    );
endmodule