module crc_comb_sva
#(
    parameter int CRC_SIZE = 8,
    parameter int MASK = 8'hff
)(
    input logic clk,
    input logic [CRC_SIZE-1:0] crc_out,
    input logic data_in,
    input logic [CRC_SIZE-1:0] crc_in,
    input logic [CRC_SIZE-1:0] crc_poly,
    input logic [CRC_SIZE-2:0] crc_poly_size
);

    // crc_out[0] is the XOR of the previous MSB and the current data bit.
    check_feedback_bit0: assert property (
        @(posedge clk) crc_out[0] == (crc_in[CRC_SIZE-1] ^ data_in)
    );

    // crc_out[1] is the XOR of the previous bit indexed by crc_poly_size[0] and the previous MSB.
    check_feedback_bit1: assert property (
        @(posedge clk) crc_out[1] == (crc_in[CRC_SIZE-2] ^ crc_in[CRC_SIZE-1])
    );

    // crc_out[2] is the XOR of the previous bit indexed by crc_poly_size[1] and the previous bit indexed by crc_poly_size[0].
    check_feedback_bit2: assert property (
        @(posedge clk) crc_out[2] == (crc_in[CRC_SIZE-3] ^ crc_in[CRC_SIZE-2])
    );

    // crc_out[3] is the XOR of the previous bit indexed by crc_poly_size[2] and the previous bit indexed by crc_poly_size[1].
    check_feedback_bit3: assert property (
        @(posedge clk) crc_out[3] == (crc_in[CRC_SIZE-4] ^ crc_in[CRC_SIZE-3])
    );

    // crc_out[4] is the XOR of the previous bit indexed by crc_poly_size[3] and the previous bit indexed by crc_poly_size[2].
    check_feedback_bit4: assert property (
        @(posedge clk) crc_out[4] == (crc_in[CRC_SIZE-5] ^ crc_in[CRC_SIZE-4])
    );

    // crc_out[5] is the XOR of the previous bit indexed by crc_poly_size[4] and the previous bit indexed by crc_poly_size[3].
    check_feedback_bit5: assert property (
        @(posedge clk) crc_out[5] == (crc_in[CRC_SIZE-6] ^ crc_in[CRC_SIZE-5])
    );

    // crc_out[6] is the XOR of the previous bit indexed by crc_poly_size[5] and the previous bit indexed by crc_poly_size[4].
    check_feedback_bit6: assert property (
        @(posedge clk) crc_out[6] == (crc_in[CRC_SIZE-7] ^ crc_in[CRC_SIZE-6])
    );

    // crc_out[7] is the XOR of the previous bit indexed by crc_poly_size[6] and the previous bit indexed by crc_poly_size[5].
    check_feedback_bit7: assert property (
        @(posedge clk) crc_out[7] == (crc_in[CRC_SIZE-8] ^ crc_in[CRC_SIZE-7])
    );

    // crc_out[8] is the XOR of the previous bit indexed by crc_poly_size[7] and the previous bit indexed by crc_poly_size[6].
    check_feedback_bit8: assert property (
        @(posedge clk) crc_out[8] == (crc_in[CRC_SIZE-9] ^ crc_in[CRC_SIZE-8])
    );

    // crc_out[9] is the XOR of the previous bit indexed by crc_poly_size[8] and the previous bit indexed by crc_poly_size[7].
    check_feedback_bit9: assert property (
        @(posedge clk) crc_out[9] == (crc_in[CRC_SIZE-10] ^ crc_in[CRC_SIZE-9])
    );

    // crc_out[10] is the XOR of the previous bit indexed by crc_poly_size[9] and the previous bit indexed by crc_poly_size[8].
    check_feedback_bit10: assert property (
        @(posedge clk) crc_out[10] == (crc_in[CRC_SIZE-11] ^ crc_in[CRC_SIZE-10])
    );

    // crc_out[11] is the XOR of the previous bit indexed by crc_poly_size[10] and the previous bit indexed by crc_poly_size[9].
    check_feedback_bit11: assert property (
        @(posedge clk) crc_out[11] == (crc_in[CRC_SIZE-12] ^ crc_in[CRC_SIZE-11])
    );

    // crc_out[12] is the XOR of the previous bit indexed by crc_poly_size[11] and the previous bit indexed by crc_poly_size[10].
    check_feedback_bit12: assert property (
        @(posedge clk) crc_out[12] == (crc_in[CRC_SIZE-13] ^ crc_in[CRC_SIZE-12])
    );

    // crc_out[13] is the XOR of the previous bit indexed by crc_poly_size[12] and the previous bit indexed by crc_poly_size[11].
    check_feedback_bit13: assert property (
        @(posedge clk) crc_out[13] == (crc_in[CRC_SIZE-14] ^ crc_in[CRC_SIZE-13])
    );

    // crc_out[14] is the XOR of the previous bit indexed by crc_poly_size[13] and the previous bit indexed by crc_poly_size[12].
    check_feedback_bit14: assert property (
        @(posedge clk) crc_out[14] == (crc_in[CRC_SIZE-15] ^ crc_in[CRC_SIZE-14])
    );

    // crc_out[15] is the XOR of the previous bit indexed by crc_poly_size[14] and the previous bit indexed by crc_poly_size[13].
    check_feedback_bit15: assert property (
        @(posedge clk) crc_out[15] == (crc_in[CRC_SIZE-16] ^ crc_in[CRC_SIZE-15])
    );

    // crc_out[16] is the XOR of the previous bit indexed by crc_poly_size[15] and the previous bit indexed by crc_poly_size[14].
    check_feedback_bit16: assert property (
        @(posedge clk) crc_out[16] == (crc_in[CRC_SIZE-17] ^ crc_in[CRC_SIZE-16])
    );

    // crc_out[17] is the XOR of the previous bit indexed by crc_poly_size[16] and the previous bit indexed by crc_poly_size[15].
    check_feedback_bit17: assert property (
        @(posedge clk) crc_out[17] == (crc_in[CRC_SIZE-18] ^ crc_in[CRC_SIZE-17])
    );

    // crc_out[18] is the XOR of the previous bit indexed by crc_poly_size[17] and the previous bit indexed by crc_poly_size[16].
    check_feedback_bit18: assert property (
        @(posedge clk) crc_out[18] == (crc_in[CRC_SIZE-19] ^ crc_in[CRC_SIZE-18])
    );

    // crc_out[19] is the XOR of the previous bit indexed by crc_poly_size[18] and the previous bit indexed by crc_poly_size[17].
    check_feedback_bit19: assert property (
        @(posedge clk) crc_out[19] == (crc_in[CRC_SIZE-20] ^ crc_in[CRC_SIZE-19])
    );

    // crc_out[20] is the XOR of the previous bit indexed by crc_poly_size[19] and the previous bit indexed by crc_poly_size[18].
    check_feedback_bit20: assert property (
        @(posedge clk) crc_out[20] == (crc_in[CRC_SIZE-21] ^ crc_in[CRC_SIZE-20])
    );

    // crc_out[21] is the XOR of the previous bit indexed by crc_poly_size[20] and the previous bit indexed by crc_poly_size[19].
    check_feedback_bit21: assert property (
        @(posedge clk) crc_out[21] == (crc_in[CRC_SIZE-22] ^ crc_in[CRC_SIZE-21])
    );

    // crc_out[22] is the XOR of the previous bit indexed by crc_poly_size[21] and the previous bit indexed by crc_poly_size[20].
    check_feedback_bit22: assert property (
        @(posedge clk) crc_out[22] == (crc_in[CRC_SIZE-23] ^ crc_in[CRC_SIZE-22])
    );

    // crc_out[23] is the XOR of the previous bit indexed by crc_poly_size[22] and the previous bit indexed by crc_poly_size[21].
    check_feedback_bit23: assert property (
        @(posedge clk) crc_out[23] == (crc_in[CRC_SIZE-24] ^ crc_in[CRC_SIZE-23])
    );

    // crc_out[24] is the XOR of the previous bit indexed by crc_poly_size[23] and the previous bit indexed by crc_poly_size[22].
    check_feedback_bit24: assert property (
        @(posedge clk) crc_out[24] == (crc_in[CRC_SIZE-25] ^ crc_in[CRC_SIZE-24])
    );

    // crc_out[25] is the XOR of the previous bit indexed by crc_poly_size[24] and the previous bit indexed by crc_poly_size[23].
    check_feedback_bit25: assert property (
        @(posedge clk) crc_out[25] == (crc_in[CRC_SIZE-26] ^ crc_in[CRC_SIZE-25])
    );

    // crc_out[26] is the XOR of the previous bit indexed by crc_poly_size[25] and the previous bit indexed by crc_poly_size[24].
    check_feedback_bit26: assert property (
        @(posedge clk) crc_out[26] == (crc_in[CRC_SIZE-27] ^ crc_in[CRC_SIZE-26])
    );

    // crc_out[27] is the XOR of the previous bit indexed by crc_poly_size[26] and the previous bit indexed by crc_poly_size[25].
    check_feedback_bit27: assert property (
        @(posedge clk) crc_out[27] == (crc_in[CRC_SIZE-28] ^ crc_in[CRC_SIZE-27])
    );

    // crc_out[28] is the XOR of the previous bit indexed by crc_poly_size[27] and the previous bit indexed by crc_poly_size[26].
    check_feedback_bit28: assert property (
        @(posedge clk) crc_out[28] == (crc_in[CRC_SIZE-29] ^ crc_in[CRC_SIZE-28])
    );

    // crc_out[29] is the XOR of the previous bit indexed by crc_poly_size[28] and the previous bit indexed by crc_poly_size[27].
    check_feedback_bit29: assert property (
        @(posedge clk) crc_out[29] == (crc_in[CRC_SIZE-30] ^ crc_in[CRC_SIZE-29])
    );

    // crc_out[30] is the XOR of the previous bit indexed by crc_poly_size[29] and the previous bit indexed by crc_poly_size[28].
    check_feedback_bit30: assert property (
        @(posedge clk) crc_out[30] == (crc_in[CRC_SIZE-31] ^ crc_in[CRC_SIZE-30])
    );

    // crc_out[31] is the XOR of the previous bit indexed by crc_poly_size[30] and the previous bit indexed by crc_poly_size[29].
    check_feedback_bit31: assert property (
        @(posedge clk) crc_out[31] == (crc_in[CRC_SIZE-32] ^ crc_in[CRC_SIZE-31])
    );

    // crc_out[32] is the XOR of the previous bit indexed by crc_poly_size[31] and the previous bit indexed by crc_poly_size[30].
    check_feedback_bit32: assert property (
        @(posedge clk) crc_out[32] == (crc_in[CRC_SIZE-33] ^ crc_in[CRC_SIZE-32])
    );

    // crc_out[33] is the XOR of the previous bit indexed by crc_poly_size[32] and the previous bit indexed by crc_poly_size[31].
    check_feedback_bit33: assert property (
        @(posedge clk) crc_out[33] == (crc_in[CRC_SIZE-34] ^ crc_in[CRC_SIZE-33])
    );

    // crc_out[34] is the XOR of the previous bit indexed by crc_poly_size[33] and the previous bit indexed by crc_poly_size[32].
    check_feedback_bit34: assert property (
        @(posedge clk) crc_out[34] == (crc_in[CRC_SIZE-35] ^ crc_in[CRC_SIZE-34])
    );

    // crc_out[35] is the XOR of the previous bit indexed by crc_poly_size[34] and the previous bit indexed by crc_poly_size[33].
    check_feedback_bit35: assert property (
        @(posedge clk) crc_out[35] == (crc_in[CRC_SIZE-36] ^ crc_in[CRC_SIZE-35])
    );

    // crc_out[36] is the XOR of the previous bit indexed by crc_poly_size[35] and the previous bit indexed by crc_poly_size[34].
    check_feedback_bit36: assert property (
        @(posedge clk) crc_out[36] == (crc_in[CRC_SIZE-37] ^ crc_in[CRC_SIZE-36])
    );

    // crc_out[37] is the XOR of the previous bit indexed by crc_poly_size[36] and the previous bit indexed by crc_poly_size[35].
    check_feedback_bit37: assert property (
        @(posedge clk) crc_out[37] == (crc_in[CRC_SIZE-38] ^ crc_in[CRC_SIZE-37])
    );

    // crc_out[38] is the XOR of the previous bit indexed by crc_poly_size[37] and the previous bit indexed by crc_poly_size[36].
    check_feedback_bit38: assert property (
        @(posedge clk) crc_out[38] == (crc_in[CRC_SIZE-39] ^ crc_in[CRC_SIZE-38])
    );

    // crc_out[39] is the XOR of the previous bit indexed by crc_poly_size[38] and the previous bit indexed by crc_poly_size[37].
    check_feedback_bit39: assert property (
        @(posedge clk) crc_out[39] == (crc_in[CRC_SIZE-40] ^ crc_in[CRC_SIZE-39])
    );

    // crc_out[40] is the XOR of the previous bit indexed by crc_poly_size[39] and the previous bit indexed by crc_poly_size[38].
    check_feedback_bit40: assert property (
        @(posedge clk) crc_out[40] == (crc_in[CRC_SIZE-41] ^ crc_in[CRC_SIZE-40])
    );

    // crc_out[41] is the XOR of the previous bit indexed by crc_poly_size[40] and the previous bit indexed by crc_poly_size[39].
    check_feedback_bit41: assert property (
        @(posedge clk) crc_out[41] == (crc_in[CRC_SIZE-42] ^ crc_in[CRC_SIZE-41])
    );

    // crc_out[42] is the XOR of the previous bit indexed by crc_poly_size[41] and the previous bit indexed by crc_poly_size[40].
    check_feedback_bit42: assert property (
        @(posedge clk) crc_out[42] == (crc_in[CRC_SIZE-43] ^ crc_in[CRC_SIZE-42])
    );

    // crc_out[43] is the XOR of the previous bit indexed by crc_poly_size[42] and the previous bit indexed by crc_poly_size[41].
    check_feedback_bit43: assert property (
        @(posedge clk) crc_out[43] == (crc_in[CRC_SIZE-44] ^ crc_in[CRC_SIZE-43])
    );

    // crc_out[44] is the XOR of the previous bit indexed by crc_poly_size[43] and the previous bit indexed by crc_poly_size[42].
    check_feedback_bit44: assert property (
        @(posedge clk) crc_out[44] == (crc_in[CRC_SIZE-45] ^ crc_in[CRC_SIZE-44])
    );

    // crc_out[45] is the XOR of the previous bit indexed by crc_poly_size[44] and the previous bit indexed by crc_poly_size[43].
    check_feedback_bit45: assert property (
        @(posedge clk) crc_out[45] == (crc_in[CRC_SIZE-46] ^ crc_in[CRC_SIZE-45])
    );

    // crc_out[46] is the XOR of the previous bit indexed by crc_poly_size[45] and the previous bit indexed by crc_poly_size[44].
    check_feedback_bit46: assert property (
        @(posedge clk) crc_out[46] == (crc_in[CRC_SIZE-47] ^ crc_in[CRC_SIZE-46])
    );

    // crc_out[47] is the XOR of the previous bit indexed by crc_poly_size[46] and the previous bit indexed by crc_poly_size[45].
    check_feedback_bit47: assert property (
        @(posedge clk) crc_out[47] == (crc_in[CRC_SIZE-48] ^ crc_in[CRC_SIZE-47])
    );

    // crc_out[48] is the XOR of the previous bit indexed by crc_poly_size[47] and the previous bit indexed by crc_poly_size[46].
    check_feedback_bit48: assert property (
        @(posedge clk) crc_out[48] == (crc_in[CRC_SIZE-49] ^ crc_in[CRC_SIZE-48])
    );

    // crc_out[49] is the XOR of the previous bit indexed by crc_poly_size[48] and the previous bit indexed by crc_poly_size[47].
    check_feedback_bit49: assert property (
        @(posedge clk) crc_out[49] == (crc_in[CRC_SIZE-50] ^ crc_in[CRC_SIZE-