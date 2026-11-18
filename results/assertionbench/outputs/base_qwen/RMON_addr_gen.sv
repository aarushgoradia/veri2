```systemverilog
module RMON_addr_gen_sva (
    input logic Clk,
    input logic Reset,
    input logic [2:0] Pkt_type_rmon,
    input logic [15:0] Pkt_length_rmon,
    input logic Apply_rmon,
    input logic [2:0] Pkt_err_type_rmon,
    output logic Reg_apply,
    output logic [4:0] Reg_addr,
    output logic [15:0] Reg_data,
    input logic Reg_next,
    output logic Reg_drop_apply
);
    // Reset handling
    reset: assert property (
        @(posedge Clk) disable iff (!Reset) (Reg_apply == 1'b0) && (Reg_addr == 5'd0) && (Reg_data == 16'd0) && (Reg_drop_apply == 1'b0)
    ) else $error("Reset did not properly reset the outputs");

    // Apply_rmon pulse generation
    apply_rmon_pulse: assert property (
        @(posedge Clk) disable iff (!Reset) (Apply_rmon_dl1 & !Apply_rmon_dl2) |-> Apply_rmon_pulse == 1'b1
    ) else $error("Apply_rmon pulse generation failed");

    // State machine transitions
    state_transition_idle_to_pkt_length: assert property (
        @(posedge Clk) disable iff (!Reset) (Apply_rmon_pulse && CurrentState == StateIdle) |-> NextState == StatePktLength
    ) else $error("State transition from idle to pkt length failed");

    state_transition_pkt_length_to_pkt_number: assert property (
        @(posedge Clk) disable iff (!Reset) (Reg_next && CurrentState == StatePktLength) |-> NextState == StatePktNumber
    ) else $error("State transition from pkt length to pkt number failed");

    state_transition_pkt_number_to_pkt_type: assert property (
        @(posedge Clk) disable iff (!Reset) (Reg_next && CurrentState == StatePktNumber) |-> NextState == StatePktType
    ) else $error("State transition from pkt number to pkt type failed");

    state_transition_pkt_type_to_pkt_range: assert property (
        @(posedge Clk) disable iff (!Reset) (Reg_next && CurrentState == StatePktType) |-> NextState == StatePktRange
    ) else $error("State transition from pkt type to pkt range failed");

    state_transition_pkt_range_to_idle: assert property (
        @(posedge Clk) disable iff (!Reset) (Reg_next && CurrentState == StatePktRange) |-> NextState == StateIdle
    ) else $error("State transition from pkt range to idle failed");

    // Reg_apply generation
    reg_apply_generation: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktLength || CurrentState == StatePktNumber || CurrentState == StatePktType || CurrentState == StatePktRange) |-> Reg_apply == 1'b1
    ) else $error("Reg_apply generation failed");

    // Reg_addr generation
    reg_addr_generation: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktLength) |-> Reg_addr == 5'd00
    ) else $error("Reg_addr generation for pkt length failed");

    reg_addr_generation_pkt_number: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktNumber) |-> Reg_addr == 5'd01
    ) else $error("Reg_addr generation for pkt number failed");

    reg_addr_generation_pkt_type: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktType) |-> Reg_addr == 5'd04
    ) else $error("Reg_addr generation for pkt type failed");

    reg_addr_generation_pkt_range: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktRange && PktLengthReg < 64) |-> Reg_addr == 5'd08
    ) else $error("Reg_addr generation for pkt range less than 64 failed");

    reg_addr_generation_pkt_range_64: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktRange && PktLengthReg == 64) |-> Reg_addr == 5'd09
    ) else $error("Reg_addr generation for pkt range equal to 64 failed");

    reg_addr_generation_pkt_range_128: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktRange && PktLengthReg < 128) |-> Reg_addr == 5'd10
    ) else $error("Reg_addr generation for pkt range less than 128 failed");

    reg_addr_generation_pkt_range_256: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktRange && PktLengthReg < 256) |-> Reg_addr == 5'd11
    ) else $error("Reg_addr generation for pkt range less than 256 failed");

    reg_addr_generation_pkt_range_512: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktRange && PktLengthReg < 512) |-> Reg_addr == 5'd12
    ) else $error("Reg_addr generation for pkt range less than 512 failed");

    reg_addr_generation_pkt_range_1024: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktRange && PktLengthReg < 1024) |-> Reg_addr == 5'd13
    ) else $error("Reg_addr generation for pkt range less than 1024 failed");

    reg_addr_generation_pkt_range_1519: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktRange && PktLengthReg < 1519) |-> Reg_addr == 5'd14
    ) else $error("Reg_addr generation for pkt range less than 1519 failed");

    // Reg_data generation
    reg_data_generation: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktLength) |-> Reg_data == PktLengthReg
    ) else $error("Reg_data generation for pkt length failed");

    reg_data_generation_pkt_number: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktNumber) |-> Reg_data == 16'd1
    ) else $error("Reg_data generation for pkt number failed");

    reg_data_generation_pkt_type: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktType) |-> Reg_data == 16'd1
    ) else $error("Reg_data generation for pkt type failed");

    reg_data_generation_pkt_range: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState == StatePktRange) |-> Reg_data == 16'd1
    ) else $error("Reg_data generation for pkt range failed");

    // Reg_drop_apply generation
    reg_drop_apply_generation: assert property (
        @(posedge Clk) disable iff (!Reset) (CurrentState != StateIdle && Apply_rmon_pulse) |-> Reg_drop_apply == 1'b1
    ) else $error("Reg_drop_apply generation failed");

endmodule
```