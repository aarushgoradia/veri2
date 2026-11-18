module bit_reversal_sva (
    input logic CLK,
    input logic [31:0] data_out,
    input logic [31:0] data_in,
    input logic [1:0]  rev_type
);

// No-reverse mode passes the input through unchanged.
    check_no_reverse_passthrough: assert property (
        @(posedge CLK) (rev_type == NO_REVERSE) |-> (data_out == data_in)
    );

// Byte-reverse mode swaps byte pairs.
    check_byte_reverse_pattern: assert property (
        @(posedge CLK) (rev_type == BYTE) |-> (data_out == {data_in[23:16], data_in[31:24], data_in[15:8], data_in[7:0]})
    );

// Half-word-reverse mode swaps half-word pairs.
    check_half_word_reverse_pattern: assert property (
        @(posedge CLK) (rev_type == HALF_WORD) |-> (data_out == {data_in[15:0], data_in[31:16]})
    );

// Word-reverse mode swaps the entire 32-bit word.
    check_word_reverse_pattern: assert property (
        @(posedge CLK) (rev_type == WORD) |-> (data_out == {data_in[31:0]})
    );

// Invalid type values select the no-reverse path.
    check_invalid_type_default: assert property (
        @(posedge CLK) (rev_type != NO_REVERSE && rev_type != BYTE && rev_type != HALF_WORD && rev_type != WORD) |-> (data_out == data_in)
    );

endmodule
