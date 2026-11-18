module can_crc_sva (
    input logic        clk,
    input logic        data,
    input logic        enable,
    input logic        initialize,
    input logic [14:0] crc
);

    // Initialize clears the CRC register.
    check_initialize_clears_crc: assert property (
        @(posedge clk) initialize |=> (crc == 15'h000)
    );

    // With enable low, the CRC register holds its value.
    check_hold_when_disabled: assert property (
        @(posedge clk) disable iff (initialize)
        !enable |=> (crc == $past(crc))
    );

    // With enable high and no bit error, the CRC shifts left and inserts zero.
    check_shift_when_no_error: assert property (
        @(posedge clk) disable iff (initialize)
        enable && !data |=> (crc == { $past(crc[13:0]), 1'b0 })
    );

    // With enable high and a bit error, the CRC shifts left, inserts zero, and XORs with 0x4599.
    check_shift_xor_on_error: assert property (
        @(posedge clk) disable iff (initialize)
        enable && data |=> (crc == { $past(crc[13:0]), 1'b0 } ^ 15'h4599)
    );

endmodule