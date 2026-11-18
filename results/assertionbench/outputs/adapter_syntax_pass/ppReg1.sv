module ppReg1_sva (
    input logic clk,
    input logic [4-1:0] opcodeIn,
    input logic [10-1:0] fieldIn,
    input logic [4-1:0] opcodeOut,
    input logic [10-1:0] fieldOut
);

    // opcodeOut captures opcodeIn on the previous rising edge.
    check_opcode_pipeline: assert property (
        @(posedge clk) 1'b1 |=> (opcodeOut == $past(opcodeIn))
    );

    // fieldOut captures fieldIn on the previous rising edge.
    check_field_pipeline: assert property (
        @(posedge clk) 1'b1 |=> (fieldOut == $past(fieldIn))
    );

    // opcodeOut and fieldOut are driven by the previous cycle's inputs.
    check_outputs_match_previous_inputs: assert property (
        @(posedge clk) 1'b1 |=> ((opcodeOut == $past(opcodeIn)) && (fieldOut == $past(fieldIn)))
    );

endmodule