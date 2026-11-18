module RMON_addr_gen_sva (
    input logic        Clk,
    input logic        Reset,
    input logic [2:0]  Pkt_type_rmon,
    input logic [15:0] Pkt_length_rmon,
    input logic        Apply_rmon,
    input logic [2:0]  Pkt_err_type_rmon,
    input logic        Reg_apply,
    input logic [4:0]  Reg_addr,
    input logic [15:0] Reg_data,
    input logic        Reg_next,
    input logic        Reg_drop_apply
);

    ///// Reset behavior /////
    // During reset, Reg_apply must be 0.
    reset_reg_apply_low: assert property (
        @(posedge Clk) Reset |-> (Reg_apply == 1'b0)
    );
    // During reset, Reg_drop_apply must be 0.
    reset_reg_drop_apply_low: assert property (
        @(posedge Clk) Reset |-> (Reg_drop_apply == 1'b0)
    );
    // During reset, Reg_addr must be 0.
    reset_reg_addr_zero: assert property (
        @(posedge Clk) Reset |-> (Reg_addr == 5'd0)
    );
    // During reset, Reg_data must be 0.
    reset_reg_data_zero: assert property (
        @(posedge Clk) Reset |-> (Reg_data == 16'd0)
    );

    ///// Reg_apply behavior /////
    // Reg_apply is high only in StatePktLength/Number/Type/Range.
    check_reg_apply_decode: assert property (
        @(posedge Clk) disable iff (Reset)
            Reg_apply == (CurrentState inside {StatePktLength, StatePktNumber, StatePktType, StatePktRange})
    );
    // Reg_apply is high only when CurrentState is not StateIdle.
    check_reg_apply_no_idle: assert property (
        @(posedge Clk) disable iff (Reset)
            Reg_apply == (CurrentState != StateIdle)
    );

    ///// Reg_addr behavior /////
    // In StatePktLength, Reg_addr is 0.
    check_reg_addr_pkt_length: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktLength) |-> (Reg_addr == 5'd0)
    );
    // In StatePktNumber, Reg_addr is 1.
    check_reg_addr_pkt_number: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktNumber) |-> (Reg_addr == 5'd1)
    );
    // In StatePktType, broadcast maps to 2, others to 4.
    check_reg_addr_pkt_type_decode: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktType) |-> (
                (PktTypeReg == 3'b011) ? (Reg_addr == 5'd2) :
                (PktTypeReg == 3'b001) ? (Reg_addr == 5'd4) :
                                          (Reg_addr == 5'd4)
            )
    );
    // In StatePktRange, error 001 maps to 5.
    check_reg_addr_pkt_range_err001: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktRange && PktErrTypeReg == 3'b001) |-> (Reg_addr == 5'd5)
    );
    // In StatePktRange, error 010 maps to 6.
    check_reg_addr_pkt_range_err010: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktRange && PktErrTypeReg == 3'b010) |-> (Reg_addr == 5'd6)
    );
    // In StatePktRange, error 011 maps to 7.
    check_reg_addr_pkt_range_err011: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktRange && PktErrTypeReg == 3'b011) |-> (Reg_addr == 5'd7)
    );
    // In StatePktRange, length < 64 maps to 8.
    check_reg_addr_pkt_range_len_lt64: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktRange && PktLengthReg < 16'd64) |-> (Reg_addr == 5'd8)
    );
    // In StatePktRange, length == 64 maps to 9.
    check_reg_addr_pkt_range_len_eq64: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktRange && PktLengthReg == 16'd64) |-> (Reg_addr == 5'd9)
    );
    // In StatePktRange, 64 < length < 128 maps to 10.
    check_reg_addr_pkt_range_len_64to127: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktRange && PktLengthReg >= 16'd65 && PktLengthReg < 16'd128) |-> (Reg_addr == 5'd10)
    );
    // In StatePktRange, 128 <= length < 256 maps to 11.
    check_reg_addr_pkt_range_len_128to255: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktRange && PktLengthReg >= 16'd128 && PktLengthReg < 16'd256) |-> (Reg_addr == 5'd11)
    );
    // In StatePktRange, 256 <= length < 512 maps to 12.
    check_reg_addr_pkt_range_len_256to511: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktRange && PktLengthReg >= 16'd256 && PktLengthReg < 16'd512) |-> (Reg_addr == 5'd12)
    );
    // In StatePktRange, 512 <= length < 1024 maps to 13.
    check_reg_addr_pkt_range_len_512to1023: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktRange && PktLengthReg >= 16'd512 && PktLengthReg < 16'd1024) |-> (Reg_addr == 5'd13)
    );
    // In StatePktRange, 1024 <= length < 1519 maps to 14.
    check_reg_addr_pkt_range_len_1024to1518: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktRange && PktLengthReg >= 16'd1024 && PktLengthReg < 16'd1519) |-> (Reg_addr == 5'd14)
    );
    // In StatePktRange, length >= 1519 maps to 15.
    check_reg_addr_pkt_range_len_ge1519: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktRange && PktLengthReg >= 16'd1519) |-> (Reg_addr == 5'd15)
    );
    // In all other states, Reg_addr is 5.
    check_reg_addr_default: assert property (
        @(posedge Clk) disable iff (Reset)
            !(CurrentState inside {StatePktLength, StatePktNumber, StatePktType, StatePktRange}) |-> (Reg_addr == 5'd5)
    );

    ///// Reg_data behavior /////
    // In StatePktLength, Reg_data equals Pkt_length_rmon.
    check_reg_data_pkt_length: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktLength) |-> (Reg_data == Pkt_length_rmon)
    );
    // In StatePktNumber, Reg_data is 1.
    check_reg_data_pkt_number: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktNumber) |-> (Reg_data == 16'd1)
    );
    // In StatePktType, Reg_data is 1.
    check_reg_data_pkt_type: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktType) |-> (Reg_data == 16'd1)
    );
    // In StatePktRange, Reg_data is 1.
    check_reg_data_pkt_range: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == StatePktRange) |-> (Reg_data == 16'd1)
    );
    // In all other states, Reg_data is 0.
    check_reg_data_default_zero: assert property (
        @(posedge Clk) disable iff (Reset)
            !(CurrentState inside {StatePktLength, StatePktNumber, StatePktType, StatePktRange}) |-> (Reg_data == 16'd0)
    );

    ///// Reg_drop_apply behavior /////
    // Reg_drop_apply is high only when not idle and Apply_rmon_pulse is high.
    check_reg_drop_apply_decode: assert property (
        @(posedge Clk) disable iff (Reset)
            Reg_drop_apply == ((!CurrentState inside {StateIdle}) && Apply_rmon_pulse)
    );
    // Reg_drop_apply is high only when CurrentState is not StateIdle.
    check_reg_drop_apply_no_idle: assert property (
        @(posedge Clk) disable iff (Reset)
            Reg_drop_apply == (CurrentState != StateIdle)
    );

endmodule