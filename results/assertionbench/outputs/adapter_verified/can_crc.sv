module can_crc_sva (
    input logic clk,
    input logic data,
    input logic enable,
    input logic initialize,
    input logic [14:0] crc
);

// Clock: clk (posedge). Reset: none. Logic: sequential (register with next-state logic).

    // On initialize, next cycle crc becomes 15'h0.
    check_initialize_clears_crc: assert property (
        @(posedge clk) initialize |=> (crc == 15'h0)
    );

// When enable=0, crc holds its value.
    check_hold_when_disabled: assert property (
        @(posedge clk) !enable |=> (crc == $past(crc))
    );

// When enable=1 and data=0, crc[14] becomes 0.
    check_bit0_clears_bit14: assert property (
        @(posedge clk) (enable && !data) |=> (crc[14] == 1'b0)
    );

// When enable=1 and data=1, crc[14] becomes 1.
    check_bit1_sets_bit14: assert property (
        @(posedge clk) (enable && data) |=> (crc[14] == 1'b1)
    );

// When enable=1 and data=0, crc[13:0] shifts left by 1.
    check_shift_left_when_disabled: assert property (
        @(posedge clk) (enable && !data) |=> (crc[13:0] == $past(crc[12:0]))
    );

// When enable=1 and data=1, crc[13:0] shifts left by 1 and XOR with 15'h4599[13:0].
    check_shift_xor_when_enabled: assert property (
        @(posedge clk) (enable && data) |=> (crc[13:0] == ($past(crc[12:0]) ^ 15'h4599[13:0]))
    );

// When enable=1 and data=1, crc equals previous crc[12:0] shifted left by 1 XOR 15'h4599[13:0].
    check_full_update_when_enabled: assert property (
        @(posedge clk) (enable && data) |=> (crc == (($past(crc[12:0]) ^ 15'h4599[13:0]) << 1))
    );

// When enable=1 and data=0, crc equals previous crc[12:0] shifted left by 1.
    check_full_update_when_disabled: assert property (
        @(posedge clk) (enable && !data) |=> (crc == ($past(crc[12:0]) << 1))
    );

endmodule
