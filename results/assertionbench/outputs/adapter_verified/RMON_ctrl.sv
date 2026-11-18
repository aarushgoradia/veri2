module RMON_CTRL_sva (
    input logic Clk,
    input logic Reset,
    input logic Reg_apply_0,
    input logic Reg_apply_1,
    input logic [4:0] Reg_addr_0,
    input logic [4:0] Reg_addr_1,
    input logic [15:0] Reg_data_0,
    input logic [15:0] Reg_data_1,
    input logic Reg_next_0,
    input logic Reg_next_1,
    input logic [5:0] Addra,
    input logic [31:0] Dina,
    input logic Wea,
    input logic [5:0] CPU_rd_addr,
    input logic CPU_rd_apply,
    input logic CPU_rd_grant,
    input logic [31:0] CPU_rd_dout
);

// CPU grant is asserted exactly when the CPU is requesting and the current state is not CPU.
    check_cpu_grant_definition: assert property (
        @(posedge Clk) disable iff (Reset)
        CPU_rd_grant == (CPU_rd_apply && (CurrentState != StateCPU))
    );

// CPU grant is never asserted when the CPU is not requesting.
    check_cpu_grant_no_when_not_apply: assert property (
        @(posedge Clk) disable iff (Reset)
        !CPU_rd_apply |-> !CPU_rd_grant
    );

// CPU grant is never asserted when the current state is CPU.
    check_cpu_grant_no_when_cpu_state: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !CPU_rd_grant
    );

// CPU grant can only rise when the CPU is requesting and the current state is not CPU.
    check_cpu_grant_rise_condition: assert property (
        @(posedge Clk) disable iff (Reset)
        $rose(CPU_rd_grant) |-> (CPU_rd_apply && (CurrentState != StateCPU))
    );

// CPU grant can only fall when the CPU is not requesting or the current state is CPU.
    check_cpu_grant_fall_condition: assert property (
        @(posedge Clk) disable iff (Reset)
        $fell(CPU_rd_grant) |-> (!CPU_rd_apply || (CurrentState == StateCPU))
    );

// CPU grant is stable across consecutive cycles.
    check_cpu_grant_stable: assert property (
        @(posedge Clk) disable iff (Reset)
        $stable(CPU_rd_grant)
    );

// CPU grant is low across consecutive cycles.
    check_cpu_grant_low_stable: assert property (
        @(posedge Clk) disable iff (Reset)
        !CPU_rd_grant |-> $stable(CPU_rd_grant)
    );

// CPU grant is high across consecutive cycles.
    check_cpu_grant_high_stable: assert property (
        @(posedge Clk) disable iff (Reset)
        CPU_rd_grant |-> $stable(CPU_rd_grant)
    );

endmodule
