module RMON_CTRL_sva (
    input logic        Clk,
    input logic        Reset,
    input logic        Reg_apply_0,
    input logic        Reg_apply_1,
    input logic [4:0]  Reg_addr_0,
    input logic [15:0] Reg_data_0,
    input logic        Reg_next_0,
    input logic [4:0]  Reg_addr_1,
    input logic [15:0] Reg_data_1,
    input logic        Reg_next_1,
    input logic [5:0]  Addra,
    input logic [31:0] Dina,
    input logic        Wea,
    input logic [5:0]  CPU_rd_addr,
    input logic        CPU_rd_apply,
    input logic        CPU_rd_grant,
    input logic [31:0] CPU_rd_dout
);

    ///// Reset behavior /////
    // During reset, CPU grant must be LOW.
    reset_grant_low: assert property (
        @(posedge Clk) Reset |-> (CPU_rd_grant == 1'b0)
    );

    ///// CPU grant behavior /////
    // CPU grant is the inverse of CPU_rd_apply_reg.
    check_grant_inverts_reg: assert property (
        @(posedge Clk) disable iff (Reset) (CPU_rd_grant == !CPU_rd_apply_reg)
    );

    // CPU grant can only rise when CPU_rd_apply was HIGH in the previous cycle.
    check_grant_rise_requires_prev_apply: assert property (
        @(posedge Clk) disable iff (Reset) $rose(CPU_rd_grant) |-> $past(CPU_rd_apply)
    );

    // CPU grant can only fall when CPU_rd_apply was LOW in the previous cycle.
    check_grant_fall_requires_prev_not_apply: assert property (
        @(posedge Clk) disable iff (Reset) $fell(CPU_rd_grant) |-> !$past(CPU_rd_apply)
    );

    // If CPU_rd_apply was HIGH in the previous cycle, grant must be LOW now.
    check_prev_apply_forces_grant_low: assert property (
        @(posedge Clk) disable iff (Reset) $past(CPU_rd_apply) |-> (CPU_rd_grant == 1'b0)
    );

    ///// Address and data mapping /////
    // Addra selects CPU_rd_addr when in StateCPU.
    check_addra_selects_cpu_addr: assert property (
        @(posedge Clk) disable iff (Reset) (CurrentState == 4'd00) |-> (Addra == CPU_rd_addr)
    );

    // Addra selects Reg_addr_0 when in StateMAC0.
    check_addra_selects_mac0_addr: assert property (
        @(posedge Clk) disable iff (Reset) (CurrentState == 4'd01) |-> (Addra == {1'd0, Reg_addr_0})
    );

    // Addra selects Reg_addr_1 when in StateMAC1.
    check_addra_selects_mac1_addr: assert property (
        @(posedge Clk) disable iff (Reset) (CurrentState == 4'd02) |-> (Addra == {1'd1, Reg_addr_1})
    );

    // Dina is zero when not in StateCPU.
    check_dina_zero_outside_cpu: assert property (
        @(posedge Clk) disable iff (Reset) (CurrentState != 4'd00) |-> (Dina == 32'h00000000)
    );

    // Dina is zero when in StateCPU and not in a write step.
    check_dina_zero_cpu_nonwrite: assert property (
        @(posedge Clk) disable iff (Reset) (CurrentState == 4'd00 && (StepCounter != 4'd3 && StepCounter != 4'd6 && StepCounter != 4'd9 && StepCounter != 4'd12)) |-> (Dina == 32'h00000000)
    );

    // In StateCPU write steps, Dina equals Douta plus the previous CPU_rd_dout.
    check_dina_cpu_write_step: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == 4'd00 &&
             (StepCounter == 4'd3 || StepCounter == 4'd6 || StepCounter == 4'd9 || StepCounter == 4'd12)) |->
            (Dina == (Douta + $past(CPU_rd_dout)))
    );

    ///// Pipeline and write enable /////
    // Wea is the direct pipeline of Write.
    check_wea_matches_write: assert property (
        @(posedge Clk) disable iff (Reset) (Wea == Write)
    );

    // Reg_next_0 is pipeline when in StateMAC0, else zero.
    check_reg_next0_pipeline: assert property (
        @(posedge Clk) disable iff (Reset) (CurrentState == 4'd01) |-> (Reg_next_0 == Pipeline)
    );

    // Reg_next_0 is zero when not in StateMAC0.
    check_reg_next0_zero_outside_mac0: assert property (
        @(posedge Clk) disable iff (Reset) (CurrentState != 4'd01) |-> (Reg_next_0 == 1'b0)
    );

    // Reg_next_1 is pipeline when in StateMAC1, else zero.
    check_reg_next1_pipeline: assert property (
        @(posedge Clk) disable iff (Reset) (CurrentState == 4'd02) |-> (Reg_next_1 == Pipeline)
    );

    // Reg_next_1 is zero when not in StateMAC1.
    check_reg_next1_zero_outside_mac1: assert property (
        @(posedge Clk) disable iff (Reset) (CurrentState != 4'd02) |-> (Reg_next_1 == 1'b0)
    );

    ///// Step counter and pipeline control /////
    // Read pulses occur at steps 1,4,7,10.
    check_read_pulses: assert property (
        @(posedge Clk) disable iff (Reset) (Read == (StepCounter inside {4'd1,4'd4,4'd7,4'd10}))
    );

    // Pipeline pulses occur at steps 2,5,8,11.
    check_pipeline_pulses: assert property (
        @(posedge Clk) disable iff (Reset) (Pipeline == (StepCounter inside {4'd2,4'd5,4'd8,4'd11}))
    );

    // Write pulses occur at steps 3,6,9,12.
    check_write_pulses: assert property (
        @(posedge Clk) disable iff (Reset) (Write == (StepCounter inside {4'd3,4'd6,4'd9,4'd12}))
    );

    // Pipeline and Write are never asserted together.
    check_pipeline_write_mutex: assert property (
        @(posedge Clk) disable iff (Reset) !(Pipeline && Write)
    );

    ///// CPU read data pipeline /////
    // CPU_rd_dout captures Douta when in StateCPU and Pipeline is asserted.
    check_cpu_rd_dout_capture: assert property (
        @(posedge Clk) disable iff (Reset)
            (CurrentState == 4'd00 && Pipeline) |->
            (CPU_rd_dout == Douta)
    );

    // CPU_rd_dout holds its value when not in StateCPU or not in Pipeline.
    check_cpu_rd_dout_hold: assert property (
        @(posedge Clk) disable iff (Reset)
            (!(CurrentState == 4'd00 && Pipeline)) |-> (CPU_rd_dout == $past(CPU_rd_dout))
    );

endmodule