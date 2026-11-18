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

// Reg_apply is high when the state is not idle.
    check_reg_apply_active_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState != StateIdle) |-> (Reg_apply == 1'b1)
    );

// Reg_apply is low when the state is idle.
    check_reg_apply_idle_state: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateIdle) |-> (Reg_apply == 1'b0)
    );

// Reg_addr is 0 when the state is idle.
    check_reg_addr_idle_state: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateIdle) |-> (Reg_addr == 5'd0)
    );

// Reg_addr is 1 when the state is StatePktNumber.
    check_reg_addr_pkt_number_state: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktNumber) |-> (Reg_addr == 5'd1)
    );

// Reg_addr is 2 when the packet type is broadcast.
    check_reg_addr_pkt_type_broadcast: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktType && PktTypeReg == 3'b011) |-> (Reg_addr == 5'd2)
    );

// Reg_addr is 3 when the packet type is multicast.
    check_reg_addr_pkt_type_multicast: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktType && PktTypeReg == 3'b001) |-> (Reg_addr == 5'd3)
    );

// Reg_addr is 16 when the packet type is pause frame.
    check_reg_addr_pkt_type_pause: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktType && PktTypeReg == 3'b100) |-> (Reg_addr == 5'd16)
    );

// Reg_addr is 4 for all other packet types.
    check_reg_addr_pkt_type_default: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktType &&
         !(PktTypeReg == 3'b011 || PktTypeReg == 3'b001 || PktTypeReg == 3'b100)) |-> (Reg_addr == 5'd4)
    );

// Reg_addr is 5 when the error type is 001.
    check_reg_addr_err_type_001: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktRange && Pkt_err_type_rmon == 3'b001) |-> (Reg_addr == 5'd5)
    );

// Reg_addr is 6 when the error type is 010.
    check_reg_addr_err_type_010: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktRange && Pkt_err_type_rmon == 3'b010) |-> (Reg_addr == 5'd6)
    );

// Reg_addr is 7 when the error type is 011.
    check_reg_addr_err_type_011: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktRange && Pkt_err_type_rmon == 3'b011) |-> (Reg_addr == 5'd7)
    );

// Reg_addr is 8 for lengths below 64 bytes.
    check_reg_addr_len_0_to_63: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktRange && Pkt_err_type_rmon == 3'b100 && Pkt_length_rmon < 16'd64) |-> (Reg_addr == 5'd8)
    );

// Reg_addr is 9 for lengths equal to 64 bytes.
    check_reg_addr_len_64: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktRange && Pkt_err_type_rmon == 3'b100 && Pkt_length_rmon == 16'd64) |-> (Reg_addr == 5'd9)
    );

// Reg_addr is 10 for lengths below 128 bytes.
    check_reg_addr_len_65_to_127: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktRange && Pkt_err_type_rmon == 3'b100 && Pkt_length_rmon < 16'd128) |-> (Reg_addr == 5'd10)
    );

// Reg_addr is 11 for lengths below 256 bytes.
    check_reg_addr_len_128_to_255: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktRange && Pkt_err_type_rmon == 3'b100 && Pkt_length_rmon < 16'd256) |-> (Reg_addr == 5'd11)
    );

// Reg_addr is 12 for lengths below 512 bytes.
    check_reg_addr_len_256_to_511: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktRange && Pkt_err_type_rmon == 3'b100 && Pkt_length_rmon < 16'd512) |-> (Reg_addr == 5'd12)
    );

// Reg_addr is 13 for lengths below 1024 bytes.
    check_reg_addr_len_512_to_1023: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktRange && Pkt_err_type_rmon == 3'b100 && Pkt_length_rmon < 16'd1024) |-> (Reg_addr == 5'd13)
    );

// Reg_addr is 14 for lengths below 1519 bytes.
    check_reg_addr_len_1024_to_1518: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktRange && Pkt_err_type_rmon == 3'b100 && Pkt_length_rmon < 16'd1519) |-> (Reg_addr == 5'd14)
    );

// Reg_addr is 15 for lengths of 1519 bytes or more.
    check_reg_addr_len_1519_and_above: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StatePktRange && Pkt_err_type_rmon == 3'b100 && Pkt_length_rmon >= 16'd1519) |-> (Reg_addr == 5'd15)
    );

// Reg_data is 1 for all active states.
    check_reg_data_active_states: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState != StateIdle) |-> (Reg_data == 16'd1)
    );

// Reg_data is 0 when the state is idle.
    check_reg_data_idle_state: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateIdle) |-> (Reg_data == 16'd0)
    );

// Reg_drop_apply is high when the state is not idle and Apply_rmon is high.
    check_reg_drop_apply_active_condition: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState != StateIdle && Apply_rmon) |-> (Reg_drop_apply == 1'b1)
    );

// Reg_drop_apply is low when the state is idle or Apply_rmon is low.
    check_reg_drop_apply_inactive_condition: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateIdle || !Apply_rmon) |-> (Reg_drop_apply == 1'b0)
    );

endmodule
