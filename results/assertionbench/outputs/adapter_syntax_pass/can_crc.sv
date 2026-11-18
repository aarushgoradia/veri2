module can_crc_sva (
    input logic clk,
    input logic data,
    input logic enable,
    input logic initialize,
    input logic [14:0] crc
);

    // Initialize clears the CRC on the next clock.
    check_crc_clears_on_initialize: assert property (
        @(posedge clk) initialize |=> (crc == 15'h00000)
    );

    // With enable low, the CRC holds its value.
    check_crc_holds_when_disabled: assert property (
        @(posedge clk) disable iff (initialize)
        !enable |=> (crc == $past(crc))
    );

    // With enable high and data low, the CRC shifts left and inserts zero.
    check_crc_shift_on_data_low: assert property (
        @(posedge clk) disable iff (initialize)
        enable && !data |=> (crc == {$past(crc[13:0]), 1'b0})
    );

    // With enable high and data high, the CRC shifts left, inserts zero, and XORs with 0x4599.
    check_crc_shift_xor_on_data_high: assert property (
        @(posedge clk) disable iff (initialize)
        enable && data |=> (crc == (($past(crc[13:0]), 1'b0) ^ 15'h4599))
    );

endmodule