module RMON_addr_gen_sva (
    input logic Clk,
    input logic Reset,
    input logic [2:0] Pkt_type_rmon,
    input logic [15:0] Pkt_length_rmon,
    input logic Apply_rmon,
    input logic [2:0] Pkt_err_type_rmon,
    input logic Reg_apply,
    input logic [4:0] Reg_addr,
    input logic [15:0] Reg_data,
    input logic Reg_next,
    input logic Reg_drop_apply
);

    // Reset clears the address register to 5'h05.
    check_reset_clears_reg_addr: assert property (
        @(posedge Clk) Reset |-> (Reg_addr == 5'h05)
    );

    // Reset clears the drop-apply flag.
    check_reset_clears_reg_drop_apply: assert property (
        @(posedge Clk) Reset |-> (Reg_drop_apply == 1'b0)
    );

    // Reg_apply is asserted while the state machine is active.
    check_reg_apply_active_during_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Reg_apply == 1'b1)
    );

    // Reg_apply is deasserted in the idle state.
    check_reg_apply_deasserted_in_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (Reg_addr == 5'h05) |-> (Reg_apply == 1'b0)
    );

    // Reg_data is driven high in all active states.
    check_reg_data_high_in_active_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (Reg_data == 16'h0001)
    );

    // Reg_data is driven low in the idle state.
    check_reg_data_low_in_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (Reg_addr == 5'h05) |-> (Reg_data == 16'h0000)
    );

    // Reg_drop_apply is asserted only when Apply_rmon is high and the state is not idle.
    check_reg_drop_apply_definition: assert property (
        @(posedge Clk) disable iff (Reset)
        (Reg_drop_apply == (Apply_rmon && (Reg_addr != 5'h05)))
    );

    // Reg_drop_apply is a single-cycle pulse.
    check_reg_drop_apply_single_cycle: assert property (
        @(posedge Clk) disable iff (Reset)
        Reg_drop_apply |=> !Reg_drop_apply
    );

    // Reg_drop_apply is never asserted in reset.
    check_reg_drop_apply_during_reset: assert property (
        @(posedge Clk) Reset |-> !Reg_drop_apply
    );

    // Reg_addr is 5'h00 in the packet-length state.
    check_reg_addr_packet_length: assert property (
        @(posedge Clk) disable iff (Reset)
        (Reg_addr == 5'h00)
    );

    // Reg_addr is 5'h01 in the packet-number state.
    check_reg_addr_packet_number: assert property (
        @(posedge Clk) disable iff (Reset)
        (Reg_addr == 5'h01)
    );

    // Reg_addr is 5'h02 in the broadcast-type state.
    check_reg_addr_broadcast_type: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h02) && (Pkt_type_rmon == 3'b011))
    );

    // Reg_addr is 5'h03 in the multicast-type state.
    check_reg_addr_multicast_type: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h03) && (Pkt_type_rmon == 3'b001))
    );

    // Reg_addr is 5'h16 in the pause-frame-type state.
    check_reg_addr_pause_type: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h16) && (Pkt_type_rmon == 3'b100))
    );

    // Reg_addr is 5'h04 in the unicast-type state.
    check_reg_addr_unicast_type: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h04) && (Pkt_type_rmon != 3'b011) &&
         (Pkt_type_rmon != 3'b001) && (Pkt_type_rmon != 3'b100))
    );

    // Reg_addr is 5'h05 in the error-code state with code 001.
    check_reg_addr_error_code_001: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h05) && (Pkt_err_type_rmon == 3'b001))
    );

    // Reg_addr is 5'h06 in the error-code state with code 010.
    check_reg_addr_error_code_010: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h06) && (Pkt_err_type_rmon == 3'b010))
    );

    // Reg_addr is 5'h07 in the error-code state with code 011.
    check_reg_addr_error_code_011: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h07) && (Pkt_err_type_rmon == 3'b011))
    );

    // Reg_addr is 5'h08 in the error-code state with code 100 and length < 64.
    check_reg_addr_error_code_100_length_lt_64: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h08) && (Pkt_err_type_rmon == 3'b100) &&
         (Pkt_length_rmon < 16'd64))
    );

    // Reg_addr is 5'h09 in the error-code state with code 100 and length == 64.
    check_reg_addr_error_code_100_length_eq_64: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h09) && (Pkt_err_type_rmon == 3'b100) &&
         (Pkt_length_rmon == 16'd64))
    );

    // Reg_addr is 5'h10 in the error-code state with code 100 and length < 128.
    check_reg_addr_error_code_100_length_lt_128: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h10) && (Pkt_err_type_rmon == 3'b100) &&
         (Pkt_length_rmon < 16'd128))
    );

    // Reg_addr is 5'h11 in the error-code state with code 100 and length < 256.
    check_reg_addr_error_code_100_length_lt_256: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h11) && (Pkt_err_type_rmon == 3'b100) &&
         (Pkt_length_rmon < 16'd256))
    );

    // Reg_addr is 5'h12 in the error-code state with code 100 and length < 512.
    check_reg_addr_error_code_100_length_lt_512: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h12) && (Pkt_err_type_rmon == 3'b100) &&
         (Pkt_length_rmon < 16'd512))
    );

    // Reg_addr is 5'h13 in the error-code state with code 100 and length < 1024.
    check_reg_addr_error_code_100_length_lt_1024: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h13) && (Pkt_err_type_rmon == 3'b100) &&
         (Pkt_length_rmon < 16'd1024))
    );

    // Reg_addr is 5'h14 in the error-code state with code 100 and length < 1519.
    check_reg_addr_error_code_100_length_lt_1519: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h14) && (Pkt_err_type_rmon == 3'b100) &&
         (Pkt_length_rmon < 16'd1519))
    );

    // Reg_addr is 5'h15 in the error-code state with code 100 and length >= 1519.
    check_reg_addr_error_code_100_length_ge_1519: assert property (
        @(posedge Clk) disable iff (Reset)
        ((Reg_addr == 5'h15) && (Pkt_err_type_rmon == 3'b100) &&
         (Pkt_length_rmon >= 16'd1519))
    );

endmodule