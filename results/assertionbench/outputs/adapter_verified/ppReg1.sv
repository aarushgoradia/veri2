module ppReg1_sva (
    input logic        clk,
    input logic [4-1:0] opcodeIn,
    input logic [10-1:0] fieldIn,
    input logic [4-1:0] opcodeOut,
    input logic [10-1:0] fieldOut
);

// opcodeOut captures opcodeIn on the next clock.
    check_opcode_capture: assert property (
        @(posedge clk) 1'b1 |=> (opcodeOut == $past(opcodeIn))
    );

// fieldOut captures fieldIn on the next clock.
    check_field_capture: assert property (
        @(posedge clk) 1'b1 |=> (fieldOut == $past(fieldIn))
    );

// opcodeOut holds its value when opcodeIn is stable.
    check_opcode_hold_when_input_stable: assert property (
        @(posedge clk) $stable(opcodeIn) |=> (opcodeOut == $past(opcodeIn))
    );

// fieldOut holds its value when fieldIn is stable.
    check_field_hold_when_input_stable: assert property (
        @(posedge clk) $stable(fieldIn) |=> (fieldOut == $past(fieldIn))
    );

// opcodeOut changes only when opcodeIn changes.
    check_opcode_change_only_on_input_change: assert property (
        @(posedge clk) 1'b1 |=> (($changed(opcodeIn) && (opcodeOut == $past(opcodeIn))) || (!$changed(opcodeIn) && (opcodeOut == $past(opcodeOut))))
    );

// fieldOut changes only when fieldIn changes.
    check_field_change_only_on_input_change: assert property (
        @(posedge clk) 1'b1 |=> (($changed(fieldIn) && (fieldOut == $past(fieldIn))) || (!$changed(fieldIn) && (fieldOut == $past(fieldOut))))
    );

endmodule
