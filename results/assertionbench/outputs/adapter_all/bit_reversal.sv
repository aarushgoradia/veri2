module bit_reversal_sva
#(
    parameter DATA_SIZE = 32
)
(
    input logic [DATA_SIZE - 1 : 0] data_out,
    input logic [DATA_SIZE - 1 : 0] data_in,
    input logic [1 : 0] rev_type
);

    localparam logic [1 : 0] NO_REVERSE = 2'b00;
    localparam logic [1 : 0] BYTE       = 2'b01;
    localparam logic [1 : 0] HALF_WORD  = 2'b10;
    localparam logic [1 : 0] WORD       = 2'b11;

    localparam int unsigned SIZE = (DATA_SIZE / 4) * (2 ** WORD);

    // No-reverse type passes the input through unchanged.
    check_no_reverse_passthrough: assert property (
        @($global_clock) (rev_type == NO_REVERSE) |-> (data_out == data_in)
    );

    // Byte-reverse type swaps bytes in the output.
    check_byte_reverse_mapping: assert property (
        @($global_clock) (rev_type == BYTE) |-> (
            data_out == {
                data_in[DATA_SIZE-1:DATA_SIZE-8],
                data_in[DATA_SIZE-9:DATA_SIZE-16],
                data_in[DATA_SIZE-17:DATA_SIZE-24],
                data_in[DATA_SIZE-25:DATA_SIZE-32]
            }
        )
    );

    // Half-word-reverse type swaps half-words in the output.
    check_half_word_reverse_mapping: assert property (
        @($global_clock) (rev_type == HALF_WORD) |-> (
            data_out == {
                data_in[DATA_SIZE-1:DATA_SIZE-16],
                data_in[DATA_SIZE-17:DATA_SIZE-32],
                data_in[DATA_SIZE-33:DATA_SIZE-48],
                data_in[DATA_SIZE-49:DATA_SIZE-64]
            }
        )
    );

    // Word-reverse type swaps words in the output.
    check_word_reverse_mapping: assert property (
        @($global_clock) (rev_type == WORD) |-> (
            data_out == {
                data_in[DATA_SIZE-1:DATA_SIZE-32],
                data_in[DATA_SIZE-33:DATA_SIZE-64],
                data_in[DATA_SIZE-65:DATA_SIZE-96],
                data_in[DATA_SIZE-97:DATA_SIZE-128]
            }
        )
    );

    // Output always matches one of the implemented reverse mappings.
    check_output_matches_implemented_type: assert property (
        @($global_clock) 1'b1 |-> (
            (data_out == data_in) ||
            (data_out == {
                data_in[DATA_SIZE-1:DATA_SIZE-8],
                data_in[DATA_SIZE-9:DATA_SIZE-16],
                data_in[DATA_SIZE-17:DATA_SIZE-24],
                data_in[DATA_SIZE-25:DATA_SIZE-32]
            }) ||
            (data_out == {
                data_in[DATA_SIZE-1:DATA_SIZE-16],
                data_in[DATA_SIZE-17:DATA_SIZE-32],
                data_in[DATA_SIZE-33:DATA_SIZE-48],
                data_in[DATA_SIZE-49:DATA_SIZE-64]
            }) ||
            (data_out == {
                data_in[DATA_SIZE-1:DATA_SIZE-32],
                data_in[DATA_SIZE-33:DATA_SIZE-64],
                data_in[DATA_SIZE-65:DATA_SIZE-96],
                data_in[DATA_SIZE-97:DATA_SIZE-128]
            })
        )
    );

endmodule