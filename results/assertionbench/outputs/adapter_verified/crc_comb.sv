module crc_comb_sva (
    input logic clk,
    input logic [7:0] crc_out,
    input logic data_in,
    input logic [7:0] crc_in,
    input logic [7:0] crc_poly,
    input logic [6:0] crc_poly_size
);

// crc_out[7] is the XOR of crc_in[7] and data_in.
    check_bit7_xor: assert property (
        @(posedge clk) crc_out[7] == (crc_in[7] ^ data_in)
    );

// crc_out[6] is the XOR of crc_in[6] and crc_poly[7].
    check_bit6_poly7: assert property (
        @(posedge clk) crc_out[6] == (crc_in[6] ^ crc_poly[7])
    );

// crc_out[5] is the XOR of crc_in[5] and crc_poly[6].
    check_bit5_poly6: assert property (
        @(posedge clk) crc_out[5] == (crc_in[5] ^ crc_poly[6])
    );

// crc_out[4] is the XOR of crc_in[4] and crc_poly[5].
    check_bit4_poly5: assert property (
        @(posedge clk) crc_out[4] == (crc_in[4] ^ crc_poly[5])
    );

// crc_out[3] is the XOR of crc_in[3] and crc_poly[4].
    check_bit3_poly4: assert property (
        @(posedge clk) crc_out[3] == (crc_in[3] ^ crc_poly[4])
    );

// crc_out[2] is the XOR of crc_in[2] and crc_poly[3].
    check_bit2_poly3: assert property (
        @(posedge clk) crc_out[2] == (crc_in[2] ^ crc_poly[3])
    );

// crc_out[1] is the XOR of crc_in[1] and crc_poly[2].
    check_bit1_poly2: assert property (
        @(posedge clk) crc_out[1] == (crc_in[1] ^ crc_poly[2])
    );

// crc_out[0] is the XOR of crc_in[0] and crc_poly[1].
    check_bit0_poly1: assert property (
        @(posedge clk) crc_out[0] == (crc_in[0] ^ crc_poly[1])
    );

endmodule
