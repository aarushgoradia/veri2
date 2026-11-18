module crc_comb_sva
#(
    parameter int CRC_SIZE = 8,
    parameter int MASK = 8'hff
)
(
    input logic clk,
    input logic [CRC_SIZE-1:0] crc_out,
    input logic data_in,
    input logic [CRC_SIZE-1:0] crc_in,
    input logic [CRC_SIZE-1:0] crc_poly,
    input logic [CRC_SIZE-2:0] crc_poly_size
);

    // crc_out[0] is the XOR of data_in and the previous MSB of crc_in.
    check_feedback_bit0: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[0] == (data_in ^ crc_in[CRC_SIZE-1])
    );

    // crc_out[1] is the XOR of crc_in[0] and the previous feedback[0].
    check_feedback_bit1: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[1] == (crc_in[0] ^ crc_out[0])
    );

    // crc_out[2] is the XOR of crc_in[1] and the previous feedback[1].
    check_feedback_bit2: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[2] == (crc_in[1] ^ crc_out[1])
    );

    // crc_out[3] is the XOR of crc_in[2] and the previous feedback[2].
    check_feedback_bit3: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[3] == (crc_in[2] ^ crc_out[2])
    );

    // crc_out[4] is the XOR of crc_in[3] and the previous feedback[3].
    check_feedback_bit4: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[4] == (crc_in[3] ^ crc_out[3])
    );

    // crc_out[5] is the XOR of crc_in[4] and the previous feedback[4].
    check_feedback_bit5: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[5] == (crc_in[4] ^ crc_out[4])
    );

    // crc_out[6] is the XOR of crc_in[5] and the previous feedback[5].
    check_feedback_bit6: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[6] == (crc_in[5] ^ crc_out[5])
    );

    // crc_out[7] is the XOR of crc_in[6] and the previous feedback[6].
    check_feedback_bit7: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[7] == (crc_in[6] ^ crc_out[6])
    );

    // crc_out[8] is the XOR of crc_in[7] and the previous feedback[7].
    check_feedback_bit8: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[8] == (crc_in[7] ^ crc_out[7])
    );

    // crc_out[9] is the XOR of crc_in[8] and the previous feedback[8].
    check_feedback_bit9: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[9] == (crc_in[8] ^ crc_out[8])
    );

    // crc_out[10] is the XOR of crc_in[9] and the previous feedback[9].
    check_feedback_bit10: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[10] == (crc_in[9] ^ crc_out[9])
    );

    // crc_out[11] is the XOR of crc_in[10] and the previous feedback[10].
    check_feedback_bit11: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[11] == (crc_in[10] ^ crc_out[10])
    );

    // crc_out[12] is the XOR of crc_in[11] and the previous feedback[11].
    check_feedback_bit12: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[12] == (crc_in[11] ^ crc_out[11])
    );

    // crc_out[13] is the XOR of crc_in[12] and the previous feedback[12].
    check_feedback_bit13: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[13] == (crc_in[12] ^ crc_out[12])
    );

    // crc_out[14] is the XOR of crc_in[13] and the previous feedback[14].
    check_feedback_bit14: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[14] == (crc_in[13] ^ crc_out[13])
    );

    // crc_out[15] is the XOR of crc_in[14] and the previous feedback[15].
    check_feedback_bit15: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[15] == (crc_in[14] ^ crc_out[14])
    );

    // crc_out[16] is the XOR of crc_in[15] and the previous feedback[16].
    check_feedback_bit16: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[16] == (crc_in[15] ^ crc_out[15])
    );

    // crc_out[17] is the XOR of crc_in[16] and the previous feedback[17].
    check_feedback_bit17: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[17] == (crc_in[16] ^ crc_out[16])
    );

    // crc_out[18] is the XOR of crc_in[17] and the previous feedback[18].
    check_feedback_bit18: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[18] == (crc_in[17] ^ crc_out[17])
    );

    // crc_out[19] is the XOR of crc_in[18] and the previous feedback[19].
    check_feedback_bit19: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[19] == (crc_in[18] ^ crc_out[18])
    );

    // crc_out[20] is the XOR of crc_in[19] and the previous feedback[20].
    check_feedback_bit20: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[20] == (crc_in[19] ^ crc_out[19])
    );

    // crc_out[21] is the XOR of crc_in[20] and the previous feedback[21].
    check_feedback_bit21: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[21] == (crc_in[20] ^ crc_out[20])
    );

    // crc_out[22] is the XOR of crc_in[21] and the previous feedback[22].
    check_feedback_bit22: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[22] == (crc_in[21] ^ crc_out[21])
    );

    // crc_out[23] is the XOR of crc_in[22] and the previous feedback[23].
    check_feedback_bit23: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[23] == (crc_in[22] ^ crc_out[22])
    );

    // crc_out[24] is the XOR of crc_in[23] and the previous feedback[24].
    check_feedback_bit24: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[24] == (crc_in[23] ^ crc_out[23])
    );

    // crc_out[25] is the XOR of crc_in[24] and the previous feedback[25].
    check_feedback_bit25: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[25] == (crc_in[24] ^ crc_out[24])
    );

    // crc_out[26] is the XOR of crc_in[25] and the previous feedback[26].
    check_feedback_bit26: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[26] == (crc_in[25] ^ crc_out[25])
    );

    // crc_out[27] is the XOR of crc_in[26] and the previous feedback[27].
    check_feedback_bit27: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[27] == (crc_in[26] ^ crc_out[26])
    );

    // crc_out[28] is the XOR of crc_in[27] and the previous feedback[28].
    check_feedback_bit28: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[28] == (crc_in[27] ^ crc_out[27])
    );

    // crc_out[29] is the XOR of crc_in[28] and the previous feedback[29].
    check_feedback_bit29: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[29] == (crc_in[28] ^ crc_out[28])
    );

    // crc_out[30] is the XOR of crc_in[29] and the previous feedback[30].
    check_feedback_bit30: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[30] == (crc_in[29] ^ crc_out[29])
    );

    // crc_out[31] is the XOR of crc_in[30] and the previous feedback[31].
    check_feedback_bit31: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[31] == (crc_in[30] ^ crc_out[30])
    );

    // crc_out[32] is the XOR of crc_in[31] and the previous feedback[32].
    check_feedback_bit32: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[32] == (crc_in[31] ^ crc_out[31])
    );

    // crc_out[33] is the XOR of crc_in[32] and the previous feedback[33].
    check_feedback_bit33: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[33] == (crc_in[32] ^ crc_out[32])
    );

    // crc_out[34] is the XOR of crc_in[33] and the previous feedback[34].
    check_feedback_bit34: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[34] == (crc_in[33] ^ crc_out[33])
    );

    // crc_out[35] is the XOR of crc_in[34] and the previous feedback[35].
    check_feedback_bit35: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[35] == (crc_in[34] ^ crc_out[34])
    );

    // crc_out[36] is the XOR of crc_in[35] and the previous feedback[36].
    check_feedback_bit36: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[36] == (crc_in[35] ^ crc_out[35])
    );

    // crc_out[37] is the XOR of crc_in[36] and the previous feedback[37].
    check_feedback_bit37: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[37] == (crc_in[36] ^ crc_out[36])
    );

    // crc_out[38] is the XOR of crc_in[37] and the previous feedback[38].
    check_feedback_bit38: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[38] == (crc_in[37] ^ crc_out[37])
    );

    // crc_out[39] is the XOR of crc_in[38] and the previous feedback[39].
    check_feedback_bit39: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[39] == (crc_in[38] ^ crc_out[38])
    );

    // crc_out[40] is the XOR of crc_in[39] and the previous feedback[40].
    check_feedback_bit40: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[40] == (crc_in[39] ^ crc_out[39])
    );

    // crc_out[41] is the XOR of crc_in[40] and the previous feedback[41].
    check_feedback_bit41: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[41] == (crc_in[40] ^ crc_out[40])
    );

    // crc_out[42] is the XOR of crc_in[41] and the previous feedback[42].
    check_feedback_bit42: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[42] == (crc_in[41] ^ crc_out[41])
    );

    // crc_out[43] is the XOR of crc_in[42] and the previous feedback[43].
    check_feedback_bit43: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[43] == (crc_in[42] ^ crc_out[42])
    );

    // crc_out[44] is the XOR of crc_in[43] and the previous feedback[44].
    check_feedback_bit44: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[44] == (crc_in[43] ^ crc_out[43])
    );

    // crc_out[45] is the XOR of crc_in[44] and the previous feedback[45].
    check_feedback_bit45: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[45] == (crc_in[44] ^ crc_out[44])
    );

    // crc_out[46] is the XOR of crc_in[45] and the previous feedback[46].
    check_feedback_bit46: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[46] == (crc_in[45] ^ crc_out[45])
    );

    // crc_out[47] is the XOR of crc_in[46] and the previous feedback[47].
    check_feedback_bit47: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[47] == (crc_in[46] ^ crc_out[46])
    );

    // crc_out[48] is the XOR of crc_in[47] and the previous feedback[48].
    check_feedback_bit48: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[48] == (crc_in[47] ^ crc_out[47])
    );

    // crc_out[49] is the XOR of crc_in[48] and the previous feedback[49].
    check_feedback_bit49: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[49] == (crc_in[48] ^ crc_out[48])
    );

    // crc_out[50] is the XOR of crc_in[49] and the previous feedback[50].
    check_feedback_bit50: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[50] == (crc_in[49] ^ crc_out[49])
    );

    // crc_out[51] is the XOR of crc_in[50] and the previous feedback[51].
    check_feedback_bit51: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[51] == (crc_in[50] ^ crc_out[50])
    );

    // crc_out[52] is the XOR of crc_in[51] and the previous feedback[52].
    check_feedback_bit52: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[52] == (crc_in[51] ^ crc_out[51])
    );

    // crc_out[53] is the XOR of crc_in[52] and the previous feedback[53].
    check_feedback_bit53: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[53] == (crc_in[52] ^ crc_out[52])
    );

    // crc_out[54] is the XOR of crc_in[53] and the previous feedback[54].
    check_feedback_bit54: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[54] == (crc_in[53] ^ crc_out[53])
    );

    // crc_out[55] is the XOR of crc_in[54] and the previous feedback[55].
    check_feedback_bit55: assert property (
        @(posedge clk) disable iff (1'b0)
        crc_out[55] == (