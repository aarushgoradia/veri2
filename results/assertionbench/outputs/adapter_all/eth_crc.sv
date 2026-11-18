module eth_crc_sva (
    input logic        Clk,
    input logic        Reset,
    input logic [3:0]  Data,
    input logic        Enable,
    input logic        Initialize,
    input logic [31:0] Crc,
    input logic        CrcError
);

    // Reset forces the CRC register to all ones.
    check_reset_sets_crc: assert property (
        @(posedge Clk) Reset |-> (Crc == 32'hffffffff)
    );

    // Initialize forces the CRC register to all ones.
    check_initialize_sets_crc: assert property (
        @(posedge Clk) disable iff (Reset) Initialize |-> (Crc == 32'hffffffff)
    );

    // CrcError is high whenever the CRC register does not match the magic value.
    check_crc_error_matches_magic: assert property (
        @(posedge Clk) disable iff (Reset) (CrcError == (Crc != 32'hc704dd7b))
    );

    // With no enable, the CRC register holds its value.
    check_hold_when_disabled: assert property (
        @(posedge Clk) disable iff (Reset) (!Initialize && !Enable) |-> (Crc == $past(Crc))
    );

    // With enable low, the upper 24 CRC bits hold their value.
    check_upper_bits_hold_when_enable_low: assert property (
        @(posedge Clk) disable iff (Reset) (!Initialize && !Enable) |-> (Crc[31:8] == $past(Crc[31:8]))
    );

    // With enable high, the upper 24 CRC bits shift left by three positions.
    check_upper_bits_shift_when_enable_high: assert property (
        @(posedge Clk) disable iff (Reset) (!Initialize && Enable) |-> (Crc[31:8] == $past(Crc[28:5]))
    );

    // With enable high, the low three CRC bits are computed from the prior state and current Data.
    check_low_bits_compute_when_enable_high: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Initialize && Enable) |-> (
            Crc[7:0] == {
                $past(Crc[6]),
                $past(Crc[5] ^ Data[3] ^ Data[2] ^ Data[1] ^ Data[0]),
                $past(Crc[4] ^ Data[3] ^ Data[2] ^ Data[1] ^ Data[0]),
                $past(Crc[3] ^ Data[3] ^ Data[2] ^ Data[1] ^ Data[0]),
                $past(Crc[2] ^ Data[2] ^ Data[1] ^ Data[0]),
                $past(Crc[1] ^ Data[1] ^ Data[0]),
                $past(Crc[0] ^ Data[0])
            }
        )
    );

    // With enable low, the low three CRC bits hold their value.
    check_low_bits_hold_when_enable_low: assert property (
        @(posedge Clk) disable iff (Reset) (!Initialize && !Enable) |-> (Crc[7:0] == $past(Crc[7:0]))
    );

    // With enable high, the CRC register updates to the computed next value.
    check_crc_updates_when_enable_high: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Initialize && Enable) |-> (
            Crc == {
                $past(Crc[28:5]),
                $past(Crc[6]),
                $past(Crc[5] ^ Data[3] ^ Data[2] ^ Data[1] ^ Data[0]),
                $past(Crc[4] ^ Data[3] ^ Data[2] ^ Data[1] ^ Data[0]),
                $past(Crc[3] ^ Data[3] ^ Data[2] ^ Data[1] ^ Data[0]),
                $past(Crc[2] ^ Data[2] ^ Data[1] ^ Data[0]),
                $past(Crc[1] ^ Data[1] ^ Data[0]),
                $past(Crc[0] ^ Data[0])
            }
        )
    );

endmodule