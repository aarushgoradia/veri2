module bit_reversal_sva
#(
    parameter DATA_SIZE = 32
)
(
    input logic [DATA_SIZE-1:0] data_out,
    input logic [DATA_SIZE-1:0] data_in,
    input logic [1:0]           rev_type
);

    localparam logic [1:0] NO_REVERSE  = 2'b00;
    localparam logic [1:0] BYTE        = 2'b01;
    localparam logic [1:0] HALF_WORD   = 2'b10;
    localparam logic [1:0] WORD        = 2'b11;

    localparam int unsigned SIZE = (DATA_SIZE / 4) * (2 ** rev_type[1:0]);

    // No-reverse mode passes the input through unchanged.
    check_no_reverse_passthrough: assert property (
        @($global_clock) (rev_type == NO_REVERSE) |-> (data_out == data_in)
    );

    // Byte-reverse mode swaps adjacent bytes.
    check_byte_reverse_mapping: assert property (
        @($global_clock) (rev_type == BYTE) |-> (data_out == {data_in[DATA_SIZE-1:24], data_in[23:16], data_in[15:8], data_in[7:0]})
    );

    // Half-word-reverse mode swaps adjacent half words.
    check_half_word_reverse_mapping: assert property (
        @($global_clock) (rev_type == HALF_WORD) |-> (data_out == {data_in[DATA_SIZE-1:16], data_in[15:0]})
    );

    // Word-reverse mode swaps the entire data bus.
    check_word_reverse_mapping: assert property (
        @($global_clock) (rev_type == WORD) |-> (data_out == {data_in[DATA_SIZE-1:32], data_in[31:0]})
    );

    // Byte-reverse mode preserves the upper half of the bus.
    check_byte_reverse_upper_preserved: assert property (
        @($global_clock) (rev_type == BYTE) |-> (data_out[DATA_SIZE-1:DATA_SIZE/2] == data_in[DATA_SIZE-1:DATA_SIZE/2])
    );

    // Byte-reverse mode preserves the lower half of the bus.
    check_byte_reverse_lower_preserved: assert property (
        @($global_clock) (rev_type == BYTE) |-> (data_out[DATA_SIZE/2-1:0] == data_in[DATA_SIZE/2-1:0])
    );

    // Half-word-reverse mode preserves the upper half of the bus.
    check_half_word_reverse_upper_preserved: assert property (
        @($global_clock) (rev_type == HALF_WORD) |-> (data_out[DATA_SIZE-1:DATA_SIZE/2] == data_in[DATA_SIZE-1:DATA_SIZE/2])
    );

    // Half-word-reverse mode preserves the lower half of the bus.
    check_half_word_reverse_lower_preserved: assert property (
        @($global_clock) (rev_type == HALF_WORD) |-> (data_out[DATA_SIZE/2-1:0] == data_in[DATA_SIZE/2-1:0])
    );

    // Word-reverse mode preserves the upper half of the bus.
    check_word_reverse_upper_preserved: assert property (
        @($global_clock) (rev_type == WORD) |-> (data_out[DATA_SIZE-1:DATA_SIZE/2] == data_in[DATA_SIZE-1:DATA_SIZE/2])
    );

    // Word-reverse mode preserves the lower half of the bus.
    check_word_reverse_lower_preserved: assert property (
        @($global_clock) (rev_type == WORD) |-> (data_out[DATA_SIZE/2-1:0] == data_in[DATA_SIZE/2-1:0])
    );

endmodule