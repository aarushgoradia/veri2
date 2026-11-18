module eth_crc_sva (
    input logic        Clk,
    input logic        Reset,
    input logic [3:0]  Data,
    input logic        Enable,
    input logic        Initialize,
    input logic [31:0] Crc,
    input logic        CrcError
);

// Reset drives the CRC register to all ones.
    check_reset_sets_crc: assert property (
        @(posedge Clk) Reset |-> (Crc == 32'hffffffff)
    );

// Reset drives the CRC error flag high.
    check_reset_sets_crc_error: assert property (
        @(posedge Clk) Reset |-> (CrcError == 1'b1)
    );

// Initialize drives the CRC register to all ones.
    check_initialize_sets_crc: assert property (
        @(posedge Clk) disable iff (Reset) Initialize |-> (Crc == 32'hffffffff)
    );

// Initialize drives the CRC error flag high.
    check_initialize_sets_crc_error: assert property (
        @(posedge Clk) disable iff (Reset) Initialize |-> (CrcError == 1'b1)
    );

// With no enable and no initialize, the CRC holds its value.
    check_crc_holds_without_enable_or_initialize: assert property (
        @(posedge Clk) disable iff (Reset) (!Initialize && !Enable) |=> (Crc == $past(Crc))
    );

// With enable high and data 0, bit 0 is cleared.
    check_bit0_clears_when_enabled_and_data0: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h0) |=> (Crc[0] == 1'b0)
    );

// With enable high and data 1, bit 0 is set.
    check_bit0_sets_when_enabled_and_data1: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h1) |=> (Crc[0] == 1'b1)
    );

// With enable high and data 2, bit 0 follows the previous bit 28.
    check_bit0_follows_bit28_when_enabled_and_data2: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h2) |=> (Crc[0] == $past(Crc[28]))
    );

// With enable high and data 3, bit 0 follows the previous bit 29.
    check_bit0_follows_bit29_when_enabled_and_data3: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h3) |=> (Crc[0] == $past(Crc[29]))
    );

// With enable high and data 4, bit 0 follows the previous bit 30.
    check_bit0_follows_bit30_when_enabled_and_data4: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h4) |=> (Crc[0] == $past(Crc[30]))
    );

// With enable high and data 5, bit 0 follows the previous bit 31.
    check_bit0_follows_bit31_when_enabled_and_data5: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h5) |=> (Crc[0] == $past(Crc[31]))
    );

// With enable high and data 6, bit 0 follows the previous bit 28 XOR 29.
    check_bit0_follows_bit28_xor_bit29_when_enabled_and_data6: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h6) |=> (Crc[0] == ($past(Crc[28]) ^ $past(Crc[29])))
    );

// With enable high and data 7, bit 0 follows the previous bit 29 XOR 30.
    check_bit0_follows_bit29_xor_bit30_when_enabled_and_data7: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h7) |=> (Crc[0] == ($past(Crc[29]) ^ $past(Crc[30])))
    );

// With enable high and data 8, bit 0 follows the previous bit 30 XOR 31.
    check_bit0_follows_bit30_xor_bit31_when_enabled_and_data8: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h8) |=> (Crc[0] == ($past(Crc[30]) ^ $past(Crc[31])))
    );

// With enable high and data 9, bit 0 follows the previous bit 31 XOR 28.
    check_bit0_follows_bit31_xor_bit28_when_enabled_and_data9: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h9) |=> (Crc[0] == ($past(Crc[31]) ^ $past(Crc[28])))
    );

// With enable high and data 10, bit 0 follows the previous bit 28 XOR 29 XOR 30.
    check_bit0_follows_bit28_xor_bit29_xor_bit30_when_enabled_and_data10: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'hA) |=> (Crc[0] == ($past(Crc[28]) ^ $past(Crc[29]) ^ $past(Crc[30])))
    );

// With enable high and data 11, bit 0 follows the previous bit 29 XOR 30 XOR 31.
    check_bit0_follows_bit29_xor_bit30_xor_bit31_when_enabled_and_data11: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'hB) |=> (Crc[0] == ($past(Crc[29]) ^ $past(Crc[30]) ^ $past(Crc[31])))
    );

// With enable high and data 12, bit 0 follows the previous bit 30 XOR 31 XOR 28.
    check_bit0_follows_bit30_xor_bit31_xor_bit28_when_enabled_and_data12: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'hC) |=> (Crc[0] == ($past(Crc[30]) ^ $past(Crc[31]) ^ $past(Crc[28])))
    );

// With enable high and data 13, bit 0 follows the previous bit 31 XOR 28 XOR 29.
    check_bit0_follows_bit31_xor_bit28_xor_bit29_when_enabled_and_data13: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'hD) |=> (Crc[0] == ($past(Crc[31]) ^ $past(Crc[28]) ^ $past(Crc[29])))
    );

// With enable high and data 14, bit 0 follows the previous bit 28 XOR 29 XOR 30 XOR 31.
    check_bit0_follows_bit28_xor_bit29_xor_bit30_xor_bit31_when_enabled_and_data14: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'hE) |=> (Crc[0] == ($past(Crc[28]) ^ $past(Crc[29]) ^ $past(Crc[30]) ^ $past(Crc[31])))
    );

// With enable high and data 15, bit 0 follows the previous bit 29 XOR 30 XOR 31 XOR 28.
    check_bit0_follows_bit29_xor_bit30_xor_bit31_xor_bit28_when_enabled_and_data15: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'hF) |=> (Crc[0] == ($past(Crc[29]) ^ $past(Crc[30]) ^ $past(Crc[31]) ^ $past(Crc[28])))
    );

// With enable high and data 0, bit 1 is cleared.
    check_bit1_clears_when_enabled_and_data0: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h0) |=> (Crc[1] == 1'b0)
    );

// With enable high and data 1, bit 1 follows the previous bit 28.
    check_bit1_follows_bit28_when_enabled_and_data1: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h1) |=> (Crc[1] == $past(Crc[28]))
    );

// With enable high and data 2, bit 1 follows the previous bit 29.
    check_bit1_follows_bit29_when_enabled_and_data2: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h2) |=> (Crc[1] == $past(Crc[29]))
    );

// With enable high and data 3, bit 1 follows the previous bit 30.
    check_bit1_follows_bit30_when_enabled_and_data3: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h3) |=> (Crc[1] == $past(Crc[30]))
    );

// With enable high and data 4, bit 1 follows the previous bit 31.
    check_bit1_follows_bit31_when_enabled_and_data4: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h4) |=> (Crc[1] == $past(Crc[31]))
    );

// With enable high and data 5, bit 1 follows the previous bit 28 XOR 29.
    check_bit1_follows_bit28_xor_bit29_when_enabled_and_data5: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h5) |=> (Crc[1] == ($past(Crc[28]) ^ $past(Crc[29])))
    );

// With enable high and data 6, bit 1 follows the previous bit 29 XOR 30.
    check_bit1_follows_bit29_xor_bit30_when_enabled_and_data6: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h6) |=> (Crc[1] == ($past(Crc[29]) ^ $past(Crc[30])))
    );

// With enable high and data 7, bit 1 follows the previous bit 30 XOR 31.
    check_bit1_follows_bit30_xor_bit31_when_enabled_and_data7: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h7) |=> (Crc[1] == ($past(Crc[30]) ^ $past(Crc[31])))
    );

// With enable high and data 8, bit 1 follows the previous bit 31 XOR 28.
    check_bit1_follows_bit31_xor_bit28_when_enabled_and_data8: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h8) |=> (Crc[1] == ($past(Crc[31]) ^ $past(Crc[28])))
    );

// With enable high and data 9, bit 1 follows the previous bit 28 XOR 29 XOR 30.
    check_bit1_follows_bit28_xor_bit29_xor_bit30_when_enabled_and_data9: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h9) |=> (Crc[1] == ($past(Crc[28]) ^ $past(Crc[29]) ^ $past(Crc[30])))
    );

// With enable high and data 10, bit 1 follows the previous bit 29 XOR 30 XOR 31.
    check_bit1_follows_bit29_xor_bit30_xor_bit31_when_enabled_and_data10: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'hA) |=> (Crc[1] == ($past(Crc[29]) ^ $past(Crc[30]) ^ $past(Crc[31])))
    );

// With enable high and data 11, bit 1 follows the previous bit 30 XOR 31 XOR 28.
    check_bit1_follows_bit30_xor_bit31_xor_bit28_when_enabled_and_data11: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'hB) |=> (Crc[1] == ($past(Crc[30]) ^ $past(Crc[31]) ^ $past(Crc[28])))
    );

// With enable high and data 12, bit 1 follows the previous bit 31 XOR 28 XOR 29.
    check_bit1_follows_bit31_xor_bit28_xor_bit29_when_enabled_and_data12: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'hC) |=> (Crc[1] == ($past(Crc[31]) ^ $past(Crc[28]) ^ $past(Crc[29])))
    );

// With enable high and data 13, bit 1 follows the previous bit 28 XOR 29 XOR 30 XOR 31.
    check_bit1_follows_bit28_xor_bit29_xor_bit30_xor_bit31_when_enabled_and_data13: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'hD) |=> (Crc[1] == ($past(Crc[28]) ^ $past(Crc[29]) ^ $past(Crc[30]) ^ $past(Crc[31])))
    );

// With enable high and data 14, bit 1 follows the previous bit 29 XOR 30 XOR 31 XOR 28.
    check_bit1_follows_bit29_xor_bit30_xor_bit31_xor_bit28_when_enabled_and_data14: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'hE) |=> (Crc[1] == ($past(Crc[29]) ^ $past(Crc[30]) ^ $past(Crc[31]) ^ $past(Crc[28])))
    );

// With enable high and data 15, bit 1 follows the previous bit 30 XOR 31 XOR 28 XOR 29.
    check_bit1_follows_bit30_xor_bit31_xor_bit28_xor_bit29_when_enabled_and_data15: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'hF) |=> (Crc[1] == ($past(Crc[30]) ^ $past(Crc[31]) ^ $past(Crc[28]) ^ $past(Crc[29])))
    );

// With enable high and data 0, bit 2 is cleared.
    check_bit2_clears_when_enabled_and_data0: assert property (
        @(posedge Clk) disable iff (Reset) (Initialize == 1'b0) && (Enable == 1'b1) && (Data == 4'h0) |=> (Crc[2] == 1'b0)
    );

// With enable high and data 1, bit 2 follows the previous bit 29.
    check_bit2