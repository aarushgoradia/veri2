module node_sva
#(
    parameter DATA_WIDTH = 8,
    parameter LOW_MUX = 1,
    parameter HI_MUX = 1
)(
    input logic clk,
    input logic [DATA_WIDTH-1:0] data_a,
    input logic [DATA_WIDTH-1:0] data_b,
    input logic [DATA_WIDTH-1:0] data_lo,
    input logic [DATA_WIDTH-1:0] data_hi
);

    // When data_a is less than data_b, data_lo must be data_a.
    check_lo_selects_a_when_a_lt_b: assert property (
        @(posedge clk) (data_a < data_b) |-> (data_lo == data_a)
    );

    // When data_a is less than data_b, data_hi must be data_b.
    check_hi_selects_b_when_a_lt_b: assert property (
        @(posedge clk) (data_a < data_b) |-> (data_hi == data_b)
    );

    // When data_a is not less than data_b, data_lo must be data_b.
    check_lo_selects_b_when_a_ge_b: assert property (
        @(posedge clk) !(data_a < data_b) |-> (data_lo == data_b)
    );

    // When data_a is not less than data_b, data_hi must be data_a.
    check_hi_selects_a_when_a_ge_b: assert property (
        @(posedge clk) !(data_a < data_b) |-> (data_hi == data_a)
    );

    // When data_a equals data_b, both outputs must match the inputs.
    check_equal_inputs_passthrough: assert property (
        @(posedge clk) (data_a == data_b) |-> ((data_lo == data_a) && (data_hi == data_a))
    );

    // If both outputs are zero, the inputs must be zero.
    check_zero_outputs_imply_zero_inputs: assert property (
        @(posedge clk) ((data_lo == {DATA_WIDTH{1'b0}}) && (data_hi == {DATA_WIDTH{1'b0}})) |-> ((data_a == {DATA_WIDTH{1'b0}}) && (data_b == {DATA_WIDTH{1'b0}}))
    );

    // If the low output is zero, the high output must be data_a.
    check_zero_lo_implies_a_on_hi: assert property (
        @(posedge clk) (data_lo == {DATA_WIDTH{1'b0}}) |-> (data_hi == data_a)
    );

    // If the high output is zero, the low output must be data_b.
    check_zero_hi_implies_b_on_lo: assert property (
        @(posedge clk) (data_hi == {DATA_WIDTH{1'b0}}) |-> (data_lo == data_b)
    );

    // If the low output is data_a, the high output must be data_b.
    check_a_on_lo_implies_b_on_hi: assert property (
        @(posedge clk) (data_lo == data_a) |-> (data_hi == data_b)
    );

    // If the high output is data_a, the low output must be data_b.
    check_a_on_hi_implies_b_on_lo: assert property (
        @(posedge clk) (data_hi == data_a) |-> (data_lo == data_b)
    );

endmodule