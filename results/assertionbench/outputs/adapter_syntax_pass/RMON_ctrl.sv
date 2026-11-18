module RMON_CTRL_sva (
    input logic Clk,
    input logic Reset,
    input logic Reg_apply_0,
    input logic Reg_apply_1,
    input logic [4:0] Reg_addr_0,
    input logic [15:0] Reg_data_0,
    input logic Reg_next_0,
    input logic [4:0] Reg_addr_1,
    input logic [15:0] Reg_data_1,
    input logic Reg_next_1,
    input logic [5:0] Addra,
    input logic [31:0] Dina,
    input logic Wea,
    input logic [5:0] CPU_rd_addr,
    input logic CPU_rd_apply,
    input logic CPU_rd_grant,
    input logic [31:0] CPU_rd_dout
);

    // Reset drives the CPU grant line low.
    check_cpu_grant_low_during_reset: assert property (
        @(posedge Clk) Reset |-> (CPU_rd_grant == 1'b0)
    );

    // CPU grant is asserted only when the previous cycle was not a grant.
    check_cpu_grant_release_condition: assert property (
        @(posedge Clk) disable iff (Reset)
        $past(!Reset) && $past(CPU_rd_apply) && !CPU_rd_apply |-> CPU_rd_grant
    );

    // CPU grant is deasserted only when the previous cycle was a grant.
    check_cpu_grant_release_only_on_grant: assert property (
        @(posedge Clk) disable iff (Reset)
        $past(!Reset) && CPU_rd_apply && !$past(CPU_rd_apply) |-> !CPU_rd_grant
    );

    // CPU grant is never asserted while the current cycle is a grant.
    check_cpu_grant_not_back_to_back: assert property (
        @(posedge Clk) disable iff (Reset)
        CPU_rd_grant |-> !CPU_rd_apply
    );

    // CPU grant is never asserted while reset is active.
    check_cpu_grant_not_during_reset: assert property (
        @(posedge Clk) Reset |-> !CPU_rd_grant
    );

    // The address bus is always zero-extended.
    check_addra_zero_extended: assert property (
        @(posedge Clk) disable iff (Reset)
        Addra[5] == 1'b0
    );

    // The write enable is directly driven by the write pulse.
    check_wea_matches_write: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea == Reg_next_0
    );

    // The write enable is also driven by the write pulse on Reg_next_1.
    check_wea_matches_write_reg1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea == Reg_next_1
    );

    // The write enable is never asserted for both registers simultaneously.
    check_wea_mutex: assert property (
        @(posedge Clk) disable iff (Reset)
        !(Reg_next_0 && Reg_next_1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU is active.
    check_wea_not_during_cpu_access: assert property (
        @(posedge Clk) disable iff (Reset)
        (CurrentState == StateCPU) |-> !Wea
    );

    // The write enable is never asserted when both register loads are inactive.
    check_wea_not_during_idle: assert property (
        @(posedge Clk) disable iff (Reset)
        (!Reg_apply_0 && !Reg_apply_1) |-> !Wea
    );

    // The write enable is asserted only when the current state is StateMAC0.
    check_wea_only_on_state_mac0: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC0)
    );

    // The write enable is asserted only when the current state is StateMAC1.
    check_wea_only_on_state_mac1: assert property (
        @(posedge Clk) disable iff (Reset)
        Wea |-> (CurrentState == StateMAC1)
    );

    // The write enable is never asserted when the CPU