module key_expander_sva (
    input logic        clk,
    input logic [127:0] key_out,
    input logic [31:0]  g_in,
    input logic [31:0]  g_out,
    input logic [127:0] key_in,
    input logic [3:0]   round,
    input logic         add_w_out,
    input logic         enc_dec
);

    // key_out[127:96] is the last key word XORed with g_func.
    check_key_out_last_word: assert property (
        @(posedge clk)
        key_out[127:96] == (key_in[127:96] ^ {g_out[7:0], g_out[31:8]})
    );

    // key_out[95:64] is the second-to-last key word XORed with the previous key word.
    check_key_out_second_last_word: assert property (
        @(posedge clk)
        key_out[95:64] == (key_in[95:64] ^ key_in[127:96])
    );

    // key_out[63:32] is the third-to-last key word XORed with the previous key word.
    check_key_out_third_last_word: assert property (
        @(posedge clk)
        key_out[63:32] == (key_in[63:32] ^ key_in[95:64])
    );

    // key_out[31:0] is the first key word XORed with the previous key word.
    check_key_out_first_word: assert property (
        @(posedge clk)
        key_out[31:0] == (key_in[31:0] ^ key_in[63:32])
    );

    // g_in[31:24] is the rotated g_out byte at index (round + 3) % 4.
    check_g_in_byte3: assert property (
        @(posedge clk)
        g_in[31:24] == g_out[(round + 3)[1:0]]
    );

    // g_in[23:16] is the rotated g_out byte at index (round + 2) % 4.
    check_g_in_byte2: assert property (
        @(posedge clk)
        g_in[23:16] == g_out[(round + 2)[1:0]]
    );

    // g_in[15:8] is the rotated g_out byte at index (round + 1) % 4.
    check_g_in_byte1: assert property (
        @(posedge clk)
        g_in[15:8] == g_out[(round + 1)[1:0]]
    );

    // g_in[7:0] is the rotated g_out byte at index round % 4.
    check_g_in_byte0: assert property (
        @(posedge clk)
        g_in[7:0] == g_out[round[1:0]]
    );

    // In decryption mode, g_in is the same as g_out.
    check_g_in_decrypt_passthrough: assert property (
        @(posedge clk)
        !enc_dec |-> (g_in == g_out)
    );

    // In encryption mode, g_in is the reverse of g_out.
    check_g_in_encrypt_reverse: assert property (
        @(posedge clk)
        enc_dec |-> (g_in == {g_out[7:0], g_out[31:8]})
    );

    // In decryption mode, key_out[127:96] is XORed with 0x1b.
    check_key_out_last_word_decrypt: assert property (
        @(posedge clk)
        !enc_dec |-> (key_out[127:96] == (key_in[127:96] ^ {g_out[7:0], g_out[31:8], 8'h1b}))
    );

    // In decryption mode, key_out[95:64] is XORed with 0x36.
    check_key_out_second_last_word_decrypt: assert property (
        @(posedge clk)
        !enc_dec |-> (key_out[95:64] == (key_in[95:64] ^ key_in[127:96] ^ {g_out[7:0], g_out[31:8], 8'h36}))
    );

    // In decryption mode, key_out[63:32] is XORed with 0x01 shifted by round.
    check_key_out_third_last_word_decrypt: assert property (
        @(posedge clk)
        !enc_dec |-> (key_out[63:32] == (key_in[63:32] ^ key_in[95:64] ^ {g_out[7:0], g_out[31:8], 8'h01 << round}))
    );

    // In decryption mode, key_out[31:0] is XORed with 0x01 shifted by round.
    check_key_out_first_word_decrypt: assert property (
        @(posedge clk)
        !enc_dec |-> (key_out[31:0] == (key_in[31:0] ^ key_in[63:32] ^ {g_out[7:0], g_out[31:8], 8'h01 << round}))
    );

    // In encryption mode, key_out[127:96] is XORed with 0x36.
    check_key_out_last_word_encrypt: assert property (
        @(posedge clk)
        enc_dec |-> (key_out[127:96] == (key_in[127:96] ^ {g_out[7:0], g_out[31:8], 8'h36}))
    );

    // In encryption mode, key_out[95:64] is XORed with 0x1b.
    check_key_out_second_last_word_encrypt: assert property (
        @(posedge clk)
        enc_dec |-> (key_out[95:64] == (key_in[95:64] ^ key_in[127:96] ^ {g_out[7:0], g_out[31:8], 8'h1b}))
    );

    // In encryption mode, key_out[63:32] is XORed with 0x80 shifted right by (round - 2).
    check_key_out_third_last_word_encrypt: assert property (
        @(posedge clk)
        enc_dec |-> (key_out[63:32] == (key_in[63:32] ^ key_in[95:64] ^ {g_out[7:0], g_out[31:8], 8'h80 >> (round - 2)}))
    );

    // In encryption mode, key_out[31:0] is XORed with 0x80 shifted right by (round - 2).
    check_key_out_first_word_encrypt: assert property (
        @(posedge clk)
        enc_dec |-> (key_out[31:0] == (key_in[31:0] ^ key_in[63:32] ^ {g_out[7:0], g_out[31:8], 8'h80 >> (round - 2)}))
    );

endmodule