```systemverilog
module can_register_asyn_syn_sva (
    input logic clk,
    input logic rst,
    input logic rst_sync,
    input logic [WIDTH-1:0] data_in,
    input logic we,
    output logic [WIDTH-1:0] data_out
);
    parameter WIDTH = 8;
    parameter RESET_VALUE = 0;

    // At reset, data_out should be driven to the reset value
    reset: assert property (
        @(posedge clk) disable iff (!rst) data_out == RESET_VALUE
    ) else $error("data_out not reset to %0d at reset", RESET_VALUE);

    // When rst_sync is asserted, data_out should be driven to the reset value
    sync_reset: assert property (
        @(posedge clk) disable iff (!rst) rst_sync |-> data_out == RESET_VALUE
    ) else $error("data_out not reset to %0d at synchronous reset", RESET_VALUE);

    // When write enable is high, data_out should be driven to data_in
    write_enable: assert property (
        @(posedge clk) disable iff (!rst) we |-> data_out == data_in
    ) else $error("data_out not updated to data_in on write enable");

    // When write enable is low, data_out should remain unchanged
    no_write: assert property (
        @(posedge clk) disable iff (!rst) !we |-> data_out == data_out
    ) else $error("data_out changed on write disable");

    // Synchronous reset should take precedence over asynchronous reset
    reset_precedence: assert property (
        @(posedge clk) disable iff (!rst) rst_sync |-> rst == 1'b0
    ) else $error("asynchronous reset active when synchronous reset is asserted");

    // Asynchronous reset should not affect data_out when synchronous reset is active
    async_reset_during_sync: assert property (
        @(posedge clk) disable iff (!rst) rst_sync |-> rst |-> data_out == data_out
    ) else $error("data_out changed during synchronous reset with asynchronous reset active");

    // Data_out should not change during a synchronous reset
    data_out_during_sync_reset: assert property (
        @(posedge clk) disable iff (!rst) rst_sync |-> data_out == data_out
    ) else $error("data_out changed during synchronous reset");

    // Data_out should not change during an asynchronous reset
    data_out_during_async_reset: assert property (
        @(posedge clk) disable iff (!rst) rst |-> data_out == data_out
    ) else $error("data_out changed during asynchronous reset");

    // Data_out should not change when both resets are active
    data_out_during_both_resets: assert property (
        @(posedge clk) disable iff (!rst) rst && rst_sync |-> data_out == data_out
    ) else $error("data_out changed during both synchronous and asynchronous resets");

    // Data_out should not change when both resets are deasserted
    data_out_during_no_resets: assert property (
        @(posedge clk) disable iff (!rst) !rst && !rst_sync |-> data_out == data_out
    ) else $error("data_out changed during no resets");

endmodule
```