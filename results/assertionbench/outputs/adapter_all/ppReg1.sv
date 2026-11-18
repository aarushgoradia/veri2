module ppReg1_sva (
    input logic clk,
    input logic [`instOpCodeLen-1:0] opcodeIn,
    input logic [`instFieldLen-1:0] fieldIn,
    input logic [`instOpCodeLen-1:0] opcodeOut,
    input logic [`instFieldLen-1:0] fieldOut
);

    // opcodeOut captures opcodeIn on the previous clock.
    check_opcode_pipeline: assert property (
        @(posedge clk) 1'b1 |=> (opcodeOut == $past(opcodeIn))
    );

    // fieldOut captures fieldIn on the previous clock.
    check_field_pipeline: assert property (
        @(posedge clk) 1'b1 |=> (fieldOut == $past(fieldIn))
    );

    // opcodeOut and fieldOut are independent of each other.
    check_outputs_independent: assert property (
        @(posedge clk) 1'b1 |=> ((opcodeOut == $past(opcodeIn)) && (fieldOut == $past(fieldIn)))
    );

    // If opcodeIn is unchanged across two cycles, opcodeOut is unchanged on the next cycle.
    check_opcode_stable_propagation: assert property (
        @(posedge clk) (opcodeIn == $past(opcodeIn)) |=> (opcodeOut == $past(opcodeOut))
    );

    // If fieldIn is unchanged across two cycles, fieldOut is unchanged on the next cycle.
    check_field_stable_propagation: assert property (
        @(posedge clk) (fieldIn == $past(fieldIn)) |=> (fieldOut == $past(fieldOut))
    );

    // If opcodeIn and fieldIn are unchanged across two cycles, both outputs are unchanged on the next cycle.
    check_outputs_stable_propagation: assert property (
        @(posedge clk) ((opcodeIn == $past(opcodeIn)) && (fieldIn == $past(fieldIn))) |=> ((opcodeOut == $past(opcodeOut)) && (fieldOut == $past(fieldOut)))
    );

endmodule