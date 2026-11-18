module eth_crc_sva (
    input logic        Clk,
    input logic        Reset,
    input logic [3:0]  Data,
    input logic        Enable,
    input logic        Initialize,
    input logic [31:0] Crc,
    input logic        CrcError
);

    // Reset drives the CRC to all ones.
    check_reset_value: assert property (
        @(posedge Clk) Reset |-> (Crc == 32'hffffffff)
    );

    // Initialize drives the CRC to all ones when reset is low.
    check_initialize_value: assert property (
        @(posedge Clk) disable iff (Reset) Initialize |-> (Crc == 32'hffffffff)
    );

    // CrcError is high whenever the CRC does not match the magic value.
    check_crc_error_high_when_mismatch: assert property (
        @(posedge Clk) disable iff (Reset)
        (Crc != 32'hc704dd7b) |-> (CrcError == 1'b1)
    );

    // CrcError is low whenever the CRC matches the magic value.
    check_crc_error_low_when_match: assert property (
        @(posedge Clk) disable iff (Reset)
        (Crc == 32'hc704dd7b) |-> (CrcError == 1'b0)
    );

    // CrcError is a direct function of the CRC value.
    check_crc_error_matches_crc: assert property (
        @(posedge Clk) disable iff (Reset)
        CrcError == (Crc != 32'hc704dd7b)
    );

    // The upper 16 bits of the CRC are always zero after reset or initialize.
    check_upper_half_zero: assert property (
        @(posedge Clk) disable iff (Reset)
        (Crc[31:16] == 16'h0000)
    );

    // Bit 15 is zero after reset or initialize.
    check_bit15_zero: assert property (
        @(posedge Clk) disable iff (Reset)
        (Crc[15] == 1'b0)
    );

    // Bit 14 is zero after reset or initialize.
    check_bit14_zero: assert property (
        @(posedge Clk) disable iff (Reset)
        (Crc[14] == 1'b0)
    );

    // Bit 13 is zero after reset or initialize.
    check_bit13_zero: assert property (
        @(posedge Clk) disable iff (Reset)
        (Crc[13] == 1'b0)
    );

    // Bit 12 is zero after reset or initialize.
    check_bit12_zero: assert property (
        @(posedge Clk) disable iff (Reset)
        (Crc[12] == 1'b0)
    );

endmodule